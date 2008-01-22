From: Jan Engelhardt <jengelh-bdq14YP6qtRlEiWPh9xO2Q@public.gmane.org>
Subject: [NFS] [PATCH] knfsd: constify function pointer tables
Date: Tue, 22 Jan 2008 20:48:49 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0801222048340.5722@fbirervta.pbzchgretzou.qr>
References: <54038cd4f87a03884e4f59f8f3697889dfb63c54.1201030614.git.jengelh@computergmbh.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43512 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752100AbYAVTtJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jan 2008 14:49:09 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JHP7K-00037F-Au
	for linux-nfs@vger.kernel.org; Wed, 23 Jan 2008 06:49:06 +1100
In-Reply-To: <54038cd4f87a03884e4f59f8f3697889dfb63c54.1201030614.git.jengelh-bdq14YP6qtRlEiWPh9xO2Q@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jan Engelhardt <jengelh-bdq14YP6qtRlEiWPh9xO2Q@public.gmane.org>
---
 fs/nfsd/export.c |    2 +-
 fs/nfsd/nfsctl.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 66d0aeb..af2da43 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -1539,7 +1539,7 @@ static int e_show(struct seq_file *m, void *p)
 	return svc_export_show(m, &svc_export_cache, cp);
 }
 
-struct seq_operations nfs_exports_op = {
+const struct seq_operations nfs_exports_op = {
 	.start	= e_start,
 	.next	= e_next,
 	.stop	= e_stop,
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 77dc989..9d23cae 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -149,7 +149,7 @@ static const struct file_operations transaction_ops = {
 	.release	= simple_transaction_release,
 };
 
-extern struct seq_operations nfs_exports_op;
+extern const struct seq_operations nfs_exports_op;
 static int exports_open(struct inode *inode, struct file *file)
 {
 	return seq_open(file, &nfs_exports_op);
-- 
1.5.3.4


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

