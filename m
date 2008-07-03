From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/7] Remaining rpcbind patches for 2.6.27
Date: Thu, 3 Jul 2008 16:45:43 -0400
Message-ID: <20080703204543.GI30918@fieldses.org>
References: <20080630223646.24534.74654.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39176 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753659AbYGCUqq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Jul 2008 16:46:46 -0400
In-Reply-To: <20080630223646.24534.74654.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 30, 2008 at 06:38:35PM -0400, Chuck Lever wrote:
> Hi Trond-
> 
> Seven patches that implement kernel RPC service registration via rpcbind v4.
> This allows the kernel to advertise IPv4-only services on hosts with IPv6
> addresses, for example.

This is Trond's baliwick, but I read through all 7 quickly and they
looked good to me....

--b.

> 
> ---
> 
> Chuck Lever (7):
>       SUNRPC: Support registering IPv6 interfaces with local rpcbind daemon
>       SUNRPC: Quickly detect missing portmapper during RPC service registration
>       SUNRPC: introduce new rpc_task flag that fails requests on xprt disconnect
>       SUNRPC: Refactor rpcb_register to make rpcbindv4 support easier
>       SUNRPC: None of rpcb_create's callers wants a privileged source port
>       SUNRPC: Introduce a specific rpcb_create for contacting localhost
>       SUNRPC: Use correct XDR encoding procedure for rpcbind SET/UNSET
> 
> 
>  include/linux/sunrpc/clnt.h  |    3 
>  include/linux/sunrpc/sched.h |    2 
>  net/sunrpc/clnt.c            |    2 
>  net/sunrpc/rpcb_clnt.c       |  290 +++++++++++++++++++++++++++++++++++++-----
>  4 files changed, 263 insertions(+), 34 deletions(-)
> 
> -- 
> Chuck Lever
> chu ckl eve rat ora cle dot com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
