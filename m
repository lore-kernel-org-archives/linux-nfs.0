Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27748 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751493Ab1FUP0t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Jun 2011 11:26:49 -0400
Date: Tue, 21 Jun 2011 11:26:45 -0400
From: Jeff Layton <jlayton@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com, bfields@fieldses.org, neilb@suse.de
Subject: rpc.mountd and character class matches
Message-ID: <20110621112645.5e9e3d09@tlielax.poochiereds.net>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I was writing up the manpage update for exports to include info about
IPv6 addressing, and made a mistake on my first pass. I put the IPv6
address in brackets. It turned out that this worked because mountd
treats stuff in brackets as a character class wildcard match.

This behavior is undocumented in the manpage and it doesn't seem to
work correctly, but it's hard to be sure as I'm not sure what correct
behavior is for this.

For instance, I have a host with a valid hostname (tlielax) in DNS on
my subnet, and when I put this in /etc/exports:

    /export [whiskeytangofoxtrot](rw)

...mountd allowed me to mount that. Normally a character class like
that should only match if you had a single-character hostname that
matches one of the characters in the brackets.

My question is -- do we want to continue to allow this sort of wildcard
match in mountd? Given that it's not documented, it's hard to imagine
anyone relying on it.

If we do want to keep it, what's the behavior we should be shooting for
here?

Thoughts?
-- 
Jeff Layton <jlayton@redhat.com>
