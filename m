From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [NFS] [PATCH] knfsd: Allow NFSv2/3 WRITE calls to succeed when
	krb5i etc is used.
Date: Fri, 11 Jan 2008 17:06:52 -0500
Message-ID: <1200089212-12204-1-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, Peter Staubach <staubach@redhat.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, stable@kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:39497 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762951AbYAKWcK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Jan 2008 17:32:10 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JDSQ3-00088G-E0
	for linux-nfs@vger.kernel.org; Sat, 12 Jan 2008 09:32:07 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: NeilBrown <neilb@suse.de>

When RPCSEC/GSS and krb5i is used, requests are padded, typically to a multiple
of 8 bytes.  This can make the request look slightly longer than it
really is.

As of

	f34b95689d2ce001c "The NFSv2/NFSv3 server does not handle zero
		length WRITE request correctly",

the xdr decode routines for NFSv2 and NFSv3 reject requests that aren't
the right length, so krb5i (for example) WRITE requests can get lost.

This patch relaxes the appropriate test and enhances the related comment.

Signed-off-by: Neil Brown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: Peter Staubach <staubach@redhat.com>
---
 fs/nfsd/nfs3xdr.c |    5 ++++-
 fs/nfsd/nfsxdr.c  |    5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 3231387..d7647f7 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -389,8 +389,11 @@ nfs3svc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 	 * Round the length of the data which was specified up to
 	 * the next multiple of XDR units and then compare that
 	 * against the length which was actually received.
+	 * Note that when RPCSEC/GSS (for example) is used, the
+	 * data buffer can be padded so dlen might be larger
+	 * than required.  It must never be smaller.
 	 */
-	if (dlen != XDR_QUADLEN(len)*4)
+	if (dlen < XDR_QUADLEN(len)*4)
 		return 0;
 
 	if (args->count > max_blocksize) {
diff --git a/fs/nfsd/nfsxdr.c b/fs/nfsd/nfsxdr.c
index 383d6d2..61ad617 100644
--- a/fs/nfsd/nfsxdr.c
+++ b/fs/nfsd/nfsxdr.c
@@ -314,8 +314,11 @@ nfssvc_decode_writeargs(struct svc_rqst *rqstp, __be32 *p,
 	 * Round the length of the data which was specified up to
 	 * the next multiple of XDR units and then compare that
 	 * against the length which was actually received.
+	 * Note that when RPCSEC/GSS (for example) is used, the
+	 * data buffer can be padded so dlen might be larger
+	 * than required.  It must never be smaller.
 	 */
-	if (dlen != XDR_QUADLEN(len)*4)
+	if (dlen < XDR_QUADLEN(len)*4)
 		return 0;
 
 	rqstp->rq_vec[0].iov_base = (void*)p;
-- 
1.5.4.rc2.60.gb2e62


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

