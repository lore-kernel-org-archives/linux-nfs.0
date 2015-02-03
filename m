Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:35892 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933938AbbBCQIr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 3 Feb 2015 11:08:47 -0500
Date: Tue, 3 Feb 2015 11:08:45 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 10/20] nfsd: implement pNFS operations
Message-ID: <20150203160845.GO22301@fieldses.org>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
 <1421925006-24231-11-git-send-email-hch@lst.de>
 <20150129203346.GA11064@fieldses.org>
 <20150202124349.GA15598@lst.de>
 <20150202142832.GC22301@fieldses.org>
 <20150202145619.GA18387@lst.de>
 <20150202150032.GD22301@fieldses.org>
 <20150202185638.GB23319@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150202185638.GB23319@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 02, 2015 at 07:56:38PM +0100, Christoph Hellwig wrote:
> On Mon, Feb 02, 2015 at 10:00:32AM -0500, J. Bruce Fields wrote:
> > I'm planning to pull Jeff's tree and then apply these on top.  (Even if
> > the conflict's fairly trivial I'm just happier being able to test the
> > combination exactly as they're commited.)
> > 
> > I'll do that now, should be pushed out in an hour or two.
> 
> I've pushed out a pnfsd-for-3.20-3 branch to
> git://git.infradead.org/users/hch/pnfs.git
> 
> Or do you want me to resend the whole thing?

No, looks fine to me as is.  Thanks!  I'll play around with it a little
more and then push it out.

GETLAYOUT is going to be annoying if we need big layouts.  We'll have to
figure out what to do with that reply size estimation, and clients will
have to figure out how to get the maxresponsesized_cached right, I
guess?  Oh well.

--b.
