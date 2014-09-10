Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:33245 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751754AbaIJWMC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 10 Sep 2014 18:12:02 -0400
Date: Wed, 10 Sep 2014 15:12:02 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>, Anna.Schumaker@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] VFS: Rename do_fallocate() to vfs_fallocate()
Message-ID: <20140910221202.GB29452@infradead.org>
References: <1410274182-30740-1-git-send-email-Anna.Schumaker@Netapp.com>
 <1410274182-30740-2-git-send-email-Anna.Schumaker@Netapp.com>
 <20140909155019.GA21928@infradead.org>
 <20140910194342.GF4210@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140910194342.GF4210@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 10, 2014 at 03:43:42PM -0400, J. Bruce Fields wrote:
> On Tue, Sep 09, 2014 at 08:50:19AM -0700, Christoph Hellwig wrote:
> > On Tue, Sep 09, 2014 at 10:49:40AM -0400, Anna.Schumaker@netapp.com wrote:
> > > From: Anna Schumaker <Anna.Schumaker@netapp.com>
> > > 
> > > This function needs to be exported so it can be used by the NFSD module
> > > when responding to ALLOCATE and DEALLOCATE operations.  Christoph Hellwig
> > > suggested renaming the function to match how other vfs functions are named.
> > > 
> > > Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
> > 
> > Looks good,
> > 
> > Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> I'd like to be able to take this into through the nfsd tree if the nfsd
> patches are going to depend on it.
> 
> Anna, on next posting maybe you could make sure to cc: the reelevant
> people (I'm not sure who...) so I can get the right ACKs for that?

Cc Al and fsdevel, please.

