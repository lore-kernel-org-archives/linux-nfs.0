Return-Path: <SRS0=WZcR=NL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-5.8 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_NEOMUTT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2D9FFECDE44
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 23:32:54 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D563020664
	for <linux-nfs@archiver.kernel.org>; Wed, 31 Oct 2018 23:32:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=wavesemi.onmicrosoft.com header.i=@wavesemi.onmicrosoft.com header.b="qE9jqH+8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D563020664
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=mips.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730631AbeKAIdB (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 1 Nov 2018 04:33:01 -0400
Received: from mail-eopbgr720128.outbound.protection.outlook.com ([40.107.72.128]:8128
        "EHLO NAM05-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1729213AbeKAIdA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 1 Nov 2018 04:33:00 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=wavesemi.onmicrosoft.com; s=selector1-wavecomp-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=lJiJm3uHAqQD/wVDGW+j0+ZnzA04542IufR4GuSF55Q=;
 b=qE9jqH+8D8B/lwU+EPcdCcuI1GpmVYfTI70e7g5bTPqt3AvRhWA6Neh+afiqc8JJ6594tWlMXFK+He9YYSEsWyDgxH64gInJMXQzNg/HguQrcEAjjy9GkBDzkXOxqmhC23aXBll/YApG9TdzvyVX2hngc8m3UBpm11XUdiUteic=
Received: from MWHSPR00MB117.namprd22.prod.outlook.com (10.175.52.23) by
 MWHPR2201MB1023.namprd22.prod.outlook.com (10.174.167.24) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1294.20; Wed, 31 Oct 2018 23:32:36 +0000
Received: from MWHSPR00MB117.namprd22.prod.outlook.com
 ([fe80::b95a:a3f9:be06:b045]) by MWHSPR00MB117.namprd22.prod.outlook.com
 ([fe80::b95a:a3f9:be06:b045%2]) with mapi id 15.20.1294.024; Wed, 31 Oct 2018
 23:32:36 +0000
From:   Paul Burton <paul.burton@mips.com>
To:     Guenter Roeck <linux@roeck-us.net>,
        Trond Myklebust <trond.myklebust@hammerspace.com>
CC:     Ralf Baechle <ralf@linux-mips.org>,
        James Hogan <jhogan@kernel.org>,
        Benjamin Herrenschmidt <benh@kernel.crashing.org>,
        Paul Mackerras <paulus@samba.org>,
        Michael Ellerman <mpe@ellerman.id.au>,
        "linux-mips@linux-mips.org" <linux-mips@linux-mips.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        Arnd Bergmann <arnd@arndb.de>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Subject: Re: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Thread-Topic: [RFC PATCH] lib: Introduce generic __cmpxchg_u64() and use it
 where needed
Thread-Index: AQHUcVNC5jTXGaDPOkOnkxlkE4DPdqU539kAgAAIcYCAABkQgA==
Date:   Wed, 31 Oct 2018 23:32:36 +0000
Message-ID: <20181031233235.qbedw3pinxcuk7me@pburton-laptop>
References: <1541015538-11382-1-git-send-email-linux@roeck-us.net>
 <20181031213240.zhh7dfcm47ucuyfl@pburton-laptop>
 <20181031220253.GA15505@roeck-us.net>
In-Reply-To: <20181031220253.GA15505@roeck-us.net>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR14CA0020.namprd14.prod.outlook.com
 (2603:10b6:300:ae::30) To MWHSPR00MB117.namprd22.prod.outlook.com
 (2603:10b6:300:10c::23)
user-agent: NeoMutt/20180716
authentication-results: spf=none (sender IP is )
 smtp.mailfrom=pburton@wavecomp.com; 
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [4.16.204.77]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;MWHPR2201MB1023;6:Hxl7xhLt9QlYwmabsdO/M+hEbLF5FugVfO7Qx0GHQJhZAQTxP9G0f45YB0jbvw3lYSqbQYYFyqwmQPV/I/JNR5+jD5ccjVdEFk9ggVgrMSzdTceKVwOIvGBWLwslSoh2uw5GkktBe4ZmMf6lKGjg9t8cigXiBgmh1VtntZ4VTJITQryWtNVaVir4eV6TGly7jfXhljOYkYQ40Mv+olPYpiGTmawp9k2s/DUjeiwlXqxukVhhNf8mi1frfnjZGtw27VBb2X7Lx//00ClkNFQCvJZF3a3DGNHH1wPDwTfVSWE62HLxmcjG2e+m3RAuys8ai7I44WsU/Syvsv6jWSaFwBXIMPUGeGsGnzOi2h6pJPSpXpDUU1yUtbWX4l99tGrWjROyGRte6cHr7H8KV3ab2j/rIvfeFRQ/1bgp/++R28iL8sWGoXCtFyzGUXneFbE8ObP1t9VfpEOuaQADs7h8cg==;5:Sg40v/gidZKLYBooAFVAEWINHg6cctyIw0w6C+uypsYK0crTYYmHvl0PZ6HXn3iZKjinjDirReUCQm0PoBqYY/euegRBpqrRadck/sjls/PQowW2rTGIrIy0KGhHoZ08JDIjdbGolW2hZMcdDquKZEgCY77fiVrtSUCqDNpygSQ=;7:AKeX9NS6NeB84bJW6BKrnVAZo1VPW1gWdbQCZnXzDOMHxM5vKI2z6McK/sk5de27iwyQNZWWjyRCCqa3BcFPAnqwBlHf/iKOPvb13NrFz5B/buOEup6Fy35n0k06BgphwMNRkYFbjX+12RUwcrIv/g==
x-ms-office365-filtering-correlation-id: ade3059c-83c1-4a84-e514-08d63f8923b6
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(7020095)(4652040)(7021145)(8989299)(4534185)(7022145)(4603075)(4627221)(201702281549075)(8990200)(7048125)(7024125)(7027125)(7023125)(5600074)(711020)(2017052603328)(7153060)(7193020);SRVR:MWHPR2201MB1023;
x-ms-traffictypediagnostic: MWHPR2201MB1023:
x-microsoft-antispam-prvs: <MWHPR2201MB10239692398A1A75237CD938C1CD0@MWHPR2201MB1023.namprd22.prod.outlook.com>
x-exchange-antispam-report-test: UriScan:;
x-ms-exchange-senderadcheck: 1
x-exchange-antispam-report-cfa-test: BCL:0;PCL:0;RULEID:(6040522)(2401047)(5005006)(8121501046)(3231382)(944501410)(52105095)(93006095)(10201501046)(3002001)(148016)(149066)(150057)(6041310)(2016111802025)(20161123558120)(20161123562045)(20161123564045)(20161123560045)(6043046)(201708071742011)(7699051)(76991095);SRVR:MWHPR2201MB1023;BCL:0;PCL:0;RULEID:;SRVR:MWHPR2201MB1023;
x-forefront-prvs: 084285FC5C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(7916004)(39840400004)(396003)(136003)(366004)(346002)(376002)(199004)(189003)(305945005)(7736002)(106356001)(2900100001)(966005)(105586002)(5250100002)(81166006)(66066001)(7416002)(2906002)(52116002)(68736007)(8936002)(8676002)(33716001)(81156014)(14454004)(97736004)(476003)(99286004)(6506007)(26005)(3846002)(6116002)(76176011)(53936002)(386003)(1076002)(33896004)(102836004)(508600001)(486006)(14444005)(256004)(25786009)(186003)(71200400001)(58126008)(71190400001)(9686003)(110136005)(6436002)(316002)(54906003)(6246003)(6306002)(6486002)(5660300001)(6512007)(229853002)(11346002)(446003)(4326008)(42882007)(44832011)(41533002)(21314003);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR2201MB1023;H:MWHSPR00MB117.namprd22.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: wavecomp.com does not designate
 permitted sender hosts)
x-microsoft-antispam-message-info: X6/InWQ6A1SLnI3yyi8N2WfTbW/01w4DsGGYv+8/mNaqt2ciWPDkYJ3ERtp4LzWglzV4XpPeOcf0HRiuHiyQHmJXG6ApRUNyZVhwCAy85afWa9szgHfsNgF8oiV+HQn/BDqilsKZO6EXZnwfrCwO26XdgYSk6+cOF/WmiUd6X8xZF2CvW386p7JBTAxDSSGaOplQz9qaL0YfckAYbkt2hhdgQGzAIOcg4u8qDabaB8cTk5H+6w0OkGmOOSFPftk9txcz+EeL/OL0F72ZgxoJu5a+4HuxPYzHyp6VZdKrrc4513I7zYMSPCszaQgT2Ve3tsPxEujjVDF4dM+xLtJ8c4GjftXYSvWDcIi6ulPupKE=
spamdiagnosticoutput: 1:99
spamdiagnosticmetadata: NSPM
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F0C2A39EF044014A971527A218259D45@namprd22.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-OriginatorOrg: mips.com
X-MS-Exchange-CrossTenant-Network-Message-Id: ade3059c-83c1-4a84-e514-08d63f8923b6
X-MS-Exchange-CrossTenant-originalarrivaltime: 31 Oct 2018 23:32:36.7586
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 463607d3-1db3-40a0-8a29-970c56230104
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR2201MB1023
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

(Copying SunRPC & net maintainers.)

Hi Guenter,

On Wed, Oct 31, 2018 at 03:02:53PM -0700, Guenter Roeck wrote:
> The alternatives I can see are
> - Do not use cmpxchg64() outside architecture code (ie drop its use from
>   the offending driver, and keep doing the same whenever the problem come=
s
>   up again).
> or
> - Introduce something like ARCH_HAS_CMPXCHG64 and use it to determine
>   if cmpxchg64 is supported or not.
>=20
> Any preference ?

My preference would be option 1 - avoiding cmpxchg64() where possible in
generic code. I wouldn't be opposed to the Kconfig option if there are
cases where cmpxchg64() can really help performance though.

The last time I'm aware of this coming up the affected driver was
modified to avoid cmpxchg64() [1].

In this particular case I have no idea why
net/sunrpc/auth_gss/gss_krb5_seal.c is using cmpxchg64() at all. It's
essentially reinventing atomic64_fetch_inc() which is already provided
everywhere via CONFIG_GENERIC_ATOMIC64 & the spinlock approach. At least
for atomic64_* functions the assumption that all access will be
performed using those same functions seems somewhat reasonable.

So how does the below look? Trond?

Thanks,
    Paul

[1] https://patchwork.ozlabs.org/cover/891284/

---
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
