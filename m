From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 2/2] nfsd: dynamically skip encoded fattr bitmap in _nfsd4_verify
Date: Sat, 28 Mar 2009 21:33:59 +0300
Message-ID: <1238265239-17255-1-git-send-email-bhalevy@panasas.com>
References: <49CE6D27.8020601@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:16227 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753291AbZC1Seu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 14:34:50 -0400
In-Reply-To: <49CE6D27.8020601@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

_nfsd4_verify currently skips 3 words from the encoded buffer begining.
With support for 3-word attr bitmaps in nfsd41, nfsd4_encode_fattr
may encode 1, 2, or 3 words, and not always 2 as it used to be, hence
we need to find out where to skip using the encoded bitmap length.

Note: This patch may be applied over pre-nfsd41 nfsd.
move this patch in front of "nfsd41: support for 3-word long attribute bitmask"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4proc.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 20583ab..a393d38 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -801,7 +801,8 @@ _nfsd4_verify(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
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

