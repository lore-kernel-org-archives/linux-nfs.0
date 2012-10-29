Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:60854 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751045Ab2J2OuE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 10:50:04 -0400
MIME-Version: 1.0
In-Reply-To: <20121029124229.GC11733@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
 <1351450948-15618-9-git-send-email-levinsasha928@gmail.com> <20121029124229.GC11733@Krystal>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 29 Oct 2012 07:49:42 -0700
Message-ID: <CA+55aFzO8DJJP3HBfgqXFac9r3=bYK+_nYe4cuXiNFg-623s6w@mail.gmail.com>
Subject: Re: [PATCH v7 09/16] SUNRPC/cache: use new hashtable implementation
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: Sasha Levin <levinsasha928@gmail.com>, tj@kernel.org,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
        rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com,
        aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org,
        josh@joshtriplett.org, eric.dumazet@gmail.com, axboe@kernel.dk,
        agk@redhat.com, dm-devel@redhat.com, neilb@suse.de,
        ccaulfie@redhat.com, teigland@redhat.com, Trond.Myklebust@netapp.com,
        bfields@fieldses.org, fweisbec@gmail.com, jesse@nicira.com,
        venkat.x.venkatsubra@oracle.com, ejt@redhat.com, snitzer@redhat.com,
        edumazet@google.com, linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 29, 2012 at 5:42 AM, Mathieu Desnoyers
<mathieu.desnoyers@efficios.com> wrote:
>
> So defining e.g.:
>
> #include <linux/log2.h>
>
> #define DFR_HASH_BITS  (PAGE_SHIFT - ilog2(BITS_PER_LONG))
>
> would keep the intended behavior in all cases: use one page for the hash
> array.

Well, since that wasn't true before either because of the long-time
bug you point out, clearly the page size isn't all that important. I
think it's more important to have small and simple code, and "9" is
certainly that, compared to playing ilog2 games with not-so-obvious
things.

Because there's no reason to believe that '9' is in any way a worse
random number than something page-shift-related, is there? And getting
away from *previous* overly-complicated size calculations that had
been broken because they were too complicated and random, sounds like
a good idea.

            Linus
