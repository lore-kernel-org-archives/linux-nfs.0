Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38916 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933112Ab2KNWAi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 17:00:38 -0500
Date: Wed, 14 Nov 2012 17:00:36 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Subject: Re: [RFC PATCH v2 00/15] NFSd state containerization
Message-ID: <20121114220036.GD539@fieldses.org>
References: <20121114152018.4708.63125.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121114152018.4708.63125.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 14, 2012 at 06:20:59PM +0300, Stanislav Kinsbursky wrote:
> This patch set is my first attempt to containerize NFSv4 state - i.e. make it
> works in networks namespace context.
> I admit, that some of this new code could be partially rewritten during future
> NFSd containerization.
> But the overall idea look more or less correct to me.
> So, the main things here are:
> 1) making nfs4_client network namespace aware.
> 2) Allocating all hashes (except file_hashtbl and reclaim_str_hashtbl) per
> network namespace context on NFSd start (not init) and destroying on NFSd
> state shutdown.
> 3) Allocating of reclaim_str_hashtbl on legacy tracker start and destroying on
> legacy tracker stop.
> 4) Moving of client_lru and close_lru lists to per-net data.
> 5) Making lundromat network namespace aware.

These look OK and pass my tests.  Jeff, do the revised recovery bits
look OK?

Have you done any testing?

It'd be interesting, for example, to know if there are any pynfs that
fail against the server in a non-init network namespace, but pass
normally.

--b.

> 
> v2:
> 1) Rebased on current nfsd-next.
> 2) Legacy tracker init become clearer.
> 
> The following series implements...
> 
> ---
> 
> Stanislav Kinsbursky (15):
>       nfsd: use service net instead of hard-coded net where possible
>       nfsd: make nfs4_client network namespace dependent
>       nfsd: make reclaim_str_hashtbl allocated per net
>       nfsd: make conf_id_hashtbl allocated per net
>       nfsd: make conf_name_tree per net
>       nfsd: make unconf_id_hashtbl allocated per net
>       nfsd: make unconf_name_tree per net
>       nfsd: make ownerstr_hashtbl allocated per net
>       nfsd: make lockowner_ino_hashtbl allocated per net
>       nfsd: make sessionid_hashtbl allocated per net
>       nfsd: make client_lru list per net
>       nfsd: make close_lru list per net
>       nfsd: use service net instead of hard-coded init_net
>       nfsd: pass nfsd_net instead of net to grace enders
>       nfsd: make laundromat network namespace aware
> 
> 
>  fs/nfsd/netns.h        |   43 +++++
>  fs/nfsd/nfs4callback.c |    2 
>  fs/nfsd/nfs4proc.c     |   13 +
>  fs/nfsd/nfs4recover.c  |  102 ++++++++---
>  fs/nfsd/nfs4state.c    |  450 +++++++++++++++++++++++++++---------------------
>  fs/nfsd/state.h        |   17 +-
>  fs/nfsd/xdr4.h         |    2 
>  7 files changed, 389 insertions(+), 240 deletions(-)
> 
