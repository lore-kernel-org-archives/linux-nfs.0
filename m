From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFS - Fix for Infinite loop during syncing
Date: Mon, 31 Jan 2005 12:44:38 -0500
Message-ID: <41FE6E86.8060303@RedHat.com>
References: <41BDFA46.7070403@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090402040006090802030704"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CvfZ9-0002C1-SQ
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 09:42:23 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CvfZ8-0001AI-Ur
	for nfs@lists.sourceforge.net; Mon, 31 Jan 2005 09:42:23 -0800
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j0VHgLB5005710
	for <nfs@lists.sourceforge.net>; Mon, 31 Jan 2005 12:42:21 -0500
Received: from [192.168.62.4] (vpn83-134.boston.redhat.com [172.16.83.134])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j0VHgLO04243
	for <nfs@lists.sourceforge.net>; Mon, 31 Jan 2005 12:42:21 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <41BDFA46.7070403@RedHat.com>
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

This is a multi-part message in MIME format.
--------------090402040006090802030704
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Steve Dickson wrote:

>
> It was brought to my attention that following series of events
> would cause an infinite loop in the 2.4 nfs kernels.
>
> 1) Mount the fileystem with acregmin=1,acregmax=1 from two clients.
> 2) On client 1, create a process that continuously writes to a file.
> 3) On client 2, remove that file that is being written
> 4) On client 1, interrupted out of the writing process (which is failing
>     with ESTALEs) and type sync
>
Here is an update patch to this problem. My original patch does
avoid the infinite loop but didn't address the actual cause of the loop.
The attached patch does... and here is what is happening:

A process is continuity writing to a broken (i.e ESTALE) fd which
is queuing up pages to be sent out.

A getattr happens (due a cache time out) which fails with ESTALE
so _nfs_revalidate_inode() removes the inode from the hash list:

    if (status == -ESTALE) {
        NFS_FLAGS(inode) |= NFS_INO_STALE;
        if (inode != inode->i_sb->s_root->d_inode)
            remove_inode_hash(inode);
    }

Now when __sync_one() comes along and see the dirty pages, the inode
is added to the locked inode list,  data is sync-ed out and then
__refile_inode() is called:
<>
    list_add(&inode->i_list, &inode->i_sb->s_locked_inodes);
<>    inode->i_state |= I_LOCK;
    /* write out data */
    inode->i_state &= ~I_LOCK;
    if (!(inode->i_state & I_FREEING))
        __refile_inode(inode);

Now here is the problem! Since the inode is has already been removed
from the i_hash list, the inode is never refiled 
__refile_inode(inode):

    if (inode->i_state & I_FREEING)
        return;
    if (list_empty(&inode->i_hash))
        return;

which causes the infinite loop because the node is never removed from 
the locked
inode list. Now my original patch avoid this loop because 
__nfs_revalidate_inode()
saw the inode was stale before it removed the inode from the hash list. 
The attached
patch still "breaks" the inode earlier (since is stop a bunch of 
unnecessary i/o)  but
it also it removes the call to remove_inode_hash() in 
_nfs_revalidate_inode() which
is the real cause of the problem....

So code in question is:
    if (inode != inode->i_sb->s_root->d_inode)
        remove_inode_hash(inode);

and I hoping someone can shed some light on as to why the
inode is being removed from the i_hash list with an ESTALE failure.
Does it make sense to remove an inode from the i_hash when there
are dirty pages?

steved.



--------------090402040006090802030704
Content-Type: text/x-patch;
 name="linux-2.4.29-nfs-syncloop.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.29-nfs-syncloop.patch"

--- linux-2.4.29/fs/nfs/write.c.orig	2004-04-14 09:05:40.000000000 -0400
+++ linux-2.4.29/fs/nfs/write.c	2005-01-31 10:51:45.979056000 -0500
@@ -1073,6 +1073,9 @@ nfs_writeback_done(struct rpc_task *task
 			SetPageError(page);
 			if (req->wb_file)
 				req->wb_file->f_error = task->tk_status;
+			if (task->tk_status == -ESTALE)
+				NFS_FLAGS(inode) |= NFS_INO_STALE;
+
 			nfs_inode_remove_request(req);
 			dprintk(", error = %d\n", task->tk_status);
 			goto next;
@@ -1223,6 +1226,9 @@ nfs_commit_done(struct rpc_task *task)
 		if (task->tk_status < 0) {
 			if (req->wb_file)
 				req->wb_file->f_error = task->tk_status;
+			if (task->tk_status == -ESTALE)
+				NFS_FLAGS(inode) |= NFS_INO_STALE;
+
 			nfs_inode_remove_request(req);
 			dprintk(", error = %d\n", task->tk_status);
 			goto next;
--- linux-2.4.29/fs/nfs/inode.c.orig	2004-04-14 09:05:40.000000000 -0400
+++ linux-2.4.29/fs/nfs/inode.c	2005-01-31 11:02:13.492190000 -0500
@@ -907,11 +907,9 @@ __nfs_revalidate_inode(struct nfs_server
 	if (status) {
 		dfprintk(PAGECACHE, "nfs_revalidate_inode: (%x/%Ld) getattr failed, error=%d\n",
 			 inode->i_dev, (long long)NFS_FILEID(inode), status);
-		if (status == -ESTALE) {
+		if (status == -ESTALE) 
 			NFS_FLAGS(inode) |= NFS_INO_STALE;
-			if (inode != inode->i_sb->s_root->d_inode)
-				remove_inode_hash(inode);
-		}
+
 		goto out;
 	}
 

--------------090402040006090802030704--


-------------------------------------------------------
This SF.Net email is sponsored by: IntelliVIEW -- Interactive Reporting
Tool for open source databases. Create drag-&-drop reports. Save time
by over 75%! Publish reports on the web. Export to DOC, XLS, RTF, etc.
Download a FREE copy at http://www.intelliview.com/go/osdn_nl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
