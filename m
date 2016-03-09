Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:48534 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933002AbcCIOsK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2016 09:48:10 -0500
Date: Wed, 9 Mar 2016 15:48:07 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] nfsd: add SCSI layout support
Message-ID: <20160309144807.GA650@lst.de>
References: <1457120777-30687-1-git-send-email-hch@lst.de> <1457120777-30687-5-git-send-email-hch@lst.de> <20160308221513.GC27006@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160308221513.GC27006@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> May as well document the server-side config there too, I guess; I'm
> editing that like:
> 
> 	On {+a server built with CONFIG_NFSD_SCSI,+} the[-server,-] pNFS
> 	SCSI volume support is

Fine with me!

