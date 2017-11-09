Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f177.google.com ([209.85.223.177]:45109 "EHLO
        mail-io0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750736AbdKIUEU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Nov 2017 15:04:20 -0500
MIME-Version: 1.0
In-Reply-To: <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
References: <a17842c3-aae7-da98-424e-4441dd727e6d@gentoo.org>
 <CA+55aFzGDyeJctD5Y3paBnysWXbA0cMF1_7mvvzG3n2OAnNhHw@mail.gmail.com>
 <20171109193715.GB21978@ZenIV.linux.org.uk> <40ad7c6e-f0d7-959a-bf29-d3e3843f5d31@gentoo.org>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 9 Nov 2017 12:04:19 -0800
Message-ID: <CA+55aFwqUbd5xVno7tH+yYD=yeu4nBdY=mpZQ+3fA0OEPS_WtQ@mail.gmail.com>
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

On Thu, Nov 9, 2017 at 11:51 AM, Patrick McLean <chutzpah@gentoo.org> wrote:
>
> We do have CONFIG_GCC_PLUGIN_STRUCTLEAK and
> CONFIG_GCC_PLUGIN_STRUCTLEAK_BYREF_ALL enabled on these boxes as well as
> CONFIG_GCC_PLUGIN_RANDSTRUCT as you pointed out before.

It might be worth just verifying without RANDSTRUCT in particular.

That case has probably not gotten a huge amount of testing.  As Al
points out, it can cause absolutely horrendous cache access pattern
changes, but it might also be triggering some corruption in case
there's a problem with the plugin, or with some piece of kernel code
that gets confused by it.

And most obviously: if there is some module or part of the kernel that
got compiled with a different seed for the randstruct hashing, that
will break in nasty nasty ways. Your out-of-kernel module is the
obvious suspect for something like that, but honestly, it could be
some missing build dependency, or simply a missing special case in the
plugin itself a missing __no_randomize_layout or any number of things.

We've hit gcc bugs many times before - and the plugins are just new
opportunities to hit cases that have gotten a lot less testing than
the "normal" code flow has.

The structleak plugin is much less likely to be a problem (simply
because it's a much simpler plugin), but hey, something being NULL
when it shouldn't possibly be might be a stray "leak initialization".

So since you seem to be able to reproduce this _reasonably_ easily,
it's definitely worth checking that it still reproduces even without
the gcc plugins.

Just to narrow it down a bit.

              Linus
