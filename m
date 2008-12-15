From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 1/3] nfs-utils: Enabling TCP wrappers
Date: Mon, 15 Dec 2008 11:58:05 -0500
Message-ID: <49468C9D.6070606@RedHat.com>
References: <49468BC7.2000907@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60780 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754060AbYLORAQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Dec 2008 12:00:16 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mBFH0GI2005985
	for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2008 12:00:16 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mBFH0Gna006980
	for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2008 12:00:16 -0500
Received: from [10.16.60.47] (xenhat.boston.devel.redhat.com [10.16.60.47])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id mBFH0FHg023254
	for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2008 12:00:15 -0500
In-Reply-To: <49468BC7.2000907-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 0e594fd44041c5c0562ed1dfc19d2c6d5d3ede0f
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Dec 15 10:52:01 2008 -0500

    When clients are define as IP addresses in /etc/hosts.deny,
    access is allow due to misinterpreting the return value of
    hosts_ctl(). This patch reworks that logic which closes
    that hole.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
index e4f453b..ceea5ce 100644
--- a/support/misc/tcpwrapper.c
+++ b/support/misc/tcpwrapper.c
@@ -86,6 +86,9 @@ int hosts_ctl(char *daemon, char *name, char *addr, char *user)
 #define log_client(addr, proc, prog) \
   logit(allow_severity, addr, proc, prog, "")
 
+#define ALLOW 1
+#define DENY 0
+
 int
 good_client(daemon, addr)
 char *daemon;
@@ -95,47 +98,44 @@ struct sockaddr_in *addr;
     char **sp;
     char *tmpname;
 
-    /* Check the IP address first. */
-    if (hosts_ctl(daemon, "", inet_ntoa(addr->sin_addr), ""))
-	return 1;
-
-    /* Check the hostname. */
-    hp = gethostbyaddr ((const char *) &(addr->sin_addr),
-			sizeof (addr->sin_addr), AF_INET);
-
-    if (!hp)
-	return 0;
-
-    /* must make sure the hostent is authorative. */
-    tmpname = alloca (strlen (hp->h_name) + 1);
-    strcpy (tmpname, hp->h_name);
-    hp = gethostbyname(tmpname);
-    if (hp) {
-	/* now make sure the "addr->sin_addr" is on the list */
+	/* First check the address. */
+	if (hosts_ctl(daemon, "", inet_ntoa(addr->sin_addr), "") == DENY)
+		return DENY;
+
+	/* Now do the hostname lookup */
+	hp = gethostbyaddr ((const char *) &(addr->sin_addr),
+		sizeof (addr->sin_addr), AF_INET);
+	if (!hp)
+		return DENY; /* never heard of it. misconfigured DNS? */
+
+	/* Make sure the hostent is authorative. */
+	tmpname = strdup(hp->h_name);
+	if (!tmpname)
+		return DENY;
+	hp = gethostbyname(tmpname);
+	free(tmpname);
+	if (!hp)
+		return DENY; /* never heard of it. misconfigured DNS? */
+
+	/* Now make sure the address is on the list */
 	for (sp = hp->h_addr_list ; *sp ; sp++) {
-	    if (memcmp(*sp, &(addr->sin_addr), hp->h_length)==0)
-		break;
+	    if (memcmp(*sp, &(addr->sin_addr), hp->h_length) == 0)
+			break;
 	}
 	if (!*sp)
-	    /* it was a FAKE. */
-	    return 0;
-    }
-    else
-	   /* never heard of it. misconfigured DNS? */
-	   return 0;
-
-   /* Check the official name first. */
-   if (hosts_ctl(daemon, hp->h_name, "", ""))
-	return 1;
-
-   /* Check aliases. */
-   for (sp = hp->h_aliases; *sp ; sp++) {
-	if (hosts_ctl(daemon, *sp, "", ""))
-	    return 1;
-   }
-
-   /* No match */
-   return 0;
+	    return DENY; /* it was a FAKE. */
+
+	/* Check the official name and address. */
+	if (hosts_ctl(daemon, hp->h_name, inet_ntoa(addr->sin_addr), "") == DENY)
+		return DENY;
+
+	/* Now check aliases. */
+	for (sp = hp->h_aliases; *sp ; sp++) {
+		if (hosts_ctl(daemon, *sp, inet_ntoa(addr->sin_addr), "") == DENY)
+	    	return DENY;
+	}
+
+   return ALLOW;
 }
 
 /* check_startup - additional startup code */
@@ -184,12 +184,13 @@ struct sockaddr_in *addr;
 u_long  proc;
 u_long  prog;
 {
-    if (!(from_local(addr) || good_client(daemon, addr))) {
-	log_bad_host(addr, proc, prog);
-	return (FALSE);
-    }
-    if (verboselog)
-	log_client(addr, proc, prog);
+	if (!(from_local(addr) || good_client(daemon, addr))) {
+		log_bad_host(addr, proc, prog);
+		return (FALSE);
+	}
+	if (verboselog)
+		log_client(addr, proc, prog);
+
     return (TRUE);
 }
 
