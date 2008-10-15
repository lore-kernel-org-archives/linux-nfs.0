From: Neil Brown <neilb@suse.de>
Subject: [PATCH/RFC]  Make nfs_file_cred more robust.
Date: Thu, 16 Oct 2008 09:28:01 +1100
Message-ID: <18678.28273.285015.747371@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns.suse.de ([195.135.220.2]:48379 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752585AbYJOW2s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Oct 2008 18:28:48 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Trond,
 I wonder if you would consider including the following patch which
 makes nfs_file_cred a little more robust.

 It isn't strictly needed with current mainline.  However we have a patch
 set which (among other things) passes a 'struct file' down (via
 ATTR_FILE) for a chmod call.
 If chmod is called on e.g. a device special file, this will cause
 nfs3_proc_setattr to call nfs_file_cred on a 'struct file' which does
 not have an associated open context or credential.  That goes Oops.

 Thanks for your consideration,
NeilBrown

--------------

From: NeilBrown <neilb@suse.de>

As not all files have an associated open_context (e.g. device special
files), it is safest to test for the existence of the open context
before de-referencing it.

Signed-off-by: NeilBrown <neilb@suse.de>


diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 78a5922..63bf8f0 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -372,8 +372,12 @@ static inline struct nfs_open_context *nfs_file_open_context(struct file *filp)
 
 static inline struct rpc_cred *nfs_file_cred(struct file *file)
 {
-	if (file != NULL)
-		return nfs_file_open_context(file)->cred;
+	if (file != NULL) {
+		struct nfs_open_context *ctx =
+			nfs_file_open_context(file);
+		if (ctx)
+			return ctx->cred;
+	}
 	return NULL;
 }
 
