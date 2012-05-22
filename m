Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47157 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753360Ab2EVWtF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 May 2012 18:49:05 -0400
Date: Tue, 22 May 2012 18:49:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Simo Sorce <simo@redhat.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] SUNRPC: Add RPC based upcall mechanism for RPCGSS
 auth
Message-ID: <20120522224904.GB6435@fieldses.org>
References: <1337087550-9821-1-git-send-email-simo@redhat.com>
 <1337087550-9821-4-git-send-email-simo@redhat.com>
 <20120522150221.GD891@fieldses.org>
 <1337699722.16840.189.camel@willson.li.ssimo.org>
 <20120522152917.GB11739@pad.fieldses.org>
 <1337701251.16840.201.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1337701251.16840.201.camel@willson.li.ssimo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 22, 2012 at 11:40:51AM -0400, Simo Sorce wrote:
> On Tue, 2012-05-22 at 11:29 -0400, J. Bruce Fields wrote:
> > On Tue, May 22, 2012 at 11:15:22AM -0400, Simo Sorce wrote:
> > > On Tue, 2012-05-22 at 11:02 -0400, J. Bruce Fields wrote:
> > > >  This seems
> > > > likely to break in subtle ways if we ever change one of those constants
> > > > to not be a multiple of a large enough power of 2.  And makes the memory
> > > > handling a little more obscure.  I'd rather just allocate those
> > > > separately if that's the choice.
> > > 
> > > I do not see why it would break, the only limit we have is the total
> > > size of the kmembuf.
> > 
> > Oh, just because the svc_cred at the end wouldn't be aligned nicely any
> > more.  Doesn't that bother some architectures?
> 
> Ah yeah I see, indeed some architecture require memory to be aligned.
> I will change that code back to kmallocs, which is what I always
> preferred anyway.
> 
> > > > Whatever, I don't really care how the various xdr_netobj->data's are
> > > > allocated, honestly there's no crusade to eliminate kmalloc()'s, I'll
> > > > only object in a case (like the struct svc_cred field above) where it
> > > > seems obviously unnecessary.
> > > 
> > > Ok, so what should I do ?
> > > I can remove the static allocation and let the code allocate the data
> > > with kmalloc, in the xdr unmarshalling code.
> > > Whatever you like best.
> > 
> > Just embed the svc_cred:
> > 
> > > > -	struct svc_cred *creds;
> > > > +	struct svc_cred creds;
> 
> Can't do, it needs to be allocated, because we steal it in scvauth_gss.c

Are you sure?  Looks to me like it's only the group list that's "stolen"
there, the rest is copied.

--b.

> 
> > and handle the rest whichever way seems cleanest to you.
> 
> Ok.
> 
> Simo.
> 
> -- 
> Simo Sorce * Red Hat, Inc * New York
> 
