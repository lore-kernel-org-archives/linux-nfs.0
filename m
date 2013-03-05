Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ye0-f182.google.com ([209.85.213.182]:63356 "EHLO
	mail-ye0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753391Ab3CEXrE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Mar 2013 18:47:04 -0500
Date: Tue, 5 Mar 2013 15:47:00 -0800
From: Tejun Heo <tj@kernel.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Oleg Nesterov <oleg@redhat.com>,
        Mandeep Singh Baines <msb@chromium.org>,
        Ming Lei <ming.lei@canonical.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "Rafael J. Wysocki" <rjw@sisk.pl>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@redhat.com>, Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: LOCKDEP: 3.9-rc1: mount.nfs/4272 still has locks held!
Message-ID: <20130305234700.GE1227@htj.dyndns.org>
References: <20130304092310.1d21100c@tlielax.poochiereds.net>
 <CACBanvrc0orXGZ1v+gKHtVPKWYKGEFx46dwoDCjTU78+nPtZyg@mail.gmail.com>
 <20130304205307.GA13527@redhat.com>
 <4FA345DA4F4AE44899BD2B03EEEC2FA9286AEEB0@sacexcmbx05-prd.hq.netapp.com>
 <20130305082308.6607d4db@tlielax.poochiereds.net>
 <20130305174648.GF12795@htj.dyndns.org>
 <20130305174954.GG12795@htj.dyndns.org>
 <20130305140312.243cb094@tlielax.poochiereds.net>
 <20130305190923.GI12795@htj.dyndns.org>
 <20130305183941.19ff39ce@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130305183941.19ff39ce@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello, Jeff.

On Tue, Mar 05, 2013 at 06:39:41PM -0500, Jeff Layton wrote:
> Al was in the middle of his signal handling/execve rework though and I
> ran the idea past him. He pointedly told me that I was crazy for even
> considering it. This is rather non-trivial to handle since it means
> mucking around in a bunch of arch-specific code and dealing with all of
> the weirdo corner cases.

Hmmm... I tried it a couple years ago while I was working on ptrace
improvements to support checkpoint-restart in userland (PTRACE_SEIZE
and friends) and had a half-working code.  At the time, Oleg was
against the idea and something else came up so I didn't push it all
the way but IIRC it didn't need to touch any arch code.  It should be
able to just share the existing trap path with ptrace.

> Anyone up for working out how to handle a freeze event on a process
> that already has a pending signal, while it's being ptraced? It's
> probably best to chat with Al (cc'ed here) before you embark on this
> plan since he was just in that code recently.

Maybe Al sees something that I don't but AFAICS it should be doable in
generic code proper and I don't think it's gonna be that hard.

Oleg, are you still opposed to the idea of making freezer share trap
points with ptrace?

Thanks.

-- 
tejun
