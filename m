From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/3] nfs-utils: Enabling TCP wrappers
Date: Fri, 19 Dec 2008 12:00:14 -0500
Message-ID: <494BD31E.5040800@RedHat.com>
References: <49468BC7.2000907@RedHat.com> <1819C671-5353-45B4-A814-98B1B2A4BEB1@oracle.com> <494AABA1.4070006@RedHat.com> <04AA0955-045D-432B-B96D-4A21F4889F6D@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Olaf Kirch <okir@suse.de>,
	Linux NFS Mailing List <linux-nfs@vger.kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57452 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751816AbYLSRCb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Dec 2008 12:02:31 -0500
In-Reply-To: <04AA0955-045D-432B-B96D-4A21F4889F6D@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Chuck Lever wrote:
>> @@ -72,12 +74,29 @@ mount_dispatch(struct svc_req *rqstp, SVCXPRT
>> *transp)
>>     union mountd_results    result;
>>
>> #ifdef HAVE_TCP_WRAPPER
>> +#ifdef IPV6_SUPPORTED
>> +    static int once = 0;
>> +
>> +    if (svc_getcaller(transp)->sin_family != AF_INET) {
> 
> It's not clear to me that svc_getcaller() will ever return a non-AF_INET
> address.
> 
> Should we use svc_getcaller_netbuf() here instead?
> 
Here is the same patch using svc_getcaller_netbuf() instead
of svc_getcaller():

comments?

steved.

commit 87aef16ecab0ee3b0744d24b0e257e9d108ff4c0
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Dec 19 11:58:02 2008 -0500

    Skip the host access check when IPv6 is enabled and its an IPv6 address.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/utils/mountd/mount_dispatch.c b/utils/mountd/mount_dispatch.c
index f00c0c5..9223509 100644
--- a/utils/mountd/mount_dispatch.c
+++ b/utils/mountd/mount_dispatch.c
@@ -12,6 +12,8 @@
 #include "tcpwrapper.h"
 #endif
 
+#include <sys/syslog.h>
+
 #include "mountd.h"
 #include "rpcmisc.h"
 
@@ -72,12 +74,32 @@ mount_dispatch(struct svc_req *rqstp, SVCXPRT *transp)
 	union mountd_results	result;
 
 #ifdef HAVE_TCP_WRAPPER
+#ifdef IPV6_SUPPORTED
+	struct sockaddr *sa;
+	static int once = 0;
+
+	sa = (struct sockaddr *)svc_getcaller_netbuf(transp)->buf;
+	if (sa->sa_family != AF_INET) {
+		if (!once) {
+			syslog(LOG_WARNING, 
+				"No IPv6 support in Access Control Library (TCP Wrappers)"); 
+			once++;
+		}
+		goto skipcheck;
+	}
+#endif
+
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
diff --git a/utils/statd/statd.c b/utils/statd/statd.c
index 321f7a9..78bf6f8 100644
--- a/utils/statd/statd.c
+++ b/utils/statd/statd.c
@@ -88,6 +88,21 @@ extern void simulator (int, char **);
 static void 
 sm_prog_1_wrapper (struct svc_req *rqstp, register SVCXPRT *transp)
 {
+#ifdef IPV6_SUPPORTED
+	struct sockaddr *sa;
+	static int once = 0;
+
+	sa = (struct sockaddr *)svc_getcaller_netbuf(transp)->buf;
+	if (sa->sa_family != AF_INET) {
+		if (!once) {
+			syslog(LOG_WARNING, 
+				"No IPv6 support in Access Control Library (TCP Wrappers)"); 
+			once++;
+		}
+		goto skipcheck;
+	}
+#endif
+
 	/* remote host authorization check */
 	if (!check_default("statd", svc_getcaller(transp),
 				 rqstp->rq_proc, SM_PROG)) {
@@ -95,6 +110,10 @@ sm_prog_1_wrapper (struct svc_req *rqstp, register SVCXPRT *transp)
 		return;
 	}
 
+#ifdef IPV6_SUPPORTED
+skipcheck:
+#endif
+
 	sm_prog_1 (rqstp, transp);
 }
 
