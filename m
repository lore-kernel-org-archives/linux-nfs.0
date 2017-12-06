Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f170.google.com ([209.85.128.170]:35236 "EHLO
        mail-wr0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752062AbdLFGFI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 01:05:08 -0500
Received: by mail-wr0-f170.google.com with SMTP id g53so2633905wra.2
        for <linux-nfs@vger.kernel.org>; Tue, 05 Dec 2017 22:05:07 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <06D33DF4-6BAC-411B-8A08-5098E52720C6@oracle.com>
References: <20171204190904.18629.70341.stgit@manet.1015granger.net>
 <20171204191330.18629.77069.stgit@manet.1015granger.net> <CANjDDBg3qsn5oWzmTSi5e3eKJKkdEceh0GUTe+pFDAGCxkDqGg@mail.gmail.com>
 <06D33DF4-6BAC-411B-8A08-5098E52720C6@oracle.com>
From: Devesh Sharma <devesh.sharma@broadcom.com>
Date: Wed, 6 Dec 2017 11:34:26 +0530
Message-ID: <CANjDDBiTSDfzvj6qLaeEf+-Jx=XA9W2rzA2wW_q45MfauwffPA@mail.gmail.com>
Subject: Re: [PATCH v1 1/4] nfs: Define NFS_RDMA_PORT
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Oh! apologies if I was not clear what I wanted to say. I was thinking
this change will avoid the step to write the nfsrdma port number into
/proc/fs/nfsd/portlist file after starting the nfs server. This is
step is a part of configuring nfs-rdma server. However, for tcp such
entries are present by default in this file.

-Regards
Devesh

On Wed, Dec 6, 2017 at 12:19 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>
>> On Dec 5, 2017, at 10:09 AM, Devesh Sharma <devesh.sharma@broadcom.com> wrote:
>>
>> Hi Chuck,
>>
>> Will this change avoid the "echo rdma 20049" on the nfs server during
>> nfs server start?
>
> I'm not familiar with this issue. Is there a bug report ?
>
>
>> -Regards
>> Devesh
>>
>> On Tue, Dec 5, 2017 at 12:43 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> The NFS/RDMA port assignment is specified in Section 9 of RFC 8267.
>>>
>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>> ---
>>> include/uapi/linux/nfs.h |    1 +
>>> 1 file changed, 1 insertion(+)
>>>
>>> diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
>>> index 057d22a..946cb62 100644
>>> --- a/include/uapi/linux/nfs.h
>>> +++ b/include/uapi/linux/nfs.h
>>> @@ -12,6 +12,7 @@
>>>
>>> #define NFS_PROGRAM    100003
>>> #define NFS_PORT       2049
>>> +#define NFS_RDMA_PORT  20049
>>> #define NFS_MAXDATA    8192
>>> #define NFS_MAXPATHLEN 1024
>>> #define NFS_MAXNAMLEN  255
>
> --
> Chuck Lever
>
>
>
