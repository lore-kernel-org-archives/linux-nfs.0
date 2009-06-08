From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 0/5] We must use rcu_barrier() on module unload
Date: Mon, 08 Jun 2009 15:11:23 +0200
Message-ID: <20090608130959.10052.54590.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: Jesper Dangaard Brouer <hawk@comx.dk>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	urs.thuermann@volkswagen.de, oliver.hartkopp@volkswagen.de,
	wg@grandegger.com, vladislav.yasevich@hp.com, sri@us.ibm.com,
	linux-sctp@vger.kernel.org, Trond.Myklebust@netapp.com,
	linux-nfs@vger.kernel.org, netfilter-devel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If an unloadable module uses RCU callbacks, it need to use
rcu_barrier() so that the module may be safely unloaded.

While hacking on a netfilter module of my own, I learned the
importance of calling rcu_barrier() instead of only a
synchronize_rcu() on module unload (iif using any call_rcu()
callbacks).  synchronize_rcu() does wait for a grace period to
elapse, but it does not wait for the callbacks to complete.

For documentation see:
 http://lwn.net/Articles/217484/
 Documentation/RCU/rcubarrier.txt


Looking through the net/ directory for call_rcu() users and unloadable
modules I found 5 modules that didn't behave correctly:

 net/8021q/vlan.c

 net/can/af_can.c

 net/netfilter/nfnetlink_queue.c

 net/sctp/protocol.c

 net/sunrpc/auth_gss/auth_gss.c

I have made a patch for each individual module, so objections can be
made on a per module basis.  I have Cc'ed all of the patches to the
maintainers of each module (according to the MAINTAINERS file).

The patchset is made on top of DaveM's net-next-2.6 tree (starting on
top of commit a1c1db392090). As this is my usual development tree,
even though this patchset is bugfixes. (Just tested it applied cleanly
on Linus'es tree ...)

---
Jesper Dangaard Brouer (5):
      sunrpc/auth_gss: Call rcu_barrier() on module unload.
      sctp: protocol.c call rcu_barrier() on unload.
      can: af_can.c use rcu_barrier() on module unload.
      nfnetlink_queue: Use rcu_barrier() on module unload.
      8021q: Vlan driver should use rcu_barrier() on unload instead of syncronize_net()


 net/8021q/vlan.c                |    2 +-
 net/can/af_can.c                |    2 ++
 net/netfilter/nfnetlink_queue.c |    4 +++-
 net/sctp/protocol.c             |    2 ++
 net/sunrpc/auth_gss/auth_gss.c  |    1 +
 5 files changed, 9 insertions(+), 2 deletions(-)

--
Best regards,
  Jesper Brouer
  ComX Networks A/S
  Linux Network developer
  Cand. Scient Datalog / MSc.
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

