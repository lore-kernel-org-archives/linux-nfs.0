From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Found issue with BKL not held during call
	to	nfs_asynch_unlink_release()
Date: Thu, 05 Oct 2006 17:53:42 -0400
Message-ID: <1160085222.15051.8.camel@lade.trondhjem.org>
References: <1160070364.3376.71.camel@dyn9047022153>
	<1160079629.10668.3.camel@lade.trondhjem.org>
	<1160081896.3376.87.camel@dyn9047022153>
	<1160082597.12684.8.camel@lade.trondhjem.org>
	<76bd70e30610051425g49ff3e50j1d698bfacb784a41@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Frank Filz <ffilzlnx@us.ibm.com>,
	NFS List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVbAA-0006mA-Lh
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 14:53:54 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GVbAB-0002lx-4H
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 14:53:55 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30610051425g49ff3e50j1d698bfacb784a41@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, 2006-10-05 at 17:25 -0400, Chuck Lever wrote:

> One more, in rpc_run_task()...

Yep.

> > Note that this would allow us to immediately get rid of all the BKL
> > wrappers around rpc_call_*() and friends.
> 
> Do you mean rpc_call_{a,}sync() or do you mean the tk_ops calls?

All direct calls to rpc_call_(a|)sync, rpc_run_task, and rpc_execute
that are being wrapped. See for instance nfs_execute_write,
nfs_execute_read, nfs_direct_read_schedule, nfs_direct_commit_schedule,
nfs_direct_write_schedule.

Also see nfs_symlink_filler, nfs3_proc_readdir, nfs_proc_readdir.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
