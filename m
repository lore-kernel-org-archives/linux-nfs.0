Return-Path: <SRS0=Ohau=NM=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D9241C0044C
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:51:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 6ACD12082E
	for <linux-nfs@archiver.kernel.org>; Thu,  1 Nov 2018 17:51:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=wavesemi.onmicrosoft.com header.i=@wavesemi.onmicrosoft.com header.b="TklUJDqZ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6ACD12082E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mips.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727498AbeKBCzk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 22:55:40 -0400
Received: from mail-eopbgr690098.outbound.protection.outlook.com ([40.107.69.98]:34720
        "EHLO NAM04-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725843AbeKBCzj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Nov 2018 22:55:39 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=wavesemi.onmicrosoft.com; s=selector1-wavecomp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=daenfvtCVCCBJo0nkXAuA8knt8OFAmq942ZVfLm4gxo=;
 b=TklUJDqZtCVCXjJB89M0sPfWa8Lfl+OWUGtSVQ3JNeIKlXzI+5fOjU9sfAHFe226gntrfkCa+RRuM8yup0ZcDPkyHO2HvIh9keGqR9Yxi588xA3ilR7x0a+F1FjbvGX+P1gwzCMcjnI7w2qBMDdlgFU/xcSGcoBkxowaU3ywAis=
Received: from MWHSPR00MB117.namprd22.prod.outlook.com (10.175.52.23) by
 MWHPR2201MB1551.namprd22.prod.outlook.com (10.174.170.164) with Microsoft
 SMTP Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.26; Thu, 1 Nov 2018 17:51:34 +0000
Received: from MWHSPR00MB117.namprd22.prod.outlook.com
 ([fe80::b95a:a3f9:be06:b045]) by MWHSPR00MB117.namprd22.prod.outlook.com
 ([fe80::b95a:a3f9:be06:b045%2]) with mapi id 15.20.1294.024; Thu, 1 Nov 2018
 17:51:34 +0000
From:   Paul Burton <paul.burton@mips.com>
To:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
CC:     "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Paul Burton <pburton@wavecomp.com>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: [PATCH] SUNRPC: Use atomic(64)_t for seq_send(64)
Thread-Topic: [PATCH] SUNRPC: Use atomic(64)_t for seq_send(64)
Thread-Index: AQHUcguHOzj2qsuXb0ebsE4dYl+dSQ==
Date:   Thu, 1 Nov 2018 17:51:34 +0000
Message-ID: <20181101175109.8621-1-paul.burton@mips.com>
References: <20181101145926.GE3178@hirez.programming.kicks-ass.net>
In-Reply-To: <20181101145926.GE3178@hirez.programming.kicks-ass.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR1701CA0020.namprd17.prod.outlook.com
 (2603:10b6:301:14::30) To MWHSPR00MB117.namprd22.prod.outlook.com
 (2603:10b6:300:10c::23)
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pburton@wavecomp.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [4.16.204.77]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;MWHPR2201MB1551;6:+ZM2RPJkzw5eC1f089QQqvNPd8CCsAInB/87TjdKqYzlyDyjUcB5i6OP3eepUpSNhZ+HQpyPNSPXm1RDOfqZb9EQS3usMDqO32k3SlWTxCDZ2HU4UCTNAwN3TZgMlz+68iFbMT6mqDacqUHRrO7ElET2Sj4CRR1R46aw5Kacyx9VOCITMFmTrHwwoI7c6FhZiEMLvgUGQDM6q/o8EUi9pWuT51vDA2IT0v2jsiICKoxgA5kRwUTXiFNivF7qZluyi5TjryS0rBe4vBKvsW8LO7EfwOjL2W9lcLAhxgDbOXUnauA/TxeNlHiT8RbGh2eiBvCm/I/jneDJt5z0GEg3AzakWwiYdvISE/5YhcTazE/jOPJzhe1bBl5Mu5DWAP9zd2shRg6cVWfiS06h+KBsHfpKiqZpqbPXUm0ypshQwyUaCtUZ5ye59SviS38GXPTV9HoC12g6q8KeP1pNn+92nw==;5:2iZDA1DAAUxxyv4/sBnKH385Rloh+lmNuHRjlbZK7+idthDR80EUgEodA9yuDru5nYs6LB4A+gWqKtGvZhtE6KGrqCm/ZsvN4c1SfdTMqxaFvmKbxvdv66IRzv6ifOW5TOf7mKWnn+jswjVZ0bDeUc5alLO2Xz9JKtu0HCciQXA=;7:ElBGO3vzdguxw00+egXHZaOZN+UqOer6K3VjT5HQDez1tijlwiRHP3UjLvB1LjHAtDPR/g5M884izcl4xWlHuBLyjvqyBu8K11XUyY6qNJoAK0/KuUnIQvr/LRZMl2yCFwVqjKKPJPVVyAf5Vh6Z2g==
x-ms-office365-filtering-correlation-id: 6974f48d-5bfe-4fb2-a610-08d64022a996
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(7021145)(8989299)(4534185)(7022145)(4603075)(4627221)(201702281549075)(8990200)(7048125)(7024125)(7027125)(7023125)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:MWHPR2201MB1551;
x-ms-traffictypediagnostic: MWHPR2201MB1551:
x-microsoft-antispam-prvs: <MWHPR2201MB15514D102A9757BE42A311A9C1CE0@MWHPR2201MB1551.namprd22.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:(788757137089)(9452136761055);
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(8121501046)(5005006)(93006095)(10201501046)(3002001)(3231382)(944501410)(52105095)(148016)(149066)(150057)(6041310)(20161123558120)(20161123564045)(20161123560045)(20161123562045)(2016111802025)(6043046)(201708071742011)(7699051)(76991095);SRVR:MWHPR2201MB1551;BCL:0;PCL:0;RULEID:;SRVR:MWHPR2201MB1551;
x-forefront-prvs: 0843C17679
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(396003)(376002)(366004)(39840400004)(136003)(189003)(199004)(81156014)(81166006)(42882007)(8676002)(36756003)(105586002)(71190400001)(71200400001)(53936002)(97736004)(14454004)(305945005)(3846002)(76176011)(52116002)(7736002)(6512007)(11346002)(4326008)(256004)(14444005)(44832011)(486006)(476003)(8936002)(2616005)(6436002)(106356001)(446003)(2501003)(110136005)(25786009)(54906003)(186003)(2900100001)(5250100002)(508600001)(26005)(316002)(2906002)(1857600001)(102836004)(386003)(6506007)(6486002)(6116002)(66066001)(99286004)(1076002)(5660300001)(68736007)(21314003);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR2201MB1551;H:MWHSPR00MB117.namprd22.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: wavecomp.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: 7Y+MuizfTsDD6rjvtlVopUk4S2J0ow//HY+zg/tX6ddPZfP2Hk6t3rIPJ21U+x14d3fpriCy5x8Wr9KXIfHGE6gLh8wn5kAnYjMLCcwj/yAv8QJWAvVdfwnnUcEEeEiNzqNveilpBgLe0gbyKERqxhgPYpx+3SfcCGKfx70pMMJgK71NlmwhcK8GyEeDpaS1NWUZv7g1I+4nFTUH2ri2toO7O+s3Q6eLrGaRtOANMgdP9x4m1fkOenreMZFkP4AsQI9K3HIPVKNr087938oYFJIANoxGATVqjoVWliMsPgEJP1K9IwQP25RypF5S3PAT/PFbwmbkrQ28F6hIRWwEi8XzS4oIjew0BvLO7sao/cs=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: mips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: 6974f48d-5bfe-4fb2-a610-08d64022a996
X-MS-Exchange-CrossTenant-originalarrivaltime: 01 Nov 2018 17:51:34.6439
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 463607d3-1db3-40a0-8a29-970c56230104
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR2201MB1551
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

The seq_send & seq_send64 fields in struct krb5_ctx are used as
atomically incrementing counters. This is implemented using cmpxchg() &
cmpxchg64() to implement what amount to custom versions of
atomic_fetch_inc() & atomic64_fetch_inc().

Besides the duplication, using cmpxchg64() has another major drawback in
that some 32 bit architectures don't provide it. As such commit
571ed1fd2390 ("SUNRPC: Replace krb5_seq_lock with a lockless scheme")
resulted in build failures for some architectures.

Change seq_send to be an atomic_t and seq_send64 to be an atomic64_t,
then use atomic(64)_* functions to manipulate the values. The atomic64_t
type & associated functions are provided even on architectures which
lack real 64 bit atomic memory access via CONFIG_GENERIC_ATOMIC64 which
uses spinlocks to serialize access. This fixes the build failures for
architectures lacking cmpxchg64().

A potential alternative that was raised would be to provide cmpxchg64()
on the 32 bit architectures that currently lack it, using spinlocks.
However this would provide a version of cmpxchg64() with semantics a
little different to the implementations on architectures with real 64
bit atomics - the spinlock-based implementation would only work if all
access to the memory used with cmpxchg64() is *always* performed using
cmpxchg64(). That is not currently a requirement for users of
cmpxchg64(), and making it one seems questionable. As such avoiding
cmpxchg64() outside of architecture-specific code seems best,
particularly in cases where atomic64_t seems like a better fit anyway.

The CONFIG_GENERIC_ATOMIC64 implementation of atomic64_* functions will
use spinlocks & so faces the same issue, but with the key difference
that the memory backing an atomic64_t ought to always be accessed via
the atomic64_* functions anyway making the issue moot.

Signed-off-by: Paul Burton <paul.burton@mips.com>
Fixes: 571ed1fd2390 ("SUNRPC: Replace krb5_seq_lock with a lockless scheme"=
)
Cc: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@kernel.org>
Cc: David S. Miller <davem@davemloft.net>
Cc: linux-nfs@vger.kernel.org
Cc: netdev@vger.kernel.org
---
 include/linux/sunrpc/gss_krb5.h     |  7 ++-----
 net/sunrpc/auth_gss/gss_krb5_mech.c | 16 ++++++++++------
 net/sunrpc/auth_gss/gss_krb5_seal.c | 28 ++--------------------------
 net/sunrpc/auth_gss/gss_krb5_wrap.c |  4 ++--
 4 files changed, 16 insertions(+), 39 deletions(-)

diff --git a/include/linux/sunrpc/gss_krb5.h b/include/linux/sunrpc/gss_krb=
5.h
index 131424cefc6a..02c0412e368c 100644
--- a/include/linux/sunrpc/gss_krb5.h
+++ b/include/linux/sunrpc/gss_krb5.h
@@ -107,8 +107,8 @@ struct krb5_ctx {
 	u8			Ksess[GSS_KRB5_MAX_KEYLEN]; /* session key */
 	u8			cksum[GSS_KRB5_MAX_KEYLEN];
 	s32			endtime;
-	u32			seq_send;
-	u64			seq_send64;
+	atomic_t		seq_send;
+	atomic64_t		seq_send64;
 	struct xdr_netobj	mech_used;
 	u8			initiator_sign[GSS_KRB5_MAX_KEYLEN];
 	u8			acceptor_sign[GSS_KRB5_MAX_KEYLEN];
@@ -118,9 +118,6 @@ struct krb5_ctx {
 	u8			acceptor_integ[GSS_KRB5_MAX_KEYLEN];
 };
=20
-extern u32 gss_seq_send_fetch_and_inc(struct krb5_ctx *ctx);
-extern u64 gss_seq_send64_fetch_and_inc(struct krb5_ctx *ctx);
-
 /* The length of the Kerberos GSS token header */
 #define GSS_KRB5_TOK_HDR_LEN	(16)
=20
diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c b/net/sunrpc/auth_gss/gss_=
krb5_mech.c
index 7f0424dfa8f6..eab71fc7af3e 100644
--- a/net/sunrpc/auth_gss/gss_krb5_mech.c
+++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
@@ -274,6 +274,7 @@ get_key(const void *p, const void *end,
 static int
 gss_import_v1_context(const void *p, const void *end, struct krb5_ctx *ctx=
)
 {
+	u32 seq_send;
 	int tmp;
=20
 	p =3D simple_get_bytes(p, end, &ctx->initiate, sizeof(ctx->initiate));
@@ -315,9 +316,10 @@ gss_import_v1_context(const void *p, const void *end, =
struct krb5_ctx *ctx)
 	p =3D simple_get_bytes(p, end, &ctx->endtime, sizeof(ctx->endtime));
 	if (IS_ERR(p))
 		goto out_err;
-	p =3D simple_get_bytes(p, end, &ctx->seq_send, sizeof(ctx->seq_send));
+	p =3D simple_get_bytes(p, end, &seq_send, sizeof(seq_send));
 	if (IS_ERR(p))
 		goto out_err;
+	atomic_set(&ctx->seq_send, seq_send);
 	p =3D simple_get_netobj(p, end, &ctx->mech_used);
 	if (IS_ERR(p))
 		goto out_err;
@@ -607,6 +609,7 @@ static int
 gss_import_v2_context(const void *p, const void *end, struct krb5_ctx *ctx=
,
 		gfp_t gfp_mask)
 {
+	u64 seq_send64;
 	int keylen;
=20
 	p =3D simple_get_bytes(p, end, &ctx->flags, sizeof(ctx->flags));
@@ -617,14 +620,15 @@ gss_import_v2_context(const void *p, const void *end,=
 struct krb5_ctx *ctx,
 	p =3D simple_get_bytes(p, end, &ctx->endtime, sizeof(ctx->endtime));
 	if (IS_ERR(p))
 		goto out_err;
-	p =3D simple_get_bytes(p, end, &ctx->seq_send64, sizeof(ctx->seq_send64))=
;
+	p =3D simple_get_bytes(p, end, &seq_send64, sizeof(seq_send64));
 	if (IS_ERR(p))
 		goto out_err;
+	atomic64_set(&ctx->seq_send64, seq_send64);
 	/* set seq_send for use by "older" enctypes */
-	ctx->seq_send =3D ctx->seq_send64;
-	if (ctx->seq_send64 !=3D ctx->seq_send) {
-		dprintk("%s: seq_send64 %lx, seq_send %x overflow?\n", __func__,
-			(unsigned long)ctx->seq_send64, ctx->seq_send);
+	atomic_set(&ctx->seq_send, seq_send64);
+	if (seq_send64 !=3D atomic_read(&ctx->seq_send)) {
+		dprintk("%s: seq_send64 %llx, seq_send %x overflow?\n", __func__,
+			seq_send64, atomic_read(&ctx->seq_send));
 		p =3D ERR_PTR(-EINVAL);
 		goto out_err;
 	}
diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c b/net/sunrpc/auth_gss/gss_=
krb5_seal.c
index b4adeb06660b..48fe4a591b54 100644
--- a/net/sunrpc/auth_gss/gss_krb5_seal.c
+++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
@@ -123,30 +123,6 @@ setup_token_v2(struct krb5_ctx *ctx, struct xdr_netobj=
 *token)
 	return krb5_hdr;
 }
=20
-u32
-gss_seq_send_fetch_and_inc(struct krb5_ctx *ctx)
-{
-	u32 old, seq_send =3D READ_ONCE(ctx->seq_send);
-
-	do {
-		old =3D seq_send;
-		seq_send =3D cmpxchg(&ctx->seq_send, old, old + 1);
-	} while (old !=3D seq_send);
-	return seq_send;
-}
-
-u64
-gss_seq_send64_fetch_and_inc(struct krb5_ctx *ctx)
-{
-	u64 old, seq_send =3D READ_ONCE(ctx->seq_send);
-
-	do {
-		old =3D seq_send;
-		seq_send =3D cmpxchg64(&ctx->seq_send64, old, old + 1);
-	} while (old !=3D seq_send);
-	return seq_send;
-}
-
 static u32
 gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
 		struct xdr_netobj *token)
@@ -177,7 +153,7 @@ gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *te=
xt,
=20
 	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data, md5cksum.len);
=20
-	seq_send =3D gss_seq_send_fetch_and_inc(ctx);
+	seq_send =3D atomic_fetch_inc(&ctx->seq_send);
=20
 	if (krb5_make_seq_num(ctx, ctx->seq, ctx->initiate ? 0 : 0xff,
 			      seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8))
@@ -205,7 +181,7 @@ gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *te=
xt,
=20
 	/* Set up the sequence number. Now 64-bits in clear
 	 * text and w/o direction indicator */
-	seq_send_be64 =3D cpu_to_be64(gss_seq_send64_fetch_and_inc(ctx));
+	seq_send_be64 =3D cpu_to_be64(atomic64_fetch_inc(&ctx->seq_send64));
 	memcpy(krb5_hdr + 8, (char *) &seq_send_be64, 8);
=20
 	if (ctx->initiate) {
diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c b/net/sunrpc/auth_gss/gss_=
krb5_wrap.c
index 962fa84e6db1..5cdde6cb703a 100644
--- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
+++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
@@ -228,7 +228,7 @@ gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
=20
 	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data, md5cksum.len);
=20
-	seq_send =3D gss_seq_send_fetch_and_inc(kctx);
+	seq_send =3D atomic_fetch_inc(&kctx->seq_send);
=20
 	/* XXX would probably be more efficient to compute checksum
 	 * and encrypt at the same time: */
@@ -475,7 +475,7 @@ gss_wrap_kerberos_v2(struct krb5_ctx *kctx, u32 offset,
 	*be16ptr++ =3D 0;
=20
 	be64ptr =3D (__be64 *)be16ptr;
-	*be64ptr =3D cpu_to_be64(gss_seq_send64_fetch_and_inc(kctx));
+	*be64ptr =3D cpu_to_be64(atomic64_fetch_inc(&kctx->seq_send64));
=20
 	err =3D (*kctx->gk5e->encrypt_v2)(kctx, offset, buf, pages);
 	if (err)
--=20
2.19.1

