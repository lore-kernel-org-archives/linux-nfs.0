From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/7] SUNRPC: Allow svc_pool_map_set_cpumask to work with any task
Date: Tue, 18 Dec 2007 15:19:36 -0500
Message-ID: <1198009182-27895-2-git-send-email-jlayton@redhat.com>
References: <1198009182-27895-1-git-send-email-jlayton@redhat.com>
Cc: linux-kernel@vger.kernel.org, nfsv4@linux-nfs.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37241 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751714AbXLRUTo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 Dec 2007 15:19:44 -0500
In-Reply-To: <1198009182-27895-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

svc_pool_map_set_cpumask will only affect "current" as of now. Add a
new arg so that it can change the cpumask on any given task. Also if
we're not changing "current" we don't care what the oldmask was, so
allow it to be a NULL pointer.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 net/sunrpc/svc.c |   16 ++++++++++------
 1 files changed, 10 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index a4a6bf7..9696ae7 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -297,7 +297,8 @@ svc_pool_map_put(void)
  * Returns 1 and fills in oldmask iff a cpumask was applied.
  */
 static inline int
-svc_pool_map_set_cpumask(unsigned int pidx, cpumask_t *oldmask)
+svc_pool_map_set_cpumask(struct task_struct *task, unsigned int pidx,
+			 cpumask_t *oldmask)
 {
 	struct svc_pool_map *m = &svc_pool_map;
 	unsigned int node; /* or cpu */
@@ -314,13 +315,15 @@ svc_pool_map_set_cpumask(unsigned int pidx, cpumask_t *oldmask)
 		return 0;
 	case SVC_POOL_PERCPU:
 		node = m->pool_to[pidx];
-		*oldmask = current->cpus_allowed;
-		set_cpus_allowed(current, cpumask_of_cpu(node));
+		if (oldmask != NULL)
+			*oldmask = task->cpus_allowed;
+		set_cpus_allowed(task, cpumask_of_cpu(node));
 		return 1;
 	case SVC_POOL_PERNODE:
 		node = m->pool_to[pidx];
-		*oldmask = current->cpus_allowed;
-		set_cpus_allowed(current, node_to_cpumask(node));
+		if (oldmask != NULL)
+			*oldmask = task->cpus_allowed;
+		set_cpus_allowed(task, node_to_cpumask(node));
 		return 1;
 	}
 }
@@ -569,7 +572,8 @@ __svc_create_thread(svc_thread_fn func, struct svc_serv *serv,
 	rqstp->rq_pool = pool;
 
 	if (serv->sv_nrpools > 1)
-		have_oldmask = svc_pool_map_set_cpumask(pool->sp_id, &oldmask);
+		have_oldmask = svc_pool_map_set_cpumask(current, pool->sp_id,
+							&oldmask);
 
 	error = kernel_thread((int (*)(void *)) func, rqstp, 0);
 
-- 
1.5.3.3

