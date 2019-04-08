Return-Path: <SRS0=JsnX=SK=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6AE58C10F13
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 16:30:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 26A102087F
	for <linux-nfs@archiver.kernel.org>; Mon,  8 Apr 2019 16:30:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="ZTg56458"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728675AbfDHQaJ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 8 Apr 2019 12:30:09 -0400
Received: from userp2120.oracle.com ([156.151.31.85]:51362 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726774AbfDHQaJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Apr 2019 12:30:09 -0400
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x38GNpqC025956;
        Mon, 8 Apr 2019 16:29:59 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=waBsrDBLlRsyfGuKCRmpN+FNzlIjrlVbOdwmHpvjjuc=;
 b=ZTg564580WASzJ90X7m+9MIMbERItQYYHTykwob6Su+RU0xHLkYpWD57y9jKFZXSTLqa
 1l0UbklJ5giTt7GpJSjcpjs9NgxUIp9b4cTbkGmkheQ7LOqF+C6Rpg2qBpxmkjEFpcad
 YiLTO8MDe7fGlKcN5KzGsI1WIkKmC2xhq+ctgwwROLbWcItP7bSy7SyjDClF0zNtfcdg
 mqAEoFtYXF6UW+dvIsr9g63tUKV0c/GE4mEyfFezvCozxPupb8Vcveiv0Dj+0QUfVV3P
 yelNBtCpyi6aWndTN3aEgAgERbnbfRL1/1l92zrZ6V68H3OtGUd52mT/29647utCh2Cu Zw== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
        by userp2120.oracle.com with ESMTP id 2rpmrpyj40-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 08 Apr 2019 16:29:59 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
        by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x38GTbxQ002126;
        Mon, 8 Apr 2019 16:29:58 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserp3020.oracle.com with ESMTP id 2rpytb4urn-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 08 Apr 2019 16:29:58 +0000
Received: from abhmp0020.oracle.com (abhmp0020.oracle.com [141.146.116.26])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x38GTub9018806;
        Mon, 8 Apr 2019 16:29:56 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 08 Apr 2019 09:29:56 -0700
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH v1 20/23] NFS: Account for XDR pad of buf->pages
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyEqrJc94gdoosH+O4xB+hcJ3MDBUJEbnc1HRxnbKOgPHQ@mail.gmail.com>
Date:   Mon, 8 Apr 2019 12:29:54 -0400
Cc:     Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <20382EFB-6E21-41F9-BDAD-BEA0F2279C0A@oracle.com>
References: <20190211161920.2817.20881.stgit@manet.1015granger.net>
 <20190211162525.2817.60645.stgit@manet.1015granger.net>
 <CAN-5tyH1zAuW7AxoZc+psRWWQT0S9J3wDu+iDgLg4=qGTvUufA@mail.gmail.com>
 <0157F163-7554-413C-ACCA-FE6646C04716@oracle.com>
 <CAN-5tyHSH75TVSok+RXdXoq6bOVse__E4AMCzuSnmYrTgzH_Vg@mail.gmail.com>
 <5AC0653D-3D4E-4C0C-BFE3-616BF32589CB@oracle.com>
 <CAN-5tyFN90xdKBvFmH2kYa2gQtW2EmVa59Q+w=M4yvHR9euuVQ@mail.gmail.com>
 <19341226-AE0F-4C94-B7CD-AE14CCB456AF@oracle.com>
 <CAN-5tyE6rgj90=bCcX82fW34i1SNSSLcLVHbjBo5dmQaXzoTwA@mail.gmail.com>
 <1E4939AD-F0AE-47EF-81E2-B919FB203B76@oracle.com>
 <CAN-5tyGtStnutmCk20Kug4FP_TWYFE5ZG3sLbDDjaVQbZnEWGA@mail.gmail.com>
 <CAN-5tyGKVdj-Ds3pt=Uv6+=kaTfBR5kxAm3x8e5_4GrU=ff1kw@mail.gmail.com>
 <CAN-5tyEqrJc94gdoosH+O4xB+hcJ3MDBUJEbnc1HRxnbKOgPHQ@mail.gmail.com>
