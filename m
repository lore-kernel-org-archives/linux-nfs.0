From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Re: Found issue with BKL not held during
	call	to	nfs_asynch_unlink_release()
Date: Thu, 05 Oct 2006 16:46:16 -0700
Message-ID: <1160091976.3376.97.camel@dyn9047022153>
References: <1160070364.3376.71.camel@dyn9047022153>
	<1160079629.10668.3.camel@lade.trondhjem.org>
	<1160081896.3376.87.camel@dyn9047022153>
	<1160082597.12684.8.camel@lade.trondhjem.org>
	<76bd70e30610051425g49ff3e50j1d698bfacb784a41@mail.gmail.com>
	<1160085222.15051.8.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NFS List <nfs@lists.sourceforge.net>,
	Chuck Lever <chucklever@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVcsu-0007yK-MA
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 16:44:13 -0700
Received: from e33.co.us.ibm.com ([32.97.110.151])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GVcsu-00008e-DD
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 16:44:13 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k95Ni6TK022888
	for <nfs@lists.sourceforge.net>; Thu, 5 Oct 2006 19:44:06 -0400
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k95Ni6PR336840
	for <nfs@lists.sourceforge.net>; Thu, 5 Oct 2006 17:44:06 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k95Ni6nl012126
	for <nfs@lists.sourceforge.net>; Thu, 5 Oct 2006 17:44:06 -0600
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1160085222.15051.8.camel@lade.trondhjem.org>
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

On Thu, 2006-10-05 at 17:53 -0400, Trond Myklebust wrote:
> On Thu, 2006-10-05 at 17:25 -0400, Chuck Lever wrote:
> 
> > One more, in rpc_run_task()...
> 
> Yep.
> 
> > > Note that this would allow us to immediately get rid of all the BKL
> > > wrappers around rpc_call_*() and friends.
> > 
> > Do you mean rpc_call_{a,}sync() or do you mean the tk_ops calls?
> 
> All direct calls to rpc_call_(a|)sync, rpc_run_task, and rpc_execute
> that are being wrapped. See for instance nfs_execute_write,
> nfs_execute_read, nfs_direct_read_schedule, nfs_direct_commit_schedule,
> nfs_direct_write_schedule.
> 
> Also see nfs_symlink_filler, nfs3_proc_readdir, nfs_proc_readdir.

I looked over all of those. A few had a bit more than just a call to rpc
inside the BKL, but I'm pretty sure they are all safe (references to the
inode and such, which should be locked, or references to stack
variables). I won't get a chance to test this until next week, but looks
promising. This will definitely remove a bunch of lock_kernel() calls at
the expense of one new one.

Frank



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
