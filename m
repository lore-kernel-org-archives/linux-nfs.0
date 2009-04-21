From: Roel Kluin <roel.kluin@gmail.com>
Subject: non working tests on unsigned f->pseudoflavor
Date: Tue, 21 Apr 2009 16:08:39 +0200
Message-ID: <49EDD367.9000709@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:41599 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752679AbZDUOIk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Apr 2009 10:08:40 -0400
Received: by ewy24 with SMTP id 24so1606877ewy.37
        for <linux-nfs@vger.kernel.org>; Tue, 21 Apr 2009 07:08:39 -0700 (PDT)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

vi include/linux/nfsd/export.h +77
and note that struct exp_flavor_info f->pseudoflavor in secinfo_parse() is
unsigned. Should there maybe be a test:

if (f->pseudoflavor > MAX)

(and what should MAX be then?)

Otherwise you may want to apply the cleanup patch below

Roel
------------------------------>8-------------8<---------------------------------
Remove redundant tests on unsigned

Signed-off-by: Roel Kluin <roel.kluin@gmail.com> 
---
diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 5839b22..f09c3b4 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -463,17 +463,6 @@ static int secinfo_parse(char **mesg, char *buf, struct svc_export *exp)
 		err = get_int(mesg, &f->pseudoflavor);
 		if (err)
 			return err;
-		/*
-		 * Just a quick sanity check; we could also try to check
-		 * whether this pseudoflavor is supported, but at worst
-		 * an unsupported pseudoflavor on the export would just
-		 * be a pseudoflavor that won't match the flavor of any
-		 * authenticated request.  The administrator will
-		 * probably discover the problem when someone fails to
-		 * authenticate.
-		 */
-		if (f->pseudoflavor < 0)
-			return -EINVAL;
 		err = get_int(mesg, &f->flags);
 		if (err)
 			return err;
