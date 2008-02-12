From: Harshula <harshula@sgi.com>
Subject: [PATCH] nfs-utils: mountd: empty export list should not be treated
	as a failure
Date: Tue, 12 Feb 2008 16:13:11 +1100
Message-ID: <1202793191.2890.36.camel@serendib.melbourne.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from relay1.sgi.com ([192.48.171.29]:58096 "EHLO relay.sgi.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750814AbYBLFNR (ORCPT
	<rfc822;@relay.sgi.com:linux-nfs@vger.kernel.org>);
	Tue, 12 Feb 2008 00:13:17 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Steve,

This patch is against:
git://git.linux-nfs.org/projects/steved/nfs-utils.git

In mountd, if get_exportlist() (utils/mountd/mountd.c) returns NULL it
should not be considered a failure. It just means that there are no
exports on the system.

The practical problem with the current code is that a showmount -e
results in a syslog message from mountd that looks like:

rpc.mountd: export request from 10.250.100.2 failed.


References: SGI: PV977213
Reviewed-by: Greg Banks <gnb@sgi.com>
Signed-off-by: Harshula Jayasuriya <harshula@sgi.com>
---

 utils/mountd/mountd.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -254,10 +254,8 @@ mount_export_1_svc(struct svc_req *rqstp, void
*argp, exports *resp)
        struct sockaddr_in *addr =
                (struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
 
-       if ((*resp = get_exportlist()) == NULL)
-               xlog(L_WARNING, "export request from %s failed.",
-                       inet_ntoa(addr->sin_addr));
-
+       xlog(D_CALL, "EXPORT1 request from %s.",
inet_ntoa(addr->sin_addr));
+       *resp = get_exportlist();
        return 1;
 }
 
@@ -267,9 +265,8 @@ mount_exportall_1_svc(struct svc_req *rqstp, void
*argp, exports *resp)
        struct sockaddr_in *addr =
                (struct sockaddr_in *) svc_getcaller(rqstp->rq_xprt);
 
-       if ((*resp = get_exportlist()) == NULL)
-               xlog(L_WARNING, "exportall request from %s failed.",
-                       inet_ntoa(addr->sin_addr));
+       xlog(D_CALL, "EXPORTALL1 request from %s.",
inet_ntoa(addr->sin_addr));
+       *resp = get_exportlist();
        return 1;
 }
 

cya,
#

