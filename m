From: Jeff Layton <jlayton@redhat.com>
Subject: Re: possible module refcount leak with auth_gss
Date: Wed, 10 Dec 2008 11:25:06 -0500
Message-ID: <20081210112506.2b2d2c3a@tleilax.poochiereds.net>
References: <20081208102855.30081708@tleilax.poochiereds.net>
	<20081208173706.GE16628@fieldses.org>
	<20081209153849.6605559a@tleilax.poochiereds.net>
	<4d569c330812091521s6b9405faq910cb94f067f3b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: "Kevin Coffman" <kwc@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:35905 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753254AbYLJQZO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Dec 2008 11:25:14 -0500
In-Reply-To: <4d569c330812091521s6b9405faq910cb94f067f3b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 9 Dec 2008 18:21:08 -0500
"Kevin Coffman" <kwc@umich.edu> wrote:

> On Tue, Dec 9, 2008 at 3:38 PM, Jeff Layton <jlayton@redhat.com> wrote:
> > On Mon, 8 Dec 2008 12:37:06 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >
> >> On Mon, Dec 08, 2008 at 10:28:55AM -0500, Jeff Layton wrote:
> >> > We had someone report a bug against Fedora that they were seeing very
> >> > high module reference counts for some krb5 related modules on his nfs
> >> > server. For instance:
> >> >
> >> > # lsmod
> >> > Module                  Size  Used by
> >> > des_generic            25216  52736
> >> > cbc                    12160  52736
> >> > rpcsec_gss_krb5        15632  26370
> >> >
> >> > ...the cbc and des_generic each have roughly 2 module references per
> >> > rpcsec_gss_krb5 refcount so I'm assuming that the "lynchpin" here is
> >> > the rpcsec_gss_krb5 refcount which seems to be increasing w/o bound.
> >>
> >> You may want to see this discussion:
> >>
> >>       http://marc.info/?t=122819524700001&r=1&w=2
> >>
> >> And these patches:
> >>
> >>       http://marc.info/?l=linux-nfs&m=122843371318602&w=2
> >>
> >
> > Doh! I saw that discussion and didn't make the connection. Thanks for
> > pointing that out.
> >
> >> In addition to increasing the timeouts on those cache entries, perhaps
> >> we could flush the contexts on rmmod?  Or change the reference counting
> >> somehow--e.g., take a reference only in the presence of export cache
> >> entries that mention krb5, and destroy contexts when the last such goes
> >> away?
> >>
> >
> > That sounds like a better scheme than what we have currently. As it stands
> > now, you can't just unplug the module -- you have to wait for the entries
> > in the cache to time out.
> >
> > FWIW, I tested out Kevin's patches and it still didn't seem to help. The
> > refcounts never seemed to go down (even after several hours). How long
> > should the context live in the cache with those patches? Until the krb5
> > ticket expires? I'll leave the box in this state until around this time
> > tomorrow to be sure (that's when the ticket expires).
> 
> Yes, that should be the normal expiration with my patches.  The
> default ticket lifetime is 10 hours I believe, but that is
> configurable by realm (and service).  You can shorten the lifetime for
> testing by setting an /etc/krb5.conf option.  This example should
> limit lifetimes to 5 minutes (300 seconds) for testing purposes.
> 
> [libdefaults]
> ticket_lifetime = 300s
> 

Thanks Kevin,

It works. With a nfs-utils that has your patches to properly set the
cache timeouts it looks like this problem is generally fixed. The module
refcounts go back to normal once the tickets expire.

That said, I think we should have a look at Bruce's suggestion for changing
the way that the module refcounts are actually handled. It would seem to
make more sense to hold the reference based on the exports using that auth
scheme, and to purge the caches on module unload.

Not a huge deal, but probably something we should consider.

-- 
Jeff Layton <jlayton@redhat.com>
