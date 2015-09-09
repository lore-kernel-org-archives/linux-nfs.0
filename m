Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:47283 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752119AbbIIU7c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Sep 2015 16:59:32 -0400
Date: Wed, 9 Sep 2015 16:59:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: readdir and old cookie verifier
Message-ID: <20150909205930.GE25750@fieldses.org>
References: <267164181.6444770.1441717712553.JavaMail.zimbra@desy.de>
 <20150909190308.GB25750@fieldses.org>
 <1769158187.6826766.1441829428223.JavaMail.zimbra@desy.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1769158187.6826766.1441829428223.JavaMail.zimbra@desy.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 09, 2015 at 10:10:28PM +0200, Mkrtchyan, Tigran wrote:
> 
> 
> ----- Original Message -----
> > From: "J. Bruce Fields" <bfields@fieldses.org>
> > To: "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>
> > Cc: "linux-nfs" <linux-nfs@vger.kernel.org>
> > Sent: Wednesday, September 9, 2015 9:03:08 PM
> > Subject: Re: readdir and old cookie verifier
> 
> > On Tue, Sep 08, 2015 at 03:08:32PM +0200, Mkrtchyan, Tigran wrote:
> >> 
> >> Dear NFS gurus,
> >> 
> >> we run into situation, where client gets BAD_COOKIE on a readdir.
> >> Before I go and try to adopt our server to handle it, let me describe
> >> the situation.
> >> 
> >> A client node (we have seen it with RHEL6 and Ubuntu 12.04, but probably
> >> others affected as well) send a bunch of readdirs to the server. After some
> >> time (this many be hours, days ) client sends an other set of readdirs.
> > 
> > Starting over with cookie zero, or resuming using some cached cookie?
> 
> It resuming with a cached cookie. Looks like the client still has a first portion
> of the listing, and want's to fetch the rest. At least in one case we found that
> application does a opendir and series of readdirs but with a big delay (iterates over
> files in a directory).
> 
> > 
> >> But
> >> it reuses cookie verifier from the first readdir sequence. Server sends back
> >> BAD_COOKIE, but client never starts over with a cookie and verifier being zero.
> > 
> > I don't think it's really required to do that.  7530 suggests that might
> > indeed result in an error:
> > 
> >	It should be a rare occurrence that a server is unable to
> >	continue properly reading a directory with the provided
> >	cookie/cookieverf pair.  The server should make every effort to
> >	avoid this condition since the application at the client may not
> >	be able to properly handle this type of failure.
> > 
> > (Also, RFC 7530 16.24.4 says NOT_SAME is the error in this case.  Is
> > that really correct?  I would have expected BAD_COOKIE too.)
> 
> Well, it makes sense to me. If a client asks for a content of a directory
> which is changed, how one can provide that listing?

My understanding of the traditional approach: the directory is treated
as an array of entries, and the cookie is an index into that array.
Entries in the array are never moved; if an entry in the middle is
removed it's marked absent somehow to prevent having to shift later
entries back.  This guarantees that iterating over the directory will
get every unchanged entry exactly once.  (It's hazier what will hapen to
removed or added entries, but posix is OK with that.) In practice
filesystems do something more complicated than this (the "array" is
probably some virtual index on the side?).

> On the other hand,
> if we always return NOT_SAME, then client will never the that listing and
> endup with infinite READDIR loop.
> 
> > 
> >> As a result, inconsistent listing and anhappy user:
> >> 
> >> 
> >> [exflserv04] ~ $ ls /pnfs/desy.de/exfel/disk/LCLS/2015/RAW/XCS/xcsh8215/xtc/
> >> ls: reading directory /pnfs/desy.de/exfel/disk/LCLS/2015/RAW/XCS/xcsh8215/xtc/:
> >> Unknown error 523
> > 
> > That's EBADCOOKIE.
> > 
> >> Is this behavior of the client correct?
> > 
> > I think so.  It's a huge pain for filesystems, but unfortunately readdir
> > cookies (like filehandles) are forever.
> 
> I already have raised this issue.
> 
> https://www.ietf.org/mail-archive/web/nfsv4/current/msg07267.html
> 
> Probably I have to bring it once again. Specs (v3, v4,+) doesn't
> talk about permanent cookies.
> 
> My guess is that client assumes that old verifier is ok as it didn't detect
> any changes in attributes. For now, we will update our server to generate a new
> listing (in our system, directory listings are virtual objects and generated on
> demand) with a hope, that we will get the same result (and the same verifier).

The resulting behavior probably still won't be posix-compliant.  I don't
know in practice to what extent applications depend on those guarantees.

If you need to keep some sort of state around to handle future readdirs,
then I guess you need some way for that to be expressed in the protocol?
So clients need to be able to open/close directories, or somehow tell
you when they're done reading a directory, so that you know when it's
safe to throw away that state.

--b.
