Return-Path: <SRS0=hAdq=OX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E10CC43387
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 21:17:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 76FC22080F
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Dec 2018 21:17:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="5PhWZwwX"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730757AbeLNVRR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Dec 2018 16:17:17 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:58946 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730734AbeLNVRR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Dec 2018 16:17:17 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBELEE4P051616;
        Fri, 14 Dec 2018 21:16:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=DM6wotLuaFJqLYSF/JSgEgz1EraoDrJIZgb2zUvdMhQ=;
 b=5PhWZwwXBic1EYFWhoKbAnK0imQiztpn0EyTlthEodB3AD4IM5O0+8A8ggpbPhkxuyqb
 aDGVMFEzOHQbF9wBIPM4joe+kAfgUEg6p2N22l/TRXkv67pTqwOApCPY/rJhcjWvfgu6
 Cwzz48Z107RjHrM8jKQiv4hToABHHm7nA0Tt7blMcFII/GzuyJ0I0f2hCUtBtbJgidgo
 LrZiAa4hjZadwMkz9R/BFpY51GDEudWFjf4RbmmGlQrRhHNSpfUUJMgPE6jjdYoAOkjg
 E1WQ2tenKXRiA2j9+M8odFp3u0pA76yxgrk5PjNqh9JQrSeJTMXYnyF5UrlgyR+D/Tva sg== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2120.oracle.com with ESMTP id 2pb7tfbpgt-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 14 Dec 2018 21:16:59 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wBELGuj7014952
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 14 Dec 2018 21:16:57 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBELGtem001426;
        Fri, 14 Dec 2018 21:16:56 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 14 Dec 2018 13:16:55 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v3 16/24] SUNRPC: Remove support for kerberos_v1
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <8E583942-5064-4096-ACFB-FDD4BA052957@oracle.com>
Date:   Fri, 14 Dec 2018 16:16:53 -0500
Cc:     linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Simo Sorce <simo@redhat.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <146883A6-0FF7-4E35-8B65-8CF0F3AF8DF6@oracle.com>
References: <20181210161723.4198.51071.stgit@manet.1015granger.net>
 <20181210163044.4198.33386.stgit@manet.1015granger.net>
 <8E583942-5064-4096-ACFB-FDD4BA052957@oracle.com>
To:     Trond Myklebust <trondmy@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9107 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=2 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812140180
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Following up...

> On Dec 12, 2018, at 4:20 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>=20
> Hi Trond-
>=20
>> On Dec 10, 2018, at 11:30 AM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>> Kerberos v1 allows the selection of encryption types that are known
>> to be insecure and are no longer widely deployed. Also there is no
>> convenient facility for testing v1 or these enctypes, so essentially
>> this code has been untested for some time.
>>=20
>> Note that RFC 6649 deprecates DES and Arcfour_56 in Kerberos, and
>> RFC 8429 (October 2018) deprecates DES3 and Arcfour.
>>=20
>> Support for DES_CBC_RAW, DES_CBC_CRC, DES_CBC_MD4, DES_CBC_MD5,
>> DES3_CBC_RAW, and ARCFOUR_HMAC encryption in the Linux kernel
>> RPCSEC_GSS implementation is removed by this patch.
>=20
> Wondering what kind of impact this will have on folks who have
> the deprecated encryption types in their krb5.keytab or with a
> KDC that might uses DES3 for user principals.
>=20
> Anna suggested putting this change behind a KCONFIG option.

I'm told there are indeed convenient ways to test these old
enctypes using current KDCs, and further that some customers
still insist on using them.

A better approach here would be to investigate testing of these
enctypes to ensure they are still in working order today and
after forthcoming significant changes in this area; and to
introduce a CONFIG option to disable these enctypes.

I will drop this patch from my for-4.21. For v4.22, I will try
to revisit via a narrower change that preserves support.

I plan to post a fresh revision of my for-4.21 next week,
rebased on v4.20-rc7, with fixes for the soft IRQ / DMAR
issues.


