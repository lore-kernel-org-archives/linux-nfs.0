From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/7] libexport.a: Replace matchhostname()
Date: Mon, 21 Jun 2010 12:55:17 -0400
Message-ID: <20100621165517.4771.53255.stgit@ellison.1015granger.net>
References: <20100621165114.4771.51575.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60812 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758107Ab0FUQzU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jun 2010 12:55:20 -0400
Received: by mail-iw0-f174.google.com with SMTP id 36so1063318iwn.19
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jun 2010 09:55:20 -0700 (PDT)
In-Reply-To: <20100621165114.4771.51575.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

So that exportfs can eventually support IPv6 addresses, copy statd's
getaddrinfo(3)-based matchhostname to exportfs, with adjustments for
dealing with export wildcards and netgroups.  Until exportfs has full
IPv6 support, however, we want to ensure that IPv6 addresses continue
to remain blocked in the address comparison code used by exportfs.  At
a later point we'll replace much of this with the generic functions
in sockaddr.h.

Since it contains special logic for handling wildcard and netgroups,
this function is specialized for exportfs, and does not belong in
one of the shared libraries.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/misc.h    |    2 -
 utils/exportfs/exportfs.c |   78 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 78 insertions(+), 2 deletions(-)

diff --git a/support/include/misc.h b/support/include/misc.h
index 9a1b25d..e817bc5 100644
--- a/support/include/misc.h
+++ b/support/include/misc.h
@@ -15,8 +15,6 @@
 int	randomkey(unsigned char *keyout, int len);
 int	weakrandomkey(unsigned char *keyout, int len);
 
-int	matchhostname(const char *h1, const char *h2); 
-
 struct hostent;
 struct hostent	*hostent_dup(struct hostent *hp);
 struct hostent	*get_hostent (const char *addr, int len, int type);
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index 0070b54..edc1625 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -15,6 +15,7 @@
 #include <sys/vfs.h>
 #include <sys/stat.h>
 #include <unistd.h>
+#include <stdbool.h>
 #include <stdlib.h>
 #include <string.h>
 #include <stdarg.h>
@@ -36,6 +37,7 @@ static void	dump(int verbose);
 static void	error(nfs_export *exp, int err);
 static void	usage(void);
 static void	validate_export(nfs_export *exp);
+static int	matchhostname(const char *hostname1, const char *hostname2);
 
 int
 main(int argc, char **argv)
@@ -421,6 +423,82 @@ validate_export(nfs_export *exp)
 	}
 }
 
+static _Bool
+is_hostname(const char *sp)
+{
+	if (*sp == '\0' || *sp == '@')
+		return false;
+
+	for (; *sp != '\0'; sp++) {
+		if (*sp == '*' || *sp == '?' || *sp == '[' || *sp == '/')
+			return false;
+		if (*sp == '\\' && sp[1] != '\0')
+			sp++;
+	}
+
+	return true;
+}
+
+static _Bool
+compare_sockaddrs4(const struct sockaddr *sa1, const struct sockaddr *sa2)
+{
+	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sa1;
+	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sa2;
+	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
+}
+
+static _Bool
+compare_sockaddrs(const struct sockaddr *sa1, const struct sockaddr *sa2)
+{
+	if (sa1->sa_family == sa2->sa_family)
+		switch (sa1->sa_family) {
+		case AF_INET:
+			return compare_sockaddrs4(sa1, sa2);
+		}
+
+	return false;
+}
+
+static int
+matchhostname(const char *hostname1, const char *hostname2)
+{
+	struct addrinfo *results1 = NULL, *results2 = NULL;
+	struct addrinfo *ai1, *ai2;
+	int result = 0;
+
+	if (strcasecmp(hostname1, hostname2) == 0)
+		return 1;
+
+	/*
+	 * Don't pass export wildcards or netgroup names to DNS
+	 */
+	if (!is_hostname(hostname1) || !is_hostname(hostname2))
+		return 0;
+
+	results1 = host_addrinfo(hostname1);
+	if (results1 == NULL)
+		goto out;
+	results2 = host_addrinfo(hostname2);
+	if (results2 == NULL)
+		goto out;
+
+	if (strcasecmp(results1->ai_canonname, results2->ai_canonname) == 0) {
+		result = 1;
+		goto out;
+	}
+
+	for (ai1 = results1; ai1 != NULL; ai1 = ai1->ai_next)
+		for (ai2 = results2; ai2 != NULL; ai2 = ai2->ai_next)
+			if (compare_sockaddrs(ai1->ai_addr, ai2->ai_addr)) {
+				result = 1;
+				break;
+			}
+
+out:
+	freeaddrinfo(results1);
+	freeaddrinfo(results2);
+	return result;
+}
 
 static char
 dumpopt(char c, char *fmt, ...)

