Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:34049 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752573AbdLFQnP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 11:43:15 -0500
Received: by mail-wm0-f67.google.com with SMTP id y82so23793967wmg.1
        for <linux-nfs@vger.kernel.org>; Wed, 06 Dec 2017 08:43:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <D1CAA846-EF79-4A1B-9BFE-70EDA1B7BBF5@oracle.com>
References: <20171204190904.18629.70341.stgit@manet.1015granger.net>
 <20171204191330.18629.77069.stgit@manet.1015granger.net> <CANjDDBg3qsn5oWzmTSi5e3eKJKkdEceh0GUTe+pFDAGCxkDqGg@mail.gmail.com>
 <06D33DF4-6BAC-411B-8A08-5098E52720C6@oracle.com> <CANjDDBiTSDfzvj6qLaeEf+-Jx=XA9W2rzA2wW_q45MfauwffPA@mail.gmail.com>
 <D1CAA846-EF79-4A1B-9BFE-70EDA1B7BBF5@oracle.com>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Wed, 6 Dec 2017 22:12:33 +0530
Message-ID: <CANjDDBijcxCvjFqspHKXyRk+ESK_SCBj6MfJktOLszGc0JG7UQ@mail.gmail.com>
Subject: Re: [PATCH v1 1/4] nfs: Define NFS_RDMA_PORT
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Okay, Thanks for the response.

On Wed, Dec 6, 2017 at 8:22 PM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>> On Dec 6, 2017, at 1:04 AM, Devesh Sharma <devesh.sharma@broadcom.com> wrote:
>>
>> Oh! apologies if I was not clear what I wanted to say. I was thinking
>> this change will avoid the step to write the nfsrdma port number into
>> /proc/fs/nfsd/portlist file after starting the nfs server. This is
>> step is a part of configuring nfs-rdma server. However, for tcp such
>> entries are present by default in this file.
>
> Hi Devesh-
>
> I don't have to do this manually on my server, but maybe that's
> because RHEL 7 system start-up scripts already handle it?
>
> Bring this up in a separate thread on linux-nfs@vger.kernel.org
> and we can work it out. To answer your original question: no,
> I don't believe this patch will change server start-up behavior.
>
>
>> -Regards
>> Devesh
>>
>> On Wed, Dec 6, 2017 at 12:19 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>
>>>> On Dec 5, 2017, at 10:09 AM, Devesh Sharma <devesh.sharma@broadcom.com> wrote:
>>>>
>>>> Hi Chuck,
>>>>
>>>> Will this change avoid the "echo rdma 20049" on the nfs server during
>>>> nfs server start?
>>>
>>> I'm not familiar with this issue. Is there a bug report ?
>>>
>>>
>>>> -Regards
>>>> Devesh
>>>>
>>>> On Tue, Dec 5, 2017 at 12:43 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>>>> The NFS/RDMA port assignment is specified in Section 9 of RFC 8267.
>>>>>
>>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>>> ---
>>>>> include/uapi/linux/nfs.h |    1 +
>>>>> 1 file changed, 1 insertion(+)
>>>>>
>>>>> diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
>>>>> index 057d22a..946cb62 100644
>>>>> --- a/include/uapi/linux/nfs.h
>>>>> +++ b/include/uapi/linux/nfs.h
>>>>> @@ -12,6 +12,7 @@
>>>>>
>>>>> #define NFS_PROGRAM    100003
>>>>> #define NFS_PORT       2049
>>>>> +#define NFS_RDMA_PORT  20049
>>>>> #define NFS_MAXDATA    8192
>>>>> #define NFS_MAXPATHLEN 1024
>>>>> #define NFS_MAXNAMLEN  255
>>>
>>> --
>>> Chuck Lever
>>>
>>>
>>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
> --
> Chuck Lever
>
>
>
