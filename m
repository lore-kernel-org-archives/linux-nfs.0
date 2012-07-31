Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:38263 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640Ab2GaVy0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 31 Jul 2012 17:54:26 -0400
MIME-Version: 1.0
In-Reply-To: <20120731143600.GD27834@fieldses.org>
References: <20120731142948.GC27834@fieldses.org> <20120731143600.GD27834@fieldses.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Tue, 31 Jul 2012 14:54:05 -0700
Message-ID: <CA+55aFzM8S0sEAAUXK9f1OhSL-OXmZ_jx_UHF81Eo0-Mi-+T_w@mail.gmail.com>
Subject: Re: nfsd changes for 3.6
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk, matthew@wil.cx
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 31, 2012 at 7:36 AM, J. Bruce Fields <bfields@fieldses.org> wrote:
>
> By the way, for a few years now I've been semi-regularly picking up
> locks.c changes for my tree.  I wonder if I should be.

I really wish you didn't. Or at least not this way.

For example, now you removed that lm_release_private case, but you did
that without apparently talking to any VFS maintainers.

And the commit seems to be pure shit.

Why is it pure shit? Look at what users are left. THERE ARE NO USERS
THAT SET THAT FIELD ANY MORE!

Maybe I missed some odd user that somehow avoids the grep, but I don't
think so. So there is nothing that ever sets it, why the hell does the
thing still remain at all?

So if this is a real bugfix, then I think it damn well should

 (a) at a minimum have been discussed with VFS maintainers

 (b) have been thought through a bit more (ie remove all remains of
that now useless lm_release_private field)

 (c) likely never have gone through the NFSD tree in any case.

I've pulled the changes for now, but I absolutely *detest* seeing
things like this. I care very little about the nfsd code, but I care
deeply when I see insanity happening in the VFS layer. And right now,
"lm_release_private" is insane as of this pull.

                Linus
