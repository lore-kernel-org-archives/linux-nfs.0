Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f179.google.com ([209.85.217.179]:43867 "EHLO
	mail-lb0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753607AbaJBNmk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Oct 2014 09:42:40 -0400
Received: by mail-lb0-f179.google.com with SMTP id l4so2207211lbv.38
        for <linux-nfs@vger.kernel.org>; Thu, 02 Oct 2014 06:42:39 -0700 (PDT)
From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: Steve Dickson <SteveD@redhat.com>, linux-nfs@vger.kernel.org,
        ncopa@alpinelinux.org
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH v2 5/5] nfslib: remove now unused FILE helpers
Date: Thu,  2 Oct 2014 16:42:01 +0300
Message-Id: <1412257321-5855-6-git-send-email-timo.teras@iki.fi>
In-Reply-To: <1412257321-5855-1-git-send-email-timo.teras@iki.fi>
References: <1412257321-5855-1-git-send-email-timo.teras@iki.fi>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All access to kernel is now done using file descriptors.

Signed-off-by: Timo Teräs <timo.teras@iki.fi>
---
 support/include/nfslib.h |   7 ---
 support/nfs/cacheio.c    | 110 -----------------------------------------------
 2 files changed, 117 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index ce4b14b..9fd22ac 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -152,11 +152,6 @@ struct nfs_fh_len *	getfh(const struct sockaddr_in *sin, const char *path);
 struct nfs_fh_len *	getfh_size(const struct sockaddr_in *sin,
 					const char *path, int const size);
 
-void qword_print(FILE *f, char *str);
-void qword_printhex(FILE *f, char *str, int slen);
-void qword_printint(FILE *f, int num);
-int qword_eol(FILE *f);
-int readline(int fd, char **buf, int *lenp);
 int qword_get(char **bpp, char *dest, int bufsize);
 int qword_get_int(char **bpp, int *anint);
 void cache_flush(int force);
@@ -167,8 +162,6 @@ void qword_addint(char **bpp, int *lp, int n);
 void qword_adduint(char **bpp, int *lp, unsigned int n);
 void qword_addeol(char **bpp, int *lp);
 int qword_get_uint(char **bpp, unsigned int *anint);
-void qword_printuint(FILE *f, unsigned int num);
-void qword_printtimefrom(FILE *f, unsigned int num);
 
 void closeall(int min);
 
diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 2726d8f..42e2502 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -121,74 +121,6 @@ void qword_addeol(char **bpp, int *lp)
 	(*lp)--;
 }
 
-static char qword_buf[8192];
-void qword_print(FILE *f, char *str)
-{
-	char *bp = qword_buf;
-	int len = sizeof(qword_buf);
-	qword_add(&bp, &len, str);
-	if (fwrite(qword_buf, bp-qword_buf, 1, f) != 1) {
-		xlog_warn("qword_print: fwrite failed: errno %d (%s)",
-			errno, strerror(errno));
-	}
-}
-
-void qword_printhex(FILE *f, char *str, int slen)
-{
-	char *bp = qword_buf;
-	int len = sizeof(qword_buf);
-	qword_addhex(&bp, &len, str, slen);
-	if (fwrite(qword_buf, bp-qword_buf, 1, f) != 1) {
-		xlog_warn("qword_printhex: fwrite failed: errno %d (%s)",
-			errno, strerror(errno));
-	}
-}
-
-void qword_printint(FILE *f, int num)
-{
-	fprintf(f, "%d ", num);
-}
-
-void qword_printuint(FILE *f, unsigned int num)
-{
-	fprintf(f, "%u ", num);
-}
-
-void qword_printtimefrom(FILE *f, unsigned int num)
-{
-	fprintf(f, "%lu ", time(0) + num);
-}
-
-int qword_eol(FILE *f)
-{
-	int err;
-
-	err = fprintf(f,"\n");
-	if (err < 0) {
-		xlog_warn("qword_eol: fprintf failed: errno %d (%s)",
-			    errno, strerror(errno));
-	} else {
-		err = fflush(f);
-		if (err) {
-			xlog_warn("qword_eol: fflush failed: errno %d (%s)",
-				  errno, strerror(errno));
-		}
-	}
-	/*
-	 * We must send one line (and one line only) in a single write
-	 * call.  In case of a write error, libc may accumulate the
-	 * unwritten data and try to write it again later, resulting in a
-	 * multi-line write.  So we must explicitly ask it to throw away
-	 * any such cached data.  But we return any original error
-	 * indication to the caller.
-	 */
-	__fpurge(f);
-	fflush(f);
-	return err;
-}
-
-
-
 #define isodigit(c) (isdigit(c) && c <= '7')
 int qword_get(char **bpp, char *dest, int bufsize)
 {
@@ -266,48 +198,6 @@ int qword_get_uint(char **bpp, unsigned int *anint)
 	return 0;
 }
 
-#define READLINE_BUFFER_INCREMENT 2048
-
-int readline(int fd, char **buf, int *lenp)
-{
-	/* read a line into *buf, which is malloced *len long
-	 * realloc if needed until we find a \n
-	 * nul out the \n and return
-	 * 0 on eof, 1 on success
-	 */
-	int len;
-
-	if (*lenp == 0) {
-		char *b = malloc(READLINE_BUFFER_INCREMENT);
-		if (b == NULL)
-			return 0;
-		*buf = b;
-		*lenp = READLINE_BUFFER_INCREMENT;
-	}
-	len = read(fd, *buf, *lenp);
-	if (len <= 0)
-		return 0;
-	while ((*buf)[len-1] != '\n') {
-	/* now the less common case.  There was no newline,
-	 * so we have to keep reading after re-alloc
-	 */
-		char *new;
-		int nl;
-		*lenp += READLINE_BUFFER_INCREMENT;
-		new = realloc(*buf, *lenp);
-		if (new == NULL)
-			return 0;
-		*buf = new;
-		nl = read(fd, *buf + len, *lenp - len);
-		if (nl <= 0)
-			return 0;
-		len += nl;
-	}
-	(*buf)[len-1] = '\0';
-	return 1;
-}
-
-
 /* Check if we should use the new caching interface
  * This succeeds iff the "nfsd" filesystem is mounted on
  * /proc/fs/nfs
-- 
2.1.2

