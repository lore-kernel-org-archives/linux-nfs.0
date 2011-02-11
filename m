Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:45624 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750699Ab1BKK3l (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 05:29:41 -0500
From: Jan Engelhardt <jengelh@medozas.de>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] nss: allow domainless lookups
Date: Fri, 11 Feb 2011 11:29:35 +0100
Message-Id: <1297420176-24960-3-git-send-email-jengelh@medozas.de>
In-Reply-To: <1297420176-24960-1-git-send-email-jengelh@medozas.de>
References: <1297420176-24960-1-git-send-email-jengelh@medozas.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

When the Solaris NFS server itself has no name mapping for a given UID,
it will export plain UIDs without a domain part. I would still like to
be able to have these resolved locally somehow.

One reason for plain UIDs to be exported is that the file server just
has no name for them because the admin did not link it with the LDAP
tree. A second case would be when a file server stores files for
multiple domains with colliding UIDs, in which case the wrong name would
be exported for at least one user's files.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 nss.c |   21 +++++++++++++++++++++
 1 files changed, 21 insertions(+), 0 deletions(-)

diff --git a/nss.c b/nss.c
index 04aff19..095794c 100644
--- a/nss.c
+++ b/nss.c
@@ -37,7 +37,9 @@
 #include <sys/types.h>
 #include <errno.h>
 #include <unistd.h>
+#include <stdbool.h>
 #include <stdlib.h>
+#include <stdio.h>
 #include <string.h>
 #include <pwd.h>
 #include <grp.h>
@@ -160,6 +162,14 @@ struct pwbuf {
 	char buf[1];
 };
 
+static bool only_digits(const char *s)
+{
+	for (; *s != '\0'; ++s)
+		if (!isdigit(*s))
+			return false;
+	return true;
+}
+
 static struct passwd *nss_getpwnam(const char *name, const char *domain, int *err_p)
 {
 	struct passwd *pw;
@@ -172,6 +182,16 @@ static struct passwd *nss_getpwnam(const char *name, const char *domain, int *er
 	if (buf == NULL)
 		goto err;
 
+	if (strchr(name, '@') == NULL && only_digits(name)) {
+		char *end;
+		long uid = strtoul(name, &end, 10);
+		err = getpwuid_r(uid, &buf->pwbuf, buf->buf, buflen, &pw);
+		IDMAP_LOG(0, ("%s: pure UID %ld lookup (result=%d,errno=%s)\n",
+			__func__, uid, err, strerror(errno)));
+		if (err == 0)
+			goto done;
+	}
+
 	err = EINVAL;
 	localname = strip_domain(name, domain);
 	IDMAP_LOG(4, ("nss_getpwnam: name '%s' domain '%s': "
@@ -189,6 +209,7 @@ static struct passwd *nss_getpwnam(const char *name, const char *domain, int *er
 			("nss_getpwnam: name '%s' not found in domain '%s'\n",
 			localname, domain));
 	free(localname);
+done:
 	if (err == 0 && pw != NULL) {
 		*err_p = 0;
 		return pw;
-- 
1.7.1

