Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:30925 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932481Ab3GWPta (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 23 Jul 2013 11:49:30 -0400
Subject: [PATCH] Fix __wait_on_atomic_t() to call the action func if the
 counter != 0
To: torvalds@linux-foundation.org
From: David Howells <dhowells@redhat.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        linux-kernel@vger.kernel.org, linux-cachefs@redhat.com,
        Milosz Tanski <milosz@adfin.com>,
        Yacine Belkadi <yacine.belkadi.1@gmail.com>
Date: Tue, 23 Jul 2013 16:49:24 +0100
Message-ID: <20130723154924.24306.42326.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Fix __wait_on_atomic_t() so that it calls the action func if the counter != 0
rather than if the counter is 0 so as to be analogous to __wait_on_bit().

Thanks to Yacine who found this by visual inspection.

This will affect FS-Cache in that it will could fail to sleep correctly when
trying to clean up after a netfs cookie is withdrawn.

Reported-by: Yacine Belkadi <yacine.belkadi.1@gmail.com>
Signed-off-by: David Howells <dhowells@redhat.com>
cc: Yacine Belkadi <yacine.belkadi.1@gmail.com>
cc: Milosz Tanski <milosz@adfin.com>
cc: Jeff Layton <jlayton@redhat.com>
---

 kernel/wait.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/kernel/wait.c b/kernel/wait.c
index ce0daa3..dec68bd 100644
--- a/kernel/wait.c
+++ b/kernel/wait.c
@@ -333,7 +333,8 @@ int __wait_on_atomic_t(wait_queue_head_t *wq, struct wait_bit_queue *q,
 		prepare_to_wait(wq, &q->wait, mode);
 		val = q->key.flags;
 		if (atomic_read(val) == 0)
-			ret = (*action)(val);
+			break;
+		ret = (*action)(val);
 	} while (!ret && atomic_read(val) != 0);
 	finish_wait(wq, &q->wait);
 	return ret;

