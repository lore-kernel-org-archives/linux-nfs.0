Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:15664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757824Ab3HMTUb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Aug 2013 15:20:31 -0400
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id r7DJKV17000809
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 15:20:31 -0400
Received: from tonberry.usersys.redhat.com (dhcp145-64.rdu.redhat.com [10.13.145.64])
	by int-mx11.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id r7DJKUcM017254
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 15:20:31 -0400
Received: from tonberry.usersys.redhat.com (localhost [127.0.0.1])
	by tonberry.usersys.redhat.com (8.14.5/8.14.5) with ESMTP id r7DJKU9t021423
	for <linux-nfs@vger.kernel.org>; Tue, 13 Aug 2013 15:20:30 -0400
Received: (from smayhew@localhost)
	by tonberry.usersys.redhat.com (8.14.5/8.14.5/Submit) id r7DJKUV4021422
	for linux-nfs@vger.kernel.org; Tue, 13 Aug 2013 15:20:30 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 1/4] mount.nfs: avoid unnecessary duplication of options passed to mount(2)
Date: Tue, 13 Aug 2013 15:20:26 -0400
Message-Id: <1376421629-21382-2-git-send-email-smayhew@redhat.com>
In-Reply-To: <1376421629-21382-1-git-send-email-smayhew@redhat.com>
References: <1376421629-21382-1-git-send-email-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfsmount.conf file has the following format:

[ section "arg" ]
	tag = value

conf_get_tag_list() currently doesn't check the arg field so we wind up
getting all the options that fall under a particular section value,
instead of just the ones that match the specific "arg" field.  As a
result, we wind up passing options to the mount syscall multiple times.

For example, if we have three different server sections, and each
section has an Nfsvers tag, then the string we pass to the mount syscall
will have three occurrences of the nfsvers option.

Note that the call to conf_get_section() in conf_parse_mntopts() will
ensure that we never pass the wrong value for an option, but we should
still avoid sending duplicate options if it's at all possible.

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

