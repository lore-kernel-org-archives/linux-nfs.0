Return-Path: linux-nfs-owner@vger.kernel.org
Received: from vader.hardeman.nu ([95.142.160.32]:51288 "EHLO hardeman.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751025AbaLIFmF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Dec 2014 00:42:05 -0500
Subject: [PATCH 15/19] nfs-utils: gssd - cleanup read_service_info
From: David =?utf-8?b?SMOkcmRlbWFu?= <david@hardeman.nu>
To: linux-nfs@vger.kernel.org
Cc: SteveD@redhat.com
Date: Tue, 09 Dec 2014 06:41:55 +0100
Message-ID: <20141209054155.24756.64700.stgit@zeus.muc.hardeman.nu>
In-Reply-To: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
References: <20141209053828.24756.89941.stgit@zeus.muc.hardeman.nu>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There's a lot of fixed buffers in use here. Clean up the code and
add more documentation on the different formats that have been
used by the kernel.

Signed-off-by: David Härdeman <david@hardeman.nu>
---
 utils/gssd/gssd.c |  208 ++++++++++++++++++++++++++++-------------------------
 1 file changed, 110 insertions(+), 98 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 91e3e05..78b836d 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -83,6 +83,9 @@ int  root_uses_machine_creds = 1;
 unsigned int  context_timeout = 0;
 unsigned int  rpc_timeout = 5;
 char *preferred_realm = NULL;
+/* Avoid DNS reverse lookups on server names */
+static bool avoid_dns = true;
+
 
 TAILQ_HEAD(topdir_list_head, topdir) topdir_list;
 
@@ -120,9 +123,6 @@ struct topdir {
  *      and rescan the whole {rpc_pipefs} when this happens.
  */
 
-/* Avoid DNS reverse lookups on server names */
-static int avoid_dns = 1;
-
 /*
  * convert a presentation address string to a sockaddr_storage struct. Returns
  * true on success or false on failure.
@@ -136,8 +136,8 @@ static int avoid_dns = 1;
  * Microsoft "standard" of using the ipv6-literal.net domainname, but it's
  * not really feasible at present.
  */
-static int
-addrstr_to_sockaddr(struct sockaddr *sa, const char *node, const char *port)
+static bool
+gssd_addrstr_to_sockaddr(struct sockaddr *sa, const char *node, const char *port)
 {
 	int rc;
 	struct addrinfo *res;
@@ -150,9 +150,9 @@ addrstr_to_sockaddr(struct sockaddr *sa, const char *node, const char *port)
 	rc = getaddrinfo(node, port, &hints, &res);
 	if (rc) {
 		printerr(0, "ERROR: unable to convert %s|%s to sockaddr: %s\n",
-			 node, port, rc == EAI_SYSTEM ? strerror(errno) :
-						gai_strerror(rc));
-		return 0;
+			 node, port,
+			 rc == EAI_SYSTEM ? strerror(errno) : gai_strerror(rc));
+		return false;
 	}
 
 #ifdef IPV6_SUPPORTED
@@ -167,46 +167,41 @@ addrstr_to_sockaddr(struct sockaddr *sa, const char *node, const char *port)
 			printerr(0, "ERROR: address %s has non-zero "
 				    "sin6_scope_id!\n", node);
 			freeaddrinfo(res);
-			return 0;
+			return false;
 		}
 	}
 #endif /* IPV6_SUPPORTED */
 
 	memcpy(sa, res->ai_addr, res->ai_addrlen);
 	freeaddrinfo(res);
-	return 1;
+	return true;
 }
 
 /*
  * convert a sockaddr to a hostname
  */
 static char *
