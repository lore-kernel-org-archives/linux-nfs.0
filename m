Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from us-smtp-delivery-194.mimecast.com ([216.205.24.194]:24976 "EHLO
        us-smtp-delivery-194.mimecast.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751162AbdAQQOj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jan 2017 11:14:39 -0500
From: Trond Myklebust <trondmy@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
CC: Olga Kornievskaia <kolga@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] NFSv3: Ignore wcc before ctime attribute
Date: Tue, 17 Jan 2017 16:14:25 +0000
Message-ID: <D828C666-FE77-4E43-925B-A6A4FC647E50@primarydata.com>
References: <1459541983-21301-1-git-send-email-kolga@netapp.com>
 <CAN-5tyG6-TPbBxmMYpLPv6_duwAYRm1V_QtRSWepT6un5EtNAg@mail.gmail.com>
In-Reply-To: <CAN-5tyG6-TPbBxmMYpLPv6_duwAYRm1V_QtRSWepT6un5EtNAg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=WINDOWS-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Is there a problem with 4.10-rc?

> On Jan 17, 2017, at 09:33, Olga Kornievskaia <aglo@umich.edu> wrote:
>=20
> Hi Trond,
>=20
> I'd like bring up this issue again as I was asked again that linux
> nfsv3 client experiences poor performance when it receives
> out-of-order write rpcs. If a general change to ignore "before" ctime
> is not acceptable, what about something that is configurable via a
> sysctl perhaps?
>=20
> On Fri, Apr 1, 2016 at 4:19 PM, Olga Kornievskaia <kolga@netapp.com> wrot=
e:
>> Commit 7c2dad99d60c86ec686b3bfdcb787c450a7ea89f
>> "Don't let the ctime override attribute barriers" introduced a problem
>> of invalidating the cache when receiving in-order WRITE replies. Because
>> ctime is no longer checked then attributes are not updated appropriately
>> and then leads to mismatch of received "before" with what's stored.
>>=20
>> Given that sending the wcc attributes is not mandatory (and linux
>> server doesn't), we can ignore the received "before" ctime. It fixes
>> the current problem and also help when we receive out-of-order WRITEs.
>>=20
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>> fs/nfs/nfs3xdr.c | 2 --
>> 1 file changed, 2 deletions(-)
>>=20
>> diff --git a/fs/nfs/nfs3xdr.c b/fs/nfs/nfs3xdr.c
>> index 267126d..feca07f 100644
>> --- a/fs/nfs/nfs3xdr.c
>> +++ b/fs/nfs/nfs3xdr.c
>> @@ -732,14 +732,12 @@ static int decode_wcc_attr(struct xdr_stream *xdr,=
 struct nfs_fattr *fattr)
>>                goto out_overflow;
>>=20
>>        fattr->valid |=3D NFS_ATTR_FATTR_PRESIZE
>> -               | NFS_ATTR_FATTR_PRECHANGE
>>                | NFS_ATTR_FATTR_PREMTIME
>>                | NFS_ATTR_FATTR_PRECTIME;
>>=20
>>        p =3D xdr_decode_size3(p, &fattr->pre_size);
>>        p =3D xdr_decode_nfstime3(p, &fattr->pre_mtime);
>>        xdr_decode_nfstime3(p, &fattr->pre_ctime);
>> -       fattr->pre_change_attr =3D nfs_timespec_to_change_attr(&fattr->p=
re_ctime);
>>=20
>>        return 0;
>> out_overflow:
>> --
>> 1.8.3.1
>>=20
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20

