Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60602 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752986AbeBEQgt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 5 Feb 2018 11:36:49 -0500
Received: from smtp.corp.redhat.com (int-mx04.intmail.prod.int.phx2.redhat.com [10.5.11.14])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id DFD0181E03
        for <linux-nfs@vger.kernel.org>; Mon,  5 Feb 2018 16:36:49 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (ovpn-117-122.phx2.redhat.com [10.3.117.122])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 8CA855D9CB
        for <linux-nfs@vger.kernel.org>; Mon,  5 Feb 2018 16:36:49 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] rmtcalls: Don't use privileged ports for remote calls.
Date: Mon,  5 Feb 2018 11:36:47 -0500
Message-Id: <20180205163647.15822-2-steved@redhat.com>
In-Reply-To: <20180205163647.15822-1-steved@redhat.com>
References: <20180205163647.15822-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sockets use for remote calls are preallocated which
mean the a port will be tied up for as long as
rpcbind runs. Make sure that port is not a privileged
port by binding the socket before calling svc_tli_create()

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 src/rpcb_svc_com.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/src/rpcb_svc_com.c b/src/rpcb_svc_com.c
index 9c1c3af..b9aeaaf 100644
--- a/src/rpcb_svc_com.c
+++ b/src/rpcb_svc_com.c
@@ -501,9 +501,12 @@ static struct rmtcallfd_list *rmttail;
 int
 create_rmtcall_fd(struct netconfig *nconf)
 {
-	int fd;
+	int fd, cc;
 	struct rmtcallfd_list *rmt;
 	SVCXPRT *xprt;
+	struct __rpc_sockinfo si;
+	struct sockaddr_storage ss;
+	struct t_bind bindaddr;
 
 	if ((fd = __rpc_nconf2fd(nconf)) == -1) {
 		if (debugging)
@@ -512,6 +515,20 @@ create_rmtcall_fd(struct netconfig *nconf)
 			nconf->nc_device, errno);
 		return (-1);
 	}
+
+	if (!__rpc_nconf2sockinfo(nconf, &si)) {
+		xlog(LOG_ERR, "create_rmtcall_fd: cannot get information for %s",
+		    nconf->nc_netid);
+		return (-1);
+	}
+	memset(&ss, 0, sizeof ss);
+	ss.ss_family = si.si_af;
+	cc = bind(fd, (struct sockaddr *)(void *)&ss,
+		(socklen_t)si.si_alen);
+	if (cc < 0) {
+		xlog(LOG_ERR, "create_rmtcall_fd: could not bind to anonymous port");
+		return (-1);
+	}
 	xprt = svc_tli_create(fd, 0, (struct t_bind *) 0, 0, 0);
 	if (xprt == NULL) {
 		if (debugging)
-- 
2.14.3

