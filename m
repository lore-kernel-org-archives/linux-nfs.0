From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [GIT] Please pull nfs client bugfixes
Date: Tue, 28 Oct 2008 15:26:10 -0400
Message-ID: <1225221970.16914.1.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:46500 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753136AbYJ1T0n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Oct 2008 15:26:43 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Linus,

Please pull from the "bugfixes" branch of the repository at

   git pull git://git.linux-nfs.org/projects/trondmy/nfs-2.6.git bugfixes

This will update the following files through the appended changesets.

  Cheers,
    Trond

----
 fs/nfs/inode.c        |   11 ++------
 net/sunrpc/auth.c     |   18 ++++++++------
 net/sunrpc/xprtsock.c |   58 ++++++++++++++++++++++++++++++++++++++++--------
 3 files changed, 61 insertions(+), 26 deletions(-)

commit 5f707eb429e2c98dfd564ffbbd9f536bf493d869
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 28 15:21:42 2008 -0400

    SUNRPC: Fix potential race in put_rpccred()
    
    We have to be careful when we try to unhash the credential in
    put_rpccred(), because we're not holding the credcache lock, so the call to
    rpcauth_unhash_cred() may fail if someone else has looked the cred up, and
    obtained a reference to it.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit eac0d18d44705f8a1b72cccec3a453e1a43eb20a
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 28 15:21:41 2008 -0400

    SUNRPC: Fix rpcauth_prune_expired
    
    We need to make sure that we don't remove creds from the cred_unused list
    if they are still under the moratorium, or else they will never get
    garbage collected.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit ae05f269400533cbb32bfba131ab528d78dffd16
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 28 15:21:40 2008 -0400

    NFS: Convert nfs_attr_generation_counter into an atomic_long
    
    The most important property we need from nfs_attr_generation_counter is
    monotonicity, which is not guaranteed by the current system of smp memory
    barriers. We should convert it to an atomic_long_t, and drop the memory
    barriers.
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

