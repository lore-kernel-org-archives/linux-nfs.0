Return-Path: <SRS0=G+EE=N3=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.7 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A095C070C3
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 00:20:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C6A33208A3
	for <linux-nfs@archiver.kernel.org>; Fri, 16 Nov 2018 00:20:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="LpX10vxl"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C6A33208A3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389043AbeKPKaE (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 16 Nov 2018 05:30:04 -0500
Received: from aserp2120.oracle.com ([141.146.126.78]:50628 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725985AbeKPKaE (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Nov 2018 05:30:04 -0500
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAG0EJYh009361;
        Fri, 16 Nov 2018 00:19:55 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=FyOez9G5SoQfvtNg1znU/4PERACCD9aXIJIdVKo1T2s=;
 b=LpX10vxlVdOw0McU/PQyZpAkfmT57pkuo6pk65W0tnHnGdm1rcVF/wvKJA8eXzXf4DJb
 JhpMw9oIg2rkX1JU+3CByhjyNf84+8Ywt2Q8xhx0v0OatbJhJ3rTiaNauu+xxU4NWnd4
 dUcyjZbmqSJ2G72iu7kyFsv/WVl2mmHeksLvwq/Vpqkexo6SBXYhTVMKLQKf6Eg1cklo
 LlibcPIttQBK4AGhsIyYemZL6teeyv+SxlIGyQQwPfKP3A4J+zofxK7aH0+2jhEwnt6g
 uGVPSw5zeWw4tC7+ziSvnxLZq4iHNBMY7pHz6W+VWu7+BJOVQPNG3w5XyK11A3SgMbHb nA== 
Received: from userv0022.oracle.com (userv0022.oracle.com [156.151.31.74])
        by aserp2120.oracle.com with ESMTP id 2nr7csch6c-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 16 Nov 2018 00:19:55 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by userv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wAG0JsUX017575
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 16 Nov 2018 00:19:54 GMT
Received: from abhmp0018.oracle.com (abhmp0018.oracle.com [141.146.116.24])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wAG0JsND012509;
        Fri, 16 Nov 2018 00:19:54 GMT
Received: from [192.168.32.39] (/64.114.255.114)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Thu, 15 Nov 2018 16:19:54 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v1 3/4] NFSD: Refactor the generic write vector fill
 helper
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181115163246.GB9022@fieldses.org>
Date:   Thu, 15 Nov 2018 16:19:52 -0800
Cc:     linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <A6FEE9E7-0226-460F-AA3E-42D7CEE9A781@oracle.com>
References: <20180727142007.21878.77494.stgit@klimt.1015granger.net>
 <20180727151905.21878.62693.stgit@klimt.1015granger.net>
 <20181115163246.GB9022@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9078 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811160000
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 15, 2018, at 8:32 AM, J. Bruce Fields <bfields@fieldses.org> =
wrote:
>=20
> Um, I somehow managed to overlook a pynfs regression till just now:
>=20
> On Fri, Jul 27, 2018 at 11:19:05AM -0400, Chuck Lever wrote:
>> fill_in_write_vector() is nearly the same logic as
>> svc_fill_write_vector(), but there are a few differences so that
>> the former can handle multiple WRITE payloads in a single COMPOUND.
>>=20
>> svc_fill_write_vector() can be adjusted so that it can be used in
>> the NFSv4 WRITE code path too. Instead of assuming the pages are
>> coming from rq_args.pages, have the caller pass in the page list.
>>=20
>> The immediate benefit is a reduction of code duplication. It also
>> prevents the NFSv4 WRITE decoder from passing an empty vector
>> element when the transport has provided the payload in the xdr_buf's
>> page array.
>>=20
> ...
>> @@ -1027,7 +1009,10 @@ static int fill_in_write_vector(struct kvec =
*vec, struct nfsd4_write *write)
>> 	write->wr_how_written =3D write->wr_stable_how;
>> 	gen_boot_verifier(&write->wr_verifier, SVC_NET(rqstp));
>>=20
>> -	nvecs =3D fill_in_write_vector(rqstp->rq_vec, write);
>> +	nvecs =3D svc_fill_write_vector(rqstp, write->wr_pagelist,
>> +				      &write->wr_head, =
write->wr_buflen);
>> +	if (!nvecs)
>> +		return nfserr_io;
>=20
> Do you remember why you added this check?

Yes, at one point svc_fill_write_vector() called the transport
layer to do some processing, and I needed a way for it to
indicate a graceful failure.


> It's causing zero-length writes to fail, in violation of the spec:
>=20
> 	"If the count is zero, the WRITE will succeed and return a count
> 	of zero subject to permissions checking."

RFC 7530, Section 16.36.4.


> I'm not seeing a reason why it wouldn't be safe just to remove that
> check.

Or, make the check more specific:

	if (!nvecs && write->wr_buflen)
		return nfserr_io;

This is a little more bullet proof, in case of bugs in the
transport layer.


> --b.
>=20
>> 	WARN_ON_ONCE(nvecs > ARRAY_SIZE(rqstp->rq_vec));
>>=20
>> 	status =3D nfsd_vfs_write(rqstp, &cstate->current_fh, filp,
>> diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
>> index f107f9f..a6faee5 100644
>> --- a/fs/nfsd/nfsproc.c
>> +++ b/fs/nfsd/nfsproc.c
>> @@ -218,7 +218,8 @@
>> 		SVCFH_fmt(&argp->fh),
>> 		argp->len, argp->offset);
>>=20
>> -	nvecs =3D svc_fill_write_vector(rqstp, &argp->first, cnt);
>> +	nvecs =3D svc_fill_write_vector(rqstp, rqstp->rq_arg.pages,
>> +				      &argp->first, cnt);
>> 	if (!nvecs)
>> 		return nfserr_io;
>> 	nfserr =3D nfsd_write(rqstp, fh_copy(&resp->fh, &argp->fh),
>> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>> index 574368e..43f88bd 100644
>> --- a/include/linux/sunrpc/svc.h
>> +++ b/include/linux/sunrpc/svc.h
>> @@ -496,6 +496,7 @@ int		   svc_register(const struct =
svc_serv *, struct net *, const int,
>> struct svc_pool *  svc_pool_for_cpu(struct svc_serv *serv, int cpu);
>> char *		   svc_print_addr(struct svc_rqst *, char *, =
size_t);
>> unsigned int	   svc_fill_write_vector(struct svc_rqst *rqstp,
>> +					 struct page **pages,
>> 					 struct kvec *first, size_t =
total);
>> char		  *svc_fill_symlink_pathname(struct svc_rqst *rqstp,
>> 					     struct kvec *first, size_t =
total);
>> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> index 30a4226..2194ed5 100644
>> --- a/net/sunrpc/svc.c
>> +++ b/net/sunrpc/svc.c
>> @@ -1537,16 +1537,16 @@ u32 svc_max_payload(const struct svc_rqst =
*rqstp)
>> /**
>>  * svc_fill_write_vector - Construct data argument for VFS write call
>>  * @rqstp: svc_rqst to operate on
>> + * @pages: list of pages containing data payload
>>  * @first: buffer containing first section of write payload
>>  * @total: total number of bytes of write payload
>>  *
>> - * Returns the number of elements populated in the data argument =
array.
>> + * Fills in rqstp::rq_vec, and returns the number of elements.
>>  */
>> -unsigned int svc_fill_write_vector(struct svc_rqst *rqstp, struct =
kvec *first,
>> -				   size_t total)
>> +unsigned int svc_fill_write_vector(struct svc_rqst *rqstp, struct =
page **pages,
>> +				   struct kvec *first, size_t total)
>> {
>> 	struct kvec *vec =3D rqstp->rq_vec;
>> -	struct page **pages;
>> 	unsigned int i;
>>=20
>> 	/* Some types of transport can present the write payload
>> @@ -1560,14 +1560,11 @@ unsigned int svc_fill_write_vector(struct =
svc_rqst *rqstp, struct kvec *first,
>> 		++i;
>> 	}
>>=20
>> -	WARN_ON_ONCE(rqstp->rq_arg.page_base !=3D 0);
>> -	pages =3D rqstp->rq_arg.pages;
>> 	while (total) {
>> 		vec[i].iov_base =3D page_address(*pages);
>> 		vec[i].iov_len =3D min_t(size_t, total, PAGE_SIZE);
>> 		total -=3D vec[i].iov_len;
>> 		++i;
>> -
>> 		++pages;
>> 	}
>>=20

--
Chuck Lever



