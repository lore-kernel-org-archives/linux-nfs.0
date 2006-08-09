From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 22/25] NFS: remove a no-longer-needed error check in
	nfs_symlink()
Date: Wed, 09 Aug 2006 10:59:43 -0400
Message-ID: <20060809145943.3914.99861.stgit@picasso.dsl.sfldmi.ameritech.net>
References: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GApcT-0000oo-Ew
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:18 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GApcT-0003FP-6k
	for nfs@lists.sourceforge.net; Wed, 09 Aug 2006 08:05:18 -0700
To: trond.myklebust@fys.uio.no
In-Reply-To: <20060809144716.3914.62804.stgit@picasso.dsl.sfldmi.ameritech.net>
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

In the early days of NFS, there was no duplicate reply cache on the server.
Thus retransmitted non-idempotent requests often found that the request had
already completed on the server.  To avoid passing an unanticipated return
code to unsuspecting applications, NFS clients would often shunt error
codes that implied the request had been retried but already completed.

On modern NFS clients, it is safe to remove such checks.

Test plan:
None.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e7ffb4d..428d963 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1472,14 +1472,10 @@ #endif
 	error = NFS_PROTO(dir)->symlink(dir, &dentry->d_name, &qsymname,
 					  &attr, &sym_fh, &sym_attr);
 	nfs_end_data_update(dir);
-	if (!error) {
+	if (!error)
 		error = nfs_instantiate(dentry, &sym_fh, &sym_attr);
-	} else {
-		if (error == -EEXIST)
-			printk("nfs_proc_symlink: %s/%s already exists??\n",
-			       dentry->d_parent->d_name.name, dentry->d_name.name);
+	else
 		d_drop(dentry);
-	}
 	unlock_kernel();
 	return error;
 }

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
