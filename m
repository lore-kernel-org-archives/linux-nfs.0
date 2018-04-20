Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:40596 "EHLO
        mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751130AbeDTRaT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Apr 2018 13:30:19 -0400
Received: by mail-io0-f181.google.com with SMTP id t123-v6so11408128iof.7
        for <linux-nfs@vger.kernel.org>; Fri, 20 Apr 2018 10:30:19 -0700 (PDT)
Subject: Re: [PATCH v8 00/13] NFS support for async intra COPY
To: Olga Kornievskaia <kolga@netapp.com>,
        Trond.Myklebust@primarydata.com, anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
References: <20180413170314.17634-1-kolga@netapp.com>
From: Anna Schumaker <schumaker.anna@gmail.com>
Message-ID: <caa5e13f-ba11-e414-0f71-4c26d7572faa@gmail.com>
Date: Fri, 20 Apr 2018 13:30:16 -0400
MIME-Version: 1.0
In-Reply-To: <20180413170314.17634-1-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Olga,

On 04/13/2018 01:03 PM, Olga Kornievskaia wrote:
> Change the client side to always request an asynchronous copy.
> 
> If server replies to the COPY with the copy stateid, client will go
> wait on the CB_OFFLOAD. To fend off the race between CB_OFFLOAD and
> COPY reply, we check the list of pending callbacks before going to
> wait. Client adds the copy to the global list of copy stateids for the
> callback to look thru and signal the waiting copy.
> 
> When the client receives reply from the CB_OFFLOAD with some bytes and
> committed how is UNSTABLE, then COMMIT is sent to the server. The results
> are propagated to the VFS and application. Assuming that application
> will deal with a partial result and continue from the new offset if needed.
> 
> If server errs with ERR_OFFLOAD_NOREQS the copy will be re-sent as a
> synchronous COPY. If application cancels an in-flight COPY,
> OFFLOAD_CANCEL is sent to the server (sending it as an async RPC in the
> context of the nfsid_workqueue).
> 
> v8. 
> - added patch 13 to handle reboot recovery of the server or network
> partition. this patch was a part of the initial "inter async" series
> but never got added to the async series. without this patch if the
> server goes away, thread that was doing the copy would be hanging
> waiting for the callback that would never arrive.
> 
> 
> 
> Anna Schumaker (1):
>   fs: Don't copy beyond the end of the file
> 
> Olga Kornievskaia (12):
>   NFS CB_OFFLOAD xdr
>   NFS OFFLOAD_STATUS xdr
>   NFS OFFLOAD_STATUS op

I'm still not sold on adding in offload status on the client without a way to use it.  Can you rearrange this series so offload status is at the very end?  That way we can add it in later, if there is ever an interface for copy statuses.

Anna

>   NFS OFFLOAD_CANCEL xdr
>   NFS COPY xdr handle async reply
>   NFS add support for asynchronous COPY
>   NFS handle COPY reply CB_OFFLOAD call race
>   NFS export nfs4_async_handle_error
>   NFS send OFFLOAD_CANCEL when COPY killed
>   NFS handle COPY ERR_OFFLOAD_NO_REQS
>   NFS add a simple sync nfs4_proc_commit after async COPY
>   NFS recover from destination server reboot for copies
> 
>  fs/nfs/callback.h         |  12 +++
>  fs/nfs/callback_proc.c    |  54 ++++++++++
>  fs/nfs/callback_xdr.c     |  81 ++++++++++++++-
>  fs/nfs/client.c           |   1 +
>  fs/nfs/nfs42.h            |   5 +-
>  fs/nfs/nfs42proc.c        | 251 ++++++++++++++++++++++++++++++++++++++++++++--
>  fs/nfs/nfs42xdr.c         | 189 +++++++++++++++++++++++++++++++---
>  fs/nfs/nfs4_fs.h          |   8 +-
>  fs/nfs/nfs4client.c       |  15 +++
>  fs/nfs/nfs4file.c         |   9 +-
>  fs/nfs/nfs4proc.c         |  38 ++++++-
>  fs/nfs/nfs4state.c        |  15 +++
>  fs/nfs/nfs4xdr.c          |   2 +
>  fs/read_write.c           |   3 +
>  include/linux/nfs4.h      |   2 +
>  include/linux/nfs_fs.h    |  11 ++
>  include/linux/nfs_fs_sb.h |   4 +
>  include/linux/nfs_xdr.h   |  14 +++
>  18 files changed, 689 insertions(+), 25 deletions(-)
> 
