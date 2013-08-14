Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34636 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758427Ab3HNPs3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Aug 2013 11:48:29 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7EFmSYn016719
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Aug 2013 11:48:29 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-64.rdu.redhat.com [10.13.145.64])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r7EFmSmM031343
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Wed, 14 Aug 2013 11:48:28 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id r7EFmSa2014207
	for <linux-nfs@vger.kernel.org>; Wed, 14 Aug 2013 11:48:28 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id r7EFmRo2014206
	for linux-nfs@vger.kernel.org; Wed, 14 Aug 2013 11:48:27 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] mount.nfs: dont pass options from configuration sections that are not relevant
Date: Wed, 14 Aug 2013 11:48:27 -0400
Message-Id: <1376495307-14174-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfsmount.conf file has the following format:

[ section "arg" ]
	tag = value

conf_get_tag_list() currently doesn't check the arg field so we wind up
getting all the options that fall under a particular section value,
instead of just the ones that match the specific "arg" field.  As a
result, we wind up passing options to the mount syscall from sections
that aren't even relevant to the mount operation that is being
performed.

For example, if we have three different server sections, and each
section has an Nfsvers tag, then the string we pass to the mount syscall
will have two extra occurrences of the nfsvers option.  Each option
should appear at most 4 times -- once for the system section, once for
the server-specific section, once for the mount-specific section, and
once for the command line mount options.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 support/include/conffile.h | 2 +-
 support/nfs/conffile.c     | 4 +++-
 utils/mount/configfile.c   | 2 +-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/support/include/conffile.h b/support/include/conffile.h
index ce7aa21..05ea5d2 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -54,7 +54,7 @@ extern int      conf_end(int, int);
 extern void     conf_free_list(struct conf_list *);
 extern struct sockaddr *conf_get_address(char *, char *);
 extern struct conf_list *conf_get_list(char *, char *);
-extern struct conf_list *conf_get_tag_list(char *);
+extern struct conf_list *conf_get_tag_list(char *, char *);
 extern int      conf_get_num(char *, char *, int);
 extern char    *conf_get_str(char *, char *);
 extern char    *conf_get_section(char *, char *, char *);
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 5015e94..c3434d5 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -565,7 +565,7 @@ cleanup:
 }
 
 struct conf_list *
-conf_get_tag_list(char *section)
+conf_get_tag_list(char *section, char *arg)
 {
 	struct conf_list *list = 0;
 	struct conf_list_node *node;
@@ -579,6 +579,8 @@ conf_get_tag_list(char *section)
 	cb = LIST_FIRST(&conf_bindings[conf_hash (section)]);
 	for (; cb; cb = LIST_NEXT(cb, link)) {
 		if (strcasecmp (section, cb->section) == 0) {
+			if (arg != NULL && strcasecmp(arg, cb->arg) != 0)
+				continue;
 			list->cnt++;
 			node = calloc(1, sizeof *node);
 			if (!node)
diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 6f2ee75..1f1b6e7 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -286,7 +286,7 @@ conf_parse_mntopts(char *section, char *arg, char *opts)
 	char *nvalue, *ptr;
 	int argtype;
 
-	list = conf_get_tag_list(section);
+	list = conf_get_tag_list(section, arg);
 	TAILQ_FOREACH(node, &list->fields, link) {
 		/*
 		 * Do not overwrite options if already exists 
-- 
1.7.11.7

