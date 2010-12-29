Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48838 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752897Ab0L2U7n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Dec 2010 15:59:43 -0500
Date: Wed, 29 Dec 2010 15:59:42 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Cc: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] svcrpc: modifying positive sunrpc cache entries is racy
Message-ID: <20101229205942.GD12218@fieldses.org>
References: <20101229204752.GC12218@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101229204752.GC12218@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 29, 2010 at 03:47:52PM -0500, bfields wrote:
> From: J. Bruce Fields <bfields@redhat.com>
> 
> Once a sunrpc cache entry is non-NEGATIVE, we should be replacing it
> (and allowing any concurrent users to destroy it on last put) instead of
> trying to update it in place.
> 
> Otherwise someone referencing the ip_map we're modifying here could try
> to use the m_client just as we're putting the last reference.
> 
> The bug should only be seen by users of the legacy nfsd interfaces.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  net/sunrpc/svcauth_unix.c |   18 ++++++++++++++++--
>  1 files changed, 16 insertions(+), 2 deletions(-)
> 
> Intended to apply for 2.6.38 if this looks right....

Also noticed while trying to track down an rhel5 oops in
svcauth_unix_set_client():

	- cache_check() can set an entry negative in place, which if
	  nothing else must cause a leak in some cases.  (Because when
	  the entry is eventually destroyed, it will be assumed to not
	  have any contents.)  I suppose the fix is again to try to
	  adding a new negative entry instead.

	- since cache_check() doesn't use any locking, I can't see what
	  guarantees that when it sees the CACHE_VALID bit set and
	  CACHE_NEGATIVE cleared, it must necessarily see the new
	  contents.   I think that'd be fixed by a wmb() before setting
	  those bits and a rmb() after checking them.  I don't know if
	  it's actually possible to hit that bug....

--b.
