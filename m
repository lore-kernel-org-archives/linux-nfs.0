Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:44980 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752470AbdLFOwc (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Dec 2017 09:52:32 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 1/4] nfs: Define NFS_RDMA_PORT
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CANjDDBiTSDfzvj6qLaeEf+-Jx=XA9W2rzA2wW_q45MfauwffPA@mail.gmail.com>
Date: Wed, 6 Dec 2017 09:52:26 -0500
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D1CAA846-EF79-4A1B-9BFE-70EDA1B7BBF5@oracle.com>
References: <20171204190904.18629.70341.stgit@manet.1015granger.net> <20171204191330.18629.77069.stgit@manet.1015granger.net> <CANjDDBg3qsn5oWzmTSi5e3eKJKkdEceh0GUTe+pFDAGCxkDqGg@mail.gmail.com> <06D33DF4-6BAC-411B-8A08-5098E52720C6@oracle.com> <CANjDDBiTSDfzvj6qLaeEf+-Jx=XA9W2rzA2wW_q45MfauwffPA@mail.gmail.com>
To: Devesh Sharma <devesh.sharma@broadcom.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 6, 2017, at 1:04 AM, Devesh Sharma <devesh.sharma@broadcom.com> =
wrote:
>=20
> Oh! apologies if I was not clear what I wanted to say. I was thinking
> this change will avoid the step to write the nfsrdma port number into
> /proc/fs/nfsd/portlist file after starting the nfs server. This is
> step is a part of configuring nfs-rdma server. However, for tcp such
> entries are present by default in this file.

Hi Devesh-

I don't have to do this manually on my server, but maybe that's
because RHEL 7 system start-up scripts already handle it?

Bring this up in a separate thread on linux-nfs@vger.kernel.org
and we can work it out. To answer your original question: no,
I don't believe this patch will change server start-up behavior.


> -Regards
> Devesh
>=20
> On Wed, Dec 6, 2017 at 12:19 AM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>>=20
>>> On Dec 5, 2017, at 10:09 AM, Devesh Sharma =
<devesh.sharma@broadcom.com> wrote:
>>>=20
>>> Hi Chuck,
>>>=20
>>> Will this change avoid the "echo rdma 20049" on the nfs server =
during
>>> nfs server start?
>>=20
>> I'm not familiar with this issue. Is there a bug report ?
>>=20
>>=20
>>> -Regards
>>> Devesh
>>>=20
>>> On Tue, Dec 5, 2017 at 12:43 AM, Chuck Lever =
<chuck.lever@oracle.com> wrote:
>>>> The NFS/RDMA port assignment is specified in Section 9 of RFC 8267.
>>>>=20
>>>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>>>> ---
>>>> include/uapi/linux/nfs.h |    1 +
>>>> 1 file changed, 1 insertion(+)
>>>>=20
>>>> diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
>>>> index 057d22a..946cb62 100644
>>>> --- a/include/uapi/linux/nfs.h
>>>> +++ b/include/uapi/linux/nfs.h
>>>> @@ -12,6 +12,7 @@
>>>>=20
>>>> #define NFS_PROGRAM    100003
>>>> #define NFS_PORT       2049
>>>> +#define NFS_RDMA_PORT  20049
>>>> #define NFS_MAXDATA    8192
>>>> #define NFS_MAXPATHLEN 1024
>>>> #define NFS_MAXNAMLEN  255
>>=20
>> --
>> Chuck Lever
>>=20
>>=20
>>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever



