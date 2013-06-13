Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:47304 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757337Ab3FMP2G (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jun 2013 11:28:06 -0400
Date: Thu, 13 Jun 2013 11:27:39 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: viro@zeniv.linux.org.uk, matthew@wil.cx, dhowells@redhat.com,
        sage@inktank.com, smfrench@gmail.com, swhiteho@redhat.com,
        Trond.Myklebust@netapp.com, akpm@linux-foundation.org,
        linux-kernel@vger.kernel.org, linux-afs@lists.infradead.org,
        ceph-devel@vger.kernel.org, linux-cifs@vger.kernel.org,
        samba-technical@lists.samba.org, cluster-devel@redhat.com,
        linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        piastryyy@gmail.com
Subject: Re: [PATCH v2 13/14] seq_file: add seq_list_*_percpu helpers
Message-ID: <20130613152739.GD20666@fieldses.org>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
 <1370948948-31784-14-git-send-email-jlayton@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1370948948-31784-14-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 11, 2013 at 07:09:07AM -0400, Jeff Layton wrote:
> When we convert the file_lock_list to a set of percpu lists, we'll need
> a way to iterate over them in order to output /proc/locks info. Add
> some seq_list_*_percpu helpers to handle that.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/seq_file.c            |   54 ++++++++++++++++++++++++++++++++++++++++++++++
>  include/linux/seq_file.h |    6 +++++
>  2 files changed, 60 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/seq_file.c b/fs/seq_file.c
> index 774c1eb..ce9f97a 100644
> --- a/fs/seq_file.c
> +++ b/fs/seq_file.c
> @@ -921,3 +921,57 @@ struct hlist_node *seq_hlist_next_rcu(void *v,
>  		return rcu_dereference(node->next);
>  }
>  EXPORT_SYMBOL(seq_hlist_next_rcu);
> +
> +/**
> + * seq_hlist_start_precpu - start an iteration of a hlist

Should be "of a percpu array of hlists"?

> + * @head: pointer to percpu array of struct hlist_heads
> + * @cpu:  pointer to cpu "cursor"
> + * @pos:  start position of sequence
> + *
> + * Called at seq_file->op->start().
> + */
> +struct hlist_node *
> +seq_hlist_start_percpu(struct hlist_head __percpu *head, int *cpu, loff_t pos)
> +{
> +	struct hlist_node *node;
> +
> +	for_each_possible_cpu(*cpu) {
> +		hlist_for_each(node, per_cpu_ptr(head, *cpu)) {
> +			if (pos-- == 0)
> +				return node;
> +		}
> +	}
> +	return NULL;
> +}
> +EXPORT_SYMBOL(seq_hlist_start_percpu);
> +
> +/**
> + * seq_hlist_next_percpu - move to the next position of the hlist

Ditto?

Just thinking if the doc scripts collected up a bunch of these summaries
into an index somewhere it'd be confusing for these to have some
description as seq_hlist_start/next.

Otherwise, ACK.

--b.

> + * @v:    pointer to current hlist_node
> + * @head: pointer to percpu array of struct hlist_heads
> + * @cpu:  pointer to cpu "cursor"
> + * @pos:  start position of sequence
> + *
> + * Called at seq_file->op->next().
> + */
> +struct hlist_node *
> +seq_hlist_next_percpu(void *v, struct hlist_head __percpu *head,
> +			int *cpu, loff_t *pos)
> +{
> +	struct hlist_node *node = v;
> +
> +	++*pos;
> +
> +	if (node->next)
> +		return node->next;
> +
> +	for (*cpu = cpumask_next(*cpu, cpu_possible_mask); *cpu < nr_cpu_ids;
> +	     *cpu = cpumask_next(*cpu, cpu_possible_mask)) {
> +		struct hlist_head *bucket = per_cpu_ptr(head, *cpu);
> +
> +		if (!hlist_empty(bucket))
> +			return bucket->first;
> +	}
> +	return NULL;
> +}
> +EXPORT_SYMBOL(seq_hlist_next_percpu);
> diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
> index 2da29ac..4e32edc 100644
> --- a/include/linux/seq_file.h
> +++ b/include/linux/seq_file.h
> @@ -173,4 +173,10 @@ extern struct hlist_node *seq_hlist_start_head_rcu(struct hlist_head *head,
>  extern struct hlist_node *seq_hlist_next_rcu(void *v,
>  						   struct hlist_head *head,
>  						   loff_t *ppos);
> +
> +/* Helpers for iterating over per-cpu hlist_head-s in seq_files */
> +extern struct hlist_node *seq_hlist_start_percpu(struct hlist_head __percpu *head, int *cpu, loff_t pos);
> +
> +extern struct hlist_node *seq_hlist_next_percpu(void *v, struct hlist_head __percpu *head, int *cpu, loff_t *pos);
> +
>  #endif
> -- 
> 1.7.1
> 
