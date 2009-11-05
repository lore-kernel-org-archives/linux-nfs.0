From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 2/5] nfsd: Fix independence of a few nfsd related
	headers
Date: Thu, 5 Nov 2009 11:33:33 -0500
Message-ID: <20091105163333.GB29981@fieldses.org>
References: <4ADEC1EF.8040107@panasas.com> <1256112873-32495-1-git-send-email-bharrosh@panasas.com> <1256171298.6809.1.camel@heimdal.trondhjem.org> <4AE01569.9000002@panasas.com> <1256220146.6402.23.camel@heimdal.trondhjem.org> <4AE08165.2040100@panasas.com> <20091104220927.GS11637@fieldses.org> <4AF2914F.60803@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	Andy Adamson <andros@netapp.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:52883 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756623AbZKEQd0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 5 Nov 2009 11:33:26 -0500
In-Reply-To: <4AF2914F.60803@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 05, 2009 at 10:48:15AM +0200, Boaz Harrosh wrote:
> On 11/05/2009 12:09 AM, J. Bruce Fields wrote:
> > On Thu, Oct 22, 2009 at 05:59:33PM +0200, Boaz Harrosh wrote:
> >> On 10/22/2009 04:02 PM, Trond Myklebust wrote:
> >>> No. What I'm saying is that this doesn't have to be an absolute rule.
> >>> The Kernel style guide assumes that everything in 'include/*' is going
> >>> to be exported all around the kernel.
> >>> The problem is that we put a lot of stuff which is private to fs/nfs and
> >>> fs/nfsd in there. Those header files do not have to absolutely follow
> >>> the style guide rule, 'cos we know what is being included before and
> >>> after them...
> >>>
> >>
> >> I'm not sure I understand
> >> You are saying that the patches are very good, but only
> >> the rule I stated originally could be relaxed a little with private
> >> headers where we might get lazy, if the effects are very local?
> >>
> >> Well, that's not a problem then, right? just that I can relax a bit
> >> if I want.
> >>
> >> But I disagree: see 3, 4, 5 above and that last patch I submitted. That patch
> >> is only the beginning. 85% of all source files in nfs/nfsd could receive the
> >> same love. I only done these I touched. Code tends to stay much-much longer
> >> then we spend time on it. Better get it in shape the first time.
> > 
> > I'm assuming Trond's objection is just to the patch changelog
> > (specifically, to the statement that any header "should be compilation
> > independent"), not to these specific changes.
> > 
> > --b.
> 
> Speaking of which, Bruce I have a question.
> 
> There are a few files in include/linux/ that define xdr definitions
> these are used by exportfs nfs and nfsd. Some of it gets exposed
> to filesystems.

Which specifically?

> With the pNFS tree we are adding lots more of these,
> specifically I'm now to move the pnfs_osd_xdr stuff as well, and blocks.
> 
> Could I open up a new  include/linux/exportfs/ folder and put there any thing
> xdr and exportfs related?

Well, if it's just a few things, maybe include/linux/exportfs.h?

But, sure, makes sense if there's includes that are specific to pNFS and
that wouldn't be needed by any filesystem that included exportfs.h.

> What should be the scope of the move, should any include/linux/ common
> files used both by nfs & nfsd be moved there?

I don't see why we'd want to do that, but maybe I'm missing something.

--b.
