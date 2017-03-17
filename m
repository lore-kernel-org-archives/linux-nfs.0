Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f43.google.com ([209.85.214.43]:38889 "EHLO
        mail-it0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751207AbdCQVVy (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Mar 2017 17:21:54 -0400
Received: by mail-it0-f43.google.com with SMTP id m27so42583499iti.1
        for <linux-nfs@vger.kernel.org>; Fri, 17 Mar 2017 14:21:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170302160142.30413-1-kolga@netapp.com>
References: <20170302160142.30413-1-kolga@netapp.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 17 Mar 2017 17:21:52 -0400
Message-ID: <CAN-5tyGHaXgWnZAeKghcXVwMOufU-v-geSpxtSqy6=FC8sUWow@mail.gmail.com>
Subject: Re: [RFC v1 00/17] NFSD support for inter+async COPY
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Bruce,

Any comments on this?

Should I separate out the async copy support and send it out like I
did for the client side? I guess the idea is to get the async first
and then add inter when the VFS layer situation is resolved?


On Thu, Mar 2, 2017 at 11:01 AM, Olga Kornievskaia <kolga@netapp.com> wrote:
> This is server-side support for NFSv4.2 inter and async COPY which is
> on top of existing intra sync COPY. It also depends on the NFS client
> piece for NFSv4.2 to do client side of the destination server piece
> in the inter SSC.
>
> NFSD determines if COPY is intra or inter and if sync or async. For
> inter, NSFD uses NFSv4.1 protocol and creates an internal mount point
> (superblock). It will destroy the mount point when copy is done.
>
> To do asynchronous copies, NFSD creates a single threaded workqueue
> and does not tie up an NFSD thread to complete the copy. Upon receiving
> the COPY, it generates a unique copy stateid (stores a global list
> for keeping track of state for OFFLOAD_STATUS to be queried by),
> queues up a workqueue for the copy, and replies back to the client.
> nfsd4_copy arguments that are allocated on the stack are copied for
> the work item.
>
> In the async copy handler, it calls into VFS copy_file_range() with
> 4MB chunks and loops until it completes the requested copy size. If
> error is encountered it's saved but also we save the amount of data
> copied so far. Once done, the results are queued for the callback
> workqueue and sent via CB_OFFLOAD. Also currently, choosing to clean
> up the copy state information stored in the global list when cope is
> done and not doing it when callback's release function (it could be
> done there alternatively if needed it?).
>
> On the source server, upon receiving a COPY_NOTIFY, it generate a
> unique stateid that's kept in the global list. Upon receiving a READ
> with a stateid, the code checks the normal list of open stateid and
> now additionally, it'll check the copy state list as well before
> deciding to either fail with BAD_STATEID or find one that matches.
> The stored stateid is only valid to be used for the first time
> with a choosen lease period (90s currently). When the source server
> received an OFFLOAD_CANCEL, it will remove the stateid from the
> global list. Otherwise, the copy stateid is removed upon the removal
> of its "parent" stateid (open/lock/delegation stateid).
>
>
> Andy Adamson (7):
>   NFSD add ca_source_server<> to COPY
>   NFSD generalize nfsd4_compound_state flag names
>   NFSD: allow inter server COPY to have a STALE source server fh
>   NFSD return nfs4_stid in nfs4_preprocess_stateid_op
>   NFSD add COPY_NOTIFY operation
>   NFSD add nfs4 inter ssc to nfsd4_copy
>   NFSD Unique stateid_t for inter server to server COPY authentication
>
> Olga Kornievskaia (10):
>   NFSD CB_OFFLOAD xdr
>   NFSD OFFLOAD_STATUS xdr
>   NFSD OFFLOAD_CANCEL xdr
>   NFSD xdr callback stateid in async COPY reply
>   NFSD first draft of async copy
>   NFSD handle OFFLOAD_CANCEL op
>   NFSD stop queued async copies on client shutdown
>   NFSD create new stateid for async copy
>   NFSD define EBADF in nfserrno
>   NFSD support OFFLOAD_STATUS
>
>  fs/nfsd/Kconfig        |  10 +
>  fs/nfsd/netns.h        |   8 +
>  fs/nfsd/nfs4callback.c |  95 +++++++
>  fs/nfsd/nfs4proc.c     | 704 ++++++++++++++++++++++++++++++++++++++++++++++---
>  fs/nfsd/nfs4state.c    | 142 +++++++++-
>  fs/nfsd/nfs4xdr.c      | 266 ++++++++++++++++++-
>  fs/nfsd/nfsctl.c       |   2 +
>  fs/nfsd/nfsd.h         |   2 +
>  fs/nfsd/nfsproc.c      |   1 +
>  fs/nfsd/state.h        |  32 ++-
>  fs/nfsd/xdr4.h         |  53 +++-
>  fs/nfsd/xdr4cb.h       |  10 +
>  include/linux/nfs4.h   |   1 +
>  13 files changed, 1273 insertions(+), 53 deletions(-)
>
> --
> 1.8.3.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
