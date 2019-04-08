Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E9364C10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 20:58:23 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A89FE20863
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 20:58:23 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="J1B7wlrO"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726464AbfDHU6X (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 16:58:23 -0400
Received: from userp2120.oracle.com ([156.151.31.85]:44964 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726437AbfDHU6X (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Apr 2019 16:58:23 -0400
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x38Kmw4O066041;
        Mon, 8 Apr 2019 20:58:18 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=yIwfN7ILQGsyZWhVRp62yxO18WMekbVzFZqlFbftIiM=;
 b=J1B7wlrOH9rNQlVfmZiC1XGBKRpNpSUs15kwtgJoB3pFfLTYeBhz5oJJj0hGwDC4m2MS
 mwIzM+0wISrcYMevqmIebvT1HKGvG4wq8iwb/OsjDbWFSYZAFhmhHiVDt1DSfiV0zRNo
 XpAS3339kb/kFccwE9AmPTDIJ3yyA38cOqOrwkEPgAOSWjTo6/2+KR5jHpJPCoqyc5pI
 Ba5B5dD0nqZmCLHexEuJ+JJgp3JarfyH/DlnjAO6YgIb3ltqzUoNrp8X8yXTZEPIHIBu
 Bpbiz4IPDgIIB+tY2ojPJZwY+nDN3sdy8hHa+5ozS1bRQ7oHgxoDrI67v+vekdR/lerO 1A== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
        by userp2120.oracle.com with ESMTP id 2rpmrq10wc-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 08 Apr 2019 20:58:18 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
        by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x38KwHpU002694;
        Mon, 8 Apr 2019 20:58:17 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserp3030.oracle.com with ESMTP id 2rpj5a6tam-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 08 Apr 2019 20:58:17 +0000
Received: from abhmp0017.oracle.com (abhmp0017.oracle.com [141.146.116.23])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x38KwF1B027720;
        Mon, 8 Apr 2019 20:58:16 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 08 Apr 2019 13:58:15 -0700
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v1] NFS: Fix handling of reply page vector
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <bede7559be11f283e9f37db2da0b47ddf869a468.camel@hammerspace.com>
Date:   Mon, 8 Apr 2019 16:58:13 -0400
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <B28ACEA4-BB35-4137-A81F-50A1D2974F6A@oracle.com>
References: <20190408200030.16366.22026.stgit@manet.1015granger.net>
 <bede7559be11f283e9f37db2da0b47ddf869a468.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9221 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904080155
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9221 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904080154
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Apr 8, 2019, at 4:38 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Mon, 2019-04-08 at 16:00 -0400, Chuck Lever wrote:
>> NFSv4 GETACL and FS_LOCATIONS requests stopped working in v5.1-rc.
>>=20
>> These two need the extra padding to be added directly to the reply
>> length.
>>=20
>> Reported-by: Olga Kornievskaia <aglo@umich.edu>
>> Fixes: 02ef04e432ba ("NFS: Account for XDR pad of buf->pages")
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> fs/nfs/nfs4xdr.c |    4 ++--
>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>=20
>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>> index cfcabc3..6024461 100644
>> --- a/fs/nfs/nfs4xdr.c
>> +++ b/fs/nfs/nfs4xdr.c
>> @@ -2589,7 +2589,7 @@ static void nfs4_xdr_enc_getacl(struct rpc_rqst
>> *req, struct xdr_stream *xdr,
>> 			ARRAY_SIZE(nfs4_acl_bitmap), &hdr);
>>=20
>> 	rpc_prepare_reply_pages(req, args->acl_pages, 0,
>> -				args->acl_len, replen);
>> +				args->acl_len, replen + 1);
>> 	encode_nops(&hdr);
>> }
>>=20
>> @@ -2811,7 +2811,7 @@ static void nfs4_xdr_enc_fs_locations(struct
>> rpc_rqst *req,
>> 	}
>>=20
>> 	rpc_prepare_reply_pages(req, (struct page **)&args->page, 0,
>> -				PAGE_SIZE, replen);
>> +				PAGE_SIZE, replen + 1);
>> 	encode_nops(&hdr);
>> }
>>=20
>=20
> I'm having trouble with the math here. Why are we pre-emptively
> subtracting a word from the tail? The header constants are always =
4-bit=20
> aligned because they are calculated as a word count, so I'm not
> understanding why we need commit 02ef04e432ba at all.
>=20
> Can you please explain, Chuck?

The goal is to allocate a reply buffer that is just large enough
to fit the expected reply, and ensure that the variable-length
payload will start exactly where the xdr_buf's pages begin.

In cases where the payload length is not aligned to four bytes,
an extra quad has to be allocated in the tail. So, the total
reply length is increased by one quad so there is enough space
for the XDR pad bytes in the tail.


--
Chuck Lever



