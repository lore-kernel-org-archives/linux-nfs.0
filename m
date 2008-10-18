From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/2] lockd: set svc_serv->sv_maxconn to a more reasonable value
Date: Sat, 18 Oct 2008 09:02:47 -0400
Message-ID: <1224334967-24754-2-git-send-email-jlayton@redhat.com>
References: <1224334967-24754-1-git-send-email-jlayton@redhat.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48574 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750878AbYJRNDJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 18 Oct 2008 09:03:09 -0400
In-Reply-To: <1224334967-24754-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The default method for calculating the number of connections allowed
per RPC service arbitrarily limits single-threaded services to 80
connections. This is too low for services like lockd and artificially
limits the number of TCP clients that it can support.

Have lockd set a default sv_maxconn value to 1024 (which is the typical
default value for RLIMIT_NOFILE. Also add a module parameter to allow an
admin to set this to an arbitrary value.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index c631a83..e804155 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -62,6 +62,9 @@ static unsigned long		nlm_timeout = LOCKD_DFLT_TIMEO;
 static int			nlm_udpport, nlm_tcpport;
 int				nsm_use_hostnames = 0;
 
+/* RLIM_NOFILE defaults to 1024. That seems like a reasonable default here. */
+static unsigned int		nlm_max_connections = 1024;
+
 /*
  * Constants needed for the sysctl interface.
  */
@@ -143,6 +146,9 @@ lockd(void *vrqstp)
 		long timeout = MAX_SCHEDULE_TIMEOUT;
 		RPC_IFDEBUG(char buf[RPC_MAX_ADDRBUFLEN]);
 
+		/* update sv_maxconn if it has changed */
+		rqstp->rq_server->sv_maxconn = nlm_max_connections;
+
 		if (signalled()) {
 			flush_signals(current);
 			if (nlmsvc_ops) {
@@ -275,6 +281,7 @@ int lockd_up(void)
 	}
 
 	svc_sock_update_bufs(serv);
+	serv->sv_maxconn = nlm_max_connections;
 
 	nlmsvc_task = kthread_run(lockd, nlmsvc_rqst, serv->sv_name);
 	if (IS_ERR(nlmsvc_task)) {
@@ -484,6 +491,7 @@ module_param_call(nlm_udpport, param_set_port, param_get_int,
 module_param_call(nlm_tcpport, param_set_port, param_get_int,
 		  &nlm_tcpport, 0644);
 module_param(nsm_use_hostnames, bool, 0644);
+module_param(nlm_max_connections, uint, 0644);
 
 /*
  * Initialising and terminating the module.
-- 
1.5.5.1

