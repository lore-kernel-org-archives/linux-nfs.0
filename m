From: Andrew Pollock <apollock@google.com>
Subject: [PATCH] gssd: By default, don't spam syslog when users' credentials
	expire (redux)
Date: Mon, 22 Feb 2010 13:33:32 -0500
Message-ID: <39d46ab51002221033n78035811y959fdd30b155b174@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:39706 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752029Ab0BVSde convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Feb 2010 13:33:34 -0500
Received: from kpbe18.cbf.corp.google.com (kpbe18.cbf.corp.google.com [172.25.105.82])
	by smtp-out.google.com with ESMTP id o1MIXXac023179
	for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2010 10:33:33 -0800
Received: from pzk13 (pzk13.prod.google.com [10.243.19.141])
	by kpbe18.cbf.corp.google.com with ESMTP id o1MIX8Bw015461
	for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2010 10:33:32 -0800
Received: by pzk13 with SMTP id 13so177827pzk.26
        for <linux-nfs@vger.kernel.org>; Mon, 22 Feb 2010 10:33:32 -0800 (PST)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a continuation of commit 09c7ad1cd9c5ca2fc46631a0057d47309abc87=
06,
adding a couple more cases that can spam syslog
---
=A0utils/gssd/gss_util.c =A0| =A0 =A02 +-
=A0utils/gssd/gssd_proc.c | =A0 =A06 +++---
=A02 files changed, 4 insertions(+), 4 deletions(-)
diff --git a/utils/gssd/gss_util.c b/utils/gssd/gss_util.c
index 99aceb3..64dddf1 100644
--- a/utils/gssd/gss_util.c
+++ b/utils/gssd/gss_util.c
@@ -126,7 +126,7 @@ display_status_1(char *m, u_int32_t code, int
type, const gss_OID mech)
=A0 "gss_display_status called from %s\n", m);
=A0 break;
=A0 } else {
- printerr(0, "ERROR: GSS-API: (%s) error in %s(): %s\n",
+ printerr(2, "ERROR: GSS-API: (%s) error in %s(): %s\n",
=A0 =A0 =A0typestr, m, (char *)msg.value);
=A0 }

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index be4fb11..5629d97 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -638,7 +638,7 @@ do_error_downcall(int k5_fd, uid_t uid, int err)
=A0 unsigned int timeout =3D 0;
=A0 int zero =3D 0;

- printerr(1, "doing error downcall\n");
+ printerr(2, "doing error downcall\n");

=A0 if (WRITE_BYTES(&p, end, uid)) goto out_err;
=A0 if (WRITE_BYTES(&p, end, timeout)) goto out_err;
@@ -906,7 +906,7 @@ process_krb5_upcall(struct clnt_info *clp, uid_t
uid, int fd, char *tgtname,
=A0 int create_resp =3D -1;
=A0 int err, downcall_err =3D -EACCES;

- printerr(1, "handling krb5 upcall (%s)\n", clp->dirname);
+ printerr(2, "handling krb5 upcall (%s)\n", clp->dirname);

=A0 if (tgtname) {
=A0 if (clp->servicename) {
@@ -1066,7 +1066,7 @@ process_spkm3_upcall(struct clnt_info *clp,
uid_t uid, int fd)
=A0 }

=A0 if (!authgss_get_private_data(auth, &pd)) {
- printerr(0, "WARNING: Failed to obtain authentication "
+ printerr(2, "WARNING: Failed to obtain authentication "
=A0 =A0 =A0"data for user with uid %d for server %s\n",
=A0 uid, clp->servername);
=A0 goto out_return_error;
--
1.5.4.3
