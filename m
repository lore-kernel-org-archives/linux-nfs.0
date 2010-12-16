Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:34516 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750922Ab0LPAgr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 19:36:47 -0500
Date: Wed, 15 Dec 2010 19:36:46 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Simon Kirby <sim@hostway.ca>, linux-nfs@vger.kernel.org
Subject: Re: System CPU increasing on idle 2.6.36
Message-ID: <20101216003646.GG9646@fieldses.org>
References: <1292441630.3068.55.camel@heimdal.trondhjem.org>
 <20101215194956.GA9646@fieldses.org>
 <1292443028.3068.60.camel@heimdal.trondhjem.org>
 <20101215201908.GB9646@fieldses.org>
 <1292445128.3068.71.camel@heimdal.trondhjem.org>
 <20101215214854.GC9646@fieldses.org>
 <1292451346.3068.93.camel@heimdal.trondhjem.org>
 <20101215222928.GE9646@fieldses.org>
 <20101215225501.GF9646@fieldses.org>
 <1292457489.3068.98.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1292457489.3068.98.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 15, 2010 at 06:58:09PM -0500, Trond Myklebust wrote:
> On Wed, 2010-12-15 at 17:55 -0500, J. Bruce Fields wrote:
> > On Wed, Dec 15, 2010 at 05:29:28PM -0500, J. Bruce Fields wrote:
> > > On Wed, Dec 15, 2010 at 05:15:46PM -0500, Trond Myklebust wrote:
> > > > I'm quite happy to accept that my user may map to completely different
> > > > identities on the server as I switch authentication schemes. Fixing that
> > > > is indeed the administrator's problem.
> > > > 
> > > > I'm thinking of the simple case of creating a file, and then expecting
> > > > to see that file appear labelled with the correct user id when I do 'ls
> > > > -l'. That should work irrespectively of the authentication scheme that I
> > > > choose.
> > > > 
> > > > In other words, if I authenticate as 'trond' on my client or to the
> > > > kerberos server, then do
> > > > 
> > > >         touch foo
> > > >         ls -l foo
> > > > 
> > > > I should see a file that is owned by 'trond'.
> > > 
> > > Thanks, understood; but then, this isn't about behavior that occurs when
> > > a user *changes* authentication flavors.
> > > 
> > > It's about what happens when someone sets nfs4_disable_idmapping but
> > > shouldn't have.
> > 
> > In other words, to make sure I understand:
> > 
> > 	- Is this switching-on-auth flavor *just* there to protect
> > 	  confused administrators against themselves?
> > 	- Or is there some reasons someone who knew what they were doing
> > 	  would actually *need* that behavior?
> 
> It is there to ensure that you can use different type of authentication
> when speaking to different servers, and still have it work without the
> administrator having to add special mount options.

Oh, OK--now I understand, thanks!  Then it really is just a restricted
sort of per-mountpoint idmapping.

As such I'm not sure I understand the relative merits of that versus
(possibly per-server) idmapd configuration.  But at least it seems
tolerable.

The biggest remaining problem either way is that the user experience on
an NFSv3->NFSv4 upgrade is still:

	- oh, look, file owners look all wrong.
	- go find documentation of the needed configuration
	  (domain setting in /etc/idmapd.conf, or nfs4_disable_idmapping
	  option)

--b.

> As I've said before, the uid-on-the-wire behaviour only makes sense with
> AUTH_SYS. It adds no value when authenticating using principals, and
> will in many (most?) cases end up doing the wrong thing.
> 
> Trond
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 
