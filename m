Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42344 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751572Ab2D1L2Q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 28 Apr 2012 07:28:16 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@redhat.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/3] mountd: prepend '?' to make use_ipaddr clients self-describing
Date: Sat, 28 Apr 2012 07:28:12 -0400
Message-Id: <1335612492-22574-3-git-send-email-bfields@redhat.com>
In-Reply-To: <20120428112639.GA22396@fieldses.org>
References: <20120428112639.GA22396@fieldses.org>
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
"?" in the use_ipaddr case.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/auth.c  |   16 ++++++++++++----
 utils/mountd/cache.c |    2 +-
 2 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index 7aa00c4..f5bdfa7 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -112,15 +112,23 @@ auth_reload()
 	return counter;
 }
 
+static char *get_client_ipaddr_name(const struct sockaddr *caller)
+{
+	char buf[INET6_ADDRSTRLEN + 1];
+
+	buf[0] = '?';
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
@@ -133,12 +141,12 @@ get_client_hostname(const struct sockaddr *caller, struct addrinfo *ai,
 
 bool ipaddr_client_matches(char *dom, nfs_export *exp, struct addrinfo *ai)
 {
-	return use_ipaddr && client_check(exp->m_client, ai);
+	return (dom[0] == '?') && client_check(exp->m_client, ai);
 }
 
 bool namelist_client_matches(char *dom, nfs_export *exp, struct addrinfo *ai)
 {
-	return !use_ipaddr && client_member(dom, exp->m_client->m_hostname);
+	return (dom[0] != '?') && client_member(dom, exp->m_client->m_hostname);
 }
 
 bool client_matches(char *dom, nfs_export *exp, struct addrinfo *ai)
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 02d5313..0e270ba 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -551,7 +551,7 @@ static void nfsd_fh(FILE *f)
 
 	auth_reload();
 
-	if (use_ipaddr) {
+	if (dom[0] == '?') {
 		ai = lookup_client_addr(dom);
 		if (!ai)
 			goto out;
-- 
1.7.7.6

