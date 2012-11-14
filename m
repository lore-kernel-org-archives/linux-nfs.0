Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60840 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932997Ab2KNWss (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 17:48:48 -0500
Date: Wed, 14 Nov 2012 17:48:46 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: bjschuma@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 00/10] NFSD: Improve fault injection
Message-ID: <20121114224846.GE539@fieldses.org>
References: <1351630254-26166-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1351630254-26166-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 30, 2012 at 04:50:44PM -0400, bjschuma@netapp.com wrote:
> From: Bryan Schumaker <bjschuma@netapp.com>
> 
> While working on p2p-nfs, I discovered that I sometimes need to clear
> state for a specific client to test all possible error recovery conditions.
> The current fault injection code deletes state as it find it, so it can
> be difficult to guess which state will be forgotten.  In addition, I
> currently print out the amount of state forgotten but I don't give details
> like "Forgot 3 locks from client w.x.y.z".  These patches set out to
> improve that.
> 
> The first 7 patches clean up the current code and prepare it for specific
> client state removal.  Patch 8 adds prints information to the server's logs
> when a fault injection file is read (such as "Client w.x.y.z has 3 open
> files").  Patch 9 adds in a custom file operations structure so users can
> write strings to fault injection files in addition to u64s.  Finally, patch
> 10 allows users to remove state by writing a client's IP address to one of
> the files.

Apologies for putting you off again, but: I'd like to get Stanislav's
patches sorted out first.  I think that shouldn't take too long--bug me
in another week or so if I haven't come back to these by then.  These
may need a little rebasing at that point.

--b.

> 
> Changes in v2:
> - Patches apply cleanly to the most recent nfsd-next branch
> - Improve printk() output
> 
> Questions, comments and suggestions are appreciated!
> 
> - Bryan
> 
> Bryan Schumaker (10):
>   NFSD: Fold fault_inject.h into state.h
>   NFSD: Lock state before calling fault injection function
>   NFSD: Clean up forgetting clients
>   NFSD: Clean up forgetting locks
>   NFSD: Clean up forgetting openowners
>   NFSD: Clean up forgetting and recalling delegations
>   NFSD: Fault injection operations take a per-client forget function
>   NFSD: Reading a fault injection file prints a state count
>   NFSD: Add a custom file operations structure for fault injection
>   NFSD: Forget state for a specific client
> 
>  fs/nfsd/fault_inject.c | 112 ++++++++++++++++++++++++++----
>  fs/nfsd/fault_inject.h |  28 --------
>  fs/nfsd/nfs4state.c    | 181 +++++++++++++++++++++++++++++++------------------
>  fs/nfsd/nfsctl.c       |   2 +-
>  fs/nfsd/state.h        |  23 +++++++
>  5 files changed, 235 insertions(+), 111 deletions(-)
>  delete mode 100644 fs/nfsd/fault_inject.h
> 
> -- 
> 1.8.0
> 
