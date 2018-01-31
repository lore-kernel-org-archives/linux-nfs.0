Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:40140 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751514AbeAaS3m (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Jan 2018 13:29:42 -0500
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.2 \(3445.5.20\))
Subject: Re: problem on nfsd doing RDMA write
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyH3NnN6ac-Q+39T5cUHubCbsBW200y03KE0YnSC4=0hAA@mail.gmail.com>
Date: Wed, 31 Jan 2018 13:29:25 -0500
Cc: Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <0F49479C-EB5B-4F86-B89B-7435FDD51E54@oracle.com>
References: <CAN-5tyFX2aZPXy2NRiATwkbv8gDbyafB-4JsRUghuF84ih_WnQ@mail.gmail.com>
 <0B3C835B-3E30-43F3-B53C-BFB4462543D3@oracle.com>
 <CAN-5tyFu9YPVFzmrCcwwdcS5v8X61Az3hSW8xSDdTA3MWi09Sg@mail.gmail.com>
 <C5643108-6C06-4043-A67A-F63A2234FC40@oracle.com>
 <CAN-5tyHv+u=FsP+S7mG+7HHrrW=NKhC3vW_fVQh0OpjPJVJ2dw@mail.gmail.com>
 <16CE3E21-2BF9-4CC5-A3E7-FFBE706A9EF4@oracle.com>
 <CAN-5tyHSW9DPHbp9BGEFaF0dSFBc_NBwdSd9L4ZNCgzLn2VEkQ@mail.gmail.com>
 <B644BF5F-F16F-4AC6-AACD-EBEE14C6FB91@oracle.com>
 <CAN-5tyH3NnN6ac-Q+39T5cUHubCbsBW200y03KE0YnSC4=0hAA@mail.gmail.com>
To: Olga Kornievskaia <aglo@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



> On Jan 30, 2018, at 12:02 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>=20
> On Mon, Jan 29, 2018 at 12:24 PM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>=20
>>> On Jan 29, 2018, at 12:19 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>=20
>>> On Fri, Jan 26, 2018 at 4:08 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>=20
>>>>=20
>>>>> On Jan 26, 2018, at 12:13 PM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>>=20
>>>>> On Fri, Jan 26, 2018 at 2:29 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>>=20
>>>>>>=20
>>>>>>> On Jan 26, 2018, at 11:05 AM, Olga Kornievskaia <aglo@umich.edu> =
wrote:
>>>>>>>=20
>>>>>>> On Fri, Jan 26, 2018 at 1:23 PM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>> On Jan 26, 2018, at 9:24 AM, Olga Kornievskaia =
<aglo@umich.edu> wrote:
>>>>>>>>>=20
>>>>>>>>> Hi Bruce/Chuck,
>>>>>>>>>=20
>>>>>>>>> There is a problem with nfsd doing a WRITE of size =
4093,4094,4095. To
>>>>>>>>> reproduce, mount with RDMA and do a simple dd "dd if=3D/dev/zero=

