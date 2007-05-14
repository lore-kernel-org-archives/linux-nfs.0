From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] [PATCH 0/18] export operations rewrite
Date: Mon, 14 May 2007 10:13:06 +1000
Message-ID: <17991.43410.74639.870369@notabene.brown>
References: <20070317010946.GA24947@infradead.org>
	<17932.34141.590792.120454@notabene.brown>
	<20070501103905.GA30906@infradead.org>
	<17978.55182.198497.902215@notabene.brown>
	<17982.27203.841272.221428@notabene.brown>
	<17982.28018.403942.663539@notabene.brown>
	<20070507075100.GA28376@infradead.org>
	<20070513204110.GA13563@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: message from Christoph Hellwig on Sunday May 13
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Sunday May 13, hch@infradead.org wrote:
> On Mon, May 07, 2007 at 08:51:00AM +0100, Christoph Hellwig wrote:
> > On Mon, May 07, 2007 at 10:06:10AM +1000, Neil Brown wrote:
> > > On Monday May 7, neilb@suse.de wrote:
> > > > 
> > > > Would you be able to respin that second patch series with one of those
> > > > changes?
> > > 
> > > Of course it is actually the first series of patches that introduces
> > > this problem.  So maybe just a full respin??
> > 
> > I'll take a look at how to solve this issues.
> 
> I'll take some more time until I can look at this.  Can you send of the
> first patch series to Linus in the meantime?

Oh.. the problem is in the second series, isn't it.  I had somehow
convinced myself it was in the first.
And the merge window has now closed, but I'll submit it to -mm
shortly.
Sorry 'bout that.

NeilBrown
