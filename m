From: Greg Banks <gnb@melbourne.sgi.com>
Subject: Re: [PATCH 0/3] [RFC] knfsd: convert to kthread API
	and	remove	signaling for shutdown
Date: Tue, 20 May 2008 13:36:26 -0700
Message-ID: <4833364A.4010803@melbourne.sgi.com>
References: <1211078114-18384-1-git-send-email-jlayton@redhat.com>	<18481.6416.571430.593722@notabene.brown>
	<4831F860.6050801@melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------030403010306070308020604"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <4831F860.6050801@melbourne.sgi.com>
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

This is a multi-part message in MIME format.
--------------030403010306070308020604
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Greg Banks wrote:
> [...]
> I'll send out the patch I mentioned when we
> chatted at Cthon, maybe you can consider the issue it fixes.
>
>   
Here's the patch.  You probably don't want to do it the same way, but
the intent is to delay the allocation of the svc_rqst structure until
the nfsd is running on the correct cpu so that the allocation comes from
the correct local memory on NUMA systems.  Absent the patch, most of the
nfsds spend a lot of time updating remote memory allocated on node0.

-- 
Greg Banks, P.Engineer, SGI Australian Software Group.
The cake is *not* a lie.
I don't speak for SGI.


--------------030403010306070308020604
Content-Type: text/plain;
 name="knfsd-allocate-svc-rqst-and-pages-on-correct-nodes-4"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename*0="knfsd-allocate-svc-rqst-and-pages-on-correct-nodes-4"

When allocating the per-thread NFS server data structures, ensure
the allocation proceeds on the NUMA node where the thread will then
spend all of its life.  This reduces the amount of cross-node traffic
needed to run NFS at high traffic rates on large NUMA machines.

Signed-off-by: Greg Banks <gnb@melbourne.sgi.com>
---

 net/sunrpc/svc.c |   94 ++++++++++++++++++++++++++++++++------------
 1 file changed, 70 insertions(+), 24 deletions(-)

Index: linux-2.6.16/net/sunrpc/svc.c
===================================================================
--- linux-2.6.16.orig/net/sunrpc/svc.c
+++ linux-2.6.16/net/sunrpc/svc.c
@@ -538,30 +538,43 @@ svc_release_buffer(struct svc_rqst *rqst
 	rqstp->rq_argused = 0;
 }
 
+struct svc_create_thread_rec
+{
+	svc_thread_fn func;
+	struct svc_serv *serv;
+	struct svc_pool *pool;
+	struct completion comp;
+};
+
 /*
- * Create a thread in the given pool.  Caller must hold BKL.
- * On a NUMA or SMP machine, with a multi-pool serv, the thread
- * will be restricted to run on the cpus belonging to the pool.
+ * Trampoline function called as the thread function for new nfsd threads.
+ * Performs all the per-thread initialisation in the thread's own context,
+ * so that the thread's memory policy and cpus_allowed mask govern the
+ * allocation of the per-thread structures and the buffer pages used
+ * to do network and disk IO.  For large NUMA machines with a lot of
+ * network and disk bandwidth, getting this page placement right can
+ * double system throughput.
  */
-static int
-__svc_create_thread(svc_thread_fn func, struct svc_serv *serv, struct svc_pool *pool)
+static int __svc_create_thread_tramp(void *data)
 {
+	struct svc_create_thread_rec *rec = data;
+	struct svc_serv *serv = rec->serv;
+	struct svc_pool *pool = rec->pool;
+	int error = -ENOMEM;
 	struct svc_rqst	*rqstp;
-	int		error = -ENOMEM;
-	int		have_oldmask = 0;
-	cpumask_t	oldmask;
 
-	rqstp = kmalloc(sizeof(*rqstp), GFP_KERNEL);
+	rqstp = kzalloc(sizeof(*rqstp), GFP_KERNEL);
 	if (!rqstp)
 		goto out;
 
-	memset(rqstp, 0, sizeof(*rqstp));
 	init_waitqueue_head(&rqstp->rq_wait);
 
-	if (!(rqstp->rq_argp = kmalloc(serv->sv_xdrsize, GFP_KERNEL))
-	 || !(rqstp->rq_resp = kmalloc(serv->sv_xdrsize, GFP_KERNEL))
-	 || !svc_init_buffer(rqstp, serv->sv_bufsz))
-		goto out_thread;
+	if (!(rqstp->rq_argp = kmalloc(serv->sv_xdrsize, GFP_KERNEL)))
+		goto out_argp;
+	if (!(rqstp->rq_resp = kmalloc(serv->sv_xdrsize, GFP_KERNEL)))
+		goto out_resp;
+	if (!svc_init_buffer(rqstp, serv->sv_bufsz))
+		goto out_buffer;
 
 	serv->sv_nrthreads++;
 	pool->sp_nrthreads++;
@@ -571,24 +584,57 @@ __svc_create_thread(svc_thread_fn func, 
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
 
+	svc_sock_update_bufs(serv);
+
+	complete(&rec->comp);
+
+	rec->func(rqstp);
+	return 0;
+
+out_buffer:
+	svc_release_buffer(rqstp);
+	kfree(rqstp->rq_resp);
+out_resp:
+	kfree(rqstp->rq_argp);
+out_argp:
+	kfree(rqstp);
+out:
+	complete(&rec->comp);
+	return error;
+}
+
+/*
+ * Create a thread in the given pool.  Caller must hold BKL.
+ * On a NUMA or SMP machine, with a multi-pool serv, the thread
+ * will be restricted to run on the cpus belonging to the pool.
+ */
+static int
+__svc_create_thread(svc_thread_fn func, struct svc_serv *serv, struct svc_pool *pool)
+{
+	int		error = -ENOMEM;
+	int		have_oldmask = 0;
+	cpumask_t	oldmask;
+	struct svc_create_thread_rec rec = {
+				.func = func,
+				.serv = serv,
+				.pool = pool
+			};
+	init_completion(&rec.comp);
+
 	if (serv->sv_nrpools > 1)
 		have_oldmask = svc_pool_map_set_cpumask(pool->sp_id, &oldmask);
 
-	error = kernel_thread((int (*)(void *)) func, rqstp, 0);
+	error = kernel_thread(__svc_create_thread_tramp, &rec, 0);
+	if (error > 0)
+		error = 0;
 
 	if (have_oldmask)
 		set_cpus_allowed(current, oldmask);
 
-	if (error < 0)
-		goto out_thread;
-	svc_sock_update_bufs(serv);
-	error = 0;
-out:
-	return error;
+	/* wait for the child thread to finish initialising */
+	wait_for_completion(&rec.comp);
 
-out_thread:
-	svc_exit_thread(rqstp);
-	goto out;
+	return error;
 }
 
 /*

--------------030403010306070308020604
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
--------------030403010306070308020604--
