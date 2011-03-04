Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:56908 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587Ab1CDTZc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2011 14:25:32 -0500
Subject: Re: [PATCH] nfs4: Ensure that ACL pages sent over NFS were not
 allocated from the slab
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Neil Horman <nhorman@tuxdriver.com>
Cc: linux-nfs@vger.kernel.org, security@kernel.org,
        Jeff Layton <jlayton@redhat.com>
In-Reply-To: <20110304191719.GC10083@hmsreliant.think-freely.org>
References: <1299257053-13175-1-git-send-email-nhorman@tuxdriver.com>
	 <1299265315.2901.7.camel@heimdal.trondhjem.org>
	 <20110304191719.GC10083@hmsreliant.think-freely.org>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 04 Mar 2011 14:25:30 -0500
Message-ID: <1299266730.2901.15.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2011-03-04 at 14:17 -0500, Neil Horman wrote: 
> On Fri, Mar 04, 2011 at 02:01:55PM -0500, Trond Myklebust wrote:
> > On Fri, 2011-03-04 at 11:44 -0500, Neil Horman wrote:
> > >  
> > > +static int buf_to_pages_noslab(const void *buf, size_t buflen,
> > > +		struct page **pages, unsigned int *pgbase)
> > > +{
> > > +	const void *p = buf;
> > > +	struct page *page, *newpage, **spages;
> > > +	int rc = -ENOMEM;
> > > +
> > > +	spages = pages;
> > > +	*pgbase = offset_in_page(buf);
> > > +	p -= *pgbase;
> > > +	while (p < buf + buflen) {
> > > +		page = virt_to_page(p);
> > > +		newpage = alloc_page(GFP_KERNEL);
> > > +		if (!newpage)
> > > +			goto unwind;
> > > +		memcpy(page_address(newpage), page_address(page),
> > > +		       PAGE_CACHE_SIZE);
> > 
> > Why do we need to keep this byzantian offset_in_page() and
> > virt_to_page() logic in order to copying data from a linear buffer into
> > a set of pages?
> > 
> We don't I suppose, but I thought it best to follow the byzantine style of the
> function immediately above it. :)  If you have a better suggestion, I'm
> listening.

Why isn't something like the following good enough?

	do {
		size_t len = min(PAGE_CACHE_SIZE, buflen);
		struct page *newpage = alloc_page(GFP_KERNEL);

		if (newpage == NULL)
			goto unwind;
		memcpy(page_address(newpage), buf, len);
		copied += len;
		buf += len;
		buflen -= len;
	} while (buflen != 0);




-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

