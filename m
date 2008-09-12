From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] More IPv6 support for lockd
Date: Fri, 12 Sep 2008 18:12:34 -0400
Message-ID: <20080912221234.GI22126@fieldses.org>
References: <20080903183411.16867.33715.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:59175 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756631AbYILWMf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Sep 2008 18:12:35 -0400
In-Reply-To: <20080903183411.16867.33715.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 03, 2008 at 02:35:31PM -0400, Chuck Lever wrote:
> Hi Bruce-
> 
> Here's the next set of IPv6-related patches for lockd.  Please consider these
> for 2.6.28.

Thanks; applied to

	git://linux-nfs.org/~bfields/linux.git for-2.6.28

--b.

> 
> ---
> 
> Chuck Lever (7):
>       lockd: Update nsm_find() to support non-AF_INET addresses
>       lockd: Combine __nsm_find() and nsm_find().
>       lockd: Support AF_INET6 when hashing addresses in nlm_lookup_host
>       lockd: Teach nlm_cmp_addr() to support AF_INET6 addresses
>       NSM: Use sockaddr_storage for sm_addr field
>       lockd: Use sockaddr_storage for h_saddr field
>       lockd: Use sockaddr_storage + length for h_addr field
> 
> 
>  fs/lockd/clntlock.c         |    3 +
>  fs/lockd/host.c             |  115 ++++++++++++++++++++++++++++---------------
>  fs/lockd/mon.c              |    2 -
>  fs/lockd/svcsubs.c          |    2 -
>  include/linux/lockd/lockd.h |   79 +++++++++++++++++++++++++++---
>  5 files changed, 149 insertions(+), 52 deletions(-)
> 
> -- 
> Chuck Lever
