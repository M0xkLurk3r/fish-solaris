# Copyright (C) 2005-2006 Axel Liljencrantz
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA
#

#
# Makefile.  Generated from Makefile.in by configure.
#

#
# Makefile for the fish shell. Can build fish and associated
# applications, install them, and recalculate dependencies.
#

# Used by docdir
PACKAGE_TARNAME = fish

#
# Programs
#

CXX := g++
INSTALL:=/usr/bin/ginstall -c
SED := /usr/bin/gsed


#
# Installation directories
#

prefix = /usr/local
exec_prefix = ${prefix}
datarootdir = ${prefix}/share
datadir = ${datarootdir}
bindir = ${exec_prefix}/bin
mandir = ${datarootdir}/man
sysconfdir = ${prefix}/etc
docdir = ${datarootdir}/doc/${PACKAGE_TARNAME}
localedir = ${datarootdir}/locale

#
# Various flags
#

MACROS = -DLOCALEDIR=\"$(localedir)\" -DPREFIX=L\"$(prefix)\" -DDATADIR=L\"$(datadir)\" -DSYSCONFDIR=L\"$(sysconfdir)\" -DBINDIR=L\"$(bindir)\" -DDOCDIR=L\"$(docdir)\"
CXXFLAGS = -g -O2 -D_LARGEFILE_SOURCE=1 -D_FILE_OFFSET_BITS=64 -fno-exceptions -Wall -Wno-sign-compare  $(MACROS) $(EXTRA_CXXFLAGS)
CPPFLAGS = 
LDFLAGS = 
LIBS = -lncurses -lsocket 
LDFLAGS_FISH = ${LDFLAGS}  -rdynamic

#
# Set to 1 if we have gettext
#

HAVE_GETTEXT=

#
# Set to 1 if we have doxygen
#

HAVE_DOXYGEN=0

#
#Additional .cpp files used by common.o. These also have a corresponding
#.h file.
#

COMMON_FILES := util.cpp fallback.cpp


#
# All objects that the system needs to build fish, except fish.o
#

FISH_OBJS := function.o builtin.o complete.o env.o exec.o expand.o		\
	highlight.o history.o kill.o parser.o proc.o reader.o sanity.o		\
	tokenizer.o wildcard.o wgetopt.o wutil.o input.o output.o intern.o	\
	env_universal_common.o input_common.o event.o		\
	signal.o io.o parse_util.o common.o screen.o path.o autoload.o		\
	parser_keywords.o iothread.o color.o postfork.o	\
	builtin_test.o parse_tree.o parse_productions.o parse_execution.o \
	pager.o utf8.o fish_version.o wcstringutil.o

FISH_INDENT_OBJS := fish_indent.o print_help.o $(FISH_OBJS) 

#
# Additional files used by builtin.o
#

BUILTIN_FILES := builtin_set.cpp builtin_commandline.cpp	\
	builtin_ulimit.cpp builtin_complete.cpp builtin_jobs.cpp	\
	builtin_set_color.cpp builtin_printf.cpp


#
# All objects that the system needs to build fish_tests
#

FISH_TESTS_OBJS := $(FISH_OBJS) fish_tests.o


#
# All objects needed to build mimedb
#

MIME_OBJS := mimedb.o print_help.o xdgmimealias.o xdgmime.o				\
	xdgmimeglob.o xdgmimeint.o xdgmimemagic.o xdgmimeparent.o wutil.o	\
	common.o fish_version.o


#
# Files containing user documentation
#

#
# These files are the source files, they contain a few @FOO@-style substitutions
# Note that this order defines the order that they appear in the documentation
#

HDR_FILES_SRC := doc_src/index.hdr.in doc_src/tutorial.hdr doc_src/design.hdr doc_src/license.hdr doc_src/commands.hdr.in doc_src/faq.hdr


#
# These are the generated result files
#

HDR_FILES := $(HDR_FILES_SRC:.hdr.in=.hdr)

# Use a pattern rule so that Make knows to only issue one invocation
# per http://www.gnu.org/software/make/manual/make.html#Pattern-Intro


#
# Files containing documentation for external commands.
#

