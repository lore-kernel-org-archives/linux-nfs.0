Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83F3DC10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 21:31:55 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4471A20857
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 21:31:55 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="EjTZJnfj"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726741AbfDHVby (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 17:31:54 -0400
Received: from userp2130.oracle.com ([156.151.31.86]:57776 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726349AbfDHVby (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Apr 2019 17:31:54 -0400
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x38LTK4O089548;
        Mon, 8 Apr 2019 21:31:50 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=edw9ZaemIui69KcxQi6FSyIUYq39c6ZKv35hxaRxwLQ=;
 b=EjTZJnfjLN5nHJUuFxuEGgF1ZV+naHnxMpJDVGXZGvx0eP0ZD0CVLPbNgHHwHCfvFNCa
 RUug2VAG4dEhVcR+iOFS3EB/agOsqd0RYzbRuW2geeh7OgSpLMX9ohOJ0ObrOhm6k9+7
 UC9lB2ismWErmy7nDL5kgYLNkexnlHFm5pd9NRu9VAqN27eztsAt29AVAa1nK0xFL1Ct
 fM9oXqL5nb8DzHOWq5Q718d4jgA2aHty7cyIHatlMAehLowCWXG7DfV7AxYGPjLz+W8a
 JS0VLHqvhaOdDfFpaxvrv7GXGZetAz6hgVEIsTCGugLge38QWUUoHELxNVZL9ISJD19r Gw== 
Received: from aserp3030.oracle.com (aserp3030.oracle.com [141.146.126.71])
        by userp2130.oracle.com with ESMTP id 2rpkhss8u8-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 08 Apr 2019 21:31:50 +0000
Received: from pps.filterd (aserp3030.oracle.com [127.0.0.1])
        by aserp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x38LTWoj071287;
        Mon, 8 Apr 2019 21:29:49 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserp3030.oracle.com with ESMTP id 2rpj5a776f-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 08 Apr 2019 21:29:49 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x38LTjxK022749;
        Mon, 8 Apr 2019 21:29:48 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 08 Apr 2019 14:29:45 -0700
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v1] NFS: Fix handling of reply page vector
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <aa8a63d9bfc6d76800ef00bfa3b6921e312cfd44.camel@hammerspace.com>
Date:   Mon, 8 Apr 2019 17:29:43 -0400
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Olga Kornievskaia <kolga@netapp.com>
Content-Transfer-Encoding: quoted-printable
Message-Id: <09085DBD-FFBD-4ACD-86CE-428F49916F61@oracle.com>
References: <20190408200030.16366.22026.stgit@manet.1015granger.net>
 <bede7559be11f283e9f37db2da0b47ddf869a468.camel@hammerspace.com>
 <B28ACEA4-BB35-4137-A81F-50A1D2974F6A@oracle.com>
 <aa8a63d9bfc6d76800ef00bfa3b6921e312cfd44.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9221 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904080157
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9221 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904080157
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Apr 8, 2019, at 5:23 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Mon, 2019-04-08 at 16:58 -0400, Chuck Lever wrote:
>>> On Apr 8, 2019, at 4:38 PM, Trond Myklebust <
>>> trondmy@hammerspace.com> wrote:
>>>=20
>>> On Mon, 2019-04-08 at 16:00 -0400, Chuck Lever wrote:
>>>> NFSv4 GETACL and FS_LOCATIONS requests stopped working in v5.1-
>>>> rc.
>>>>=20
>>>> These two need the extra padding to be added directly to the
>>>> reply
>>>> length.
>>>>=20
>>>> Reported-by: Olga Kornievskaia <aglo@umich.edu>
>>>> Fixes: 02ef04e432ba ("NFS: Account for XDR pad of buf->pages")
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> fs/nfs/nfs4xdr.c |    4 ++--
>>>> 1 file changed, 2 insertions(+), 2 deletions(-)
>>>>=20
>>>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>>>> index cfcabc3..6024461 100644
>>>> --- a/fs/nfs/nfs4xdr.c
>>>> +++ b/fs/nfs/nfs4xdr.c
>>>> @@ -2589,7 +2589,7 @@ static void nfs4_xdr_enc_getacl(struct
>>>> rpc_rqst
>>>> *req, struct xdr_stream *xdr,
>>>> 			ARRAY_SIZE(nfs4_acl_bitmap), &hdr);
>>>>=20
>>>> 	rpc_prepare_reply_pages(req, args->acl_pages, 0,
>>>> -				args->acl_len, replen);
>>>> +				args->acl_len, replen + 1);
>>>> 	encode_nops(&hdr);
>>>> }
>>>>=20
>>>> @@ -2811,7 +2811,7 @@ static void
>>>> nfs4_xdr_enc_fs_locations(struct
>>>> rpc_rqst *req,
>>>> 	}
>>>>=20
>>>> 	rpc_prepare_reply_pages(req, (struct page **)&args->page, 0,
>>>> -				PAGE_SIZE, replen);
>>>> +				PAGE_SIZE, replen + 1);
>>>> 	encode_nops(&hdr);
>>>> }
>>>>=20
>>>=20
>>> I'm having trouble with the math here. Why are we pre-emptively
>>> subtracting a word from the tail? The header constants are always
>>> 4-bit=20
>>> aligned because they are calculated as a word count, so I'm not
>>> understanding why we need commit 02ef04e432ba at all.
>>>=20
>>> Can you please explain, Chuck?
>>=20
>> The goal is to allocate a reply buffer that is just large enough
>> to fit the expected reply, and ensure that the variable-length
>> payload will start exactly where the xdr_buf's pages begin.
>>=20
>> In cases where the payload length is not aligned to four bytes,
>> an extra quad has to be allocated in the tail. So, the total
>> reply length is increased by one quad so there is enough space
>> for the XDR pad bytes in the tail.
>>=20
> Right, but we should never hit that problem because the proc->p_arglen
> and proc->p_replen are always in units of 32-bit words.

But buf->pages aren't. The point is to accommodate XDR padding
of the data payload, which goes into the page cache. You want
just the data to go into the page cache, and the padding to
land in the tail.


> IOW: the functions that allocate memory, will always do so in full
> words, hence it should not be necessary for xdr_inline_pages() to
> adjust that allocation.
>=20
> The one thing that we _might_ want to do if we're to do anything at =
all
> is to perhaps adjust tail->iov_base by (xdr->page_len & 3) bytes to
> ensure that we have word-aligned data in the tail.
>=20
> i.e. capture the padding in the remaining bytes in that first word, so
> that xdr_read_pages() sets word aligned values for xdr->p and =
xdr->end.

I'm in favor of hiding the details of that in the generic
XDR code, and I probably should have taken that step in
02ef04e432ba.

So I think we should add a quad to the tail whenever the
expected size of the data payload (ie, payload that goes into
the page cache) is going to be non-word aligned. Otherwise
the tail doesn't need that space. In those cases, the tail
can be eliminated.

The reason to do that is that then the RDMA transport does
not need to register a 4-byte memory region for the XDR
padding.


--
Chuck Lever



