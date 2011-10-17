Return-Path: linux-nfs-owner@vger.kernel.org
Received: from rcsinet15.oracle.com ([148.87.113.117]:63274 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649Ab1JQHlk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Oct 2011 03:41:40 -0400
Date: Mon, 17 Oct 2011 10:41:17 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        kernel-janitors@vger.kernel.org
Subject: [patch] nfsd4: typo logical vs bitwise negate
Message-ID: <20111017074117.GA11912@elgon.mountain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This should be a bitwise negate here.  It silences a Sparse warning:
fs/nfsd/nfs4xdr.c:693:16: warning: dubious: x & !y

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2cab33c..645a0a9 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -690,7 +690,7 @@ static __be32 nfsd4_decode_share_deny(struct nfsd4_compoundargs *argp, u32 *x)
 	READ_BUF(4);
 	READ32(*x);
 	/* Note: unlinke access bits, deny bits may be zero. */
-	if (*x & !NFS4_SHARE_DENY_BOTH)
+	if (*x & ~NFS4_SHARE_DENY_BOTH)
 		return nfserr_bad_xdr;
 	return nfs_ok;
 xdr_error:
