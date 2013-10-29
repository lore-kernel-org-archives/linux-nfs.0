Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:59595 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753431Ab3J2NxZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Oct 2013 09:53:25 -0400
Date: Tue, 29 Oct 2013 09:53:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [RFC 5/4] NFSD: Add basic CB_OFFLOAD support
Message-ID: <20131029135321.GI29606@fieldses.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-6-git-send-email-bjschuma@netapp.com>
 <20131028215221.GQ31322@fieldses.org>
 <20131029073719.GB10889@infradead.org>
 <20131029133611.GF29606@fieldses.org>
 <20131029133800.GA27762@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131029133800.GA27762@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 06:38:00AM -0700, Christoph Hellwig wrote:
> On Tue, Oct 29, 2013 at 09:36:11AM -0400, J. Bruce Fields wrote:
> > Yeah, understood, I'm glad we're not implementing that, I just wonder
> > why every one of these operations (COPY, WRITE_PLUS, etc.) has to have
> > this asynchronous option.
> > 
> > The client's still stuck implementing it even if the server does, it's
> > extra protocol verbage even if nobody uses it, and I'm not completely
> > clear what it's for.
> 
> Seems like Trond answered that question: feature creep that people
> without the slightest sense of abstraction tried to overload over a few
> operations.

Your complaint as I understand it is that quick and long-running
operations were combined into one one operation when they would have
better been separated. I agree.

But I also don't understand why the long-running operations need an
async option.  Maybe they do, I just don't understand why.

Alternatives might include just letting the operation hog a request slot
for the whole time, or making it work in chunks.  (E.g. allowing COPY to
return short writes.)

--b.
