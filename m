Return-Path: linux-nfs-owner@vger.kernel.org
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:48851
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751076Ab2CCJbV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 3 Mar 2012 04:31:21 -0500
Date: Sat, 3 Mar 2012 04:31:16 -0500
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: trond.myklebust@netapp.com, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/12] commit 6f38b4ba433ac6494f83cb73dd07dcbde797e1e0
Message-ID: <20120303093116.GA4661@infradead.org>
References: <20120302215559.12758.39526.stgit@degas.1015granger.net>
 <20120302215931.12758.32538.stgit@degas.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120302215931.12758.32538.stgit@degas.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 02, 2012 at 04:59:31PM -0500, Chuck Lever wrote:
> NFS: Make clientaddr= optional
> 
>     For NFSv4 mounts, the clientaddr= mount option has always been
>     required.  Now we have rpc_localaddr() in the kernel, which was
>     modeled after the same logic in the mount.nfs command that constructs
>     the clientaddr= mount option.  If user space doesn't provide a
>     clientaddr= mount option, the kernel can now construct its own.
> 
>     Signed-off-by: Chuck Lever <chuck.lever@oracle.com>

Something messed up formatting here.

