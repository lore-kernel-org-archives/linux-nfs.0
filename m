Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:38409 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750774AbeBSFDa (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 19 Feb 2018 00:03:30 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Date: Mon, 19 Feb 2018 16:02:28 +1100
Subject: [PATCH 03/23] cred: export get_task_cred().
Cc: linux-nfs@vger.kernel.org
Message-ID: <151901654884.17421.2146401182386690621.stgit@noble>
In-Reply-To: <151901634940.17421.7637564368419392071.stgit@noble>
References: <151901634940.17421.7637564368419392071.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is no reason that modules should not be able
to use this, and NFS will need it when converted to
use 'struct cred'.

Signed-off-by: NeilBrown <neilb@suse.com>
---
 kernel/cred.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/cred.c b/kernel/cred.c
index f11aa4e0d2b9..3e43bde1fd3c 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -200,6 +200,7 @@ const struct cred *get_task_cred(struct task_struct *task)
 	rcu_read_unlock();
 	return cred;
 }
+EXPORT_SYMBOL(get_task_cred);
 
 /*
  * Allocate blank credentials, such that the credentials can be filled in at a


