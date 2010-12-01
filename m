Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35396 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753133Ab0LAQ3c (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Dec 2010 11:29:32 -0500
Date: Wed, 1 Dec 2010 11:29:12 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Neil Brown <neilb@suse.de>, Steve Dickson <SteveD@redhat.com>,
        Spelic <spelic@shiftmail.org>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4 behaviour on unknown users
Message-ID: <20101201162912.GC6832@fieldses.org>
References: <4CF3F326.4060608@shiftmail.org>
 <20101129190122.GA31843@fieldses.org>
 <1291057747.12784.38.camel@heimdal.trondhjem.org>
 <4CF519F2.8080900@RedHat.com>
 <1291155578.2998.38.camel@heimdal.trondhjem.org>
 <20101130222651.GB5054@fieldses.org>
 <1291156414.4393.2.camel@heimdal.trondhjem.org>
 <20101130223627.GC5054@fieldses.org>
 <20101201135740.0d3b5948@notabene.brown>
 <1291173002.7694.7.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1291173002.7694.7.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Nov 30, 2010 at 10:10:02PM -0500, Trond Myklebust wrote:
> On Wed, 2010-12-01 at 13:57 +1100, Neil Brown wrote:
> > I have a strong memory from about 7 years ago of Brian Pawlowski saying - or
> > possibly being quoted as saying - that the user information in NFS requests
> > (the stuff that idmapper handles) is totally independent of the RPC
> > authentication mechanism being used (the AUTH_SYS / RPCSEC_GSS stuff).
> > 
> > I always thought that was nonsense, but I wasn't in a position to discuss it
> > at the time for reasons that I really don't recall.
> > 
> > If users are being authorised using numbers (AUTH_SYS) then it only (to me)
> > makes sense to communication all identies as numbers.
> > And if users are being authenticated as name@domain strings, then it only
> > make sense to communicate all identities as name@domain.
> > 
> > But this path is not the path for NFSv4 followed.
> > 
> > I've very glad to see Linux NFS allowing numeric IDs "on the wire" and hope
> > to see this very sensible approach widely adopted (where AUTH_SYS is used).
> > I think it would be great if nfsd did the same thing completely in-kernel
> > without reference to idmapd.  Accepting either numeric or domain-based is
> > trivial.  Choosing which to send on a per-client basis might be a challenge,
> > but probably not a big one.
> > 
> > 
> > I wonder if Brian remembers saying anything like that...
> 
> I think you need to take beepy's words in context here: as I believe I
> mentioned previously, RFC3530 (and its predecessor RFC3010) assumed
> everyone would be using principals for authenticating, either through
> RPCSEC_GSS w/ krb5, or through the SPKM/Lipkey mechanism. So sure was
> everyone of this, that AUTH_SYS isn't even mentioned as a valid
> authentication mechanism, and so nobody had to worry about the
> consequences of using it.

I also wonder whether the value of a transparent upgrade from NFSv3 got
a little lost.

To me that seems like the first requirement for version n+1 of
anything--that we should be able to upgrade people to version n without
their noticing.

Maybe there are features that are necessarily incompatible, and that
merit the downside, but the downside--losing the chance to get new
features to every user automatically--seems significant to me.


And, perhaps it's a disease, but I have gotten into the habit of
thinking of the (krb5 principal)->(id, gid's) mapping as independent of
the (NFSv4 user name)<->(uid) and (NFSv4 group name)<->(gid) mappings.

Granted they have to be coordinated on any reasonably complicated setup.
But there are simple cases where they don't necessarily need to be.

E.g. on a dumb "cp -ax / /nfs" backup it doesn't really matter "who"
does the backup as long as they have sufficient permissions, since the
files will all be explicitly chown'd as they're created.  And with krb5
it's simple enough to make that work with a single static mapping from a
client-side principal to root on the server.

And, again, that's something that works now with NFSv3.

--b.
