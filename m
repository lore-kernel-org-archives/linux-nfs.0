Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:39249 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750835AbbAKLmp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Jan 2015 06:42:45 -0500
Date: Sun, 11 Jan 2015 12:42:42 +0100
From: Christoph Hellwig <hch@lst.de>
To: Tom Haynes <thomas.haynes@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 03/18] nfsd: factor out a helper to decode nfstime4
	values
Message-ID: <20150111114242.GA11939@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de> <1420561721-9150-4-git-send-email-hch@lst.de> <20150109230202.GB107259@kitty>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150109230202.GB107259@kitty>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 09, 2015 at 03:02:02PM -0800, Tom Haynes wrote:
> >  	DECODE_HEAD;
> > @@ -358,15 +373,10 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
> >  		dummy32 = be32_to_cpup(p++);
> >  		switch (dummy32) {
> >  		case NFS4_SET_TO_CLIENT_TIME:
> > -			/* We require the high 32 bits of 'seconds' to be 0, and we ignore
> > -			   all 32 bits of 'nseconds'. */
> 
> Have you done away with these requirements?

No, the comment just go lost, I'll add it bacl.

> 
> > -			READ_BUF(12);
> >  			len += 12;
> 
> I think this code makes it clear that the magic number 12 is the
> same on both lines. With the change, that gets lost.
> 
> Do I think that the 12 will ever change? No.
> 
> Do I think this becomes more "magic"? Yes.

Sure. but the whole counting the number to be decoded in setattr
is magic to start with.  I guess we could replace it with some magic
pointer arithmetic on argp->p, but is that really worth it?  Should
be a separate patch for sure.
