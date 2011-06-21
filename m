Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:50036 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753500Ab1FUP5U (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2011 11:57:20 -0400
Date: Tue, 21 Jun 2011 11:57:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, steved@redhat.com, neilb@suse.de
Subject: Re: rpc.mountd and character class matches
Message-ID: <20110621155718.GB25534@fieldses.org>
References: <20110621112645.5e9e3d09@tlielax.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110621112645.5e9e3d09@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jun 21, 2011 at 11:26:45AM -0400, Jeff Layton wrote:
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

If it's complicated, likely buggy code, and we can't find any evidence
that anyone uses it, let's toss it.  Hard to imagine anyone will
complain, but if they do, at least they may be able to help us answer
this question:

> If we do want to keep it, what's the behavior we should be shooting for
> here?

--b.
