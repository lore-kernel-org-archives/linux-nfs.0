Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56333 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755525Ab2DYSYM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Apr 2012 14:24:12 -0400
Date: Wed, 25 Apr 2012 14:24:09 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [PATCH 0/3] SUNRPC: three bugfixes for PipeFS event handling
Message-ID: <20120425182409.GE751@fieldses.org>
References: <20120420141419.10848.84280.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120420141419.10848.84280.stgit@localhost6.localdomain6>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 20, 2012 at 06:18:59PM +0400, Stanislav Kinsbursky wrote:
> These bugfixes were caught (or noticed) due to the following simple script:

I'm assuming Trond should take these (possibly for 3.4?).

--b.

> 
> ======================================================================
> 
> #!/bin/bash
> service rpcbind stop
> service rpcidmapd stop
> killall -TERM rpc.statd
> umount /var/lib/nfs/rpc_pipefs
> rmmod nfs
> service rpcbind start
> service nfs start
> mount -t rpc_pipefs sunrpc /var/lib/nfs/rpc_pipefs
> 
> =======================================================================
> 
> The following series consists of:
> 
> ---
> 
> Stanislav Kinsbursky (3):
>       SUNRPC: skip clients with program without PipeFS entries
>       SUNRPC: traverse clients tree on PipeFS event
>       SUNRPC: set per-net PipeFS superblock before notification
> 
> 
>  net/sunrpc/clnt.c     |   34 ++++++++++++++++++++++++++++------
>  net/sunrpc/rpc_pipe.c |    3 ++-
>  2 files changed, 30 insertions(+), 7 deletions(-)
> 
