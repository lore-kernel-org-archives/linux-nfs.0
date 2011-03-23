Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34838 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932773Ab1CWP0W convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Mar 2011 11:26:22 -0400
Subject: Re: [PATCH 0/4] RFC: RPC over AF_LOCAL, kernel client-side
Content-Type: text/plain; charset=us-ascii
From: Andy Adamson <andros@netapp.com>
In-Reply-To: <20110322220518.4360.51304.stgit@matisse.1015granger.net>
Date: Wed, 23 Mar 2011 11:26:05 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <B08BDAF0-04A9-42ED-ACCE-6291E0F6BF4E@netapp.com>
References: <20110322220518.4360.51304.stgit@matisse.1015granger.net>
To: Chuck Lever <chuck.lever@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Are you reviving the "RPC Upcall" that I implemented 10 years ago?

-->Andy

On Mar 22, 2011, at 6:08 PM, Chuck Lever wrote:

> Just for sh*ts and giggles, I threw together a partial implementation
> of RPC over AF_LOCAL sockets, and taught the kernel rpcbind client to
> use it for registering in-kernel RPC services.
> 
> It's still a little rough around the edges.  Any thoughts?
> 
> ---
> 
> Chuck Lever (4):
>      SUNRPC: Use AF_LOCAL for rpcbind upcalls
>      SUNRPC: Support for RPC over AF_LOCAL transports
>      SUNRPC: Rename xs_encode_tcp_fragment_header()
>      SUNRPC: Clean up use of curly braces in switch cases
> 
> 
> include/linux/sunrpc/msg_prot.h |    1 
> include/linux/sunrpc/xprt.h     |    3 
> net/sunrpc/clnt.c               |   25 +-
> net/sunrpc/rpcb_clnt.c          |   97 ++++++++-
> net/sunrpc/svc.c                |    2 
> net/sunrpc/xprtsock.c           |  417 ++++++++++++++++++++++++++++++++++++++-
> 6 files changed, 506 insertions(+), 39 deletions(-)
> 
> -- 
> Chuck Lever
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

