From: Srinivasa Ds <srinivasa@in.ibm.com>
Subject: [PATCH] NFS4  fix for recursive locking problem.
Date: Tue, 31 Oct 2006 19:24:56 +0530
Message-ID: <454755B0.5020103@in.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030606080606090309030201"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GetZ2-0001zB-BW
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 05:22:00 -0800
Received: from ausmtp04.au.ibm.com ([202.81.18.152])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GetYy-0001aQ-LU
	for nfs@lists.sourceforge.net; Tue, 31 Oct 2006 05:22:01 -0800
Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.5) with ESMTP id k9VDVlFj212580
	for <nfs@lists.sourceforge.net>; Wed, 1 Nov 2006 00:31:47 +1100
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0208e0.au.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id
	k9VDOlFa238072
	for <nfs@lists.sourceforge.net>; Wed, 1 Nov 2006 00:24:52 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	k9VDGn8B029820
	for <nfs@lists.sourceforge.net>; Wed, 1 Nov 2006 00:16:49 +1100
To: linux-kernel@vger.kernel.org, akpm@osdl.org, neilb@suse.de,
	nfs@lists.sourceforge.net, bfields@fieldses.org,
	andros@citi.umich.edu
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

This is a multi-part message in MIME format.
--------------030606080606090309030201
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

When I was performing some operations on NFS, I got below error on server side.

===========================================================

=============================================
[ INFO: possible recursive locking detected ]
2.6.19-prep #1
---------------------------------------------
nfsd4/3525 is trying to acquire lock:
 (&inode->i_mutex){--..}, at: [<c0611e5a>] mutex_lock+0x21/0x24

but task is already holding lock:
 (&inode->i_mutex){--..}, at: [<c0611e5a>] mutex_lock+0x21/0x24

other info that might help us debug this:
2 locks held by nfsd4/3525:
 #0:  (client_mutex){--..}, at: [<c0611e5a>] mutex_lock+0x21/0x24
 #1:  (&inode->i_mutex){--..}, at: [<c0611e5a>] mutex_lock+0x21/0x24

stack backtrace:
 [<c04051ed>] show_trace_log_lvl+0x58/0x16a
 [<c04057fa>] show_trace+0xd/0x10
 [<c0405913>] dump_stack+0x19/0x1b
 [<c043b6f1>] __lock_acquire+0x778/0x99c
 [<c043be86>] lock_acquire+0x4b/0x6d
 [<c0611ceb>] __mutex_lock_slowpath+0xbc/0x20a
 [<c0611e5a>] mutex_lock+0x21/0x24
 [<c047fd7e>] vfs_rmdir+0x76/0xf8
 [<f94b7ce9>] nfsd4_clear_clid_dir+0x2c/0x41 [nfsd]
 [<f94b7de9>] nfsd4_remove_clid_dir+0xb1/0xe8 [nfsd]
 [<f94b307b>] laundromat_main+0x9b/0x1c3 [nfsd]
 [<c04333d6>] run_workqueue+0x7a/0xbb
 [<c0433d0b>] worker_thread+0xd2/0x107
 [<c0436285>] kthread+0xc3/0xf2
 [<c0402005>] kernel_thread_helper+0x5/0xb
===================================================================
Cause for this problem was,2 successive mutex_lock calls on 2 diffrent inodes ,as shown below
======================================================
static int
nfsd4_clear_clid_dir(struct dentry *dir, struct dentry *dentry)
{
        int status;

        /* For now this directory should already be empty, but we empty it of
         * any regular files anyway, just in case the directory was created by
         * a kernel from the future.... */
        nfsd4_list_rec_dir(dentry, nfsd4_remove_clid_file);
        mutex_lock(&dir->d_inode->i_mutex);
        status = vfs_rmdir(dir->d_inode, dentry);
=======================================================
int vfs_rmdir(struct inode *dir, struct dentry *dentry)
{
        int error = may_delete(dir, dentry, 1);

        if (error)
                return error;

        if (!dir->i_op || !dir->i_op->rmdir)
                return -EPERM;

        DQUOT_INIT(dir);

        mutex_lock(&dentry->d_inode->i_mutex);
===========================================================
So I have developed the patch to overcome this problem. Please let me know your comments on this.

Signed-off-by: Srinivasa DS <srinivasa@in.ibm.com>




--------------030606080606090309030201
Content-Type: text/plain;
 name="nfs4.fix"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfs4.fix"

 nfs4recover.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: linux-2.6.19-rc3/fs/nfsd/nfs4recover.c
===================================================================
--- linux-2.6.19-rc3.orig/fs/nfsd/nfs4recover.c	2006-10-24 04:32:02.000000000 +0530
+++ linux-2.6.19-rc3/fs/nfsd/nfs4recover.c	2006-10-31 18:27:30.000000000 +0530
@@ -274,7 +274,7 @@
 	 * any regular files anyway, just in case the directory was created by
 	 * a kernel from the future.... */
 	nfsd4_list_rec_dir(dentry, nfsd4_remove_clid_file);
-	mutex_lock(&dir->d_inode->i_mutex);
+	mutex_lock_nested(&dir->d_inode->i_mutex, I_MUTEX_PARENT);
 	status = vfs_rmdir(dir->d_inode, dentry);
 	mutex_unlock(&dir->d_inode->i_mutex);
 	return status;

--------------030606080606090309030201
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--------------030606080606090309030201
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--------------030606080606090309030201--
