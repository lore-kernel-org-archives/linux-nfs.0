Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:20124 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753552Ab3FKLJn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Jun 2013 07:09:43 -0400
From: Jeff Layton <jlayton@redhat.com>
To: viro@zeniv.linux.org.uk, matthew@wil.cx, bfields@fieldses.org
Cc: dhowells@redhat.com, sage@inktank.com, smfrench@gmail.com,
        swhiteho@redhat.com, Trond.Myklebust@netapp.com,
        akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
        linux-afs@lists.infradead.org, ceph-devel@vger.kernel.org,
        linux-cifs@vger.kernel.org, samba-technical@lists.samba.org,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, piastryyy@gmail.com
Subject: [PATCH v2 06/14] locks: don't walk inode->i_flock list in locks_show
Date: Tue, 11 Jun 2013 07:09:00 -0400
Message-Id: <1370948948-31784-7-git-send-email-jlayton@redhat.com>
In-Reply-To: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
References: <1370948948-31784-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When we convert over to using the i_lock to protect the i_flock list,
that will introduce a potential lock inversion problem in locks_show.
When we want to walk the i_flock list, we'll need to take the i_lock.

Rather than do that, just walk the global blocked_locks list and print
out any that are blocked on the given lock.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/locks.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index e451d18..3fd27f0 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -2249,8 +2249,10 @@ static int locks_show(struct seq_file *f, void *v)
 
 	lock_get_status(f, fl, *((loff_t *)f->private), "");
 
-	list_for_each_entry(bfl, &fl->fl_block, fl_block)
-		lock_get_status(f, bfl, *((loff_t *)f->private), " ->");
+	list_for_each_entry(bfl, &blocked_list, fl_link) {
+		if (bfl->fl_next == fl)
+			lock_get_status(f, bfl, *((loff_t *)f->private), " ->");
+	}
 
 	return 0;
 }
-- 
1.7.1

