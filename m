From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: Linux' NFS locking b0rken?
Date: Tue, 25 May 2004 15:09:53 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0405251504220.24001-100000@fattire.ngdc.noaa.gov>
References: <1085512326.9224.33.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Cc: Dan Stromberg <strombrg@dcs.nac.uci.edu>,
   Jeffrey Layton <jtlayton@poochiereds.net>, Olaf Kirch <okir@suse.de>,
   <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BSjCW-00037f-Lh
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 14:11:08 -0700
Received: from fattire.ngdc.noaa.gov ([140.172.187.207])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BSjCW-0002f8-1V
	for nfs@lists.sourceforge.net; Tue, 25 May 2004 14:11:08 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1085512326.9224.33.camel@lade.trondhjem.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Tue, 25 May 2004, Trond Myklebust wrote:

> P=E5 ty , 25/05/2004 klokka 15:08, skreiv Ara.T.Howard:
> > yes, in that it would work, you simply would not coordinate with other
> > processes which do NOT use fcntl based locks.  ruby and perl ship with
> > implemtations of flock which are, in fact, fctnl under the hood.
>=20
> No it would not. Read the manpages...
>=20
> Trond

i'm not saying this is GOOD - just that you certainly can make a wrapper
around fcntl and call it flock (or anything else for that matter) and so lo=
ng
as all your processes are using this interface all will be well.  of course
the two types don't mix.  in any case i understand what you are saying,
nevertheless it __is__ being done out there:


=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
file: ruby-1.8.1/missing/flock.c
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D

#include "config.h"

#if defined HAVE_FCNTL && defined HAVE_FCNTL_H

/* These are the flock() constants.  Since this sytems doesn't have
   flock(), the values of the constants are probably not available.
*/
# ifndef LOCK_SH
#  define LOCK_SH 1
# endif
# ifndef LOCK_EX
#  define LOCK_EX 2
# endif
# ifndef LOCK_NB
#  define LOCK_NB 4
# endif
# ifndef LOCK_UN
#  define LOCK_UN 8
# endif

#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

int
flock(fd, operation)
    int fd;
    int operation;
{
    struct flock lock;
=20
    switch (operation & ~LOCK_NB) {
    case LOCK_SH:
=09lock.l_type =3D F_RDLCK;
=09break;
    case LOCK_EX:
=09lock.l_type =3D F_WRLCK;
=09break;
    case LOCK_UN:
=09lock.l_type =3D F_UNLCK;
=09break;
    default:
=09errno =3D EINVAL;
=09return -1;
    }
    lock.l_whence =3D SEEK_SET;
    lock.l_start =3D lock.l_len =3D 0L;
=20
    return fcntl(fd, (operation & LOCK_NB) ? F_SETLK : F_SETLKW, &lock);
}

#elif defined(HAVE_LOCKF)

#include <unistd.h>
#include <errno.h>

/*  Emulate flock() with lockf() or fcntl().  This is just to increase
    portability of scripts.  The calls might not be completely
    interchangeable.  What's really needed is a good file
    locking module.
*/

# ifndef F_ULOCK
#  define F_ULOCK=090=09/* Unlock a previously locked region */
# endif
# ifndef F_LOCK
#  define F_LOCK=091=09/* Lock a region for exclusive use */
# endif
# ifndef F_TLOCK
#  define F_TLOCK=092=09/* Test and lock a region for exclusive use */
# endif
# ifndef F_TEST
#  define F_TEST=093=09/* Test a region for other processes locks */
# endif

/* These are the flock() constants.  Since this sytems doesn't have
   flock(), the values of the constants are probably not available.
*/
# ifndef LOCK_SH
#  define LOCK_SH 1
# endif
# ifndef LOCK_EX
#  define LOCK_EX 2
# endif
# ifndef LOCK_NB
#  define LOCK_NB 4
# endif
# ifndef LOCK_UN
#  define LOCK_UN 8
# endif

int
flock(fd, operation)
    int fd;
    int operation;
{
    switch (operation) {

=09/* LOCK_SH - get a shared lock */
      case LOCK_SH:
        rb_notimplement();
        return -1;
=09/* LOCK_EX - get an exclusive lock */
      case LOCK_EX:
=09return lockf (fd, F_LOCK, 0);

=09/* LOCK_SH|LOCK_NB - get a non-blocking shared lock */
      case LOCK_SH|LOCK_NB:
        rb_notimplement();
        return -1;
=09/* LOCK_EX|LOCK_NB - get a non-blocking exclusive lock */
      case LOCK_EX|LOCK_NB:
=09return lockf (fd, F_TLOCK, 0);

=09/* LOCK_UN - unlock */
      case LOCK_UN:
=09return lockf (fd, F_ULOCK, 0);

=09/* Default - can't decipher operation */
      default:
=09errno =3D EINVAL;
        return -1;
    }
}
#elif !defined _WIN32
int
flock(fd, operation)
    int fd;
    int operation;
{
    rb_notimplement();
    return -1;
}
#endif



-a
--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| ADDRESS :: E/GC2 325 Broadway, Boulder, CO 80305-3328
| URL     :: http://www.ngdc.noaa.gov/stp/
| "640K ought to be enough for anybody." - Bill Gates, 1981
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D



-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
