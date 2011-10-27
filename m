Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39779 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753635Ab1J0UZU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 27 Oct 2011 16:25:20 -0400
Date: Thu, 27 Oct 2011 16:25:14 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, devel@openvz.org
Subject: Re: [PATCH v3 0/3] SUNRPC: rcbind clients virtualization
Message-ID: <20111027202514.GA31669@fieldses.org>
References: <20111027180824.20459.23219.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111027180824.20459.23219.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 27, 2011 at 10:10:43PM +0300, Stanislav Kinsbursky wrote:
> v3:
> 1) First two patches from previous version were squashed.
> 
> This patch-set was created in context of clone of git branch:
> git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git
> and rebased on tag "v3.1".
> 
> This patch-set virtualizes rpcbind clients per network namespace context. IOW,
> each network namespace will have its own pair of rpcbind clients (if they would
> be created by request).
> 
> Note:
> 1) this patch-set depends on "SUNRPC: make rpcbind clients allocated and
> destroyed dynamically" patch-set which has been send earlier.
> 2) init_net pointer is still used instead of current->nsproxy->net_ns,
> because I'm not sure yet about how to virtualize services. I.e. NFS callback
> services will be per netns. NFSd service will be per netns too from my pow. But
> Lockd can be per netns or one for all.

I'm not sure what you mean by that; could you explain?

--b.

> And also we have NFSd file system, which
> is not virtualized yet.
> 
> The following series consists of:
> 
> ---
> 
> Stanislav Kinsbursky (3):
>       SUNRPC: move rpcbind internals to sunrpc part of network namespace context
>       SUNRPC: optimize net_ns dereferencing in rpcbind creation calls
>       SUNRPC: optimize net_ns dereferencing in rpcbind registering calls
> 
> 
>  net/sunrpc/netns.h     |    5 ++
>  net/sunrpc/rpcb_clnt.c |  103 ++++++++++++++++++++++++++----------------------
>  2 files changed, 61 insertions(+), 47 deletions(-)
> 
> -- 
> Signature
