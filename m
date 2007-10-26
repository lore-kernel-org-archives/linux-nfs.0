From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/27] NFS: Fix use of copy_to_user() in
	idmap_pipe_upcall
Date: Fri, 26 Oct 2007 13:31:36 -0400
Message-ID: <20071026173136.31475.13261.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT2B-0007Dv-0M
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:49 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT2F-0008Ms-AY
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:52 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

The idmap_pipe_upcall() function expects the copy_to_user() function to
return a negative error value if the call fails, but copy_to_user()
returns an unsigned long number of bytes that couldn't be copied.
    
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/idmap.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/idmap.c b/fs/nfs/idmap.c
index e687ba2..6ecc9c3 100644
--- a/fs/nfs/idmap.c
+++ b/fs/nfs/idmap.c
@@ -357,19 +357,20 @@ idmap_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
 		  char __user *dst, size_t buflen)
 {
 	char *data = (char *)msg->data + msg->copied;
-	ssize_t mlen = msg->len - msg->copied;
-	ssize_t left;
+	size_t mlen = msg->len;
+	unsigned long left;
 
 	if (mlen > buflen)
 		mlen = buflen;
 
 	left = copy_to_user(dst, data, mlen);
-	if (left < 0) {
-		msg->errno = left;
-		return left;
+	if (left == mlen) {
+		msg->errno = -EFAULT;
+		return -1;
 	}
+
 	mlen -= left;
-	msg->copied += mlen;
+	msg->copied += left;
 	msg->errno = 0;
 	return mlen;
 }


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
