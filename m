Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59842 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726890AbeHIXBY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 9 Aug 2018 19:01:24 -0400
Date: Thu, 9 Aug 2018 16:34:53 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v10 0/9] NFSD support for async COPY
Message-ID: <20180809203450.GE14104@parsley.fieldses.org>
References: <20180720221925.50744-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180720221925.50744-1-kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, I've added these to my -next branch, and I want to read through
them tomorrow.

--b.

On Fri, Jul 20, 2018 at 06:19:16PM -0400, Olga Kornievskaia wrote:
> From: Olga Kornievskaia <olga.kornievskaia@gmail.com>
> 
> To do asynchronous copies, NFSD creates a new kthread to handle the request.
> Upon receiving the COPY, it generates a unique copy stateid (stored in a
> global list for keeping track of state for OFFLOAD_STATUS to be queried by),
> starts the thread, and replies back to the client. nfsd4_copy arguments that
> are allocated on the stack are copies for the kthread.
> 
> For the async copy handler, copy is done in the loop for the requested
> number of bytes. If an error is encountered and partial copy has happened,
> a successful partial copy is returned in the CB_OFFLOAD. vfs_copy_file_range
> is called with 4MB chunks for both async and sync, allowing for 4MB
> granularity of OFFLOAD_STATUS queiry. Once copy is done, the results are
> queued for the callback workqueue and sent via CB_OFFLOAD.
> 
> When the server received an OFFLOAD_CANCEL, it will find the kthread running
> the copy and will send a SIGPENDING and kthread_stop() and it will interrupt
> the ongoing do_splice() and once vfs returns we are choosing not to send
> the CB_OFFLOAD back to the client.
> 
> When the server receives an OFFLOAD_STATUS, it will find the kthread running
> the copy and will locate within the copy state the current number of bytes
> copied so far.
> 
> v10:
> -- removed the module parameter
> -- nfsd4_init_copy_res() changed to void
> -- freed async_copy in nfsd4_copy() on an error case caught by kbuild
> 
> Olga Kornievskaia (9):
>   NFSD CB_OFFLOAD xdr
>   NFSD OFFLOAD_STATUS xdr
>   NFSD OFFLOAD_CANCEL xdr
>   NFSD xdr callback stateid in async COPY reply
>   NFSD introduce async copy feature
>   NFSD create new stateid for async copy
>   NFSD handle OFFLOAD_CANCEL op
>   NFSD support OFFLOAD_STATUS
>   NFSD stop ongoing async copies on client shutdown
> 
>  fs/nfsd/netns.h        |   8 ++
>  fs/nfsd/nfs4callback.c |  98 +++++++++++++++++
>  fs/nfsd/nfs4proc.c     | 293 ++++++++++++++++++++++++++++++++++++++++++++++---
>  fs/nfsd/nfs4state.c    |  38 ++++++-
>  fs/nfsd/nfs4xdr.c      |  50 +++++++--
>  fs/nfsd/nfsctl.c       |   1 +
>  fs/nfsd/state.h        |  10 ++
>  fs/nfsd/xdr4.h         |  28 +++++
>  fs/nfsd/xdr4cb.h       |  10 ++
>  9 files changed, 512 insertions(+), 24 deletions(-)
> 
> -- 
> 1.8.3.1
> 
