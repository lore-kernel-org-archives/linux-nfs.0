Return-Path: <SRS0=avcE=RX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0B827C43381
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 16:39:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CA90B2183E
	for <linux-nfs@archiver.kernel.org>; Wed, 20 Mar 2019 16:39:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727012AbfCTQjf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 20 Mar 2019 12:39:35 -0400
Received: from mx1.redhat.com ([209.132.183.28]:63580 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726860AbfCTQje (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Mar 2019 12:39:34 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.phx2.redhat.com [10.5.11.16])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 4D526307D92F
        for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2019 16:39:34 +0000 (UTC)
Received: from jumitche.remote.csb (unknown [10.33.36.25])
        by smtp.corp.redhat.com (Postfix) with ESMTPS id C738F5C260
        for <linux-nfs@vger.kernel.org>; Wed, 20 Mar 2019 16:39:33 +0000 (UTC)
Message-ID: <1553099972.8215.40.camel@redhat.com>
Subject: [PATCH] nfs-utils: Modify nfs.conf in-place instead of replacing
 the file
From:   Justin Mitchell <jumitche@redhat.com>
To:     linux-nfs@vger.kernel.org
Date:   Wed, 20 Mar 2019 16:39:32 +0000
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.16
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Wed, 20 Mar 2019 16:39:34 +0000 (UTC)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

When changes are written to nfs.conf the old method of building a new file
and then switching them leaves less opportunities for race conditions
against 3rd party tools but loses any existing permissions, ownerships,
attributes, etc. This patch instead uses an advisory flock to guard the
contents whilst it reads, modifies, and then rewrites the existing file.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/nfs/conffile.c | 134 +++++++++++++++++++++++++++----------------------
 1 file changed, 74 insertions(+), 60 deletions(-)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 77c5790..d8f2e8e 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -50,6 +50,7 @@
 #include <err.h>
 #include <syslog.h>
 #include <libgen.h>
+#include <sys/file.h>
 
 #include "conffile.h"
 #include "xlog.h"
@@ -504,6 +505,17 @@ conf_readfile(const char *path)
 			return NULL;
 		}
 
+		/* Grab a shared lock to ensure its not mid-rewrite */
+		if (flock(fd, LOCK_SH)) {
+			xlog_warn("conf_readfile: attempt to grab read lock failed: %s",
+				strerror(errno));
+			goto fail;
+		}
+
+		/* only after we have the lock, check the file size ready to read it */
+		sz = lseek(fd, 0, SEEK_END);
+		lseek(fd, 0, SEEK_SET);
+
 		new_conf_addr = malloc(sz+1);
 		if (!new_conf_addr) {
 			xlog_warn("conf_readfile: malloc (%lu) failed", (unsigned long)sz);
@@ -1583,6 +1595,17 @@ flush_outqueue(struct tailhead *queue, FILE *fout)
 	return 0;
 }
 
+/* append one queue to another */
+static void
+append_queue(struct tailhead *inq, struct tailhead *outq)
+{
+	while (inq->tqh_first != NULL) {
+		struct outbuffer *ob = inq->tqh_first;
+		TAILQ_REMOVE(inq, ob, link);
+		TAILQ_INSERT_TAIL(outq, ob, link);
+	}
+}
+
 /* read one line of text from a file, growing the buffer as necessary */
 static int
 read_line(char **buff, int *buffsize, FILE *in)
@@ -1723,6 +1746,16 @@ is_folded(const char *line)
 	return false;
 }
 
