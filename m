Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1033 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751551Ab1ITLUv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 20 Sep 2011 07:20:51 -0400
Date: Tue, 20 Sep 2011 07:24:06 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Subject: Re: [PATCH v4 0/8] SUNRPC: make rpcbind clients allocated and
 destroyed dynamically
Message-ID: <20110920072406.378f5ebd@corrin.poochiereds.net>
In-Reply-To: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
References: <20110920101031.9861.18444.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 20 Sep 2011 14:13:32 +0400
Stanislav Kinsbursky <skinsbursky@parallels.com> wrote:

> v4:
> 1) creation and destruction on rpcbind clients now depends on service program
> versions "vs_hidden" flag.
> 
> This patch is required for further RPC layer virtualization, because rpcbind
> clients have to be per network namespace.
> To achive this, we have to untie network namespace from rpcbind clients sockets.
> The idea of this patch set is to make rpcbind clients non-static. I.e. rpcbind
> clients will be created during first RPC service creation, and destroyed when
> last RPC service is stopped.
> With this patch set rpcbind clients can be virtualized easely.
> 
> 
> The following series consists of:
> 
> ---
> 
> Stanislav Kinsbursky (8):
>       SUNRPC: introduce helpers for reference counted rpcbind clients
>       SUNRPC: use rpcbind reference counting helpers
>       SUNRPC: introduce svc helpers for prepairing rpcbind infrastructure
>       SUNRPC: setup rpcbind clients if service requires it
>       SUNRPC: cleanup service destruction
>       NFSd: call svc rpcbind cleanup explicitly
>       SUNRPC: remove rpcbind clients creation during service registering
>       SUNRPC: remove rpcbind clients destruction on module cleanup
> 
> 
>  fs/nfsd/nfssvc.c            |    2 +
>  include/linux/sunrpc/clnt.h |    2 +
>  include/linux/sunrpc/svc.h  |    1 +
>  net/sunrpc/rpcb_clnt.c      |   85 ++++++++++++++++++++++++++++---------------
>  net/sunrpc/sunrpc_syms.c    |    3 --
>  net/sunrpc/svc.c            |   48 +++++++++++++++++++++++-
>  6 files changed, 105 insertions(+), 36 deletions(-)
> 

Patchset looks good to me. The only remaining thing I think is to set
vs_hidden on nfs4_callback_version4, but that patch is orthogonal to
this set.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