-get_servername(const char *name, const struct sockaddr *sa, const char *addr)
+gssd_get_servername(const char *name, const struct sockaddr *sa, const char *addr)
 {
 	socklen_t		addrlen;
 	int			err;
-	char			*hostname;
 	char			hbuf[NI_MAXHOST];
 	unsigned char		buf[sizeof(struct in6_addr)];
 
-	if (avoid_dns) {
+	while (avoid_dns) {
 		/*
 		 * Determine if this is a server name, or an IP address.
 		 * If it is an IP address, do the DNS lookup otherwise
 		 * skip the DNS lookup.
 		 */
-		int is_fqdn = 1;
 		if (strchr(name, '.') == NULL)
-			is_fqdn = 0; /* local name */
+			break; /* local name */
 		else if (inet_pton(AF_INET, name, buf) == 1)
-			is_fqdn = 0; /* IPv4 address */
+			break; /* IPv4 address */
 		else if (inet_pton(AF_INET6, name, buf) == 1)
-			is_fqdn = 0; /* IPv6 addrss */
+			break; /* IPv6 addrss */
 
-		if (is_fqdn) {
-			return strdup(name);
-		}
-		/* Sorry, cannot avoid dns after all */
+		return strdup(name);
 	}
 
 	switch (sa->sa_family) {
@@ -233,84 +228,113 @@ get_servername(const char *name, const struct sockaddr *sa, const char *addr)
 		return NULL;
 	}
 
-	hostname = strdup(hbuf);
-
-	return hostname;
+	return strdup(hbuf);
 }
 
-/* XXX buffer problems: */
-static int
-read_service_info(int fd, char **servicename, char **servername,
-		  int *prog, int *vers, char **protocol,
-		  struct sockaddr *addr) {
-#define INFOBUFLEN 256
-	char		buf[INFOBUFLEN + 1];
-	static char	server[128];
-	int		nbytes;
-	static char	service[128];
-	static char	address[128];
-	char		program[16];
-	char		version[16];
-	char		protoname[16];
-	char		port[128];
-	char		*p;
-	int		numfields;
-
-	*servicename = *servername = *protocol = NULL;
-
-	if ((nbytes = read(fd, buf, INFOBUFLEN)) == -1)
+static void
+gssd_read_service_info(int dirfd, struct clnt_info *clp)
+{
+	int fd;
+	FILE *info = NULL;
+	int numfields;
+	char *server = NULL;
+	char *service = NULL;
+	int program;
+	int version;
+	char *address = NULL;
+	char *protoname = NULL;
+	char *port = NULL;
+	char *servername = NULL;
+
+	fd = openat(dirfd, "info", O_RDONLY);
+	if (fd < 0) {
+		printerr(0, "ERROR: can't open %s/info: %s\n",
+			 clp->relpath, strerror(errno));
 		goto fail;
+	}
 
-	buf[nbytes] = '\0';
-
-	numfields = sscanf(buf,"RPC server: %127s\n"
-		   "service: %127s %15s version %15s\n"
-		   "address: %127s\n"
-		   "protocol: %15s\n",
-		   server,
-		   service, program, version,
-		   address,
-		   protoname);
-
-	if (numfields == 5) {
-		strcpy(protoname, "tcp");
-	} else if (numfields != 6) {
+	info = fdopen(fd, "r");
+	if (!info) {
+		printerr(0, "ERROR: can't fdopen %s/info: %s\n",
+			 clp->relpath, strerror(errno));
+		close(fd);
 		goto fail;
 	}
 
-	port[0] = '\0';
-	if ((p = strstr(buf, "port")) != NULL)
-		sscanf(p, "port: %127s\n", port);
-
-	/* get program, and version numbers */
-	*prog = atoi(program + 1); /* skip open paren */
-	*vers = atoi(version);
-
-	if (!addrstr_to_sockaddr(addr, address, port))
+	/*
+	 * Some history:
+	 *
+	 * The first three lines were added with rpc_pipefs in 2003-01-13.
+	 * (commit af2f003391786fb632889c02142c941b212ba4ff)
+	 * 
+	 * The 'protocol' line was added in 2003-06-11.
+	 * (commit 9bd741ae48785d0c0e75cf906ff66f893d600c2d)
+	 *
+	 * The 'port' line was added in 2007-09-26.
+	 * (commit bf19aacecbeebccb2c3d150a8bd9416b7dba81fe)
+	 */
+	numfields = fscanf(info,
+			   "RPC server: %ms\n"
+			   "service: %ms (%d) version %d\n"
+			   "address: %ms\n"
+			   "protocol: %ms\n"
+			   "port: %ms\n",
+			   &server,
+			   &service, &program, &version,
+			   &address,
+			   &protoname,
+			   &port);
+
+
+	switch (numfields) {
+	case 5:
+		protoname = strdup("tcp");
+		if (!protoname)
+			goto fail;
+		/* fall through */
+	case 6:
+		/* fall through */
+	case 7:
+		break;
+	default:
 		goto fail;
+	}
 
-	*servername = get_servername(server, addr, address);
-	if (*servername == NULL)
+	if (!gssd_addrstr_to_sockaddr((struct sockaddr *)&clp->addr,
+				 address, port ? port : ""))
 		goto fail;
 
-	nbytes = snprintf(buf, INFOBUFLEN, "%s@%s", service, *servername);
-	if (nbytes > INFOBUFLEN)
+	servername = gssd_get_servername(server, (struct sockaddr *)&clp->addr, address);
+	if (!servername)
 		goto fail;
 
-	if (!(*servicename = calloc(strlen(buf) + 1, 1)))
+	if (asprintf(&clp->servicename, "%s@%s", service, servername) < 0)
 		goto fail;
-	memcpy(*servicename, buf, strlen(buf));
 
-	if (!(*protocol = strdup(protoname)))
-		goto fail;
-	return 0;
+	clp->servername = servername;
+	clp->prog = program;
+	clp->vers = version;
+	clp->protocol = protoname;
+
+	goto out;
+
 fail:
-	printerr(0, "ERROR: failed to read service info\n");
-	free(*servername);
-	free(*servicename);
-	free(*protocol);
-	*servicename = *servername = *protocol = NULL;
-	return -1;
+	printerr(0, "ERROR: failed to parse %s/info\n", clp->relpath);
+	free(servername);
+	free(protoname);
+	clp->servicename = NULL;
+	clp->servername = NULL;
+	clp->prog = 0;
+	clp->vers = 0;
+	clp->protocol = NULL;
+out:
+	if (info)
+		fclose(info);
+
+	free(server);
+	free(service);
+	free(address);
+	free(port);
 }
 
 static void
@@ -475,20 +499,8 @@ gssd_scan_clnt(struct topdir *tdi, const char *name)
 		/* not fatal, files might appear later */
 		goto out;
 
-	if (clp->prog == 0) {
-		int infofd;
-
-		infofd = openat(clntfd, "info", O_RDONLY);
-		if (infofd < 0) {
-			printerr(0, "ERROR: can't open %s/info: %s\n",
-				 clp->relpath, strerror(errno));
-		} else {
-			read_service_info(infofd, &clp->servicename,
-					  &clp->servername, &clp->prog, &clp->vers,
-					  &clp->protocol, (struct sockaddr *) &clp->addr);
-			close(infofd);
-		}
-	}
+	if (clp->prog == 0)
+		gssd_read_service_info(clntfd, clp);
 
 out:
 	close(clntfd);
@@ -692,7 +704,7 @@ main(int argc, char *argv[])
 #endif
 				break;
 			case 'D':
-				avoid_dns = 0;
+				avoid_dns = false;
 				break;
 			default:
 				usage(argv[0]);