>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/linux/sunrpc/gss_krb5.h          |   39 ---
>> include/linux/sunrpc/gss_krb5_enctypes.h |    2=20
>> net/sunrpc/Kconfig                       |    3=20
>> net/sunrpc/auth_gss/Makefile             |    2=20
>> net/sunrpc/auth_gss/gss_krb5_crypto.c    |  423 =
------------------------------
>> net/sunrpc/auth_gss/gss_krb5_keys.c      |   53 ----
>> net/sunrpc/auth_gss/gss_krb5_mech.c      |  278 --------------------
>> net/sunrpc/auth_gss/gss_krb5_seal.c      |   73 -----
>> net/sunrpc/auth_gss/gss_krb5_seqnum.c    |  164 ------------
>> net/sunrpc/auth_gss/gss_krb5_unseal.c    |   80 ------
>> net/sunrpc/auth_gss/gss_krb5_wrap.c      |  254 ------------------
>> 11 files changed, 12 insertions(+), 1359 deletions(-)
>> delete mode 100644 net/sunrpc/auth_gss/gss_krb5_seqnum.c
>>=20
>> diff --git a/include/linux/sunrpc/gss_krb5.h =
b/include/linux/sunrpc/gss_krb5.h
>> index 02c0412..57f4a49 100644
>> --- a/include/linux/sunrpc/gss_krb5.h
>> +++ b/include/linux/sunrpc/gss_krb5.h
>> @@ -105,7 +105,6 @@ struct krb5_ctx {
>> 	struct crypto_sync_skcipher *acceptor_enc_aux;
>> 	struct crypto_sync_skcipher *initiator_enc_aux;
>> 	u8			Ksess[GSS_KRB5_MAX_KEYLEN]; /* session =
key */
>> -	u8			cksum[GSS_KRB5_MAX_KEYLEN];
>> 	s32			endtime;
>> 	atomic_t		seq_send;
>> 	atomic64_t		seq_send64;
>> @@ -235,11 +234,6 @@ enum seal_alg {
>> 	+ GSS_KRB5_MAX_CKSUM_LEN)
>>=20
>> u32
>> -make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
>> -		struct xdr_buf *body, int body_offset, u8 *cksumkey,
>> -		unsigned int usage, struct xdr_netobj *cksumout);
>> -
>> -u32
>> make_checksum_v2(struct krb5_ctx *, char *header, int hdrlen,
>> 		 struct xdr_buf *body, int body_offset, u8 *key,
>> 		 unsigned int usage, struct xdr_netobj *cksum);
>> @@ -268,25 +262,6 @@ u32 gss_verify_mic_kerberos(struct gss_ctx *, =
struct xdr_buf *,
>> 	     void *iv, void *in, void *out, int length);=20
>>=20
>> int
>> -gss_encrypt_xdr_buf(struct crypto_sync_skcipher *tfm, struct xdr_buf =
*outbuf,
>> -		    int offset, struct page **pages);
>> -
>> -int
>> -gss_decrypt_xdr_buf(struct crypto_sync_skcipher *tfm, struct xdr_buf =
*inbuf,
>> -		    int offset);
>> -
>> -s32
>> -krb5_make_seq_num(struct krb5_ctx *kctx,
>> -		struct crypto_sync_skcipher *key,
>> -		int direction,
>> -		u32 seqnum, unsigned char *cksum, unsigned char *buf);
>> -
>> -s32
>> -krb5_get_seq_num(struct krb5_ctx *kctx,
>> -	       unsigned char *cksum,
>> -	       unsigned char *buf, int *direction, u32 *seqnum);
>> -
>> -int
>> xdr_extend_head(struct xdr_buf *buf, unsigned int base, unsigned int =
shiftlen);
>>=20
>> u32
>> @@ -297,11 +272,6 @@ u32 gss_verify_mic_kerberos(struct gss_ctx *, =
struct xdr_buf *,
>> 		gfp_t gfp_mask);
>>=20
>> u32
>> -gss_krb5_des3_make_key(const struct gss_krb5_enctype *gk5e,
>> -		       struct xdr_netobj *randombits,
>> -		       struct xdr_netobj *key);
>> -
>> -u32
>> gss_krb5_aes_make_key(const struct gss_krb5_enctype *gk5e,
>> 		      struct xdr_netobj *randombits,
>> 		      struct xdr_netobj *key);
>> @@ -316,14 +286,5 @@ u32 gss_verify_mic_kerberos(struct gss_ctx *, =
struct xdr_buf *,
>> 		     struct xdr_buf *buf, u32 *plainoffset,
>> 		     u32 *plainlen);
>>=20
>> -int
>> -krb5_rc4_setup_seq_key(struct krb5_ctx *kctx,
>> -		       struct crypto_sync_skcipher *cipher,
>> -		       unsigned char *cksum);
>> -
>> -int
>> -krb5_rc4_setup_enc_key(struct krb5_ctx *kctx,
>> -		       struct crypto_sync_skcipher *cipher,
>> -		       s32 seqnum);
>> void
>> gss_krb5_make_confounder(char *p, u32 conflen);
>> diff --git a/include/linux/sunrpc/gss_krb5_enctypes.h =
b/include/linux/sunrpc/gss_krb5_enctypes.h
>> index ec6234e..7a8abcf 100644
>> --- a/include/linux/sunrpc/gss_krb5_enctypes.h
>> +++ b/include/linux/sunrpc/gss_krb5_enctypes.h
>> @@ -1,4 +1,4 @@
>> /*
>> * Dumb way to share this static piece of information with nfsd
>> */
>> -#define KRB5_SUPPORTED_ENCTYPES "18,17,16,23,3,1,2"
>> +#define KRB5_SUPPORTED_ENCTYPES "18,17"
>> diff --git a/net/sunrpc/Kconfig b/net/sunrpc/Kconfig
>> index ac09ca8..80c8efc 100644
>> --- a/net/sunrpc/Kconfig
>> +++ b/net/sunrpc/Kconfig
>> @@ -18,9 +18,8 @@ config SUNRPC_SWAP
>> config RPCSEC_GSS_KRB5
>> 	tristate "Secure RPC: Kerberos V mechanism"
>> 	depends on SUNRPC && CRYPTO
>> -	depends on CRYPTO_MD5 && CRYPTO_DES && CRYPTO_CBC && CRYPTO_CTS
>> +	depends on CRYPTO_MD5 && CRYPTO_CTS
>> 	depends on CRYPTO_ECB && CRYPTO_HMAC && CRYPTO_SHA1 && =
CRYPTO_AES
>> -	depends on CRYPTO_ARC4
>> 	default y
>> 	select SUNRPC_GSS
>> 	help
>> diff --git a/net/sunrpc/auth_gss/Makefile =
b/net/sunrpc/auth_gss/Makefile
>> index c374268..b5a65a0 100644
>> --- a/net/sunrpc/auth_gss/Makefile
>> +++ b/net/sunrpc/auth_gss/Makefile
>> @@ -12,4 +12,4 @@ auth_rpcgss-y :=3D auth_gss.o gss_generic_token.o \
>> obj-$(CONFIG_RPCSEC_GSS_KRB5) +=3D rpcsec_gss_krb5.o
>>=20
>> rpcsec_gss_krb5-y :=3D gss_krb5_mech.o gss_krb5_seal.o =
gss_krb5_unseal.o \
>> -	gss_krb5_seqnum.o gss_krb5_wrap.o gss_krb5_crypto.o =
gss_krb5_keys.o
>> +	gss_krb5_wrap.o gss_krb5_crypto.o gss_krb5_keys.o
>> diff --git a/net/sunrpc/auth_gss/gss_krb5_crypto.c =
b/net/sunrpc/auth_gss/gss_krb5_crypto.c
>> index 4f43383..896dd87 100644
>> --- a/net/sunrpc/auth_gss/gss_krb5_crypto.c
>> +++ b/net/sunrpc/auth_gss/gss_krb5_crypto.c
>> @@ -138,230 +138,6 @@
>> 	return crypto_ahash_update(req);
>> }
>>=20
>> -static int
>> -arcfour_hmac_md5_usage_to_salt(unsigned int usage, u8 salt[4])
>> -{
>> -	unsigned int ms_usage;
>> -
>> -	switch (usage) {
>> -	case KG_USAGE_SIGN:
>> -		ms_usage =3D 15;
>> -		break;
>> -	case KG_USAGE_SEAL:
>> -		ms_usage =3D 13;
>> -		break;
>> -	default:
>> -		return -EINVAL;
>> -	}
>> -	salt[0] =3D (ms_usage >> 0) & 0xff;
>> -	salt[1] =3D (ms_usage >> 8) & 0xff;
>> -	salt[2] =3D (ms_usage >> 16) & 0xff;
>> -	salt[3] =3D (ms_usage >> 24) & 0xff;
>> -
>> -	return 0;
>> -}
>> -
>> -static u32
>> -make_checksum_hmac_md5(struct krb5_ctx *kctx, char *header, int =
hdrlen,
>> -		       struct xdr_buf *body, int body_offset, u8 =
*cksumkey,
>> -		       unsigned int usage, struct xdr_netobj *cksumout)
>> -{
>> -	struct scatterlist              sg[1];
>> -	int err =3D -1;
>> -	u8 *checksumdata;
>> -	u8 *rc4salt;
>> -	struct crypto_ahash *md5;
>> -	struct crypto_ahash *hmac_md5;
>> -	struct ahash_request *req;
>> -
>> -	if (cksumkey =3D=3D NULL)
>> -		return GSS_S_FAILURE;
>> -
>> -	if (cksumout->len < kctx->gk5e->cksumlength) {
>> -		dprintk("%s: checksum buffer length, %u, too small for =
%s\n",
>> -			__func__, cksumout->len, kctx->gk5e->name);
>> -		return GSS_S_FAILURE;
>> -	}
>> -
>> -	rc4salt =3D kmalloc_array(4, sizeof(*rc4salt), GFP_NOFS);
>> -	if (!rc4salt)
>> -		return GSS_S_FAILURE;
>> -
>> -	if (arcfour_hmac_md5_usage_to_salt(usage, rc4salt)) {
>> -		dprintk("%s: invalid usage value %u\n", __func__, =
usage);
>> -		goto out_free_rc4salt;
>> -	}
>> -
>> -	checksumdata =3D kmalloc(GSS_KRB5_MAX_CKSUM_LEN, GFP_NOFS);
>> -	if (!checksumdata)
>> -		goto out_free_rc4salt;
>> -
>> -	md5 =3D crypto_alloc_ahash("md5", 0, CRYPTO_ALG_ASYNC);
>> -	if (IS_ERR(md5))
>> -		goto out_free_cksum;
>> -
>> -	hmac_md5 =3D crypto_alloc_ahash(kctx->gk5e->cksum_name, 0,
>> -				      CRYPTO_ALG_ASYNC);
>> -	if (IS_ERR(hmac_md5))
>> -		goto out_free_md5;
>> -
>> -	req =3D ahash_request_alloc(md5, GFP_NOFS);
>> -	if (!req)
>> -		goto out_free_hmac_md5;
>> -
>> -	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, =
NULL);
>> -
>> -	err =3D crypto_ahash_init(req);
>> -	if (err)
>> -		goto out;
>> -	sg_init_one(sg, rc4salt, 4);
>> -	ahash_request_set_crypt(req, sg, NULL, 4);
>> -	err =3D crypto_ahash_update(req);
>> -	if (err)
>> -		goto out;
>> -
>> -	sg_init_one(sg, header, hdrlen);
>> -	ahash_request_set_crypt(req, sg, NULL, hdrlen);
>> -	err =3D crypto_ahash_update(req);
>> -	if (err)
>> -		goto out;
>> -	err =3D xdr_process_buf(body, body_offset, body->len - =
body_offset,
>> -			      checksummer, req);
>> -	if (err)
>> -		goto out;
>> -	ahash_request_set_crypt(req, NULL, checksumdata, 0);
>> -	err =3D crypto_ahash_final(req);
>> -	if (err)
>> -		goto out;
>> -
>> -	ahash_request_free(req);
>> -	req =3D ahash_request_alloc(hmac_md5, GFP_NOFS);
>> -	if (!req)
>> -		goto out_free_hmac_md5;
>> -
>> -	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, =
NULL);
>> -
>> -	err =3D crypto_ahash_setkey(hmac_md5, cksumkey, =
kctx->gk5e->keylength);
>> -	if (err)
>> -		goto out;
>> -
>> -	sg_init_one(sg, checksumdata, crypto_ahash_digestsize(md5));
>> -	ahash_request_set_crypt(req, sg, checksumdata,
>> -				crypto_ahash_digestsize(md5));
>> -	err =3D crypto_ahash_digest(req);
>> -	if (err)
>> -		goto out;
>> -
>> -	memcpy(cksumout->data, checksumdata, kctx->gk5e->cksumlength);
>> -	cksumout->len =3D kctx->gk5e->cksumlength;
>> -out:
>> -	ahash_request_free(req);
>> -out_free_hmac_md5:
>> -	crypto_free_ahash(hmac_md5);
>> -out_free_md5:
>> -	crypto_free_ahash(md5);
>> -out_free_cksum:
>> -	kfree(checksumdata);
>> -out_free_rc4salt:
>> -	kfree(rc4salt);
>> -	return err ? GSS_S_FAILURE : 0;
>> -}
>> -
>> -/*
>> - * checksum the plaintext data and hdrlen bytes of the token header
>> - * The checksum is performed over the first 8 bytes of the
>> - * gss token header and then over the data body
>> - */
>> -u32
>> -make_checksum(struct krb5_ctx *kctx, char *header, int hdrlen,
>> -	      struct xdr_buf *body, int body_offset, u8 *cksumkey,
>> -	      unsigned int usage, struct xdr_netobj *cksumout)
>> -{
>> -	struct crypto_ahash *tfm;
>> -	struct ahash_request *req;
>> -	struct scatterlist              sg[1];
>> -	int err =3D -1;
>> -	u8 *checksumdata;
>> -	unsigned int checksumlen;
>> -
>> -	if (kctx->gk5e->ctype =3D=3D CKSUMTYPE_HMAC_MD5_ARCFOUR)
>> -		return make_checksum_hmac_md5(kctx, header, hdrlen,
>> -					      body, body_offset,
>> -					      cksumkey, usage, =
cksumout);
>> -
>> -	if (cksumout->len < kctx->gk5e->cksumlength) {
>> -		dprintk("%s: checksum buffer length, %u, too small for =
%s\n",
>> -			__func__, cksumout->len, kctx->gk5e->name);
>> -		return GSS_S_FAILURE;
>> -	}
>> -
>> -	checksumdata =3D kmalloc(GSS_KRB5_MAX_CKSUM_LEN, GFP_NOFS);
>> -	if (checksumdata =3D=3D NULL)
>> -		return GSS_S_FAILURE;
>> -
>> -	tfm =3D crypto_alloc_ahash(kctx->gk5e->cksum_name, 0, =
CRYPTO_ALG_ASYNC);
>> -	if (IS_ERR(tfm))
>> -		goto out_free_cksum;
>> -
>> -	req =3D ahash_request_alloc(tfm, GFP_NOFS);
>> -	if (!req)
>> -		goto out_free_ahash;
>> -
>> -	ahash_request_set_callback(req, CRYPTO_TFM_REQ_MAY_SLEEP, NULL, =
NULL);
>> -
>> -	checksumlen =3D crypto_ahash_digestsize(tfm);
>> -
>> -	if (cksumkey !=3D NULL) {
>> -		err =3D crypto_ahash_setkey(tfm, cksumkey,
>> -					  kctx->gk5e->keylength);
>> -		if (err)
>> -			goto out;
>> -	}
>> -
>> -	err =3D crypto_ahash_init(req);
>> -	if (err)
>> -		goto out;
>> -	sg_init_one(sg, header, hdrlen);
>> -	ahash_request_set_crypt(req, sg, NULL, hdrlen);
>> -	err =3D crypto_ahash_update(req);
>> -	if (err)
>> -		goto out;
>> -	err =3D xdr_process_buf(body, body_offset, body->len - =
body_offset,
>> -			      checksummer, req);
>> -	if (err)
>> -		goto out;
>> -	ahash_request_set_crypt(req, NULL, checksumdata, 0);
>> -	err =3D crypto_ahash_final(req);
>> -	if (err)
>> -		goto out;
>> -
>> -	switch (kctx->gk5e->ctype) {
>> -	case CKSUMTYPE_RSA_MD5:
>> -		err =3D kctx->gk5e->encrypt(kctx->seq, NULL, =
checksumdata,
>> -					  checksumdata, checksumlen);
>> -		if (err)
>> -			goto out;
>> -		memcpy(cksumout->data,
>> -		       checksumdata + checksumlen - =
kctx->gk5e->cksumlength,
>> -		       kctx->gk5e->cksumlength);
>> -		break;
>> -	case CKSUMTYPE_HMAC_SHA1_DES3:
>> -		memcpy(cksumout->data, checksumdata, =
kctx->gk5e->cksumlength);
>> -		break;
>> -	default:
>> -		BUG();
>> -		break;
>> -	}
>> -	cksumout->len =3D kctx->gk5e->cksumlength;
>> -out:
>> -	ahash_request_free(req);
>> -out_free_ahash:
>> -	crypto_free_ahash(tfm);
>> -out_free_cksum:
>> -	kfree(checksumdata);
>> -	return err ? GSS_S_FAILURE : 0;
>> -}
>> -
>> /*
>> * checksum the plaintext data and hdrlen bytes of the token header
>> * Per rfc4121, sec. 4.2.4, the checksum is performed over the data
>> @@ -526,35 +302,6 @@ struct encryptor_desc {
>> 	return 0;
>> }
>>=20
>> -int
>> -gss_encrypt_xdr_buf(struct crypto_sync_skcipher *tfm, struct xdr_buf =
*buf,
>> -		    int offset, struct page **pages)
>> -{
>> -	int ret;
>> -	struct encryptor_desc desc;
>> -	SYNC_SKCIPHER_REQUEST_ON_STACK(req, tfm);
>> -
>> -	BUG_ON((buf->len - offset) % crypto_sync_skcipher_blocksize(tfm) =
!=3D 0);
>> -
>> -	skcipher_request_set_sync_tfm(req, tfm);
>> -	skcipher_request_set_callback(req, 0, NULL, NULL);
>> -
>> -	memset(desc.iv, 0, sizeof(desc.iv));
>> -	desc.req =3D req;
>> -	desc.pos =3D offset;
>> -	desc.outbuf =3D buf;
>> -	desc.pages =3D pages;
>> -	desc.fragno =3D 0;
>> -	desc.fraglen =3D 0;
>> -
>> -	sg_init_table(desc.infrags, 4);
>> -	sg_init_table(desc.outfrags, 4);
>> -
>> -	ret =3D xdr_process_buf(buf, offset, buf->len - offset, =
encryptor, &desc);
>> -	skcipher_request_zero(req);
>> -	return ret;
>> -}
>> -
>> struct decryptor_desc {
>> 	u8 iv[GSS_KRB5_MAX_BLOCKSIZE];
>> 	struct skcipher_request *req;
>> @@ -609,32 +356,6 @@ struct decryptor_desc {
>> 	return 0;
>> }
>>=20
>> -int
>> -gss_decrypt_xdr_buf(struct crypto_sync_skcipher *tfm, struct xdr_buf =
*buf,
>> -		    int offset)
>> -{
>> -	int ret;
>> -	struct decryptor_desc desc;
>> -	SYNC_SKCIPHER_REQUEST_ON_STACK(req, tfm);
>> -
>> -	/* XXXJBF: */
>> -	BUG_ON((buf->len - offset) % crypto_sync_skcipher_blocksize(tfm) =
!=3D 0);
>> -
>> -	skcipher_request_set_sync_tfm(req, tfm);
>> -	skcipher_request_set_callback(req, 0, NULL, NULL);
>> -
>> -	memset(desc.iv, 0, sizeof(desc.iv));
>> -	desc.req =3D req;
>> -	desc.fragno =3D 0;
>> -	desc.fraglen =3D 0;
>> -
>> -	sg_init_table(desc.frags, 4);
>> -
>> -	ret =3D xdr_process_buf(buf, offset, buf->len - offset, =
decryptor, &desc);
>> -	skcipher_request_zero(req);
>> -	return ret;
>> -}
>> -
>> /*
>> * This function makes the assumption that it was ultimately called
>> * from gss_wrap().
>> @@ -942,147 +663,3 @@ struct decryptor_desc {
>> 		ret =3D GSS_S_FAILURE;
>> 	return ret;
>> }
>> -
>> -/*
>> - * Compute Kseq given the initial session key and the checksum.
>> - * Set the key of the given cipher.
>> - */
>> -int
>> -krb5_rc4_setup_seq_key(struct krb5_ctx *kctx,
>> -		       struct crypto_sync_skcipher *cipher,
>> -		       unsigned char *cksum)
>> -{
>> -	struct crypto_shash *hmac;
>> -	struct shash_desc *desc;
>> -	u8 Kseq[GSS_KRB5_MAX_KEYLEN];
>> -	u32 zeroconstant =3D 0;
>> -	int err;
>> -
>> -	dprintk("%s: entered\n", __func__);
>> -
>> -	hmac =3D crypto_alloc_shash(kctx->gk5e->cksum_name, 0, 0);
>> -	if (IS_ERR(hmac)) {
>> -		dprintk("%s: error %ld, allocating hash '%s'\n",
>> -			__func__, PTR_ERR(hmac), =
kctx->gk5e->cksum_name);
>> -		return PTR_ERR(hmac);
>> -	}
>> -
>> -	desc =3D kmalloc(sizeof(*desc) + crypto_shash_descsize(hmac),
>> -		       GFP_NOFS);
>> -	if (!desc) {
>> -		dprintk("%s: failed to allocate shash descriptor for =
'%s'\n",
>> -			__func__, kctx->gk5e->cksum_name);
>> -		crypto_free_shash(hmac);
>> -		return -ENOMEM;
>> -	}
>> -
>> -	desc->tfm =3D hmac;
>> -	desc->flags =3D 0;
>> -
>> -	/* Compute intermediate Kseq from session key */
>> -	err =3D crypto_shash_setkey(hmac, kctx->Ksess, =
kctx->gk5e->keylength);
>> -	if (err)
>> -		goto out_err;
>> -
>> -	err =3D crypto_shash_digest(desc, (u8 *)&zeroconstant, 4, Kseq);
>> -	if (err)
>> -		goto out_err;
>> -
>> -	/* Compute final Kseq from the checksum and intermediate Kseq */
>> -	err =3D crypto_shash_setkey(hmac, Kseq, kctx->gk5e->keylength);
>> -	if (err)
>> -		goto out_err;
>> -
>> -	err =3D crypto_shash_digest(desc, cksum, 8, Kseq);
>> -	if (err)
>> -		goto out_err;
>> -
>> -	err =3D crypto_sync_skcipher_setkey(cipher, Kseq, =
kctx->gk5e->keylength);
>> -	if (err)
>> -		goto out_err;
>> -
>> -	err =3D 0;
>> -
>> -out_err:
>> -	kzfree(desc);
>> -	crypto_free_shash(hmac);
>> -	dprintk("%s: returning %d\n", __func__, err);
>> -	return err;
>> -}
>> -
>> -/*
>> - * Compute Kcrypt given the initial session key and the plaintext =
seqnum.
>> - * Set the key of cipher kctx->enc.
>> - */
>> -int
>> -krb5_rc4_setup_enc_key(struct krb5_ctx *kctx,
>> -		       struct crypto_sync_skcipher *cipher,
>> -		       s32 seqnum)
>> -{
>> -	struct crypto_shash *hmac;
>> -	struct shash_desc *desc;
>> -	u8 Kcrypt[GSS_KRB5_MAX_KEYLEN];
>> -	u8 zeroconstant[4] =3D {0};
>> -	u8 seqnumarray[4];
>> -	int err, i;
>> -
>> -	dprintk("%s: entered, seqnum %u\n", __func__, seqnum);
>> -
>> -	hmac =3D crypto_alloc_shash(kctx->gk5e->cksum_name, 0, 0);
>> -	if (IS_ERR(hmac)) {
>> -		dprintk("%s: error %ld, allocating hash '%s'\n",
>> -			__func__, PTR_ERR(hmac), =
kctx->gk5e->cksum_name);
>> -		return PTR_ERR(hmac);
>> -	}
>> -
>> -	desc =3D kmalloc(sizeof(*desc) + crypto_shash_descsize(hmac),
>> -		       GFP_NOFS);
>> -	if (!desc) {
>> -		dprintk("%s: failed to allocate shash descriptor for =
'%s'\n",
>> -			__func__, kctx->gk5e->cksum_name);
>> -		crypto_free_shash(hmac);
>> -		return -ENOMEM;
>> -	}
>> -
>> -	desc->tfm =3D hmac;
>> -	desc->flags =3D 0;
>> -
>> -	/* Compute intermediate Kcrypt from session key */
>> -	for (i =3D 0; i < kctx->gk5e->keylength; i++)
>> -		Kcrypt[i] =3D kctx->Ksess[i] ^ 0xf0;
>> -
>> -	err =3D crypto_shash_setkey(hmac, Kcrypt, =
kctx->gk5e->keylength);
>> -	if (err)
>> -		goto out_err;
>> -
>> -	err =3D crypto_shash_digest(desc, zeroconstant, 4, Kcrypt);
>> -	if (err)
>> -		goto out_err;
>> -
>> -	/* Compute final Kcrypt from the seqnum and intermediate Kcrypt =
*/
>> -	err =3D crypto_shash_setkey(hmac, Kcrypt, =
kctx->gk5e->keylength);
>> -	if (err)
>> -		goto out_err;
>> -
>> -	seqnumarray[0] =3D (unsigned char) ((seqnum >> 24) & 0xff);
>> -	seqnumarray[1] =3D (unsigned char) ((seqnum >> 16) & 0xff);
>> -	seqnumarray[2] =3D (unsigned char) ((seqnum >> 8) & 0xff);
>> -	seqnumarray[3] =3D (unsigned char) ((seqnum >> 0) & 0xff);
>> -
>> -	err =3D crypto_shash_digest(desc, seqnumarray, 4, Kcrypt);
>> -	if (err)
>> -		goto out_err;
>> -
>> -	err =3D crypto_sync_skcipher_setkey(cipher, Kcrypt,
>> -					  kctx->gk5e->keylength);
>> -	if (err)
>> -		goto out_err;
>> -
>> -	err =3D 0;
>> -
>> -out_err:
>> -	kzfree(desc);
>> -	crypto_free_shash(hmac);
>> -	dprintk("%s: returning %d\n", __func__, err);
>> -	return err;
>> -}
>> diff --git a/net/sunrpc/auth_gss/gss_krb5_keys.c =
b/net/sunrpc/auth_gss/gss_krb5_keys.c
>> index 550fdf1..de327ae 100644
>> --- a/net/sunrpc/auth_gss/gss_krb5_keys.c
>> +++ b/net/sunrpc/auth_gss/gss_krb5_keys.c
>> @@ -242,59 +242,6 @@ u32 krb5_derive_key(const struct =
gss_krb5_enctype *gk5e,
>> 	return ret;
>> }
>>=20
>> -#define smask(step) ((1<<step)-1)
>> -#define pstep(x, step) (((x)&smask(step))^(((x)>>step)&smask(step)))
>> -#define parity_char(x) pstep(pstep(pstep((x), 4), 2), 1)
>> -
>> -static void mit_des_fixup_key_parity(u8 key[8])
>> -{
>> -	int i;
>> -	for (i =3D 0; i < 8; i++) {
>> -		key[i] &=3D 0xfe;
>> -		key[i] |=3D 1^parity_char(key[i]);
>> -	}
>> -}
>> -
>> -/*
>> - * This is the des3 key derivation postprocess function
>> - */
>> -u32 gss_krb5_des3_make_key(const struct gss_krb5_enctype *gk5e,
>> -			   struct xdr_netobj *randombits,
>> -			   struct xdr_netobj *key)
>> -{
>> -	int i;
>> -	u32 ret =3D EINVAL;
>> -
>> -	if (key->len !=3D 24) {
>> -		dprintk("%s: key->len is %d\n", __func__, key->len);
>> -		goto err_out;
>> -	}
>> -	if (randombits->len !=3D 21) {
>> -		dprintk("%s: randombits->len is %d\n",
>> -			__func__, randombits->len);
>> -		goto err_out;
>> -	}
>> -
>> -	/* take the seven bytes, move them around into the top 7 bits of =
the
>> -	   8 key bytes, then compute the parity bits.  Do this three =
times. */
>> -
>> -	for (i =3D 0; i < 3; i++) {
>> -		memcpy(key->data + i*8, randombits->data + i*7, 7);
>> -		key->data[i*8+7] =3D (((key->data[i*8]&1)<<1) |
>> -				    ((key->data[i*8+1]&1)<<2) |
>> -				    ((key->data[i*8+2]&1)<<3) |
>> -				    ((key->data[i*8+3]&1)<<4) |
>> -				    ((key->data[i*8+4]&1)<<5) |
>> -				    ((key->data[i*8+5]&1)<<6) |
>> -				    ((key->data[i*8+6]&1)<<7));
>> -
>> -		mit_des_fixup_key_parity(key->data + i*8);
>> -	}
>> -	ret =3D 0;
>> -err_out:
>> -	return ret;
>> -}
>> -
>> /*
>> * This is the aes key derivation postprocess function
>> */
>> diff --git a/net/sunrpc/auth_gss/gss_krb5_mech.c =
b/net/sunrpc/auth_gss/gss_krb5_mech.c
>> index eab71fc..0837543 100644
>> --- a/net/sunrpc/auth_gss/gss_krb5_mech.c
>> +++ b/net/sunrpc/auth_gss/gss_krb5_mech.c
>> @@ -54,69 +54,6 @@
>>=20
>> static const struct gss_krb5_enctype supported_gss_krb5_enctypes[] =3D =
{
>> 	/*
>> -	 * DES (All DES enctypes are mapped to the same gss =
functionality)
>> -	 */
>> -	{
>> -	  .etype =3D ENCTYPE_DES_CBC_RAW,
>> -	  .ctype =3D CKSUMTYPE_RSA_MD5,
>> -	  .name =3D "des-cbc-crc",
>> -	  .encrypt_name =3D "cbc(des)",
>> -	  .cksum_name =3D "md5",
>> -	  .encrypt =3D krb5_encrypt,
>> -	  .decrypt =3D krb5_decrypt,
>> -	  .mk_key =3D NULL,
>> -	  .signalg =3D SGN_ALG_DES_MAC_MD5,
>> -	  .sealalg =3D SEAL_ALG_DES,
>> -	  .keybytes =3D 7,
>> -	  .keylength =3D 8,
>> -	  .blocksize =3D 8,
>> -	  .conflen =3D 8,
>> -	  .cksumlength =3D 8,
>> -	  .keyed_cksum =3D 0,
>> -	},
>> -	/*
>> -	 * RC4-HMAC
>> -	 */
>> -	{
>> -	  .etype =3D ENCTYPE_ARCFOUR_HMAC,
>> -	  .ctype =3D CKSUMTYPE_HMAC_MD5_ARCFOUR,
>> -	  .name =3D "rc4-hmac",
>> -	  .encrypt_name =3D "ecb(arc4)",
>> -	  .cksum_name =3D "hmac(md5)",
>> -	  .encrypt =3D krb5_encrypt,
>> -	  .decrypt =3D krb5_decrypt,
>> -	  .mk_key =3D NULL,
>> -	  .signalg =3D SGN_ALG_HMAC_MD5,
>> -	  .sealalg =3D SEAL_ALG_MICROSOFT_RC4,
>> -	  .keybytes =3D 16,
>> -	  .keylength =3D 16,
>> -	  .blocksize =3D 1,
>> -	  .conflen =3D 8,
>> -	  .cksumlength =3D 8,
>> -	  .keyed_cksum =3D 1,
>> -	},
>> -	/*
>> -	 * 3DES
>> -	 */
>> -	{
>> -	  .etype =3D ENCTYPE_DES3_CBC_RAW,
>> -	  .ctype =3D CKSUMTYPE_HMAC_SHA1_DES3,
>> -	  .name =3D "des3-hmac-sha1",
>> -	  .encrypt_name =3D "cbc(des3_ede)",
>> -	  .cksum_name =3D "hmac(sha1)",
>> -	  .encrypt =3D krb5_encrypt,
>> -	  .decrypt =3D krb5_decrypt,
>> -	  .mk_key =3D gss_krb5_des3_make_key,
>> -	  .signalg =3D SGN_ALG_HMAC_SHA1_DES3_KD,
>> -	  .sealalg =3D SEAL_ALG_DES3KD,
>> -	  .keybytes =3D 21,
>> -	  .keylength =3D 24,
>> -	  .blocksize =3D 8,
>> -	  .conflen =3D 8,
>> -	  .cksumlength =3D 20,
>> -	  .keyed_cksum =3D 1,
>> -	},
>> -	/*
>> 	 * AES128
>> 	 */
>> 	{
>> @@ -227,15 +164,6 @@
>> 	if (IS_ERR(p))
>> 		goto out_err;
>>=20
>> -	switch (alg) {
>> -	case ENCTYPE_DES_CBC_CRC:
>> -	case ENCTYPE_DES_CBC_MD4:
>> -	case ENCTYPE_DES_CBC_MD5:
>> -		/* Map all these key types to ENCTYPE_DES_CBC_RAW */
>> -		alg =3D ENCTYPE_DES_CBC_RAW;
>> -		break;
>> -	}
>> -
>> 	if (!supported_gss_krb5_enctype(alg)) {
>> 		printk(KERN_WARNING "gss_kerberos_mech: unsupported "
>> 			"encryption key algorithm %d\n", alg);
>> @@ -271,81 +199,6 @@
>> 	return p;
>> }
>>=20
>> -static int
>> -gss_import_v1_context(const void *p, const void *end, struct =
krb5_ctx *ctx)
>> -{
>> -	u32 seq_send;
>> -	int tmp;
>> -
>> -	p =3D simple_get_bytes(p, end, &ctx->initiate, =
sizeof(ctx->initiate));
>> -	if (IS_ERR(p))
>> -		goto out_err;
>> -
>> -	/* Old format supports only DES!  Any other enctype uses new =
format */
>> -	ctx->enctype =3D ENCTYPE_DES_CBC_RAW;
>> -
>> -	ctx->gk5e =3D get_gss_krb5_enctype(ctx->enctype);
>> -	if (ctx->gk5e =3D=3D NULL) {
>> -		p =3D ERR_PTR(-EINVAL);
>> -		goto out_err;
>> -	}
>> -
>> -	/* The downcall format was designed before we completely =
understood
>> -	 * the uses of the context fields; so it includes some stuff we
>> -	 * just give some minimal sanity-checking, and some we ignore
>> -	 * completely (like the next twenty bytes): */
>> -	if (unlikely(p + 20 > end || p + 20 < p)) {
>> -		p =3D ERR_PTR(-EFAULT);
>> -		goto out_err;
>> -	}
>> -	p +=3D 20;
>> -	p =3D simple_get_bytes(p, end, &tmp, sizeof(tmp));
>> -	if (IS_ERR(p))
>> -		goto out_err;
>> -	if (tmp !=3D SGN_ALG_DES_MAC_MD5) {
>> -		p =3D ERR_PTR(-ENOSYS);
>> -		goto out_err;
>> -	}
>> -	p =3D simple_get_bytes(p, end, &tmp, sizeof(tmp));
>> -	if (IS_ERR(p))
>> -		goto out_err;
>> -	if (tmp !=3D SEAL_ALG_DES) {
>> -		p =3D ERR_PTR(-ENOSYS);
>> -		goto out_err;
>> -	}
>> -	p =3D simple_get_bytes(p, end, &ctx->endtime, =
sizeof(ctx->endtime));
>> -	if (IS_ERR(p))
>> -		goto out_err;
>> -	p =3D simple_get_bytes(p, end, &seq_send, sizeof(seq_send));
>> -	if (IS_ERR(p))
>> -		goto out_err;
>> -	atomic_set(&ctx->seq_send, seq_send);
>> -	p =3D simple_get_netobj(p, end, &ctx->mech_used);
>> -	if (IS_ERR(p))
>> -		goto out_err;
>> -	p =3D get_key(p, end, ctx, &ctx->enc);
>> -	if (IS_ERR(p))
>> -		goto out_err_free_mech;
>> -	p =3D get_key(p, end, ctx, &ctx->seq);
>> -	if (IS_ERR(p))
>> -		goto out_err_free_key1;
>> -	if (p !=3D end) {
>> -		p =3D ERR_PTR(-EFAULT);
>> -		goto out_err_free_key2;
>> -	}
>> -
>> -	return 0;
>> -
>> -out_err_free_key2:
>> -	crypto_free_sync_skcipher(ctx->seq);
>> -out_err_free_key1:
>> -	crypto_free_sync_skcipher(ctx->enc);
>> -out_err_free_mech:
>> -	kfree(ctx->mech_used.data);
>> -out_err:
>> -	return PTR_ERR(p);
>> -}
>> -
>> static struct crypto_sync_skcipher *
>> context_v2_alloc_cipher(struct krb5_ctx *ctx, const char *cname, u8 =
*key)
>> {
>> @@ -377,124 +230,6 @@
>> }
>>=20
>> static int
>> -context_derive_keys_des3(struct krb5_ctx *ctx, gfp_t gfp_mask)
>> -{
>> -	struct xdr_netobj c, keyin, keyout;
>> -	u8 cdata[GSS_KRB5_K5CLENGTH];
>> -	u32 err;
>> -
>> -	c.len =3D GSS_KRB5_K5CLENGTH;
>> -	c.data =3D cdata;
>> -
>> -	keyin.data =3D ctx->Ksess;
>> -	keyin.len =3D ctx->gk5e->keylength;
>> -	keyout.len =3D ctx->gk5e->keylength;
>> -
>> -	/* seq uses the raw key */
>> -	ctx->seq =3D context_v2_alloc_cipher(ctx, =
ctx->gk5e->encrypt_name,
>> -					   ctx->Ksess);
>> -	if (ctx->seq =3D=3D NULL)
>> -		goto out_err;
>> -
>> -	ctx->enc =3D context_v2_alloc_cipher(ctx, =
ctx->gk5e->encrypt_name,
>> -					   ctx->Ksess);
>> -	if (ctx->enc =3D=3D NULL)
>> -		goto out_free_seq;
>> -
>> -	/* derive cksum */
>> -	set_cdata(cdata, KG_USAGE_SIGN, KEY_USAGE_SEED_CHECKSUM);
>> -	keyout.data =3D ctx->cksum;
>> -	err =3D krb5_derive_key(ctx->gk5e, &keyin, &keyout, &c, =
gfp_mask);
>> -	if (err) {
>> -		dprintk("%s: Error %d deriving cksum key\n",
>> -			__func__, err);
>> -		goto out_free_enc;
>> -	}
>> -
>> -	return 0;
>> -
>> -out_free_enc:
>> -	crypto_free_sync_skcipher(ctx->enc);
>> -out_free_seq:
>> -	crypto_free_sync_skcipher(ctx->seq);
>> -out_err:
>> -	return -EINVAL;
>> -}
>> -
>> -/*
>> - * Note that RC4 depends on deriving keys using the sequence
>> - * number or the checksum of a token.  Therefore, the final keys
>> - * cannot be calculated until the token is being constructed!
>> - */
>> -static int
>> -context_derive_keys_rc4(struct krb5_ctx *ctx)
>> -{
>> -	struct crypto_shash *hmac;
>> -	char sigkeyconstant[] =3D "signaturekey";
>> -	int slen =3D strlen(sigkeyconstant) + 1;	/* include null =
terminator */
>> -	struct shash_desc *desc;
>> -	int err;
>> -
>> -	dprintk("RPC:       %s: entered\n", __func__);
>> -	/*
>> -	 * derive cksum (aka Ksign) key
>> -	 */
>> -	hmac =3D crypto_alloc_shash(ctx->gk5e->cksum_name, 0, 0);
>> -	if (IS_ERR(hmac)) {
>> -		dprintk("%s: error %ld allocating hash '%s'\n",
>> -			__func__, PTR_ERR(hmac), ctx->gk5e->cksum_name);
>> -		err =3D PTR_ERR(hmac);
>> -		goto out_err;
>> -	}
>> -
>> -	err =3D crypto_shash_setkey(hmac, ctx->Ksess, =
ctx->gk5e->keylength);
>> -	if (err)
>> -		goto out_err_free_hmac;
>> -
>> -
>> -	desc =3D kmalloc(sizeof(*desc) + crypto_shash_descsize(hmac), =
GFP_NOFS);
>> -	if (!desc) {
>> -		dprintk("%s: failed to allocate hash descriptor for =
'%s'\n",
>> -			__func__, ctx->gk5e->cksum_name);
>> -		err =3D -ENOMEM;
>> -		goto out_err_free_hmac;
>> -	}
>> -
>> -	desc->tfm =3D hmac;
>> -	desc->flags =3D 0;
>> -
>> -	err =3D crypto_shash_digest(desc, sigkeyconstant, slen, =
ctx->cksum);
>> -	kzfree(desc);
>> -	if (err)
>> -		goto out_err_free_hmac;
>> -	/*
>> -	 * allocate hash, and skciphers for data and seqnum encryption
>> -	 */
>> -	ctx->enc =3D crypto_alloc_sync_skcipher(ctx->gk5e->encrypt_name, =
0, 0);
>> -	if (IS_ERR(ctx->enc)) {
>> -		err =3D PTR_ERR(ctx->enc);
>> -		goto out_err_free_hmac;
>> -	}
>> -
>> -	ctx->seq =3D crypto_alloc_sync_skcipher(ctx->gk5e->encrypt_name, =
0, 0);
>> -	if (IS_ERR(ctx->seq)) {
>> -		crypto_free_sync_skcipher(ctx->enc);
>> -		err =3D PTR_ERR(ctx->seq);
>> -		goto out_err_free_hmac;
>> -	}
>> -
>> -	dprintk("RPC:       %s: returning success\n", __func__);
>> -
>> -	err =3D 0;
>> -
>> -out_err_free_hmac:
>> -	crypto_free_shash(hmac);
>> -out_err:
>> -	dprintk("RPC:       %s: returning %d\n", __func__, err);
>> -	return err;
>> -}
>> -
>> -static int
>> context_derive_keys_new(struct krb5_ctx *ctx, gfp_t gfp_mask)
>> {
>> 	struct xdr_netobj c, keyin, keyout;
>> @@ -635,9 +370,6 @@
>> 	p =3D simple_get_bytes(p, end, &ctx->enctype, =
sizeof(ctx->enctype));
>> 	if (IS_ERR(p))
>> 		goto out_err;
>> -	/* Map ENCTYPE_DES3_CBC_SHA1 to ENCTYPE_DES3_CBC_RAW */
>> -	if (ctx->enctype =3D=3D ENCTYPE_DES3_CBC_SHA1)
>> -		ctx->enctype =3D ENCTYPE_DES3_CBC_RAW;
>> 	ctx->gk5e =3D get_gss_krb5_enctype(ctx->enctype);
>> 	if (ctx->gk5e =3D=3D NULL) {
>> 		dprintk("gss_kerberos_mech: unsupported krb5 enctype =
%u\n",
>> @@ -665,10 +397,6 @@
>> 	ctx->mech_used.len =3D gss_kerberos_mech.gm_oid.len;
>>=20
>> 	switch (ctx->enctype) {
>> -	case ENCTYPE_DES3_CBC_RAW:
>> -		return context_derive_keys_des3(ctx, gfp_mask);
>> -	case ENCTYPE_ARCFOUR_HMAC:
>> -		return context_derive_keys_rc4(ctx);
>> 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
>> 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
>> 		return context_derive_keys_new(ctx, gfp_mask);
>> @@ -694,11 +422,7 @@
>> 	if (ctx =3D=3D NULL)
>> 		return -ENOMEM;
>>=20
>> -	if (len =3D=3D 85)
>> -		ret =3D gss_import_v1_context(p, end, ctx);
>> -	else
>> -		ret =3D gss_import_v2_context(p, end, ctx, gfp_mask);
>> -
>> +	ret =3D gss_import_v2_context(p, end, ctx, gfp_mask);
>> 	if (ret =3D=3D 0) {
>> 		ctx_id->internal_ctx_id =3D ctx;
>> 		if (endtime)
>> diff --git a/net/sunrpc/auth_gss/gss_krb5_seal.c =
b/net/sunrpc/auth_gss/gss_krb5_seal.c
>> index 48fe4a5..feb0f2a 100644
>> --- a/net/sunrpc/auth_gss/gss_krb5_seal.c
>> +++ b/net/sunrpc/auth_gss/gss_krb5_seal.c
>> @@ -70,32 +70,6 @@
>> #endif
>>=20
>> static void *
>> -setup_token(struct krb5_ctx *ctx, struct xdr_netobj *token)
>> -{
>> -	u16 *ptr;
>> -	void *krb5_hdr;
>> -	int body_size =3D GSS_KRB5_TOK_HDR_LEN + ctx->gk5e->cksumlength;
>> -
>> -	token->len =3D g_token_size(&ctx->mech_used, body_size);
>> -
>> -	ptr =3D (u16 *)token->data;
>> -	g_make_token_header(&ctx->mech_used, body_size, (unsigned char =
**)&ptr);
>> -
>> -	/* ptr now at start of header described in rfc 1964, section =
1.2.1: */
>> -	krb5_hdr =3D ptr;
>> -	*ptr++ =3D KG_TOK_MIC_MSG;
>> -	/*
>> -	 * signalg is stored as if it were converted from LE to host =
endian, even
>> -	 * though it's an opaque pair of bytes according to the RFC.
>> -	 */
>> -	*ptr++ =3D (__force u16)cpu_to_le16(ctx->gk5e->signalg);
>> -	*ptr++ =3D SEAL_ALG_NONE;
>> -	*ptr =3D 0xffff;
>> -
>> -	return krb5_hdr;
>> -}
>> -
>> -static void *
>> setup_token_v2(struct krb5_ctx *ctx, struct xdr_netobj *token)
>> {
>> 	u16 *ptr;
>> @@ -124,45 +98,6 @@
>> }
>>=20
>> static u32
>> -gss_get_mic_v1(struct krb5_ctx *ctx, struct xdr_buf *text,
>> -		struct xdr_netobj *token)
>> -{
>> -	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
>> -	struct xdr_netobj	md5cksum =3D {.len =3D =
sizeof(cksumdata),
>> -					    .data =3D cksumdata};
>> -	void			*ptr;
>> -	s32			now;
>> -	u32			seq_send;
>> -	u8			*cksumkey;
>> -
>> -	dprintk("RPC:       %s\n", __func__);
>> -	BUG_ON(ctx =3D=3D NULL);
>> -
>> -	now =3D get_seconds();
>> -
>> -	ptr =3D setup_token(ctx, token);
>> -
>> -	if (ctx->gk5e->keyed_cksum)
>> -		cksumkey =3D ctx->cksum;
>> -	else
>> -		cksumkey =3D NULL;
>> -
>> -	if (make_checksum(ctx, ptr, 8, text, 0, cksumkey,
>> -			  KG_USAGE_SIGN, &md5cksum))
>> -		return GSS_S_FAILURE;
>> -
>> -	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data, md5cksum.len);
>> -
>> -	seq_send =3D atomic_fetch_inc(&ctx->seq_send);
>> -
>> -	if (krb5_make_seq_num(ctx, ctx->seq, ctx->initiate ? 0 : 0xff,
>> -			      seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr =
+ 8))
>> -		return GSS_S_FAILURE;
>> -
>> -	return (ctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : =
GSS_S_COMPLETE;
>> -}
>> -
>> -static u32
>> gss_get_mic_v2(struct krb5_ctx *ctx, struct xdr_buf *text,
>> 		struct xdr_netobj *token)
>> {
>> @@ -210,14 +145,10 @@
>> 	struct krb5_ctx		*ctx =3D gss_ctx->internal_ctx_id;
>>=20
>> 	switch (ctx->enctype) {
>> -	default:
>> -		BUG();
>> -	case ENCTYPE_DES_CBC_RAW:
>> -	case ENCTYPE_DES3_CBC_RAW:
>> -	case ENCTYPE_ARCFOUR_HMAC:
>> -		return gss_get_mic_v1(ctx, text, token);
>> 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
>> 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
>> 		return gss_get_mic_v2(ctx, text, token);
>> +	default:
>> +		return GSS_S_FAILURE;
>> 	}
>> }
>> diff --git a/net/sunrpc/auth_gss/gss_krb5_seqnum.c =
b/net/sunrpc/auth_gss/gss_krb5_seqnum.c
>> deleted file mode 100644
>> index fb66562..0000000
>> --- a/net/sunrpc/auth_gss/gss_krb5_seqnum.c
>> +++ /dev/null
>> @@ -1,164 +0,0 @@
>> -/*
>> - *  linux/net/sunrpc/gss_krb5_seqnum.c
>> - *
>> - *  Adapted from MIT Kerberos 5-1.2.1 lib/gssapi/krb5/util_seqnum.c
>> - *
>> - *  Copyright (c) 2000 The Regents of the University of Michigan.
>> - *  All rights reserved.
>> - *
>> - *  Andy Adamson   <andros@umich.edu>
>> - */
>> -
>> -/*
>> - * Copyright 1993 by OpenVision Technologies, Inc.
>> - *
>> - * Permission to use, copy, modify, distribute, and sell this =
software
>> - * and its documentation for any purpose is hereby granted without =
fee,
>> - * provided that the above copyright notice appears in all copies =
and
>> - * that both that copyright notice and this permission notice appear =
in
>> - * supporting documentation, and that the name of OpenVision not be =
used
>> - * in advertising or publicity pertaining to distribution of the =
software
>> - * without specific, written prior permission. OpenVision makes no
>> - * representations about the suitability of this software for any
>> - * purpose.  It is provided "as is" without express or implied =
warranty.
>> - *
>> - * OPENVISION DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
>> - * INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, =
IN NO
>> - * EVENT SHALL OPENVISION BE LIABLE FOR ANY SPECIAL, INDIRECT OR
>> - * CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM =
LOSS OF
>> - * USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, =
NEGLIGENCE OR
>> - * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE =
USE OR
>> - * PERFORMANCE OF THIS SOFTWARE.
>> - */
>> -
>> -#include <crypto/skcipher.h>
>> -#include <linux/types.h>
>> -#include <linux/sunrpc/gss_krb5.h>
>> -
>> -#if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
>> -# define RPCDBG_FACILITY        RPCDBG_AUTH
>> -#endif
>> -
>> -static s32
>> -krb5_make_rc4_seq_num(struct krb5_ctx *kctx, int direction, s32 =
seqnum,
>> -		      unsigned char *cksum, unsigned char *buf)
>> -{
>> -	struct crypto_sync_skcipher *cipher;
>> -	unsigned char plain[8];
>> -	s32 code;
>> -
>> -	dprintk("RPC:       %s:\n", __func__);
>> -	cipher =3D crypto_alloc_sync_skcipher(kctx->gk5e->encrypt_name, =
0, 0);
>> -	if (IS_ERR(cipher))
>> -		return PTR_ERR(cipher);
>> -
>> -	plain[0] =3D (unsigned char) ((seqnum >> 24) & 0xff);
>> -	plain[1] =3D (unsigned char) ((seqnum >> 16) & 0xff);
>> -	plain[2] =3D (unsigned char) ((seqnum >> 8) & 0xff);
>> -	plain[3] =3D (unsigned char) ((seqnum >> 0) & 0xff);
>> -	plain[4] =3D direction;
>> -	plain[5] =3D direction;
>> -	plain[6] =3D direction;
>> -	plain[7] =3D direction;
>> -
>> -	code =3D krb5_rc4_setup_seq_key(kctx, cipher, cksum);
>> -	if (code)
>> -		goto out;
>> -
>> -	code =3D krb5_encrypt(cipher, cksum, plain, buf, 8);
>> -out:
>> -	crypto_free_sync_skcipher(cipher);
>> -	return code;
>> -}
>> -s32
>> -krb5_make_seq_num(struct krb5_ctx *kctx,
>> -		struct crypto_sync_skcipher *key,
>> -		int direction,
>> -		u32 seqnum,
>> -		unsigned char *cksum, unsigned char *buf)
>> -{
>> -	unsigned char plain[8];
>> -
>> -	if (kctx->enctype =3D=3D ENCTYPE_ARCFOUR_HMAC)
>> -		return krb5_make_rc4_seq_num(kctx, direction, seqnum,
>> -					     cksum, buf);
>> -
>> -	plain[0] =3D (unsigned char) (seqnum & 0xff);
>> -	plain[1] =3D (unsigned char) ((seqnum >> 8) & 0xff);
>> -	plain[2] =3D (unsigned char) ((seqnum >> 16) & 0xff);
>> -	plain[3] =3D (unsigned char) ((seqnum >> 24) & 0xff);
>> -
>> -	plain[4] =3D direction;
>> -	plain[5] =3D direction;
>> -	plain[6] =3D direction;
>> -	plain[7] =3D direction;
>> -
>> -	return krb5_encrypt(key, cksum, plain, buf, 8);
>> -}
>> -
>> -static s32
>> -krb5_get_rc4_seq_num(struct krb5_ctx *kctx, unsigned char *cksum,
>> -		     unsigned char *buf, int *direction, s32 *seqnum)
>> -{
>> -	struct crypto_sync_skcipher *cipher;
>> -	unsigned char plain[8];
>> -	s32 code;
>> -
>> -	dprintk("RPC:       %s:\n", __func__);
>> -	cipher =3D crypto_alloc_sync_skcipher(kctx->gk5e->encrypt_name, =
0, 0);
>> -	if (IS_ERR(cipher))
>> -		return PTR_ERR(cipher);
>> -
>> -	code =3D krb5_rc4_setup_seq_key(kctx, cipher, cksum);
>> -	if (code)
>> -		goto out;
>> -
>> -	code =3D krb5_decrypt(cipher, cksum, buf, plain, 8);
>> -	if (code)
>> -		goto out;
>> -
>> -	if ((plain[4] !=3D plain[5]) || (plain[4] !=3D plain[6])
>> -				   || (plain[4] !=3D plain[7])) {
>> -		code =3D (s32)KG_BAD_SEQ;
>> -		goto out;
>> -	}
>> -
>> -	*direction =3D plain[4];
>> -
>> -	*seqnum =3D ((plain[0] << 24) | (plain[1] << 16) |
>> -					(plain[2] << 8) | (plain[3]));
>> -out:
>> -	crypto_free_sync_skcipher(cipher);
>> -	return code;
>> -}
>> -
>> -s32
>> -krb5_get_seq_num(struct krb5_ctx *kctx,
>> -	       unsigned char *cksum,
>> -	       unsigned char *buf,
>> -	       int *direction, u32 *seqnum)
>> -{
>> -	s32 code;
>> -	unsigned char plain[8];
>> -	struct crypto_sync_skcipher *key =3D kctx->seq;
>> -
>> -	dprintk("RPC:       krb5_get_seq_num:\n");
>> -
>> -	if (kctx->enctype =3D=3D ENCTYPE_ARCFOUR_HMAC)
>> -		return krb5_get_rc4_seq_num(kctx, cksum, buf,
>> -					    direction, seqnum);
>> -
>> -	if ((code =3D krb5_decrypt(key, cksum, buf, plain, 8)))
>> -		return code;
>> -
>> -	if ((plain[4] !=3D plain[5]) || (plain[4] !=3D plain[6]) ||
>> -	    (plain[4] !=3D plain[7]))
>> -		return (s32)KG_BAD_SEQ;
>> -
>> -	*direction =3D plain[4];
>> -
>> -	*seqnum =3D ((plain[0]) |
>> -		   (plain[1] << 8) | (plain[2] << 16) | (plain[3] << =
24));
>> -
>> -	return 0;
>> -}
>> diff --git a/net/sunrpc/auth_gss/gss_krb5_unseal.c =
b/net/sunrpc/auth_gss/gss_krb5_unseal.c
>> index ef2b25b..f0f646a 100644
>> --- a/net/sunrpc/auth_gss/gss_krb5_unseal.c
>> +++ b/net/sunrpc/auth_gss/gss_krb5_unseal.c
>> @@ -71,78 +71,6 @@
>> * supposedly taken over. */
>>=20
>> static u32
>> -gss_verify_mic_v1(struct krb5_ctx *ctx,
>> -		struct xdr_buf *message_buffer, struct xdr_netobj =
*read_token)
>> -{
>> -	int			signalg;
>> -	int			sealalg;
>> -	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
>> -	struct xdr_netobj	md5cksum =3D {.len =3D =
sizeof(cksumdata),
>> -					    .data =3D cksumdata};
>> -	s32			now;
>> -	int			direction;
>> -	u32			seqnum;
>> -	unsigned char		*ptr =3D (unsigned char =
*)read_token->data;
>> -	int			bodysize;
>> -	u8			*cksumkey;
>> -
>> -	dprintk("RPC:       krb5_read_token\n");
>> -
>> -	if (g_verify_token_header(&ctx->mech_used, &bodysize, &ptr,
>> -					read_token->len))
>> -		return GSS_S_DEFECTIVE_TOKEN;
>> -
>> -	if ((ptr[0] !=3D ((KG_TOK_MIC_MSG >> 8) & 0xff)) ||
>> -	    (ptr[1] !=3D  (KG_TOK_MIC_MSG & 0xff)))
>> -		return GSS_S_DEFECTIVE_TOKEN;
>> -
>> -	/* XXX sanity-check bodysize?? */
>> -
>> -	signalg =3D ptr[2] + (ptr[3] << 8);
>> -	if (signalg !=3D ctx->gk5e->signalg)
>> -		return GSS_S_DEFECTIVE_TOKEN;
>> -
>> -	sealalg =3D ptr[4] + (ptr[5] << 8);
>> -	if (sealalg !=3D SEAL_ALG_NONE)
>> -		return GSS_S_DEFECTIVE_TOKEN;
>> -
>> -	if ((ptr[6] !=3D 0xff) || (ptr[7] !=3D 0xff))
>> -		return GSS_S_DEFECTIVE_TOKEN;
>> -
>> -	if (ctx->gk5e->keyed_cksum)
>> -		cksumkey =3D ctx->cksum;
>> -	else
>> -		cksumkey =3D NULL;
>> -
>> -	if (make_checksum(ctx, ptr, 8, message_buffer, 0,
>> -			  cksumkey, KG_USAGE_SIGN, &md5cksum))
>> -		return GSS_S_FAILURE;
>> -
>> -	if (memcmp(md5cksum.data, ptr + GSS_KRB5_TOK_HDR_LEN,
>> -					ctx->gk5e->cksumlength))
>> -		return GSS_S_BAD_SIG;
>> -
>> -	/* it got through unscathed.  Make sure the context is unexpired =
*/
>> -
>> -	now =3D get_seconds();
>> -
>> -	if (now > ctx->endtime)
>> -		return GSS_S_CONTEXT_EXPIRED;
>> -
>> -	/* do sequencing checks */
>> -
>> -	if (krb5_get_seq_num(ctx, ptr + GSS_KRB5_TOK_HDR_LEN, ptr + 8,
>> -			     &direction, &seqnum))
>> -		return GSS_S_FAILURE;
>> -
>> -	if ((ctx->initiate && direction !=3D 0xff) ||
>> -	    (!ctx->initiate && direction !=3D 0))
>> -		return GSS_S_BAD_SIG;
>> -
>> -	return GSS_S_COMPLETE;
>> -}
>> -
>> -static u32
>> gss_verify_mic_v2(struct krb5_ctx *ctx,
>> 		struct xdr_buf *message_buffer, struct xdr_netobj =
*read_token)
>> {
>> @@ -214,14 +142,10 @@
>> 	struct krb5_ctx *ctx =3D gss_ctx->internal_ctx_id;
>>=20
>> 	switch (ctx->enctype) {
>> -	default:
>> -		BUG();
>> -	case ENCTYPE_DES_CBC_RAW:
>> -	case ENCTYPE_DES3_CBC_RAW:
>> -	case ENCTYPE_ARCFOUR_HMAC:
>> -		return gss_verify_mic_v1(ctx, message_buffer, =
read_token);
>> 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
>> 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
>> 		return gss_verify_mic_v2(ctx, message_buffer, =
read_token);
>> +	default:
>> +		return GSS_S_FAILURE;
>> 	}
>> }
>> diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c =
b/net/sunrpc/auth_gss/gss_krb5_wrap.c
>> index 5cdde6c..98c99d3 100644
>> --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
>> +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
>> @@ -146,244 +146,6 @@
>> 	}
>> }
>>=20
>> -/* Assumptions: the head and tail of inbuf are ours to play with.
>> - * The pages, however, may be real pages in the page cache and we =
replace
>> - * them with scratch pages from **pages before writing to them. */
>> -/* XXX: obviously the above should be documentation of wrap =
interface,
>> - * and shouldn't be in this kerberos-specific file. */
>> -
>> -/* XXX factor out common code with seal/unseal. */
>> -
>> -static u32
>> -gss_wrap_kerberos_v1(struct krb5_ctx *kctx, int offset,
>> -		struct xdr_buf *buf, struct page **pages)
>> -{
>> -	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
>> -	struct xdr_netobj	md5cksum =3D {.len =3D =
sizeof(cksumdata),
>> -					    .data =3D cksumdata};
>> -	int			blocksize =3D 0, plainlen;
>> -	unsigned char		*ptr, *msg_start;
>> -	s32			now;
>> -	int			headlen;
>> -	struct page		**tmp_pages;
>> -	u32			seq_send;
>> -	u8			*cksumkey;
>> -	u32			conflen =3D kctx->gk5e->conflen;
>> -
>> -	dprintk("RPC:       %s\n", __func__);
>> -
>> -	now =3D get_seconds();
>> -
>> -	blocksize =3D crypto_sync_skcipher_blocksize(kctx->enc);
>> -	gss_krb5_add_padding(buf, offset, blocksize);
>> -	BUG_ON((buf->len - offset) % blocksize);
>> -	plainlen =3D conflen + buf->len - offset;
>> -
>> -	headlen =3D g_token_size(&kctx->mech_used,
>> -		GSS_KRB5_TOK_HDR_LEN + kctx->gk5e->cksumlength + =
plainlen) -
>> -		(buf->len - offset);
>> -
>> -	ptr =3D buf->head[0].iov_base + offset;
>> -	/* shift data to make room for header. */
>> -	xdr_extend_head(buf, offset, headlen);
>> -
>> -	/* XXX Would be cleverer to encrypt while copying. */
>> -	BUG_ON((buf->len - offset - headlen) % blocksize);
>> -
>> -	g_make_token_header(&kctx->mech_used,
>> -				GSS_KRB5_TOK_HDR_LEN +
>> -				kctx->gk5e->cksumlength + plainlen, =
&ptr);
>> -
>> -
>> -	/* ptr now at header described in rfc 1964, section 1.2.1: */
>> -	ptr[0] =3D (unsigned char) ((KG_TOK_WRAP_MSG >> 8) & 0xff);
>> -	ptr[1] =3D (unsigned char) (KG_TOK_WRAP_MSG & 0xff);
>> -
>> -	msg_start =3D ptr + GSS_KRB5_TOK_HDR_LEN + =
kctx->gk5e->cksumlength;
>> -
>> -	/*
>> -	 * signalg and sealalg are stored as if they were converted from =
LE
>> -	 * to host endian, even though they're opaque pairs of bytes =
according
>> -	 * to the RFC.
>> -	 */
>> -	*(__le16 *)(ptr + 2) =3D cpu_to_le16(kctx->gk5e->signalg);
>> -	*(__le16 *)(ptr + 4) =3D cpu_to_le16(kctx->gk5e->sealalg);
>> -	ptr[6] =3D 0xff;
>> -	ptr[7] =3D 0xff;
>> -
>> -	gss_krb5_make_confounder(msg_start, conflen);
>> -
>> -	if (kctx->gk5e->keyed_cksum)
>> -		cksumkey =3D kctx->cksum;
>> -	else
>> -		cksumkey =3D NULL;
>> -
>> -	/* XXXJBF: UGH!: */
>> -	tmp_pages =3D buf->pages;
>> -	buf->pages =3D pages;
>> -	if (make_checksum(kctx, ptr, 8, buf, offset + headlen - conflen,
>> -					cksumkey, KG_USAGE_SEAL, =
&md5cksum))
>> -		return GSS_S_FAILURE;
>> -	buf->pages =3D tmp_pages;
>> -
>> -	memcpy(ptr + GSS_KRB5_TOK_HDR_LEN, md5cksum.data, md5cksum.len);
>> -
>> -	seq_send =3D atomic_fetch_inc(&kctx->seq_send);
>> -
>> -	/* XXX would probably be more efficient to compute checksum
>> -	 * and encrypt at the same time: */
>> -	if ((krb5_make_seq_num(kctx, kctx->seq, kctx->initiate ? 0 : =
0xff,
>> -			       seq_send, ptr + GSS_KRB5_TOK_HDR_LEN, ptr =
+ 8)))
>> -		return GSS_S_FAILURE;
>> -
>> -	if (kctx->enctype =3D=3D ENCTYPE_ARCFOUR_HMAC) {
>> -		struct crypto_sync_skcipher *cipher;
>> -		int err;
>> -		cipher =3D =
crypto_alloc_sync_skcipher(kctx->gk5e->encrypt_name,
>> -						    0, 0);
>> -		if (IS_ERR(cipher))
>> -			return GSS_S_FAILURE;
>> -
>> -		krb5_rc4_setup_enc_key(kctx, cipher, seq_send);
>> -
>> -		err =3D gss_encrypt_xdr_buf(cipher, buf,
>> -					  offset + headlen - conflen, =
pages);
>> -		crypto_free_sync_skcipher(cipher);
>> -		if (err)
>> -			return GSS_S_FAILURE;
>> -	} else {
>> -		if (gss_encrypt_xdr_buf(kctx->enc, buf,
>> -					offset + headlen - conflen, =
pages))
>> -			return GSS_S_FAILURE;
>> -	}
>> -
>> -	return (kctx->endtime < now) ? GSS_S_CONTEXT_EXPIRED : =
GSS_S_COMPLETE;
>> -}
>> -
>> -static u32
>> -gss_unwrap_kerberos_v1(struct krb5_ctx *kctx, int offset, struct =
xdr_buf *buf)
>> -{
>> -	int			signalg;
>> -	int			sealalg;
>> -	char			cksumdata[GSS_KRB5_MAX_CKSUM_LEN];
>> -	struct xdr_netobj	md5cksum =3D {.len =3D =
sizeof(cksumdata),
>> -					    .data =3D cksumdata};
>> -	s32			now;
>> -	int			direction;
>> -	s32			seqnum;
>> -	unsigned char		*ptr;
>> -	int			bodysize;
>> -	void			*data_start, *orig_start;
>> -	int			data_len;
>> -	int			blocksize;
>> -	u32			conflen =3D kctx->gk5e->conflen;
>> -	int			crypt_offset;
>> -	u8			*cksumkey;
>> -
>> -	dprintk("RPC:       gss_unwrap_kerberos\n");
>> -
>> -	ptr =3D (u8 *)buf->head[0].iov_base + offset;
>> -	if (g_verify_token_header(&kctx->mech_used, &bodysize, &ptr,
>> -					buf->len - offset))
>> -		return GSS_S_DEFECTIVE_TOKEN;
>> -
>> -	if ((ptr[0] !=3D ((KG_TOK_WRAP_MSG >> 8) & 0xff)) ||
>> -	    (ptr[1] !=3D  (KG_TOK_WRAP_MSG & 0xff)))
>> -		return GSS_S_DEFECTIVE_TOKEN;
>> -
>> -	/* XXX sanity-check bodysize?? */
>> -
>> -	/* get the sign and seal algorithms */
>> -
>> -	signalg =3D ptr[2] + (ptr[3] << 8);
>> -	if (signalg !=3D kctx->gk5e->signalg)
>> -		return GSS_S_DEFECTIVE_TOKEN;
>> -
>> -	sealalg =3D ptr[4] + (ptr[5] << 8);
>> -	if (sealalg !=3D kctx->gk5e->sealalg)
>> -		return GSS_S_DEFECTIVE_TOKEN;
>> -
>> -	if ((ptr[6] !=3D 0xff) || (ptr[7] !=3D 0xff))
>> -		return GSS_S_DEFECTIVE_TOKEN;
>> -
>> -	/*
>> -	 * Data starts after token header and checksum.  ptr points
>> -	 * to the beginning of the token header
>> -	 */
>> -	crypt_offset =3D ptr + (GSS_KRB5_TOK_HDR_LEN + =
kctx->gk5e->cksumlength) -
>> -					(unsigned char =
*)buf->head[0].iov_base;
>> -
>> -	/*
>> -	 * Need plaintext seqnum to derive encryption key for =
arcfour-hmac
>> -	 */
>> -	if (krb5_get_seq_num(kctx, ptr + GSS_KRB5_TOK_HDR_LEN,
>> -			     ptr + 8, &direction, &seqnum))
>> -		return GSS_S_BAD_SIG;
>> -
>> -	if ((kctx->initiate && direction !=3D 0xff) ||
>> -	    (!kctx->initiate && direction !=3D 0))
>> -		return GSS_S_BAD_SIG;
>> -
>> -	if (kctx->enctype =3D=3D ENCTYPE_ARCFOUR_HMAC) {
>> -		struct crypto_sync_skcipher *cipher;
>> -		int err;
>> -
>> -		cipher =3D =
crypto_alloc_sync_skcipher(kctx->gk5e->encrypt_name,
>> -						    0, 0);
>> -		if (IS_ERR(cipher))
>> -			return GSS_S_FAILURE;
>> -
>> -		krb5_rc4_setup_enc_key(kctx, cipher, seqnum);
>> -
>> -		err =3D gss_decrypt_xdr_buf(cipher, buf, crypt_offset);
>> -		crypto_free_sync_skcipher(cipher);
>> -		if (err)
>> -			return GSS_S_DEFECTIVE_TOKEN;
>> -	} else {
>> -		if (gss_decrypt_xdr_buf(kctx->enc, buf, crypt_offset))
>> -			return GSS_S_DEFECTIVE_TOKEN;
>> -	}
>> -
>> -	if (kctx->gk5e->keyed_cksum)
>> -		cksumkey =3D kctx->cksum;
>> -	else
>> -		cksumkey =3D NULL;
>> -
>> -	if (make_checksum(kctx, ptr, 8, buf, crypt_offset,
>> -					cksumkey, KG_USAGE_SEAL, =
&md5cksum))
>> -		return GSS_S_FAILURE;
>> -
>> -	if (memcmp(md5cksum.data, ptr + GSS_KRB5_TOK_HDR_LEN,
>> -						=
kctx->gk5e->cksumlength))
>> -		return GSS_S_BAD_SIG;
>> -
>> -	/* it got through unscathed.  Make sure the context is unexpired =
*/
>> -
>> -	now =3D get_seconds();
>> -
>> -	if (now > kctx->endtime)
>> -		return GSS_S_CONTEXT_EXPIRED;
>> -
>> -	/* do sequencing checks */
>> -
>> -	/* Copy the data back to the right position.  XXX: Would =
probably be
>> -	 * better to copy and encrypt at the same time. */
>> -
>> -	blocksize =3D crypto_sync_skcipher_blocksize(kctx->enc);
>> -	data_start =3D ptr + (GSS_KRB5_TOK_HDR_LEN + =
kctx->gk5e->cksumlength) +
>> -					conflen;
>> -	orig_start =3D buf->head[0].iov_base + offset;
>> -	data_len =3D (buf->head[0].iov_base + buf->head[0].iov_len) - =
data_start;
>> -	memmove(orig_start, data_start, data_len);
>> -	buf->head[0].iov_len -=3D (data_start - orig_start);
>> -	buf->len -=3D (data_start - orig_start);
>> -
>> -	if (gss_krb5_remove_padding(buf, blocksize))
>> -		return GSS_S_DEFECTIVE_TOKEN;
>> -
>> -	return GSS_S_COMPLETE;
>> -}
>> -
>> /*
>> * We can shift data by up to LOCAL_BUF_LEN bytes in a pass.  If we =
need
>> * to do more than that, we shift repeatedly.  Kevin Coffman reports
>> @@ -588,15 +350,11 @@ static void rotate_left(u32 base, struct =
xdr_buf *buf, unsigned int shift)
>> 	struct krb5_ctx	*kctx =3D gctx->internal_ctx_id;
>>=20
>> 	switch (kctx->enctype) {
>> -	default:
>> -		BUG();
>> -	case ENCTYPE_DES_CBC_RAW:
>> -	case ENCTYPE_DES3_CBC_RAW:
>> -	case ENCTYPE_ARCFOUR_HMAC:
>> -		return gss_wrap_kerberos_v1(kctx, offset, buf, pages);
>> 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
>> 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
>> 		return gss_wrap_kerberos_v2(kctx, offset, buf, pages);
>> +	default:
>> +		return GSS_S_FAILURE;
>> 	}
>> }
>>=20
>> @@ -606,14 +364,10 @@ static void rotate_left(u32 base, struct =
xdr_buf *buf, unsigned int shift)
>> 	struct krb5_ctx	*kctx =3D gctx->internal_ctx_id;
>>=20
>> 	switch (kctx->enctype) {
>> -	default:
>> -		BUG();
>> -	case ENCTYPE_DES_CBC_RAW:
>> -	case ENCTYPE_DES3_CBC_RAW:
>> -	case ENCTYPE_ARCFOUR_HMAC:
>> -		return gss_unwrap_kerberos_v1(kctx, offset, buf);
>> 	case ENCTYPE_AES128_CTS_HMAC_SHA1_96:
>> 	case ENCTYPE_AES256_CTS_HMAC_SHA1_96:
>> 		return gss_unwrap_kerberos_v2(kctx, offset, buf);
>> +	default:
>> +		return GSS_S_FAILURE;
>> 	}
>> }
>>=20
>=20
> --
> Chuck Lever

--
Chuck Lever



