Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:45032 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932133AbbBBS4k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 Feb 2015 13:56:40 -0500
Date: Mon, 2 Feb 2015 19:56:38 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: [PATCH 10/20] nfsd: implement pNFS operations
Message-ID: <20150202185638.GB23319@lst.de>
References: <1421925006-24231-1-git-send-email-hch@lst.de> <1421925006-24231-11-git-send-email-hch@lst.de> <20150129203346.GA11064@fieldses.org> <20150202124349.GA15598@lst.de> <20150202142832.GC22301@fieldses.org> <20150202145619.GA18387@lst.de> <20150202150032.GD22301@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150202150032.GD22301@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 02, 2015 at 10:00:32AM -0500, J. Bruce Fields wrote:
> I'm planning to pull Jeff's tree and then apply these on top.  (Even if
> the conflict's fairly trivial I'm just happier being able to test the
> combination exactly as they're commited.)
> 
> I'll do that now, should be pushed out in an hour or two.

I've pushed out a pnfsd-for-3.20-3 branch to
git://git.infradead.org/users/hch/pnfs.git

Or do you want me to resend the whole thing?
