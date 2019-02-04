Return-Path: <SRS0=dgFe=QL=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D7BC0C282C4
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 19:49:18 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9AC442087C
	for <linux-nfs@archiver.kernel.org>; Mon,  4 Feb 2019 19:49:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="kNjqsyhY"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726242AbfBDTtR (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 4 Feb 2019 14:49:17 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:58624 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725854AbfBDTtR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Feb 2019 14:49:17 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x14JiH3Z131995;
        Mon, 4 Feb 2019 19:49:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=0ArmlwnYgxvZFXAFm6EVd3ztFlJvvozUKJci/1iSRP8=;
 b=kNjqsyhYxI01490fugGBIAnx65ZYCqoEEc7lmGrlnuSCckhyTgOOQL0uGu4Hcmuia8Us
 A7SQxLlmDcVHZUjajD+r/hYF4F3M18Z6N4sTSfOvNDUYgHc4aCojZNwuzRem8f/CQPl9
 aOFep5X6n9mlYKczlsLVgc2pBUCrVjtrOsvMXu/6PCNo1ua6TJQR1Ior6ovGLH/N2oic
 tYkdbc67F7sPNBZJ9GY+kR63H352Je/wln/DMWPfww6ZGjHvHuNEoH7G1fmZ3JLWPLyq
 Nvu20n9qWa4DTQoC5bcbVFbpPtSkEMImKPYeAWPR4s22rEEXScfuvYlRQkFdk9k61HOC Jw== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2130.oracle.com with ESMTP id 2qd9ar78u4-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 04 Feb 2019 19:49:13 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x14JnC85025289
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 4 Feb 2019 19:49:13 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x14JnCkE008858;
        Mon, 4 Feb 2019 19:49:12 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 04 Feb 2019 19:49:12 +0000
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC 09/10] SUNRPC: Remove xdr_buf_trim()
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190204194615.GC1816@fieldses.org>
Date:   Mon, 4 Feb 2019 14:49:11 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>, simo@redhat.com
Content-Transfer-Encoding: quoted-printable
Message-Id: <014F38E7-993C-4FD6-A8C6-9FE113A54A03@oracle.com>
References: <20190201195538.11389.96106.stgit@manet.1015granger.net>
 <20190201195814.11389.4023.stgit@manet.1015granger.net>
 <20190204194615.GC1816@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9157 signatures=668682
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902040151
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 4, 2019, at 2:46 PM, bfields@fieldses.org wrote:
>=20
> On Fri, Feb 01, 2019 at 02:58:14PM -0500, Chuck Lever wrote:
>> The key action of xdr_buf_trim() is that it shortens buf->len, the
>> length of the xdr_buf' content. The other actions -- shortening the
>> head, pages, and tail components -- are actually not necessary. In
>> some cases, changing the size of those components corrupts the RPC
>> message contained in the buffer.
>=20
> That's really burying the lede.... Is there an actual user-visible bug
> here?

I don't think so. This is more of the form:

a) the function does fundamentally the wrong thing, so

b) certain changes to this code path result is unexpected and incorrect
   behavior

Thus typically only developers hacking on this code run into a problem.


