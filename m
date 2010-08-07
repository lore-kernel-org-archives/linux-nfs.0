Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from wine.ocn.ne.jp ([122.1.235.145]:53098 "EHLO smtp.wine.ocn.ne.jp"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752510Ab0HGBsG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Aug 2010 21:48:06 -0400
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        jlayton@redhat.com
Subject: Re: linux-next NFSD: NULL pointer dereference at nfsd_svc()
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20100805204612.GA13821@fieldses.org>
	<20100805213107.GB13821@fieldses.org>
	<20100806212727.GC29536@fieldses.org>
	<20100806220537.GE29536@fieldses.org>
	<20100806221000.GF29536@fieldses.org>
In-Reply-To: <20100806221000.GF29536@fieldses.org>
Message-Id: <201008071048.AGD12971.FOFQLtSJFMOVHO@I-love.SAKURA.ne.jp>
Date: Sat, 7 Aug 2010 10:48:02 +0900
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Applying commit 4cd7eb015e92f7cefb43eaab3e111d1b3c7b3cbf (with below patch)
and commit e844a7b9805a2b74cfd34c8604f5bba3e0869305 and
commit 7fa53cc872332b265bc5ba1266f39586f218ad4a on linux-2.6.35-next-20100802
solved all problems found in my environment.

Thank you.
--------------------

Fix build error by commit 4cd7eb015e92f7cefb43eaab3e111d1b3c7b3cbf
"nfsd: fix startup/shutdown order bug".

---
 fs/nfsd/nfssvc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-2.6.35-next.orig/fs/nfsd/nfssvc.c
+++ linux-2.6.35-next/fs/nfsd/nfssvc.c
@@ -444,7 +444,7 @@ nfsd_svc(unsigned short port, int nrserv
 	error = nfsd_startup(port, nrservs);
 	if (error)
 		goto out_destroy;
-	}
+
 	error = svc_set_num_threads(nfsd_serv, NULL, nrservs);
 	if (error)
 		goto out_shutdown;
