Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60683 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752222Ab1CDT7y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2011 14:59:54 -0500
Date: Fri, 4 Mar 2011 14:59:48 -0500
From: Neil Horman <nhorman@tuxdriver.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, security@kernel.org,
        Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] nfs4: Ensure that ACL pages sent over NFS were not
 allocated from the slab
Message-ID: <20110304195948.GD10083@hmsreliant.think-freely.org>
References: <1299257053-13175-1-git-send-email-nhorman@tuxdriver.com>
 <1299265315.2901.7.camel@heimdal.trondhjem.org>
 <20110304191719.GC10083@hmsreliant.think-freely.org>
 <1299266730.2901.15.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1299266730.2901.15.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Mar 04, 2011 at 02:25:30PM -0500, Trond Myklebust wrote:
> On Fri, 2011-03-04 at 14:17 -0500, Neil Horman wrote: 
> > On Fri, Mar 04, 2011 at 02:01:55PM -0500, Trond Myklebust wrote:
> > > On Fri, 2011-03-04 at 11:44 -0500, Neil Horman wrote:
> > > >  
> > > > +static int buf_to_pages_noslab(const void *buf, size_t buflen,
> > > > +		struct page **pages, unsigned int *pgbase)
> > > > +{
> > > > +	const void *p = buf;
> > > > +	struct page *page, *newpage, **spages;
> > > > +	int rc = -ENOMEM;
> > > > +
> > > > +	spages = pages;
> > > > +	*pgbase = offset_in_page(buf);
> > > > +	p -= *pgbase;
> > > > +	while (p < buf + buflen) {
> > > > +		page = virt_to_page(p);
> > > > +		newpage = alloc_page(GFP_KERNEL);
> > > > +		if (!newpage)
> > > > +			goto unwind;
> > > > +		memcpy(page_address(newpage), page_address(page),
> > > > +		       PAGE_CACHE_SIZE);
> > > 
> > > Why do we need to keep this byzantian offset_in_page() and
> > > virt_to_page() logic in order to copying data from a linear buffer into
> > > a set of pages?
> > > 
> > We don't I suppose, but I thought it best to follow the byzantine style of the
> > function immediately above it. :)  If you have a better suggestion, I'm
> > listening.
> 
> Why isn't something like the following good enough?
> 
> 	do {
> 		size_t len = min(PAGE_CACHE_SIZE, buflen);
> 		struct page *newpage = alloc_page(GFP_KERNEL);
> 
> 		if (newpage == NULL)
> 			goto unwind;
> 		memcpy(page_address(newpage), buf, len);
> 		copied += len;
> 		buf += len;
> 		buflen -= len;
> 	} while (buflen != 0);
> 
Ah, I see what your saying - you're suggesting that we copy from an offset in
the page to the start of the page and always make the resulting pgbase be zero.
That makes sense.  I'll respin it that way.
Neil

> 
> 
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
> 
