Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:50466 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755007Ab0IJX4B (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 19:56:01 -0400
Date: Fri, 10 Sep 2010 19:56:00 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 08/13] RFC: pnfs: filelayout: introduce minimal file
 layout driver
Message-ID: <20100910235600.GA11231@infradead.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
 <1283450419-5648-9-git-send-email-iisaman@netapp.com>
 <1284147111.10062.74.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1284147111.10062.74.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Sep 10, 2010 at 03:31:51PM -0400, Trond Myklebust wrote:
> > +	tristate
> > +	depends on NFS_FS && NFS_V4_1
> > +	default m
> 
> Should be 'default y', otherwise it has an implicit dependency on
> CONFIG_MODULES.

No, it should not have a default statement at all.  The only reason to
put in a default statement is to keep existing code working when it's
split into multiple options, which this is not.  This is not just my
opinion, btw - Linus has frequently whacked people for introducing pointless
defaults in the past.

And even if it was okay sometimes pnfs nowhere is near important enough
to add it in Kconfig.
