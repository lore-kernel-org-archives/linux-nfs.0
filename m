From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/3] nfs-utils: initialize fakeseed in prepare_krb5_rfc1964_buffer
Date: Sat,  7 Mar 2009 07:45:26 -0500
Message-ID: <1236429928-4680-2-git-send-email-jlayton@redhat.com>
References: <1236429928-4680-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	chuck.lever@oracle.com
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55529 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754635AbZCGMph (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 7 Mar 2009 07:45:37 -0500
In-Reply-To: <1236429928-4680-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This causes a compiler warning and also means that we're stuffing
the buffer with uninitialized junk from the stack. Other places in
this code initialize "fakeseed" to 0. Do the same here.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 utils/gssd/context_lucid.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/utils/gssd/context_lucid.c b/utils/gssd/context_lucid.c
index af7de58..4a682ae 100644
--- a/utils/gssd/context_lucid.c
+++ b/utils/gssd/context_lucid.c
@@ -70,9 +70,10 @@ static int
 prepare_krb5_rfc1964_buffer(gss_krb5_lucid_context_v1_t *lctx,
 	gss_buffer_desc *buf, int32_t *endtime)
 {
+#define FAKESEED_SIZE 16
 	char *p, *end;
 	static int constant_zero = 0;
-	unsigned char fakeseed[16];
+	unsigned char fakeseed[FAKESEED_SIZE];
 	uint32_t word_send_seq;
 	gss_krb5_lucid_key_t enc_key;
 	int i;
@@ -88,6 +89,7 @@ prepare_krb5_rfc1964_buffer(gss_krb5_lucid_context_v1_t *lctx,
 	 */
 	memset(&enc_key, 0, sizeof(enc_key));
 	memset(&fakeoid, 0, sizeof(fakeoid));
+	memset(fakeseed, 0, FAKESEED_SIZE);
 
 	if (!(buf->value = calloc(1, MAX_CTX_LEN)))
 		goto out_err;
@@ -98,7 +100,7 @@ prepare_krb5_rfc1964_buffer(gss_krb5_lucid_context_v1_t *lctx,
 
 	/* seed_init and seed not used by kernel anyway */
 	if (WRITE_BYTES(&p, end, constant_zero)) goto out_err;
-	if (write_bytes(&p, end, &fakeseed, 16)) goto out_err;
+	if (write_bytes(&p, end, &fakeseed, FAKESEED_SIZE)) goto out_err;
 
 	if (WRITE_BYTES(&p, end, lctx->rfc1964_kd.sign_alg)) goto out_err;
 	if (WRITE_BYTES(&p, end, lctx->rfc1964_kd.seal_alg)) goto out_err;
-- 
1.6.0.6

