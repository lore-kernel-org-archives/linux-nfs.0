From: "Aaron Wiebe" <epiphani@gmail.com>
Subject: Re: nlm bad unlocking condition (results in stuck lock serverside)
Date: Thu, 27 Mar 2008 17:24:16 -0400
Message-ID: <e7ca40f70803271424m4dd8c360o5171a6e88b47d27e@mail.gmail.com>
References: <e7ca40f70803270933vb526f3bxb93be24b4f791926@mail.gmail.com>
	 <EXNANE01YTHrdusluCB000001cc@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	bseibel@gmail.com
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.182]:25388 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754420AbYC0VYS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Mar 2008 17:24:18 -0400
Received: by el-out-1112.google.com with SMTP id z25so2612545ele.15
        for <linux-nfs@vger.kernel.org>; Thu, 27 Mar 2008 14:24:17 -0700 (PDT)
In-Reply-To: <EXNANE01YTHrdusluCB000001cc-kboziUmgGqYSZCGxjG3uujkOHZLvdrmu@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We think we have a fix - however we definitely need some folks to
review.  This does appear to solve the reproducible issue as we were
seeing it.

>From 627028f01dae67882061c533236ac3f1f00c70c3 Mon Sep 17 00:00:00 2001
From: Aaron Wiebe <aaronw-k7QPB+T73Rje9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Date: Thu, 27 Mar 2008 16:53:04 -0400
Subject: [PATCH] Fix an issue where an NLM CANCEL would desync VFS

In the condition where a process is waiting on an NLM
lock, and the process receives a signal, an NLM CANCEL
is sent to the nfs server.  In that case, VFS would
maintain an entry in its blocked list.  After the
signal handler returns, NLM re-requests the lock.

VFS is not being properly notified to release the local
lock when the NLM CANCEL is processed.  When NLM
re-requests the lock, blocks, and then a GRANTED
callback is received, the process ends up blocking on
its original (cancelled) lock.

Tell VFS to clear the lock request after a CANCEL is
completed.

Signed-off-by:  Aaron Wiebe <aaronw-k7QPB+T73Rje9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
Signed-off-by:  Brandon Seibel <brandon.seibel-k7QPB+T73Rje9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
---
 fs/lockd/clntproc.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index b6b74a6..6a1b80c 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -687,6 +687,10 @@ static int nlmclnt_cancel(struct nlm_host *host,
int block, struct file_lock *fl
                return -ENOMEM;
        req->a_flags = RPC_TASK_ASYNC;

+       /* set the lock type to F_UNLCK for vfs, so once the cancel has
+        * completed, the vfs blocked list will be updated accordingly
+        */
+       fl->fl_type = F_UNLCK;
        nlmclnt_setlockargs(req, fl);
        req->a_args.block = block;

-- 
1.5.3.4
