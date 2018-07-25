Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:42971 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729514AbeGYT03 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Jul 2018 15:26:29 -0400
MIME-Version: 1.0
References: <7828.1532527332@warthog.procyon.org.uk>
In-Reply-To: <7828.1532527332@warthog.procyon.org.uk>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 25 Jul 2018 11:13:29 -0700
Message-ID: <CA+55aFy2v3OW+mmSDF4MPWW673WsJEdQef3LChWg5k9=_k9ggg@mail.gmail.com>
Subject: Re: [GIT PULL] fscache and cachefiles fixes
To: David Howells <dhowells@redhat.com>
Cc: kiran.modukuri@gmail.com, linux-cachefs@redhat.com,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 25, 2018 at 7:02 AM David Howells <dhowells@redhat.com> wrote:
>
> Can you pull these fixes for fscache and cachefiles please?

I've pulled them, but I'm not happy about it. They are all *very* new.

Why do they have commit times literally *minutes* before your email to
ask me to pull?

What kind of testing have these gotten?

Seriously, if I get a pull request with commits this new, I want to
have an *explanation*. The explanation could be "I use quilt, and this
underwent lots of testing outside of git", but the explanation should
be there!

I took them because they look simple enough, but that still leaves me grumpy.

                   Linus