>>>>>>>>> of=3D/mnt/testfile bs=3D4093 count=3D1". What happens is that =
nfsd fails to
>>>>>>>>> parse GETATTR after the WRITE in the compound. It fails the =
operation
>>>>>>>>> with ERR_OP_ILLEGAL.
>>>>>>>>>=20
>>>>>>>>> The problem happens for the values where XDR round up ends up =
rounding
>>>>>>>>> up to the page size. I don't know if my fix is the appropriate =
way to
>>>>>>>>> fix this but with it I don't get the error:
>>>>>>>>>=20
>>>>>>>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>>>>>>>>> index 2c61c6b..a8489c3 100644
>>>>>>>>> --- a/fs/nfsd/nfs4xdr.c
>>>>>>>>> +++ b/fs/nfsd/nfs4xdr.c
>>>>>>>>> @@ -1289,11 +1289,12 @@ static __be32 =
nfsd4_decode_opaque(struct nfsd4_compounda
>>>>>>>>>=20
>>>>>>>>>    len =3D XDR_QUADLEN(write->wr_buflen) << 2;
>>>>>>>>>    if (len >=3D avail) {
>>>>>>>>> -               int pages;
>>>>>>>>> +               int pages =3D 0;
>>>>>>>>>=20
>>>>>>>>>            len -=3D avail;
>>>>>>>>>=20
>>>>>>>>> -               pages =3D len >> PAGE_SHIFT;
>>>>>>>>> +               if (write->wr_buflen >=3D PAGE_SIZE)
>>>>>>>>> +                       pages =3D len >> PAGE_SHIFT;
>>>>>>>>>            argp->pagelist +=3D pages;
>>>>>>>>>            argp->pagelen -=3D pages * PAGE_SIZE;
>>>>>>>>>            len -=3D pages * PAGE_SIZE;
>>>>>>>>>=20
>>>>>>>>> So the problem is the using "len" instead of =
"write->wr_buflen" leads
>>>>>>>>> for the values 4093,4094,4095 that are rounded up to 4096, it =
makes
>>>>>>>>> pages=3D1 and the argp->pagelen ends up being a negative value =
leading
>>>>>>>>> to problems of parsing the GETATTR.
>>>>>>>>=20
>>>>>>>> Would this also be a problem near any page boundary, say, a
>>>>>>>> write length of 8191 bytes?
>>>>>>>>=20
>>>>>>>> Instead of using the rounded up "len", why not try this:
>>>>>>>>=20
>>>>>>>> -               pages =3D len >> PAGE_SHIFT;
>>>>>>>> +               pages =3D write->wr_buflen >> PAGE_SHIFT;
>>>>>>>=20
>>>>>>> You are right. It needs to be that. Otherwise 8191 fails the =
same way.
>>>>>>>=20
>>>>>>>> And be sure to test with TCP as well.
>>>>>>>=20
>>>>>>> Sigh. It breaks normal (non-RDMA) mounts. I'll figure out why.
>>>>>>=20
>>>>>> OK.
>>>>>>=20
>>>>>> Remember that a Read chunk's length does not have to be
>>>>>> rounded up. Maybe the transport needs to round up the
>>>>>> length of the unmarshaled data content on behalf of the
>>>>>> NFSv4 write decoder.
>>>>>>=20
>>>>>=20
>>>>> The problem of simply taking write->wr_buflen was that len before =
that
>>>>> could have been adjusted by avail value in then non-RDAM mounts.
>>>>>=20
>>>>> Again, I'm not sure if this is the right fix. But this one works =
for
>>>>> both non-RDMA and RDMA mounts.
>>>>>=20
>>>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>>>>> index 2c61c6b..3178997 100644
>>>>> --- a/fs/nfsd/nfs4xdr.c
>>>>> +++ b/fs/nfsd/nfs4xdr.c
>>>>> @@ -1293,7 +1293,10 @@ static __be32 nfsd4_decode_opaque(struct
>>>>> nfsd4_compoundargs *argp, struct xdr_ne
>>>>>=20
>>>>>              len -=3D avail;
>>>>>=20
>>>>> -               pages =3D len >> PAGE_SHIFT;
>>>>> +               if (!avail)
>>>>> +                       pages =3D write->wr_buflen >> PAGE_SHIFT;
>>>>> +               else
>>>>> +                       pages =3D len >> PAGE_SHIFT;
>>>>>              argp->pagelist +=3D pages;
>>>>>              argp->pagelen -=3D pages * PAGE_SIZE;
>>>>>              len -=3D pages * PAGE_SIZE;
>>>>=20
>>>> This code has been around since 2012. Has it always been
>>>> broken for RDMA? I suspect the root problem is in the
>>>> transport, not here in the decoder. Can you bisect to
>>>> find out where the problem started to occur?
>>>=20
>>> To see if I could go back to 2012, I first want to see if I could go
>>> back to before mlx5 driver was added which was in 3.11-rc1. But I'm
>>> having issues trying to boot into a kernel based on 3.10 or 3.9. I'm
>>> trying to verify if my CX-5 card would even work with mlx4 driver
>>> which I'm having doubts it would.
>>=20
>> The CX-5 works only with mlx5.
>>=20
>>=20
>>> These old kernels fail to boot in
>>> XFS saying that it's a wrong version. Some googling makes me think
>>> that since my XFS partition was created with a newer kernel it's not
>>> compatible with an older kernel...
>>=20
>> That's correct, the XFS filesystem has new features like
>> metadata checksum that don't work on older kernels.
>>=20
>> To start with, you could try some very late 3.x or early
>> 4.x kernels. My intuition is that you will find an svcrdma
>> change that is more recent than 2012 that is causing the
>> underlying issue.
>=20
> It works in 4.8 and does not work in 4.9. It's this commit that breaks =
it:
>=20
> commit cc9d83408b52265ddab2874cf19d1611da4ca7ee
>=20
> svcrdma: Server-side support for rpcrdma_connect_private
>=20
> Prepare to receive an RDMA-CM private message when handling a new
> connection attempt, and send a similar message as part of connection
> acceptance.
>=20
> Both sides can communicate their various implementation limits.
> Implementations that don't support this sideband protocol ignore it.
>=20
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>=20
> So far I don't understand how can causes problems...

More likely it's:


commit eae03e2ac80a3476f0652cb0ee451d7b06d30564
Author:     Chuck Lever <chuck.lever@oracle.com>
AuthorDate: Fri Aug 18 11:12:27 2017 -0400
Commit:     J. Bruce Fields <bfields@redhat.com>
CommitDate: Tue Sep 5 15:15:29 2017 -0400

    nfsd: Incoming xdr_bufs may have content in tail buffer



This is a 3 op compound. The third op is GETATTR.
The reply shows that the WRITE op succeeds, which
is why no error is reported to the application.
The GETATTR fails with OP_ILLEGAL, and the client
I guess is trained to ignore that kind of failure.

After nfsd4_decode_write pushes into the "next" page
in the page list, the next time READ_BUF is called
(to handle the next op in the compound), it is
supposed to see that the XDR page list is now
exhausted, and switch to the XDR tail buf.

TCP doesn't use the tail buf; the GETATTR in that
case is at the end of the page list, following the
WRITE payload. That would explain why this issue
cannot be reproduced there.

RDMA does use the tail buf in this case. For some
reason the logic added in eae03e2ac8 is not working,
and the server is looking at uninitialized memory
to find that third op.

I run cthon04 all the time, so I wonder why I never
hit this case.


>>>>>>>>> If this looks OK, I can send a patch.
>>>>>>>>> --
>>>>>>>>> To unsubscribe from this list: send the line "unsubscribe =
linux-nfs" in
>>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>>> More majordomo info at  =
http://vger.kernel.org/majordomo-info.html
>>>>>>>>=20
>>>>>>>> --
>>>>>>>> Chuck Lever
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>>=20
>>>>>>>> --
>>>>>>>> To unsubscribe from this list: send the line "unsubscribe =
linux-nfs" in
>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>> More majordomo info at  =
http://vger.kernel.org/majordomo-info.html
>>>>>>> --
>>>>>>> To unsubscribe from this list: send the line "unsubscribe =
linux-nfs" in
>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>> More majordomo info at  =
http://vger.kernel.org/majordomo-info.html
>>>>>>=20
>>>>>> --
>>>>>> Chuck Lever
>>>>>>=20
>>>>>>=20
>>>>>>=20
>>>>> --
>>>>> To unsubscribe from this list: send the line "unsubscribe =
linux-nfs" in
>>>>> the body of a message to majordomo@vger.kernel.org
>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>=20
>>>> --
>>>> Chuck Lever
>>>>=20
>>>>=20
>>>>=20
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



