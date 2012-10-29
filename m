Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:54160 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758607Ab2J2QHG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 12:07:06 -0400
MIME-Version: 1.0
In-Reply-To: <20121029112907.GA9115@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <20121029112907.GA9115@Krystal>
From: Sasha Levin <levinsasha928@gmail.com>
Date: Mon, 29 Oct 2012 12:06:44 -0400
Message-ID: <CA+1xoqfQn92igbFS1TtrpYuSiy7+Ro02ar=axgqSOJOuE_EVuA@mail.gmail.com>
Subject: Re: [PATCH v7 01/16] hashtable: introduce a small and naive hashtable
To: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Cc: torvalds@linux-foundation.org, tj@kernel.org, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-mm@kvack.org,
        paul.gortmaker@windriver.com, davem@davemloft.net, rostedt@goodmis.org,
        mingo@elte.hu, ebiederm@xmission.com, aarcange@redhat.com,
        ericvh@gmail.com, netdev@vger.kernel.org, josh@joshtriplett.org,
        eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
        teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
        fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
        ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
        linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 29, 2012 at 7:29 AM, Mathieu Desnoyers
<mathieu.desnoyers@efficios.com> wrote:
> * Sasha Levin (levinsasha928@gmail.com) wrote:
>> +
>> +     for (i = 0; i < sz; i++)
>> +             INIT_HLIST_HEAD(&ht[sz]);
>
> ouch. How did this work ? Has it been tested at all ?
>
> sz -> i

Funny enough, it works perfectly. Generally as a test I boot the
kernel in a VM and let it fuzz with trinity for a bit, doing that with
the code above worked flawlessly.

While it works, it's obviously wrong. Why does it work though? Usually
there's a list op happening pretty soon after that which brings the
list into proper state.

I've been playing with a patch that adds a magic value into list_head
if CONFIG_DEBUG_LIST is set, and checks that magic in the list debug
code in lib/list_debug.c.

Does it sound like something useful? If so I'll send that patch out.


Thanks,
Sasha
