From: Andrew Ryan <andrewr@nam-shub.com>
Subject: Re: 2.4.19+RPC_ALL hangs running dbench 2.0
Date: Mon, 14 Oct 2002 22:03:28 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5.0.2.1.0.20021014215801.02898ec0@pop.sfrn.dnai.com>
References: <Pine.BSF.4.32L2.0210141450280.12721-100000@lenny.sfrn.dnai.com>
 <Pine.BSF.4.32L2.0210141450280.12721-100000@lenny.sfrn.dnai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; format=flowed
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from barney.sfrn.dnai.com ([208.59.199.24])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181Jq5-0004dy-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 22:01:53 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shs8z10l7u6.fsf@charged.uio.no>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

I applied this patch on top of Oct-05 NFS_ALL, rebuilt my kernel, and still 
get the same problem.

Anything else I can try?

At 05:05 AM 10/15/02 +0200, Trond Myklebust wrote:
> >>>>> " " == Andrew Ryan <andrewr@nam-shub.com> writes:
>
>      > When I ctl-C the hung dbench process, sometimes the kernel
>      > generates an oops, but other times not. If I have kdb on, I can
>      > get a backtrace, but I was hoping there was an easier way to
>      > figure out what is causing this bug. The one oops I get says
>      > something about 'kernel BUG at highmem.c:159!'
>
>The following patch removes an unbalanced kunmap() that should really
>have gone in -fix_kmap2.dif.
>
>Marcelo: this needs to be applied to 2.4.20-pre10 (it's already in 2.5.x).
>
>Cheers,
>   Trond
>
>--- linux-2.4.19-smp/fs/nfs/dir.c.orig  Sat Oct  5 03:55:12 2002
>+++ linux-2.4.19-smp/fs/nfs/dir.c       Tue Oct 15 04:59:27 2002
>@@ -152,7 +152,6 @@
>         return 0;
>   error:
>         SetPageError(page);
>-       kunmap(page);
>         UnlockPage(page);
>         invalidate_inode_pages(inode);
>         desc->error = error;



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
