From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH 1/2] nfsd: make sure data is on disk before calling ->fsync
Date: Tue, 5 Jan 2010 16:22:31 +0100
Message-ID: <20100105152231.GA32332@lst.de>
References: <20091225164445.GA4578@lst.de> <20100104135045.GA18072@lst.de> <20100104204206.GD30129@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@lst.de>, viro@zeniv.linux.org.uk,
	jack@suse.cz, linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20100104204206.GD30129@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 04, 2010 at 03:42:06PM -0500, J. Bruce Fields wrote:
> On Mon, Jan 04, 2010 at 02:50:45PM +0100, Christoph Hellwig wrote:
> > ping?  this fixes a quite nasty issue introduced in 2.6.32, so we should
> > fix it ASAP (including backport to -stable)
> 
> Apologies for the delay.  Which commit exactly introduced the original
> regression?  I'll take over getting them into 2.6.33 and 2.6.32.y unless
> you tell me you're already doing that.

2daea67e966dc0c42067ebea015ddac6834cef88 changed the calling convention.
Removal of the explicit wait in the filesystem might have been another
few commits.

If you can easily take care of getting the first patch into -stable I'll
leave it to you.
