Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49054 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727566AbeIMTSl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 13 Sep 2018 15:18:41 -0400
Subject: [PATCH 3/3] Remove the dependency on MIT Kerberos
From: David Howells <dhowells@redhat.com>
To: keyrings@vger.kernel.org
Cc: dhowells@redhat.com, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-security-module@vger.kernel.org
Date: Thu, 13 Sep 2018 15:08:59 +0100
Message-ID: <153684773962.10049.5588679375049584208.stgit@warthog.procyon.org.uk>
In-Reply-To: <153684771698.10049.12488548190876920608.stgit@warthog.procyon.org.uk>
References: <153684771698.10049.12488548190876920608.stgit@warthog.procyon.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Remove the dependency on MIT Kerberos as not everyone has it available.

With the "use best match" change to /sbin/request-key, the kafs-client
package can install a more specific handler for dns_resolver afsdb:*
requests in front of the default one.

This means that the dns resolver program only needs to look up DNS records
and can ignore any static kafs configuration.

Signed-off-by: David Howells <dhowells@redhat.com>
---

 Makefile      |    2 
 dns.afsdb.c   |  268 ++++++++-------------------------------------------------
 keyutils.spec |    2 
 3 files changed, 37 insertions(+), 235 deletions(-)

diff --git a/Makefile b/Makefile
index 5ce6746..96b5df7 100644
--- a/Makefile
+++ b/Makefile
@@ -153,7 +153,7 @@ request-key: request-key.o $(LIB_DEPENDENCY)
 
 key.dns_resolver: key.dns_resolver.o dns.afsdb.o $(LIB_DEPENDENCY)
 	$(CC) -L. $(CFLAGS) $(LDFLAGS) $(RPATH) -o $@ \
-		key.dns_resolver.o dns.afsdb.o -lkrb5 -lcom_err -lkeyutils -lresolv
+		key.dns_resolver.o dns.afsdb.o -lkeyutils -lresolv
 
 key.dns_resolver.o: key.dns_resolver.c key.dns.h
 dns.afsdb.o: dns.afsdb.c key.dns.h
diff --git a/dns.afsdb.c b/dns.afsdb.c
index 4e24815..064d9c8 100644
--- a/dns.afsdb.c
+++ b/dns.afsdb.c
@@ -36,179 +36,9 @@
  * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
  */
 #include "key.dns.h"
-#include <profile.h>
 
-static const char *afs_cellservdb[] = {
-	"/etc/kafs/cellservdb.conf",
-	"/usr/share/kafs/cellservdb.conf",
-	NULL
-};
-
-static profile_t afs_conf;
-static bool afs_cell_in_conf;
-static bool afs_prefer_dns;
 static unsigned long afs_ttl = ULONG_MAX;
 
-/*
- * Check that a configured address is valid and add it to the list of addresses
- * if okay.
- */
-static void afs_conf_add_address(char *addr)
-{
-	char *p, *q, *port = NULL;
-	size_t plen = 0;
-
-	if (!addr[0])
-		return;
-
-	if (addr[0] == '[') {
-		/* IPv6 */
-		struct in6_addr in6;
-
-		p = strchr(addr + 1, ']');
-		if (!p)
-			return;
-		*p = 0;
-		if (inet_pton(AF_INET6, addr + 1, &in6) == 0)
-			return;
-		*p++ = ']';
-	} else {
-		struct in_addr in;
-
-		p = strchr(addr, ':');
-		if (p)
-			*p = 0;
-		if (inet_pton(AF_INET, addr, &in) == 0)
-			return;
-		if (p)
-			*p = ':';
-	}
-
-	/* See if there's a port specifier as well */
-	if (p && *p) {
-		if (*p != ':')
-			return;
-		p++;
-		port = p;
-		plen = strlen(port);
-		if (plen > 5)
-			return;
-		strtoul(p, &q, 10);
-		if (q != port + plen)
-			return;
-	}
-
-	append_address_to_payload(addr);
-}
-
-/*
- * Parse the cell database file
- */
-static void afs_conf_find_cell(const char *cell)
-{
-	const char *filter[6];
-	char **list;
-	long res;
-	int tmp;
-
-	/* Parse the cell database file */
-	res = profile_init(afs_cellservdb, &afs_conf);
-	if (res != 0) {
-		afs_prefer_dns = true;
-		goto error;
-	}
-
-	/* Check to see if the named cell is in the list */
-	filter[0] = "cells";
-	filter[1] = cell;
-	filter[2] = NULL;
-
-	res = profile_get_subsection_names(afs_conf, filter, &list);
-	if (res != 0) {
-		afs_prefer_dns = true;
-		goto error;
-	}
-
-	if (!list[0]) {
-		info("cell not configured\n");
-		afs_cell_in_conf = false;
-		afs_prefer_dns = true;
-	} else {
-		afs_cell_in_conf = true;
-
-		/* Retrieve the use_dns value for the cell */
-		res = profile_get_boolean(afs_conf, "cells", cell, "use_dns", 1, &tmp);
-		if (res != 0) {
-			afs_prefer_dns = true;
-			goto error;
-		}
-
-		if (tmp)
-			afs_prefer_dns = true;
-		else
-			info("cell sets use_dns=no");
-	}
-
-	return;
-
-error:
-	_error("cellservdb: %s", error_message(res));
-}
-
-/*
- * Get list of server names from the config file.
- */
-static char **afs_conf_list_servers(const char *cell)
-{
-	const char *filter[] = {
-		"cells",
-		cell,
-		"servers",
-		NULL
-	};
-	char **servers;
-	long res;
-
-	res = profile_get_subsection_names(afs_conf, filter, &servers);
-	if (res != 0)
-		goto error;
-
-	return servers;
-
-error:
-	_error("cellservdb: %s", error_message(res));
-	return NULL;
-}
-
-/*
- * Get list of addresses for a server from the config file.
- */
-static int afs_conf_list_addresses(const char *cell, const char *server)
-{
-	const char *filter[] = {
-		"cells",
-		cell,
-		"servers",
-		server,
-		"address",
-		NULL
-	};
-	char **list, **p;
-	long res;
-
-	res = profile_get_values(afs_conf, filter, &list);
-	if (res != 0)
-		goto error;
-
-	for (p = list; *p; p++)
-		afs_conf_add_address(*p);
-	return 0;
-
-error:
-	_error("cellservdb: %s", error_message(res));
-	return -1;
-}
-
 /*
  *
  */
