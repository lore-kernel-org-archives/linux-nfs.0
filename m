From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/27] SUNRPC: Prevent length underflow in read_flush()
Date: Fri, 26 Oct 2007 13:31:20 -0400
Message-ID: <20071026173120.31475.76007.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlT20-0007Da-N4
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:36 -0700
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]
	helo=flpi185.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IlT26-0008FS-4q
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 10:31:42 -0700
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

Make sure we compare an unsigned length to an unsigned count in
read_flush().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/cache.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
index 8e05557..578084f 100644
--- a/net/sunrpc/cache.c
+++ b/net/sunrpc/cache.c
@@ -1242,18 +1242,18 @@ static ssize_t read_flush(struct file *file, char __user *buf,
 	struct cache_detail *cd = PDE(file->f_path.dentry->d_inode)->data;
 	char tbuf[20];
 	unsigned long p = *ppos;
-	int len;
+	size_t len;
 
 	sprintf(tbuf, "%lu\n", cd->flush_time);
 	len = strlen(tbuf);
 	if (p >= len)
 		return 0;
 	len -= p;
-	if (len > count) len = count;
+	if (len > count)
+		len = count;
 	if (copy_to_user(buf, (void*)(tbuf+p), len))
-		len = -EFAULT;
-	else
-		*ppos += len;
+		return -EFAULT;
+	*ppos += len;
 	return len;
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
