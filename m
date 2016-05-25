Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:46983 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634AbcEYPJT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 May 2016 11:09:19 -0400
Date: Wed, 25 May 2016 17:09:17 +0200
From: Christoph Hellwig <hch@lst.de>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 4/4] nfsd: Provide a config option for flex file layouts
Message-ID: <20160525150917.GC27535@lst.de>
References: <1464152979-103988-1-git-send-email-loghyr@primarydata.com> <1464152979-103988-5-git-send-email-loghyr@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1464152979-103988-5-git-send-email-loghyr@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +config NFSD_FLEXFILELAYOUT
> +	bool "NFSv4.1 server support for pNFS Flex File layouts"
> +	depends on NFSD_V4
> +	select NFSD_PNFS
> +	help
> +	  This option enables support for the exporting pNFS Flex File
> +	  layouts in the kernel's NFS server. The pNFS Flex File  layout
> +	  enables NFS clients to directly perform I/O to NFSv3 devices
> +	  accesible to both the server and the clients.  See
> +	  draft-ietf-nfsv4-flex-files for more details.

How about a bit more of a warning that this is just a toy demo server?

Also I'd say merge this into the previous patch.
