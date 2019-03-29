Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.7 required=3.0 tests=DKIM_ADSP_CUSTOM_MED,
	FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DE5ABC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 14:23:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B6BBC2173C
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 14:23:54 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728652AbfC2OXy (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 10:23:54 -0400
Received: from mx1.redhat.com ([209.132.183.28]:44418 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728630AbfC2OXy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 29 Mar 2019 10:23:54 -0400
Received: from smtp.corp.redhat.com (int-mx08.intmail.prod.int.phx2.redhat.com [10.5.11.23])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6B12230B96EC;
        Fri, 29 Mar 2019 14:23:53 +0000 (UTC)
Received: from localhost (dhcp-12-130.nay.redhat.com [10.66.12.130])
        by smtp.corp.redhat.com (Postfix) with ESMTP id CB1266B807;
        Fri, 29 Mar 2019 14:23:52 +0000 (UTC)
From:   Murphy Zhou <jencce.kernel@gmail.com>
To:     linux-nfs@vger.kernel.org
Cc:     neilb@suse.com, bfields@fieldses.org, jlayton@kernel.org,
        Murphy Zhou <jencce.kernel@gmail.com>
Subject: [PATCH] nfsd/nfsd3_proc_readdir: check before encoding on temporary page
Date:   Fri, 29 Mar 2019 22:23:32 +0800
Message-Id: <20190329142332.12010-1-jencce.kernel@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.23
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.49]); Fri, 29 Mar 2019 14:23:53 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

After this commit
  f875a79 nfsd: allow nfsv3 readdir request to be larger.
nfsv3 readdir request size can be larger than PAGE_SIZE. So if the
request and the directory are large enough, we can run out of pages
in rq_respages. Then the temporary page we are encoding on is a
random page, Oops happen.

Listing a directory with 30000 files in it can trigger the panic.

Fixing this by ensuring the temporary page resides in rq_respages.
And when counting how many bytes left currently from buffer to the
end of the page which buffer is pointing to, aka len1, do not
assume that curr_page_addr is at the beginning of the same page.
Also, update resp->count by going through all pages. Because the
pages may not be sequential, the old way is not safe.

Fixes: f875a79 "nfsd: allow nfsv3 readdir request to be larger"
Signed-off-by: Murphy Zhou <jencce.kernel@gmail.com>
---
 fs/nfsd/nfs3proc.c | 17 +++++++++++++++--
 fs/nfsd/nfs3xdr.c  |  8 +++++---
 2 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs3proc.c b/fs/nfsd/nfs3proc.c
index 8f933e84cec1..9bc32af4e2da 100644
--- a/fs/nfsd/nfs3proc.c
+++ b/fs/nfsd/nfs3proc.c
@@ -442,7 +442,9 @@ nfsd3_proc_readdir(struct svc_rqst *rqstp)
 	struct nfsd3_readdirargs *argp = rqstp->rq_argp;
 	struct nfsd3_readdirres  *resp = rqstp->rq_resp;
 	__be32		nfserr;
-	int		count;
+	int		count = 0;
+	struct page	**p;
+	caddr_t		page_addr = NULL;
 
 	dprintk("nfsd: READDIR(3)  %s %d bytes at %d\n",
 				SVCFH_fmt(&argp->fh),
@@ -462,7 +464,18 @@ nfsd3_proc_readdir(struct svc_rqst *rqstp)
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
index 93fea246f676..1fabf1952bdb 100644
--- a/fs/nfsd/nfs3xdr.c
+++ b/fs/nfsd/nfs3xdr.c
@@ -953,6 +953,7 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 			break;
 	}
 
+
 	if ((caddr_t)(cd->buffer + elen) < (curr_page_addr + PAGE_SIZE)) {
 		/* encode entry in current page */
 
@@ -961,11 +962,12 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 		if (plus)
 			p = encode_entryplus_baggage(cd, p, name, namlen, ino);
 		num_entry_words = p - cd->buffer;
-	} else if (*(page+1) != NULL) {
+	} else if (*(page+1) != NULL && (page+1) < cd->rqstp->rq_next_page) {
 		/* temporarily encode entry into next page, then move back to
 		 * current and next page in rq_respages[] */
 		__be32 *p1, *tmp;
 		int len1, len2;
+		caddr_t	tmp_page_addr = NULL;
 
 		/* grab next page for temporary storage of entry */
 		p1 = tmp = page_address(*(page+1));
@@ -977,7 +979,8 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 
 		/* determine entry word length and lengths to go in pages */
 		num_entry_words = p1 - tmp;
-		len1 = curr_page_addr + PAGE_SIZE - (caddr_t)cd->buffer;
+		tmp_page_addr = (caddr_t)((unsigned long)cd->buffer & PAGE_MASK);
+		len1 = tmp_page_addr + PAGE_SIZE - (caddr_t)cd->buffer;
 		if ((num_entry_words << 2) < len1) {
 			/* the actual number of words in the entry is less
 			 * than elen and can still fit in the current page
@@ -1026,7 +1029,6 @@ encode_entry(struct readdir_cd *ccd, const char *name, int namlen,
 	cd->buffer = p;
 	cd->common.err = nfs_ok;
 	return 0;
-
 }
 
 int
-- 
2.21.0

