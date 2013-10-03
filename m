Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48318 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751628Ab3JCNRw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Oct 2013 09:17:52 -0400
Date: Thu, 3 Oct 2013 06:17:50 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Ric Wheeler <rwheeler@redhat.com>
Cc: Benny Halevy <bhalevy@primarydata.com>,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        Steven Whitehouse <swhiteho@redhat.com>,
        Bob Peterson <rpeterso@redhat.com>, Abhijith Das <adas@redhat.com>,
        Andrew Price <anprice@redhat.com>, Paul Evans <pevans@redhat.com>
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
Message-ID: <20131003131750.GA23408@infradead.org>
References: <52481B11.2080407@primarydata.com>
 <20130929122130.GI21083@infradead.org>
 <20130929123553.GA7510@infradead.org>
 <20131001203047.GH16245@pad.fieldses.org>
 <524C0556.9070705@primarydata.com>
 <20131002160759.GB27988@infradead.org>
 <524D0873.40602@primarydata.com>
 <20131003095511.GA30147@infradead.org>
 <524D6312.7020709@primarydata.com>
 <524D6D38.1040506@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <524D6D38.1040506@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 03, 2013 at 09:12:24AM -0400, Ric Wheeler wrote:
> >>>Which in-tree or soon in-tree filesystem do you care about?  And why
> >>>don't we see pnfs support for it submitted instead of the fairly useless
> >>>gfs2 support?
> >I picked gfs2 as the initial use case for simplicity and ease of review.
> >If there is a rough consensus that it's useless and not worthy of inclusion
> >then the one we care about the most is exofs that has a more complete pnfs
> >implementation.
> >
> >Benny
> >
> 
> I don't see having GFS2 supported as a base for pNFS as useless.
> Christoph, is this a concern about GFS2 being too complicated for
> normal deployment or a lack in the pNFS support on top of it?

Fairly useless was specific to the particular implementation:

 - which in the stipped down version here only supports DS access for
   reads
 - which in the previous version showed worse performance than always
   going through the MDS

I don't have a problem with using GFS2 by itself, but any implementation
proposed should actually show signifiant real life benefits before it
gets merged.

