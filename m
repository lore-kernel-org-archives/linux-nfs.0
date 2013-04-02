Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31691 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761435Ab3DBPSs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Apr 2013 11:18:48 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r32FIlWs028243
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 2 Apr 2013 11:18:47 -0400
Message-ID: <515AF6DB.4000708@RedHat.com>
Date: Tue, 02 Apr 2013 11:18:51 -0400
From: Steve Dickson <SteveD@redhat.com>
MIME-Version: 1.0
To: Simo Sorce <simo@redhat.com>
CC: linux-nfs <linux-nfs@vger.kernel.org>, Jeffrey Layton <jlayton@redhat.com>
Subject: Re: [PATCH] Avoid PTR lookups when possible
References: <1364910351.2660.1243.camel@willson.li.ssimo.org>
In-Reply-To: <1364910351.2660.1243.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 02/04/13 09:45, Simo Sorce wrote:
> The attached patch adds a new command line switch to rpc.gssd to avoid
> PTR resolution when possible.
> 
> The current code *depends* on PTR resolution for GSSAPI authentication
> and this is *bad*.
> It imposes an annoying, and unnecessary, constraint on the correctness
> of DNS resolution, which prevents mounts from working in networks where
> the PTR record cannot be easily controlled (for example networks where
> the forward name is reasonable while the PTR is set to some artificial
> name based on the IP address or so that is not the canonical name or
> where no PTR exist at all).
> 
> Depending on PTR resolution for GSSAPI is also very bad practice because
> it opens up DNS spoofing attacks where an attacker can try to redirect a
> user to the wrong server fooling mutual authentication, and induce a
> user to trust improper data or disclose (by copying on the impostor
> server) data that should be confidential.
> 
> Ideally people will always use the -N switch, however I added an actual
> switch to avoid breaking existing configuration where someone may
> intentionally or inadvertently be using multiple A names instead of
> using CNAMEs but relying on PTR records to find the "canonical name".
> 
> It would be probably nice to switch the behavior on by default in
> future.
> 
> Jeff in CC as he also implemented a similar switch for cifs.upcall
> (there it is called -t|--trust-dns, but in rpc.gsssd -t is already
> taken ...).
> 
A nits..  
>>>> Please do not post patches as attachments. In-lining them in 
>>>> the email makes it easier to review... 

>From 53dade1e5d22eee06a08ace2684257292514cb49 Mon Sep 17 00:00:00 2001
From: Simo Sorce <simo@redhat.com>
Date: Mon, 1 Apr 2013 21:00:55 -0400
Subject: [PATCH] Avoid forced reverse resolution for server name

A NFS client should be able to work properly even if the PTR record for the
server is not set. there is no excuse to forcefully prevent that from working
when it can.
So, use some heuristics to see if the server is a FQDN or an IP address.
If it is an IP address or a shortname (no '.' in name) then do a PTR lookup,
otherwise avoid it.

This is enabled by the new -N flag which is off by default for now, ideally we
will turn this on by default after a transition period.
---
 utils/gssd/gss_util.h  |  2 ++
 utils/gssd/gssd.c      |  4 +++-
 utils/gssd/gssd.man    |  7 ++++++-
 utils/gssd/gssd_proc.c | 31 +++++++++++++++++++++++++++----
 4 files changed, 38 insertions(+), 6 deletions(-)

diff --git a/utils/gssd/gss_util.h b/utils/gssd/gss_util.h
index aa9f77806075f9ab67a7763a75a010369ba2d1b9..663fb0998bede6144118f890b9311ee8687176e3 100644
--- a/utils/gssd/gss_util.h
+++ b/utils/gssd/gss_util.h
@@ -52,4 +52,6 @@ int gssd_check_mechs(void);
 		gss_krb5_set_allowable_enctypes(min, cred, num, types)
 #endif
 
+extern int avoid_ptr;
+
 #endif /* _GSS_UTIL_H_ */
diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 0be251781bacaa562270f773341126bc95ca6b45..2a98e94812a662f0fd868fce8dc3419f65648a4d 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -85,7 +85,7 @@ sig_hup(int signal)
 static void
 usage(char *progname)
 {
-	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm]\n",
+	fprintf(stderr, "usage: %s [-f] [-l] [-M] [-n] [-v] [-r] [-p pipefsdir] [-k keytab] [-d ccachedir] [-t timeout] [-R preferred realm] [-N]\n",
>>>> Could please move the [-N] in front of [-n]... At lease that that point in the list things
>>>> are in alphabetical order

 		progname);
 	exit(1);
 }
@@ -150,6 +150,8 @@ main(int argc, char *argv[])
 				errx(1, "Encryption type limits not supported by Kerberos libraries.");
 #endif
 				break;
