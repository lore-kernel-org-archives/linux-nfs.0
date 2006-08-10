From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: rpc.idmapd oops with latest NFS bits from your web site
Date: Thu, 10 Aug 2006 17:44:34 -0400
Message-ID: <1155246274.5826.64.camel@localhost>
References: <76bd70e30608101221se9d6fb6l8bb50e93109c7a5b@mail.gmail.com>
	<1155238502.5826.2.camel@localhost>
	<76bd70e30608101245w45779d6u7ef99d790c726d31@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-PWxyx/3qtrY2hfsYi0r3"
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GBIKf-0001hs-NR
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 14:44:49 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GBIKd-0001XW-Qw
	for nfs@lists.sourceforge.net; Thu, 10 Aug 2006 14:44:50 -0700
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <76bd70e30608101245w45779d6u7ef99d790c726d31@mail.gmail.com>
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


--=-PWxyx/3qtrY2hfsYi0r3
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, 2006-08-10 at 15:45 -0400, Chuck Lever wrote:
> Yeah.  I'd say something is overwriting i_cdev with garbarge.  Then
> __fput sees that i_cdev is not NULL and tries to call cdev_put with a
> bogus address.

Looks like something is calling fput() on a file pointing to an inode
that has already been freed. 6b6b6b6b is the mark of the poisoned slab
entry.

Hmm.... Does the attached patch fix it for you?

Cheers,
  Trond



--=-PWxyx/3qtrY2hfsYi0r3
Content-Disposition: inline; filename=linux-2.6.18-fix_rpc_unlink_rmdir_2.dif
Content-Type: message/rfc822; name=linux-2.6.18-fix_rpc_unlink_rmdir_2.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
SUNRPC: rpc_rmdir() and rpc_unlink() must check for unhashed dentries
Date: Thu, 10 Aug 2006 17:44:24 -0400
Subject: No Subject
Message-Id: <1155246264.5826.63.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/rpc_pipe.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 9c355e1..0b1a1ac 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -539,6 +539,7 @@ repeat:
 				rpc_close_pipes(dentry->d_inode);
 				simple_unlink(dir, dentry);
 			}
+			inode_dir_notify(dir, DN_DELETE);
 			dput(dentry);
 		} while (n);
 		goto repeat;
@@ -610,8 +611,8 @@ __rpc_rmdir(struct inode *dir, struct de
 	int error;
 
 	shrink_dcache_parent(dentry);
-	if (dentry->d_inode)
-		rpc_close_pipes(dentry->d_inode);
+	if (d_unhashed(dentry))
+		return 0;
 	if ((error = simple_rmdir(dir, dentry)) != 0)
 		return error;
 	if (!error) {
@@ -747,13 +748,15 @@ rpc_unlink(struct dentry *dentry)
 	parent = dget_parent(dentry);
 	dir = parent->d_inode;
 	mutex_lock_nested(&dir->i_mutex, I_MUTEX_PARENT);
-	d_drop(dentry);
-	if (dentry->d_inode) {
-		rpc_close_pipes(dentry->d_inode);
-		error = simple_unlink(dir, dentry);
+	if (!d_unhashed(dentry)) {
+		d_drop(dentry);
+		if (dentry->d_inode) {
+			rpc_close_pipes(dentry->d_inode);
+			error = simple_unlink(dir, dentry);
+		}
+		inode_dir_notify(dir, DN_DELETE);
 	}
 	dput(dentry);
-	inode_dir_notify(dir, DN_DELETE);
 	mutex_unlock(&dir->i_mutex);
 	dput(parent);
 	return error;

--=-PWxyx/3qtrY2hfsYi0r3
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
--=-PWxyx/3qtrY2hfsYi0r3
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-PWxyx/3qtrY2hfsYi0r3--
