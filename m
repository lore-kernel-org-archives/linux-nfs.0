From: "Richard B. Johnson" <root@chaos.analogic.com>
Subject: Re: [PATCH] 2.4.19-rc1/2.5.25 provide dummy fsync() routine for directories on NFS mounts
Date: Tue, 9 Jul 2002 15:13:14 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <agfcp3$2a1$2@main.gmane.org>
References: <E17S0OD-0005UY-00@the-village.bc.nu>
Reply-To: root@chaos.analogic.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>, nfs@lists.sourceforge.net,
   linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from chaos.analogic.com ([204.178.40.224])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17S0QV-00037M-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Jul 2002 12:13:31 -0700
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <E17S0OD-0005UY-00@the-village.bc.nu>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On Tue, 9 Jul 2002, Alan Cox wrote:

> > Really? Then what is the meaning of fsync() on a read-only file-
> > descriptor? You can't update the information you can't change.
> 
> fsync ensures the data for that inode/file content is on stable storage - note
> _the_ _data_ not only random things written by this specific file handle.
> 

That is what it's supposed to do with files. The attached code clearly
shows that it doesn't work with directories. The fsync() instantly
returns, even though there is buffered data still to be written.


#include <stdio.h>
#include <unistd.h>
#include <fcntl.h>
#define NR_WRITES 0x1000
int main()
{
    char foo[0x10000];

    int dirfd, outfd;
    int flags, i;
    outfd = open("/foo", O_WRONLY|O_TRUNC|O_CREAT, 0644);


    dirfd = open("/", O_RDONLY, 0);
    flags = fcntl(dirfd, F_GETFL);
    flags &= ~O_RDONLY;
    flags |= O_RDWR;
    fcntl(dirfd, F_SETFL, flags);
    fprintf(stderr, "Write %d bytes\n", sizeof(foo) * NR_WRITES);
    for(i=0; i< NR_WRITES; i++)
        write(outfd, foo, sizeof(foo));
    fprintf(stderr, "Write complete\n");
    fprintf(stderr, "Sync the directory\n");
    fsync(dirfd);
    fprintf(stderr, "Done, returns immediately!\n");
    close(outfd);
    fprintf(stderr, "Now execute sync and see if your disk is active!\n");
//    unlink("/foo");
}


Again, to assure that file-data is written to storage, one must
execute fsync on files, not directories. The dummy return of 0,
that Linux provides is a database bug waiting to happen.

Cheers,
Dick Johnson

Penguin : Linux version 2.4.18 on an i686 machine (797.90 BogoMips).

                 Windows-2000/Professional isn't.



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Stuff, things, and much much more.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
