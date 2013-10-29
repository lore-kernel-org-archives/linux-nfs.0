Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35843 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753241Ab3J2NaL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 09:30:11 -0400
Date: Tue, 29 Oct 2013 09:30:06 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
Message-ID: <20131029133006.GB29606@fieldses.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-5-git-send-email-bjschuma@netapp.com>
 <20131029073558.GA10889@infradead.org>
 <526FB180.1060003@netapp.com>
 <20131029130721.GA32094@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131029130721.GA32094@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 06:07:21AM -0700, Christoph Hellwig wrote:
> On Tue, Oct 29, 2013 at 09:00:48AM -0400, Anna Schumaker wrote:
> >  From what I can tell, I think the allocated flag will just tell the 
> > clients if all the blocks exist on disk or not.  Is there a way to have 
> > a hole with allocated blocks?  Or maybe it's supposed to represent 
> > partially allocated blocks?  I checked the draft, and it doesn't 
> > actually say what they expect allocated to represent...
> 
> You can have preallocated space, which behaves like a hole in that
> reads return zeroes.  As far as SEEK_DATA/SEEK_HOLE is concerned we
> tend to treat them as holes when we can as that's what the users expect.
> 
> Note that at least the pnfs block rfc has a special state representing
> this kind of preallocated space.

http://tools.ietf.org/html/draft-ietf-nfsv4-minorversion2-20#section-5.2

E.g. "Hole:  A byte range within a Sparse file that contains regions of
all zeroes.  For block-based file systems, this could also be an
unallocated region of the file."

So it sounds like a hole can either be allocated or not, which seems to
agree with what you expect?

I haven't read these parts of the spec yet at all....

--b.
