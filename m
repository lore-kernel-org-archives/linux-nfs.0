From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: [PATCH 3/3] Remove unnecessary code from idmapd.
Date: Tue, 11 Sep 2007 09:03:27 -0400
Message-ID: <1189515807.12340.6.camel@moss-terrapins.epoch.ncsc.mil>
References: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org
To: nfs@lists.sourceforge.net
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1189459543.7914.16.camel@moss-terrapins.epoch.ncsc.mil>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

This patch removes unnecessary code from idmapd. setproctitle is not used
anywhere and it can be removed. In addition the kernel section of the
nfs_idmap.h header is not used and is out of date and thus is removed.

Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
---
 utils/idmapd/Makefile.am    |    1 -
 utils/idmapd/nfs_idmap.h    |    7 ---
 utils/idmapd/setproctitle.c |  110 -------------------------------------------
 3 files changed, 0 insertions(+), 118 deletions(-)
 delete mode 100644 utils/idmapd/setproctitle.c

diff --git a/utils/idmapd/Makefile.am b/utils/idmapd/Makefile.am
index 586ac9a..eb393df 100644
--- a/utils/idmapd/Makefile.am
+++ b/utils/idmapd/Makefile.am
@@ -16,7 +16,6 @@ idmapd_SOURCES = \
 	atomicio.c \
 	cfg.c \
 	idmapd.c \
-	setproctitle.c \
 	strlcat.c \
 	strlcpy.c \
 	\
diff --git a/utils/idmapd/nfs_idmap.h b/utils/idmapd/nfs_idmap.h
index 5ec7cf1..59bced3 100644
--- a/utils/idmapd/nfs_idmap.h
+++ b/utils/idmapd/nfs_idmap.h
@@ -61,11 +61,4 @@ struct idmap_msg {
 	u_int8_t  im_status;
 };
 
-#ifdef __KERNEL__
-void      *nfs_idmap_new(struct nfs_server *);
-void       nfs_idmap_delete(struct nfs_server *);
-int        nfs_idmap_id(struct nfs_server *, u_int8_t, char *, u_int,  uid_t *);
-int        nfs_idmap_name(struct nfs_server *, u_int8_t, uid_t, char *, u_int *);
-#endif /* __KERNEL__ */
-
 #endif /* NFS_IDMAP_H */
diff --git a/utils/idmapd/setproctitle.c b/utils/idmapd/setproctitle.c
deleted file mode 100644
index 0679f4e..0000000
--- a/utils/idmapd/setproctitle.c
+++ /dev/null
@@ -1,110 +0,0 @@
-/*
- * Modified for OpenSSH by Kevin Steves
- * October 2000
- */
-
-/*
- * Copyright (c) 1994, 1995 Christopher G. Demetriou
- * All rights reserved.
- *
- * Redistribution and use in source and binary forms, with or without
- * modification, are permitted provided that the following conditions
- * are met:
- * 1. Redistributions of source code must retain the above copyright
- *    notice, this list of conditions and the following disclaimer.
- * 2. Redistributions in binary form must reproduce the above copyright
- *    notice, this list of conditions and the following disclaimer in the
- *    documentation and/or other materials provided with the distribution.
- * 3. All advertising materials mentioning features or use of this software
- *    must display the following acknowledgement:
- *      This product includes software developed by Christopher G. Demetriou
- *	for the NetBSD Project.
- * 4. The name of the author may not be used to endorse or promote products
- *    derived from this software without specific prior written permission
- *
- * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
- * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
- * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
- * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
- * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
- * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
- * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
- * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
- * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
- * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
- */
-
-#if defined(LIBC_SCCS) && !defined(lint)
-static char rcsid[] = "$OpenBSD: setproctitle.c,v 1.8 2001/11/06 19:21:40 art Exp $";
-#endif /* LIBC_SCCS and not lint */
-
-#include <sys/types.h>
-
-#include <stdio.h>
-#include <string.h>
-#include <stdarg.h>
-
-#ifdef HAVE_CONFIG_H
-#include "config.h"
-#endif /* HAVE_CONFIG_H */
-
-#ifndef HAVE_SETPROCTITLE
-
-#define SPT_NONE	0
-#define SPT_PSTAT	1
-
-#ifndef SPT_TYPE
-#define SPT_TYPE	SPT_NONE
-#endif
-
-#if SPT_TYPE == SPT_PSTAT
-#include <sys/param.h>
-#include <sys/pstat.h>
-#endif /* SPT_TYPE == SPT_PSTAT */
-
-#define	MAX_PROCTITLE	2048
-
-extern char *__progname;
-
-/*
- * Set Process Title (SPT) defines.  Modeled after sendmail's
- * SPT type definition strategy.
- *
- * SPT_TYPE:
- *
- * SPT_NONE:	Don't set the process title.  Default.
- * SPT_PSTAT:	Use pstat(PSTAT_SETCMD).  HP-UX specific.
- */
-
-void
-setproctitle(const char *fmt, ...)
-{
-#if SPT_TYPE != SPT_NONE
-	va_list ap;
-
-	char buf[MAX_PROCTITLE];
-	size_t used;
-
-#if SPT_TYPE == SPT_PSTAT
-	union pstun pst;
-#endif /* SPT_TYPE == SPT_PSTAT */
-
-	va_start(ap, fmt);
-	if (fmt != NULL) {
-		used = snprintf(buf, MAX_PROCTITLE, "%s: ", __progname);
-		if (used >= MAX_PROCTITLE)
-			used = MAX_PROCTITLE - 1;
-		(void)vsnprintf(buf + used, MAX_PROCTITLE - used, fmt, ap);
-	} else
-		(void)snprintf(buf, MAX_PROCTITLE, "%s", __progname);
-	va_end(ap);
-	used = strlen(buf);
-
-#if SPT_TYPE == SPT_PSTAT
-	pst.pst_command = buf;
-	pstat(PSTAT_SETCMD, pst, used, 0, 0);
-#endif /* SPT_TYPE == SPT_PSTAT */
-
-#endif /* SPT_TYPE != SPT_NONE */
-}
-#endif /* HAVE_SETPROCTITLE */
-- 
1.5.2.4
