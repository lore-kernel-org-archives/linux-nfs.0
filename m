Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:54288 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756689Ab1AMThl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Jan 2011 14:37:41 -0500
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.13.8/8.13.8) with ESMTP id p0DJbfRJ014262
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 14:37:41 -0500
Received: from bighat.boston.devel.redhat.com (bighat.boston.devel.redhat.com [10.16.60.55])
	by int-mx02.intmail.prod.int.phx2.redhat.com (8.13.8/8.13.8) with ESMTP id p0DJbelo004960
	for <linux-nfs@vger.kernel.org>; Thu, 13 Jan 2011 14:37:41 -0500
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Improve debugging in svcgssd
Date: Thu, 13 Jan 2011 14:37:37 -0500
Message-Id: <1294947457-14274-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Added in gss_display_error() which translates the GSS error into the
actual GSS macro name. Currently only the translation of these errors
are logged. Since those translations are buried deep in the kerberos
library code, having the actual GSS macro name makes it easier to
follow the code.

Moved the nfs4_init_name_mapping() call into main() so if debug is
enabled the DNS name and realms will be logged during start up.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/gss_util.c     |   81 +++++++++++++++++++++++++++++++++++++++++++-
 utils/gssd/svcgssd.c      |    1 +
 utils/gssd/svcgssd_proc.c |    2 +-
 3 files changed, 81 insertions(+), 3 deletions(-)

diff --git a/utils/gssd/gss_util.c b/utils/gssd/gss_util.c
index 8fe1e9b..ee304cc 100644
--- a/utils/gssd/gss_util.c
+++ b/utils/gssd/gss_util.c
@@ -138,6 +138,83 @@ display_status_1(char *m, u_int32_t code, int type, const gss_OID mech)
 	}
 }
 #endif
+static char *
+gss_display_error(OM_uint32 status)
+{
+		char *error = NULL;
+
+		switch(status) {
+		case GSS_S_COMPLETE: 
+			error = "GSS_S_COMPLETE";
+			break;
+		case GSS_S_CALL_INACCESSIBLE_READ: 
+			error = "GSS_S_CALL_INACCESSIBLE_READ";
+			break;
+		case GSS_S_CALL_INACCESSIBLE_WRITE:
+			error = "GSS_S_CALL_INACCESSIBLE_WRITE";
+			break;
+		case GSS_S_CALL_BAD_STRUCTURE:
+			error = "GSS_S_CALL_BAD_STRUCTURE";
+			break;
+		case  GSS_S_BAD_MECH:
+			error = "GSS_S_BAD_MECH";
+			break;
+		case  GSS_S_BAD_NAME:
+			error = "GSS_S_BAD_NAME";
+			break;
+		case  GSS_S_BAD_NAMETYPE:
+			error = "GSS_S_BAD_NAMETYPE";
+			break;
+		case  GSS_S_BAD_BINDINGS:
+			error = "GSS_S_BAD_BINDINGS";
+			break;
+		case  GSS_S_BAD_STATUS:
+			error = "GSS_S_BAD_STATUS";
+			break;
+		case  GSS_S_BAD_SIG:
+			error = "GSS_S_BAD_SIG";
+			break;
+		case  GSS_S_NO_CRED:
+			error = "GSS_S_NO_CRED";
+			break;
+		case  GSS_S_NO_CONTEXT:
+			error = "GSS_S_NO_CONTEXT";
+			break;
+		case  GSS_S_DEFECTIVE_TOKEN:
+			error = "GSS_S_DEFECTIVE_TOKEN";
+			break;
+		case  GSS_S_DEFECTIVE_CREDENTIAL:
+			error = "GSS_S_DEFECTIVE_CREDENTIAL";
+			break;
+		case  GSS_S_CREDENTIALS_EXPIRED:
+			error = "GSS_S_CREDENTIALS_EXPIRED";
+			break;
+		case  GSS_S_CONTEXT_EXPIRED:
+			error = "GSS_S_CONTEXT_EXPIRED";
+			break;
+		case  GSS_S_FAILURE:
+			error = "GSS_S_FAILURE";
+			break;
+		case  GSS_S_BAD_QOP:
+			error = "GSS_S_BAD_QOP";
+			break;
+		case  GSS_S_UNAUTHORIZED:
+			error = "GSS_S_UNAUTHORIZED";
+			break;
+		case  GSS_S_UNAVAILABLE:
+			error = "GSS_S_UNAVAILABLE";
+			break;
+		case  GSS_S_DUPLICATE_ELEMENT:
+			error = "GSS_S_DUPLICATE_ELEMENT";
+			break;
+		case  GSS_S_NAME_NOT_MN:
+			error = "GSS_S_NAME_NOT_MN";
+			break;
+		default:
+			error = "Not defined";
+		}
+	return error;
+}
 
 static void
 display_status_2(char *m, u_int32_t major, u_int32_t minor, const gss_OID mech)
@@ -175,8 +252,8 @@ display_status_2(char *m, u_int32_t major, u_int32_t minor, const gss_OID mech)
 
 	if (major == GSS_S_CREDENTIALS_EXPIRED)
 		msg_verbosity = 1;
-	printerr(msg_verbosity, "ERROR: GSS-API: error in %s(): %s - %s\n",
-		 m, maj, min);
+	printerr(msg_verbosity, "ERROR: GSS-API: error in %s(): %s (%s) - %s(%s)\n",
+		 m, gss_display_error(major), maj, min);
 
 	if (maj_gss_buf.length != 0)
 		(void) gss_release_buffer(&min_stat1, &maj_gss_buf);
diff --git a/utils/gssd/svcgssd.c b/utils/gssd/svcgssd.c
index 9b463f3..17af2da 100644
--- a/utils/gssd/svcgssd.c
+++ b/utils/gssd/svcgssd.c
@@ -267,6 +267,7 @@ main(int argc, char *argv[])
 	if (!fg)
 		release_parent();
 
+	nfs4_init_name_mapping(NULL); /* XXX: should only do this once */
 	gssd_run();
 	printerr(0, "gssd_run returned!\n");
 	abort();
diff --git a/utils/gssd/svcgssd_proc.c b/utils/gssd/svcgssd_proc.c
index 3894078..0ecbab6 100644
--- a/utils/gssd/svcgssd_proc.c
+++ b/utils/gssd/svcgssd_proc.c
@@ -241,7 +241,7 @@ get_ids(gss_name_t client_name, gss_OID mech, struct svc_cred *cred)
 			"file for name '%s'\n", sname);
 		goto out_free;
 	}
-	nfs4_init_name_mapping(NULL); /* XXX: should only do this once */
+
 	res = nfs4_gss_princ_to_ids(secname, sname, &uid, &gid);
 	if (res < 0) {
 		/*
-- 
1.7.3.3

