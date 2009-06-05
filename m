From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] nfs-utils: Set all verbose types in gssd daemons.
Date: Fri, 05 Jun 2009 11:25:50 -0400
Message-ID: <4A2938FE.2070903@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55207 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750893AbZFEP2u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 11:28:50 -0400
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n55FSrLF025998
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jun 2009 11:28:53 -0400
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n55FSqVC024569
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jun 2009 11:28:52 -0400
Received: from xenhat.boston.devel.redhat.com (vpn-10-18.bos.redhat.com [10.16.10.18])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n55FSpcT028150
	for <linux-nfs@vger.kernel.org>; Fri, 5 Jun 2009 11:28:51 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I founded it very handy to have library verbosity enabled
when verbosity is enabled on either the gssd or 
svcgssd daemons. 

So this patch will set the verbosity level in the 
librpcsecgss library and in the libnfsidmapd (for svcgssd) 
when verbosity level is set by the '-v' flag it on
either daemon.

Signed-off-by: Steve Dickson <steved@redhat.com>
----------------------------------------------

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index f6949db..40a2b4d 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -171,6 +171,8 @@ main(int argc, char *argv[])
 
 	initerr(progname, verbosity, fg);
 #ifdef HAVE_AUTHGSS_SET_DEBUG_LEVEL
+	if (verbosity && rpc_verbosity == 0)
+		rpc_verbosity = verbosity;
 	authgss_set_debug_level(rpc_verbosity);
 #else
         if (rpc_verbosity > 0)
diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 6ca0e8d..69d2a69 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -208,6 +208,8 @@ main(int argc, char *argv[])
 
 	initerr(progname, verbosity, fg);
 #ifdef HAVE_AUTHGSS_SET_DEBUG_LEVEL
+	if (verbosity && rpc_verbosity == 0)
+		rpc_verbosity = verbosity;
 	authgss_set_debug_level(rpc_verbosity);
 #else
 	if (rpc_verbosity > 0)
@@ -215,6 +217,8 @@ main(int argc, char *argv[])
 			    "support setting debug level\n");
 #endif
 #ifdef HAVE_NFS4_SET_DEBUG
+		if (verbosity && idmap_verbosity == 0)
+			idmap_verbosity = verbosity;
         nfs4_set_debug(idmap_verbosity, NULL);
 #else
 	if (idmap_verbosity > 0)
