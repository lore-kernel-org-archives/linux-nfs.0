Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:36419 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758289Ab2EBBni (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 May 2012 21:43:38 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        NeilBrown <neilb@suse.de>, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] mountd: prepend '$' to make use_ipaddr clients self-describing
Date: Tue,  1 May 2012 21:43:34 -0400
Message-Id: <1335923014-2789-3-git-send-email-bfields@redhat.com>
In-Reply-To: <20120502014155.GA2684@fieldses.org>
References: <20120502014155.GA2684@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Mountd is responsible for filling three interrelated kernel caches:

	- auth_unix_ip maps an incoming ip addresses to a "domain".
	- nfsd_fh maps (domain, filehandle-fragment) pairs to paths.
	- nfsd_export maps (domain, path) pairs to export options.

Note that each export is assocated with a "client" string--the part
before the parentheses in an /etc/export line--which may be a domain
name, a netgroup, etc.

The "domain" string in the above three caches may be either:

	- in the !use_ipaddr case, a comma-separated list of client
	  strings.
	- in the use_ipaddr case, an ip address.

In the former case, mountd does the hard work of matching an ip address
to the clients when doing the auth_unix_ip mapping.  In the latter case,
it delays that until the nfsd_fh or nfsd_export upcall.

We're currently depending on being able to flush the kernel caches
completely when switching between the use_ipaddr and !use_ipaddr cases.
However, the kernel's cache-flushing doesn't really provide reliable
guarantees on return; it's still possible we could see nfsd_fh or
nfsd_export upcalls with the old domain-type after flushing.

So, instead, make the two domain types self-describing by prepending a
"$" in the use_ipaddr case.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/auth.c   |   14 +++++++++++---
 utils/mountd/cache.c  |    8 +++++---
 utils/mountd/mountd.h |    5 +++++
 3 files changed, 21 insertions(+), 6 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 1ed9a4b..15da54c 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -112,15 +112,23 @@ auth_reload()
 	return counter;
 }
 
+static char *get_client_ipaddr_name(const struct sockaddr *caller)
+{
+	char buf[INET6_ADDRSTRLEN + 1];
+
+	buf[0] = '$';
+	host_ntop(caller, buf + 1, sizeof(buf) - 1);
+	return strdup(buf);
+}
+
 static char *
 get_client_hostname(const struct sockaddr *caller, struct addrinfo *ai,
 		enum auth_error *error)
 {
-	char buf[INET6_ADDRSTRLEN];
 	char *n;
 
 	if (use_ipaddr)
-		return strdup(host_ntop(caller, buf, sizeof(buf)));
+		return get_client_ipaddr_name(caller);
 	n = client_compose(ai);
 	*error = unknown_host;
 	if (!n)
@@ -143,7 +151,7 @@ bool namelist_client_matches(nfs_export *exp, char *dom)
 
 bool client_matches(nfs_export *exp, char *dom, struct addrinfo *ai)
 {
-	if (use_ipaddr)
+	if (is_ipaddr_client(dom))
 		return ipaddr_client_matches(exp, ai);
 	return namelist_client_matches(exp, dom);
 }
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 6cc58d2..1833b3a 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -551,7 +551,7 @@ static void nfsd_fh(FILE *f)
 
 	auth_reload();
 
-	if (use_ipaddr) {
+	if (dom[0] == '$') {
 		ai = lookup_client_addr(dom);
 		if (!ai)
 			goto out;
@@ -587,7 +587,8 @@ static void nfsd_fh(FILE *f)
 				next_exp = exp->m_next;
 			}
 
-			if (!use_ipaddr && !namelist_client_matches(exp, dom))
+			if (!is_ipaddr_client(dom)
+					&& !namelist_client_matches(exp, dom))
 				continue;
 			if (exp->m_export.e_mountpoint &&
 			    !is_mountpoint(exp->m_export.e_mountpoint[0]?
@@ -597,7 +598,8 @@ static void nfsd_fh(FILE *f)
 
 			if (!match_fsid(&parsed, exp, path))
 				continue;
-			if (use_ipaddr && !ipaddr_client_matches(exp, ai))
+			if (is_ipaddr_client(dom)
+					&& !ipaddr_client_matches(exp, ai))
 				continue;
 			if (!found || subexport(&exp->m_export, found)) {
 				found = &exp->m_export;
diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
index c969a27..6d358a7 100644
--- a/utils/mountd/mountd.h
+++ b/utils/mountd/mountd.h
@@ -60,4 +60,9 @@ bool ipaddr_client_matches(nfs_export *exp, struct addrinfo *ai);
 bool namelist_client_matches(nfs_export *exp, char *dom);
 bool client_matches(nfs_export *exp, char *dom, struct addrinfo *ai);
 
+static inline bool is_ipaddr_client(char *dom)
+{
+	return dom[0] == '$';
+}
+
 #endif /* MOUNTD_H */
-- 
1.7.7.6

