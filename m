Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45638 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751432AbaFDT4o (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Jun 2014 15:56:44 -0400
Date: Wed, 4 Jun 2014 15:56:43 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: trond.myklebust@primarydata.com, bhalevy@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 0/9] nfsd: bugfixes and preliminary patches for
 client_mutex removal
Message-ID: <20140604195643.GA5603@fieldses.org>
References: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1401455373-18207-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 30, 2014 at 09:09:24AM -0400, Jeff Layton wrote:
> Hi Bruce!
> 
> This patchset contains some bugfixes and preliminary patches for
> the client_mutex removal work. I'm sending these out first as they
> either fix bugs or don't add extra locking that's only nested inside
> the client_mutex anyway.
> 
> These are based on your nfsd-next tree. Patch #3 fixes a (possibly
> minor?) bug in the fi_delegations list handling, and might be suitable
> for stable based on that. I haven't cc'ed stable on it as I can't quite
> convince myself it's a real problem, but it might be reasonable to do
> so anyway.

It looks innocent enough, so I'm adding the stable cc:.

I'm dropping patch 9 ("NFSd: protect delegation setup with the i_lock")
and applying the others.

--b.

> 
> Benny Halevy (3):
>   nfsd4: use recall_lock for delegation hashing
>   nfsd4: rename recall_lock to state_lock
>   nfsd4: hash deleg stateid only on successful nfs4_set_delegation
> 
> Jeff Layton (4):
>   nfsd: make nfsd4_encode_fattr static
>   nfsd: fix laundromat next-run-time calculation
>   nfsd: fix setting of NFS4_OO_CONFIRMED in nfsd4_open
>   nfsd: remove unneeded zeroing of fields in nfsd4_proc_compound
> 
> Trond Myklebust (2):
>   NFSd: Protect addition to the file_hashtbl
>   NFSd: protect delegation setup with the i_lock
> 
>  fs/nfsd/nfs4callback.c |  18 +++++-
>  fs/nfsd/nfs4proc.c     |   6 +-
>  fs/nfsd/nfs4state.c    | 168 ++++++++++++++++++++++++++++++-------------------
>  fs/nfsd/nfs4xdr.c      |   2 +-
>  fs/nfsd/state.h        |   1 +
>  5 files changed, 124 insertions(+), 71 deletions(-)
> 
> -- 
> 1.9.3
> 
