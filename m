From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: linux-next: nfs client fixup
Date: Wed, 27 Feb 2008 00:16:36 -0800
Message-ID: <1204100196.7327.5.camel@heimdal.trondhjem.org>
References: <20080227165251.f3393be2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-next@vger.kernel.org, linux-nfs@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pat.uio.no ([129.240.10.15]:60243 "EHLO pat.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753909AbYB0IQm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Feb 2008 03:16:42 -0500
In-Reply-To: <20080227165251.f3393be2.sfr@canb.auug.org.au>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Wed, 2008-02-27 at 16:52 +1100, Stephen Rothwell wrote:
> Hi Trond,
> 
> I assume you have already found this, but the current linux-next tree
> fails to build if CONFIG_NFS_V4 is not set and CONFIG_NFS_FS is set.
> 
> s/nfs/client.c:192: error: 'struct nfs_client' has no member named 'cl_rpcwaitq'
> 

Thanks Stephen! I assume I can add a signed-off-by line on your behalf?

Cheers
  Trond

