From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: Re: debugging hanging locks
Date: Tue, 17 Aug 2004 17:30:47 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408171718050.12428@harp.ngdc.noaa.gov>
References: <Pine.LNX.4.60.0408161741020.5649@harp.ngdc.noaa.gov>
 <1092702159.11722.77.camel@lade.trondhjem.org>
 <Pine.LNX.4.60.0408161846440.5649@harp.ngdc.noaa.gov>
 <1092757186.4030.11.camel@lade.trondhjem.org>  <Pine.LNX.4.60.0408171146190.12428@harp.ngdc.noaa.gov>
 <1092765798.4030.59.camel@lade.trondhjem.org>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="8323328-1604903416-1092785447=:12428"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BxDQ0-0008Gl-Vf
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 16:31:04 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BxDQ0-00049u-De
	for nfs@lists.sourceforge.net; Tue, 17 Aug 2004 16:31:04 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1092765798.4030.59.camel@lade.trondhjem.org>
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

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--8323328-1604903416-1092785447=:12428
Content-Type: TEXT/PLAIN; charset=X-UNKNOWN; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE

On Tue, 17 Aug 2004, Trond Myklebust wrote:

> P=E5 ty , 17/08/2004 klokka 13:50, skreiv Ara.T.Howard:
>
>> any ideas how one might try to exercise the kernel's clean-up beyond sim=
ply
>> sending SIGKILL to processes holding locks?  perhaps calls to _exit and
>> sendend one's self SIGKILL?
>
> Just failing to lockf(F_ULOCK) will cause it to trigger, however the
> races tend to occur if/when you interrupt the actual lockf(F_LOCK) call,
> since that may cause the client to miss a reply from the server.

so this code seems to expose the soft timeout bug and/or the kernel not
cleaning up properly - if you run this and compile it:

  ~ > cd nfs_mounted
  ~ > gcc lock.c
  ~ > touch foobar
  ~ > a.out foobar

you'll see the program eventually start failing.  the code forks a child th=
at
attempts to get a lock and not clean up well after itself.  the parent slee=
ps
a tiny bit and sometimes sends SIGKILL to the child.  the expectation is th=
at
the child should sometime succeed and sometimes fail (if killed with -9) - =
but
that the some future child should succeed at getting the lock since the ker=
nel
should eventually clean up the mess.  instead i see the children all succee=
d
untill, sudenly, they all start failing and no more ever succeed.  in
otherwords, some mess is created that causes the child to never be able to =
get
the lock again...

code inlined below...

thoughts?

-a
--
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| A flower falls, even though we love it;
| and a weed grows, even though we do not love it.=20
|   --Dogen
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D


#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
int
main (argc, argv)
   int argc;
   char **argv;
{
   struct flock flock;
   char *path;
   int fd;
   int ret;

   path =3D argv[1];
   fd =3D open (path, O_RDWR);
   printf ("fd <%d>\n", fd);

   flock.l_type =3D F_WRLCK;
   flock.l_whence =3D SEEK_SET;
   flock.l_start =3D 0;
   flock.l_len =3D 0;

   ret =3D fcntl (fd, F_SETLK, &flock);

   printf ("lock <%s> =3D> %d\n", path, ret);
   (void) getc (stdin);
   return (EXIT_SUCCESS);
}
--8323328-1604903416-1092785447=:12428--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