> --b.
>=20
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/linux/sunrpc/xdr.h          |    1 -
>> net/sunrpc/auth_gss/gss_krb5_wrap.c |    8 ++++---
>> net/sunrpc/auth_gss/svcauth_gss.c   |    2 +-
>> net/sunrpc/xdr.c                    |   41 =
-----------------------------------
>> 4 files changed, 6 insertions(+), 46 deletions(-)
>>=20
>> diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
>> index 69161cb..4ae398c 100644
>> --- a/include/linux/sunrpc/xdr.h
>> +++ b/include/linux/sunrpc/xdr.h
>> @@ -183,7 +183,6 @@ static inline __be32 *xdr_encode_array(__be32 *p, =
const void *s, unsigned int le
>> extern void xdr_shift_buf(struct xdr_buf *, size_t);
>> extern void xdr_buf_from_iov(struct kvec *, struct xdr_buf *);
>> extern int xdr_buf_subsegment(struct xdr_buf *, struct xdr_buf *, =
unsigned int, unsigned int);
>> -extern void xdr_buf_trim(struct xdr_buf *, unsigned int);
>> extern int xdr_buf_read_netobj(struct xdr_buf *, struct xdr_netobj *, =
unsigned int);
>> extern int read_bytes_from_xdr_buf(struct xdr_buf *, unsigned int, =
void *, unsigned int);
>> extern int write_bytes_to_xdr_buf(struct xdr_buf *, unsigned int, =
void *, unsigned int);
>> diff --git a/net/sunrpc/auth_gss/gss_krb5_wrap.c =
b/net/sunrpc/auth_gss/gss_krb5_wrap.c
>> index 5cdde6c..14a0aff 100644
>> --- a/net/sunrpc/auth_gss/gss_krb5_wrap.c
>> +++ b/net/sunrpc/auth_gss/gss_krb5_wrap.c
>> @@ -570,14 +570,16 @@ static void rotate_left(u32 base, struct =
xdr_buf *buf, unsigned int shift)
>> 	 */
>> 	movelen =3D min_t(unsigned int, buf->head[0].iov_len, buf->len);
>> 	movelen -=3D offset + GSS_KRB5_TOK_HDR_LEN + headskip;
>> -	BUG_ON(offset + GSS_KRB5_TOK_HDR_LEN + headskip + movelen >
>> -							=
buf->head[0].iov_len);
>> +	if (offset + GSS_KRB5_TOK_HDR_LEN + headskip + movelen >
>> +	    buf->head[0].iov_len)
>> +		return GSS_S_FAILURE;
>> 	memmove(ptr, ptr + GSS_KRB5_TOK_HDR_LEN + headskip, movelen);
>> 	buf->head[0].iov_len -=3D GSS_KRB5_TOK_HDR_LEN + headskip;
>> 	buf->len -=3D GSS_KRB5_TOK_HDR_LEN + headskip;
>>=20
>> 	/* Trim off the trailing "extra count" and checksum blob */
>> -	xdr_buf_trim(buf, ec + GSS_KRB5_TOK_HDR_LEN + tailskip);
>> +	buf->len -=3D ec + GSS_KRB5_TOK_HDR_LEN + tailskip;
>> +
>> 	return GSS_S_COMPLETE;
>> }
>>=20
>> diff --git a/net/sunrpc/auth_gss/svcauth_gss.c =
b/net/sunrpc/auth_gss/svcauth_gss.c
>> index 152790e..f1aabab 100644
>> --- a/net/sunrpc/auth_gss/svcauth_gss.c
>> +++ b/net/sunrpc/auth_gss/svcauth_gss.c
>> @@ -896,7 +896,7 @@ u32 svcauth_gss_flavor(struct auth_domain *dom)
>> 	if (svc_getnl(&buf->head[0]) !=3D seq)
>> 		goto out;
>> 	/* trim off the mic and padding at the end before returning */
>> -	xdr_buf_trim(buf, round_up_to_quad(mic.len) + 4);
>> +	buf->len -=3D 4 + round_up_to_quad(mic.len);
>> 	stat =3D 0;
>> out:
>> 	kfree(mic.data);
>> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
>> index 5f0aa53..4bce619 100644
>> --- a/net/sunrpc/xdr.c
>> +++ b/net/sunrpc/xdr.c
>> @@ -1139,47 +1139,6 @@ void xdr_enter_page(struct xdr_stream *xdr, =
unsigned int len)
>> }
>> EXPORT_SYMBOL_GPL(xdr_buf_subsegment);
>>=20
>> -/**
>> - * xdr_buf_trim - lop at most "len" bytes off the end of "buf"
>> - * @buf: buf to be trimmed
>> - * @len: number of bytes to reduce "buf" by
>> - *
>> - * Trim an xdr_buf by the given number of bytes by fixing up the =
lengths. Note
>> - * that it's possible that we'll trim less than that amount if the =
xdr_buf is
>> - * too small, or if (for instance) it's all in the head and the =
parser has
>> - * already read too far into it.
>> - */
>> -void xdr_buf_trim(struct xdr_buf *buf, unsigned int len)
>> -{
>> -	size_t cur;
>> -	unsigned int trim =3D len;
>> -
>> -	if (buf->tail[0].iov_len) {
>> -		cur =3D min_t(size_t, buf->tail[0].iov_len, trim);
>> -		buf->tail[0].iov_len -=3D cur;
>> -		trim -=3D cur;
>> -		if (!trim)
>> -			goto fix_len;
>> -	}
>> -
>> -	if (buf->page_len) {
>> -		cur =3D min_t(unsigned int, buf->page_len, trim);
>> -		buf->page_len -=3D cur;
>> -		trim -=3D cur;
>> -		if (!trim)
>> -			goto fix_len;
>> -	}
>> -
>> -	if (buf->head[0].iov_len) {
>> -		cur =3D min_t(size_t, buf->head[0].iov_len, trim);
>> -		buf->head[0].iov_len -=3D cur;
>> -		trim -=3D cur;
>> -	}
>> -fix_len:
>> -	buf->len -=3D (len - trim);
>> -}
>> -EXPORT_SYMBOL_GPL(xdr_buf_trim);
>> -
>> static void __read_bytes_from_xdr_buf(struct xdr_buf *subbuf, void =
*obj, unsigned int len)
>> {
>> 	unsigned int this_len;

--
Chuck Lever