To:     Olga Kornievskaia <aglo@umich.edu>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9221 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904080133
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9221 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904080133
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Apr 8, 2019, at 11:50 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> On Mon, Apr 8, 2019 at 11:26 AM Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>=20
>> On Mon, Apr 8, 2019 at 11:21 AM Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>=20
>>> On Mon, Apr 8, 2019 at 10:43 AM Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>>>=20
>>>>=20
>>>>=20
>>>>> On Apr 8, 2019, at 10:36 AM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>>=20
>>>>> On Fri, Apr 5, 2019 at 3:42 PM Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>>=20
>>>>>>=20
>>>>>>=20
>>>>>>> On Apr 5, 2019, at 3:27 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>>>>=20
>>>>>>> On Fri, Apr 5, 2019 at 3:23 PM Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>> On Apr 5, 2019, at 3:17 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>>>>>>=20
>>>>>>>>> On Fri, Apr 5, 2019 at 1:51 PM Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>>>>>>=20
>>>>>>>>>>=20
>>>>>>>>>>=20
>>>>>>>>>>> On Apr 5, 2019, at 1:36 PM, Olga Kornievskaia =
<aglo@umich.edu> wrote:
>>>>>>>>>>>=20
>>>>>>>>>>> Hi Chuck,
>>>>>>>>>>>=20
>>>>>>>>>>> This patch break ACLs. After applying this patch =
nfs4_getfacl fails
>>>>>>>>>>> (it fails within xdr and returns ENOTSUPP). Any ideas why?
>>>>>>>>>>=20
>>>>>>>>>> Possibly the macro that defines the maximum size of the reply
>>>>>>>>>> is incorrect.
>>>>>>>>>>=20
>>>>>>>>>=20
>>>>>>>>> This also breaks FS_LOCATION. I'm going to go on the limb here =
and say
>>>>>>>>> that it probably breaks whatever else it modified.
>>>>>>>>=20
>>>>>>>> It modifies READ, READDIR, and READLINK. Are those broken?
>>>>>>>=20
>>>>>>> I don't know how to test READLINK.. but I think READ/READDIR =
work OK
>>>>>>> otherwise folks would have noticed it (I gather ACL and =
FS_LOCATION
>>>>>>> testing doesn't happen frequently).
>>>>>>=20
>>>>>> I guess I don't have any NFSv4 ACL or FS_LOCATIONS regressions
>>>>>> tests in my automated unit tests.
>>>>>>=20
>>>>>>=20
>>>>>>>>> The question is: can't we just revert it??
>>>>>>>>=20
>>>>>>>> Why not "root cause" it first?
>>>>>>>=20
>>>>>>> I'm trying :-/ I was just fishing to see how important the =
change was.
>>>>>>=20
>>>>>> Try reverting just this hunk:
>>>>>=20
>>>>> That doesn't help. It seems to be this piece that's causing issues
>>>>> hdrsize +=3D RPC_REPHDRSIZE + req->rq_cred->cr_auth->au_rslack - 1
>>>>>=20
>>>>> With this there is an extra byte (in front) in the buffer when =
(ACL)
>>>>> operation is decoded.
>>>>=20
>>>> How do you know there isn't a latent bug in the getfacl decoder?
>>>=20
>>> I don't. All I know is that it passed tests before and now it =
doesn't.
>>=20
>> Also this bug will have to be in both getfacl and fs_location code.
>> What they both share is xd_enter_page() code that now with new
>> semantics makes the buffer point to the wrong place.
>>=20
>>>> How are you reproducing this issue? I can try it here later today.
>>>=20
>>> The issue was found running xfstest nfs/001. However, you don't need
>>> that: (1) mount (2) nfs4_getfacl <file>
>>>=20
>>> To understand a patch, does it fix a problem with READLINK or is the
>>> an optimization?
>=20
> So this "fixes" it but this don't look really good.
>=20
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index cfcabc3..f2a5553 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
>=20
> @@ -5280,6 +5280,7 @@ static int decode_getacl(struct xdr_stream *xdr,
> struct rpc_rqst *req,
>  goto out;
>  xdr_enter_page(xdr, xdr->buf->page_len);
> + xdr->p++;
>=20
>  /* Calculate the offset of the page data */
>  pg_offset =3D xdr->buf->head[0].iov_len;
> @@ -6949,6 +6950,7 @@ static int nfs4_xdr_dec_fs_locations(struct =
rpc_rqst *req,
>  goto out;
>  if (res->migration) {
>  xdr_enter_page(xdr, PAGE_SIZE);
> + xdr->p++;
>  status =3D decode_getfattr_generic(xdr,
>  &res->fs_locations->fattr,
>  NULL, res->fs_locations,
> @@ -6962,6 +6964,7 @@ static int nfs4_xdr_dec_fs_locations(struct =
rpc_rqst *req,
>  if (status)
>  goto out;
>  xdr_enter_page(xdr, PAGE_SIZE);
> + xdr->p++;
>  status =3D decode_getfattr_generic(xdr,
>  &res->fs_locations->fattr,
>  NULL, res->fs_locations,

Your workaround appears to advance xdr->p one quad into the first page =
in
the xdr_buf. We really want that XDR data item to fall right at offset 0
of that page.

I'm looking into it.


>>>>>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>>>>>> index d0fa18d..6d9d5e2 100644
>>>>>> --- a/fs/nfs/nfs4xdr.c
>>>>>> +++ b/fs/nfs/nfs4xdr.c
>>>>>> @@ -284,14 +284,14 @@ static int decode_layoutget(struct =
xdr_stream *xdr, struct rpc_rqst *req,
>>>>>> #define decode_delegreturn_maxsz (op_decode_hdr_maxsz)
>>>>>> #define encode_getacl_maxsz     (encode_getattr_maxsz)
>>>>>> #define decode_getacl_maxsz     (op_decode_hdr_maxsz + \
>>>>>> -                                nfs4_fattr_bitmap_maxsz + 1)
>>>>>> +                                nfs4_fattr_bitmap_maxsz + 1 + 1)
>>>>>> #define encode_setacl_maxsz     (op_encode_hdr_maxsz + \
>>>>>>                                encode_stateid_maxsz + 3)
>>>>>> #define decode_setacl_maxsz     (decode_setattr_maxsz)
>>>>>> #define encode_fs_locations_maxsz \
>>>>>>                               (encode_getattr_maxsz)
>>>>>> #define decode_fs_locations_maxsz \
>>>>>> -                               (0)
>>>>>> +                               (1)
>>>>>> #define encode_secinfo_maxsz    (op_encode_hdr_maxsz + =
nfs4_name_maxsz)
>>>>>> #define decode_secinfo_maxsz    (op_decode_hdr_maxsz + 1 + =
((NFS_MAX_SECFLAVORS * (16 + GSS_OID_MAX_LEN)) / 4))
>>>>>>=20
>>>>>>=20
>>>>>>>>>>> On Mon, Feb 11, 2019 at 11:25 AM Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>>>>>>>>=20
>>>>>>>>>>>> Certain NFS results (eg. READLINK) might expect a data =
payload that
>>>>>>>>>>>> is not an exact multiple of 4 bytes. In this case, XDR =
encoding
>>>>>>>>>>>> is required to pad that payload so its length on the wire =
is a
>>>>>>>>>>>> multiple of 4 bytes. The constants that define the maximum =
size of
>>>>>>>>>>>> each NFS result do not appear to account for this extra =
word.
>>>>>>>>>>>>=20
>>>>>>>>>>>> In each case where the data payload is to be received into =
pages:
>>>>>>>>>>>>=20
>>>>>>>>>>>> - 1 word is added to the size of the receive buffer =
allocated by
>>>>>>>>>>>> call_allocate
>>>>>>>>>>>>=20
>>>>>>>>>>>> - rpc_inline_rcv_pages subtracts 1 word from @hdrsize so =
that the
>>>>>>>>>>>> extra buffer space falls into the rcv_buf's tail iovec
>>>>>>>>>>>>=20
>>>>>>>>>>>> - If buf->pagelen is word-aligned, an XDR pad is not needed =
and
>>>>>>>>>>>> is thus removed from the tail
>>>>>>>>>>>>=20
>>>>>>>>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>>>>>>>>> ---
>>>>>>>>>>>> fs/nfs/nfs2xdr.c  |    6 +++---
>>>>>>>>>>>> fs/nfs/nfs3xdr.c  |   10 +++++-----
>>>>>>>>>>>> fs/nfs/nfs4xdr.c  |   15 ++++++++-------
>>>>>>>>>>>> net/sunrpc/clnt.c |    6 +++++-
>>>>>>>>>>>> net/sunrpc/xdr.c  |    2 ++
>>>>>>>>>>>> 5 files changed, 23 insertions(+), 16 deletions(-)
>>>>>>>>>>>>=20
>>>>>>>>>>>> diff --git a/fs/nfs/nfs2xdr.c b/fs/nfs/nfs2xdr.c
>>>>>>>>>>>> index 1dcd0fe..a7ed29d 100644
>>>>>>>>>>>> --- a/fs/nfs/nfs2xdr.c
>>>>>>>>>>>> +++ b/fs/nfs/nfs2xdr.c
>>>>>>>>>>>> @@ -56,11 +56,11 @@
>>>>>>>>>>>>=20
>>>>>>>>>>>> #define NFS_attrstat_sz                (1+NFS_fattr_sz)
>>>>>>>>>>>> #define NFS_diropres_sz                =
(1+NFS_fhandle_sz+NFS_fattr_sz)
>>>>>>>>>>>> -#define NFS_readlinkres_sz     (2)
>>>>>>>>>>>> -#define NFS_readres_sz         (1+NFS_fattr_sz+1)
>>>>>>>>>>>> +#define NFS_readlinkres_sz     (2+1)
>>>>>>>>>>>> +#define NFS_readres_sz         (1+NFS_fattr_sz+1+1)
>>>>>>>>>>>> #define NFS_writeres_sz         (NFS_attrstat_sz)
>>>>>>>>>>>> #define NFS_stat_sz            (1)
>>>>>>>>>>>> -#define NFS_readdirres_sz      (1)
>>>>>>>>>>>> +#define NFS_readdirres_sz      (1+1)
>>>>>>>>>>>> #define NFS_statfsres_sz       (1+NFS_info_sz)
>>>>>>>>>>>>=20
>>>>>>>>>>>> static int nfs_stat_to_errno(enum nfs_stat);
>>>>>>>>>>>> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
>>>>>>>>>>>> index a54dcf4..110358f 100644
>>>>>>>>>>>> --- a/fs/nfs/nfs3xdr.c
>>>>>>>>>>>> +++ b/fs/nfs/nfs3xdr.c
>>>>>>>>>>>> @@ -69,13 +69,13 @@
>>>>>>>>>>>> #define NFS3_removeres_sz      (NFS3_setattrres_sz)
>>>>>>>>>>>> #define NFS3_lookupres_sz      (1+NFS3_fh_sz+(2 * =
NFS3_post_op_attr_sz))
>>>>>>>>>>>> #define NFS3_accessres_sz      (1+NFS3_post_op_attr_sz+1)
>>>>>>>>>>>> -#define NFS3_readlinkres_sz    (1+NFS3_post_op_attr_sz+1)
>>>>>>>>>>>> -#define NFS3_readres_sz                =
(1+NFS3_post_op_attr_sz+3)
>>>>>>>>>>>> +#define NFS3_readlinkres_sz    =
(1+NFS3_post_op_attr_sz+1+1)
>>>>>>>>>>>> +#define NFS3_readres_sz                =
(1+NFS3_post_op_attr_sz+3+1)
>>>>>>>>>>>> #define NFS3_writeres_sz       (1+NFS3_wcc_data_sz+4)
>>>>>>>>>>>> #define NFS3_createres_sz      =
(1+NFS3_fh_sz+NFS3_post_op_attr_sz+NFS3_wcc_data_sz)
>>>>>>>>>>>> #define NFS3_renameres_sz      (1+(2 * NFS3_wcc_data_sz))
>>>>>>>>>>>> #define NFS3_linkres_sz                =
(1+NFS3_post_op_attr_sz+NFS3_wcc_data_sz)
>>>>>>>>>>>> -#define NFS3_readdirres_sz     (1+NFS3_post_op_attr_sz+2)
>>>>>>>>>>>> +#define NFS3_readdirres_sz     =
(1+NFS3_post_op_attr_sz+2+1)
>>>>>>>>>>>> #define NFS3_fsstatres_sz      (1+NFS3_post_op_attr_sz+13)
>>>>>>>>>>>> #define NFS3_fsinfores_sz      (1+NFS3_post_op_attr_sz+12)
>>>>>>>>>>>> #define NFS3_pathconfres_sz    (1+NFS3_post_op_attr_sz+6)
>>>>>>>>>>>> @@ -85,7 +85,7 @@
>>>>>>>>>>>> #define ACL3_setaclargs_sz     (NFS3_fh_sz+1+ \
>>>>>>>>>>>>                            =
XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE))
>>>>>>>>>>>> #define ACL3_getaclres_sz      (1+NFS3_post_op_attr_sz+1+ \
>>>>>>>>>>>> -                               =
XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE))
>>>>>>>>>>>> +                               =
XDR_QUADLEN(NFS_ACL_INLINE_BUFSIZE)+1)
>>>>>>>>>>>> #define ACL3_setaclres_sz      (1+NFS3_post_op_attr_sz)
>>>>>>>>>>>>=20
>>>>>>>>>>>> static int nfs3_stat_to_errno(enum nfs_stat);
>>>>>>>>>>>> @@ -1629,7 +1629,7 @@ static int =
nfs3_xdr_dec_read3res(struct rpc_rqst *req, struct xdr_stream *xdr,
>>>>>>>>>>>>    result->op_status =3D status;
>>>>>>>>>>>>    if (status !=3D NFS3_OK)
>>>>>>>>>>>>            goto out_status;
>>>>>>>>>>>> -       result->replen =3D 3 + ((xdr_stream_pos(xdr) - pos) =
>> 2);
>>>>>>>>>>>> +       result->replen =3D 4 + ((xdr_stream_pos(xdr) - pos) =
>> 2);
>>>>>>>>>>>>    error =3D decode_read3resok(xdr, result);
>>>>>>>>>>>> out:
>>>>>>>>>>>>    return error;
>>>>>>>>>>>> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
>>>>>>>>>>>> index d0fa18d..6d9d5e2 100644
>>>>>>>>>>>> --- a/fs/nfs/nfs4xdr.c
>>>>>>>>>>>> +++ b/fs/nfs/nfs4xdr.c
>>>>>>>>>>>> @@ -215,14 +215,14 @@ static int decode_layoutget(struct =
xdr_stream *xdr, struct rpc_rqst *req,
>>>>>>>>>>>>                             nfs4_fattr_bitmap_maxsz)
>>>>>>>>>>>> #define encode_read_maxsz      (op_encode_hdr_maxsz + \
>>>>>>>>>>>>                             encode_stateid_maxsz + 3)
>>>>>>>>>>>> -#define decode_read_maxsz      (op_decode_hdr_maxsz + 2)
>>>>>>>>>>>> +#define decode_read_maxsz      (op_decode_hdr_maxsz + 2 + =
1)
>>>>>>>>>>>> #define encode_readdir_maxsz   (op_encode_hdr_maxsz + \
>>>>>>>>>>>>                             2 + encode_verifier_maxsz + 5 + =
\
>>>>>>>>>>>>                            nfs4_label_maxsz)
>>>>>>>>>>>> #define decode_readdir_maxsz   (op_decode_hdr_maxsz + \
>>>>>>>>>>>> -                                decode_verifier_maxsz)
>>>>>>>>>>>> +                                decode_verifier_maxsz + 1)
>>>>>>>>>>>> #define encode_readlink_maxsz  (op_encode_hdr_maxsz)
>>>>>>>>>>>> -#define decode_readlink_maxsz  (op_decode_hdr_maxsz + 1)
>>>>>>>>>>>> +#define decode_readlink_maxsz  (op_decode_hdr_maxsz + 1 + =
1)
>>>>>>>>>>>> #define encode_write_maxsz     (op_encode_hdr_maxsz + \
>>>>>>>>>>>>                             encode_stateid_maxsz + 4)
>>>>>>>>>>>> #define decode_write_maxsz     (op_decode_hdr_maxsz + \
>>>>>>>>>>>> @@ -284,14 +284,14 @@ static int decode_layoutget(struct =
xdr_stream *xdr, struct rpc_rqst *req,
>>>>>>>>>>>> #define decode_delegreturn_maxsz (op_decode_hdr_maxsz)
>>>>>>>>>>>> #define encode_getacl_maxsz    (encode_getattr_maxsz)
>>>>>>>>>>>> #define decode_getacl_maxsz    (op_decode_hdr_maxsz + \
>>>>>>>>>>>> -                                nfs4_fattr_bitmap_maxsz + =
1)
>>>>>>>>>>>> +                                nfs4_fattr_bitmap_maxsz + =
1 + 1)
>>>>>>>>>>>> #define encode_setacl_maxsz    (op_encode_hdr_maxsz + \
>>>>>>>>>>>>                             encode_stateid_maxsz + 3)
>>>>>>>>>>>> #define decode_setacl_maxsz    (decode_setattr_maxsz)
>>>>>>>>>>>> #define encode_fs_locations_maxsz \
>>>>>>>>>>>>                            (encode_getattr_maxsz)
>>>>>>>>>>>> #define decode_fs_locations_maxsz \
>>>>>>>>>>>> -                               (0)
>>>>>>>>>>>> +                               (1)
>>>>>>>>>>>> #define encode_secinfo_maxsz   (op_encode_hdr_maxsz + =
nfs4_name_maxsz)
>>>>>>>>>>>> #define decode_secinfo_maxsz   (op_decode_hdr_maxsz + 1 + =
((NFS_MAX_SECFLAVORS * (16 + GSS_OID_MAX_LEN)) / 4))
>>>>>>>>>>>>=20
>>>>>>>>>>>> @@ -392,12 +392,13 @@ static int decode_layoutget(struct =
xdr_stream *xdr, struct rpc_rqst *req,
>>>>>>>>>>>>                            1 /* opaque devaddr4 length */ + =
\
>>>>>>>>>>>>                              /* devaddr4 payload is read =
into page */ \
>>>>>>>>>>>>                            1 /* notification bitmap length =
*/ + \
>>>>>>>>>>>> -                               1 /* notification bitmap, =
word 0 */)
>>>>>>>>>>>> +                               1 /* notification bitmap, =
word 0 */ + \
>>>>>>>>>>>> +                               1 /* possible XDR padding =
*/)
>>>>>>>>>>>> #define encode_layoutget_maxsz (op_encode_hdr_maxsz + 10 + =
\
>>>>>>>>>>>>                            encode_stateid_maxsz)
>>>>>>>>>>>> #define decode_layoutget_maxsz (op_decode_hdr_maxsz + 8 + \
>>>>>>>>>>>>                            decode_stateid_maxsz + \
>>>>>>>>>>>> -                               =
XDR_QUADLEN(PNFS_LAYOUT_MAXSIZE))
>>>>>>>>>>>> +                               =
XDR_QUADLEN(PNFS_LAYOUT_MAXSIZE) + 1)
>>>>>>>>>>>> #define encode_layoutcommit_maxsz (op_encode_hdr_maxsz +    =
      \
