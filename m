From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH 3/5] can: af_can.c use rcu_barrier() on module unload.
Date: Mon, 08 Jun 2009 19:00:10 +0200
Message-ID: <4A2D439A.4020803@hartkopp.net>
References: <20090608130959.10052.54590.stgit@localhost> <20090608131138.10052.5408.stgit@localhost> <20090608161329.GD6961@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de, wg@grandegger.com,
	vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, netfilter-devel@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090608161329.GD6961@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Paul E. McKenney wrote:
> On Mon, Jun 08, 2009 at 03:11:38PM +0200, Jesper Dangaard Brouer wrote:
>> This module uses rcu_call() thus it should use rcu_barrier()
>> on module unload.
> 
> This does appear to make things better!!!
> 
> However, I don't understand why it is safe to do the following in
> can_exit():
> 
> 	hlist_for_each_entry_safe(d, n, next, &can_rx_dev_list, list) {
> 		hlist_del(&d->list);
> 		kfree(d);
> 	}
> 
> Given that this list is scanned by RCU readers, shouldn't this kfree()
> be something like "call_rcu(&d->rcu, can_rx_delete_device);"?
> 
> Also, what frees up the "struct receiver" structures?

Hi Paul,

af_can.c only provides an infrastructure for PF_CAN modules like can-raw.ko,
can-bcm.ko or can-isotp.ko.

Please take a look into can_notifier() in net/can/af_can.c and raw_notifier()
in net/can/raw.c:

The receivers are removed when the appropriate socket is closed that created
the belonging receivers. And you can not remove can.ko (af_can.c) when another
PF_CAN protocol like can-raw.ko is using it.

So when a netdev notifier removes the interface both the PF_CAN protocol (e.g.
can-raw.ko) and the PF_CAN core (af_can.c) cleans up all receivers and finally
removes the per-interface structure dev_rcv_lists (e.g. for can0).

In can_exit() all the dev_rcv_lists for ARPHRD_CAN interfaces are removed that
had been created by NETDEV_REGISTER notifier and are unused by any of the
PF_CAN protocols and therefore without any receivers attached to them.

The list is protected by spin_lock(&can_rcvlists_lock) - which is probably not
even needed in this particular case - and there is no PF_CAN protocol
registered at this time. So it's really save to remove the empty dev_rcv_lists
structs here that do not link to any receivers.

Puh - much text. But i hope it clarifies it.

Thinking about the rcu stuff again, rcu_barrier() still makes sense when you
are unloading the module chain of can-raw.ko and can.ko very fast.

Regards,
Oliver


>> Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
>> ---
>>
>>  net/can/af_can.c |    2 ++
>>  1 files changed, 2 insertions(+), 0 deletions(-)
>>
>> diff --git a/net/can/af_can.c b/net/can/af_can.c
>> index 10f0528..e733725 100644
>> --- a/net/can/af_can.c
>> +++ b/net/can/af_can.c
>> @@ -903,6 +903,8 @@ static __exit void can_exit(void)
>>  	}
>>  	spin_unlock(&can_rcvlists_lock);
>>
>> +	rcu_barrier(); /* Wait for completion of call_rcu()'s */
>> +
>>  	kmem_cache_destroy(rcv_cache);
>>  }
