From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC] Reinstate NFS exportability for JFFS2.
Date: Fri, 1 Aug 2008 10:16:45 +1000
Message-ID: <18578.21997.529551.676627@notabene.brown>
References: <1209670979.25560.587.camel@pmac.infradead.org>
	<20080501204820.GA5951@infradead.org>
	<1209681898.25560.613.camel@pmac.infradead.org>
	<18458.28833.539314.455215@notabene.brown>
	<1217541264.1126.15.camel@shinybook.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-mtd@lists.infradead.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: message from David Woodhouse on Thursday July 31
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thursday July 31, dwmw2@infradead.org wrote:
> On Fri, 2008-05-02 at 11:38 +1000, Neil Brown wrote:
> > Why is there a deadlock here?

I was really hoping you would answer this question.
I can see the sense in your approach, but it does still seem a bit
hackish.  I would like to understand the details of the problem enough
to be confident that there is no less-hackish solution.

Thanks,
NeilBrown


> > Both readdir and lookup are called with i_mutex held on the directory
> > so there should need to do any extra locking (he said, naively).  In
> > the readdirplus cases, i_mutex is held across both the readdir and the
> > lookup....
> > 
> > One problem with your proposed solution is that filehandles aren't all
> > the same length, so you cannot reliably leave space for them.
> > 
> > Awkward.
> 
> Yeah. I think the sanest plan for the short term is, as hch suggests,
> just to transplant the existing XFS hack into the nfsd code. That way,
> at least we can avoid using the hack for local users. And it makes NFS
> export from other file systems (jffs2, btrfs, etc.) easier without
> having to put the same hacks in each one.
> 
> Git tree at git.infradead.org/users/dwmw2/nfsexport-2.6.git; patch
> sequence follows...
> 
> -- 
> David Woodhouse                            Open Source Technology Centre
> David.Woodhouse@intel.com                              Intel Corporation
