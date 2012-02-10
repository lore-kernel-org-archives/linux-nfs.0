Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:64297 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759461Ab2BJQGt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Feb 2012 11:06:49 -0500
Date: Fri, 10 Feb 2012 11:06:46 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 3/5] nfsd: convert nfs4_client->cl_cb_flags to a
 generic flags field
Message-ID: <20120210110646.61d96454@tlielax.poochiereds.net>
In-Reply-To: <20120208160023.5ef38176@tlielax.poochiereds.net>
References: <1328111052-28389-1-git-send-email-jlayton@redhat.com>
	<1328111052-28389-4-git-send-email-jlayton@redhat.com>
	<20120203193533.GA2999@fieldses.org>
	<20120208160023.5ef38176@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 8 Feb 2012 16:00:23 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Fri, 3 Feb 2012 14:35:33 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Wed, Feb 01, 2012 at 10:44:10AM -0500, Jeff Layton wrote:
> > > We'll need a way to flag the nfs4_client as already being recorded on
> > > stable storage so that we don't continually upcall.
> > 
> > Looks like the code currently uses cl_firststate for that purpose.
> > 
> > I'm perfectly open to the argument that using a u32 to store a boolean
> > is rather silly, and can't see any problem with doing it this way
> > instead, but then let's remove cl_firstate while we're at it.
> > 
> > --b.
> > 
> 
> I started looking at this. The semantics on cl_firststate are a little
> different from my proposed flag:
> 
> The meaning of the flag I was proposing is fairly clear -- I set it
> whenever the kernel believes that there is already a record for this
> client on stable storage. So, when we first upcall to check if a client
> is on stable storage, then we'll also set that bit if it was, as well
> as when we first create a client record on stable storage.
> 
> The legacy tracker sets cl_firststate whenever the directory is
> created, or in nfs4_set_claim_prev. When the clients are restored
> after a reboot by reading in the contents of the v4recoverydir, then
> they do not have the cl_firststate set initially. It's only after a
> NFS4_OPEN_CLAIM_PREVIOUS open request comes in that they get it.
> 
> Now, I don't think it really matters much. We'll just have this flag
> set a little earlier with the new client tracker, and it may get set
> again when it's already set. I don't see any cases right offhand where
> the legacy and new client trackers would cause different behavior.
> 
> Am I missing any subtlety in the semantics of cl_firststate here?
> 

Apologies for the self-reply...

It does matter -- the check in nfsd4_reclaim_complete won't work
correctly with the new client ID tracker if we just replace
cl_firststate with NFSD4_CLIENT_STABLE. I think the right approach
is probably to add a new flag here that nfsd4_reclaim_complete can
use in place of its existing cl_firststate check.

I'll give it some more thought...

Thanks,
-- 
Jeff Layton <jlayton@redhat.com>
