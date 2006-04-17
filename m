From: Neil Brown <neilb@suse.de>
Subject: Re: ANNOUNCE: nfs-utils 1.0.8 (final)
Date: Mon, 17 Apr 2006 12:26:03 +1000
Message-ID: <17474.64699.722635.687707@cse.unsw.edu.au>
References: <17468.29136.672049.677855@cse.unsw.edu.au>
	<x6ek0018da@gzp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FVJRZ-00071c-RI
	for nfs@lists.sourceforge.net; Sun, 16 Apr 2006 19:26:25 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FVJRX-0006ON-7o
	for nfs@lists.sourceforge.net; Sun, 16 Apr 2006 19:26:25 -0700
To: "Gabor Z. Papp" <gzp@papp.hu>
In-Reply-To: message from Gabor Z. Papp on Friday April 14
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Friday April 14, gzp@papp.hu wrote:
> * Neil Brown <neilb@suse.de>:
> 
> | I have made a final release of  nfs-utils 1.0.8
> 
> I'm trying to compile it on Linux 2.4.32 using gcc 3.4.5, glibc 2.2.5
> 
> Probably my glibc is outdated, but works well. ;-)

Probably it is.  It doesn't work well enough for nfs-utils :-(

ifaddrs.h was added to glibc in July 2002, which I think was about
2.2.6.

I guess we should get 'configure' to check for ifaddrs, and exclude
the code that uses it if not available.

For now you can try backing out the following patch.

NeilBrown


Index: rmtcall.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/statd/rmtcall.c,v
retrieving revision 1.11
retrieving revision 1.12
diff -u -r1.11 -r1.12
--- rmtcall.c	28 Feb 2005 03:20:33 -0000	1.11
+++ rmtcall.c	6 Oct 2005 05:20:25 -0000	1.12
@@ -26,6 +26,7 @@
 #include <sys/socket.h>
 #include <sys/time.h>
 #include <netinet/in.h>
+#include <net/if.h>
 #include <arpa/inet.h>
 #include <rpc/rpc.h>
 #include <rpc/pmap_prot.h>
@@ -34,6 +35,7 @@
 #include <netdb.h>
 #include <string.h>
 #include <unistd.h>
+#include <ifaddrs.h>
 #include "sm_inter.h"
 #include "statd.h"
 #include "notlist.h"
@@ -90,7 +92,50 @@
 out_success:
 	return sockfd;
 }
-
+/*
+ * Using the NL_ADDR(lp), reset (if needed) the hostname
+ * that will be put in the SM_NOTIFY to the hostname
+ * that is associated with the network interface 
+ * that was monitored
+ */
+static void
+reset_my_name(notify_list *lp)
+{
+	struct ifaddrs *ifa = NULL, *ifap;
+	struct in_addr netaddr, tmp;
+	struct sockaddr_in *sin, *nsin;
+	struct hostent *hp;
+
+	netaddr.s_addr = inet_netof(NL_ADDR(lp));
+	if (getifaddrs(&ifa) >= 0) {
+		for (ifap = ifa; ifap != NULL; ifap = ifap->ifa_next) {
+			if (!(ifap->ifa_flags & IFF_UP))
+				continue;
+
+			note(N_DEBUG, "ifa_name %s\n", ifap->ifa_name);
+			if (ifap->ifa_addr == NULL)
+				continue;
+			if (ifap->ifa_addr->sa_family != AF_INET)
+				continue;
+
+			sin = (struct sockaddr_in *)ifap->ifa_addr;
+			nsin = (struct sockaddr_in *)ifap->ifa_netmask;
+			tmp.s_addr = sin->sin_addr.s_addr & nsin->sin_addr.s_addr;
+			if (memcmp(&tmp.s_addr, &netaddr.s_addr, sizeof(netaddr.s_addr)))
+				continue;
+			hp = gethostbyaddr((char *)&sin->sin_addr, 
+				sizeof(sin->sin_addr), AF_INET);
+			if (hp == NULL)
+				continue;
+			if (strcmp(NL_MY_NAME(lp), hp->h_name)) {
+				free(NL_MY_NAME(lp));
+				NL_MY_NAME(lp)= strdup(hp->h_name);
+				note(N_DEBUG, "NL_MY_NAME %s\n", NL_MY_NAME(lp));
+			}
+		}
+	}
+	return;
+}
 /*
  * Try to resolve host name for notify/callback request
  *
@@ -300,6 +345,7 @@
 {
 	struct sockaddr_in	sin;
 	struct status		new_status;
+	stat_chge		new_stat;
 	xdrproc_t		func;
 	void			*objp;
 	u_int32_t		proc, vers, prog;
@@ -326,9 +372,19 @@
 
 		/* Use source address for notify replies */
 		sin.sin_addr   = lp->addr;
+		/* 
+		 * Unless a static hostname has been defined
+		 * set the NL_MY_NAME(lp) hostname to the 
+		 * one associated with the network interface
+		 */
+		if (!(run_mode & STATIC_HOSTNAME))
+			reset_my_name(lp);
 
 		func = (xdrproc_t) xdr_stat_chge;
-		objp = &SM_stat_chge;
+		new_stat.state = MY_STATE;
+		new_stat.mon_name = NL_MY_NAME(lp);
+
+		objp = &new_stat;
 		break;
 	case NOTIFY_CALLBACK:
 		prog = NL_MY_PROG(lp);


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
