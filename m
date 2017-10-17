Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:42835 "EHLO relay.sw.ru"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753209AbdJQQrv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 17 Oct 2017 12:47:51 -0400
From: Vasily Averin <vvs@virtuozzo.com>
Subject: [RFC PATCH 1/2] race of lockd inetaddr notifiers with nlmsvc_rqst
 change
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Message-ID: <a1be8714-f72c-b087-b35c-885dfb2ecc6b@virtuozzo.com>
Date: Tue, 17 Oct 2017 19:47:47 +0300
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

lockd_inet[6]addr_event use nlmsvc_rqst without taken nlmsvc_mutex,
nlmsvc_rqst can be changed during execution of notifiers and crash the host.

Patch enables access to nlmsvc_rqst only when it was correctly initialized
and delays its cleanup until notifiers are in use.

NB: this patch depends on my patch "lockd: double unregister of inetaddr notifiers"
submitted separately.

Signed-off-by: Vasily Averin <vvs@virtuozzo.com>
---
 fs/lockd/svc.c | 16 ++++++++++++++--
 1 file changed, 14 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index f04ecfc..c1573860 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -57,6 +57,9 @@ static struct task_struct	*nlmsvc_task;
 static struct svc_rqst		*nlmsvc_rqst;
 unsigned long			nlmsvc_timeout;
 
+atomic_t nlm_ntf_refcnt = ATOMIC_INIT(0);
+DECLARE_WAIT_QUEUE_HEAD(nlm_ntf_wq);
+
 unsigned int lockd_net_id;
 
 /*
@@ -290,7 +293,8 @@ static int lockd_inetaddr_event(struct notifier_block *this,
 	struct in_ifaddr *ifa = (struct in_ifaddr *)ptr;
 	struct sockaddr_in sin;
 
-	if (event != NETDEV_DOWN)
+	if ((event != NETDEV_DOWN) ||
+	    !atomic_inc_not_zero(&nlm_ntf_refcnt))
 		goto out;
 
 	if (nlmsvc_rqst) {
@@ -301,6 +305,8 @@ static int lockd_inetaddr_event(struct notifier_block *this,
 		svc_age_temp_xprts_now(nlmsvc_rqst->rq_server,
 			(struct sockaddr *)&sin);
 	}
+	atomic_dec(&nlm_ntf_refcnt);
+	wake_up(&nlm_ntf_wq);
 
 out:
 	return NOTIFY_DONE;
@@ -317,7 +323,8 @@ static int lockd_inet6addr_event(struct notifier_block *this,
 	struct inet6_ifaddr *ifa = (struct inet6_ifaddr *)ptr;
 	struct sockaddr_in6 sin6;
 
-	if (event != NETDEV_DOWN)
+	if ((event != NETDEV_DOWN) ||
+	    !atomic_inc_not_zero(&nlm_ntf_refcnt))
 		goto out;
 
 	if (nlmsvc_rqst) {
@@ -329,6 +336,8 @@ static int lockd_inet6addr_event(struct notifier_block *this,
 		svc_age_temp_xprts_now(nlmsvc_rqst->rq_server,
 			(struct sockaddr *)&sin6);
 	}
+	atomic_dec(&nlm_ntf_refcnt);
+	wake_up(&nlm_ntf_wq);
 
 out:
 	return NOTIFY_DONE;
@@ -345,10 +354,12 @@ static void lockd_unregister_notifiers(void)
 #if IS_ENABLED(CONFIG_IPV6)
 	unregister_inet6addr_notifier(&lockd_inet6addr_notifier);
 #endif
+	wait_event(nlm_ntf_wq, atomic_read(&nlm_ntf_refcnt) == 0);
 }
 
 static void lockd_svc_exit_thread(void)
 {
+	atomic_dec(&nlm_ntf_refcnt);
 	lockd_unregister_notifiers();
 	svc_exit_thread(nlmsvc_rqst);
 }
@@ -373,6 +384,7 @@ static int lockd_start_svc(struct svc_serv *serv)
 		goto out_rqst;
 	}
 
+	atomic_inc(&nlm_ntf_refcnt);
 	svc_sock_update_bufs(serv);
 	serv->sv_maxconn = nlm_max_connections;
 
-- 
2.7.4

