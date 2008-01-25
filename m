From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 103/112] SUNRPC: Clean up block comment preceding
	rpcb_getport_sync()
Date: Fri, 25 Jan 2008 11:38:01 -0500
Message-ID: <20080125163800.31887.26348.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:63111 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756736AbYAYRA1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:27 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH09Uk010371
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:27 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 net/sunrpc/rpcb_clnt.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 77af989..8cbdc0a 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -200,10 +200,13 @@ int rpcb_register(u32 prog, u32 vers, int prot, unsigned short port, int *okay)
  * @vers: RPC version number to bind
  * @prot: transport protocol to use to make this request
  *
+ * Return value is the requested advertised port number,
+ * or a negative errno value.
+ *
  * Called from outside the RPC client in a synchronous task context.
  * Uses default timeout parameters specified by underlying transport.
  *
- * XXX: Needs to support IPv6, and rpcbind versions 3 and 4
+ * XXX: Needs to support IPv6
  */
 int rpcb_getport_sync(struct sockaddr_in *sin, u32 prog, u32 vers, int prot)
 {
