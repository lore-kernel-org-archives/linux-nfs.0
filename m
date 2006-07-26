From: Josh Triplett <josht@us.ibm.com>
Subject: Re: [NFS] [PATCH] [nfsd] Add lock annotations to e_start and e_stop
Date: Wed, 26 Jul 2006 08:42:17 -0700
Message-ID: <1153928537.12517.44.camel@josh-work.beaverton.ibm.com>
References: <1153840824.12517.9.camel@josh-work.beaverton.ibm.com>
	 <20060726080656.GA28346@infradead.org>
	 <1153901976.3381.1.camel@laptopd505.fenrus.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, Andrew Morton <akpm@osdl.org>,
	nfs@lists.sourceforge.net, Neil Brown <neilb@cse.unsw.edu.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751670AbWGZPmT@vger.kernel.org>
To: Arjan van de Ven <arjan@infradead.org>
In-Reply-To: <1153901976.3381.1.camel@laptopd505.fenrus.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2006-07-26 at 10:19 +0200, Arjan van de Ven wrote:
> On Wed, 2006-07-26 at 09:06 +0100, Christoph Hellwig wrote:
> > On Tue, Jul 25, 2006 at 08:20:24AM -0700, Josh Triplett wrote:
> > > e_start acquires svc_export_cache.hash_lock, and e_stop releases it.  Add lock
> > > annotations to these two functions so that sparse can check callers for lock
> > > pairing, and so that sparse will not complain about these functions since they
> > > intentionally use locks in this manner.
> > > 
> > > Signed-off-by: Josh Triplett <josh@freedesktop.org>
> > 
> > The Signed-off-by: line doesn't match the from line of this mail.  Is that
> > any problem or fine in general?
> 
> As far as I can see it's customary for the SOB line to state the
> affiliation of the person, eg the company that wants to own the
> copyright on the code. So I'd expect Josh to use his ibm.com account...

When my internship with IBM ends, the address in the From line stops
working.  I've already run into a number of bounces when sending in
these patches; I don't want to contribute to that problem.  The address
I gave in the Signed-off-by line should always work, as I can change
where it forwards.

- Josh Triplett
