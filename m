From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 5/5] sunrpc/auth_gss: Call rcu_barrier() on module unload.
Date: Mon, 08 Jun 2009 15:11:48 +0200
Message-ID: <20090608131148.10052.39869.stgit@localhost>
References: <20090608130959.10052.54590.stgit@localhost>
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
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <20090608130959.10052.54590.stgit@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As the module uses rcu_call() we should make sure that all
rcu callback has been completed before removing the code.

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 net/sunrpc/auth_gss/auth_gss.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index e630b38..66d458f 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -1548,6 +1548,7 @@ static void __exit exit_rpcsec_gss(void)
 {
 	gss_svc_shutdown();
 	rpcauth_unregister(&authgss_ops);
+	rcu_barrier(); /* Wait for completion of call_rcu()'s */
 }
 
 MODULE_LICENSE("GPL");

