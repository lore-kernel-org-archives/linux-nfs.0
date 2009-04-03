From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v3 31/35] nfsd: dynamically skip encoded fattr bitmap in _nfsd4_verify
Date: Fri,  3 Apr 2009 08:29:08 +0300
Message-ID: <1238736548-18048-1-git-send-email-bhalevy@panasas.com>
References: <49D599EA.6060705@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:24774 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757680AbZDCF3N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 3 Apr 2009 01:29:13 -0400
In-Reply-To: <49D599EA.6060705@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

_nfsd4_verify currently skips 3 words from the encoded buffer begining.
With support for 3-word attr bitmaps in nfsd41, nfsd4_encode_fattr
may encode 1, 2, or 3 words, and not always 2 as it used to be, hence
we need to find out where to skip using the encoded bitmap length.

Note: This patch may be applied over pre-nfsd41 nfsd.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 52bb14d..937853f 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -775,7 +775,8 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (status)
 		goto out_kfree;
 
-	p = buf + 3;
+	/* skip bitmap */
+	p = buf + 1 + ntohl(buf[0]);
 	status = nfserr_not_same;
 	if (ntohl(*p++) != verify->ve_attrlen)
 		goto out_kfree;
-- 
1.6.2.1

