Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:46875 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752096Ab0LOWzH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Dec 2010 17:55:07 -0500
Date: Wed, 15 Dec 2010 17:55:01 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Simon Kirby <sim@hostway.ca>, linux-nfs@vger.kernel.org
Subject: Re: System CPU increasing on idle 2.6.36
Message-ID: <20101215225501.GF9646@fieldses.org>
References: <1292437333.3068.14.camel@heimdal.trondhjem.org>
 <20101215183816.GB7773@fieldses.org>
 <1292441630.3068.55.camel@heimdal.trondhjem.org>
 <20101215194956.GA9646@fieldses.org>
 <1292443028.3068.60.camel@heimdal.trondhjem.org>
 <20101215201908.GB9646@fieldses.org>
 <1292445128.3068.71.camel@heimdal.trondhjem.org>
 <20101215214854.GC9646@fieldses.org>
 <1292451346.3068.93.camel@heimdal.trondhjem.org>
 <20101215222928.GE9646@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101215222928.GE9646@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Dec 15, 2010 at 05:29:28PM -0500, J. Bruce Fields wrote:
> On Wed, Dec 15, 2010 at 05:15:46PM -0500, Trond Myklebust wrote:
> > On Wed, 2010-12-15 at 16:48 -0500, J. Bruce Fields wrote:
> > > On Wed, Dec 15, 2010 at 03:32:08PM -0500, Trond Myklebust wrote:
> > > > On Wed, 2010-12-15 at 15:19 -0500, J. Bruce Fields wrote:
> > > > 
> > > > > Could you give an example of a case in which all of the following are
> > > > > true?:
> > > > > 	- the administrator explicitly requests numeric id's (for
> > > > > 	  example by setting nfs4_disable_idmapping).
> > > > > 	- numeric id's work as long as the client uses auth_sys.
> > > > > 	- they no longer work if that same client switches to krb5.
> > > > 
> > > > Trivially:
> > > > 
> > > > Server /etc/passwd maps trondmy to uid 1000
> > > > Client /etc/passwd maps trondmy to uid 500
> > > 
> > > I understand that any problematic case would involve different
> > > name<->id mappings on the two sides.
> > > 
> > > What I don't understand--and apologies if I'm being dense!--is what
> > > sequence of operations exactly would work in this situation if we
> > > automatically switch idmapping based on auth flavor, and would not work
> > > without it.
> > > 
> > > Are you imagining a future client that is also able to switch auth
> > > flavors on the fly (say, based on whether a krb5 ticket exists or not),
> > > or just unmounting and remounting to change the security flavor?
> > > 
> > > Are you thinking of creating a file under one flavor and accessing it
> > > under another?
> > 
> > Neither.
> > 
> > I'm quite happy to accept that my user may map to completely different
> > identities on the server as I switch authentication schemes. Fixing that
> > is indeed the administrator's problem.
> > 
> > I'm thinking of the simple case of creating a file, and then expecting
> > to see that file appear labelled with the correct user id when I do 'ls
> > -l'. That should work irrespectively of the authentication scheme that I
> > choose.
> > 
> > In other words, if I authenticate as 'trond' on my client or to the
> > kerberos server, then do
> > 
> >         touch foo
> >         ls -l foo
> > 
> > I should see a file that is owned by 'trond'.
> 
> Thanks, understood; but then, this isn't about behavior that occurs when
> a user *changes* authentication flavors.
> 
> It's about what happens when someone sets nfs4_disable_idmapping but
> shouldn't have.

In other words, to make sure I understand:

	- Is this switching-on-auth flavor *just* there to protect
	  confused administrators against themselves?
	- Or is there some reasons someone who knew what they were doing
	  would actually *need* that behavior?

--b.
