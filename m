Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:10216 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754712Ab3GJRVS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 10 Jul 2013 13:21:18 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r6AHLHeO013878
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 10 Jul 2013 13:21:18 -0400
Received: from fury.redhat.com (vpn-230-234.phx2.redhat.com [10.3.230.234])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r6AHLFcs020864
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES128-SHA bits=128 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 10 Jul 2013 13:21:16 -0400
Date: Wed, 10 Jul 2013 13:19:50 -0400
From: David Jeffery <djeffery@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] lockd: protect nlm_blocked access in nlmsvc_retry_blocked
Message-ID: <20130710171903.GA30834@fury.redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In nlmsvc_retry_blocked, the check that the list is non-empty and acquiring
the pointer of the first entry is unprotected by any lock.  This allows a rare
race condition when there is only one entry on the list.  A function such as
nlmsvc_grant_callback() can be called, which will temporarily remove the entry
from the list.  Between the list_empty() and list_entry(),the list may become
empty, causing an invalid pointer to be used as an nlm_block, leading to a
possible crash.

This patch adds the nlm_block_lock around these calls to prevent concurrent
use of the nlm_blocked list.

Signed-off-by: David Jeffery <djeffery@redhat.com>


--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -951,6 +951,7 @@ nlmsvc_retry_blocked(void)
 	unsigned long	timeout = MAX_SCHEDULE_TIMEOUT;
 	struct nlm_block *block;
 
+	spin_lock(&nlm_blocked_lock);
 	while (!list_empty(&nlm_blocked) && !kthread_should_stop()) {
 		block = list_entry(nlm_blocked.next, struct nlm_block, b_list);
 
@@ -960,6 +961,7 @@ nlmsvc_retry_blocked(void)
 			timeout = block->b_when - jiffies;
 			break;
 		}
+		spin_unlock(&nlm_blocked_lock);
 
 		dprintk("nlmsvc_retry_blocked(%p, when=%ld)\n",
 			block, block->b_when);
@@ -969,7 +971,9 @@ nlmsvc_retry_blocked(void)
 			retry_deferred_block(block);
 		} else
 			nlmsvc_grant_blocked(block);
+		spin_lock(&nlm_blocked_lock);
 	}
+	spin_unlock(&nlm_blocked_lock);
 
 	return timeout;
 }
