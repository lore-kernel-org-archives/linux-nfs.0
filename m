Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([173.255.197.46]:47456 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751063AbbBRByf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Feb 2015 20:54:35 -0500
Date: Tue, 17 Feb 2015 20:54:32 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <SteveD@redhat.com>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH/RFC nfs-utils] exports.man: improve documentation of
 'nohide' and 'crossmnt'
Message-ID: <20150218015432.GA4148@fieldses.org>
References: <20150216122107.4bfd4225@notabene.brown>
 <20150216201751.GB22154@fieldses.org>
 <20150218124101.0c1cebfe@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150218124101.0c1cebfe@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 18, 2015 at 12:41:01PM +1100, NeilBrown wrote:
> On Mon, 16 Feb 2015 15:17:51 -0500 bfields@fieldses.org (J. Bruce Fields)
> wrote:
> 
> > On Mon, Feb 16, 2015 at 12:21:07PM +1100, NeilBrown wrote:
> > > 
> > > 
> > > - note that 'nohide' is irrelevant for NFSv4
> > > - note that children on a 'crossmnt' filesystem cannot be unexported
> > > - note that 'nocrossmnt' is a valid option, but probably not useful.
> > > 
> > > Signed-off-by: NeilBrown <neilb@suse.de>
> > > 
> > > ---
> > > 
> > > I wonder if we should add a new option, e.g. "noaccess" so that children
> > > of a "crossmnt" filesystem can be hidden.  The  kernel wouldn't need to
> > > know about this.  It would just tell mountd to refuse to export that
> > > filesystem even if the parent was "crossmnt".
> > > ??
> > 
> > Seems logical enough, but I can't recall seeing requests for it, and
> > the options here already seem complicated enough.
> 
> I haven't seem requests myself.  Just rumours of 'nohide' not working with
> NFSv4, which seems to suggest that someone wants something like that.
> But I cannot find a clear source.
> 
> Maybe:
> 
> http://ubuntuforums.org/showthread.php?t=2152643
> http://ubuntuforums.org/showthread.php?t=1603881
> 
> 
> > 
> > In theory something like that could also be done with namespaces.  (So,
> > run mountd in a separate mount namespace that lacks those children.)
> 
> Do any of the NFS man pages need to be updated to say something about
> namespaces?

Maybe just a note in the rpc.mountd man page that export paths are all
with respect to the mount namespace rpc.mountd is running in?

--b.
