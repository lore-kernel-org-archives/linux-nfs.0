From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Non-blocking lock requests during the grace period
Date: 15 Nov 2002 03:33:56 +0100
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <shswunf8stn.fsf@helicity.uio.no>
References: <OFCACC2A48.A38B3611-ON87256C71.006D0CEB@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Juan Gomez <juang@us.ibm.com>
In-Reply-To: <OFCACC2A48.A38B3611-ON87256C71.006D0CEB@us.ibm.com>
List-ID: <nfs.lists.sourceforge.net>

>>>>> " " == Juan Gomez <juang@us.ibm.com> writes:

     > I found out that the current Linux client of lockd blocks
     > non-blocking lock requests while the server is in the grace
     > period.  I think this is incorrect behavior and I am wondering
     > if the will exists out there to correct this and return
     > "resource not available" to the process when a request is for a
     > *non-blocking* lock while the server is in the grace period.

Would the following fix it?

Cheers,
  Trond

--- linux-2.5.47/fs/lockd/clntproc.c.orig	2002-09-29 10:15:13.000000000 -0400
+++ linux-2.5.47/fs/lockd/clntproc.c	2002-11-14 21:32:26.000000000 -0500
@@ -256,10 +256,8 @@
 		msg.rpc_cred = NULL;
 
 	do {
-		if (host->h_reclaiming && !argp->reclaim) {
-			interruptible_sleep_on(&host->h_gracewait);
-			continue;
-		}
+		if (host->h_reclaiming && !argp->reclaim)
+			goto wait_on_grace;
 
 		/* If we have no RPC client yet, create one. */
 		if ((clnt = nlm_bind_host(host)) == NULL)
@@ -296,6 +294,9 @@
 			dprintk("lockd: server returns status %d\n", resp->status);
 			return 0;	/* Okay, call complete */
 		}
+wait_on_grace:
+		if (!argp->block)
+			return -EAGAIN;
 
 		/* Back off a little and try again */
 		interruptible_sleep_on_timeout(&host->h_gracewait, 15*HZ);
