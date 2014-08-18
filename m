Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59140 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751066AbaHRUE4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Aug 2014 16:04:56 -0400
Date: Mon, 18 Aug 2014 16:04:56 -0400
To: Jeff Layton <jlayton@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [nfs-utils RFC PATCH 0/7] nfs-utils: support for lifting grace
 period early
Message-ID: <20140818200456.GC1096@fieldses.org>
References: <1408113915-5573-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1408113915-5573-1-git-send-email-jlayton@primarydata.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for working on this, it's currently a major annoyance!

On Fri, Aug 15, 2014 at 10:45:08AM -0400, Jeff Layton wrote:
> This patchset adds some support to sm-notify and nfsdcltrack for lifting
> the grace periods early. Allowing this actually work depends on the
> companion kernel patchset, but the approach I've taken here should deal
> properly with userland/kernel mismatch.
> 
> There are two main pieces:
> 
> sm-notify: in the event that sm-notify isn't sending any NOTIFY
> requests, we don't expect to see any reclaims from clients. In that
> case, we should be able to safely lift the lockd grace period early.
> The first patch in the series implements this (though we'll probably
> need a bit of selinux work to get that working in Fedora under enforcing
> mode).
> 
> nfsdcltrack: if there are no v4.0 clients and all v4.1+ clients have
> issued a RECLAIM_COMPLETE, then we can go ahead and end the nfsd grace
> period. The remainder of the patchset adds the support for this. This
> requires revving the DB schema for it, and making use of the environment
> variables that are passed to the upcall by the kernel.

And we get to skip the grace period on first start, and on any restart
during which no clients hold state, which seem like big improvements on
their own.

Mostly a pointless digression, but I've been wondering if there are any
further improvements that are worth it.  I'm feeling skeptical:

As long as nobody uses deny modes we could deal with them with a big
dumb hammer (e.g. synchronously record something if anyone requests one,
insist on a full grace period if they do).

But we're still stuck blocking all new opens as long as there are
delegations outstanding.  (Well, maybe only new read opens, until we get
write delegations.)

Would it work to record a count of delegations on shutdown, to speed up
the restart-after-clean-shutdown case?  And if it worked, would it be
worth the effort?  (Alternatively on shutdown we could stop giving out
delegations, recall everything, and wait till we had no delegations till
shutting down completely.  Wonder how painful that would be.)

So anyway maybe our best bet is just to hope people upgrade to 4.1 soon.

--b.

> 
> Again, this is just an RFC set for now. Does anyone have thoughts or
> comments on the general approach?
> 
> Jeff Layton (7):
>   sm-notify: inform the kernel if there were no hosts to notify
>   nfsdcltrack: update comments in sqlite.c
>   nfsdcltrack: rename CLD_* constants with CLTRACK_* prefixes
>   nfsdcltrack: overhaul database initializtion
>   nfsdcltrack: update schema to v2
>   nfsdcltrack: grab the client minorversion from the env var if it's
>     present
>   nfsdcltrack: fetch NFSDCLTRACK_GRACE_START out of environment
> 
>  utils/nfsdcltrack/nfsdcltrack.c | 106 +++++++++++-
>  utils/nfsdcltrack/sqlite.c      | 375 ++++++++++++++++++++++++++++++----------
>  utils/nfsdcltrack/sqlite.h      |   5 +-
>  utils/statd/sm-notify.c         |  25 +++
>  4 files changed, 413 insertions(+), 98 deletions(-)
> 
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
