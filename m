Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:63336 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758550Ab2CNU6z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 14 Mar 2012 16:58:55 -0400
Received: by wibhj6 with SMTP id hj6so7820557wib.1
        for <linux-nfs@vger.kernel.org>; Wed, 14 Mar 2012 13:58:53 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] pnfsd: verify minlength and range as per RFC5661
Date: Wed, 14 Mar 2012 22:58:49 +0200
Message-Id: <1331758729-4317-1-git-send-email-bhalevy@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implement verification logic for loga_minlength and loga_length
specified in RFC5661, Section 18.43.3.

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4pnfsd.c |   19 +++++++++++++++++++
 1 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4pnfsd.c b/fs/nfsd/nfs4pnfsd.c
index dfb41e6..bd80ef4 100644
--- a/fs/nfsd/nfs4pnfsd.c
+++ b/fs/nfsd/nfs4pnfsd.c
@@ -703,6 +703,25 @@ struct super_block *
 
 	dprintk("NFSD: %s Begin\n", __func__);
 
+	/* verify minlength and range as per RFC5661:
+	 *  o  If loga_length is less than loga_minlength,
+	 *     the metadata server MUST return NFS4ERR_INVAL.
+	 *  o  If the sum of loga_offset and loga_minlength exceeds
+	 *     NFS4_UINT64_MAX, and loga_minlength is not
+	 *     NFS4_UINT64_MAX, the error NFS4ERR_INVAL MUST result.
+	 *  o  If the sum of loga_offset and loga_length exceeds
+	 *     NFS4_UINT64_MAX, and loga_length is not NFS4_UINT64_MAX,
+	 *     the error NFS4ERR_INVAL MUST result.
+	 */
+	if ((lgp->lg_seg.length < lgp->lg_minlength) ||
+	    (lgp->lg_minlength != NFS4_MAX_UINT64 &&
+	     lgp->lg_minlength > NFS4_MAX_UINT64 - lgp->lg_seg.offset) ||
+	    (lgp->lg_seg.length != NFS4_MAX_UINT64 &&
+	     lgp->lg_seg.length > NFS4_MAX_UINT64 - lgp->lg_seg.offset)) {
+		nfserr = nfserr_inval;
+		goto out;
+	}
+
 	args.lg_sbid = find_create_sbid(sb);
 	if (!args.lg_sbid) {
 		nfserr = nfserr_layouttrylater;
-- 
1.7.6.5

