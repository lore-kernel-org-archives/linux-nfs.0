Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:50468 "EHLO newverein.lst.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751560AbdF1Qph (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 28 Jun 2017 12:45:37 -0400
Date: Wed, 28 Jun 2017 18:45:35 +0200
From: Christoph Hellwig <hch@lst.de>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, trond.myklebust@primarydata.com,
        "J. Bruce Fields" <bfields@fieldses.org>, jlayton@poochiereds.net,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] nfs4: add NFSv4 LOOKUPP handlers
Message-ID: <20170628164535.GA8563@lst.de>
References: <20170627154403.20944-1-hch@lst.de> <20170627154403.20944-4-hch@lst.de> <99a3d554-399f-3d02-2033-3962fc00afea@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <99a3d554-399f-3d02-2033-3962fc00afea@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 28, 2017 at 10:55:35AM -0400, Anna Schumaker wrote:
> Hi Christoph,
> 
> On 06/27/2017 11:44 AM, Christoph Hellwig wrote:
> > From: Jeff Layton <jeff.layton@primarydata.com>
> > 
> > This will be needed in order to implement the get_parent export op
> > for nfsd.
> 
> I think this patch conflicts with your constify and function pointer cleanups from a few weeks ago, and it may need to be updated.
> 
> Just double checking:  Bruce, are you taking the constify series for 4.13?

Seems like it's in linux-next through Bruce's tree.

I can respin these patches against it.  Anna, Trond: are you fine
with just basing the nfs tree on top of the nfsd one?  Or do we want
to take this series through the nfsd tree?
