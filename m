Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45129 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751615Ab1LHUqv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Dec 2011 15:46:51 -0500
Date: Thu, 8 Dec 2011 15:46:48 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, davem@davemloft.net, devel@openvz.org
Subject: Re: [PATCH 0/4] SUNRPC: pass network namespace context to sockaddr
 construction routines
Message-ID: <20111208204648.GB32505@fieldses.org>
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111207111716.17273.63010.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 07, 2011 at 03:20:07PM +0300, Stanislav Kinsbursky wrote:
> This is another precursor patch set aimed to remove hard-coded "init_net"
> reference from SUNRPC sockaddr convertion and construction routines.

ACK--all look straightforward.  (Only complaint would be that this isn't
terribly interesting till we see how these are used.)

--b.


> 
> The following series consists of:
> 
> ---
> 
> Stanislav Kinsbursky (4):
>       SUNRPC: use passed network namespace context in rpc_parse_scope_id()
>       SUNRPC: use passed network namespace context in rpc_pton6()
>       SUNRPC: use passed network namespace context in rpc_pton()
>       SUNRPC: use passed network namespace context in rpc_uaddr2sockaddr()
> 
> 
>  fs/nfs/dns_resolve.c        |    4 ++--
>  fs/nfs/nfs4filelayoutdev.c  |    2 +-
>  fs/nfs/nfs4namespace.c      |    2 +-
>  fs/nfs/super.c              |    4 ++--
>  fs/nfsd/nfs4state.c         |    2 +-
>  fs/nfsd/nfsctl.c            |    2 +-
>  include/linux/sunrpc/clnt.h |    4 ++--
>  net/sunrpc/addr.c           |   24 +++++++++++++-----------
>  net/sunrpc/rpcb_clnt.c      |    2 +-
>  net/sunrpc/svcauth_unix.c   |    2 +-
>  10 files changed, 25 insertions(+), 23 deletions(-)
> 
> -- 
> Signature
