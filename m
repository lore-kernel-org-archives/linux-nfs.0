From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 06/69] LOCKD: Make lockd_up() and lockd_down() exported
 GPL-only
Date: Tue, 23 Dec 2008 18:02:06 -0500
Message-ID: <20081223230206.13743.41664.stgit@heimdal.trondhjem.org>
References: <20081223230158.13743.53992.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29099 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752191AbYLWXXj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Dec 2008 18:23:39 -0500
Received: from svlrsexc1-prd.hq.netapp.com ([10.57.115.30])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id mBNNNbsO006182
	for <linux-nfs@vger.kernel.org>; Tue, 23 Dec 2008 15:23:38 -0800 (PST)
In-Reply-To: <20081223230158.13743.53992.stgit-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/lockd/svc.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)


diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 56b0767..252d801 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -45,7 +45,7 @@
 static struct svc_program	nlmsvc_program;
 
 struct nlmsvc_binding *		nlmsvc_ops;
-EXPORT_SYMBOL(nlmsvc_ops);
+EXPORT_SYMBOL_GPL(nlmsvc_ops);
 
 static DEFINE_MUTEX(nlmsvc_mutex);
 static unsigned int		nlmsvc_users;
@@ -300,7 +300,7 @@ out:
 	mutex_unlock(&nlmsvc_mutex);
 	return error;
 }
-EXPORT_SYMBOL(lockd_up);
+EXPORT_SYMBOL_GPL(lockd_up);
 
 /*
  * Decrement the user count and bring down lockd if we're the last.
@@ -329,7 +329,7 @@ lockd_down(void)
 out:
 	mutex_unlock(&nlmsvc_mutex);
 }
-EXPORT_SYMBOL(lockd_down);
+EXPORT_SYMBOL_GPL(lockd_down);
 
 #ifdef CONFIG_SYSCTL
 

