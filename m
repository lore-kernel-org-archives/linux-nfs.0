Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52434 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965355Ab2EPUGd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 May 2012 16:06:33 -0400
Date: Wed, 16 May 2012 16:06:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH RFC 00/13] Lockd: grace period containerization
Message-ID: <20120516200630.GB20487@fieldses.org>
References: <20120505170722.11559.74503.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120505170722.11559.74503.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, May 05, 2012 at 09:21:30PM +0400, Stanislav Kinsbursky wrote:
> This patch set is marked with RFC, because I'm still not quite sure, that this
> implementation will satisfy other interested people.
> So, would be appreciated for any comments.
> 
> This patch set makes grace period and hosts reclaiming network namespace
> aware.
> 
> Main ideas:
> 1)  moving of 
> 
> 	unsigned long next_gc;
> 	unsigned long nrhosts;
> 
> 	struct delayed_work grace_period_end;
> 	struct lock_manager lockd_manager;
> 	struct list_head grace_list;
> 
> to per-net Lockd data.
> 
> 2) moving of 
> 
> 	struct lock_manager nfsd4_manager;
> 
> to per-net NFSd data.
> 
> 3) shutdown + gc of NLM hosts done now network namespace aware.

That all sounds reasonable to me.

> 4) restart_grace() now works only for init_net.

Eventually we might just remove that.  I doubt it's used anywhere.

--b.

> 
> The following series implements...
> 
> ---
> 
> Stanislav Kinsbursky (13):
>       LockD: mark host per network namespace on garbage collect
>       LockD: make garbage collector network namespace aware.
>       LockD: manage garbage collection timeout per networks namespace
>       LockD: manage used host count per networks namespace
>       Lockd: host complaining function introduced
>       Lockd: add more debug to host shutdown functions
>       LockD: manage grace period per network namespace
>       LockD: make lockd manager allocated per network namespace
>       NFSd: make nfsd4_manager allocated per network namespace context.
>       SUNRPC: service request network namespace helper introduced
>       LockD: manage grace list per network namespace
>       LockD: pass actual network namespace to grace period management functions
>       Lockd: move grace period management from lockd() to per-net functions
> 
> 
>  fs/lockd/grace.c            |   16 +++++--
>  fs/lockd/host.c             |   92 +++++++++++++++++++++++++++++--------------
>  fs/lockd/netns.h            |    7 +++
>  fs/lockd/svc.c              |   43 ++++++++++++--------
>  fs/lockd/svc4proc.c         |   13 +++---
>  fs/lockd/svclock.c          |   16 ++++---
>  fs/lockd/svcproc.c          |   15 ++++---
>  fs/lockd/svcsubs.c          |   19 ++++++---
>  fs/nfs/callback_xdr.c       |    4 +-
>  fs/nfsd/export.c            |    4 +-
>  fs/nfsd/netns.h             |    2 +
>  fs/nfsd/nfs4idmap.c         |    4 +-
>  fs/nfsd/nfs4proc.c          |   18 +++++---
>  fs/nfsd/nfs4state.c         |   60 ++++++++++++++++------------
>  fs/nfsd/state.h             |    3 +
>  include/linux/fs.h          |    5 +-
>  include/linux/lockd/lockd.h |    6 +--
>  include/linux/sunrpc/svc.h  |    2 +
>  18 files changed, 204 insertions(+), 125 deletions(-)
> 
