From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 0/2] complex block layout
Date: Mon, 26 Jul 2010 09:58:27 +0300
Message-ID: <4C4D3213.9050506@panasas.com>
References: <cover.1279743856.git.rees@umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: Jim Rees <rees@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:49685 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753335Ab0GZG6a (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Jul 2010 02:58:30 -0400
In-Reply-To: <cover.1279743856.git.rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jul. 22, 2010, 1:29 +0300, Jim Rees <rees@umich.edu> wrote:
> This is a replacement for the patch set I sent last week, rebased to current
> pnfs-all-latest and incorporating suggestions both from reviewers and from
> checkpatch.pl.
> 
> These two patches move the complex block layout device mapping from the
> kernel to a user space daemon.  The first patch adds a simple upcall
> mechanism via pipefs for the kernel piece to communicate with the daemon.
> The second patch removes the kernel device mapping and replaces it with
> calls to the daemon.
> 
> Passes Connectathon tests to both EMC and spnfs servers.
> 
> The user daemon will be sent separately as a patch to nfs-utils.

Jim, I've merged these patches only into the pnfs-block branch,
not pnfs-block-all (part of the pnfs-all-latest chain), until
we get the user mode daemon into pnfs-nfs-utils.  Once there.
I'll merge the patches also into pnfs-block-all.

Benny

> 
> Haiying Tang (2):
>   pnfs-block: Add support for simple rpc pipefs
>   pnfs-block: Remove device creation from kernel
> 
>  fs/nfs/blocklayout/Makefile                      |    2 +-
>  fs/nfs/blocklayout/block-device-discovery-pipe.c |   66 +++
>  fs/nfs/blocklayout/blocklayout.c                 |   15 +-
>  fs/nfs/blocklayout/blocklayout.h                 |   18 +-
>  fs/nfs/blocklayout/blocklayoutdev.c              |  494 +++-------------------
>  fs/nfs/blocklayout/blocklayoutdm.c               |  297 ++-----------
>  include/linux/sunrpc/rpc_pipe_fs.h               |    4 +
>  include/linux/sunrpc/simple_rpc_pipefs.h         |  111 +++++
>  net/sunrpc/Makefile                              |    2 +-
>  net/sunrpc/simple_rpc_pipefs.c                   |  424 +++++++++++++++++++
>  10 files changed, 721 insertions(+), 712 deletions(-)
>  create mode 100644 fs/nfs/blocklayout/block-device-discovery-pipe.c
>  create mode 100644 include/linux/sunrpc/simple_rpc_pipefs.h
>  create mode 100644 net/sunrpc/simple_rpc_pipefs.c
> 
