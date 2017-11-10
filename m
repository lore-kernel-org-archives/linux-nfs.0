Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f174.google.com ([209.85.223.174]:47131 "EHLO
        mail-io0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753490AbdKJSmv (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Nov 2017 13:42:51 -0500
MIME-Version: 1.0
In-Reply-To: <23f7da04-95f7-24e7-ee70-ce40c5b8fee3@gentoo.org>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <20171109193715.GB21978@ZenIV.linux.org.uk> <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
 <CA+55aFwqUbd5xVno7tH+yYD=yeu4nBdY=mpZQ+3fA0OEPS_WtQ@mail.gmail.com> <23f7da04-95f7-24e7-ee70-ce40c5b8fee3@gentoo.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Fri, 10 Nov 2017 10:42:49 -0800
Message-ID: <CA+55aFx63wq=qN0+P+S-aahq7HzvYLi1tSxhPT9x78E8BrMNGQ@mail.gmail.com>
Subject: Re: [nfsd4] potentially hardware breaking regression in 4.14-rc and 4.13.11
To: Patrick McLean <chutzpah@gentoo.org>
Cc: Al Viro <viro@zeniv.linux.org.uk>,
        Bruce Fields <bfields@redhat.com>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        stable <stable@vger.kernel.org>,
        Thorsten Leemhuis <regressions@leemhuis.info>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 9, 2017 at 5:58 PM, Patrick McLean <chutzpah@gentoo.org> wrote:
>
> Something must have changed since 4.13.8 to trigger this though.

Well, yes and no.

Obviously something changed, but it doesn't necessarily have to be
anything particular.

Almost every time we've seen compiler bugs, it's been an innocuous
change that just happened to trigger a latent issue. Pretty much by
definition compiler bugs tend to be about rare situations, so it's
some odd special case that triggers.

Since it's apparently fairly repeatable for you, a bisection between
4.13.8 and 4.13.11 would be very interesting, and shouldn't take all
that long. There's only 142 commits in that range, so even just a
partial bisection of say four of five rounds should narrow it down to
just a couple of commits. And even a full bisection should only take
something like 8 build/test cycles.

Arnd pointed to some commits that might be relevant for the cp210x
module, but those are all already in 4.13.8, so if 4.13.8 really is
rock solid for you, I don't think that's it.

I really don't see anything that looks even half-way suspicious in
that 4.13.8..11 range. But as mentioned, compiler interactions can be
_really_ subtle.

And hey, it can be a real kernel bug too, that just happens to be
exposed by RANDSTRUCT, so a bisect really would be very nice.

Because in the end, compiler bugs are very rare. They are particularly
annoying when they do happen, though, so they loom big in the mind of
people who have had to chase them down.

                 Linus