commit 2a9e1cfa23fb62da37739af81127dab5af095d99
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Tue Oct 28 15:21:39 2008 -0400

    SUNRPC: Respond promptly to server TCP resets
    
    If the server sends us an RST error while we're in the TCP_ESTABLISHED
    state, then that will not result in a state change, and so the RPC client
    ends up hanging forever (see
    http://bugzilla.kernel.org/show_bug.cgi?id=11154)
    
    We can intercept the reset by setting up an sk->sk_error_report callback,
    which will then allow us to initiate a proper shutdown and retry...
    
    We also make sure that if the send request receives an ECONNRESET, then we
    shutdown too...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index dc52793..d22eb38 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -908,21 +908,16 @@ static int nfs_size_need_update(const struct inode *inode, const struct nfs_fatt
 	return nfs_size_to_loff_t(fattr->size) > i_size_read(inode);
 }
 
-static unsigned long nfs_attr_generation_counter;
+static atomic_long_t nfs_attr_generation_counter;
 
 static unsigned long nfs_read_attr_generation_counter(void)
 {
-	smp_rmb();
-	return nfs_attr_generation_counter;
+	return atomic_long_read(&nfs_attr_generation_counter);
 }
 
 unsigned long nfs_inc_attr_generation_counter(void)
 {
-	unsigned long ret;
-	smp_rmb();
-	ret = ++nfs_attr_generation_counter;
-	smp_wmb();
-	return ret;
+	return atomic_long_inc_return(&nfs_attr_generation_counter);
 }
 
 void nfs_fattr_init(struct nfs_fattr *fattr)
diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 436bf1b..cb216b2 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -228,19 +228,21 @@ static int
 rpcauth_prune_expired(struct list_head *free, int nr_to_scan)
 {
 	spinlock_t *cache_lock;
-	struct rpc_cred *cred;
+	struct rpc_cred *cred, *next;
 	unsigned long expired = jiffies - RPC_AUTH_EXPIRY_MORATORIUM;
 
-	while (!list_empty(&cred_unused)) {
-		cred = list_entry(cred_unused.next, struct rpc_cred, cr_lru);
+	list_for_each_entry_safe(cred, next, &cred_unused, cr_lru) {
+
+		/* Enforce a 60 second garbage collection moratorium */
+		if (time_in_range(cred->cr_expire, expired, jiffies) &&
+		    test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0)
+			continue;
+
 		list_del_init(&cred->cr_lru);
 		number_cred_unused--;
 		if (atomic_read(&cred->cr_count) != 0)
 			continue;
-		/* Enforce a 5 second garbage collection moratorium */
-		if (time_in_range(cred->cr_expire, expired, jiffies) &&
-		    test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) != 0)
-			continue;
+
 		cache_lock = &cred->cr_auth->au_credcache->lock;
 		spin_lock(cache_lock);
 		if (atomic_read(&cred->cr_count) == 0) {
@@ -453,7 +455,7 @@ need_lock:
 	}
 	if (test_bit(RPCAUTH_CRED_UPTODATE, &cred->cr_flags) == 0)
 		rpcauth_unhash_cred(cred);
-	else if (test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0) {
+	if (test_bit(RPCAUTH_CRED_HASHED, &cred->cr_flags) != 0) {
 		cred->cr_expire = jiffies;
 		list_add_tail(&cred->cr_lru, &cred_unused);
 		number_cred_unused++;
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 9a288d5..0a50361 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -249,6 +249,7 @@ struct sock_xprt {
 	void			(*old_data_ready)(struct sock *, int);
 	void			(*old_state_change)(struct sock *);
 	void			(*old_write_space)(struct sock *);
+	void			(*old_error_report)(struct sock *);
 };
 
 /*
@@ -698,8 +699,9 @@ static int xs_tcp_send_request(struct rpc_task *task)
 	case -EAGAIN:
 		xs_nospace(task);
 		break;
-	case -ECONNREFUSED:
 	case -ECONNRESET:
+		xs_tcp_shutdown(xprt);
+	case -ECONNREFUSED:
 	case -ENOTCONN:
 	case -EPIPE:
 		status = -ENOTCONN;
@@ -742,6 +744,22 @@ out_release:
 	xprt_release_xprt(xprt, task);
 }
 
+static void xs_save_old_callbacks(struct sock_xprt *transport, struct sock *sk)
+{
+	transport->old_data_ready = sk->sk_data_ready;
+	transport->old_state_change = sk->sk_state_change;
+	transport->old_write_space = sk->sk_write_space;
+	transport->old_error_report = sk->sk_error_report;
+}
+
+static void xs_restore_old_callbacks(struct sock_xprt *transport, struct sock *sk)
+{
+	sk->sk_data_ready = transport->old_data_ready;
+	sk->sk_state_change = transport->old_state_change;
+	sk->sk_write_space = transport->old_write_space;
+	sk->sk_error_report = transport->old_error_report;
+}
+
 /**
  * xs_close - close a socket
  * @xprt: transport
@@ -765,9 +783,8 @@ static void xs_close(struct rpc_xprt *xprt)
 	transport->sock = NULL;
 
 	sk->sk_user_data = NULL;
-	sk->sk_data_ready = transport->old_data_ready;
-	sk->sk_state_change = transport->old_state_change;
-	sk->sk_write_space = transport->old_write_space;
+
+	xs_restore_old_callbacks(transport, sk);
 	write_unlock_bh(&sk->sk_callback_lock);
 
 	sk->sk_no_check = 0;
@@ -1180,6 +1197,28 @@ static void xs_tcp_state_change(struct sock *sk)
 }
 
 /**
+ * xs_tcp_error_report - callback mainly for catching RST events
+ * @sk: socket
+ */
+static void xs_tcp_error_report(struct sock *sk)
+{
+	struct rpc_xprt *xprt;
+
+	read_lock(&sk->sk_callback_lock);
+	if (sk->sk_err != ECONNRESET || sk->sk_state != TCP_ESTABLISHED)
+		goto out;
+	if (!(xprt = xprt_from_sock(sk)))
+		goto out;
+	dprintk("RPC:       %s client %p...\n"
+			"RPC:       error %d\n",
+			__func__, xprt, sk->sk_err);
+
+	xprt_force_disconnect(xprt);
+out:
+	read_unlock(&sk->sk_callback_lock);
+}
+
+/**
  * xs_udp_write_space - callback invoked when socket buffer space
  *                             becomes available
  * @sk: socket whose state has changed
@@ -1454,10 +1493,9 @@ static void xs_udp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 
 		write_lock_bh(&sk->sk_callback_lock);
 
+		xs_save_old_callbacks(transport, sk);
+
 		sk->sk_user_data = xprt;
-		transport->old_data_ready = sk->sk_data_ready;
-		transport->old_state_change = sk->sk_state_change;
-		transport->old_write_space = sk->sk_write_space;
 		sk->sk_data_ready = xs_udp_data_ready;
 		sk->sk_write_space = xs_udp_write_space;
 		sk->sk_no_check = UDP_CSUM_NORCV;
@@ -1589,13 +1627,13 @@ static int xs_tcp_finish_connecting(struct rpc_xprt *xprt, struct socket *sock)
 
 		write_lock_bh(&sk->sk_callback_lock);
 
+		xs_save_old_callbacks(transport, sk);
+
 		sk->sk_user_data = xprt;
-		transport->old_data_ready = sk->sk_data_ready;
-		transport->old_state_change = sk->sk_state_change;
-		transport->old_write_space = sk->sk_write_space;
 		sk->sk_data_ready = xs_tcp_data_ready;
 		sk->sk_state_change = xs_tcp_state_change;
 		sk->sk_write_space = xs_tcp_write_space;
+		sk->sk_error_report = xs_tcp_error_report;
 		sk->sk_allocation = GFP_ATOMIC;
 
 		/* socket options */

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