+			case 'N':
+				avoid_ptr = 1;
 			default:
 				usage(argv[0]);
 				break;
diff --git a/utils/gssd/gssd.man b/utils/gssd/gssd.man
index 79d9bf91ac6b976c57d167e60d07f828a3ff5b1f..09253b43ba6502202c17bbc84bd6bcf9dec85e9b 100644
--- a/utils/gssd/gssd.man
+++ b/utils/gssd/gssd.man
@@ -8,7 +8,7 @@
 rpc.gssd \- RPCSEC_GSS daemon
 .SH SYNOPSIS
 .B rpc.gssd
-.RB [ \-fMnlvr ]
+.RB [ \-fMnlvrN ]
>>>>> Same as above....

 .RB [ \-k
 .IR keytab ]
 .RB [ \-p
@@ -266,6 +266,11 @@ new kernel contexts to be negotiated after
 seconds, which allows changing Kerberos tickets and identities frequently.
 The default is no explicit timeout, which means the kernel context will live
 the lifetime of the Kerberos service ticket used in its creation.
+.TP
+.B -N
+Tries to avoid PTR lookups for resolving the server name, if the name used at 
+mount looks like a Fully Qualified Domain Name. This is import to avoid GSSAPI 
+issues when PTR records are set and to help avoid some kind of MITM attack.
>>>> I'm sorry this does not make much sense. Can we use more meaningful terms
>>>> like DNS lookups or DNS PTR lookups... something not so condensed 
>>>>
>>>>> Also, could you please talk about who will be needing this new flag and how will 
>>>>> they know they needed?

 .SH SEE ALSO
 .BR rpc.svcgssd (8),
 .BR kerberos (1),
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index ea01e92e4565670b97dea1a936d2f0dbdc7c4610..0a584d2084d626ee98a8ad6ff56da95464b882fe 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -67,6 +67,7 @@
 #include <errno.h>
 #include <gssapi/gssapi.h>
 #include <netdb.h>
+#include <ctype.h>
 
 #include "gssd.h"
 #include "err_util.h"
@@ -107,6 +108,8 @@ struct pollfd * pollarray;
 
 unsigned long pollsize;  /* the size of pollaray (in pollfd's) */
 
+int avoid_ptr = 0;
+
 /*
  * convert a presentation address string to a sockaddr_storage struct. Returns
  * true on success or false on failure.
@@ -165,12 +168,32 @@ addrstr_to_sockaddr(struct sockaddr *sa, const char *node, const char *port)
  * convert a sockaddr to a hostname
  */
 static char *
-sockaddr_to_hostname(const struct sockaddr *sa, const char *addr)
+get_servername(const char *name, const struct sockaddr *sa, const char *addr)
 {
 	socklen_t		addrlen;
 	int			err;
 	char			*hostname;
 	char			hbuf[NI_MAXHOST];
+	const char		*p;
+	int			do_ptr_lookup = 0;
+
+	if (avoid_ptr) {
+		/* try to determine if this is FQDN, or an IP address with
+		 * basic heuristics, if they fail try a PTR lookup */
+		p = strrchr(name, '.');
+		if (!p || strchr(name, ':'))
+			do_ptr_lookup = 1; /* non-FQDN, or IPv6 */
+		else {
+			for (++p; *p; p++)
+				if (!isdigit(*p))
+					break;
+			if (!*p)
+				do_ptr_lookup = 1; /* IPv4 */
+		}
+		if (!do_ptr_lookup) {
+			return strdup(name);
+		}
+	}
Is this "reinventing the wheel"? ;-) Don't we already have a why of determining a FQDN? 
Maybe not...


steved.
  
 
 	switch (sa->sa_family) {
 	case AF_INET:
@@ -208,7 +231,7 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 		  struct sockaddr *addr) {
 #define INFOBUFLEN 256
 	char		buf[INFOBUFLEN + 1];
-	static char	dummy[128];
+	static char	server[128];
 	int		nbytes;
 	static char	service[128];
 	static char	address[128];
@@ -236,7 +259,7 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 		   "service: %127s %15s version %15s\n"
 		   "address: %127s\n"
 		   "protocol: %15s\n",
-		   dummy,
+		   server,
 		   service, program, version,
 		   address,
 		   protoname);
@@ -258,7 +281,7 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
 	if (!addrstr_to_sockaddr(addr, address, port))
 		goto fail;
 
-	*servername = sockaddr_to_hostname(addr, address);
+	*servername = get_servername(server, addr, address);
 	if (*servername == NULL)
 		goto fail;
 
-- 
1.8.1.4



