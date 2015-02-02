Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:35060 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753145AbbBBPAd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Feb 2015 10:00:33 -0500
Date: Mon, 2 Feb 2015 10:00:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 10/20] nfsd: implement pNFS operations
Message-ID: <20150202150032.GD22301@fieldses.org>
References: <1421925006-24231-1-git-send-email-hch@lst.de>
 <1421925006-24231-11-git-send-email-hch@lst.de>
 <20150129203346.GA11064@fieldses.org>
 <20150202124349.GA15598@lst.de>
 <20150202142832.GC22301@fieldses.org>
 <20150202145619.GA18387@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150202145619.GA18387@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 02, 2015 at 03:56:19PM +0100, Christoph Hellwig wrote:
> On Mon, Feb 02, 2015 at 09:28:32AM -0500, J. Bruce Fields wrote:
> > I didn't notice anything that looked like a big problem to me, so absent
> > any objections I'll commit the revised versions for 3.20 once we figure
> > out how to handle the xfs stuff.
> 
> Do you want the resend to be on top of Jeffs locks tree, or do you
> want me to be based just on the nfsd changes, which would require
> a fairly trivial merge once both of the trees hit mainline?

I'm planning to pull Jeff's tree and then apply these on top.  (Even if
the conflict's fairly trivial I'm just happier being able to test the
combination exactly as they're commited.)

I'll do that now, should be pushed out in an hour or two.

--b.
