Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.openrapids.net ([64.15.138.104]:58437 "EHLO
	blackscsi.openrapids.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751318Ab2J2Mq5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 08:46:57 -0400
Date: Mon, 29 Oct 2012 08:46:55 -0400
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
Subject: Re: [PATCH v7 10/16] dlm: use new hashtable implementation
Message-ID: <20121029124655.GD11733@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-10-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1351450948-15618-10-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Sasha Levin (levinsasha928@gmail.com) wrote:
[...]
> @@ -158,34 +159,21 @@ static int dlm_allow_conn;
>  static struct workqueue_struct *recv_workqueue;
>  static struct workqueue_struct *send_workqueue;
>  
> -static struct hlist_head connection_hash[CONN_HASH_SIZE];
> +static struct hlist_head connection_hash[CONN_HASH_BITS];
>  static DEFINE_MUTEX(connections_lock);
>  static struct kmem_cache *con_cache;
>  
>  static void process_recv_sockets(struct work_struct *work);
>  static void process_send_sockets(struct work_struct *work);
>  
> -
> -/* This is deliberately very simple because most clusters have simple
> -   sequential nodeids, so we should be able to go straight to a connection
> -   struct in the array */
> -static inline int nodeid_hash(int nodeid)
> -{
> -	return nodeid & (CONN_HASH_SIZE-1);
> -}

There is one thing I dislike about this change: you remove a useful
comment. It's good to be informed of the reason why a direct mapping
"value -> hash" without any dispersion function is preferred here.

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
