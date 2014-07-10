Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40958 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750988AbaGJUOv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 10 Jul 2014 16:14:51 -0400
Date: Thu, 10 Jul 2014 16:14:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: hch@infradead.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 00/11] nfsd: deny mode handling overhaul
Message-ID: <20140710201448.GF26561@fieldses.org>
References: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405015655-12469-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 10, 2014 at 02:07:24PM -0400, Jeff Layton wrote:
> Here is the deny mode handling overhaul broken out into a separate
> series, as requested by Christoph. I've tried to address most of
> his review comments, but I may have missed some. Let me know if
> if I did.

They look fine to me; I'll merge them soon absent any objections from
Christoph.

--b.

> 
> Part of the client_mutex removal series involves cleaning up the
> handling of deny modes in the server in order to setting and
> enforcement atomic.
> 
> This does add a new per-nfs4_file spinlock, but in principle it
> should never be contended while the client_mutex is still wrapped
> around all of this code.
> 
> Jeff Layton (8):
>   nfsd: refactor nfs4_file_get_access and nfs4_file_put_access
>   nfsd: remove nfs4_file_put_fd
>   nfsd: shrink st_access_bmap and st_deny_bmap
>   nfsd: set stateid access and deny bits in nfs4_get_vfs_file
>   nfsd: clean up reset_union_bmap_deny
>   nfsd: always hold the fi_lock when bumping fi_access refcounts
>   nfsd: make deny mode enforcement more efficient and close races in it
>   nfsd: cleanup and rename nfs4_check_open
> 
> Trond Myklebust (3):
>   nfsd: Add fine grained protection for the nfs4_file->fi_stateids list
>   nfsd: Add locking to the nfs4_file->fi_fds[] array
>   nfsd: clean up helper __release_lock_stateid
> 
>  fs/nfsd/nfs4state.c | 437 ++++++++++++++++++++++++++++++++++++++--------------
>  fs/nfsd/state.h     |  32 +---
>  2 files changed, 325 insertions(+), 144 deletions(-)
> 
> -- 
> 1.9.3
> 
