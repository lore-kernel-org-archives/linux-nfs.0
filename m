Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41400 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751289Ab0LHAPu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Dec 2010 19:15:50 -0500
Date: Tue, 7 Dec 2010 19:15:48 -0500
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: Spencer Shepler <spencer.shepler@gmail.com>
Cc: "'Trond Myklebust'" <Trond.Myklebust@netapp.com>,
        "'Thomas Haynes'" <thomas@netapp.com>,
        "'Spelic'" <spelic@shiftmail.org>, linux-nfs@vger.kernel.org
Subject: Re: NFSv4 behaviour on unknown users
Message-ID: <20101208001548.GA30196@fieldses.org>
References: <1291155578.2998.38.camel@heimdal.trondhjem.org>
 <20101130222651.GB5054@fieldses.org>
 <1291156414.4393.2.camel@heimdal.trondhjem.org>
 <20101130223627.GC5054@fieldses.org>
 <20101201135740.0d3b5948@notabene.brown>
 <1291173002.7694.7.camel@heimdal.trondhjem.org>
 <20101201162912.GC6832@fieldses.org>
 <99BBEF51-7EB1-4BAA-9B12-F0F98A629C74@netapp.com>
 <1291331885.2915.1.camel@heimdal.trondhjem.org>
 <03e401cb9278$ad554ad0$07ffe070$@gmail.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <03e401cb9278$ad554ad0$07ffe070$@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Dec 02, 2010 at 03:28:48PM -0800, Spencer Shepler wrote:
> 
> 
> > -----Original Message-----
> > From: linux-nfs-owner@vger.kernel.org [mailto:linux-nfs-
> > owner@vger.kernel.org] On Behalf Of Trond Myklebust
> > Sent: Thursday, December 02, 2010 3:18 PM
> > To: Thomas Haynes
> > Cc: J. Bruce Fields; Spelic; linux-nfs@vger.kernel.org
> > Subject: Re: NFSv4 behaviour on unknown users
> > 
> > On Thu, 2010-12-02 at 17:10 -0600, Thomas Haynes wrote:
> > > On Dec 1, 2010, at 10:29 AM, J. Bruce Fields wrote:
> > >
> > > > On Tue, Nov 30, 2010 at 10:10:02PM -0500, Trond Myklebust wrote:
> > > >>
> > > >> I think you need to take beepy's words in context here: as I
> > > >> believe I mentioned previously, RFC3530 (and its predecessor
> > > >> RFC3010) assumed everyone would be using principals for
> > > >> authenticating, either through RPCSEC_GSS w/ krb5, or through the
> > > >> SPKM/Lipkey mechanism. So sure was everyone of this, that AUTH_SYS
> > > >> isn't even mentioned as a valid authentication mechanism, and so
> > > >> nobody had to worry about the consequences of using it.
> > > >
> > > > I also wonder whether the value of a transparent upgrade from NFSv3
> > > > got a little lost.
> > > >
> > > > To me that seems like the first requirement for version n+1 of
> > > > anything--that we should be able to upgrade people to version n
> > > > without their noticing.
> > > >
> > > > Maybe there are features that are necessarily incompatible, and that
> > > > merit the downside, but the downside--losing the chance to get new
> > > > features to every user automatically--seems significant to me.
> > > >
> > > >
> > > > And, perhaps it's a disease, but I have gotten into the habit of
> > > > thinking of the (krb5 principal)->(id, gid's) mapping as independent
> > > > of the (NFSv4 user name)<->(uid) and (NFSv4 group name)<->(gid)
> > mappings.
> > > >
> > > > Granted they have to be coordinated on any reasonably complicated
> > setup.
> > > > But there are simple cases where they don't necessarily need to be.
> > > >
> > > > E.g. on a dumb "cp -ax / /nfs" backup it doesn't really matter "who"
> > > > does the backup as long as they have sufficient permissions, since
> > > > the files will all be explicitly chown'd as they're created.  And
> > > > with krb5 it's simple enough to make that work with a single static
> > > > mapping from a client-side principal to root on the server.
> > > >
> > > > And, again, that's something that works now with NFSv3.
> > > >
> > > > --b.
> > > > --
> > > > To unsubscribe from this list: send the line "unsubscribe linux-nfs"
> > > > in the body of a message to majordomo@vger.kernel.org More majordomo
> > > > info at  http://vger.kernel.org/majordomo-info.html
> > >
> > >
> > > Another question is whether or not such an approach would be
> > > appreciated as part of 3530bis?
> > 
> > You want to add a discussion about AUTH_SYS support for 3530bis? I'd be OK
> > with that...
> 
> What would the substance of such a discussion?
> 
> The NFSv4 RFCs do not preclude the use of a variety of RPC authentication types.
> It asks that implementations treat the RPCSEC_GSS framework and the Kerberos
> and lipkey types as mandatory to implement.
> 
> Given that the user of NFSv4 is not forced to use these or other authentication
> methods, does the discussion reside in the interaction with these various
> authentication types and their impact on the content of communicated attributes?
> 
> In any case, I would suggest a treatment of these issues be captured in a
> separate I-D and ultimately a separate RFC to allow for expediency of
> publication and application to NFSv4.0 and NFSv4.1.

The v3->v4 upgrade would be dead-simple if the default (without *any*
idmapping configuration) was to send and receive purely numeric id's.

A client that attempts that with a server that has normal NFSv4
name-mapping set up will see "nobody" on any "ls" and get BADOWNER on
any attempt to set anything, but that's more or less the typical
experience right now, and as a default if anything numeric id's seems
safer than guessing a domain and assuming local account names map into
it.

And as soon as some form of idmapping is set up (even if it's just
setting a default domain, effectively just a declaration that any local
account <user> is also an nfsv4 user <user>@<domain>), things work
normally.

I don't see any of this as a violation of the spec, which allows use of
numeric id's in the absence of a "valid translation" for a user or
group.

And the mere existance of a local account with a certain name doesn't
imply the existance of a valid translation into any nfsv4 namespace.

So if that makes sense, then I don't think any change to rfc 3530
section 5.8 is required beyond possibly some clarification or change in
emphasis.

(I see AUTH_SYS as a different issue.  It's unfortunately true that
AUTH_SYS has effectively turned out to be required-to-implement even if
it wasn't meant to be, so maybe the spec's out of line with reality
there; but I haven't heard of that causing any practical
problems--whereas "why does ls show all users as nobody after an upgrade
to NFSv4" is a FAQ.)

--b.
