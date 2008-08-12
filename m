From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 6/7] nfsd: properly xdr-decode NFS4_OPEN_CLAIM_DELEGATE_CUR stateid
Date: Tue, 12 Aug 2008 20:45:51 +0300
Message-ID: <1218563151-25450-1-git-send-email-bhalevy@panasas.com>
References: <48A1CB0C.4090906@panasas.com>
Cc: NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chucklever@gmail.com>,
	Benny Halevy <bhalevy@panasas.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:48668 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751016AbYHLRqJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Aug 2008 13:46:09 -0400
In-Reply-To: <48A1CB0C.4090906@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4xdr.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index e102247..47ac498 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -679,7 +679,9 @@ nfsd4_decode_open(struct nfsd4_compoundargs *argp, struct nfsd4_open *open)
 		break;
 	case NFS4_OPEN_CLAIM_DELEGATE_CUR:
 		READ_BUF(sizeof(stateid_t) + 4);
-		COPYMEM(&open->op_delegate_stateid, sizeof(stateid_t));
+		READ32(open->op_delegate_stateid.si_generation);
+		COPYMEM(&open->op_delegate_stateid.si_opaque,
+			sizeof(stateid_opaque_t));
 		READ32(open->op_fname.len);
 		READ_BUF(open->op_fname.len);
 		SAVEMEM(open->op_fname.data, open->op_fname.len);
-- 
1.5.6.5

