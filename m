Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay4-d.mail.gandi.net ([217.70.183.196]:60218 "EHLO
	relay4-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760255Ab2J2ScJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 14:32:09 -0400
Date: Mon, 29 Oct 2012 11:31:57 -0700
From: Josh Triplett <josh@joshtriplett.org>
To: Sasha Levin <levinsasha928@gmail.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>,
        torvalds@linux-foundation.org, tj@kernel.org,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, paul.gortmaker@windriver.com, davem@davemloft.net,
        rostedt@goodmis.org, mingo@elte.hu, ebiederm@xmission.com,
        aarcange@redhat.com, ericvh@gmail.com, netdev@vger.kernel.org,
        eric.dumazet@gmail.com, axboe@kernel.dk, agk@redhat.com,
        dm-devel@redhat.com, neilb@suse.de, ccaulfie@redhat.com,
        teigland@redhat.com, Trond.Myklebust@netapp.com, bfields@fieldses.org,
        fweisbec@gmail.com, jesse@nicira.com, venkat.x.venkatsubra@oracle.com,
        ejt@redhat.com, snitzer@redhat.com, edumazet@google.com,
        linux-nfs@vger.kernel.org, dev@openvswitch.org,
        rds-devel@oss.oracle.com, lw@cn.fujitsu.com
Subject: Re: [PATCH v7 06/16] tracepoint: use new hashtable implementation
Message-ID: <20121029183157.GC3097@jtriplet-mobl1>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com>
 <1351450948-15618-6-git-send-email-levinsasha928@gmail.com>
 <20121029113515.GB9115@Krystal>
 <CA+1xoqce6uJ6wy3+2CBwsLHKnsz4wD0vt8MBEGKCFfXTvuC0Hg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CA+1xoqce6uJ6wy3+2CBwsLHKnsz4wD0vt8MBEGKCFfXTvuC0Hg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 29, 2012 at 01:29:24PM -0400, Sasha Levin wrote:
> On Mon, Oct 29, 2012 at 7:35 AM, Mathieu Desnoyers
> <mathieu.desnoyers@efficios.com> wrote:
> > * Sasha Levin (levinsasha928@gmail.com) wrote:
> >> Switch tracepoints to use the new hashtable implementation. This reduces the amount of
> >> generic unrelated code in the tracepoints.
> >>
> >> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>
> >> ---
> >>  kernel/tracepoint.c | 27 +++++++++++----------------
> >>  1 file changed, 11 insertions(+), 16 deletions(-)
> >>
> >> diff --git a/kernel/tracepoint.c b/kernel/tracepoint.c
> >> index d96ba22..854df92 100644
> >> --- a/kernel/tracepoint.c
> >> +++ b/kernel/tracepoint.c
> >> @@ -26,6 +26,7 @@
> >>  #include <linux/slab.h>
> >>  #include <linux/sched.h>
> >>  #include <linux/static_key.h>
> >> +#include <linux/hashtable.h>
> >>
> >>  extern struct tracepoint * const __start___tracepoints_ptrs[];
> >>  extern struct tracepoint * const __stop___tracepoints_ptrs[];
> >> @@ -49,8 +50,7 @@ static LIST_HEAD(tracepoint_module_list);
> >>   * Protected by tracepoints_mutex.
> >>   */
> >>  #define TRACEPOINT_HASH_BITS 6
> >> -#define TRACEPOINT_TABLE_SIZE (1 << TRACEPOINT_HASH_BITS)
> >> -static struct hlist_head tracepoint_table[TRACEPOINT_TABLE_SIZE];
> >> +static DEFINE_HASHTABLE(tracepoint_table, TRACEPOINT_HASH_BITS);
> >>
> > [...]
> >>
> >> @@ -722,6 +715,8 @@ struct notifier_block tracepoint_module_nb = {
> >>
> >>  static int init_tracepoints(void)
> >>  {
> >> +     hash_init(tracepoint_table);
> >> +
> >>       return register_module_notifier(&tracepoint_module_nb);
> >>  }
> >>  __initcall(init_tracepoints);
> >
> > So we have a hash table defined in .bss (therefore entirely initialized
> > to NULL), and you add a call to "hash_init", which iterates on the whole
> > array and initialize it to NULL (again) ?
> >
> > This extra initialization is redundant. I think it should be removed
> > from here, and hashtable.h should document that hash_init() don't need
> > to be called on zeroed memory (which includes static/global variables,
> > kzalloc'd memory, etc).
> 
> This was discussed in the previous series, the conclusion was to call
> hash_init() either way to keep the encapsulation and consistency.
> 
> It's cheap enough and happens only once, so why not?

Unnecessary work adds up.  Better not to do it unnecessarily, even if by
itself it doesn't cost that much.

It doesn't seem that difficult for future fields to have 0 as their
initialized state.

- Josh Triplett
