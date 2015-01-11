Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yh0-f52.google.com ([209.85.213.52]:58951 "EHLO
	mail-yh0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750955AbbAKXxs (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Jan 2015 18:53:48 -0500
Received: by mail-yh0-f52.google.com with SMTP id z6so8370406yhz.11
        for <linux-nfs@vger.kernel.org>; Sun, 11 Jan 2015 15:53:48 -0800 (PST)
Date: Sun, 11 Jan 2015 18:53:44 -0500
From: Tom Haynes <thomas.haynes@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 03/18] nfsd: factor out a helper to decode nfstime4 values
Message-ID: <20150111235344.GA11746@slacker.internal.excfb.com>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
 <1420561721-9150-4-git-send-email-hch@lst.de>
 <20150109230202.GB107259@kitty>
 <20150111114242.GA11939@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150111114242.GA11939@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jan 11, 2015 at 12:42:42PM +0100, Christoph Hellwig wrote:
> On Fri, Jan 09, 2015 at 03:02:02PM -0800, Tom Haynes wrote:
> > 
> > > -			READ_BUF(12);
> > >  			len += 12;
> > 
> > I think this code makes it clear that the magic number 12 is the
> > same on both lines. With the change, that gets lost.
> > 
> > Do I think that the 12 will ever change? No.
> > 
> > Do I think this becomes more "magic"? Yes.
> 
> Sure. but the whole counting the number to be decoded in setattr
> is magic to start with.  

Agreed.

> I guess we could replace it with some magic
> pointer arithmetic on argp->p, but is that really worth it?  

Which is why I asked the leading questions. I see both sides,
but ultimately it is a nit considering the rest of the abuse.

I'm fine with you deciding it is still magic overall.

> Should
> be a separate patch for sure.
