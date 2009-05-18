From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/2] Two more nfs-utils patches
Date: Mon, 18 May 2009 13:27:55 -0400
Message-ID: <4A119A9B.2050202@RedHat.com>
References: <20090518161224.12029.86761.stgit@seurat.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:44037 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750756AbZERRay (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 May 2009 13:30:54 -0400
In-Reply-To: <20090518161224.12029.86761.stgit-x+BlCsqV7M/wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Chuck Lever wrote:
> Steve-
> 
> While you're at it, here are two more fixes.
> 
> ---
> 
> Chuck Lever (2):
>       umount.nfs: Harden umount.nfs error reporting
>       nfs-utils: Fix IPv6 support in support/nfs/rpc_socket.c
> 
> 
>  support/nfs/rpc_socket.c |   12 +++++-------
>  utils/mount/network.c    |   19 ++++++++++++++-----
>  utils/mount/nfsumount.c  |   17 +++++++++--------
>  3 files changed, 28 insertions(+), 20 deletions(-)
> 

Committed...

steved.
