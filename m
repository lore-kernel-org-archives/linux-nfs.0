Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47640 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752503AbdIATlc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 1 Sep 2017 15:41:32 -0400
Date: Fri, 1 Sep 2017 15:41:31 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [RFC v1 00/17] NFSD support for inter+async COPY
Message-ID: <20170901194130.GA27922@parsley.fieldses.org>
References: <20170302160142.30413-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170302160142.30413-1-kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Apologies, remind me:

	- does wireshark have support for all of this?  (Or are there
	  patches?)
	- How are you testing?
	- What's the status of the client side?
	- Do we have any user documentation?  Does the client or server
	  administrator need to do any special setup, or is it just a
	  matter of exporting and mounting over 4.1 and calling
	  copy_file_range()?
	- what currently happens if you try to copy across krb5 mounts?

--b.

On Thu, Mar 02, 2017 at 11:01:24AM -0500, Olga Kornievskaia wrote:
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
