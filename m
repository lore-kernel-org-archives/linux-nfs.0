From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: (fwd) nfs hang on 2.6.24
Date: Wed, 6 Feb 2008 13:31:28 -0500
Message-ID: <20080206183128.GG5342@fieldses.org>
References: <20080205090132.GA8286@stro.at> <1202248931.12271.18.camel@heimdal.trondhjem.org> <003301c86888$ed735a20$0301a8c0@MURTLE> <1202310021.12647.6.camel@heimdal.trondhjem.org> <20080206150739.GA5342@fieldses.org> <1202310924.12647.24.camel@heimdal.trondhjem.org> <20080206172315.GE5342@fieldses.org> <1202320337.14889.18.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Dixie <andrew-0FSrDVjkvKm9koe0gwxAeg@public.gmane.org>, linux-nfs@vger.kernel.org,
	maximilian attems <max-U9r9yeDMy7A@public.gmane.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from pie.citi.umich.edu ([141.211.133.115]:35194 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753970AbYBFSbn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 13:31:43 -0500
In-Reply-To: <1202320337.14889.18.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 06, 2008 at 12:52:17PM -0500, Trond Myklebust wrote:
> 
> On Wed, 2008-02-06 at 12:23 -0500, J. Bruce Fields wrote:
> > On Wed, Feb 06, 2008 at 10:15:23AM -0500, Trond Myklebust wrote:
> > > 
> > > On Wed, 2008-02-06 at 10:07 -0500, J. Bruce Fields wrote:
> > > 
> > > > That went into 2.6.22:
> > > > 
> > > > 	21315edd4877b593d5bf.. "[PATCH] knfsd: nfsd4: demote "clientid
> > > > 	in use" printk to a dprintk"
> > > > 
> > > > It may suggest a problem if this is happening a lot, though, right?
> > > 
> > > The client should always be able to generate a new unique clientid if
> > > this happens.
> > 
> > And then the client may fail to reclaim its state on the next server
> > reboot, or mistakenly prevent some other client from reclaiming state,
> > since it's not recording the new clientid in stable storage.  So if it's
> > happening a lot then we I suppose we should figure out better ways to
> > generate client id's.
> 
> Huh?
> 
> If the server reboots, the client will try to reclaim state using the
> _same_ client identifier string.

Oh, right, I was confusing client and server reboot and assuming the
client would forget the uniquifier on server reboot.  That's obviously
wrong!  The client will forget its own uniquifier on client reboot, but
that's alright since it's happy enough just to let that old state time
out at that point.  So the only possible problem is suboptimal behavior
when the client reboot time is less than the lease time.

> Two clients should _not_ be able to generate the same clientid unless
> they're also sharing the same IP address and a number of other
> properties that we include in the client identifier.

Or unless two client implementations just happen to have clashing
clientid generation algorithms, but we hope that's unlikely.

(Except that older Linux clients were prone to produce the same
clientid, if I remember right.  But the more likely explanation may be
that these are the result of a single client destroying and then
creating state on the server within a lease period, and the server being
stubborn and refusing to let go of the old state (even though no opens
are associated with it any more) until the end of a lease period.  I
think that's a server bug.)

--b.
