Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:63173 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753739AbaIHQgA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Sep 2014 12:36:00 -0400
Received: by mail-qc0-f181.google.com with SMTP id i17so16055271qcy.12
        for <linux-nfs@vger.kernel.org>; Mon, 08 Sep 2014 09:35:59 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] gssd: ensure that preferred_realm is non-NULL before passing it to strcmp
Date: Mon,  8 Sep 2014 12:35:54 -0400
Message-Id: <1410194154-25567-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible for "preferred_realm" to be NULL, in which case we
don't want to pass it to strcmp. Other places that use this variable
test whether it's NULL first -- we need to do the same here.

This should fix the gssd crash reported here:

    https://bugzilla.redhat.com/show_bug.cgi?id=1108615

Reported-by: Brian J. Murrell <brian@interlinx.bc.ca>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 utils/gssd/krb5_util.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 8369fdf0ed27..f1ebc0d09731 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -876,7 +876,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt, const char *tgtname,
 	i = 0;
 	realm = realmnames[i];
 
-	if (strcmp (realm, preferred_realm) != 0) {
+	if (preferred_realm && strcmp (realm, preferred_realm) != 0) {
 		realm = preferred_realm;
 		/* resetting the realmnames index */
 		i = -1;
-- 
1.9.3

