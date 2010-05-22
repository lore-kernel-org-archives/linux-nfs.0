From: Dan Carpenter <error27@gmail.com>
Subject: re: SUNRPC: Fail over more quickly on connect errors
Date: Sat, 22 May 2010 22:23:28 +0200
Message-ID: <20100522202327.GM22515@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:54278 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758017Ab0EVUXv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 22 May 2010 16:23:51 -0400
Received: by vws9 with SMTP id 9so1653453vws.19
        for <linux-nfs@vger.kernel.org>; Sat, 22 May 2010 13:23:50 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm going through some smatch stuff and it complains about a potential
null dereference from a8ce4a8f37: "SUNRPC: Fail over more quickly on 
connect errors"

--- a/net/sunrpc/xprt.c
+++ b/net/sunrpc/xprt.c
@@ -710,7 +710,7 @@ void xprt_connect(struct rpc_task *task)
                if (task->tk_rqstp)
                ^^^^^^^^^^^^^^^^^^^

	We assume task->tk_rqstp can be null here.

                        task->tk_rqstp->rq_bytes_sent = 0;
 
-               task->tk_timeout = xprt->connect_timeout;
+               task->tk_timeout = task->tk_rqstp->rq_timeout;
                                   ^^^^^^^^^^^^^^^^^^^^^^^^^^^

	We dereference it here.

                rpc_sleep_on(&xprt->pending, task, xprt_connect_status);
 
                if (test_bit(XPRT_CLOSING, &xprt->state))

regards,
dan carpenter

