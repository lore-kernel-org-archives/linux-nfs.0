From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Thu, 25 Sep 2008 16:41:11 -0400
Message-ID: <20080925204110.GB14349@fieldses.org>
References: <20080924163528.GB5772@fieldses.org> <1222275582.7390.8.camel@localhost> <20080924172134.GI5772@fieldses.org> <1222277168.7390.19.camel@localhost> <20080924174230.GJ5772@fieldses.org> <1222281745.7390.34.camel@localhost> <20080924184934.GK5772@fieldses.org> <48DBE6D9.3010603@panasas.com> <20080925200014.GA14078@fieldses.org> <1222374421.13388.26.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:45458 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753631AbYIYUlP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2008 16:41:15 -0400
In-Reply-To: <1222374421.13388.26.camel@localhost>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 25, 2008 at 04:27:01PM -0400, Trond Myklebust wrote:
> On Thu, 2008-09-25 at 16:00 -0400, J. Bruce Fields wrote:
> > > >> Another fix would be to add a refcount to the rpc_program structure...
> > > > 
> > > > ... a refcount seems more straightforward.  Benny, what do you think?
> > > 
> > > I agree.  I'll send a patch hopefully tomorrow.
> > > Would you like that combined with the one I sent or as a separate one?
> > > (I'm inclined towards the latter).
> > 
> > That'd be fine.
> 
> So, looking at what you're trying to do, I'm still having trouble
> figuring out why you think you need a dynamically allocated rpc_program
> in the first place.
> 
> If the only thing you are trying to support is dynamically allocated
> program numbers, then note that rpc_encode_header() doesn't use
> program->number at all. Instead, it uses clnt->cl_prog and
> clnt->cl_vers. Nothing stops you from setting those values explicitly...

Oh, sure, that sounds like an excellent plan--thanks!

There's still, as far as I can tell, the small risk of a race on module
unload.  I don't think we've seen it, and I don't know if it's worth
much effort at this point.

--b.