>>>>>>>>>>>>                            2 /* offset */ + \
>>>>>>>>>>>>                            2 /* length */ + \
>>>>>>>>>>>> diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
>>>>>>>>>>>> index f780605..4ea38b0 100644
>>>>>>>>>>>> --- a/net/sunrpc/clnt.c
>>>>>>>>>>>> +++ b/net/sunrpc/clnt.c
>>>>>>>>>>>> @@ -1177,7 +1177,11 @@ void rpc_prepare_reply_pages(struct =
rpc_rqst *req, struct page **pages,
>>>>>>>>>>>>                         unsigned int base, unsigned int =
len,
>>>>>>>>>>>>                         unsigned int hdrsize)
>>>>>>>>>>>> {
>>>>>>>>>>>> -       hdrsize +=3D RPC_REPHDRSIZE + =
req->rq_cred->cr_auth->au_rslack;
>>>>>>>>>>>> +       /* Subtract one to force an extra word of buffer =
space for the
>>>>>>>>>>>> +        * payload's XDR pad to fall into the rcv_buf's =
tail iovec.
>>>>>>>>>>>> +        */
>>>>>>>>>>>> +       hdrsize +=3D RPC_REPHDRSIZE + =
req->rq_cred->cr_auth->au_rslack - 1;
>>>>>>>>>>>> +
>>>>>>>>>>>>    xdr_inline_pages(&req->rq_rcv_buf, hdrsize << 2, pages, =
base, len);
>>>>>>>>>>>>    trace_rpc_reply_pages(req);
>>>>>>>>>>>> }
>>>>>>>>>>>> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
>>>>>>>>>>>> index 7cca515..aa8177d 100644
>>>>>>>>>>>> --- a/net/sunrpc/xdr.c
>>>>>>>>>>>> +++ b/net/sunrpc/xdr.c
>>>>>>>>>>>> @@ -189,6 +189,8 @@ __be32 *xdr_encode_opaque(__be32 *p, =
const void *ptr, unsigned int nbytes)
>>>>>>>>>>>>=20
>>>>>>>>>>>>    tail->iov_base =3D buf + offset;
>>>>>>>>>>>>    tail->iov_len =3D buflen - offset;
>>>>>>>>>>>> +       if ((xdr->page_len & 3) =3D=3D 0)
>>>>>>>>>>>> +               tail->iov_len -=3D sizeof(__be32);
>>>>>>>>>>>>=20
>>>>>>>>>>>>    xdr->buflen +=3D len;
>>>>>>>>>>>> }
>>>>>>>>>>>>=20
>>>>>>>>>>=20
>>>>>>>>>> --
>>>>>>>>>> Chuck Lever
>>>>>>>>=20
>>>>>>>> --
>>>>>>>> Chuck Lever
>>>>>>=20
>>>>>> --
>>>>>> Chuck Lever
>>>>=20
>>>> --
>>>> Chuck Lever

--
Chuck Lever



