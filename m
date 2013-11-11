Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41375 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024Ab3KKVBl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 16:01:41 -0500
Date: Mon, 11 Nov 2013 13:01:41 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix pnfs Kconfig defaults
Message-ID: <20131111210141.GB13942@infradead.org>
References: <20131102102201.GA3860@infradead.org>
 <6C8CF6D6-0456-4195-B00B-F35A37B64E12@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <6C8CF6D6-0456-4195-B00B-F35A37B64E12@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 11, 2013 at 08:30:48PM +0000, Myklebust, Trond wrote:
> > diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> > index b5e80b0..f731180 100644
> > --- a/fs/nfs/Kconfig
> > +++ b/fs/nfs/Kconfig
> > @@ -116,17 +116,17 @@ config NFS_V4_2
> > config PNFS_FILE_LAYOUT
> > 	tristate
> > 	depends on NFS_V4_1
> > -	default m
> > +	default NFS_FS
> 
> Shouldn?t that really be
> 	default NFS_V4
> in order to get the dependency right? The current Kconfig does allow you to have nfs built in, while leaving NFSv4 as a module.

Probably should.  For some reason I had NFS_V4_1 in mind as a bool.
