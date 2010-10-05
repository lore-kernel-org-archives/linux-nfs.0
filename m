Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:33979 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755460Ab0JEIWx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Oct 2010 04:22:53 -0400
Received: from cyclope.frec.bull.fr (cyclope.frec.bull.fr [129.183.4.9])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 3557C700DE
	for <linux-nfs@vger.kernel.org>; Tue,  5 Oct 2010 10:22:30 +0200 (CEST)
Received: from [129.183.101.246] (pa-129.183.101.246.frec.bull.fr [129.183.101.246])
	by cyclope.frec.bull.fr (Postfix) with ESMTP id BD24D2728D
	for <linux-nfs@vger.kernel.org>; Tue,  5 Oct 2010 10:22:29 +0200 (CEST)
Message-ID: <4CAAE046.5060209@bull.net>
Date: Tue, 05 Oct 2010 10:22:30 +0200
From: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
To: linux-nfs@vger.kernel.org
Subject: "xprt" reference count drops to 0
References: <4C7E4469.70807@duchatelet.net>
In-Reply-To: <4C7E4469.70807@duchatelet.net>
Content-Type: multipart/mixed;
 boundary="------------070802090509040908030606"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

--------------070802090509040908030606
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi,

Due to some race conditions, the reference count can become 0
while "xprt" is still on a "pool":

WARNING: at lib/kref.c:43 kref_get+0x23/0x2d()
  [] kref_get+0x23/0x2d
  [] svc_xprt_get+0x12/0x14 [sunrpc]
  [] svc_recv+0x2db/0x78a [sunrpc]

I think we should increase the reference counter before adding "xprt"
onto any list.

Obviously, we keep increasing the reference count before passing "xprt"
to another thread via "rqstp->rq_xprt".

Thanks,

Zoltan Menyhart

--------------070802090509040908030606
Content-Type: text/plain;
 name="diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="diff"

"svc_xprt_get()" should be invoked before adding "xprt" onto "pool" by
"svc_xprt_enqueue()".
Otherwise "xprt->xpt_ref" can drop to 0 due to race conditions.

Signed-off-by: Zoltan Menyhart <Zoltan.Menyhart@bull.net>

--- old/net/sunrpc/svc_xprt.c	2010-10-05 09:47:51.000000000 +0200
+++ new/net/sunrpc/svc_xprt.c	2010-10-05 09:47:20.000000000 +0200
@@ -369,6 +369,7 @@
 	}
 
  process:
+	svc_xprt_get(xprt);
 	if (!list_empty(&pool->sp_threads)) {
 		rqstp = list_entry(pool->sp_threads.next,
 				   struct svc_rqst,
@@ -381,7 +382,6 @@
 				"svc_xprt_enqueue: server %p, rq_xprt=%p!\n",
 				rqstp, rqstp->rq_xprt);
 		rqstp->rq_xprt = xprt;
-		svc_xprt_get(xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 		pool->sp_stats.threads_woken++;
@@ -655,7 +655,6 @@
 	xprt = svc_xprt_dequeue(pool);
 	if (xprt) {
 		rqstp->rq_xprt = xprt;
-		svc_xprt_get(xprt);
 		rqstp->rq_reserved = serv->sv_max_mesg;
 		atomic_add(rqstp->rq_reserved, &xprt->xpt_reserved);
 	} else {

--------------070802090509040908030606--
