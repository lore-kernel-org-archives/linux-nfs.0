Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx3-phx2.redhat.com ([209.132.183.24]:37383 "EHLO
	mx3-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753119AbaHEPTm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Aug 2014 11:19:42 -0400
Received: from zmail10.collab.prod.int.phx2.redhat.com (zmail10.collab.prod.int.phx2.redhat.com [10.5.83.12])
	by mx3-phx2.redhat.com (8.13.8/8.13.8) with ESMTP id s75FJgPx016830
	for <linux-nfs@vger.kernel.org>; Tue, 5 Aug 2014 11:19:42 -0400
Date: Tue, 5 Aug 2014 11:19:42 -0400 (EDT)
From: David Jeffery <djeffery@redhat.com>
To: linux-nfs@vger.kernel.org
Message-ID: <1630665170.14504134.1407251982055.JavaMail.zimbra@redhat.com>
In-Reply-To: <1195286747.14503775.1407251856163.JavaMail.zimbra@redhat.com>
Subject: [PATCH] nfs: Don't busy-wait on SIGKILL in __nfs_iocounter_wait
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


If a SIGKILL is sent to a task waiting in __nfs_iocounter_wait,
it will busy-wait or soft lockup in its while loop.
nfs_wait_bit_killable won't sleep, and the loop won't exit on
the error return.  

Stop the busy-wait by breaking out of the loop when
nfs_wait_bit_killable returns an error.

Signed-off-by: David Jeffery <djeffery@redhat.com>
---
I'm not completely confident this is the right solution. I
would like feedback if the intention was to break out of
this loop on error, or if we do need to wait here until
io_count hits zero and use something other than
nfs_wait_bit_killable to wait in case of SIGKILL.

 pagelist.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 17fab89..f29a690 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -116,7 +116,7 @@ __nfs_iocounter_wait(struct nfs_io_counter *c)
 		if (atomic_read(&c->io_count) == 0)
 			break;
 		ret = nfs_wait_bit_killable(&c->flags);
-	} while (atomic_read(&c->io_count) != 0);
+	} while (atomic_read(&c->io_count) != 0 && !ret);
 	finish_wait(wq, &q.wait);
 	return ret;
 }
