Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 28E23C43334
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Jul 2022 20:19:59 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S236531AbiGVUT5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Jul 2022 16:19:57 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:46554 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S234603AbiGVUT4 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2022 16:19:56 -0400
Received: from ams.source.kernel.org (ams.source.kernel.org [IPv6:2604:1380:4601:e00::1])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 30DBAAF70E
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2022 13:19:56 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by ams.source.kernel.org (Postfix) with ESMTPS id DF755B82A1E
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2022 20:19:54 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9D03FC341C6
        for <linux-nfs@vger.kernel.org>; Fri, 22 Jul 2022 20:19:53 +0000 (UTC)
Subject: [PATCH v1 09/11] NFSD: Remove kmalloc from nfsd4_do_async_copy()
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Date:   Fri, 22 Jul 2022 16:19:52 -0400
Message-ID: <165852119268.11403.4801478667056229494.stgit@manet.1015granger.net>
In-Reply-To: <165852076926.11403.44005570813790008.stgit@manet.1015granger.net>
References: <165852076926.11403.44005570813790008.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Instead of manufacturing a phony struct nfsd_file, pass the
struct file returned by nfs42_ssc_open() directly to
nfsd4_do_copy().

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4proc.c |   28 ++++++++++++++--------------
 1 file changed, 14 insertions(+), 14 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 347a86a6730e..0365a5575236 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1763,29 +1763,31 @@ static void cleanup_async_copy(struct nfsd4_copy *copy)
 	nfs4_put_copy(copy);
 }
 
+/**
+ * nfsd4_do_async_copy - kthread function for background server-side COPY
+ * @data: arguments for COPY operation
+ *
+ * Return values:
+ *   %0: Copy operation is done.
+ */
 static int nfsd4_do_async_copy(void *data)
 {
 	struct nfsd4_copy *copy = (struct nfsd4_copy *)data;
 	struct nfsd4_copy *cb_copy;
 
 	if (nfsd4_ssc_is_inter(copy)) {
-		copy->nf_src = kzalloc(sizeof(struct nfsd_file), GFP_KERNEL);
-		if (!copy->nf_src) {
-			copy->nfserr = nfserr_serverfault;
-			nfsd4_interssc_disconnect(copy->ss_mnt);
-			goto do_callback;
-		}
-		copy->nf_src->nf_file = nfs42_ssc_open(copy->ss_mnt, &copy->c_fh,
-					      &copy->stateid);
-		if (IS_ERR(copy->nf_src->nf_file)) {
+		struct file *filp;
+
+		filp = nfs42_ssc_open(copy->ss_mnt, &copy->c_fh,
+				      &copy->stateid);
+		if (IS_ERR(filp)) {
 			copy->nfserr = nfserr_offload_denied;
 			nfsd4_interssc_disconnect(copy->ss_mnt);
 			goto do_callback;
 		}
-		copy->nfserr = nfsd4_do_copy(copy, copy->nf_src->nf_file,
+		copy->nfserr = nfsd4_do_copy(copy, filp,
 					     copy->nf_dst->nf_file, false);
-		nfsd4_cleanup_inter_ssc(copy->ss_mnt, copy->nf_src->nf_file,
-					copy->nf_dst);
+		nfsd4_cleanup_inter_ssc(copy->ss_mnt, filp, copy->nf_dst);
 	} else {
 		copy->nfserr = nfsd4_do_copy(copy, copy->nf_src->nf_file,
 					     copy->nf_dst->nf_file, false);
@@ -1807,8 +1809,6 @@ static int nfsd4_do_async_copy(void *data)
 			      &copy->fh, copy->cp_count, copy->nfserr);
 	nfsd4_run_cb(&cb_copy->cp_cb);
 out:
-	if (nfsd4_ssc_is_inter(copy))
-		kfree(copy->nf_src);
 	cleanup_async_copy(copy);
 	return 0;
 }