@@ -377,40 +207,6 @@ static void srv_hosts_to_addrs(ns_msg handle, ns_sect section)
 	info("ttl: %u", ttl);
 }
 
-/*
- * Instantiate the key.
- */
-static __attribute__((noreturn))
-void afs_instantiate(const char *cell)
-{
-	int ret;
-
-	/* set the key's expiry time from the minimum TTL encountered */
-	if (!debug_mode) {
-		ret = keyctl_set_timeout(key, afs_ttl);
-		if (ret == -1)
-			error("%s: keyctl_set_timeout: %m", __func__);
-	}
-
-	/* handle a lack of results */
-	if (payload_index == 0)
-		nsError(NO_DATA, cell);
-
-	/* must include a NUL char at the end of the payload */
-	payload[payload_index].iov_base = "";
-	payload[payload_index++].iov_len = 1;
-	dump_payload();
-
-	/* load the key with data key */
-	if (!debug_mode) {
-		ret = keyctl_instantiate_iov(key, payload, payload_index, 0);
-		if (ret == -1)
-			error("%s: keyctl_instantiate: %m", __func__);
-	}
-
-	exit(0);
-}
-
 /*
  * Look up an AFSDB record to get the VL server addresses.
  */
@@ -487,45 +283,53 @@ static int dns_query_VL_SRV(const char *cell)
 	return 0;
 }
 
+/*
+ * Instantiate the key.
+ */
+static __attribute__((noreturn))
+void afs_instantiate(const char *cell)
+{
+	int ret;
+
+	/* set the key's expiry time from the minimum TTL encountered */
+	if (!debug_mode) {
+		ret = keyctl_set_timeout(key, afs_ttl);
+		if (ret == -1)
+			error("%s: keyctl_set_timeout: %m", __func__);
+	}
+
+	/* handle a lack of results */
+	if (payload_index == 0)
+		nsError(NO_DATA, cell);
+
+	/* must include a NUL char at the end of the payload */
+	payload[payload_index].iov_base = "";
+	payload[payload_index++].iov_len = 1;
+	dump_payload();
+
+	/* load the key with data key */
+	if (!debug_mode) {
+		ret = keyctl_instantiate_iov(key, payload, payload_index, 0);
+		if (ret == -1)
+			error("%s: keyctl_instantiate: %m", __func__);
+	}
+
+	exit(0);
+}
+
 /*
  * Look up VL servers for AFS.
  */
 void afs_look_up_VL_servers(const char *cell, char *options)
 {
-	char **servers;
-
 	/* Is the IP address family limited? */
 	if (strcmp(options, "ipv4") == 0)
 		mask = INET_IP4_ONLY;
 	else if (strcmp(options, "ipv6") == 0)
 		mask = INET_IP6_ONLY;
 
-	afs_conf_find_cell(cell);
-
-	if (afs_prefer_dns) {
-		if (dns_query_VL_SRV(cell) == 0)
-			goto instantiate;
-		if (dns_query_AFSDB(cell) == 0)
-			goto instantiate;
-	}
-
-	if (!afs_cell_in_conf)
-		goto instantiate; /* Record a negative result */
-
-	servers = afs_conf_list_servers(cell);
-	if (!servers) {
-		debug("conf: no servers");
-		goto instantiate; /* Record a negative result */
-	}
-
-	for (; *servers; servers++) {
-		char *server = *servers;
-
-		debug("conf server %s", server);
-		if (dns_resolver(server, NULL) < 0)
-			afs_conf_list_addresses(cell, server);
-	}
+	if (dns_query_VL_SRV(cell) != 0)
+		dns_query_AFSDB(cell);
 
-instantiate:
 	afs_instantiate(cell);
 }
diff --git a/keyutils.spec b/keyutils.spec
index 4303f94..544fe7c 100644
--- a/keyutils.spec
+++ b/keyutils.spec
@@ -17,9 +17,7 @@ Source0: http://people.redhat.com/~dhowells/keyutils/keyutils-%{version}.tar.bz2
 
 BuildRequires: gcc
 BuildRequires: glibc-kernheaders >= 2.4-9.1.92
-BuildRequires: krb5-devel
 Requires: %{name}-libs%{?_isa} = %{version}-%{release}
-Requires: krb5-libs
 
 %description
 Utilities to control the kernel key management facility and to provide
