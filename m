Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59356 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932150AbcHHT7t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Aug 2016 15:59:49 -0400
Date: Mon, 8 Aug 2016 15:59:48 -0400
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 0/2] Eliminate race between LOCK and FREE_STATEID
Message-ID: <20160808195948.GB6539@fieldses.org>
References: <20160808184711.11661.86427.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160808184711.11661.86427.stgit@klimt.1015granger.net>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 08, 2016 at 02:59:35PM -0400, Chuck Lever wrote:
> This series passes light testing in my lab. If it looks good I will
> pass it along to Alexey to confirm it closes the race.
> 
> To aid distributors and stable kernel maintainers, wondering if a
> Fixes: tag should be added. Alexey first observed this issue in v4.1
> kernels (UEK4). But looks like the race could have been introduced
> as early as v3.17. Maybe this one?

The other reason we didn't see this till now might be client-side
changes (maybe b4019c0e219b "NFSv4.1: Allow parallel LOCK/LOCKU
calls"?).  (Not trying to dodge responsibility for a server-side bug
here, but that might still be useful information for the changelog (not
the Fixes: line) if it's correct.)

--b.

> 
> commit fc5a96c3b70d00c863f69ff4ea7f5dfddbcbc0d8
> Author: Jeff Layton <jlayton@primarydata.com>
> Date:   Tue Jul 29 21:34:40 2014 -0400
> 
>     nfsd: close potential race in nfsd4_free_stateid
> 
> There have been a lot of changes since then. It's hard to say if the
> race can be attributed to a single commit.
> 
> 
> Changes since v2:
> - Move NFS4_LOCK_STID arm into a helper, for clarity
> - Add more detail to patch description
> - Add Jeff's patch to fix similar race in nfsd4_lock
> 
> Changes since v1:
> - Use s->sc_count to preserve stateid while cl_lock is dropped
> 
> ---
> 
> Chuck Lever (1):
>       nfsd: Fix race between FREE_STATEID and LOCK
> 
> Jeff Layton (1):
>       nfsd: don't return an unhashed lock stateid after taking mutex
> 
> 
>  fs/nfsd/nfs4state.c |   65 ++++++++++++++++++++++++++++++++++++++-------------
>  1 file changed, 48 insertions(+), 17 deletions(-)
> 
> --
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
