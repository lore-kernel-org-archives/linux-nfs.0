Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:52488 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751025AbdAQQVG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Jan 2017 11:21:06 -0500
Content-Type: text/plain; charset="windows-1252"
MIME-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH 1/1] NFSv3: Ignore wcc before ctime attribute
From: Olga Kornievskaia <kolga@netapp.com>
In-Reply-To: <D828C666-FE77-4E43-925B-A6A4FC647E50@primarydata.com>
Date: Tue, 17 Jan 2017 11:20:57 -0500
CC: Olga Kornievskaia <aglo@umich.edu>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-ID: <06CF6532-70AD-428F-93C7-C30305E09B35@netapp.com>
References: <1459541983-21301-1-git-send-email-kolga@netapp.com>
 <CAN-5tyG6-TPbBxmMYpLPv6_duwAYRm1V_QtRSWepT6un5EtNAg@mail.gmail.com>
 <D828C666-FE77-4E43-925B-A6A4FC647E50@primarydata.com>
To: Trond Myklebust <trondmy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Honestly, I haven=92t retried the 4.10-rc. I haven=92t recalled any =
patches that dealt with out of order RPCs and attributes and therefore =
assumed it was still an issue. I will recheck the 4.10-rc if you think =
the issue should have been addressed.


> On Jan 17, 2017, at 11:14 AM, Trond Myklebust =
<trondmy@primarydata.com> wrote:
>=20
> Is there a problem with 4.10-rc?
>=20
>> On Jan 17, 2017, at 09:33, Olga Kornievskaia <aglo@umich.edu> wrote:
>>=20
>> Hi Trond,
>>=20
>> I'd like bring up this issue again as I was asked again that linux
>> nfsv3 client experiences poor performance when it receives
>> out-of-order write rpcs. If a general change to ignore "before" ctime
>> is not acceptable, what about something that is configurable via a
>> sysctl perhaps?
>>=20
>> On Fri, Apr 1, 2016 at 4:19 PM, Olga Kornievskaia <kolga@netapp.com> =
wrote:
>>> Commit 7c2dad99d60c86ec686b3bfdcb787c450a7ea89f
>>> "Don't let the ctime override attribute barriers" introduced a =
problem
>>> of invalidating the cache when receiving in-order WRITE replies. =
Because
>>> ctime is no longer checked then attributes are not updated =
appropriately
>>> and then leads to mismatch of received "before" with what's stored.
>>>=20
>>> Given that sending the wcc attributes is not mandatory (and linux
>>> server doesn't), we can ignore the received "before" ctime. It fixes
>>> the current problem and also help when we receive out-of-order =
WRITEs.
>>>=20
>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>> ---
>>> fs/nfs/nfs3xdr.c | 2 --
>>> 1 file changed, 2 deletions(-)
>>>=20
>>> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
>>> index 267126d..feca07f 100644
>>> --- a/fs/nfs/nfs3xdr.c
>>> +++ b/fs/nfs/nfs3xdr.c
>>> @@ -732,14 +732,12 @@ static int decode_wcc_attr(struct xdr_stream =
*xdr, struct nfs_fattr *fattr)
>>>               goto out_overflow;
>>>=20
>>>       fattr->valid |=3D NFS_ATTR_FATTR_PRESIZE
>>> -               | NFS_ATTR_FATTR_PRECHANGE
>>>               | NFS_ATTR_FATTR_PREMTIME
>>>               | NFS_ATTR_FATTR_PRECTIME;
>>>=20
>>>       p =3D xdr_decode_size3(p, &fattr->pre_size);
>>>       p =3D xdr_decode_nfstime3(p, &fattr->pre_mtime);
>>>       xdr_decode_nfstime3(p, &fattr->pre_ctime);
>>> -       fattr->pre_change_attr =3D =
nfs_timespec_to_change_attr(&fattr->pre_ctime);
>>>=20
>>>       return 0;
>>> out_overflow:
>>> --
>>> 1.8.3.1
>>>=20
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
>=20

