Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:33745 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152Ab0HBMTi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Aug 2010 08:19:38 -0400
Received: from cyclope.frec.bull.fr (cyclope.frec.bull.fr [129.183.4.9])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 31C936F5E3
	for <linux-nfs@vger.kernel.org>; Mon,  2 Aug 2010 13:49:52 +0200 (CEST)
Received: from [129.183.101.247] (pa-129.183.101.247.frec.bull.fr [129.183.101.247])
	by cyclope.frec.bull.fr (Postfix) with ESMTP id 5A59A27291
	for <linux-nfs@vger.kernel.org>; Mon,  2 Aug 2010 13:49:50 +0200 (CEST)
Message-ID: <4C56B126.2080407@bull.net>
Date: Mon, 02 Aug 2010 13:51:02 +0200
From: Menyhart Zoltan <Zoltan.Menyhart@bull.net>
To: linux-nfs@vger.kernel.org
Subject: Warning in kref handling + kernel hangs
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I have a warning in kref handling (e.g. in 2.6.34.1) and my kernel hangs.
Should not we miss a svc_xprt_get(xprt) in the else branch of svc_xprt_enqueue() ?

int svc_recv(struct svc_rqst *rqstp, long timeout)
{
...
	xprt = svc_xprt_dequeue(pool);
	if (xprt) {
		rqstp->rq_xprt = xprt;
		svc_xprt_get(xprt);  //WARNING: at lib/kref.c:43 kref_get+0x23/0x2d()


void svc_xprt_enqueue(struct svc_xprt *xprt)
{
...
         if (!list_empty(&pool->sp_threads)) {
...
                 svc_xprt_get(xprt);
...
                 wake_up(&rqstp->rq_wait);
         } else {
                 list_add_tail(&xprt->xpt_ready, &pool->sp_sockets);
                 pool->sp_stats.sockets_queued++;
         }

Thanks,

Zoltan Menyhart
