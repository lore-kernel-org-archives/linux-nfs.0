From: NeilBrown <neilb@suse.de>
Subject: [PATCH] knfsd: Fix race that can disable NFS server.
Date: Fri, 20 Oct 2006 11:52:44 +1000
Message-ID: <1061020015244.26756@suse.de>
References: <20061020114959.26698.patches@notabene>
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946782AbWJTBw6@vger.kernel.org>
To: Andrew Morton <akpm@osdl.org>
Cc: stable@kernel.org, Adrian Bunk <bunk@stusta.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

This patch is suitable for just about any 2.6 kernel.
It should go in 2.6.19 and 2.6.18.2 and possible even the .17 and .16
stable series.

### Comments for Changeset

This is a long standing bug that seems to have only recently become
apparent, presumably due to increasing use of NFS over TCP - many
distros seem to be making it the default.

The SK_CONN bit gets set when a listening socket may be ready
for an accept, just as SK_DATA is set when data may be available.

It is entirely possible for svc_tcp_accept to be called with neither
of these set.  It doesn't happen often but there is a small race in
svc_sock_enqueue as SK_CONN and SK_DATA are tested outside the
spin_lock.  They could be cleared immediately after the test and
before the lock is gained.

This normally shouldn't be a problem.  The sockets are non-blocking so
trying to read() or accept() when ther is nothing to do is not a problem.

However: svc_tcp_recvfrom makes the decision "Should I accept() or
should I read()" based on whether SK_CONN is set or not.  This usually
works but is not safe.  The decision should be based on whether it is
a TCP_LISTEN socket or a TCP_CONNECTED socket.


Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/svcsock.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff .prev/net/sunrpc/svcsock.c ./net/sunrpc/svcsock.c
--- .prev/net/sunrpc/svcsock.c	2006-10-20 11:49:18.000000000 +1000
+++ ./net/sunrpc/svcsock.c	2006-10-20 11:49:47.000000000 +1000
@@ -1002,7 +1002,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		return 0;
 	}
 
-	if (test_bit(SK_CONN, &svsk->sk_flags)) {
+	if (svsk->sk_sk->sk_state == TCP_LISTEN) {
 		svc_tcp_accept(svsk);
 		svc_sock_received(svsk);
 		return 0;
