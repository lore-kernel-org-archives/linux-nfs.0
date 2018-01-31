Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35102 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752497AbeAaFQv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 31 Jan 2018 00:16:51 -0500
From: NeilBrown <neilb@suse.com>
To: David Howells <dhowells@redhat.com>,
        Andrew Morton <akpm@linux-foundation.org>,
        Ingo Molnar <mingo@kernel.org>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>
Date: Wed, 31 Jan 2018 16:15:39 +1100
Subject: [PATCH 3/4] cred: export get_task_cred().
Cc: NFS <linux-nfs@vger.kernel.org>,
        lkml <linux-kernel@vger.kernel.org>
Message-ID: <151737573954.14845.13896237848012870176.stgit@noble>
In-Reply-To: <151737571564.14845.2874586176125198504.stgit@noble>
References: <151737571564.14845.2874586176125198504.stgit@noble>
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