+static int
+lock_file(FILE *f)
+{
+	int ret;
+	ret = flock(fileno(f), LOCK_EX);
+	if (ret) 
+		xlog(L_ERROR, "Error could not lock the file");
+	return ret;
+}
+
 /***
  * Write a value to an nfs.conf style filename
  *
@@ -1733,15 +1766,14 @@ int
 conf_write(const char *filename, const char *section, const char *arg,
 	   const char *tag, const char *value)
 {
-	int fdout = -1;
-	char *outpath = NULL;
-	FILE *outfile = NULL;
 	FILE *infile = NULL;
 	int ret = 1;
 	struct tailhead outqueue;
+	struct tailhead inqueue;
 	char * buff = NULL;
 	int buffsize = 0;
 
+	TAILQ_INIT(&inqueue);
 	TAILQ_INIT(&outqueue);
 
 	if (!filename) {
@@ -1754,26 +1786,7 @@ conf_write(const char *filename, const char *section, const char *arg,
 		return ret;
 	}
 
-	if (asprintf(&outpath, "%s.XXXXXX", filename) == -1) {
-		xlog(L_ERROR, "conf_write: error composing temp filename");
-		return ret;
-	}
-
-	fdout = mkstemp(outpath);
-	if (fdout < 0) {
-		xlog(L_ERROR, "conf_write: open temp file %s failed: %s",
-			 outpath, strerror(errno));
-		goto cleanup;
-	}
-
-	outfile = fdopen(fdout, "w");
-	if (!outfile) {
-		xlog(L_ERROR, "conf_write: fdopen temp file failed: %s",
-			 strerror(errno));
-		goto cleanup;
-	}
-
-	infile = fopen(filename, "r");
+	infile = fopen(filename, "r+");
 	if (!infile) {
 		if (!value) {
 			xlog_warn("conf_write: config file \"%s\" not found, nothing to do", filename);
@@ -1782,18 +1795,29 @@ conf_write(const char *filename, const char *section, const char *arg,
 		}
 
 		xlog_warn("conf_write: config file \"%s\" not found, creating.", filename);
-		if (append_line(&outqueue, NULL, make_section(section, arg)))
+		infile = fopen(filename, "wx");
+		if (!infile) {
+			xlog(L_ERROR, "conf_write: Error creating config file \"%s\".", filename);
+			goto cleanup;
+		}
+
+		if (lock_file(infile))
 			goto cleanup;
 
-		if (append_line(&outqueue, NULL, make_tagline(tag, value)))
+		if (append_line(&inqueue, NULL, make_section(section, arg)))
 			goto cleanup;
 
-		if (flush_outqueue(&outqueue, outfile))
+		if (append_line(&inqueue, NULL, make_tagline(tag, value)))
 			goto cleanup;
+
+		append_queue(&inqueue, &outqueue);
 	} else {
 		bool found = false;
 		int err = 0;
 
+		if (lock_file(infile))
+			goto cleanup;
+
 		buffsize = 4096;
 		buff = calloc(1, buffsize);
 		if (buff == NULL) {
@@ -1808,7 +1832,7 @@ conf_write(const char *filename, const char *section, const char *arg,
 			/* read in one section worth of lines */
 			do {
 				if (*buff != '\0') {
-					if (append_line(&outqueue, NULL, strdup(buff)))
+					if (append_line(&inqueue, NULL, strdup(buff)))
 						goto cleanup;
 				}
 
@@ -1816,7 +1840,7 @@ conf_write(const char *filename, const char *section, const char *arg,
 			} while (err == 0 && buff[0] != '[');
 
 			/* find the section header */
-			where = TAILQ_FIRST(&outqueue);
+			where = TAILQ_FIRST(&inqueue);
 			while (where != NULL) {
 				if (where->text != NULL && where->text[0] == '[')
 					break;
@@ -1864,7 +1888,7 @@ conf_write(const char *filename, const char *section, const char *arg,
 					/* remove current tag */
 					do {
 						struct outbuffer *next = TAILQ_NEXT(where, link);
-						TAILQ_REMOVE(&outqueue, where, link);
+						TAILQ_REMOVE(&inqueue, where, link);
 						if (is_folded(where->text))
 							again = true;
 						else
@@ -1876,14 +1900,14 @@ conf_write(const char *filename, const char *section, const char *arg,
 
 					/* insert new tag */
 					if (value) {
-						if (append_line(&outqueue, prev, make_tagline(tag, value)))
+						if (append_line(&inqueue, prev, make_tagline(tag, value)))
 							goto cleanup;
 					}
 				} else
 				/* no existing assignment found and we need to add one */
 				if (value) {
 					/* rewind past blank lines and comments */
-					struct outbuffer *tail = TAILQ_LAST(&outqueue, tailhead);
+					struct outbuffer *tail = TAILQ_LAST(&inqueue, tailhead);
 
 					/* comments immediately before a section usually relate
 					 * to the section below them */
@@ -1895,7 +1919,7 @@ conf_write(const char *filename, const char *section, const char *arg,
 						tail = TAILQ_PREV(tail, tailhead, link);
 
 					/* now add the tag here */
-					if (append_line(&outqueue, tail, make_tagline(tag, value)))
+					if (append_line(&inqueue, tail, make_tagline(tag, value)))
 						goto cleanup;
 
 					found = true;
@@ -1905,49 +1929,45 @@ conf_write(const char *filename, const char *section, const char *arg,
 			/* EOF and correct section not found, so add one */
 			if (err && !found && value) {
 				/* did the last section end in a blank line */
-				struct outbuffer *tail = TAILQ_LAST(&outqueue, tailhead);
+				struct outbuffer *tail = TAILQ_LAST(&inqueue, tailhead);
 				if (tail && !is_empty(tail->text)) {
 					/* no, so add one for clarity */
-					if (append_line(&outqueue, NULL, strdup("\n")))
+					if (append_line(&inqueue, NULL, strdup("\n")))
 						goto cleanup;
 				}
 
 				/* add the new section header */
-				if (append_line(&outqueue, NULL, make_section(section, arg)))
+				if (append_line(&inqueue, NULL, make_section(section, arg)))
 					goto cleanup;
 
 				/* now add the tag */
-				if (append_line(&outqueue, NULL, make_tagline(tag, value)))
+				if (append_line(&inqueue, NULL, make_tagline(tag, value)))
 					goto cleanup;
 			}
 
-			/* we are done with this section, write it out */
-			if (flush_outqueue(&outqueue, outfile))
-				goto cleanup;
+			/* we are done with this section, move it to the out queue */
+			append_queue(&inqueue, &outqueue);
 		} while(err == 0);
 	}
 
-	if (infile) {
-		fclose(infile);
-		infile = NULL;
-	}
+	/* now rewind and overwrite the file with the updated data */
+	rewind(infile);
 
-	fdout = -1;
-	if (fclose(outfile)) {
-		xlog(L_ERROR, "Error writing config file: %s", strerror(errno));
+	if (ftruncate(fileno(infile), 0)) {
+		xlog(L_ERROR, "Error truncating config file");
 		goto cleanup;
 	}
 
-	/* now swap the old file for the new one */
-	if (rename(outpath, filename)) {
-		xlog(L_ERROR, "Error updating config file: %s: %s\n", filename, strerror(errno));
-		ret = 1;
-	} else {
-		ret = 0;
-		free(outpath);
-		outpath = NULL;
+	if (flush_outqueue(&outqueue, infile))
+		goto cleanup;
+
+	if (infile) {
+		fclose(infile);
+		infile = NULL;
 	}
 
+	ret = 0;
+
 cleanup:
 	flush_outqueue(&outqueue, NULL);
 
@@ -1955,11 +1975,5 @@ cleanup:
 		free(buff);
 	if (infile)
 		fclose(infile);
-	if (fdout != -1)
-		close(fdout);
-	if (outpath) {
-		unlink(outpath);
-		free(outpath);
-	}
 	return ret;
 }
-- 
1.8.3.1

