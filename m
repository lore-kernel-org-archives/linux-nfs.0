Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.openrapids.net ([64.15.138.104]:58361 "EHLO
	blackscsi.openrapids.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757311Ab2J2MUz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 08:20:55 -0400
Date: Mon, 29 Oct 2012 08:20:52 -0400
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
Subject: Re: [PATCH v7 08/16] block,elevator: use new hashtable
	implementation
Message-ID: <20121029122052.GB11733@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-8-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1351450948-15618-8-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Sasha Levin (levinsasha928@gmail.com) wrote:
[...]
> @@ -96,6 +97,8 @@ struct elevator_type
>  	struct list_head list;
>  };
>  
> +#define ELV_HASH_BITS 6
> +
>  /*
>   * each queue has an elevator_queue associated with it
>   */
> @@ -105,7 +108,7 @@ struct elevator_queue
>  	void *elevator_data;
>  	struct kobject kobj;
>  	struct mutex sysfs_lock;
> -	struct hlist_head *hash;
> +	DECLARE_HASHTABLE(hash, ELV_HASH_BITS);
>  	unsigned int registered:1;

Hrm, so this is moving "registered" out of the elevator_queue first
cache-line by turning the pointer into a 256 or 512 bytes hash table.

Maybe we should consider moving "registered" before the "hash" field ?

Thanks,

Mathieu

>  };
>  
> -- 
> 1.7.12.4
> 

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
