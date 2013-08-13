Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:43488 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758186Ab3HMTUb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 15:20:31 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7DJKVMj000819
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 15:20:31 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-64.rdu.redhat.com [10.13.145.64])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r7DJKVAH017259
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 15:20:31 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id r7DJKUA3021428
	for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 15:20:30 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id r7DJKUst021427
	for linux-nfs@vger.kernel.org; Tue, 13 Aug 2013 15:20:30 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 2/4] mount.nfs: avoid sending conflicting mount options
Date: Tue, 13 Aug 2013 15:20:27 -0400
Message-Id: <1376421629-21382-3-git-send-email-smayhew@redhat.com>
In-Reply-To: <1376421629-21382-1-git-send-email-smayhew@redhat.com>
References: <1376421629-21382-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

conf_parse_mntopts() calls lookup_entry() in an attempt to avoid
"overwriting" of mount options (actually it tries to avoid appending
conflicting options to the string passed to mount(2)).  Currently this doesn't
do much of anything.  For example, if you have Timeo=600 in the global
section, Timeo=300 in the server-specific section, and Timeo=150 in the
mountpoint-specific section, then the string that is passed to the mount
syscall will contain "timeo=600,timeo=300,timeo=150".

Note that the ordering of the conflicting options ensures that the
correct option will ultimately be applied, but we should still avoid sending
the conflicting options in the first place if possible.

This patch fixes all but the MNT_NOARG type options (fg, bg, and sloppy).

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/mount/configfile.c | 24 +++++++++++++++++++-----
 1 file changed, 19 insertions(+), 5 deletions(-)

diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 1f1b6e7..221436f 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -170,10 +170,16 @@ char *lookup_entry(char *opt)
 {
 	struct entry *entry;
 
-	SLIST_FOREACH(entry, &head, entries) {
-		if (strcasecmp(entry->opt, opt) == 0)
-			return opt;
-	}
+	if (strlen(opt) > 0 && opt[strlen(opt) - 1] == '=')
+		SLIST_FOREACH(entry, &head, entries) {
+			if (strncasecmp(entry->opt, opt, strlen(opt)) == 0)
+				return opt;
+		}
+	else
+		SLIST_FOREACH(entry, &head, entries) {
+			if (strcasecmp(entry->opt, opt) == 0)
+				return opt;
+		}
 	return NULL;
 }
 /*
@@ -300,13 +306,21 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
 		if (opts && check_vers(opts, node->field))
 			continue;
 
-		if (lookup_entry(node->field) != NULL)
+		if (lookup_entry(buf) != NULL)
 			continue;
 		buf[0] = '\0';
 		value = conf_get_section(section, arg, node->field);
 		if (value == NULL)
 			continue;
 		field = mountopts_alias(node->field, &argtype);
+		if (lookup_entry(field) != NULL)
+			continue;
+		if (argtype != MNT_NOARG) {
+			snprintf(buf, BUFSIZ, "no%s", field);
+			if (lookup_entry(buf) != NULL)
+				continue;
+			buf[0] = '\0';
+		}
 		if (strcasecmp(value, "false") == 0) {
 			if (argtype != MNT_NOARG)
 				snprintf(buf, BUFSIZ, "no%s", field);
-- 
1.7.11.7

