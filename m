Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:51760 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752035AbcKRUWF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 18 Nov 2016 15:22:05 -0500
Date: Fri, 18 Nov 2016 15:22:02 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        stable@vger.kernel.org
Subject: Re: [GIT PULL] another nfsd bugfix for 4.9
Message-ID: <20161118202202.GE5424@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20161118191008.GB5424@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Also, this commit (ea08e39230e8 "sunrpc: svc_age_temp_xprts_now should
not call setsockopt non-tcp transports") fixes a bug going back to 4.5,
so should have been tagged for stable.

--b.

On Fri, Nov 18, 2016 at 02:10:08PM -0500, bfields wrote:
> Please pull:
> 
>   git://linux-nfs.org/~bfields/linux.git tags/nfsd-4.9-2
> 
> Just one fix for an NFS/RDMA crash.
> 
> --b.
> 
> Scott Mayhew (1):
>       sunrpc: svc_age_temp_xprts_now should not call setsockopt non-tcp transports
> 
>  include/linux/sunrpc/svc_xprt.h          |  1 +
>  net/sunrpc/svc_xprt.c                    | 11 +----------
>  net/sunrpc/svcsock.c                     | 21 +++++++++++++++++++++
>  net/sunrpc/xprtrdma/svc_rdma_transport.c |  6 ++++++
>  4 files changed, 29 insertions(+), 10 deletions(-)
