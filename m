Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay119.isp.belgacom.be ([195.238.20.146]:48137 "EHLO
	mailrelay119.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754488AbbFPT6H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 16 Jun 2015 15:58:07 -0400
From: Fabian Frederick <fabf@skynet.be>
To: linux-kernel@vger.kernel.org
Cc: Fabian Frederick <fabf@skynet.be>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH 1/1 net-next] sunrpc: use sg_init_one() in krb5_rc4_setup_enc/seq_key()
Date: Tue, 16 Jun 2015 21:57:52 +0200
Message-Id: <1434484672-5877-1-git-send-email-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Don't opencode sg_init_one()

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 net/sunrpc/auth_gss/gss_krb5_crypto.c | 8 ++------
 1 file changed, 2 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c b/net/sunrpc/auth_gss/gss_krb5_crypto.c
index b5408e8..fee3c15 100644
--- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
+++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
@@ -881,9 +881,7 @@ krb5_rc4_setup_seq_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
 	if (err)
 		goto out_err;
 
-	sg_init_table(sg, 1);
-	sg_set_buf(sg, &zeroconstant, 4);
-
+	sg_init_one(sg, &zeroconstant, 4);
 	err = crypto_hash_digest(&desc, sg, 4, Kseq);
 	if (err)
 		goto out_err;
@@ -951,9 +949,7 @@ krb5_rc4_setup_enc_key(struct krb5_ctx *kctx, struct crypto_blkcipher *cipher,
 	if (err)
 		goto out_err;
 
-	sg_init_table(sg, 1);
-	sg_set_buf(sg, zeroconstant, 4);
-
+	sg_init_one(sg, zeroconstant, 4);
 	err = crypto_hash_digest(&desc, sg, 4, Kcrypt);
 	if (err)
 		goto out_err;
-- 
2.4.2

