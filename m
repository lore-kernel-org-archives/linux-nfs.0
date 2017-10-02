Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:40214 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750891AbdJBIC1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 2 Oct 2017 04:02:27 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 8536C81E0B
        for <linux-nfs@vger.kernel.org>; Mon,  2 Oct 2017 08:02:27 +0000 (UTC)
Message-ID: <1506931344.3753.3.camel@redhat.com>
Subject: [PATCH nfs-utils] merge vers= and nfsvers= options in mount.nfs
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Mon, 02 Oct 2017 09:02:24 +0100
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When using mount.nfs if an nfsvers= option is set in a config file,
and a vers= option is given on the commandline, then they are not
always correctly combined and this can result in both being present
in the resulting mount call.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 utils/mount/configfile.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index e4b39ef..64688bf 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -66,6 +66,7 @@ struct mnt_alias {
 	{"background", "bg", MNT_NOARG},
 	{"foreground", "fg", MNT_NOARG},
 	{"sloppy", "sloppy", MNT_NOARG},
+	{"nfsvers", "vers", MNT_UNSET},
 };
 int mnt_alias_sz = (sizeof(mnt_alias_tab)/sizeof(mnt_alias_tab[0]));
 
@@ -292,20 +293,21 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
 
 	list = conf_get_tag_list(section, arg);
 	TAILQ_FOREACH(node, &list->fields, link) {
+		/* check first if this is an alias for another option */
+		field = mountopts_alias(node->field, &argtype);
 		/*
 		 * Do not overwrite options if already exists 
 		 */
-		snprintf(buf, BUFSIZ, "%s=", node->field);
+		snprintf(buf, BUFSIZ, "%s=", field);
 		if (opts && strcasestr(opts, buf) != NULL)
 			continue;
 
-		if (lookup_entry(node->field) != NULL)
+		if (lookup_entry(field) != NULL)
 			continue;
 		buf[0] = '\0';
 		value = conf_get_section(section, arg, node->field);
 		if (value == NULL)
 			continue;
-		field = mountopts_alias(node->field, &argtype);
 		if (strcasecmp(value, "false") == 0) {
 			if (argtype != MNT_NOARG)
 				snprintf(buf, BUFSIZ, "no%s", field);
-- 
1.8.3.1



