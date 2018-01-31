Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35068 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752321AbeAaFQo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Jan 2018 00:16:44 -0500
From: NeilBrown <neilb@suse.com>
To: David Howells <dhowells@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@kernel.org>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Date: Wed, 31 Jan 2018 16:15:39 +1100
Subject: [PATCH 2/4] cred: add get_cred_rcu()
Cc: NFS <linux-nfs@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>
Message-ID: <151737573951.14845.5608065682472518930.stgit@noble>
In-Reply-To: <151737571564.14845.2874586176125198504.stgit@noble>
References: <151737571564.14845.2874586176125198504.stgit@noble>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sometimes we want to opportunistically get a
ref to a cred in an rcu_read_lock protected section.
get_task_cred() does this, and NFS does as similar thing
with its own credential structures.
To prepare for NFS converting to use 'struct cred' more
uniformly, define get_cred_rcu(), and use it in
get_task_cred().

Signed-off-by: NeilBrown <neilb@suse.com>
---
 include/linux/cred.h |   11 +++++++++++
 kernel/cred.c        |    2 +-
 2 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/include/linux/cred.h b/include/linux/cred.h
index 6dd51e503f23..69ed76f7d49f 100644
--- a/include/linux/cred.h
+++ b/include/linux/cred.h
@@ -247,6 +247,17 @@ static inline const struct cred *get_cred(const struct cred *cred)
 	return get_new_cred(nonconst_cred);
 }
 
+static inline const struct cred *get_cred_rcu(const struct cred *cred)
+{
+	struct cred *nonconst_cred = (struct cred *) cred;
+	if (!cred)
+		return NULL;
+	if (!atomic_inc_not_zero(&nonconst_cred->usage))
+		return NULL;
+	validate_creds(cred);
+	return cred;
+}
+
 /**
  * put_cred - Release a reference to a set of credentials
  * @cred: The credentials to release
diff --git a/kernel/cred.c b/kernel/cred.c
index 4ce75c6fb752..f11aa4e0d2b9 100644
--- a/kernel/cred.c
+++ b/kernel/cred.c
@@ -195,7 +195,7 @@ const struct cred *get_task_cred(struct task_struct *task)
 	do {
 		cred = __task_cred((task));
 		BUG_ON(!cred);
-	} while (!atomic_inc_not_zero(&((struct cred *)cred)->usage));
+	} while (!get_cred_rcu(cred));
 
 	rcu_read_unlock();
 	return cred;


