Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45159 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757493Ab1FVAxd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2011 20:53:33 -0400
Date: Tue, 21 Jun 2011 20:55:06 -0400
From: Jeff Layton <jlayton@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, bfields@fieldses.org
Subject: Re: rpc.mountd and character class matches
Message-ID: <20110621205506.71261a43@corrin.poochiereds.net>
In-Reply-To: <20110622083344.3575a424@notabene.brown>
References: <20110621112645.5e9e3d09@tlielax.poochiereds.net>
	<20110622083344.3575a424@notabene.brown>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 22 Jun 2011 08:33:44 +1000
NeilBrown <neilb@suse.de> wrote:

> On Tue, 21 Jun 2011 11:26:45 -0400 Jeff Layton <jlayton@redhat.com> wrote:
> 
> > I was writing up the manpage update for exports to include info about
> > IPv6 addressing, and made a mistake on my first pass. I put the IPv6
> > address in brackets. It turned out that this worked because mountd
> > treats stuff in brackets as a character class wildcard match.
> > 
> > This behavior is undocumented in the manpage and it doesn't seem to
> > work correctly, but it's hard to be sure as I'm not sure what correct
> > behavior is for this.
> > 
> > For instance, I have a host with a valid hostname (tlielax) in DNS on
> > my subnet, and when I put this in /etc/exports:
> > 
> >     /export [whiskeytangofoxtrot](rw)
> > 
> > ...mountd allowed me to mount that. Normally a character class like
> > that should only match if you had a single-character hostname that
> > matches one of the characters in the brackets.
> > 
> > My question is -- do we want to continue to allow this sort of wildcard
> > match in mountd? Given that it's not documented, it's hard to imagine
> > anyone relying on it.
> 
> No, it isn't documented.  But the documentation does talk about
> 'wildcards' (though it only mentions '*' and '?') and [foo] is often a valid
> wildcard, so people could try to use it and if they find that it works...
> 
> I tried your example and it didn't work for me. I could not (from 'notabene')
> mount
>     /home [whiskeytangofoxtrot](rw,no_root_squash,async,no_subtree_check)
> 
> or
>     /home [notabene](rw,no_root_squash,async,no_subtree_check)
> 
> but I could mount
> 
>     /home [notabene]*(rw,no_root_squash,async,no_subtree_check)
> 
> and looking at the code (in support/nfs/wildmat.c) I cannot see how your
> pattern would match anything other than a single character hostname...
> 
> You did of course run "exportfs -r" after changing /etc/exports....
> 
> > 
> > If we do want to keep it, what's the behavior we should be shooting for
> > here?
> > 
> > Thoughts?
> 
> I think we should leave the current functionality in place (once we confirm
> that it works correctly as I think it does), possibly document it, but if the
> hostname looked like an IPv6 address in [], then special case that in much
> the same way that we special-case IP address.
> ie.   192.168.1.2 is a /32 subnetmask
>       one.nine.one.two is a host name
> 

I was pretty sure that I did that before, but I think you're correct
that I must have made a mistake in testing. I redid the above test and
it didn't allow me to mount. I also did some investigation and figured
out why having this was making it behave strangely:

    https://bugzilla.redhat.com/show_bug.cgi?id=714977#c4

I also played around with the test program in wildmat.c and I think the
character class matches are working as intended. Given that I don't see
any need to rip the code out, but I think we probably should document
it. I'll roll up a patch to do that soon.

I think with that, I don't really see any need to special case IPv6
addresses inside brackets. There's really no reason to use brackets
around them in /etc/exports as it doesn't use ':' as a delimiter. When
I do the patch to document character class wildcards, I'll also add a
note to the parts about IPv6 addresses and mention that brackets should
not be used around them in /etc/exports.

-- 
Jeff Layton <jlayton@redhat.com>
