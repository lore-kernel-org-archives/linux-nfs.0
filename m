Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:53869 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751138Ab3KKUau convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 15:30:50 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix pnfs Kconfig defaults
Date: Mon, 11 Nov 2013 20:30:48 +0000
Message-ID: <6C8CF6D6-0456-4195-B00B-F35A37B64E12@netapp.com>
References: <20131102102201.GA3860@infradead.org>
In-Reply-To: <20131102102201.GA3860@infradead.org>
Content-Type: text/plain; charset="Windows-1252"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Nov 2, 2013, at 6:22, Christoph Hellwig <hch@infradead.org> wrote:

> Defaulting to m seem to prevent building the pnfs layout modules into the
> kernel.  Default to the value of CONFIG_NFS_FS make sure they are
> built in for a built-in NFS and modular for a modular NFS.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
> fs/nfs/Kconfig |    6 +++---
> 1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index b5e80b0..f731180 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -116,17 +116,17 @@ config NFS_V4_2
> config PNFS_FILE_LAYOUT
> 	tristate
> 	depends on NFS_V4_1
> -	default m
> +	default NFS_FS

Shouldn’t that really be
	default NFS_V4
in order to get the dependency right? The current Kconfig does allow you to have nfs built in, while leaving NFSv4 as a module.

