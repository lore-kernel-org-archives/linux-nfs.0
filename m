Return-Path: <SRS0=rsXR=4O=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.9 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE331C4BA24
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Feb 2020 19:02:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 852D92072D
	for <linux-nfs@archiver.kernel.org>; Wed, 26 Feb 2020 19:02:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="CC5guoZf"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727168AbgBZTC1 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 26 Feb 2020 14:02:27 -0500
Received: from us-smtp-delivery-1.mimecast.com ([207.211.31.120]:47765 "EHLO
        us-smtp-1.mimecast.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1727125AbgBZTC1 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Feb 2020 14:02:27 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
        s=mimecast20190719; t=1582743747;
        h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
         to:to:cc:mime-version:mime-version:
         content-transfer-encoding:content-transfer-encoding;
        bh=ejM3sNHWuoChbfXrBZLOI4gzURyTonOAkACXs7CvBDE=;
        b=CC5guoZf6I5DRvmck7NU46bK+Gm9oGRwjVwAshDW2Y73k8f9rhvcU0WzBj0RxbhA46dl1v
        wJOffQISWcOW2UUs+3wYJlhHR3/769ZR9x5ID8Hq/+xfR/kTRUNXIwx02HaJT528qmYHJw
        oSWe1Uf3X987cm0aunWatQNBTw+Hh4Q=
Received: from mimecast-mx01.redhat.com (mimecast-mx01.redhat.com
 [209.132.183.4]) (Using TLS) by relay.mimecast.com with ESMTP id
 us-mta-223-AM1iOblvNgu6WUrxfVgogw-1; Wed, 26 Feb 2020 14:02:25 -0500
X-MC-Unique: AM1iOblvNgu6WUrxfVgogw-1
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mimecast-mx01.redhat.com (Postfix) with ESMTPS id 3C3BBA0CC3
        for <linux-nfs@vger.kernel.org>; Wed, 26 Feb 2020 19:02:24 +0000 (UTC)
Received: from madhat.boston.devel.redhat.com (madhat.boston.devel.redhat.com [10.19.60.33])
        by smtp.corp.redhat.com (Postfix) with ESMTP id E58EE1CB
        for <linux-nfs@vger.kernel.org>; Wed, 26 Feb 2020 19:02:23 +0000 (UTC)
From:   Steve Dickson <steved@redhat.com>
To:     Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] gssd: Use krb5_free_string() instead of free()
Date:   Wed, 26 Feb 2020 14:02:21 -0500
Message-Id: <20200226190221.24885-1-steved@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
Content-Transfer-Encoding: quoted-printable
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Commit ae9e9760 plugged up some memory leaks
by freeing memory via free(2). The proper
way to free memory that has been allocated by
krb5 functions is with krb5_free_string()

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/gssd/krb5_util.c | 20 ++++++++++----------
 1 file changed, 10 insertions(+), 10 deletions(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 85f60ae..8c73748 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -484,7 +484,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 	if (ccache)
 		krb5_cc_close(context, ccache);
 	krb5_free_cred_contents(context, &my_creds);
-	free(k5err);
+	krb5_free_string(context, k5err);
 	return (code);
 }
=20
@@ -723,7 +723,7 @@ gssd_search_krb5_keytab(krb5_context context, krb5_ke=
ytab kt,
 				 "we failed to unparse principal name: %s\n",
 				 k5err);
 			k5_free_kt_entry(context, kte);
-			free(k5err);
+			krb5_free_string(context, k5err);
 			k5err =3D NULL;
 			continue;
 		}
@@ -770,7 +770,7 @@ gssd_search_krb5_keytab(krb5_context context, krb5_ke=
ytab kt,
 	if (retval < 0)
 		retval =3D 0;
   out:
-	free(k5err);
+	krb5_free_string(context, k5err);
 	return retval;
 }
=20
@@ -927,7 +927,7 @@ find_keytab_entry(krb5_context context, krb5_keytab k=
t,
 				k5err =3D gssd_k5_err_msg(context, code);
 				printerr(1, "%s while building principal for '%s'\n",
 					 k5err, spn);
-				free(k5err);
+				krb5_free_string(context, k5err);
 				k5err =3D NULL;
 				continue;
 			}
@@ -937,7 +937,7 @@ find_keytab_entry(krb5_context context, krb5_keytab k=
t,
 				k5err =3D gssd_k5_err_msg(context, code);
 				printerr(3, "%s while getting keytab entry for '%s'\n",
 					 k5err, spn);
-				free(k5err);
+				krb5_free_string(context, k5err);
 				k5err =3D NULL;
 				/*
 				 * We tried the active directory machine account
@@ -986,7 +986,7 @@ out:
 		k5_free_default_realm(context, default_realm);
 	if (realmnames)
 		krb5_free_host_realm(context, realmnames);
-	free(k5err);
+	krb5_free_string(context, k5err);
 	return retval;
 }
=20
@@ -1249,7 +1249,7 @@ gssd_destroy_krb5_machine_creds(void)
 			printerr(0, "WARNING: %s while resolving credential "
 				    "cache '%s' for destruction\n", k5err,
 				    ple->ccname);
-			free(k5err);
+			krb5_free_string(context, k5err);
 			k5err =3D NULL;
 			continue;
 		}
@@ -1258,13 +1258,13 @@ gssd_destroy_krb5_machine_creds(void)
 			k5err =3D gssd_k5_err_msg(context, code);
 			printerr(0, "WARNING: %s while destroying credential "
 				    "cache '%s'\n", k5err, ple->ccname);
-			free(k5err);
+			krb5_free_string(context, k5err);
 			k5err =3D NULL;
 		}
 	}
 	krb5_free_context(context);
   out:
-	free(k5err);
+	krb5_free_string(context, k5err);
 }
=20
 /*
@@ -1347,7 +1347,7 @@ out_free_kt:
 out_free_context:
 	krb5_free_context(context);
 out:
-	free(k5err);
+	krb5_free_string(context, k5err);
 	return retval;
 }
=20
--=20
2.24.1

