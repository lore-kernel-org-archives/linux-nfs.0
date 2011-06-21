Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:56085 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755534Ab1FUWd5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2011 18:33:57 -0400
Date: Wed, 22 Jun 2011 08:33:44 +1000
From: NeilBrown <neilb@suse.de>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, bfields@fieldses.org
Subject: Re: rpc.mountd and character class matches
Message-ID: <20110622083344.3575a424@notabene.brown>
In-Reply-To: <20110621112645.5e9e3d09@tlielax.poochiereds.net>
References: <20110621112645.5e9e3d09@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 21 Jun 2011 11:26:45 -0400 Jeff Layton <jlayton@redhat.com> wrote:

> I was writing up the manpage update for exports to include info about
> IPv6 addressing, and made a mistake on my first pass. I put the IPv6
> address in brackets. It turned out that this worked because mountd
> treats stuff in brackets as a character class wildcard match.
> 
> This behavior is undocumented in the manpage and it doesn't seem to
> work correctly, but it's hard to be sure as I'm not sure what correct
> behavior is for this.
> 
> For instance, I have a host with a valid hostname (tlielax) in DNS on
> my subnet, and when I put this in /etc/exports:
> 
>     /export [whiskeytangofoxtrot](rw)
> 
> ...mountd allowed me to mount that. Normally a character class like
> that should only match if you had a single-character hostname that
> matches one of the characters in the brackets.
> 
> My question is -- do we want to continue to allow this sort of wildcard
> match in mountd? Given that it's not documented, it's hard to imagine
> anyone relying on it.

No, it isn't documented.  But the documentation does talk about
'wildcards' (though it only mentions '*' and '?') and [foo] is often a valid
wildcard, so people could try to use it and if they find that it works...

I tried your example and it didn't work for me. I could not (from 'notabene')
mount
    /home [whiskeytangofoxtrot](rw,no_root_squash,async,no_subtree_check)

or
    /home [notabene](rw,no_root_squash,async,no_subtree_check)

but I could mount

    /home [notabene]*(rw,no_root_squash,async,no_subtree_check)

and looking at the code (in support/nfs/wildmat.c) I cannot see how your
pattern would match anything other than a single character hostname...

You did of course run "exportfs -r" after changing /etc/exports....

> 
> If we do want to keep it, what's the behavior we should be shooting for
> here?
> 
> Thoughts?

I think we should leave the current functionality in place (once we confirm
that it works correctly as I think it does), possibly document it, but if the
hostname looked like an IPv6 address in [], then special case that in much
the same way that we special-case IP address.
ie.   192.168.1.2 is a /32 subnetmask
      one.nine.one.two is a host name

NeilBrown
