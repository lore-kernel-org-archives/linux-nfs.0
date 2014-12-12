Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f52.google.com ([209.85.216.52]:60118 "EHLO
	mail-qa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750867AbaLLC3i (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Dec 2014 21:29:38 -0500
MIME-Version: 1.0
In-Reply-To: <20141212021241.GA5944@ZenIV.linux.org.uk>
References: <1418238480-18857-1-git-send-email-jlayton@primarydata.com>
	<20141212021241.GA5944@ZenIV.linux.org.uk>
Date: Thu, 11 Dec 2014 18:29:37 -0800
Message-ID: <CA+55aFy_LRUzMO_ixgVtysr7OKs=GSk9dU1ORRUdrTn210VuyA@mail.gmail.com>
Subject: Re: [PATCH v2 00/16] nfsd/sunrpc: add support for a workqueue-based nfsd
From: Linus Torvalds <torvalds@linux-foundation.org>
To: Al Viro <viro@zeniv.linux.org.uk>
Cc: Jeff Layton <jlayton@primarydata.com>, Bruce Fields <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Tejun Heo <tj@kernel.org>, NeilBrown <neilb@suse.de>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 11, 2014 at 6:12 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
>
> Linus, do you see any problems with the following patch (against the mainline)?

Not concpetually, but create_kthread() uses CLONE_FS, and I don't
think it's just umask that things like nfsd want to avoid sharing.
What about all the *other* fields?

Just as an example: even if all the threads actually end up all having
the same global root, what about contention on 'fs->lock'?

I have *not* looked at the details, and maybe there's some reason I'm
completely off, but it worries me.

                      Linus
