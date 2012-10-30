Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.openrapids.net ([64.15.138.104]:59953 "EHLO
	blackscsi.openrapids.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754075Ab2J3TUb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Oct 2012 15:20:31 -0400
Date: Tue, 30 Oct 2012 15:20:28 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
To: Sasha Levin <levinsasha928@gmail.com>
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
Subject: Re: [PATCH v8 06/16] tracepoint: use new hashtable implementation
Message-ID: <20121030192028.GC9427@Krystal>
References: <1351622772-16400-1-git-send-email-levinsasha928@gmail.com> <1351622772-16400-6-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1351622772-16400-6-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Sasha Levin (levinsasha928@gmail.com) wrote:
> Switch tracepoints to use the new hashtable implementation. This reduces the
> amount of generic unrelated code in the tracepoints.
> 
> Signed-off-by: Sasha Levin <levinsasha928@gmail.com>

Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

> ---
>  kernel/tracepoint.c | 25 +++++++++----------------
>  1 file changed, 9 insertions(+), 16 deletions(-)
> 
> diff --git a/kernel/tracepoint.c b/kernel/tracepoint.c
> index d96ba22..5b599f1 100644
> --- a/kernel/tracepoint.c
> +++ b/kernel/tracepoint.c
> @@ -26,6 +26,7 @@
>  #include <linux/slab.h>
>  #include <linux/sched.h>
>  #include <linux/static_key.h>
> +#include <linux/hashtable.h>
>  
>  extern struct tracepoint * const __start___tracepoints_ptrs[];
>  extern struct tracepoint * const __stop___tracepoints_ptrs[];
> @@ -49,8 +50,7 @@ static LIST_HEAD(tracepoint_module_list);
>   * Protected by tracepoints_mutex.
>   */
>  #define TRACEPOINT_HASH_BITS 6
> -#define TRACEPOINT_TABLE_SIZE (1 << TRACEPOINT_HASH_BITS)
> -static struct hlist_head tracepoint_table[TRACEPOINT_TABLE_SIZE];
> +static DEFINE_HASHTABLE(tracepoint_table, TRACEPOINT_HASH_BITS);
>  
>  /*
>   * Note about RCU :
> @@ -191,16 +191,15 @@ tracepoint_entry_remove_probe(struct tracepoint_entry *entry,
>   */
>  static struct tracepoint_entry *get_tracepoint(const char *name)
>  {
> -	struct hlist_head *head;
>  	struct hlist_node *node;
>  	struct tracepoint_entry *e;
>  	u32 hash = jhash(name, strlen(name), 0);
>  
> -	head = &tracepoint_table[hash & (TRACEPOINT_TABLE_SIZE - 1)];
> -	hlist_for_each_entry(e, node, head, hlist) {
> +	hash_for_each_possible(tracepoint_table, e, node, hlist, hash) {
>  		if (!strcmp(name, e->name))
>  			return e;
>  	}
> +
>  	return NULL;
>  }
>  
> @@ -210,19 +209,13 @@ static struct tracepoint_entry *get_tracepoint(const char *name)
>   */
>  static struct tracepoint_entry *add_tracepoint(const char *name)
>  {
> -	struct hlist_head *head;
> -	struct hlist_node *node;
>  	struct tracepoint_entry *e;
>  	size_t name_len = strlen(name) + 1;
>  	u32 hash = jhash(name, name_len-1, 0);
>  
> -	head = &tracepoint_table[hash & (TRACEPOINT_TABLE_SIZE - 1)];
> -	hlist_for_each_entry(e, node, head, hlist) {
> -		if (!strcmp(name, e->name)) {
> -			printk(KERN_NOTICE
> -				"tracepoint %s busy\n", name);
> -			return ERR_PTR(-EEXIST);	/* Already there */
> -		}
> +	if (get_tracepoint(name)) {
> +		printk(KERN_NOTICE "tracepoint %s busy\n", name);
> +		return ERR_PTR(-EEXIST);	/* Already there */
>  	}
>  	/*
>  	 * Using kmalloc here to allocate a variable length element. Could
> @@ -234,7 +227,7 @@ static struct tracepoint_entry *add_tracepoint(const char *name)
>  	memcpy(&e->name[0], name, name_len);
>  	e->funcs = NULL;
>  	e->refcount = 0;
> -	hlist_add_head(&e->hlist, head);
> +	hash_add(tracepoint_table, &e->hlist, hash);
>  	return e;
>  }
>  
> @@ -244,7 +237,7 @@ static struct tracepoint_entry *add_tracepoint(const char *name)
>   */
>  static inline void remove_tracepoint(struct tracepoint_entry *e)
>  {
> -	hlist_del(&e->hlist);
> +	hash_del(&e->hlist);
>  	kfree(e);
>  }
>  
> -- 
> 1.7.12.4
> 

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
