Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:50360 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752161AbcF3PJf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Jun 2016 11:09:35 -0400
Date: Thu, 30 Jun 2016 11:09:21 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Scott Mayhew <smayhew@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] lockd: unregister notifier blocks if the service fails
 to come up completely
Message-ID: <20160630150921.GA2954@fieldses.org>
References: <1467297572-27945-1-git-send-email-smayhew@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1467297572-27945-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 30, 2016 at 10:39:32AM -0400, Scott Mayhew wrote:
> If the lockd service fails to start up then we need to be sure that the
> notifier blocks are not registered, otherwise a subsequent start of the
> service could cause the same notifier to be registered twice, leading to
> soft lockups.

Good catch, thanks!

I think the following (untested) should do the same job slightly more
concisely?

--b.

commit d2f017465698
Author: Scott Mayhew <smayhew@redhat.com>
Date:   Thu Jun 30 10:39:32 2016 -0400

    lockd: unregister notifier blocks if the service fails to come up completely
    
    If the lockd service fails to start up then we need to be sure that the
    notifier blocks are not registered, otherwise a subsequent start of the
    service could cause the same notifier to be registered twice, leading to
    soft lockups.
    
    Signed-off-by: Scott Mayhew <smayhew@redhat.com>
    Cc: stable@vger.kernel.org
    Fixes: 0751ddf77b6a "lockd: Register callbacks on the inetaddr_chain..."
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 154a107cd376..fc4084ef4736 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -335,12 +335,17 @@ static struct notifier_block lockd_inet6addr_notifier = {
 };
 #endif
 
-static void lockd_svc_exit_thread(void)
+static void lockd_unregister_notifiers(void)
 {
 	unregister_inetaddr_notifier(&lockd_inetaddr_notifier);
 #if IS_ENABLED(CONFIG_IPV6)
 	unregister_inet6addr_notifier(&lockd_inet6addr_notifier);
 #endif
+}
+
+static void lockd_svc_exit_thread(void)
+{
+	lockd_unregister_notifiers();
 	svc_exit_thread(nlmsvc_rqst);
 }
 
@@ -462,7 +467,7 @@ int lockd_up(struct net *net)
 	 * Note: svc_serv structures have an initial use count of 1,
 	 * so we exit through here on both success and failure.
 	 */
-err_net:
+err_put:
 	svc_destroy(serv);
 err_create:
 	mutex_unlock(&nlmsvc_mutex);
@@ -470,7 +475,9 @@ err_create:
 
 err_start:
 	lockd_down_net(serv, net);
-	goto err_net;
+err_net:
+	lockd_unregister_notifiers();
+	goto err_put;
 }
 EXPORT_SYMBOL_GPL(lockd_up);
 
