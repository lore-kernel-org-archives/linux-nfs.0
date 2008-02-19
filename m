From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: flush signals before taking down callback thread
Date: Tue, 19 Feb 2008 12:51:35 -0500
Message-ID: <1203443495-7854-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the reference counting on the callback thread is working as
expected, it uncovers another problem.  Peter Staubach noticed while
testing that patch on an older kernel that he would occasionally see
this printk in rpc_register fire:

    "RPC: failed to contact portmap (errno -512).

The NFSv4 callback thread is signaled by nfs_callback_down(), but never
flushes that signal. All of the shutdown processing is done with that
signal pending. This makes it fail the call to unregister the port with
the portmapper.

In actuality, this rpc_register call isn't necessary at all since the
port isn't actually registered with the portmapper anymore. Regardless,
there doesn't seem to be any reason to leave the signal pending while
the thread is being shut down and flushing it should generally silence
that printk.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/callback.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index ecc06c6..0d784f6 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -93,6 +93,7 @@ static void nfs_callback_svc(struct svc_rqst *rqstp)
 		svc_process(rqstp);
 	}
 
+	flush_signals(current);
 	svc_exit_thread(rqstp);
 	nfs_callback_info.pid = 0;
 	complete(&nfs_callback_info.stopped);
-- 
1.5.3.8
