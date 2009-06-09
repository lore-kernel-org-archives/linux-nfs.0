From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH 4/5] sctp: protocol.c call rcu_barrier() on unload.
Date: Tue, 09 Jun 2009 12:26:25 -0400
Message-ID: <4A2E8D31.1030307@hp.com>
References: <20090608130959.10052.54590.stgit@localhost> <20090608131143.10052.96470.stgit@localhost> <20090608162227.GE6961@linux.vnet.ibm.com> <4A2E8357.80509@hp.com> <20090609155011.GD6789@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, urs.thuermann-l29pVbxQd1IUtdQbppsyvg@public.gmane.org,
	oliver.hartkopp-l29pVbxQd1IUtdQbppsyvg@public.gmane.org, wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, netfilter-devel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:3818 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753338AbZFIQ0Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2009 12:26:25 -0400
In-Reply-To: <20090609155011.GD6789@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney wrote:
> On Tue, Jun 09, 2009 at 11:44:23AM -0400, Vlad Yasevich wrote:
>> Paul E. McKenney wrote:
>>> On Mon, Jun 08, 2009 at 03:11:43PM +0200, Jesper Dangaard Brouer wrote:
>>>> On module unload call rcu_barrier(), this is needed as synchronize_rcu()
>>>> is not strong enough.  The kmem_cache_destroy() does invoke
>>>> synchronize_rcu() but it does not provide same protection.
>>> Good, looks like sctp_v4_del_protocol() invokes call_rcu(), which the
>>> rcu_barrier() would then wait for.  And it looks like sctp_v6_del_protocol()
>>> does the same for IPv6.
>>>
>>> Reviewed_by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
>>>
>>>> Signed-off-by: Jesper Dangaard Brouer <hawk-4UpuNZONu4c@public.gmane.org>
>>>> ---
>>>>
>>>>  net/sctp/protocol.c |    2 ++
>>>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>>>
>>>> diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
>>>> index cb2c50d..79cbd47 100644
>>>> --- a/net/sctp/protocol.c
>>>> +++ b/net/sctp/protocol.c
>>>> @@ -1370,6 +1370,8 @@ SCTP_STATIC __exit void sctp_exit(void)
>>>>  	sctp_proc_exit();
>>>>  	cleanup_sctp_mibs();
>>>>
>>>> +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
>>>> +
>>>>  	kmem_cache_destroy(sctp_chunk_cachep);
>>>>  	kmem_cache_destroy(sctp_bucket_cachep);
>>>>  }
>> Shouldn't the rcu_barrier call be before sctp_free_local_addr_list()?
> 
> Hmmm...  What sequence of events would lead to a failure if
> rcu_barrier() is after sctp_free_local_addr_list()?
> 
> 							Thanx, Paul
> 

I thought that the notifier could could potentially execute at the
same time as the unregister(), but I see that's protected.  So, I guess
it doesn't really matter then where the barrier is.

Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

-vlad
