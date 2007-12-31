From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/40] svc: SVC Transport Switch
Date: Mon, 31 Dec 2007 17:13:36 -0500
Message-ID: <20071231221336.GA26470@fieldses.org>
References: <20071231030712.8430.45576.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:41273 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752225AbXLaWNh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Dec 2007 17:13:37 -0500
In-Reply-To: <20071231030712.8430.45576.stgit-gUwIgmpLGaKNDNWfRnPdfg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 30, 2007 at 09:07:12PM -0600, Tom Tucker wrote:
> 
> The Server Side Transport switch implements a pluggable transport
> provider layer for RPC servers. This allows network transport drivers
> to be dynamically loaded and registered, thereby extending the set of
> transports that can carry RPC. This patchset includes a transport
> provider driver for TCP and UDP sockets.
>
> 
> This version of the patchset is functionally equivalent to the
> preceding patchset and includes the following improvements:

Thanks!  Got it.

--b.

> 
> - Fixed a bug in svc_create_socket that resulted in svc_xprt_received
>   being called without holding the XPT_BUSY bit.
> 
> - Added a BUG_ON in svc_xprt_received to catch providers calling
>   svc_xprt_received without holding the XPT_BUSY bit.
> 
> - Removed code setting the XPT_BUSY bit in the create path and moved
>   this logic to common code.
> 
> - Cleaned up the SMP locking strategy comment and moved it to
>   svc_xprt.c
> 
> - Changed return type of svc_unreg_xprt_class to void
> 
> - Simplified transport class removal logic
> 
> - Fixed a white-space abuse issue
>   
> - Made some style changes to the patch comments
> 
> - Created a separate patch that moves the connection limit code to
>   generic logic
> 
> - Created a separate patch that moves the call to svc_xprt_received
>   out of tcp_accept and into common logic
> 
> - Created a separate patch for removal of unnecessary call to
>   svc_sock_enqueue in svc_tcp_accept function
> 
> - Removed silly BUG_ON from kref svc_xprt_free callback function
>   
> - Moved unlock of svc_xprt_class list to after the try_module_lock
>   call.
> 
> - Refactored svc_create_xprt logic
> 
> - Removed unnecessary call to svc_find_xprt in portlist code
> 
> -- 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
