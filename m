Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41326 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932313AbdBGWTX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 7 Feb 2017 17:19:23 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 337E780F9C
        for <linux-nfs@vger.kernel.org>; Tue,  7 Feb 2017 22:19:19 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [libnfsidmap PATCH] libnfsidmap: nss_gss_princ_to_ids() and nss_gss_princ_to_grouplist() must strip the realm
Date: Tue,  7 Feb 2017 17:19:18 -0500
Message-Id: <1486505958-41507-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

nss_gss_princ_to_ids() and nss_gss_princ_to_grouplist() were hard-coded
to call nss_getpwnam with the 'dostrip' arg set to 0, which is the
opposite of what they should have had.  Note: there's no point making
the decision to strip or not to strip configurable in these two
functions.  Ideally both of these functions should be taking a
gss_name_t instead of a char * for the principal, calling
gss_localname() on that, and passing the result to nss_getpwnam... but
that would require changes in both rpc.svcgssd and libgssglue (both of
which have been deprecated for a while).

Fixes: 4db1bb1 (libnfsidmap: add options to aid id mapping in multi domain environments)
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/nss.c b/nss.c
index 67e657a..82799ce 100644
--- a/nss.c
+++ b/nss.c
@@ -415,7 +415,7 @@ static int nss_gss_princ_to_ids(char *secname, char *princ,
 		return -ENOENT;
 	}
 	/* XXX: this should call something like getgssauthnam instead? */
-	pw = nss_getpwnam(princ, NULL, &err, 0);
+	pw = nss_getpwnam(princ, NULL, &err, 1);
 	if (pw == NULL) {
 		err = -ENOENT;
 		goto out;
@@ -438,7 +438,7 @@ int nss_gss_princ_to_grouplist(char *secname, char *princ,
 		goto out;
 	/* XXX: not quite right?  Need to know default realm? */
 	/* XXX: this should call something like getgssauthnam instead? */
-	pw = nss_getpwnam(princ, NULL, &ret, 0);
+	pw = nss_getpwnam(princ, NULL, &ret, 1);
 	if (pw == NULL) {
 		ret = -ENOENT;
 		goto out;
-- 
2.7.4

