From: "Richard B. Johnson" <root@chaos.analogic.com>
Subject: Re: [PATCH] 2.4.19-rc1/2.5.25 provide dummy fsync() routine for directories on NFS mounts
Date: Tue, 9 Jul 2002 10:06:45 -0400 (EDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <ager03$jie$2@main.gmane.org>
References: <200207091549.15913.trond.myklebust@fys.uio.no>
Reply-To: root@chaos.analogic.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from chaos.analogic.com ([204.178.40.224])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17RvcZ-00078L-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Jul 2002 07:05:39 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <200207091549.15913.trond.myklebust@fys.uio.no>
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

On Tue, 9 Jul 2002, Trond Myklebust wrote:

> Hi,
> 
>    There was a bug reported on the 'exim' user list a couple of months ago: 
> the Linux NFS client reports -EINVAL if you try to fsync() a directory.
> 
>    The correct response would be to return a dummy '0' for success, since all 
> NFS operations that change the directory are supposed to be performed 
> synchronously on the server anyway...
> 
> Cheers,
>   Trond
> 
> 

Isn't it supposed to return EINVAL if "fd is bound to a file which
doesn't support synchronization..."  That's what POSIX 4 says.

Errors:
EBADF	fildes is not a valid file descriptor.
EINVAL	The file descriptor is valid, but the system doesn't support
	fsync on this particular file.

I think code that opens a directory as a file is broken. We have
opendir() for that and it returns a DIR pointer, not a file descriptor.
If the directory was properly opened, one would never attempt to
fsync() it.

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
