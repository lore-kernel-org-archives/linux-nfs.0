Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.openrapids.net ([64.15.138.104]:58475 "EHLO
	blackscsi.openrapids.net" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754539Ab2J2NEG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2012 09:04:06 -0400
Date: Mon, 29 Oct 2012 09:04:03 -0400
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
Subject: Re: [PATCH v7 11/16] net,l2tp: use new hashtable implementation
Message-ID: <20121029130403.GE11733@Krystal>
References: <1351450948-15618-1-git-send-email-levinsasha928@gmail.com> <1351450948-15618-11-git-send-email-levinsasha928@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1351450948-15618-11-git-send-email-levinsasha928@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

* Sasha Levin (levinsasha928@gmail.com) wrote:
[...]  
> -/* Session hash global list for L2TPv3.
> - * The session_id SHOULD be random according to RFC3931, but several
> - * L2TP implementations use incrementing session_ids.  So we do a real
> - * hash on the session_id, rather than a simple bitmask.
> - */
> -static inline struct hlist_head *
> -l2tp_session_id_hash_2(struct l2tp_net *pn, u32 session_id)
> -{
> -	return &pn->l2tp_session_hlist[hash_32(session_id, L2TP_HASH_BITS_2)];
> -
> -}

I understand that you removed this hash function, as well as
"l2tp_session_id_hash" below, but is there any way we could leave those
comments in place ? They look useful.

> -/* Session hash list.
> - * The session_id SHOULD be random according to RFC2661, but several
> - * L2TP implementations (Cisco and Microsoft) use incrementing
> - * session_ids.  So we do a real hash on the session_id, rather than a
> - * simple bitmask.

Ditto.

> - */
> -static inline struct hlist_head *
> -l2tp_session_id_hash(struct l2tp_tunnel *tunnel, u32 session_id)
> -{
> -	return &tunnel->session_hlist[hash_32(session_id, L2TP_HASH_BITS)];
> -}
> -
>  /* Lookup a session by id
>   */

Thanks,

Mathieu

-- 
Mathieu Desnoyers
Operating System Efficiency R&D Consultant
EfficiOS Inc.
http://www.efficios.com
