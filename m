From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/2] lockd: set svc_serv->sv_maxconn to a more reasonable value
Date: Fri, 17 Oct 2008 14:26:10 -0400
Message-ID: <1224267970-15769-2-git-send-email-jlayton@redhat.com>
References: <1224267970-15769-1-git-send-email-jlayton@redhat.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49892 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754251AbYJQS0k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Oct 2008 14:26:40 -0400
In-Reply-To: <1224267970-15769-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The default method for calculating the number of connections allowed
per RPC service arbitrarily limits single-threaded services to 80
connections. This is too low for services like lockd and artificially
limits the number of TCP clients that it can support.

Have lockd set a default sv_maxconn value to RLIMIT_NOFILE for the
lockd thread (usually this will be 1024). Also add a module parameter
to allow an admin to set this to an arbitrary value at module load
time.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/svc.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index c631a83..81c336a 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -61,6 +61,7 @@ static unsigned long		nlm_grace_period;
 static unsigned long		nlm_timeout = LOCKD_DFLT_TIMEO;
 static int			nlm_udpport, nlm_tcpport;
 int				nsm_use_hostnames = 0;
+unsigned int			nlm_max_connections;
 
 /*
  * Constants needed for the sysctl interface.
@@ -287,6 +288,9 @@ int lockd_up(void)
 		goto destroy_and_out;
 	}
 
+	serv->sv_maxconn = nlm_max_connections ? nlm_max_connections :
+			    nlmsvc_task->signal->rlim[RLIMIT_NOFILE].rlim_cur;
+
 	/*
 	 * Note: svc_serv structures have an initial use count of 1,
 	 * so we exit through here on both success and failure.
@@ -484,6 +488,7 @@ module_param_call(nlm_udpport, param_set_port, param_get_int,
 module_param_call(nlm_tcpport, param_set_port, param_get_int,
 		  &nlm_tcpport, 0644);
 module_param(nsm_use_hostnames, bool, 0644);
+module_param(nlm_max_connections, uint, 0644);
 
 /*
  * Initialising and terminating the module.
-- 
1.5.5.1

