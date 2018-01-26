Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f195.google.com ([209.85.217.195]:46956 "EHLO
        mail-ua0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752260AbeAZUNv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Jan 2018 15:13:51 -0500
Received: by mail-ua0-f195.google.com with SMTP id j23so1054176uak.13
        for <linux-nfs@vger.kernel.org>; Fri, 26 Jan 2018 12:13:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <C5643108-6C06-4043-A67A-F63A2234FC40@oracle.com>
References: <CAN-5tyFX2aZPXy2NRiATwkbv8gDbyafB-4JsRUghuF84ih_WnQ@mail.gmail.com>
 <0B3C835B-3E30-43F3-B53C-BFB4462543D3@oracle.com> <CAN-5tyFu9YPVFzmrCcwwdcS5v8X61Az3hSW8xSDdTA3MWi09Sg@mail.gmail.com>
 <C5643108-6C06-4043-A67A-F63A2234FC40@oracle.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 26 Jan 2018 15:13:48 -0500
Message-ID: <CAN-5tyHv+u=FsP+S7mG+7HHrrW=NKhC3vW_fVQh0OpjPJVJ2dw@mail.gmail.com>
Subject: Re: problem on nfsd doing RDMA write
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Bruce Fields <bfields@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 26, 2018 at 2:29 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>
>> On Jan 26, 2018, at 11:05 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>
>> On Fri, Jan 26, 2018 at 1:23 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>
>>>> On Jan 26, 2018, at 9:24 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
>>>>
>>>> Hi Bruce/Chuck,
>>>>
>>>> There is a problem with nfsd doing a WRITE of size 4093,4094,4095. To
>>>> reproduce, mount with RDMA and do a simple dd "dd if=/dev/zero
>>>> of=/mnt/testfile bs=4093 count=1". What happens is that nfsd fails to
>>>> parse GETATTR after the WRITE in the compound. It fails the operation
>>>> with ERR_OP_ILLEGAL.
>>>>
>>>> The problem happens for the values where XDR round up ends up rounding
>>>> up to the page size. I don't know if my fix is the appropriate way to
>>>> fix this but with it I don't get the error:
>>>>
>>>> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
>>>> index 2c61c6b..a8489c3 100644
>>>> --- a/fs/nfsd/nfs4xdr.c
>>>> +++ b/fs/nfsd/nfs4xdr.c
>>>> @@ -1289,11 +1289,12 @@ static __be32 nfsd4_decode_opaque(struct nfsd4_compounda
>>>>
>>>>       len = XDR_QUADLEN(write->wr_buflen) << 2;
>>>>       if (len >= avail) {
>>>> -               int pages;
>>>> +               int pages = 0;
>>>>
>>>>               len -= avail;
>>>>
>>>> -               pages = len >> PAGE_SHIFT;
>>>> +               if (write->wr_buflen >= PAGE_SIZE)
>>>> +                       pages = len >> PAGE_SHIFT;
>>>>               argp->pagelist += pages;
>>>>               argp->pagelen -= pages * PAGE_SIZE;
>>>>               len -= pages * PAGE_SIZE;
>>>>
>>>> So the problem is the using "len" instead of "write->wr_buflen" leads
>>>> for the values 4093,4094,4095 that are rounded up to 4096, it makes
>>>> pages=1 and the argp->pagelen ends up being a negative value leading
>>>> to problems of parsing the GETATTR.
>>>
>>> Would this also be a problem near any page boundary, say, a
>>> write length of 8191 bytes?
>>>
>>> Instead of using the rounded up "len", why not try this:
>>>
>>> -               pages = len >> PAGE_SHIFT;
>>> +               pages = write->wr_buflen >> PAGE_SHIFT;
>>
>> You are right. It needs to be that. Otherwise 8191 fails the same way.
>>
>>> And be sure to test with TCP as well.
>>
>> Sigh. It breaks normal (non-RDMA) mounts. I'll figure out why.
>
> OK.
>
> Remember that a Read chunk's length does not have to be
> rounded up. Maybe the transport needs to round up the
> length of the unmarshaled data content on behalf of the
> NFSv4 write decoder.
>

The problem of simply taking write->wr_buflen was that len before that
could have been adjusted by avail value in then non-RDAM mounts.

Again, I'm not sure if this is the right fix. But this one works for
both non-RDMA and RDMA mounts.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2c61c6b..3178997 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1293,7 +1293,10 @@ static __be32 nfsd4_decode_opaque(struct
nfsd4_compoundargs *argp, struct xdr_ne

                len -= avail;

-               pages = len >> PAGE_SHIFT;
+               if (!avail)
+                       pages = write->wr_buflen >> PAGE_SHIFT;
+               else
+                       pages = len >> PAGE_SHIFT;
                argp->pagelist += pages;
                argp->pagelen -= pages * PAGE_SIZE;
                len -= pages * PAGE_SIZE;

>
>>
>>>> If this looks OK, I can send a patch.
>>>> --
>>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>>> the body of a message to majordomo@vger.kernel.org
>>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>>
>>> --
>>> Chuck Lever
>>>
>>>
>>>
>>> --
>>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>>> the body of a message to majordomo@vger.kernel.org
>>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
>
>
>
