Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50299 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757717AbbEVQQl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 May 2015 12:16:41 -0400
Date: Fri, 22 May 2015 12:16:38 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: NFS <linux-nfs@vger.kernel.org>
Subject: Re: Does NFSv4 need to call inode_permission on every write???
Message-ID: <20150522161638.GE5580@fieldses.org>
References: <20150521144029.57f1b33f@notabene.brown>
 <20150521130735.GA27065@fieldses.org>
 <20150522090127.1571fcb7@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150522090127.1571fcb7@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 22, 2015 at 09:01:27AM +1000, NeilBrown wrote:
> On Thu, 21 May 2015 09:07:35 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Thu, May 21, 2015 at 02:40:29PM +1000, NeilBrown wrote:
> > > 
> > > 
> > > Apologies if this has been answered before, however...
> > > 
> > > In nfsd_write() we have:
> > > 
> > > 	if (file) {
> > > 		err = nfsd_permission(rqstp, fhp->fh_export, fhp->fh_dentry,
> > > 				NFSD_MAY_WRITE|NFSD_MAY_OWNER_OVERRIDE);
> > > 		if (err)
> > > 			goto out;
> > > 		err = nfsd_vfs_write(rqstp, fhp, file, offset, vec, vlen, cnt,
> > > 				stablep);
> > > 	} else {
> > > 
> > > So if a 'file' is already available - because the request came via NFSv4 and
> > > there was a valid state id, and a 'struct file' was associated with that
> > > state - we still call nfsd_permission().
> > > 
> > > Is that really needed?  The permission check will have been performed at open
> > > - it shouldn't be needed again now.
> > > 
> > > With NFSv3 we have to check permission at each IO, and this is slightly
> > > different from POSIX semantics.  We shouldn't have to with NFSv4... should we?
> > > 
> > > The particular issue that brought this to my attention is that "chattr +i" -
> > > to make a file immutable - is not supposed to affect current opens, only
> > > future opens.  But a current open over NFSv4 is affected.
> > > 
> > > Is there some reason that we cannot just remove that nfsd_permission() check?
> > 
> > The only proof that this write is part of the open is a stateid provided
> > as part of the write arguments.  Anyone could sniff or guess that
> > stateid.
> 
> But a stateid is tied to a clientid

The stateid does have sufficient information to allow the server to
determine which NFSv4 client it's associated with.

> and the clientid is tied to server credentials....??

I'm not sure what you're thinking of there.  It could conceivably be
tied to some kind of client credentials, but it isn't really.  A write
is sent as the user performing the write, but could come from any IP
address, from a different user than did the open or the setclientid,
etc.

4.1 server state protection does give us more of a client credential,
but I don't know that that helps here.

> I guess it is harder than I at first imagined.
> 
> > 
> > We could try to make that work by checking the stateid against the
> > principal from the rpc header.  Unfortunately that turns out to be more
> > complicated than "is this the same principal as did the open"; among
> > other things I think it's possible the stateid resulted from opens done
> > by different principals, so we'd need to keep a list.  If we added that
> > kind of check, could we drop the per-operation check?  It's not obvious
> > to me.
> 
> Delegations would certainly make that interesting.  Who exactly does
> authentic writes when a delegation is flushed ... I don't remember.
> 
> Sounds like this belongs in the too-hard basket.

That's been my conclusion so far.

--b.
