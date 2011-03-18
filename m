Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:38214 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752488Ab1CRW4D (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Mar 2011 18:56:03 -0400
From: Wolfgang Walter <wolfgang.walter@stwm.de>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: problem with nfs4: rpciod seems to loop in rpc_shutdown_client forever
Date: Fri, 18 Mar 2011 23:49:21 +0100
Content-Type: Text/Plain;
  charset="iso-8859-1"
Message-Id: <201103182349.22331.wolfgang.walter@stwm.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hello,

I have a problem with our nfs-server (stable 2.6.32.33 but also with
.31 or .32 and probably older ones): sometimes
one or more rpciod get stuck. I used

	rpcdebug -m rpc -s all

I get messages as the following one about every second:

Mar 18 11:15:37 au kernel: [44640.906793] RPC:       killing all tasks for client ffff88041c51de00
Mar 18 11:15:38 au kernel: [44641.906793] RPC:       killing all tasks for client ffff88041c51de00
Mar 18 11:15:39 au kernel: [44642.906795] RPC:       killing all tasks for client ffff88041c51de00
Mar 18 11:15:40 au kernel: [44643.906793] RPC:       killing all tasks for client ffff88041c51de00
Mar 18 11:15:41 au kernel: [44644.906795] RPC:       killing all tasks for client ffff88041c51de00
Mar 18 11:15:42 au kernel: [44645.906794] RPC:       killing all tasks for client ffff88041c51de00

and I get this messages:

Mar 18 22:45:57 au kernel: [86061.779008]   174 0381     -5 ffff88041c51de00   (null)        0 ffffffff817211a0 nfs4_cbv1 CB_NULL a:rpc_exit_task q:none

My theorie is this one:

* this async task is runnable but does not progress (calling rpc_exit_task).
* this is because the same rpciod which handles this task loops in
  rpc_shutdown_client waiting for this task to go away.
* because rpc_shutdown_client is called from an async rpc, too

At the beginning is is always one or more tasks as above.

Once a rpciod hangs more an more other tasks hang forever:

Mar 18 22:45:57 au kernel: [86061.778809] -pid- flgs status -client- --rqstp- -timeout ---ops--
Mar 18 22:45:57 au kernel: [86061.778819]   300 0281    -13 ffff8801ef5d0600   (null)        0 ffffffff817211a0 nfs4_cbv1 CB_NULL a:call_refreshresult q:none
Mar 18 22:45:57 au kernel: [86061.778823]   289 0281      0 ffff880142a49800 ffff8802a1dde000        0 ffffffff817a3fd0 rpcbindv2 GETPORT a:call_status q:none
Mar 18 22:45:57 au kernel: [86061.778827]   286 0281      0 ffff880349f57e00 ffff88010affe000        0 ffffffff817a3fd0 rpcbindv2 GETPORT a:call_status q:none
Mar 18 22:45:57 au kernel: [86061.778830]   283 0281      0 ffff88041d19ac00 ffff880418650000        0 ffffffff817a3fd0 rpcbindv2 GETPORT a:call_status q:none
Mar 18 22:45:57 au kernel: [86061.778833]   280 0281      0 ffff880380561400 ffff8803d3b7a000        0 ffffffff817a3fd0 rpcbindv2 GETPORT a:call_status q:none
Mar 18 22:45:57 au kernel: [86061.778837]   277 0281      0 ffff8803ef73ac00 ffff88010af50000        0 ffffffff817a3fd0 rpcbindv2 GETPORT a:call_status q:none
Mar 18 22:45:57 au kernel: [86061.778840]   274 0281      0 ffff880302c31c00 ffff8803e92b6000        0 ffffffff817a3fd0 rpcbindv2 GETPORT a:call_status q:none
Mar 18 22:45:57 au kernel: [86061.778844]   271 0281      0 ffff8803c44d0600 ffff88002687e000        0 ffffffff817a3fd0 rpcbindv2 GETPORT a:call_status q:none
Mar 18 22:45:57 au kernel: [86061.778847]   234 0281   -110 ffff8801f414b000 ffff880005382000        0 ffffffff817a3fd0 rpcbindv2 GETPORT a:call_connect_status q:none
Mar 18 22:45:57 au kernel: [86061.778851]   233 0281   -110 ffff8802c9945800 ffff880050382000        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778855]   235 0281   -110 ffff8802c9945800 ffff880050382150        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778858]   236 0281   -110 ffff8802c9945800 ffff8800503822a0        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778861]   237 0281   -110 ffff8802c9945800 ffff8800503823f0        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778864]   238 0281   -110 ffff8802c9945800 ffff880050382540        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778867]   239 0281   -110 ffff8802c9945800 ffff880050382690        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778870]   240 0281   -110 ffff8802c9945800 ffff8800503827e0        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778874]   241 0281   -110 ffff8802c9945800 ffff880050382930        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778877]   242 0281   -110 ffff8802c9945800 ffff880050382a80        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778880]   243 0281   -110 ffff8802c9945800 ffff880050382bd0        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778884]   244 0281   -110 ffff8802c9945800 ffff880050382d20        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778887]   245 0281   -110 ffff8802c9945800 ffff880050382e70        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778890]   246 0281   -110 ffff8802c9945800 ffff880050382fc0        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778893]   247 0281   -110 ffff8802c9945800 ffff880050383110        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778896]   248 0281   -110 ffff8802c9945800 ffff880050383260        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778899]   249 0281   -110 ffff8802c9945800 ffff8800503833b0        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_bind_status q:none
Mar 18 22:45:57 au kernel: [86061.778903]   250 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778906]   251 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778909]   252 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778912]   253 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778915]   254 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778919]   255 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778922]   256 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778925]   257 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778928]   258 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778931]   259 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778935]   260 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778938]   261 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778941]   262 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778945]   263 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778948]   264 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778951]   265 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778954]   266 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778958]   267 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778961]   268 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778964]   269 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 UNLOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778967]   272 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 LOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778971]   275 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 LOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778974]   278 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 LOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778977]   281 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 LOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778980]   284 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 LOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778983]   287 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 LOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778987]   290 0281    -11 ffff8802c9945800   (null)        0 ffffffff81721440 lockdv4 LOCK_RES a:call_reserveresult q:xprt_backlog
Mar 18 22:45:57 au kernel: [86061.778990]   232 0281   -110 ffff8803d3bc6000 ffff8803d5eaa000        0 ffffffff817a3fd0 rpcbindv2 GETPORT a:call_connect_status q:none
Mar 18 22:45:57 au kernel: [86061.778993]   230 0281    -13 ffff8801ef5d0200   (null)        0 ffffffff817211a0 nfs4_cbv1 CB_NULL a:call_refreshresult q:none
Mar 18 22:45:57 au kernel: [86061.778997]   180 0281    -13 ffff880341e36800   (null)        0 ffffffff817211a0 nfs4_cbv1 CB_NULL a:call_refreshresult q:none
Mar 18 22:45:57 au kernel: [86061.779000]   179 0281    -13 ffff88027dc01000   (null)        0 ffffffff817211a0 nfs4_cbv1 CB_NULL a:call_refreshresult q:none
Mar 18 22:45:57 au kernel: [86061.779003]   178 0281    -13 ffff8801bddac600   (null)        0 ffffffff817211a0 nfs4_cbv1 CB_NULL a:call_refreshresult q:none
Mar 18 22:45:57 au kernel: [86061.779008]   174 0381     -5 ffff88041c51de00   (null)        0 ffffffff817211a0 nfs4_cbv1 CB_NULL a:rpc_exit_task q:none

I think I saw hanging rpciods once in a while but since we use kerberos we
have it very often.


My theorie may be completely bogus and there is another reason, I'm not
familiar with the code.

Regards,
-- 
Wolfgang Walter
Studentenwerk München
Anstalt des öffentlichen Rechts
