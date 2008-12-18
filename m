From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] nfs-utils: Enabling TCP wrappers
Date: Thu, 18 Dec 2008 14:59:29 -0500
Message-ID: <494AABA1.4070006@RedHat.com>
References: <49468BC7.2000907@RedHat.com> <1819C671-5353-45B4-A814-98B1B2A4BEB1@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:59129 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753904AbYLRUDn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Dec 2008 15:03:43 -0500
In-Reply-To: <1819C671-5353-45B4-A814-98B1B2A4BEB1@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
> 
> A general comment:  This code will need support for IPv6 addresses.
> 
> Until it has it, perhaps we should add some logic to configure.ac that
> prevents the use of tcpwrappers when --enable-ipv6 is in effect.
The following patch does address this concern....

comments?

steved.


commit 5526bb225c745d169c070d392402fc1a569f1d15
Author: Steve Dickson <steved@redhat.com>
Date:   Thu Dec 18 14:57:52 2008 -0500

    Skip the host access check when IPv6 is enabled and its an IPv6 address.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mountd/mount_dispatch.c b/utils/mountd/mount_dispatch.c
index f00c0c5..8aa1955 100644
--- a/utils/mountd/mount_dispatch.c
+++ b/utils/mountd/mount_dispatch.c
@@ -12,6 +12,8 @@
 #include "tcpwrapper.h"
 #endif
 
+#include <sys/syslog.h>
+
 #include "mountd.h"
 #include "rpcmisc.h"
 
@@ -72,12 +74,29 @@ mount_dispatch(struct svc_req *rqstp, SVCXPRT *transp)
 	union mountd_results	result;
 
 #ifdef HAVE_TCP_WRAPPER
+#ifdef IPV6_SUPPORTED
+	static int once = 0;
+
+	if (svc_getcaller(transp)->sin_family != AF_INET) {
+		if (!once) {
+			syslog(LOG_WARNING, 
+				"No IPv6 support in Access Control Library (TCP Wrappers)"); 
+			once++;
+		}
+		goto skipcheck;
+	}
+#endif
 	/* remote host authorization check */
 	if (!check_default("mountd", svc_getcaller(transp),
 			   rqstp->rq_proc, MOUNTPROG)) {
 		svcerr_auth (transp, AUTH_FAILED);
 		return;
 	}
+
+#ifdef IPV6_SUPPORTED
+skipcheck:
+#endif
+
 #endif
 
 	rpc_dispatch(rqstp, transp, dtable, number_of(dtable),
