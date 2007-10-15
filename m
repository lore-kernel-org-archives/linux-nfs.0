From: Neil Brown <neilb@suse.de>
Subject: Re: [NFS] nfsd closes port 2049
Date: Tue, 16 Oct 2007 06:24:27 +1000
Message-ID: <18195.52347.544844.155538@notabene.brown>
References: <47139C02.9020009@cineca.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: LKML <linux-kernel@vger.kernel.org>, nfs@lists.sourceforge.net
To: righiandr@users.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S934784AbXJOUZO@vger.kernel.org>
In-Reply-To: message from Andrea Righi on Monday October 15
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Monday October 15, a.righi@cineca.it wrote:
> Hi all,
> 
> I'm trying to debug a weird problem with nfsd on a 2.6.16.27-0.6-smp
> kernel.
> 
> 1 server: SuSE SLES 10 x86_64, config attached
> 256 clients: RHEL4 Update 4 2.6.9-42.ELsmp x86_64
> 
> Using nfs v3.
> 
> The clients have been happily talking to the server for several days
> without incident.
> 
> The weird thing is that at a certain point the socket opened on port
> 2049 on the NFS server is being closed for unknown reasons (or better
> for unknown reasons for me!).

This is fixed in any release based on 2.6.16.31 or later.
The relevant mainline patch is 
    1a047060a99f274a7c52cfea8159e4142a14b8a7
as below.
So update your kernel package.

NeilBrown


commit 1a047060a99f274a7c52cfea8159e4142a14b8a7
Author: NeilBrown <neilb@suse.de>
Date:   Thu Oct 19 23:29:13 2006 -0700

    [PATCH] knfsd: fix race that can disable NFS server
    
    This patch is suitable for just about any 2.6 kernel.  It should go in
    2.6.19 and 2.6.18.2 and possible even the .17 and .16 stable series.
    
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
    Cc: Adrian Bunk <bunk@stusta.de>
    Cc: <stable@kernel.org>
    Cc: Trond Myklebust <trond.myklebust@fys.uio.no>
    Signed-off-by: Andrew Morton <akpm@osdl.org>
    Signed-off-by: Linus Torvalds <torvalds@osdl.org>

diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 61e307c..96521f1 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -973,7 +973,7 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		return 0;
 	}
 
-	if (test_bit(SK_CONN, &svsk->sk_flags)) {
+	if (svsk->sk_sk->sk_state == TCP_LISTEN) {
 		svc_tcp_accept(svsk);
 		svc_sock_received(svsk);
 		return 0;
