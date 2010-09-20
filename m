Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:40743 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752543Ab0ITPRs convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Sep 2010 11:17:48 -0400
Received: by bwz11 with SMTP id 11so4315296bwz.19
        for <linux-nfs@vger.kernel.org>; Mon, 20 Sep 2010 08:17:47 -0700 (PDT)
In-Reply-To: <4C976E81.9040001@panasas.com>
References: <1284779874-10499-1-git-send-email-iisaman@netapp.com>
	<1284779874-10499-7-git-send-email-iisaman@netapp.com>
	<4C973A86.6050008@panasas.com>
	<AANLkTi=3CA+2e6GRytZkFTLbv6Mya7cfRm_iSkvVxXWh@mail.gmail.com>
	<4C976E81.9040001@panasas.com>
Date: Mon, 20 Sep 2010 11:17:47 -0400
Message-ID: <AANLkTin3mabp5XBy8ivYisDaBSskXw9bK9A_-JQT8ozo@mail.gmail.com>
Subject: Re: [PATCH 06/12] RFC: nfs: set layout driver
From: Fred Isaman <iisaman@netapp.com>
To: Benny Halevy <bhalevy@panasas.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Sep 20, 2010 at 10:24 AM, Benny Halevy <bhalevy@panasas.com> wrote:
> On 2010-09-20 16:06, Fred Isaman wrote:
>> On Mon, Sep 20, 2010 at 6:42 AM, Benny Halevy <bhalevy@panasas.com> wrote:
>>> On 2010-09-18 05:17, Fred Isaman wrote:
>>>> From: The pNFS Team <linux-nfs@vger.kernel.org>
>>>>
>>>> Put in the infrastructure that uses information returned from the
>>>> server at mount to select a layout driver module.
>>>>
>>>> In this patch, a stub is used that always returns "no driver found".
>>>>
>>>> Signed-off-by: TBD - melding/reorganization of several patches
>>>> ---
>>>>  fs/nfs/Makefile           |    1 +
>>>>  fs/nfs/client.c           |    4 ++
>>>>  fs/nfs/pnfs.c             |   78 +++++++++++++++++++++++++++++++++++++++++++++
>>>>  fs/nfs/pnfs.h             |   56 ++++++++++++++++++++++++++++++++
>>>>  include/linux/nfs_fs.h    |    1 +
>>>>  include/linux/nfs_fs_sb.h |    1 +
>>>>  6 files changed, 141 insertions(+), 0 deletions(-)
>>>>  create mode 100644 fs/nfs/pnfs.c
>>>>  create mode 100644 fs/nfs/pnfs.h
>>>>
>>>> diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
>>>> index da7fda6..bb9e773 100644
>>>> --- a/fs/nfs/Makefile
>>>> +++ b/fs/nfs/Makefile
>>>> @@ -15,5 +15,6 @@ nfs-$(CONFIG_NFS_V4)        += nfs4proc.o nfs4xdr.o nfs4state.o nfs4renewd.o \
>>>>                          delegation.o idmap.o \
>>>>                          callback.o callback_xdr.o callback_proc.o \
>>>>                          nfs4namespace.o
>>>> +nfs-$(CONFIG_NFS_V4_1)       += pnfs.o
>>>>  nfs-$(CONFIG_SYSCTL) += sysctl.o
>>>>  nfs-$(CONFIG_NFS_FSCACHE) += fscache.o fscache-index.o
>>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>>>> index 4e7df2a..eed1212 100644
>>>> --- a/fs/nfs/client.c
>>>> +++ b/fs/nfs/client.c
>>>> @@ -48,6 +48,7 @@
>>>>  #include "iostat.h"
>>>>  #include "internal.h"
>>>>  #include "fscache.h"
>>>> +#include "pnfs.h"
>>>>
>>>>  #define NFSDBG_FACILITY              NFSDBG_CLIENT
>>>>
>>>> @@ -898,6 +899,8 @@ static void nfs_server_set_fsinfo(struct nfs_server *server, struct nfs_fsinfo *
>>>>       if (server->wsize > NFS_MAX_FILE_IO_SIZE)
>>>>               server->wsize = NFS_MAX_FILE_IO_SIZE;
>>>>       server->wpages = (server->wsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
>>>> +     set_pnfs_layoutdriver(server, fsinfo->layouttype);
>>>> +
>>>
>>> Originally (9170cf5 pnfs_submit: set and unset pnfs layoutdriver modules),
>>> nfs4_init_pnfs called set_pnfs_layoutdriver under the following conditions:
>>>
>>>        if (nfs4_has_session(clp) &&
>>>            (clp->cl_exchange_flags & EXCHGID4_FLAG_USE_PNFS_MDS))
>>>                set_pnfs_layoutdriver(server, fsinfo->layouttype);
>>>
>>> So in the DS only case we don't want to set server->pnfs_curr_ld.
>>> did you test your code with a standalone DS to make there are no
>>> ill side effects in this case?
>>>
>>
>> This is called from the mount code.  It is never called for a DS
>> (unless the DS is also a MDS, in which case it will be called in the
>> MDS role).
>
> So at least let's add a BUG_ON and a comment since we're relying on
> side effects of code implemented elsewhere.
>

OK.


> Benny
>
> P.S. I wonder what happens if you try to explicitly mount a DS
> (which is not an MDS).
>
>

Note there are two possibilities here, DS only, or DS and normal NFS
server (but not a MDS).

In the second case, the mount should work, and it does.  In the first,
the client should abort when it sees the EXCHID flags (which it
doesn't...this needs to be fixed) or when the server sends
NFS4ERR_NOTSUPP to the PUTROOTFH, which it MUST do.

Fred
