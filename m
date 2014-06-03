Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f172.google.com ([209.85.128.172]:60245 "EHLO
	mail-ve0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932750AbaFCOZY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Jun 2014 10:25:24 -0400
Received: by mail-ve0-f172.google.com with SMTP id oz11so7118114veb.3
        for <linux-nfs@vger.kernel.org>; Tue, 03 Jun 2014 07:25:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140603105547.GV11096@twins.programming.kicks-ass.net>
References: <20140602104948.4faf0bc2@tlielax.poochiereds.net>
	<CAHQdGtRR6SvEhXiqWo24hoUh9AU9cL82Z8Z-d8-7u951F_d+5g@mail.gmail.com>
	<CALAqxLVmRdv3eVaf_ue-NutDmjxJA2NNAXnH-Tm4a6ud2U7Q4g@mail.gmail.com>
	<CAHQdGtSn9RwdgaFgEDQXjrxSA_Bg=rNWux+96-5f43dyUwXLRw@mail.gmail.com>
	<CALAqxLUwtMnE9eB_dfV=C5CLuXpEdB9+mK7pw2jgo5Yg2ACKPA@mail.gmail.com>
	<CAHQdGtQhurcOsAii7PYNZwEL4Xm-8a2CKBkS4OhrS0FhaAX3Aw@mail.gmail.com>
	<CALAqxLXeuiTffvgu0uBbn2fiYQ0-3PVdZ4V4AxqC-ZkTaFSfQQ@mail.gmail.com>
	<20140603105547.GV11096@twins.programming.kicks-ass.net>
Date: Tue, 3 Jun 2014 10:25:23 -0400
Message-ID: <CAHQdGtTotdPj9ijyCqnAcZeK=vmUe3R1pFaTzXwzQ3pu0Q8WPA@mail.gmail.com>
Subject: Re: nfs4_do_reclaim lockdep pop in v3.15.0-rc1
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Peter Zijlstra <peterz@infradead.org>
Cc: John Stultz <john.stultz@linaro.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Ingo Molnar <mingo@elte.hu>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 3, 2014 at 6:55 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> Ah, I think I see what Trond means; so raw_write_seqcount_{begin,end}()
> are without lockdep, _however_ raw_seqcount_begin() is with lockdep.
>
> This is inconsistent within the same API (seqcount/seqlock).
>
> Yes, we should fix that.
>
> raw_seqcount_begin() is a variant of read_seqcount_begin() but without
> the spin loop in. Maybe we should find a new name for this.

As far as I can see, there are 2 users of raw_seqcount_begin outside
the NFS code: __d_lookup_rcu and netdev_get_name. Neither one of them
are using it as part of a lock (no waiting), but rather as a notifier
of conflicting events. As far as I can tell, there are therefore no
users that benefit from lockdep checking here.

So is there any reason why we shouldn't just revert that part of
commit 1ca7d67cf5d5a, and leave it to future generations to add a
lockdep-enabled version if and when they need it?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
