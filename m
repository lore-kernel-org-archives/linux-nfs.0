Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f172.google.com ([209.85.212.172]:50252 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888Ab2I0Q7f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Sep 2012 12:59:35 -0400
MIME-Version: 1.0
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF7A3@SACEXCMBX04-PRD.hq.netapp.com>
References: <20120807134156.GP1996@amd.com> <20120927145217.GA18962@8bytes.org>
 <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF572@SACEXCMBX04-PRD.hq.netapp.com>
 <20120927153928.GB18962@8bytes.org> <4FA345DA4F4AE44899BD2B03EEEC2FA908FEF7A3@SACEXCMBX04-PRD.hq.netapp.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 27 Sep 2012 09:59:13 -0700
Message-ID: <CA+55aFx5CtDDpXTunJDtkDQWPX7sY0hYMRyekuPErC+s5yXpWw@mail.gmail.com>
Subject: Re: kernel BUG at /data/lemmy/linux.trees.git/fs/nfs/idmap.c:681!
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Joerg Roedel <joro@8bytes.org>, Joerg Roedel <joerg.roedel@amd.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 27, 2012 at 9:16 AM, Myklebust, Trond
<Trond.Myklebust@netapp.com> wrote:
>
> I cannot see how that BUG_ON can be triggered in the current code, given
> that the only place where idmap->idmap_key_cons is set to a non-NULL
> value is covered by a mutex, and that it is always cleared before we
> release said mutex.

Quite frankly, the "I cannot see" thing is *never* an excuse for a BUG_ON().

We don't do kernel-killing asserts in Linux. Never.

The only excuse for a BUG_ON() is "I cannot possibly continue, I don't
even have an error path I can take".

If it's a fundamentally impossible situation, the BUG_ON() should
never have been there in the first place!

And if it's a "I don't see how it could happen", then it should have
been something like

    if (WARN_ON_ONCE(condition))
        goto cleanup;

rather than a BUG_ON().

We have too many f*cking BUG_ON's in the kernel, and the fact that one
triggers and it has taken a month and a half without it even being
resolved is a problem.

Get rid of the thing, already, dammit. If you cannot figure out how it
can happen, then the *last* thing you want to do is then kill the
machine so that it's impossible to debug it sanely.

Besides, as far as I can tell, idmap_key_cons locking is suspect
anyway. Stuff like this:

                cons = ACCESS_ONCE(idmap->idmap_key_cons);
                idmap->idmap_key_cons = NULL;

is an almost certain example of "the code is racy, and we did it
wrong". The above is basically *never* correct.

If the access is properly locked, then the ACCESS_ONCE() is a bug.

And if the access *isn't* properly locked, then setting things to NULL
afterwards is in no way safe.

IOW, either way, it's broken. And there's at least two of those
clearly buggy code-sequences involving that field.

So get rid of the BUG_ON() (possibly replacing it with the
WARN_ON_ONCE), and please look at those ACCESS_ONCE() sequences and
fix them. Either they happen under a lock, or they don't. None of this
crazy racy crap, please.

                   Linus