HELP_SRC := $(wildcard doc_src/*.txt)

#
# HTML includes needed for HTML help
#

HTML_SRC := doc_src/user_doc.header.html doc_src/user_doc.footer.html doc_src/user_doc.css

#
# Files in the test directory
#

TEST_IN := $(wildcard tests/test*.in)

#
# Files in ./share/completions/
#

COMPLETIONS_DIR_FILES := $(wildcard share/completions/*.fish) share/completions/..fish


#
# Files in ./share/functions/
#

FUNCTIONS_DIR_FILES := $(wildcard share/functions/*.fish)


#
# Programs to install
#

PROGRAMS := fish mimedb fish_indent

#
# Manual pages to install
#

MANUALS := $(addsuffix .1, $(addprefix share/man/man1/,	\
	$(PROGRAMS)))


#
# All translation message catalogs
#

TRANSLATIONS_SRC := $(wildcard po/*.po)
ifdef HAVE_GETTEXT
	TRANSLATIONS := $(TRANSLATIONS_SRC:.po=.gmo)
else
	TRANSLATIONS :=
endif

#
# If Doxygen is not available, don't attempt to build the documentation
#

ifeq ($(HAVE_DOXYGEN), 1)
  user_doc=user_doc
  share_man=share/man
else
  user_doc=
  share_man=
endif

#
# Make everything needed for installing fish
#

all: $(PROGRAMS) $(user_doc) $(share_man) $(TRANSLATIONS) fish.pc
	@echo fish has now been built.
	@echo Use \'$(MAKE) install\' to install fish.
.PHONY: all

#
# Pull version information
#

FISH-BUILD-VERSION-FILE: FORCE
	@./build_tools/git_version_gen.sh
-include FISH-BUILD-VERSION-FILE
CPPFLAGS += -DFISH_BUILD_VERSION=\"$(FISH_BUILD_VERSION)\"
.PHONY: FORCE
fish_version.o: FISH-BUILD-VERSION-FILE


#
# These dependencies make sure that autoconf and configure are run
# when the source code for the build configuration has changed.
#

configure: configure.ac
	./config.status --recheck

Makefile: Makefile.in configure
	./config.status


#
# Build fish with some debug flags specified. This is GCC specific,
# and should only be used when debuging fish.
#

prof: EXTRA_CXXFLAGS += -pg
prof: LDFLAGS += -pg
prof: all
.PHONY: prof

#
# User documentation, describing the features of the fish shell.
#

# Depend on the sources (*.hdr.in) and manually make the
# intermediate *.hdr and doc.h files if needed
# The sed command deletes everything including and after the first -, for simpler version numbers
# Cleans up the user_doc/html directory once Doxygen is done.

user_doc: $(HDR_FILES_SRC) Doxyfile.user $(HTML_SRC) $(HELP_SRC) doc.h $(HDR_FILES) lexicon_filter
	(cat Doxyfile.user; echo INPUT_FILTER=./lexicon_filter; \
	echo PROJECT_NUMBER=$(FISH_BUILD_VERSION) | $(SED) "s/-.*//") | doxygen - && touch user_doc; \
	cd user_doc/html && rm -f bc_s.png bdwn.png closed.png ftv2*.png nav*.png open.png sync_*.png tab*.* doxygen.* dynsections.js jquery.js pages.html

#
# Source code documentation. Also includes user documentation.
#

doc: *.h *.cpp doc.h Doxyfile lexicon_filter
	(cat Doxyfile; echo INPUT_FILTER=./lexicon_filter; echo PROJECT_NUMBER=$(FISH_BUILD_VERSION)) | doxygen - ;


#
# PDF version of the source code documentation.
#

doc/refman.pdf: doc
	cd doc/latex && \
	make &&  \
	mv refman.pdf ..;
	rm -r doc/latex;


#
# This target runs both the low level code tests and the high level script tests.
#

test: test_low_level test_high_level
.PHONY: test

# We want the various tests to run serially so their output doesn't mix
# We can do that by adding ordering dependencies based on what goals are being used.

test_goals := test_low_level test_fishscript test_interactive

# The following variables define targets that depend on the tests. If any more targets
# are added that depend, directly or indirectly, on tests, they need to be recorded here.
test_test_deps = test_low_level $(test_high_level_test_deps)
test_high_level_test_deps = test_fishscript test_interactive

active_test_goals = $(filter $(test_goals),$(foreach a,$(or $(MAKECMDGOALS),$(.DEFAULT_GOAL)),$(a) $($(a)_test_deps)))
filter_up_to = $(eval b:=1)$(foreach a,$(2),$(and $(b),$(if $(subst $(1),,$(a)),$(a),$(eval b:=))))

test_low_level: fish_tests $(call filter_up_to,test_low_level,$(active_test_goals))
	./fish_tests
.PHONY: test_low_level

test_high_level: test_fishscript test_interactive
.PHONY: test_high_level

test_fishscript: $(PROGRAMS) $(call filter_up_to,test_fishscript,$(active_test_goals))
	cd tests && ../fish test.fish
.PHONY: test_fishscript

test_interactive: $(PROGRAMS) $(call filter_up_to,test_interactive,$(active_test_goals))
	cd tests && ../fish interactive.fish
.PHONY: test_interactive

#
# commands.hdr collects documentation on all commands, functions and
# builtins
#

doc_src/commands.hdr:$(HELP_SRC) doc_src/commands.hdr.in
	-rm command_list.tmp command_list_toc.tmp $@
	for i in `printf "%s\n" $(HELP_SRC)|sort`; do \
		echo "<hr>" >>command_list.tmp; \
		cat $$i >>command_list.tmp; \
		echo >>command_list.tmp; \
		echo >>command_list.tmp; \
		NAME=`basename $$i .txt`; \
		echo '- <a href="#'$$NAME'">'$$NAME'</a>' >> command_list_toc.tmp; \
		echo "Back to <a href='index.html#toc-commands'>index</a>". >>command_list.tmp; \
	done
	mv command_list.tmp command_list.txt
	mv command_list_toc.tmp command_list_toc.txt
	cat $@.in | awk '{if ($$0 ~ /@command_list_toc@/) { system("cat command_list_toc.txt"); } else if ($$0 ~ /@command_list@/){ system("cat command_list.txt");} else{ print $$0;}}' >$@


toc.txt: $(HDR_FILES:index.hdr=index.hdr.in)
	-rm toc.tmp $@
	# Ugly hack to set the toc initial title for the main page
	echo '- <a href="index.html" id="toc-index">Documentation</a>' > toc.tmp
	# The first sed command captures the page name, followed by the description
	# The second sed command captures the command name \1 and the description \2, but only up to a dash
	# This is to reduce the size of the TOC in the command listing on the main page
	for i in $(HDR_FILES:index.hdr=index.hdr.in); do\
		NAME=`basename $$i .hdr`; \
		NAME=`basename $$NAME .hdr.in`; \
		$(SED) <$$i >>toc.tmp -n \
		-e 's,.*\\page *\([^ ]*\) *\(.*\)$$,- <a href="'$$NAME'.html" id="toc-'$$NAME'">\2</a>,p' \
		-e 's,.*\\section *\([^ ]*\) *\([^-]*\)\(.*\)$$,  - <a href="'$$NAME'.html#\1">\2</a>,p'; \
	done
	mv toc.tmp $@

doc_src/index.hdr: toc.txt doc_src/index.hdr.in
	cat $@.in | awk '{if ($$0 ~ /@toc@/){ system("cat toc.txt");} else{ print $$0;}}' >$@

#
# To enable the lexicon filter, we first need to be aware of what fish
# considers to be a command, function, or external binary. We use
# command_list_toc.txt for the base commands. Scan the share/functions
# directory for other functions, some of which are mentioned in the docs, and
# use /share/completions to find a good selection of binaries. Additionally,
# colour defaults from __fish_config_interactive to set the docs colours when
# used in a 'cli' style context.
#

lexicon.txt: doc_src/commands.hdr $(FUNCTIONS_DIR_FILES) $(COMPLETIONS_DIR_FILES) share/functions/__fish_config_interactive.fish
	-rm lexicon.tmp lexicon_catalog.tmp lexicon_catalog.txt $@
	# Scan sources for commands/functions/binaries/colours. If GNU sed was portable, this could be much smarter.
	$(SED) <command_list_toc.txt >>lexicon.tmp -n \
		-e "s|^.*>\([a-z][a-z_]*\)</a>|'\1'|w lexicon_catalog.tmp" \
		-e "s|'\(.*\)'|bltn \1|p"; mv lexicon_catalog.tmp lexicon_catalog.txt; \
	printf "%s\n" $(COMPLETIONS_DIR_FILES) | $(SED) -n \
		-e "s|[^ ]*/\([a-z][a-z_-]*\).fish|'\1'|p" | fgrep -vx -f lexicon_catalog.txt | $(SED) >>lexicon.tmp -n \
		-e 'w lexicon_catalog.tmp' \
		-e "s|'\(.*\)'|cmnd \1|p"; cat lexicon_catalog.tmp >> lexicon_catalog.txt; \
	printf "%s\n" $(FUNCTIONS_DIR_FILES) | $(SED) -n \
		-e "s|[^ ]*/\([a-z][a-z_-]*\).fish|'\1'|p" | fgrep -vx -f lexicon_catalog.txt | $(SED) >>lexicon.tmp -n \
		-e 'w lexicon_catalog.tmp' \
		-e "s|'\(.*\)'|func \1|p"; \
	$(SED) <share/functions/__fish_config_interactive.fish >>lexicon.tmp -n \
		-e '/set_default/s/.*\(fish_[a-z][a-z_]*\).*$$/clrv \1/p'; \
	$(SED) <lexicon_filter.in >>lexicon.tmp -n \
		-e '/^#.!#/s/^#.!# \(.... [a-z][a-z_]*\)/\1/p'; \
	mv lexicon.tmp lexicon.txt; rm -f lexicon_catalog.tmp lexicon_catalog.txt;

#
# Compile Doxygen Input Filter from the lexicon. This is an executable sed
# script as Doxygen opens it via popen()(3) Input (doc.h) is piped through and
# matching words inside /fish../endfish blocks are marked up, contextually,
# with custom Doxygen commands in the form of @word_type{content}. These are
# trapped by ALIASES in the various Doxyfiles, allowing the content to be
# transformed depending on output type (HTML, man page, developer docs). In
# HTML, a style context can be applied through the /fish{style} block and
# providing suitable CSS in user_doc.css.in
#

lexicon_filter: lexicon.txt lexicon_filter.in
	-rm $@.tmp $@
	# Set the shebang as sed can reside in multiple places.
	$(SED) <$@.in >$@.tmp -e 's|@sed@|'$(SED)'|'
	# Scan through the lexicon, transforming each line to something useful to Doxygen.
	if echo x | $(SED) "/[[:<:]]x/d" 2>/dev/null; then \
		WORDBL='[[:<:]]'; WORDBR='[[:>:]]'; \
	else \
		WORDBL='\\<'; WORDBR='\\>'; \
	fi; \
	$(SED) <lexicon.txt >>$@.tmp -n \
		-e "s|^\([a-z][a-z][a-z][a-z]\) \([a-z_-]*\)$$|s,$$WORDBL\2$$WORDBR,@\1{\2},g|p" \
		-e '$$G;s/.*\n/b tidy/p'; \
	mv $@.tmp $@; if test -x $@; then true; else chmod a+x $@; fi

#
# doc.h is a compilation of the various snipptes of text used both for
# the user documentation and for internal help functions into a single
# file that can be parsed by Doxygen to generate the user
# documentation.
#

doc.h: $(HDR_FILES)
	cat $(HDR_FILES) >$@

#
# This rule creates complete doxygen headers from each of the various
# snipptes of text used both for the user documentation and for
# internal help functions, that can be parsed to Doxygen to generate
# the internal help function text.
#

%.doxygen:%.txt
	echo  "/** \page " `basename $*` >$@;
	cat $*.txt >>$@;
	echo "*/" >>$@

# Depend on Makefile because I don't see a better way of rebuilding
# if any of the paths change.
%: %.in Makefile FISH-BUILD-VERSION-FILE
	$(SED) <$< >$@ \
		-e "s,@sysconfdir\@,$(sysconfdir),g" \
		-e "s,@datadir\@,$(datadir),g" \
		-e "s,@docdir\@,$(docdir),g" \
		-e "s|@configure_input\@|$@, generated from $@.in by the Makefile. DO NOT MANUALLY EDIT THIS FILE!|g" \
		-e "s,@prefix\@,$(prefix),g" \
		-e "s,@fish_build_version\@,$(FISH_BUILD_VERSION),g" \


#
# Compile translation files to binary format
#

%.gmo:
	msgfmt -o $@ $*.po

#
# Update existing po file or copy messages.pot
#

%.po:messages.pot
	if test -f $*.po; then \
		msgmerge -U --backup=existing $*.po messages.pot;\
	else \
		cp messages.pot $*.po;\
	fi

#
# Create a template translation object
#

messages.pot: *.cpp *.h share/completions/*.fish share/functions/*.fish
	xgettext -k_ -kN_ *.cpp *.h -o messages.pot
	xgettext -j -k_ -kN_ -k--description -LShell --from-code=UTF-8 share/completions/*.fish share/functions/*.fish -o messages.pot

builtin.o: $(BUILTIN_FILES)

common.o: $(COMMON_FILES)


#
# Generate the internal help functions by making doxygen create
# man-pages. The convertion path looks like this:
#
#   .txt file
#       ||
#     (make)
#       ||
#       \/
#  .doxygen file
#       ||
#    (doxygen)
#       ||
#       \/
#    roff file
#       ||
# (__fish_print_help)
#       ||
#       \/
#   formated text
#   with escape
#    sequences
#
#
# There ought to be something simpler.
#

share/man: $(HELP_SRC) lexicon_filter
	-mkdir share/man
	touch share/man
	-rm -Rf share/man/man1
	PROJECT_NUMBER=`echo $(FISH_BUILD_VERSION)| $(SED) "s/-.*//"` INPUT_FILTER=./lexicon_filter \
	./build_tools/build_documentation.sh Doxyfile.help ./doc_src ./share

#
# The build rules for installing/uninstalling fish
#

#
# Check for an incompatible installed fish version, and fail with an
# error if found
#

check-uninstall:
	if test -f $(DESTDIR)$(sysconfdir)/fish.d/fish_function.fish -o -f $(DESTDIR)$(sysconfdir)/fish.d/fish_complete.fish; then \
		echo;\
		echo ERROR;\
		echo;\
		echo An older fish installation using an incompatible filesystem hierarchy was detected;\
		echo You must uninstall this fish version before proceeding;\
		echo type \'$(MAKE) uninstall-legacy\' to uninstall these files,;\
		echo or type \'$(MAKE) force-install\' to force installation.;\
		echo The latter may result in a broken installation.;\
		echo;\
		false;\
	fi;
	if test -f $(DESTDIR)$(sysconfdir)/fish; then \
		echo;\
		echo ERROR;\
		echo;\
		echo An older fish installation using an incompatible filesystem hierarchy was detected;\
		echo You must remove the file $(DESTDIR)$(sysconfdir)/fish before proceeding;\
		echo type \'$(MAKE) uninstall-legacy\' to uninstall this file,;\
		echo or remove it manually using \'rm $(DESTDIR)$(sysconfdir)/fish\'.;\
		echo;\
		false;\
	fi;
.PHONY: check-uninstall

check-legacy-binaries:
	@SEQLOC=$(prefix)/bin/seq;\
	if test -f "$$SEQLOC" && grep -q '\(^#!/.*/fish\|^#!/usr/bin/env fish\)' "$$SEQLOC"; then\
		echo "An outdated seq from a previous fish install was found. You should remove it with:";\
		echo "    rm '$$SEQLOC'";\
	fi;
	@SETCOLOR_LOC=$(prefix)/bin/set_color;\
	if test -x "$$SETCOLOR_LOC" && $$SETCOLOR_LOC -v 2>&1 >/dev/null | grep -q "^set_color, version "; then\
		echo "An outdated set_color from a previous fish install was found. You should remove it with:";\
		echo "    rm '$$SETCOLOR_LOC'";\
	fi;
	@true;
.PHONY: check-legacy-binaries


#
# This check makes sure that the install-sh script is executable. The
# darcs repo doesn't preserve the executable bit, so this needs to be
# run after checkout.
#

install-sh:
	if test -x $@; then true; else chmod 755 $@; fi
.PHONY: install-sh


#
# Try to install after checking for incompatible installed versions.
#

install: all install-sh check-uninstall install-force check-legacy-binaries
.PHONY: install

#
# Xcode install
#
xcode-install:
	rm -Rf /tmp/fish_build;\
	xcodebuild install DSTROOT=/tmp/fish_build;\
	ditto /tmp/fish_build /
.PHONY: xcode-install

#
# Force installation, even in presense of incompatible previous
# version. This may fail.
# These 'true' lines are to prevent installs from failing for (e.g.) missing man pages.
#

install-force: all install-translations
	$(INSTALL) -m 755 -d $(DESTDIR)$(bindir)
	for i in $(PROGRAMS); do\
		$(INSTALL) -m 755 $$i $(DESTDIR)$(bindir) ; \
		true ;\
	done;
	$(INSTALL) -m 755 -d $(DESTDIR)$(sysconfdir)/fish
	$(INSTALL) -m 755 -d $(DESTDIR)$(datadir)/fish
	$(INSTALL) -m 755 -d $(DESTDIR)$(datadir)/fish/completions
	$(INSTALL) -m 755 -d $(DESTDIR)$(datadir)/fish/vendor_completions.d
	$(INSTALL) -m 755 -d $(DESTDIR)$(datadir)/fish/functions
	$(INSTALL) -m 755 -d $(DESTDIR)$(datadir)/fish/man/man1
	$(INSTALL) -m 755 -d $(DESTDIR)$(datadir)/fish/tools
	$(INSTALL) -m 755 -d $(DESTDIR)$(datadir)/fish/tools/web_config
	$(INSTALL) -m 755 -d $(DESTDIR)$(datadir)/fish/tools/web_config/js
	$(INSTALL) -m 755 -d $(DESTDIR)$(datadir)/fish/tools/web_config/partials
	$(INSTALL) -m 755 -d $(DESTDIR)$(datadir)/fish/tools/web_config/sample_prompts
	$(INSTALL) -m 644 etc/config.fish                  $(DESTDIR)$(sysconfdir)/fish/
	$(INSTALL) -m 644 share/config.fish                $(DESTDIR)$(datadir)/fish/
	$(INSTALL) -m 755 -d $(DESTDIR)$(datadir)/pkgconfig
	$(INSTALL) -m 644 fish.pc $(DESTDIR)$(datadir)/pkgconfig
	for i in $(COMPLETIONS_DIR_FILES:%='%'); do \
		$(INSTALL) -m 644 $$i $(DESTDIR)$(datadir)/fish/completions/; \
		true; \
	done;
	for i in $(FUNCTIONS_DIR_FILES:%='%'); do \
		$(INSTALL) -m 644 $$i $(DESTDIR)$(datadir)/fish/functions/; \
		true; \
	done;
	for i in share/man/man1/*.1; do \
		$(INSTALL) -m 644 $$i $(DESTDIR)$(datadir)/fish/man/man1/; \
		true; \
	done;
	for i in share/tools/*.py; do\
		$(INSTALL) -m 755 $$i $(DESTDIR)$(datadir)/fish/tools/; \
		true; \
	done;
	for i in share/tools/web_config/*; do\
		$(INSTALL) -m 644 $$i $(DESTDIR)$(datadir)/fish/tools/web_config/; \
		true; \
	done;
	for i in share/tools/web_config/js/*; do\
		$(INSTALL) -m 644 $$i $(DESTDIR)$(datadir)/fish/tools/web_config/js/; \
		true; \
	done;
	for i in share/tools/web_config/partials/*; do\
		$(INSTALL) -m 644 $$i $(DESTDIR)$(datadir)/fish/tools/web_config/partials/; \
		true; \
	done;
	for i in share/tools/web_config/sample_prompts/*.fish; do\
		$(INSTALL) -m 644 $$i $(DESTDIR)$(datadir)/fish/tools/web_config/sample_prompts/; \
		true; \
	done;
	for i in share/tools/web_config/*.py; do\
		$(INSTALL) -m 755 $$i $(DESTDIR)$(datadir)/fish/tools/web_config/; \
		true; \
	done;

	$(INSTALL) -m 755 -d $(DESTDIR)$(docdir)
	for i in user_doc/html/* ChangeLog; do \
		if test -f $$i; then \
			$(INSTALL) -m 644 $$i $(DESTDIR)$(docdir); \
		fi; \
	done;
	$(INSTALL) -m 755 -d $(DESTDIR)$(mandir)/man1
	for i in $(MANUALS); do \
		$(INSTALL) -m 644 $$i $(DESTDIR)$(mandir)/man1/; \
		true; \
	done;
	@echo fish is now installed on your system.
	@echo To run fish, type \'fish\' in your terminal.
	@echo
	@if type chsh >/dev/null 2>&1; then \
		echo To use fish as your login shell:; \
		grep -q -- "$(DESTDIR)$(bindir)/fish" /etc/shells || echo \* add the line \'$(DESTDIR)$(bindir)/fish\' to the file \'/etc/shells\'.; \
		echo \* use the command \'chsh -s $(DESTDIR)$(bindir)/fish\'.; \
		echo; \
	fi;
	@if type chcon >/dev/null 2>&1; then \
		echo If you have SELinux enabled, you may need to manually update the security policy:; \
		echo \* use the command \'chcon -t shell_exec_t $(DESTDIR)$(bindir)/fish\'.; \
		echo; \
	fi;
	@echo To set your colors, run \'fish_config\'
	@echo To scan your man pages for completions, run \'fish_update_completions\'
	@echo To autocomplete command suggestions press Ctrl + F or right arrow key.
	@echo
	@echo Have fun!
.PHONY: install-force


#
# Uninstall this fish version
#

uninstall: uninstall-translations
	-for i in $(PROGRAMS); do \
		rm -f $(DESTDIR)$(bindir)/$$i; \
	done;
	-rm -rf $(DESTDIR)$(sysconfdir)/fish
	-if test -d $(DESTDIR)$(datadir)/fish; then \
		rm -r $(DESTDIR)$(datadir)/fish; \
	fi
	-if test -d $(DESTDIR)$(docdir); then \
		rm -rf $(DESTDIR)$(docdir);\
	fi
	-if test -f $(DESTDIR)$(datadir)/pkgconfig/fish.pc; then \
		rm -f $(DESTDIR)$(datadir)/pkgconfig/fish.pc;\
	fi
	-for i in $(MANUALS); do \
		rm -rf $(DESTDIR)$(mandir)/man1/`basename $$i`*; \
	done;
.PHONY: uninstall


#
# Uninstall an older fish release. This is not the default uninstall
# since there is a slight chance that it removes a file put in place by
# the sysadmin. But if 'make install' detects a file confligt, it
# suggests using this target.
#

uninstall-legacy: uninstall
	-rm -f $(DESTDIR)$(sysconfdir)/fish.d/fish_interactive.fish
	-rm -f $(DESTDIR)$(sysconfdir)/fish.d/fish_complete.fish
	-rm -f $(DESTDIR)$(sysconfdir)/fish.d/fish_function.fish
	-rm -f $(DESTDIR)$(sysconfdir)/fish/fish_inputrc
	-if test -d $(DESTDIR)$(sysconfdir)/fish.d/completions; then \
		for i in $(COMPLETIONS_DIR_FILES); do \
			basename=`basename $$i`; \
			if test -f $(DESTDIR)$(sysconfdir)/fish.d/completions/$$basename; then \
				rm $(DESTDIR)$(sysconfdir)/fish.d/completions/$$basename; \
			fi; \
		done; \
	fi;
	-rmdir $(DESTDIR)$(sysconfdir)/fish.d/completions
	-rmdir $(DESTDIR)$(sysconfdir)/fish.d
	-rm $(DESTDIR)$(sysconfdir)/fish
	@echo The previous fish installation has been removed.
.PHONY: uninstall-legacy

install-translations: $(TRANSLATIONS)
ifdef HAVE_GETTEXT
	for i in $(TRANSLATIONS); do \
		$(INSTALL) -m 755 -d $(DESTDIR)$(localedir)/`basename $$i .gmo`/LC_MESSAGES; \
		$(INSTALL) -m 644 $$i $(DESTDIR)$(localedir)/`basename $$i .gmo`/LC_MESSAGES/fish.mo; \
		echo $(DESTDIR)$(localedir)/`basename $$i .gmo`/LC_MESSAGES/fish.mo;\
	done
endif
.PHONY: install-translations

uninstall-translations:
	rm -f $(DESTDIR)$(localedir)/*/LC_MESSAGES/fish.mo
.PHONY: uninstall-translations


#
# The build rules for all the commands
#

#
# Build the fish program.
#

fish: $(FISH_OBJS) fish.o
	$(CXX) $(CXXFLAGS) $(LDFLAGS_FISH) $(FISH_OBJS) fish.o $(LIBS) -o $@


#
# Build the fish_tests program.
#

fish_tests: $(FISH_TESTS_OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS_FISH) $(FISH_TESTS_OBJS) $(LIBS) -o $@


#
# Build the mimedb program.
#

mimedb: $(MIME_OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(MIME_OBJS) $(LIBS) -o $@


#
# Build the fish_indent program.
#

fish_indent: $(FISH_INDENT_OBJS)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $(FISH_INDENT_OBJS) $(LIBS) -o $@


#
# Neat little program to show output from terminal
#

key_reader: $(FISH_OBJS) key_reader.o
	$(CXX) $(CXXFLAGS) $(LDFLAGS_FISH) $^ $(LIBS) -o $@


#
# Update dependencies
#
depend:
	makedepend -fMakefile.in -Y *.cpp
	./config.status
.PHONY: depend

#
# Cleanup targets
#

#
# distclean should restore the tree to the state right after extracting a tarball.
#

distclean: clean
	rm -f config.status config.log config.h Makefile
.PHONY: distclean


#
# clean removes everything built by the makefile, but not things that
# are created by the configure script.
#

# Don't delete the docs unless we have Doxygen installed
# We provide pre-built docs in the tarball, and if they get
# deleted we won't be able to regenerate them

clean:
	rm -f *.o doc.h doc.tmp doc_src/*.doxygen doc_src/*.cpp doc_src/*.o doc_src/commands.hdr
	rm -f tests/tmp.err tests/tmp.out tests/tmp.status tests/foo.txt
	rm -f $(PROGRAMS) fish_tests key_reader
	rm -f command_list.txt command_list_toc.txt toc.txt
	rm -f doc_src/index.hdr doc_src/commands.hdr
	rm -f lexicon_filter lexicon.txt lexicon.log
	rm -f FISH-BUILD-VERSION-FILE
	if test "$(HAVE_DOXYGEN)" = 1; then \
		rm -rf doc user_doc share/man; \
	fi
	rm -f po/*.gmo
.PHONY: clean


# DO NOT DELETE THIS LINE -- make depend depends on it.

autoload.o: config.h autoload.h common.h util.h lru.h wutil.h signal.h env.h
autoload.o: exec.h proc.h io.h parse_tree.h tokenizer.h parse_constants.h
builtin.o: config.h signal.h fallback.h util.h wutil.h common.h builtin.h
builtin.o: io.h function.h event.h env.h complete.h proc.h parse_tree.h
builtin.o: tokenizer.h parse_constants.h parser.h reader.h highlight.h
builtin.o: color.h wgetopt.h sanity.h wildcard.h expand.h input_common.h
builtin.o: input.h intern.h exec.h parse_util.h autoload.h lru.h
builtin.o: parser_keywords.h path.h history.h wcstringutil.h builtin_set.cpp
builtin.o: builtin_commandline.cpp builtin_complete.cpp builtin_ulimit.cpp
builtin.o: builtin_jobs.cpp builtin_set_color.cpp output.h screen.h
builtin.o: builtin_printf.cpp
builtin_commandline.o: config.h signal.h fallback.h util.h wutil.h common.h
builtin_commandline.o: builtin.h io.h wgetopt.h reader.h complete.h
builtin_commandline.o: highlight.h env.h color.h proc.h parse_tree.h
builtin_commandline.o: tokenizer.h parse_constants.h parser.h event.h
builtin_commandline.o: function.h input_common.h input.h parse_util.h
builtin_commandline.o: autoload.h lru.h
builtin_complete.o: config.h signal.h fallback.h util.h wutil.h common.h
builtin_complete.o: builtin.h io.h complete.h wgetopt.h parser.h proc.h
builtin_complete.o: parse_tree.h tokenizer.h parse_constants.h event.h
builtin_complete.o: function.h env.h reader.h highlight.h color.h
builtin_jobs.o: config.h fallback.h signal.h util.h wutil.h common.h
builtin_jobs.o: builtin.h io.h proc.h parse_tree.h tokenizer.h
builtin_jobs.o: parse_constants.h parser.h event.h function.h env.h wgetopt.h
builtin_printf.o: common.h util.h
builtin_set.o: config.h signal.h fallback.h util.h wutil.h common.h builtin.h
builtin_set.o: io.h env.h expand.h parse_constants.h wgetopt.h proc.h
builtin_set.o: parse_tree.h tokenizer.h parser.h event.h function.h
builtin_set_color.o: config.h builtin.h util.h io.h common.h color.h output.h
builtin_set_color.o: screen.h highlight.h env.h
builtin_test.o: config.h common.h util.h builtin.h io.h wutil.h proc.h
builtin_test.o: signal.h parse_tree.h tokenizer.h parse_constants.h
builtin_ulimit.o: config.h fallback.h signal.h util.h builtin.h io.h common.h
builtin_ulimit.o: wgetopt.h
color.o: color.h config.h common.h util.h fallback.h signal.h
common.o: config.h fallback.h signal.h util.h wutil.h common.h expand.h
common.o: parse_constants.h proc.h io.h parse_tree.h tokenizer.h wildcard.h
common.o: complete.h parser.h event.h function.h env.h util.cpp fallback.cpp
complete.o: config.h signal.h fallback.h util.h tokenizer.h common.h
complete.o: wildcard.h expand.h parse_constants.h complete.h proc.h io.h
complete.o: parse_tree.h parser.h event.h function.h env.h builtin.h exec.h
complete.o: reader.h highlight.h color.h history.h wutil.h intern.h
complete.o: parse_util.h autoload.h lru.h parser_keywords.h path.h iothread.h
env.o: config.h signal.h fallback.h util.h wutil.h common.h proc.h io.h
env.o: parse_tree.h tokenizer.h parse_constants.h env.h sanity.h expand.h
env.o: history.h reader.h complete.h highlight.h color.h parser.h event.h
env.o: function.h env_universal_common.h input.h input_common.h path.h
env.o: fish_version.h
env_universal_common.o: config.h env_universal_common.h wutil.h common.h
env_universal_common.o: util.h env.h fallback.h signal.h utf8.h path.h
env_universal_common.o: iothread.h
event.o: config.h signal.h fallback.h util.h wutil.h common.h function.h
event.o: event.h env.h input_common.h proc.h io.h parse_tree.h tokenizer.h
event.o: parse_constants.h parser.h
exec.o: config.h signal.h fallback.h util.h iothread.h postfork.h common.h
exec.o: proc.h io.h parse_tree.h tokenizer.h parse_constants.h wutil.h exec.h
exec.o: parser.h event.h function.h env.h builtin.h wildcard.h expand.h
exec.o: complete.h sanity.h parse_util.h autoload.h lru.h
expand.o: config.h signal.h fallback.h util.h common.h wutil.h env.h proc.h
expand.o: io.h parse_tree.h tokenizer.h parse_constants.h parser.h event.h
expand.o: function.h expand.h wildcard.h complete.h exec.h iothread.h
expand.o: parse_util.h autoload.h lru.h
fallback.o: config.h fallback.h signal.h util.h
fish.o: config.h signal.h fallback.h util.h common.h reader.h io.h complete.h
fish.o: highlight.h env.h color.h builtin.h function.h event.h wutil.h
fish.o: sanity.h proc.h parse_tree.h tokenizer.h parse_constants.h parser.h
fish.o: expand.h intern.h exec.h output.h screen.h history.h path.h input.h
fish.o: input_common.h fish_version.h
fish_indent.o: config.h fallback.h signal.h util.h common.h wutil.h
fish_indent.o: tokenizer.h print_help.h parser_keywords.h fish_version.h
fish_tests.o: config.h signal.h fallback.h util.h common.h proc.h io.h
fish_tests.o: parse_tree.h tokenizer.h parse_constants.h reader.h complete.h
fish_tests.o: highlight.h env.h color.h builtin.h function.h event.h
fish_tests.o: autoload.h lru.h wutil.h expand.h parser.h output.h screen.h
fish_tests.o: exec.h path.h history.h iothread.h postfork.h parse_util.h
fish_tests.o: pager.h input.h input_common.h utf8.h env_universal_common.h
fish_tests.o: wcstringutil.h
fish_version.o: fish_version.h
function.o: config.h signal.h wutil.h common.h util.h fallback.h function.h
function.o: event.h env.h proc.h io.h parse_tree.h tokenizer.h
function.o: parse_constants.h parser.h intern.h reader.h complete.h
function.o: highlight.h color.h parse_util.h autoload.h lru.h
function.o: parser_keywords.h expand.h
highlight.o: config.h signal.h fallback.h util.h wutil.h common.h highlight.h
highlight.o: env.h color.h tokenizer.h proc.h io.h parse_tree.h
highlight.o: parse_constants.h parser.h event.h function.h parse_util.h
highlight.o: autoload.h lru.h parser_keywords.h builtin.h expand.h sanity.h
highlight.o: complete.h output.h screen.h wildcard.h path.h history.h
history.o: config.h fallback.h signal.h util.h sanity.h tokenizer.h common.h
history.o: reader.h io.h complete.h highlight.h env.h color.h parse_tree.h
history.o: parse_constants.h wutil.h history.h intern.h path.h autoload.h
history.o: lru.h iothread.h
input.o: config.h signal.h fallback.h util.h wutil.h common.h reader.h io.h
input.o: complete.h highlight.h env.h color.h proc.h parse_tree.h tokenizer.h
input.o: parse_constants.h sanity.h input_common.h input.h parser.h event.h
input.o: function.h expand.h output.h screen.h intern.h
input_common.o: config.h fallback.h signal.h util.h common.h wutil.h
input_common.o: input_common.h env_universal_common.h env.h iothread.h
intern.o: config.h fallback.h signal.h util.h wutil.h common.h intern.h
io.o: config.h fallback.h signal.h util.h wutil.h common.h exec.h proc.h io.h
io.o: parse_tree.h tokenizer.h parse_constants.h
iothread.o: config.h iothread.h common.h util.h signal.h
key_reader.o: config.h common.h util.h fallback.h signal.h input_common.h
kill.o: config.h signal.h fallback.h util.h wutil.h common.h kill.h proc.h
kill.o: io.h parse_tree.h tokenizer.h parse_constants.h sanity.h env.h exec.h
kill.o: path.h
mimedb.o: config.h xdgmime.h fallback.h signal.h util.h print_help.h
mimedb.o: fish_version.h
output.o: config.h signal.h fallback.h util.h wutil.h common.h expand.h
output.o: parse_constants.h output.h screen.h highlight.h env.h color.h
pager.o: config.h pager.h complete.h util.h common.h screen.h highlight.h
pager.o: env.h color.h reader.h io.h input_common.h wutil.h
parse_execution.o: parse_execution.h config.h util.h parse_tree.h common.h
parse_execution.o: tokenizer.h parse_constants.h proc.h signal.h io.h
parse_execution.o: parse_util.h autoload.h lru.h complete.h wildcard.h
parse_execution.o: expand.h builtin.h parser.h event.h function.h env.h
parse_execution.o: reader.h highlight.h color.h wutil.h exec.h path.h
parse_productions.o: parse_productions.h parse_tree.h config.h util.h
parse_productions.o: common.h tokenizer.h parse_constants.h
parse_tree.o: parse_productions.h parse_tree.h config.h util.h common.h
parse_tree.o: tokenizer.h parse_constants.h fallback.h signal.h wutil.h
parse_tree.o: proc.h io.h
parse_util.o: config.h fallback.h signal.h util.h wutil.h common.h
parse_util.o: tokenizer.h parse_util.h autoload.h lru.h parse_tree.h
parse_util.o: parse_constants.h expand.h intern.h exec.h proc.h io.h env.h
parse_util.o: wildcard.h complete.h parser.h event.h function.h builtin.h
parser.o: config.h signal.h fallback.h util.h common.h wutil.h proc.h io.h
parser.o: parse_tree.h tokenizer.h parse_constants.h parser.h event.h
parser.o: function.h env.h parser_keywords.h exec.h wildcard.h expand.h
parser.o: complete.h builtin.h reader.h highlight.h color.h sanity.h intern.h
parser.o: parse_util.h autoload.h lru.h path.h parse_execution.h
parser_keywords.o: config.h fallback.h signal.h common.h util.h
parser_keywords.o: parser_keywords.h
path.o: config.h fallback.h signal.h util.h common.h env.h wutil.h path.h
path.o: expand.h parse_constants.h
postfork.o: signal.h postfork.h config.h common.h util.h proc.h io.h
postfork.o: parse_tree.h tokenizer.h parse_constants.h wutil.h iothread.h
postfork.o: exec.h
print_help.o: print_help.h
proc.o: config.h signal.h fallback.h util.h wutil.h common.h proc.h io.h
proc.o: parse_tree.h tokenizer.h parse_constants.h reader.h complete.h
proc.o: highlight.h env.h color.h sanity.h parser.h event.h function.h
proc.o: output.h screen.h
reader.o: config.h signal.h fallback.h util.h wutil.h common.h highlight.h
reader.o: env.h color.h reader.h io.h complete.h proc.h parse_tree.h
reader.o: tokenizer.h parse_constants.h parser.h event.h function.h history.h
reader.o: sanity.h exec.h expand.h kill.h input_common.h input.h output.h
reader.o: screen.h iothread.h intern.h path.h parse_util.h autoload.h lru.h
reader.o: parser_keywords.h pager.h
sanity.o: config.h signal.h fallback.h util.h common.h sanity.h proc.h io.h
sanity.o: parse_tree.h tokenizer.h parse_constants.h history.h wutil.h
sanity.o: reader.h complete.h highlight.h env.h color.h kill.h
screen.o: config.h fallback.h signal.h common.h util.h wutil.h output.h
screen.o: screen.h highlight.h env.h color.h pager.h complete.h reader.h io.h
signal.o: config.h signal.h common.h util.h fallback.h wutil.h event.h
signal.o: reader.h io.h complete.h highlight.h env.h color.h proc.h
signal.o: parse_tree.h tokenizer.h parse_constants.h
tokenizer.o: config.h fallback.h signal.h util.h wutil.h common.h tokenizer.h
utf8.o: utf8.h
util.o: config.h fallback.h signal.h util.h common.h wutil.h
wcstringutil.o: config.h wcstringutil.h common.h util.h
wgetopt.o: config.h wgetopt.h wutil.h common.h util.h fallback.h signal.h
wildcard.o: config.h fallback.h signal.h util.h wutil.h common.h complete.h
wildcard.o: wildcard.h expand.h parse_constants.h reader.h io.h highlight.h
wildcard.o: env.h color.h exec.h proc.h parse_tree.h tokenizer.h
wutil.o: config.h fallback.h signal.h util.h common.h wutil.h
xdgmime.o: xdgmime.h xdgmimeint.h xdgmimeglob.h xdgmimemagic.h xdgmimealias.h
xdgmime.o: xdgmimeparent.h
xdgmimealias.o: xdgmimealias.h xdgmime.h xdgmimeint.h
xdgmimeglob.o: xdgmimeglob.h xdgmime.h xdgmimeint.h
xdgmimeint.o: xdgmimeint.h xdgmime.h
xdgmimemagic.o: xdgmimemagic.h xdgmime.h xdgmimeint.h
xdgmimeparent.o: xdgmimeparent.h xdgmime.h xdgmimeint.h
