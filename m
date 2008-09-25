From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [pnfs] [PATCH] nfsd: use nfs client rpc callback program
Date: Thu, 25 Sep 2008 16:27:01 -0400
Message-ID: <1222374421.13388.26.camel@localhost>
References: <48D19C74.8000303@panasas.com> <48D2AAF7.6060808@panasas.com>
	 <20080924163528.GB5772@fieldses.org> <1222275582.7390.8.camel@localhost>
	 <20080924172134.GI5772@fieldses.org> <1222277168.7390.19.camel@localhost>
	 <20080924174230.GJ5772@fieldses.org> <1222281745.7390.34.camel@localhost>
	 <20080924184934.GK5772@fieldses.org> <48DBE6D9.3010603@panasas.com>
	 <20080925200014.GA14078@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Benny Halevy <bhalevy@panasas.com>,
	Olga Kornievskaia <aglo@citi.umich.edu>,
	linux-nfs@vger.kernel.org, pnfs mailing list <pnfs@linux-nfs.org>,
	Trond Myklebust <trond@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:37918 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753655AbYIYU1V (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2008 16:27:21 -0400
In-Reply-To: <20080925200014.GA14078@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2008-09-25 at 16:00 -0400, J. Bruce Fields wrote:
> > >> Another fix would be to add a refcount to the rpc_program structure...
> > > 
> > > ... a refcount seems more straightforward.  Benny, what do you think?
> > 
> > I agree.  I'll send a patch hopefully tomorrow.
> > Would you like that combined with the one I sent or as a separate one?
> > (I'm inclined towards the latter).
> 
> That'd be fine.

So, looking at what you're trying to do, I'm still having trouble
figuring out why you think you need a dynamically allocated rpc_program
in the first place.

If the only thing you are trying to support is dynamically allocated
program numbers, then note that rpc_encode_header() doesn't use
program->number at all. Instead, it uses clnt->cl_prog and
clnt->cl_vers. Nothing stops you from setting those values explicitly...

Trond

