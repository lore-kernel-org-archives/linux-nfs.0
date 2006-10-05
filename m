From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: Found issue with BKL not held during call
	to	nfs_asynch_unlink_release()
Date: Thu, 05 Oct 2006 10:46:04 -0700
Message-ID: <1160070364.3376.71.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVXGM-0000n9-CU
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 10:44:02 -0700
Received: from e33.co.us.ibm.com ([32.97.110.151])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GVXGM-0003Ds-Ly
	for nfs@lists.sourceforge.net; Thu, 05 Oct 2006 10:44:03 -0700
Received: from westrelay02.boulder.ibm.com (westrelay02.boulder.ibm.com
	[9.17.195.11])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k95HhrY3006600
	for <nfs@lists.sourceforge.net>; Thu, 5 Oct 2006 13:43:53 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by westrelay02.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k95HhriZ485678
	for <nfs@lists.sourceforge.net>; Thu, 5 Oct 2006 11:43:53 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k95HhqrK032140
	for <nfs@lists.sourceforge.net>; Thu, 5 Oct 2006 11:43:52 -0600
Received: from dyn9047022153 (dyn9047022153.beaverton.ibm.com [9.47.22.153])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.12.11) with ESMTP id
	k95HhqRm032117
	for <nfs@lists.sourceforge.net>; Thu, 5 Oct 2006 11:43:52 -0600
To: NFS List <nfs@lists.sourceforge.net>
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

We have found a problem with the BKL not being held during a call to
nfs_asynch_unlink_release(), the call stack (this is an rpciod process)
is:

nfs_async_unlink_release (called via tk_ops->rpc_release())
rpc_release_task
__rpc_execute
run_workqueue
worker_thread
kthread
kernel_thread

I have been talking to Chuck Lever about this because I had noted one of
his patches for removing the BKL added a spin lock to protect the
nfs_deletes list used in fs/nfs/unlink.c. This patch happens to fix the
specific problem we are seeing, but discussion with Chuck suggests there
may be a larger problem.

Chuck pointed out that tk_ops is a recent addition, and that perhaps the
think to do would be to add a lock_kernel() around the call to 
tk_ops->rpc_release().

When I had been investigating removing the BKL, I had noted that it
seemed inconsistent whether the BKL was held for calls to rpc_execute(),
and in some cases, the BKL was held ONLY for the call to rpc_execute().
My investigations found that rpciod does not hold the BKL when calling
__rpc_execute(), and I also think some of the direct I/O code in
fs/nfs/direct.c does not hold the BKL, or possible the asynch code (I
didn't keep good notes - I had made a cursory examination, then noted
for sure there were code paths where rpc_execute was called without the
BKL, and naively assumed it was not needed, and didn't pursue exactly
which calls did and did not hold the BKL - it seems that assumption may
be wrong).

At first, I thought that using Chuck's patch to unlink.c would be a good
fix since it would not introduce new lock_kernel() calls, however, if
there may be other holes, it might be simpler to put the proper
lock_kernel() calls in, and then cleanly remove all uses of the BKL when
Chuck's patch set is adopted.

Frank Filz



-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
