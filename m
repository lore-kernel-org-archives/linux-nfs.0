From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] lockd: Don't bother with RPC ping for NSM upcalls
Date: Fri, 15 May 2009 11:33:02 -0400
Message-ID: <20090515153301.17053.34426.stgit@ingres.1015granger.net>
References: <20090515153111.17053.3822.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:39850 "EHLO
	rgminet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752737AbZEOPdR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 May 2009 11:33:17 -0400
In-Reply-To: <20090515153111.17053.3822.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cut NSM upcall RPC traffic in half -- don't do a NULL call first.
The cases where a ping would be helpful are rare.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/mon.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 3838533..7fce1b5 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -112,6 +112,7 @@ static struct rpc_clnt *nsm_create(void)
 		.program		= &nsm_program,
 		.version		= NSM_VERSION,
 		.authflavor		= RPC_AUTH_NULL,
+		.flags			= RPC_CLNT_CREATE_NOPING,
 	};
 
 	return rpc_create(&args);

