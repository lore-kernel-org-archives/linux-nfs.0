Return-Path: <SRS0=gHGj=5J=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 54CA4C54FCE
	for <linux-nfs@archiver.kernel.org>; Tue, 24 Mar 2020 23:49:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2266720719
	for <linux-nfs@archiver.kernel.org>; Tue, 24 Mar 2020 23:49:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1585093782;
	bh=ksX41en9zXztZkK7yJUP1w30ssz69SdnHLr2M+BntI0=;
	h=From:To:Subject:Date:In-Reply-To:References:List-ID:From;
	b=jL2MzgwUhtqNSuDbNambRKfvwQS9ubCN07E/bBdK9Qcr9bngJQHFzKO2CbjwYVYqw
	 jKKuOcLpJEAM2cbhKpI3cy7YF3v2VAQomdquZWYMiLEhFPCsMwItyuF8vBMwGJ4IdT
	 bu2/nmyGp1lIp5C8MtJNjP5tQCbo8JKzhc9zS2WI=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727118AbgCXXtl (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 24 Mar 2020 19:49:41 -0400
Received: from mail.kernel.org ([198.145.29.99]:35392 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726956AbgCXXtk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 24 Mar 2020 19:49:40 -0400
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net [68.40.189.247])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 520FD20719
        for <linux-nfs@vger.kernel.org>; Tue, 24 Mar 2020 23:49:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1585093780;
        bh=ksX41en9zXztZkK7yJUP1w30ssz69SdnHLr2M+BntI0=;
        h=From:To:Subject:Date:In-Reply-To:References:From;
        b=nHR5kdL8jDBM7VYzDqNshOvXF4f15UZQ0JEv2mf9SPbss2Vu+2411rYgt210QA+Qy
         2mXzklU2ioEnvzUv2IS/3nuCcEgQLepGffoXVbItpfBYQwsjGgJ2DlV1oVcRwSySja
         H1yujwZf/4hPwDBY6w0lCpz69ts22gMp33hp85G0=
From:   trondmy@kernel.org
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 06/22] pNFS: Support per-layout segment commits in pnfs_generic_recover_commit_reqs()
Date:   Tue, 24 Mar 2020 19:47:12 -0400
Message-Id: <20200324234728.8997-7-trondmy@kernel.org>
X-Mailer: git-send-email 2.25.1
In-Reply-To: <20200324234728.8997-6-trondmy@kernel.org>
References: <20200324234728.8997-1-trondmy@kernel.org>
 <20200324234728.8997-2-trondmy@kernel.org>
 <20200324234728.8997-3-trondmy@kernel.org>
 <20200324234728.8997-4-trondmy@kernel.org>
 <20200324234728.8997-5-trondmy@kernel.org>
 <20200324234728.8997-6-trondmy@kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trond.myklebust@hammerspace.com>

Add support for scanning the full list of per-layout segment commit
arrays to pnfs_generic_recover_commit_reqs().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs_nfs.c | 41 +++++++++++++++++++++++++++++++++--------
 1 file changed, 33 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 81fd85e66fd9..f16bd6d0e830 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -189,22 +189,23 @@ int pnfs_generic_scan_commit_lists(struct nfs_commit_info *cinfo, int max)
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_scan_commit_lists);
 
-/* Pull everything off the committing lists and dump into @dst.  */
-void pnfs_generic_recover_commit_reqs(struct list_head *dst,
-				      struct nfs_commit_info *cinfo)
+static unsigned int
+pnfs_bucket_recover_commit_reqs(struct list_head *dst,
+			        struct pnfs_commit_bucket *buckets,
+				unsigned int nbuckets,
+				struct nfs_commit_info *cinfo)
 {
 	struct pnfs_commit_bucket *b;
 	struct pnfs_layout_segment *freeme;
-	int nwritten;
-	int i;
+	unsigned int nwritten, ret = 0;
+	unsigned int i;
 
-	lockdep_assert_held(&NFS_I(cinfo->inode)->commit_mutex);
 restart:
-	for (i = 0, b = cinfo->ds->buckets; i < cinfo->ds->nbuckets; i++, b++) {
+	for (i = 0, b = buckets; i < nbuckets; i++, b++) {
 		nwritten = nfs_scan_commit_list(&b->written, dst, cinfo, 0);
 		if (!nwritten)
 			continue;
-		cinfo->ds->nwritten -= nwritten;
+		ret += nwritten;
 		if (list_empty(&b->written)) {
 			freeme = b->wlseg;
 			b->wlseg = NULL;
@@ -212,6 +213,30 @@ void pnfs_generic_recover_commit_reqs(struct list_head *dst,
 			goto restart;
 		}
 	}
+	return ret;
+}
+
+/* Pull everything off the committing lists and dump into @dst.  */
+void pnfs_generic_recover_commit_reqs(struct list_head *dst,
+				      struct nfs_commit_info *cinfo)
+{
+	struct pnfs_ds_commit_info *fl_cinfo = cinfo->ds;
+	struct pnfs_commit_array *array;
+	unsigned int nwritten;
+
+	lockdep_assert_held(&NFS_I(cinfo->inode)->commit_mutex);
+	nwritten = pnfs_bucket_recover_commit_reqs(dst,
+						   fl_cinfo->buckets,
+						   fl_cinfo->nbuckets,
+						   cinfo);
+	fl_cinfo->nwritten -= nwritten;
+	list_for_each_entry(array, &fl_cinfo->commits, cinfo_list) {
+		nwritten = pnfs_bucket_recover_commit_reqs(dst,
+							   array->buckets,
+							   array->nbuckets,
+							   cinfo);
+		fl_cinfo->nwritten -= nwritten;
+	}
 }
 EXPORT_SYMBOL_GPL(pnfs_generic_recover_commit_reqs);
 
-- 
2.25.1

