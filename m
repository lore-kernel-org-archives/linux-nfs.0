Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45493 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753256Ab1KWQ1O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Nov 2011 11:27:14 -0500
Date: Wed, 23 Nov 2011 11:27:11 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org, xemul@parallels.com,
        neilb@suse.de, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, davem@davemloft.net, devel@openvz.org
Subject: Re: [PATCH 0/6] SUNRPC: make RPC clients use
 network-namespace-aware PipeFS routines
Message-ID: <20111123162711.GA30672@fieldses.org>
References: <20111123104945.11077.10270.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20111123104945.11077.10270.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 23, 2011 at 02:51:10PM +0300, Stanislav Kinsbursky wrote:
> This patch set was created in context of clone of git
> branch: git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git.
> tag: v3.1
> 
> This patch set depends on previous patch sets titled:
> 1) "SUNRPC: initial part of making pipefs work in net ns"
> 2) "SUNPRC: cleanup PipeFS for network-namespace-aware users"

Do you have a git tree set up with all of these applied?

(If I want to take a quick look it would personally be easier for me to
fetch your git tree than to get those patches out of old email.)

--b.

> 
> This patch set is a first part of reworking SUNPRC PipeFS users.
> It makes SUNRPC clients using PipeFS nofitications for directory and GSS pipes
> dentries creation. With this patch set RPC clients and GSS auth creations
> routines doesn't force SUNRPC PipeFS mount point creation which actually means,
> that they now can work without PipeFS dentries.
> 
> The following series consists of:
> 
> ---
> 
> Stanislav Kinsbursky (6):
>       SUNRPC: handle RPC client pipefs dentries by network namespace aware routines
>       SUNRPC: handle GSS AUTH pipes by network namespace aware routines
>       SUNRPC: subscribe RPC clients to pipefs notifications
>       SUNRPC: remove RPC client pipefs dentries after unregister
>       SUNRPC: remove RPC pipefs mount point manipulations from RPC clients code
>       SUNRPC: remove RPC PipeFS mount point reference from RPC client
> 
> 
>  fs/nfs/idmap.c                 |    4 +
>  fs/nfsd/nfs4callback.c         |    2 -
>  include/linux/nfs.h            |    2 -
>  include/linux/sunrpc/auth.h    |    2 +
>  include/linux/sunrpc/clnt.h    |    2 -
>  net/sunrpc/auth_gss/auth_gss.c |  101 +++++++++++++++++++++------
>  net/sunrpc/clnt.c              |  151 +++++++++++++++++++++++++++++++---------
>  net/sunrpc/rpc_pipe.c          |   19 +++--
>  net/sunrpc/sunrpc.h            |    2 +
>  9 files changed, 218 insertions(+), 67 deletions(-)
> 
> -- 
> Signature
