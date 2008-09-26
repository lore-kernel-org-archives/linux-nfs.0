From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/2] SUNRPC: Register both netids for AF_INET6 servers
Date: Fri, 26 Sep 2008 17:17:36 -0400
Message-ID: <20080926211736.GA7138@fieldses.org>
References: <20080915212437.3939.82594.stgit@ellison.1015granger.net> <20080915212723.3939.23359.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: okir@suse.de, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50040 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983AbYIZVRn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Sep 2008 17:17:43 -0400
In-Reply-To: <20080915212723.3939.23359.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 15, 2008 at 04:27:23PM -0500, Chuck Lever wrote:
...
> We've recently determined that this is incorrect behavior.  In the
> TI-RPC world, "udp6" is not meant to imply that the registered RPC
> service handles requests from AF_INET as well, even if the listener
> socket does address mapping.  "udp" and "udp6" are entirely separate
> capabilities, and must be registered separately.
> 
> The Linux kernel, unlike TI-RPC, leverages address mapping to allow a
> single listener socket to handle requests for both AF_INET and AF_INET6.
> This is still OK, but the kernel currently assumes registering "udp6"
> will cover "udp" as well.  It registers only "udp6" for it's AF_INET6
> services, even though they handle both AF_INET and AF_INET6 on the same
> port.
> 
> So svc_register() actually needs to register both "udp" and "udp6"
> explicitly (and likewise for TCP).  Until rpcbind is fixed, the
> kernel can ignore the return code for the second RPCB_SET call.

Looks fine, thanks, applied.

> Please merge this with commit 15231312:
> 
>     SUNRPC: Support IPv6 when registering kernel RPC services

That was actually a pretty helpful commit message; I'm tempted just to
leave this unmerged and not worry too much about the briefly-existing
bug in this case.

--b.
