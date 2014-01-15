Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47741 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751391AbaAOVlg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jan 2014 16:41:36 -0500
Received: from int-mx10.intmail.prod.int.phx2.redhat.com (int-mx10.intmail.prod.int.phx2.redhat.com [10.5.11.23])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id s0FLfZe4003973
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 15 Jan 2014 16:41:36 -0500
Subject: [PATCH] Fix crdential sourcing with new setuid behavior in rpc.gssd
From: Simo Sorce <simo@redhat.com>
To: Steve Dickson <SteveD@redhat.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: multipart/mixed; boundary="=-/OqEpO0XMhIZuh2wHjah"
Date: Wed, 15 Jan 2014 16:41:34 -0500
Message-ID: <1389822094.26102.488.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--=-/OqEpO0XMhIZuh2wHjah
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

The attached patch makes some edge cases work where the name returned by
getpwnam() does not match the data in the credential cache without
having to fall back to trolling the ccaches on the file systems.

It also allow KEYRING (or any other future type) based ccaches work
which otherwise don't as there is not code for trolling any other ccache
type then FILE or DIR.

[Found testing RHEL7 beta with keyring caches into a FreeIPA/RH-Idm
Domain trusting a Windows AD Domain, with a Windows user logged into the
Linux client.]

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

--=-/OqEpO0XMhIZuh2wHjah
Content-Disposition: attachment; filename="0001-Improve-first-attempt-at-acquiring-GSS-credentials.patch"
Content-Type: text/x-patch; name="0001-Improve-first-attempt-at-acquiring-GSS-credentials.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 421f66b1cd0b031ef843f7680f463027904b93ca Mon Sep 17 00:00:00 2001
From: Simo Sorce <simo@redhat.com>
Date: Wed, 15 Jan 2014 16:01:49 -0500
Subject: [PATCH] Improve first attempt at acquiring GSS credentials

Since now rpc.gssd is swithing uid before attempting to acquire
credentials, we do not need to pass in the special uid-as-a-string name
to gssapi, because the process is already running under the user's
credentials.

By making this optional we can fix a class of false negatives where the
user name does not match the actual ccache credentials and the ccache
type used is not one of the only 2 supported explicitly by rpc.gssd by the
fallback trolling done later.

Signed-off-by: Simo Sorce <simo@redhat.com>
---
 utils/gssd/krb5_util.c | 32 ++++++++++++++++++--------------
 1 file changed, 18 insertions(+), 14 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 697d1d2e79db0cc38160ea4772d3af3a9b7d6c21..7db5baf4e4bea75ed7beebd2103afbc291efb641 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -1383,24 +1383,28 @@ gssd_acquire_user_cred(uid_t uid, gss_cred_id_t *gss_cred)
 {
 	OM_uint32 maj_stat, min_stat;
 	gss_buffer_desc name_buf;
-	gss_name_t name;
+	gss_name_t name = GSS_C_NO_NAME;
 	char buf[11];
 	int ret;
 
-	ret = snprintf(buf, 11, "%u", uid);
-	if (ret < 1 || ret > 10) {
-		return -1;
-	}
-	name_buf.value = buf;
-	name_buf.length = ret + 1;
+	/* the follwing is useful only if change_identity() in
+	 * process_krb5_upcall() failed to change uids */
+	if (getuid() == 0) {
+		ret = snprintf(buf, 11, "%u", uid);
+		if (ret < 1 || ret > 10) {
+			return -1;
+		}
+		name_buf.value = buf;
+		name_buf.length = ret + 1;
 
-	maj_stat = gss_import_name(&min_stat, &name_buf,
-				   GSS_C_NT_STRING_UID_NAME, &name);
-	if (maj_stat != GSS_S_COMPLETE) {
-		if (get_verbosity() > 0)
-			pgsserr("gss_import_name",
-				maj_stat, min_stat, &krb5oid);
-		return -1;
+		maj_stat = gss_import_name(&min_stat, &name_buf,
+					   GSS_C_NT_STRING_UID_NAME, &name);
+		if (maj_stat != GSS_S_COMPLETE) {
+			if (get_verbosity() > 0)
+				pgsserr("gss_import_name",
+					maj_stat, min_stat, &krb5oid);
+			return -1;
+		}
 	}
 
 	ret = gssd_acquire_krb5_cred(name, gss_cred);
-- 
1.8.4.2


--=-/OqEpO0XMhIZuh2wHjah--

