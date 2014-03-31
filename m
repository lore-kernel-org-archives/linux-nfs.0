Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:46726 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750987AbaCaVht (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 31 Mar 2014 17:37:49 -0400
Date: Mon, 31 Mar 2014 17:37:48 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 0/5][RESEND]NFSD/SUNRPC: Fix memory leak for the
 backchannel
Message-ID: <20140331213748.GE20024@fieldses.org>
References: <532FAC85.20909@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <532FAC85.20909@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 24, 2014 at 11:54:45AM +0800, Kinglong Mee wrote:
> When using pynfs test-site, I found some memory leak for the backchannel.

All applied, thanks.--b.

> 
> Kinglong Mee (5):
>   NFSD: Using free_conn free connection
>   NFSD: Free backchannel xprt in bc_destroy
>   SUNRPC: New helper for creating client with rpc_xprt
>   NFSD/SUNRPC: Check rpc_xprt out of xs_setup_bc_tcp
>   SUNRPC: Clear xpt_bc_xprt if xs_setup_bc_tcp failed
> 
>  fs/nfsd/nfs4callback.c      | 19 ++++++++++++++-
>  fs/nfsd/nfs4state.c         |  3 ++-
>  include/linux/sunrpc/clnt.h |  2 ++
>  include/linux/sunrpc/xprt.h | 13 +++++++++-
>  net/sunrpc/clnt.c           | 58 ++++++++++++++++++++++++++-------------------
>  net/sunrpc/xprt.c           | 12 ----------
>  net/sunrpc/xprtsock.c       | 15 +++++-------
>  7 files changed, 73 insertions(+), 49 deletions(-)
> 
> -- 
> 1.8.5.3
