Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34497 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755214Ab2LCRSJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Dec 2012 12:18:09 -0500
Received: by mail-ie0-f174.google.com with SMTP id c11so4554894ieb.19
        for <linux-nfs@vger.kernel.org>; Mon, 03 Dec 2012 09:18:09 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/5] mountd: Report the absolute path used to load the
 junction plug-in
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 03 Dec 2012 12:18:08 -0500
Message-ID: <20121203171808.1390.33578.stgit@lebasque.1015granger.net>
In-Reply-To: <20121203171549.1390.64007.stgit@lebasque.1015granger.net>
References: <20121203171549.1390.64007.stgit@lebasque.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

As a debugging feature, report the absolute pathname of the plug-in
library that mountd loads to resolve junctions.

Since mountd passes a relative path to dlopen(3), dlopen(3) must
search for the right library.  Displaying the absolute pathname of
the object that it found verifies that mountd loaded the correct
plug-in.

Note: dlinfo(3) is provided by libdl, but there doesn't seem to be a
man page on Fedora 16 for dlinfo(3).  Instead, see:

  http://www.unix.com/man-page/all/3/dlinfo/

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index c264e14..3853bb6 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -826,6 +826,7 @@ lookup_export(char *dom, char *path, struct addrinfo *ai)
 
 #ifdef HAVE_NFS_PLUGIN_H
 #include <dlfcn.h>
+#include <link.h>
 #include <nfs-plugin.h>
 
 /*
@@ -1090,6 +1091,7 @@ static struct exportent *lookup_junction(char *dom, const char *pathname,
 		struct addrinfo *ai)
 {
 	struct exportent *exp;
+	struct link_map *map;
 	void *handle;
 
 	handle = dlopen("libnfsjunct.so", RTLD_NOW);
@@ -1097,6 +1099,11 @@ static struct exportent *lookup_junction(char *dom, const char *pathname,
 		xlog(D_GENERAL, "%s: dlopen: %s", __func__, dlerror());
 		return NULL;
 	}
+
+	if (dlinfo(handle, RTLD_DI_LINKMAP, &map) == 0)
+		xlog(D_GENERAL, "%s: loaded plug-in %s",
+			__func__, map->l_name);
+
 	(void)dlerror();	/* Clear any error */
 
 	exp = invoke_junction_ops(handle, dom, pathname, ai);

