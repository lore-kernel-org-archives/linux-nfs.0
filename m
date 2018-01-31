Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f174.google.com ([209.85.217.174]:44867 "EHLO
        mail-ua0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751669AbeAaVMw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 31 Jan 2018 16:12:52 -0500
Received: by mail-ua0-f174.google.com with SMTP id x4so10393435uaj.11
        for <linux-nfs@vger.kernel.org>; Wed, 31 Jan 2018 13:12:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <DC591DD6-86DE-40FF-8883-9C369756FA54@oracle.com>
References: <CAN-5tyFX2aZPXy2NRiATwkbv8gDbyafB-4JsRUghuF84ih_WnQ@mail.gmail.com>
 <0B3C835B-3E30-43F3-B53C-BFB4462543D3@oracle.com> <CAN-5tyFu9YPVFzmrCcwwdcS5v8X61Az3hSW8xSDdTA3MWi09Sg@mail.gmail.com>
 <C5643108-6C06-4043-A67A-F63A2234FC40@oracle.com> <CAN-5tyHv+u=FsP+S7mG+7HHrrW=NKhC3vW_fVQh0OpjPJVJ2dw@mail.gmail.com>
 <16CE3E21-2BF9-4CC5-A3E7-FFBE706A9EF4@oracle.com> <CAN-5tyHSW9DPHbp9BGEFaF0dSFBc_NBwdSd9L4ZNCgzLn2VEkQ@mail.gmail.com>
 <B644BF5F-F16F-4AC6-AACD-EBEE14C6FB91@oracle.com> <CAN-5tyH3NnN6ac-Q+39T5cUHubCbsBW200y03KE0YnSC4=0hAA@mail.gmail.com>
 <0F49479C-EB5B-4F86-B89B-7435FDD51E54@oracle.com> <CAN-5tyFoa8DSyxBHYznASdUD1rLON0V6BvZ-2jSiRSXS-T2PqA@mail.gmail.com>
 <DC591DD6-86DE-40FF-8883-9C369756FA54@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Wed, 31 Jan 2018 16:12:50 -0500
Message-ID: <CAN-5tyHvPMgY_UtM7tECHsHaLPQV2N9bXDP36aoKOAjcRzYXrw@mail.gmail.com>
Subject: Re: problem on nfsd doing RDMA write
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 31, 2018 at 2:51 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On Jan 31, 2018, at 1:52 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Wed, Jan 31, 2018 at 1:29 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>
>>>> On Jan 30, 2018, at 12:02 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>
>>>> On Mon, Jan 29, 2018 at 12:24 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>
>>>>>
>>>>>> On Jan 29, 2018, at 12:19 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>
>>>>>> On Fri, Jan 26, 2018 at 4:08 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>>
>>>>>>>
>>>>>>>> On Jan 26, 2018, at 12:13 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>>>
>>>>>>>> On Fri, Jan 26, 2018 at 2:29 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>> On Jan 26, 2018, at 11:05 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>>>>>
>>>>>>>>>> On Fri, Jan 26, 2018 at 1:23 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>>> On Jan 26, 2018, at 9:24 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>>>>>>>>>
>>>>>>>>>>>> Hi Bruce/Chuck,
>>>>>>>>>>>>
>>>>>>>>>>>> There is a problem with nfsd doing a WRITE of size 4093,4094,4095. To
>>>>>>>>>>>> reproduce, mount with RDMA and do a simple dd "dd if=/dev/zero
>>>>>>>>>>>> of=/mnt/testfile bs=4093 count=1". What happens is that nfsd fails to
>>>>>>>>>>>> parse GETATTR after the WRITE in the compound. It fails the operation
>>>>>>>>>>>> with ERR_OP_ILLEGAL.
>>>>>>>>>>>>
>>>>>>>>>>>> The problem happens for the values where XDR round up ends up rounding
>>>>>>>>>>>> up to the page size. I don't know if my fix is the appropriate way to
>>>>>>>>>>>> fix this but with it I don't get the error:
>>>>>>>>>>>>
>>>>>>>>>>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>>>>>>>>>>>> index 2c61c6b..a8489c3 100644
>>>>>>>>>>>> --- a/fs/nfsd/nfs4xdr.c
>>>>>>>>>>>> +++ b/fs/nfsd/nfs4xdr.c
>>>>>>>>>>>> @@ -1289,11 +1289,12 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compounda
>>>>>>>>>>>>
>>>>>>>>>>>>   len = XDR_QUADLEN(write->wr_buflen) << 2;
>>>>>>>>>>>>   if (len >= avail) {
>>>>>>>>>>>> -               int pages;
>>>>>>>>>>>> +               int pages = 0;
>>>>>>>>>>>>
>>>>>>>>>>>>           len -= avail;
>>>>>>>>>>>>
>>>>>>>>>>>> -               pages = len >> PAGE_SHIFT;
>>>>>>>>>>>> +               if (write->wr_buflen >= PAGE_SIZE)
>>>>>>>>>>>> +                       pages = len >> PAGE_SHIFT;
>>>>>>>>>>>>           argp->pagelist += pages;
>>>>>>>>>>>>           argp->pagelen -= pages * PAGE_SIZE;
>>>>>>>>>>>>           len -= pages * PAGE_SIZE;
>>>>>>>>>>>>
>>>>>>>>>>>> So the problem is the using "len" instead of "write->wr_buflen" leads
>>>>>>>>>>>> for the values 4093,4094,4095 that are rounded up to 4096, it makes
>>>>>>>>>>>> pages=1 and the argp->pagelen ends up being a negative value leading
>>>>>>>>>>>> to problems of parsing the GETATTR.
>>>>>>>>>>>
>>>>>>>>>>> Would this also be a problem near any page boundary, say, a
>>>>>>>>>>> write length of 8191 bytes?
>>>>>>>>>>>
>>>>>>>>>>> Instead of using the rounded up "len", why not try this:
>>>>>>>>>>>
>>>>>>>>>>> -               pages = len >> PAGE_SHIFT;
>>>>>>>>>>> +               pages = write->wr_buflen >> PAGE_SHIFT;
>>>>>>>>>>
>>>>>>>>>> You are right. It needs to be that. Otherwise 8191 fails the same way.
>>>>>>>>>>
>>>>>>>>>>> And be sure to test with TCP as well.
>>>>>>>>>>
>>>>>>>>>> Sigh. It breaks normal (non-RDMA) mounts. I'll figure out why.
>>>>>>>>>
>>>>>>>>> OK.
>>>>>>>>>
>>>>>>>>> Remember that a Read chunk's length does not have to be
>>>>>>>>> rounded up. Maybe the transport needs to round up the
>>>>>>>>> length of the unmarshaled data content on behalf of the
>>>>>>>>> NFSv4 write decoder.
>>>>>>>>>
>>>>>>>>
>>>>>>>> The problem of simply taking write->wr_buflen was that len before that
>>>>>>>> could have been adjusted by avail value in then non-RDAM mounts.
>>>>>>>>
>>>>>>>> Again, I'm not sure if this is the right fix. But this one works for
>>>>>>>> both non-RDMA and RDMA mounts.
>>>>>>>>
>>>>>>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>>>>>>>> index 2c61c6b..3178997 100644
>>>>>>>> --- a/fs/nfsd/nfs4xdr.c
>>>>>>>> +++ b/fs/nfsd/nfs4xdr.c
>>>>>>>> @@ -1293,7 +1293,10 @@ static __be32 nfsd4_decode_opaque(struct
>>>>>>>> nfsd4_compoundargs *argp, struct xdr_ne
>>>>>>>>
>>>>>>>>             len -= avail;
>>>>>>>>
>>>>>>>> -               pages = len >> PAGE_SHIFT;
>>>>>>>> +               if (!avail)
>>>>>>>> +                       pages = write->wr_buflen >> PAGE_SHIFT;
>>>>>>>> +               else
>>>>>>>> +                       pages = len >> PAGE_SHIFT;
>>>>>>>>             argp->pagelist += pages;
>>>>>>>>             argp->pagelen -= pages * PAGE_SIZE;
>>>>>>>>             len -= pages * PAGE_SIZE;
>>>>>>>
>>>>>>> This code has been around since 2012. Has it always been
>>>>>>> broken for RDMA? I suspect the root problem is in the
>>>>>>> transport, not here in the decoder. Can you bisect to
>>>>>>> find out where the problem started to occur?
>>>>>>
>>>>>> To see if I could go back to 2012, I first want to see if I could go
>>>>>> back to before mlx5 driver was added which was in 3.11-rc1. But I'm
>>>>>> having issues trying to boot into a kernel based on 3.10 or 3.9. I'm
>>>>>> trying to verify if my CX-5 card would even work with mlx4 driver
>>>>>> which I'm having doubts it would.
>>>>>
>>>>> The CX-5 works only with mlx5.
>>>>>
>>>>>
>>>>>> These old kernels fail to boot in
>>>>>> XFS saying that it's a wrong version. Some googling makes me think
>>>>>> that since my XFS partition was created with a newer kernel it's not
>>>>>> compatible with an older kernel...
>>>>>
>>>>> That's correct, the XFS filesystem has new features like
>>>>> metadata checksum that don't work on older kernels.
>>>>>
>>>>> To start with, you could try some very late 3.x or early
>>>>> 4.x kernels. My intuition is that you will find an svcrdma
>>>>> change that is more recent than 2012 that is causing the
>>>>> underlying issue.
>>>>
>>>> It works in 4.8 and does not work in 4.9. It's this commit that breaks it:
>>>>
>>>> commit cc9d83408b52265ddab2874cf19d1611da4ca7ee
>>>>
>>>> svcrdma: Server-side support for rpcrdma_connect_private
>>>>
>>>> Prepare to receive an RDMA-CM private message when handling a new
>>>> connection attempt, and send a similar message as part of connection
>>>> acceptance.
>>>>
>>>> Both sides can communicate their various implementation limits.
>>>> Implementations that don't support this sideband protocol ignore it.
>>>>
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> Reviewed-by: Sagi Grimberg <sagi@grimberg.me>
>>>> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
>>>>
>>>> So far I don't understand how can causes problems...
>>>
>>> More likely it's:
>>>
>>>
>>> commit eae03e2ac80a3476f0652cb0ee451d7b06d30564
>>> Author:     Chuck Lever <chuck.lever@oracle.com>
>>> AuthorDate: Fri Aug 18 11:12:27 2017 -0400
>>> Commit:     J. Bruce Fields <bfields@redhat.com>
>>> CommitDate: Tue Sep 5 15:15:29 2017 -0400
>>>
>>>    nfsd: Incoming xdr_bufs may have content in tail buffer
>>>
>>>
>>>
>>> This is a 3 op compound. The third op is GETATTR.
>>> The reply shows that the WRITE op succeeds, which
>>> is why no error is reported to the application.
>>> The GETATTR fails with OP_ILLEGAL, and the client
>>> I guess is trained to ignore that kind of failure.
>>>
>>> After nfsd4_decode_write pushes into the "next" page
>>> in the page list, the next time READ_BUF is called
>>> (to handle the next op in the compound), it is
>>> supposed to see that the XDR page list is now
>>> exhausted, and switch to the XDR tail buf.
>>>
>>> TCP doesn't use the tail buf; the GETATTR in that
>>> case is at the end of the page list, following the
>>> WRITE payload. That would explain why this issue
>>> cannot be reproduced there.
>>>
>>> RDMA does use the tail buf in this case. For some
>>> reason the logic added in eae03e2ac8 is not working,
>>> and the server is looking at uninitialized memory
>>> to find that third op.
>>>
>>> I run cthon04 all the time, so I wonder why I never
>>> hit this case.
>>
>> While this commit seems like a better explanation,  I can 100% hit the
>> issue running 4.8-rc6 based kernel (this is from your nfsd-for-4.9
>> branch and rollback back to the cc9d83408b) . What matters is the
>> assignment of the "private_data" in the conn_param. If I set it to
>> NULL and 0 for the length. The problem goes away.
>
> There's no obvious connection between the NFSv4 WRITE
> misbehavior and CM private data being present.
>
>
>> Are you hitting the issue now?
>
> I can reproduce it 100% of the time using your dd example
> from a Linux NFS client.
>
> I've also done a 8009 byte write on TCP, which forces the
> same page boundary edge condition in nfsd4_decode_write,
> and the failure does not occur.
>
>
>> Are you 100% certain that you haven't
>> hit it before. Do you always inspect the network traces? Without
>> inspecting the network trace you wouldn't have found it. cthon never
>> fails so from the user perspective nothing failed.
>
> Fair enough.
>
>
>> I will check eae03e2ac80a3476f0652cb0ee451d7b06d30564 commit to see
>> what different do I see in my testing.
>
> My theory is it's that one or this related one:
>
> commit 193bcb7b3719a315814dce40fc8dcd1af786ea64
> Author:     Chuck Lever <chuck.lever@oracle.com>
> AuthorDate: Fri Aug 18 11:12:35 2017 -0400
> Commit:     J. Bruce Fields <bfields@redhat.com>
> CommitDate: Tue Sep 5 15:15:29 2017 -0400
>
>     svcrdma: Populate tail iovec when receiving

I have looked for these patches. I'm still not sure how these patches
can be the cause if they are not present in 4.8-rc6 but the problem is
there?

Let me say what else I have observed that perhaps it will trigger some
other  ideas.

There is a difference in the size of the RDMA Read Request that the
client does between the working kernel vs the non-working one. This is
something that the client is doing. How is a patch on the server
(dealing with the private data) can effect what size the client is
specifying. In working case, it's 4112 and not working one is 4093.


>>>>>>>>>>>> If this looks OK, I can send a patch.
>>>>>>>>>>>> --
>>>>>>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>>>>>
>>>>>>>>>>> --
>>>>>>>>>>> Chuck Lever
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>>
>>>>>>>>>>> --
>>>>>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>>>> --
>>>>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>>>
>>>>>>>>> --
>>>>>>>>> Chuck Lever
>>>>>>>>>
>>>>>>>>>
>>>>>>>>>
>>>>>>>> --
>>>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>>>
>>>>>>> --
>>>>>>> Chuck Lever
>>>>>>>
>>>>>>>
>>>>>>>
>>>>>> --
>>>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>>>> the body of a message to majordomo@vger.kernel.org
>>>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>>>
>>>>> --
>>>>> Chuck Lever
>>>>>
>>>>>
>>>>>
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> --
>>> Chuck Lever
>
> --
> Chuck Lever
>
>
>
