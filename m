Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:4981 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755038Ab0IKAEF convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Sep 2010 20:04:05 -0400
Subject: Re: [PATCH 08/13] RFC: pnfs: filelayout: introduce minimal file
 layout driver
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Fred Isaman <iisaman@netapp.com>, linux-nfs@vger.kernel.org
In-Reply-To: <20100910235600.GA11231@infradead.org>
References: <1283450419-5648-1-git-send-email-iisaman@netapp.com>
	 <1283450419-5648-9-git-send-email-iisaman@netapp.com>
	 <1284147111.10062.74.camel@heimdal.trondhjem.org>
	 <20100910235600.GA11231@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 10 Sep 2010 20:03:53 -0400
Message-ID: <1284163433.14078.102.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-09-10 at 19:56 -0400, Christoph Hellwig wrote:
> On Fri, Sep 10, 2010 at 03:31:51PM -0400, Trond Myklebust wrote:
> > > +	tristate
> > > +	depends on NFS_FS && NFS_V4_1
> > > +	default m
> > 
> > Should be 'default y', otherwise it has an implicit dependency on
> > CONFIG_MODULES.
> 
> No, it should not have a default statement at all.  The only reason to
> put in a default statement is to keep existing code working when it's
> split into multiple options, which this is not.  This is not just my
> opinion, btw - Linus has frequently whacked people for introducing pointless
> defaults in the past.
> 
> And even if it was okay sometimes pnfs nowhere is near important enough
> to add it in Kconfig.

So you are saying we should simply equate CONFIG_PNFS_FILE_LAYOUT and
CONFIG_NFS_V4_1 right now? Yep, I'd be fine with that... I'm still
working on the patches to get rid of all these CONFIG options, but
ultimately this is what I'm working towards.

Cheers
  Trond
