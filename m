Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:16694 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754877Ab1GVSjS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 22 Jul 2011 14:39:18 -0400
Subject: Re: [PATCH 13/13] sunrpc: use SKB fragment destructors to delay
 completion until page is released by network stack.
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org, linux-nfs@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@fieldses.org>
Date: Fri, 22 Jul 2011 14:39:16 -0400
In-Reply-To: <1311340653-19336-13-git-send-email-ian.campbell@citrix.com>
References: <1311340095.12772.57.camel@zakaz.uk.xensource.com>
	 <1311340653-19336-13-git-send-email-ian.campbell@citrix.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1311359956.13553.8.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-07-22 at 14:17 +0100, Ian Campbell wrote: 
> This prevents an issue where an ACK is delayed, a retransmit is queued (either
> at the RPC or TCP level) and the ACK arrives before the retransmission hits the
> wire. If this happens to an NFS WRITE RPC then the write() system call
> completes and the userspace process can continue, potentially modifying data
> referenced by the retransmission before the retransmission occurs.
> 
> Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
> Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Neil Brown <neilb@suse.de>
> Cc: "J. Bruce Fields" <bfields@fieldses.org>
> Cc: linux-nfs@vger.kernel.org
> Cc: netdev@vger.kernel.org
> [since v1:
>   Push down from NFS layer into RPM layer
> ]
> ---
>  include/linux/sunrpc/xdr.h  |    2 ++
>  include/linux/sunrpc/xprt.h |    5 ++++-
>  net/sunrpc/clnt.c           |   27 ++++++++++++++++++++++-----
>  net/sunrpc/svcsock.c        |    2 +-
>  net/sunrpc/xprt.c           |   13 +++++++++++++
>  net/sunrpc/xprtsock.c       |    2 +-
>  6 files changed, 43 insertions(+), 8 deletions(-)

This looks good to me. Thanks, Ian!

Acked-by: Trond Myklebust <Trond.Myklebust@netapp.com>

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

