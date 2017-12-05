Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp2130.oracle.com ([141.146.126.79]:35868 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751416AbdLESuB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Dec 2017 13:50:01 -0500
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Subject: Re: [PATCH v1 1/4] nfs: Define NFS_RDMA_PORT
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CANjDDBg3qsn5oWzmTSi5e3eKJKkdEceh0GUTe+pFDAGCxkDqGg@mail.gmail.com>
Date: Tue, 5 Dec 2017 13:49:56 -0500
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        linux-rdma <linux-rdma@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <06D33DF4-6BAC-411B-8A08-5098E52720C6@oracle.com>
References: <20171204190904.18629.70341.stgit@manet.1015granger.net> <20171204191330.18629.77069.stgit@manet.1015granger.net> <CANjDDBg3qsn5oWzmTSi5e3eKJKkdEceh0GUTe+pFDAGCxkDqGg@mail.gmail.com>
To: Devesh Sharma <devesh.sharma@broadcom.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Dec 5, 2017, at 10:09 AM, Devesh Sharma =
<devesh.sharma@broadcom.com> wrote:
>=20
> Hi Chuck,
>=20
> Will this change avoid the "echo rdma 20049" on the nfs server during
> nfs server start?

I'm not familiar with this issue. Is there a bug report ?


> -Regards
> Devesh
>=20
> On Tue, Dec 5, 2017 at 12:43 AM, Chuck Lever <chuck.lever@oracle.com> =
wrote:
>> The NFS/RDMA port assignment is specified in Section 9 of RFC 8267.
>>=20
>> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>> ---
>> include/uapi/linux/nfs.h |    1 +
>> 1 file changed, 1 insertion(+)
>>=20
>> diff --git a/include/uapi/linux/nfs.h b/include/uapi/linux/nfs.h
>> index 057d22a..946cb62 100644
>> --- a/include/uapi/linux/nfs.h
>> +++ b/include/uapi/linux/nfs.h
>> @@ -12,6 +12,7 @@
>>=20
>> #define NFS_PROGRAM    100003
>> #define NFS_PORT       2049
>> +#define NFS_RDMA_PORT  20049
>> #define NFS_MAXDATA    8192
>> #define NFS_MAXPATHLEN 1024
>> #define NFS_MAXNAMLEN  255

--
Chuck Lever



