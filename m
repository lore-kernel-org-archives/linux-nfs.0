From: Bernd Schubert <bernd-schubert@web.de>
Subject: Re: list of patches between 2.6.9 and 2.6.11-rc4
Date: Tue, 22 Feb 2005 02:00:13 +0100
Message-ID: <200502220200.13774.bernd-schubert@web.de>
References: <200502212335.25502.bernd-schubert@web.de> <1109030592.22895.57.camel@lade.trondhjem.org> <1109030738.22895.59.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D3OOS-00052m-7u
	for nfs@lists.sourceforge.net; Mon, 21 Feb 2005 16:59:16 -0800
Received: from smtp08.web.de ([217.72.192.226])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D3OOR-0000MB-Bl
	for nfs@lists.sourceforge.net; Mon, 21 Feb 2005 16:59:16 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1109030738.22895.59.camel@lade.trondhjem.org>
Sender: nfs-admin@lists.sourceforge.net
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

Hello Trond,

thanks for the bitkeeper information, it seems I need to become familiar wi=
th=20
it :)


On Tuesday 22 February 2005 01:05, you wrote:
> m=E5 den 21.02.2005 Klokka 19:03 (-0500) skreiv Trond Myklebust:
> > You should really always be mounting using "nolock" when you are running
> > against unfs3. Is that what you have normally been using?
>
> Duh... Sorry, you've already answered that question in your mail....
>
> Do you have a "strace" output of what ypbind is seeing?

To make it easier to understand I isolated the code and testing it as own=20
program.

=2E..
access("/etc/ld.so.nohwcap", F_OK)      =3D -1 ENOENT (No such file or=20
directory)
open("/lib/tls/i686/cmov/libc.so.6", O_RDONLY) =3D 3
read(3, "\177ELF\1\1\1\0\0\0\0\0\0\0\0\0\3\0\3\0\1\0\0\0\300\350"..., 512) =
=3D=20
512
fstat64(3, {st_mode=3DS_IFREG|0644, st_size=3D1281552, ...}) =3D 0
old_mmap(0x41019000, 1284940, PROT_READ|PROT_EXEC, MAP_PRIVATE, 3, 0) =3D=20
0x41019000
old_mmap(0x41148000, 32768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED, 3,=
=20
0x12f000) =3D 0x41148000
old_mmap(0x41150000, 11084, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|
MAP_ANONYMOUS, -1, 0) =3D 0x41150000
close(3)                                =3D 0
old_mmap(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0=
) =3D=20
0x4001e000
set_thread_area({entry_number:-1 -> 6, base_addr:0x4001e460, limit:1048575,=
=20
seg_32bit:1, contents:0, read_exec_only:0, limit_in_pages:1,=20
seg_not_present:0, useable:1}) =3D 0
munmap(0x40001000, 115498)              =3D 0
open("/var/run/test_lock.pid", O_RDWR|O_CREAT, 0644) =3D 3
fcntl64(3, F_GETFD)                     =3D 0
fcntl64(3, F_SETFD, FD_CLOEXEC)         =3D 0
fcntl64(3, F_GETLK, {type=3DF_WRLCK, whence=3DSEEK_SET, start=3D0, len=3D0,=
 pid=3D3595})=20
=3D 0
fstat64(1, {st_mode=3DS_IFCHR|0600, st_rdev=3Dmakedev(136, 0), ...}) =3D 0
mmap2(NULL, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) =
=3D=20
0x40001000
write(1, " lock.l_type =3D 1\n", 17 lock.l_type =3D 1
)      =3D 17
write(1, " F_UNLCK =3D 2\n", 13 F_UNLCK =3D 2
)          =3D 13
write(1, "errno: 0: Success\n", 18errno: 0: Success
)     =3D 18
write(1, "ypbind-mt already running (pid 3"..., 47ypbind-mt already running=
=20
(pid 3595) - exiting
) =3D 47
munmap(0x40001000, 4096)                =3D 0
exit_group(1)                           =3D ?


The PID file is of course empty, so I don't know whats causing the problem=
=20
there, but I'm also not familiar with file locking.


#include <sys/param.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/stat.h>
#include <dirent.h>
#include <stdio.h>
#include <ctype.h>
#include <fcntl.h>
#include <errno.h>
#include <stdlib.h>
#include <unistd.h>
#include <syslog.h>
#include <string.h>
#include <signal.h>
#include <locale.h>
#include <libintl.h>
#include <rpc/rpc.h>
#if defined(HAVE_RPC_SVC_SOC_H)
#include <rpc/svc_soc.h>
#endif /* HAVE_RPC_SVC_SOC_H */
#include <rpcsvc/ypclnt.h>
#include <rpc/pmap_clnt.h>
#include <pthread.h>
#if defined(HAVE_NSS_H)
#include <nss.h>
#endif

#define _(String) gettext (String)

#ifdef HAVE_PATHS_H
#include <paths.h>
#endif



#define _YPBIND_PIDFILE "/var/run/test_lock.pid"

void main ( void )
{
        int lock_fd;
        struct flock lock ;
        int left, written;
        pid_t pid;
        char pbuf[ 10 ], *ptr;
        int flags;

        lock_fd =3D open ( _YPBIND_PIDFILE, O_CREAT | O_RDWR,
                         S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH );
        if ( lock_fd < 0 )
                printf (  "cannot create pidfile %s" , _YPBIND_PIDFILE );

        /* Make sure file gets correctly closed when process finished.  */
        flags =3D fcntl ( lock_fd, F_GETFD, 0 );
        if ( flags =3D=3D -1 ) {
                /* Cannot get file flags.  */
                close ( lock_fd );
                return ;
        }
        flags |=3D FD_CLOEXEC;          /* Close on exit.  */
        if ( fcntl ( lock_fd, F_SETFD, flags ) < 0 ) {
                /* Cannot set new flags.  */
                close ( lock_fd );
                return ;
        }

        lock.l_type =3D F_WRLCK;
        lock.l_start =3D 0;
        lock.l_whence =3D SEEK_SET;
        lock.l_len =3D 0;

        /* Is the pidfile locked by another ypserv ? */
        if ( fcntl ( lock_fd, F_GETLK, &lock ) < 0 ) {
                if ( errno !=3D ENOLCK ) {
                        printf (  "fcntl error: %s" , strerror ( errno ) );
                        /* XXX look, which pid is in pidfile */
                }
                pid =3D 0;
        }
        else if ( lock.l_type =3D=3D F_UNLCK )
                pid =3D 0;               /* false, region is not locked by=
=20
another proc */
        else  {
                printf(" lock.l_type =3D %i\n", lock.l_type);
                printf(" F_UNLCK =3D %i\n", F_UNLCK);
                pid =3D lock.l_pid;      /* true, return pid of lock owner =
*/
                printf("errno: %i: %s\n", errno, strerror(errno));

        }

        if ( pid !=3D 0 ) {
                printf ( "ypbind-mt already running (pid %d) - exiting\n" ,
                          pid );
                exit ( 1 );
        }

        printf("locking seems to work fine, pid=3D%i\n", pid);
}


Thanks a lot for your help,
 Bernd


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
