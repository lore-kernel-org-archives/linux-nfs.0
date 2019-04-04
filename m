Return-Path: <SRS0=4rwz=SG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CB4A0C10F0C
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 06:57:45 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A1D3520882
	for <linux-nfs@archiver.kernel.org>; Thu,  4 Apr 2019 06:57:45 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727112AbfDDG5p (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 4 Apr 2019 02:57:45 -0400
Received: from mx1.redhat.com ([209.132.183.28]:59364 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726930AbfDDG5o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 4 Apr 2019 02:57:44 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id C8A2BE3DEC;
        Thu,  4 Apr 2019 06:57:44 +0000 (UTC)
Received: from localhost (dhcp-12-130.nay.redhat.com [10.66.12.130])
        by smtp.corp.redhat.com (Postfix) with ESMTP id DDCCB5C88F;
        Thu,  4 Apr 2019 06:57:43 +0000 (UTC)
From:   Murphy Zhou <jencce.kernel@gmail.com>
To:     linux-nfs@vger.kernel.org, neilb@suse.com
Cc:     bfields@fieldses.org, jlayton@kernel.org,
        Murphy Zhou <jencce.kernel@gmail.com>
Subject: [PATCH v2] nfsd/nfsd3_proc_readdir: fix buffer count and page pointers
Date:   Thu,  4 Apr 2019 14:57:11 +0800
Message-Id: <20190404065711.19763-1-jencce.kernel@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Thu, 04 Apr 2019 06:57:44 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

After this commit
  f875a79 nfsd: allow nfsv3 readdir request to be larger.
nfsv3 readdir request size can be larger than PAGE_SIZE. So if the
directory been read is large enough, we can use multiple pages
in rq_respages. Update buffer count and page pointers like we do
in readdirplus to make this happen.

Now listing a directory within 3000 files will panic because we
are counting in a wrong way and would write on random page.

Fixes: f875a79 "nfsd: allow nfsv3 readdir request to be larger"
Signed-off-by: Murphy Zhou <jencce.kernel@gmail.com>
---

v2:
  fix nfs3svc_decode_readdirargs to set page pointers like decode_readdirplusargs
  do not test pointers in encode_entry as we've fixed them when decoding

 fs/nfsd/nfs3proc.c | 17 +++++++++++++++--
 fs/nfsd/nfs3xdr.c  | 11 +++++++++--
 2 files changed, 24 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 8f933e8..9bc32af 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -442,7 +442,9 @@
 	struct nfsd3_readdirargs *argp = rqstp->rq_argp;
 	struct nfsd3_readdirres  *resp = rqstp->rq_resp;
 	__be32		nfserr;
-	int		count;
+	int		count = 0;
+	struct page	**p;
+	caddr_t		page_addr = NULL;
 
 	dprintk("nfsd: READDIR(3)  %s %d bytes at %d\n",
 				SVCFH_fmt(&argp->fh),
@@ -462,7 +464,18 @@
 	nfserr = nfsd_readdir(rqstp, &resp->fh, (loff_t*) &argp->cookie, 
 					&resp->common, nfs3svc_encode_entry);
 	memcpy(resp->verf, argp->verf, 8);
-	resp->count = resp->buffer - argp->buffer;
+	count = 0;
+	for (p = rqstp->rq_respages + 1; p < rqstp->rq_next_page; p++) {
+		page_addr = page_address(*p);
+
+		if (((caddr_t)resp->buffer >= page_addr) &&
+		    ((caddr_t)resp->buffer < page_addr + PAGE_SIZE)) {
+			count += (caddr_t)resp->buffer - page_addr;
+			break;
+		}
+		count += PAGE_SIZE;
+	}
+	resp->count = count >> 2;
 	if (resp->offset) {
 		loff_t offset = argp->cookie;
 
diff --git a/fs/nfsd/nfs3xdr.c b/fs/nfsd/nfs3xdr.c
index 93fea24..8d78912 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -573,6 +573,7 @@ void fill_post_wcc(struct svc_fh *fhp)
 nfs3svc_decode_readdirargs(struct svc_rqst *rqstp, __be32 *p)
 {
 	struct nfsd3_readdirargs *args = rqstp->rq_argp;
+	int len;
 	u32 max_blocksize = svc_max_payload(rqstp);
 
 	p = decode_fh(p, &args->fh);
@@ -582,8 +583,14 @@ void fill_post_wcc(struct svc_fh *fhp)
 	args->verf   = p; p += 2;
 	args->dircount = ~0;
 	args->count  = ntohl(*p++);
-	args->count  = min_t(u32, args->count, max_blocksize);
-	args->buffer = page_address(*(rqstp->rq_next_page++));
+	len = args->count  = min_t(u32, args->count, max_blocksize);
+
+	while (len > 0) {
+		struct page *p = *(rqstp->rq_next_page++);
+		if (!args->buffer)
+			args->buffer = page_address(p);
+		len -= PAGE_SIZE;
+	}
 
 	return xdr_argsize_check(rqstp, p);
 }
-- 
1.8.3.1
