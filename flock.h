/* Copyright (C) 1992-2014 Free Software Foundation, Inc.
   This file is part of the GNU C Library.

   The GNU C Library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Lesser General Public
   License as published by the Free Software Foundation; either
   version 2.1 of the License, or (at your option) any later version.

   The GNU C Library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Lesser General Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with the GNU C Library; if not, see
   <http://www.gnu.org/licenses/>.  */

/* This file implements the `flock' function in terms of the POSIX.1 `fcntl'
   locking mechanism.  In 4BSD, these are two incompatible locking mechanisms,
   perhaps with different semantics?  */

/*
 * Now fucks the Solaris' libc!
 * Fucks by M0xkLurk3r.
 */

#ifndef FLOCK_H
#define FLOCK_H

#include <errno.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/syscall.h>

/* Alternate names for values for the WHENCE argument to `lseek'.
   These are the same as SEEK_SET, SEEK_CUR, and SEEK_END, respectively.  */
#ifndef L_SET
# define L_SET  0       /* Seek from beginning of file.  */
# define L_INCR 1       /* Seek from current position.  */
# define L_XTND 2       /* Seek from end of file.  */
#endif


/* Operations for the `flock' call.  */
#define LOCK_SH 1       /* Shared lock.  */
#define LOCK_EX 2       /* Exclusive lock.  */
#define LOCK_UN 8       /* Unlock.  */
#define __LOCK_ATOMIC   16      /* Atomic update.  */

/* Can be OR'd in to one of the above.  */
#define LOCK_NB 4       /* Don't block when locking.  */

#define __fcntl fcntl

/* Apply or remove an advisory lock, according to OPERATION,
   on the file FD refers to.  */
int _flock(int fd, int operation){ 
  struct flock lbuf;

  switch (operation & ~LOCK_NB)
    {
    case LOCK_SH:
      lbuf.l_type = F_RDLCK;
      break;
    case LOCK_EX:
      lbuf.l_type = F_WRLCK;
      break;
    case LOCK_UN:
      lbuf.l_type = F_UNLCK;
      break;
    default:
      __set_errno (EINVAL);
      return -1;
    }

  lbuf.l_whence = SEEK_SET;
  lbuf.l_start = lbuf.l_len = 0L; /* Lock the whole file.  */

  return __fcntl (fd, (operation & LOCK_NB) ? F_SETLK : F_SETLKW, &lbuf);
}


#endif // FLOCK_H
