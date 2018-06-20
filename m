Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:44958 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S932225AbeFTMNb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 20 Jun 2018 08:13:31 -0400
Received: from smtp.corp.redhat.com (int-mx06.intmail.prod.int.rdu2.redhat.com [10.11.54.6])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 38F8E40200A7
        for <linux-nfs@vger.kernel.org>; Wed, 20 Jun 2018 12:13:31 +0000 (UTC)
Message-ID: <1529496808.7473.12.camel@redhat.com>
Subject: [PATCH 4/5] nfs-utils: Add config file writing function
From: Justin Mitchell <jumitche@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Cc: Steve Dickson <steved@redhat.com>
Date: Wed, 20 Jun 2018 13:13:28 +0100
In-Reply-To: <1529496583.7473.8.camel@redhat.com>
References: <1529496583.7473.8.camel@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Adds a function to nfsconf handling to write a single config
entry, creating the file and section headers as required.

Signed-off-by: Justin Mitchell <jumitche@redhat.com>
---
 support/include/conffile.h |   1 +
 support/nfs/conffile.c     | 621 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 622 insertions(+)

diff --git a/support/include/conffile.h b/support/include/conffile.h
index bc2d61f..a3340f9 100644
--- a/support/include/conffile.h
+++ b/support/include/conffile.h
@@ -67,6 +67,7 @@ extern int      conf_match_num(const char *, const char *, int);
 extern int      conf_remove(int, const char *, const char *);
 extern int      conf_remove_section(int, const char *);
 extern void     conf_report(FILE *);
+extern int      conf_write(const char *, const char *, const char *, const char *, const char *);
 
 /*
  * Convert letter from upper case to lower case
diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index c7c3a62..c2dbced 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -1323,3 +1323,624 @@ cleanup:
 	}
 	return;
 }
+
+/* struct and queue for buffing output lines */
+TAILQ_HEAD(tailhead, outbuffer);
+
+struct outbuffer {
+	TAILQ_ENTRY(outbuffer) link;
+	char *text;
+};
+
+static struct outbuffer *
+make_outbuffer(char *line)
+{
+	struct outbuffer *new;
+
+	if (line == NULL)
+		return NULL;
+
+	new = calloc(1, sizeof(struct outbuffer));
+	if (new == NULL) {
+		xlog(L_ERROR, "malloc error creating outbuffer");
+		return NULL;
+	}
+	new->text = line;
+	return new;
+}
+
+/* compose a properly escaped tag=value line */
+static char *
+make_tagline(const char *tag, const char *value)
+{
+	char *line;
+	int ret;
+
+	if (!value)
+		return NULL;
+
+	if (should_escape(value))
+		ret = asprintf(&line, "%s = \"%s\"\n", tag, value);
+	else
+		ret = asprintf(&line, "%s = %s\n", tag, value);
+
+	if (ret == -1) {
+		xlog(L_ERROR, "malloc error composing a tag line");
+		return NULL;
+	}
+	return line;
+}
+
+/* compose a section header line */
+static char *
+make_section(const char *section, const char *arg)
+{
+	char *line;
+	int ret;
+
+	if (arg)
+		ret = asprintf(&line, "[%s \"%s\"]\n", section, arg);
+	else
+		ret = asprintf(&line, "[%s]\n", section);
+
+	if (ret == -1) {
+		xlog(L_ERROR, "malloc error composing section header");
+		return NULL;
+	}
+	return line;
+}
+
+/* does the supplied line contain the named section header */
+static bool
+is_section(const char *line, const char *section, const char *arg)
+{
+	char *end;
+	char *name;
+	char *sub;
+	bool found = false;
+
+	/* skip leading white space */
+	while (*line == '[' || isspace(*line))
+		line++;
+
+	name = strdup(line);
+	if (name == NULL) {
+		xlog_warn("conf_write: malloc failed ");
+		return false;
+	}
+
+	/* find the end */
+	end = strchr(name, ']');
+
+	/* malformed line */
+	if (end == NULL) {
+		xlog_warn("conf_write: warning: malformed section name");
+		goto cleanup;
+	}
+
+	while (*end && ( *end == ']' || isblank(*end)))
+		*(end--) = '\0';
+
+	/* is there a subsection name (aka arg) */
+	sub = strchr(name, '"');
+	if (sub) {
+		end = sub - 1;
+		*(sub++) = '\0';
+
+		/* trim whitespace between section name and arg */
+		while (end > name && isblank(*end))
+			*(end--) = '\0';
+
+		/* trim off closing quote */
+		end = strchr(sub, '"');
+		if (end == NULL) {
+			xlog_warn("conf_write: warning: malformed sub-section name");
+			goto cleanup;
+		}
+		*end = '\0';
+	}
+
+	/* ready to compare */
+	if (strcasecmp(section, name)!=0)
+		goto cleanup;
+
+	if (arg != NULL) {
+		if (sub == NULL || strcasecmp(arg, sub)!=0)
+			goto cleanup;
+	} else {
+		if (sub != NULL)
+			goto cleanup;
+	}
+
+	found = true;
+
+cleanup:
+	free(name);
+	return found;
+}
+
+/* check that line contains the specified tag assignment */
+static bool
+is_tag(const char *line, const char *tagname)
+{
+	char *end;
+	char *name;
+	bool found = false;
+
+	/* quick check, is this even an assignment line */
+	end = strchr(line, '=');
+	if (end == NULL)
+		return false;
+
+	/* skip leading white space before tag name */
+	while (isblank(*line))
+		line++;
+
+	name = strdup(line);
+	if (name == NULL) {
+		xlog_warn("conf_write: malloc failed");
+		return false;
+	}
+
+	/* trim any newline characters */
+	end = strchr(name, '\n');
+	if (end)
+		*end = '\0';
+	end = strchr(name, '\r');
+	if (end)
+		*end = '\0';
+
+	/* find the assignment equals sign */
+	end = strchr(name, '=');
+
+	/* malformed line, i swear the equals was there earlier */
+	if (end == NULL) {
+		xlog_warn("conf_write: warning: malformed tag name");
+		goto cleanup;
+	}
+
+	/* trim trailing whitespace after tag name */
+	do {
+		*(end--) = '\0';
+	}while (end > name && *end && isblank(*end));
+
+	/* quoted string, take contents of quotes only */
+	if (*name == '"') {
+		char * new = strdup(name+1);
+		end = strchr(new, '"');
+		if (end != NULL) {
+			*end = 0;
+			free(name);
+			name = new;
+		} else {
+			free(new);
+		}
+	}
+
+	/* now compare */
+	if (strcasecmp(tagname, name) == 0)
+		found = true;
+
+cleanup:
+	free(name);
+	return found;
+}
+
+/* is this an empty line ? */
+static bool
+is_empty(const char *line)
+{
+	const char *p = line;
+
+	if (line == NULL)
+		return true;
+	if (*line == '\0')
+		return true;
+
+	while (*p != '\0' && isspace(*p))
+		p++;
+
+	if (*p == '\0')
+		return true;
+
+	return false;
+}
+
+/* is this line just a comment ? */
+static bool
+is_comment(const char *line)
+{
+	if (line == NULL)
+		return false;
+
+	while (isblank(*line))
+		line++;
+
+	if (*line == '#')
+		return true;
+
+	return false;
+}
+
+/* delete a buffer queue whilst optionally outputting to file */
+static int
+flush_outqueue(struct tailhead *queue, FILE *fout)
+{
+	int ret = 0;
+	while (queue->tqh_first != NULL) {
+		struct outbuffer *ob = queue->tqh_first;
+		TAILQ_REMOVE(queue, ob, link);
+		if (ob->text) {
+			if (fout) {
+				ret = fprintf(fout, "%s", ob->text);
+				if (ret == -1) {
+					xlog(L_ERROR, "Error writing to config file: %s",
+						 strerror(errno));
+					fout = NULL;
+				}
+			}
+			free(ob->text);
+		}
+		free(ob);
+	}
+	if (ret == -1)
+		return 1;
+	return 0;
+}
+
+/* read one line of text from a file, growing the buffer as necessary */
+static int
+read_line(char **buff, int *buffsize, FILE *in)
+{
+	char *readp;
+	int used = 0;
+	bool again = false;
+
+	/* make sure we have a buffer to read into */
+	if (*buff == NULL) {
+		*buffsize = 4096;
+		*buff = calloc(1, *buffsize);
+		if (*buff == NULL) {
+			xlog(L_ERROR, "malloc error for read buffer");
+			return -1;
+		}
+	}
+
+	readp = *buff;
+
+	do {
+		int len;
+
+		/* read in a chunk */
+		if (fgets(readp, *buffsize-used, in)==NULL)
+			return -1;
+
+		len = strlen(*buff);
+		if (len == 0)
+			return -1;
+
+		/* was this the end of a line, or partial read */
+		readp = *buff + len - 1;
+
+		if (*readp != '\n' && *readp !='\r') {
+			/* no nl/cr must be partial read, go again */
+			readp++;
+			again = true;
+		} else {
+			/* that was a normal end of line */
+			again = false;
+		}
+
+		/* do we need more space */
+		if (again && *buffsize - len < 1024) {
+			int offset = readp - *buff;
+			char *newbuff;
+			*buffsize += 4096;
+			newbuff = realloc(*buff, *buffsize);
+			if (newbuff == NULL) {
+				xlog(L_ERROR, "malloc error reading line");
+				return -1;
+			}
+			*buff = newbuff;
+			readp = newbuff + offset;
+		}
+	} while(again);
+	return 0;
+}
+
+/* append a line to the given location in the queue */
+static int
+append_line(struct tailhead *queue, struct outbuffer *entry, char *line)
+{
+	int ret = 0;
+	char *end;
+	bool splitmode = false;
+	char *start = line;
+
+	if (line == NULL)
+		return -1;
+
+	/* if there are \n's in the middle of the string
+	 * then we need to split it into folded lines */
+	do {
+		char *thisline;
+		struct outbuffer *qbuff;
+
+		end = strchr(start, '\n');
+		if (end && *(end+1) != '\0') {
+			*end = '\0';
+
+			ret = asprintf(&thisline, "%s\\\n", start);
+			if (ret == -1) {
+				xlog(L_ERROR, "malloc error composing output");
+				return -1;
+			}
+			splitmode = true;
+			start = end+1;
+		} else {
+			end = NULL;
+			if (splitmode) {
+				thisline = strdup(start);
+				if (thisline == NULL)
+					return -1;
+			} else {
+				thisline = start;
+			}
+		}
+
+		qbuff = make_outbuffer(thisline);
+		if (qbuff == NULL)
+			return -1;
+
+		if (entry) {
+			TAILQ_INSERT_AFTER(queue, entry, qbuff, link);
+			entry = TAILQ_NEXT(entry, link);
+		} else {
+			TAILQ_INSERT_TAIL(queue, qbuff, link);
+		}
+	}while (end != NULL);
+
+	/* we malloced copies of this, so free the original */
+	if (splitmode)
+		free(line);
+
+	return 0;
+}
+
+/* is this a "folded" line, i.e. ends in backslash */
+static bool
+is_folded(const char *line)
+{
+	const char *end;
+	if (line == NULL)
+		return false;
+
+	end = line + strlen(line);
+	while (end > line) {
+		end--;
+		if (*end != '\n' && *end != '\r')
+			break;
+	}
+
+	if (*end == '\\')
+		return true;
+
+	return false;
+}
+
+/***
+ * Write a value to an nfs.conf style filename
+ *
+ * create the file if it doesnt already exist
+ * if value==NULL removes the setting (if present)
+ */
+int
+conf_write(const char *filename, const char *section, const char *arg,
+	   const char *tag, const char *value)
+{
+	int fdout = -1;
+	char *outpath = NULL;
+	FILE *outfile = NULL;
+	FILE *infile = NULL;
+	int ret = 1;
+	struct tailhead outqueue;
+	char * buff = NULL;
+	int buffsize = 0;
+
+	TAILQ_INIT(&outqueue);
+
+	if (!filename) {
+		xlog_warn("conf_write: no filename supplied");
+		return ret;
+	}
+
+	if (!section || !tag) {
+		xlog_warn("conf_write: section or tag name missing");
+		return ret;
+	}
+
+	if (asprintf(&outpath, "%s.XXXXXX", filename) == -1) {
+		xlog(L_ERROR, "conf_write: error composing temp filename");
+		return ret;
+	}
+
+	fdout = mkstemp(outpath);
+	if (fdout < 0) {
+		xlog(L_ERROR, "conf_write: open temp file %s failed: %s",
+			 outpath, strerror(errno));
+		goto cleanup;
+	}
+
+	outfile = fdopen(fdout, "w");
+	if (!outfile) {
+		xlog(L_ERROR, "conf_write: fdopen temp file failed: %s",
+			 strerror(errno));
+		goto cleanup;
+	}
+
+	infile = fopen(filename, "r");
+	if (!infile) {
+		if (!value) {
+			xlog_warn("conf_write: config file \"%s\" not found, nothing to do", filename);
+			ret = 0;
+			goto cleanup;
+		}
+
+		xlog_warn("conf_write: config file \"%s\" not found, creating.", filename);
+		if (append_line(&outqueue, NULL, make_section(section, arg)))
+			goto cleanup;
+
+		if (append_line(&outqueue, NULL, make_tagline(tag, value)))
+			goto cleanup;
+
+		if (flush_outqueue(&outqueue, outfile))
+			goto cleanup;
+	} else {
+		bool found = false;
+		int err = 0;
+
+		buffsize = 4096;
+		buff = calloc(1, buffsize);
+		if (buff == NULL) {
+			xlog(L_ERROR, "malloc error for read buffer");
+			goto cleanup;
+		}
+
+		buff[0] = '\0';
+		do {
+			struct outbuffer *where = NULL;
+
+			/* read in one section worth of lines */
+			do {
+				if (*buff != '\0') {
+					if (append_line(&outqueue, NULL, strdup(buff)))
+						goto cleanup;
+				}
+
+				err = read_line(&buff, &buffsize, infile);
+			} while (err == 0 && buff[0] != '[');
+
+			/* find the section header */
+			where = TAILQ_FIRST(&outqueue);
+			while (where != NULL) {
+				if (where->text != NULL && where->text[0] == '[')
+					break;
+				where = TAILQ_NEXT(where, link);
+			}
+
+			/* this is the section we care about */
+			if (where != NULL && is_section(where->text, section, arg)) {
+				/* is there an existing assignment */
+				while ((where = TAILQ_NEXT(where, link)) != NULL) {
+					if (is_tag(where->text, tag)) {
+						found = true;
+						break;
+					}
+				}
+
+				if (found) {
+					struct outbuffer *prev = TAILQ_PREV(where, tailhead, link);
+					bool again = false;
+
+					/* remove current tag */
+					do {
+						struct outbuffer *next = TAILQ_NEXT(where, link);
+						TAILQ_REMOVE(&outqueue, where, link);
+						if (is_folded(where->text))
+							again = true;
+						else
+							again = false;
+						free(where->text);
+						free(where);
+						where = next;
+					} while(again && where != NULL);
+
+					/* insert new tag */
+					if (value) {
+						if (append_line(&outqueue, prev, make_tagline(tag, value)))
+							goto cleanup;
+					}
+				} else
+				/* no existing assignment found and we need to add one */
+				if (value) {
+					/* rewind past blank lines and comments */
+					struct outbuffer *tail = TAILQ_LAST(&outqueue, tailhead);
+
+					/* comments immediately before a section usually relate
+					 * to the section below them */
+					while (tail != NULL && is_comment(tail->text))
+						tail = TAILQ_PREV(tail, tailhead, link);
+
+					/* there is usually blank line(s) between sections */
+					while (tail != NULL && is_empty(tail->text))
+						tail = TAILQ_PREV(tail, tailhead, link);
+
+					/* now add the tag here */
+					if (append_line(&outqueue, tail, make_tagline(tag, value)))
+						goto cleanup;
+
+					found = true;
+				}
+			}
+
+			/* EOF and correct section not found, so add one */
+			if (err && !found && value) {
+				/* did the last section end in a blank line */
+				struct outbuffer *tail = TAILQ_LAST(&outqueue, tailhead);
+				if (tail && !is_empty(tail->text)) {
+					/* no, so add one for clarity */
+					if (append_line(&outqueue, NULL, strdup("\n")))
+						goto cleanup;
+				}
+
+				/* add the new section header */
+				if (append_line(&outqueue, NULL, make_section(section, arg)))
+					goto cleanup;
+
+				/* now add the tag */
+				if (append_line(&outqueue, NULL, make_tagline(tag, value)))
+					goto cleanup;
+			}
+
+			/* we are done with this section, write it out */
+			if (flush_outqueue(&outqueue, outfile))
+				goto cleanup;
+		} while(err == 0);
+	}
+
+	if (infile) {
+		fclose(infile);
+		infile = NULL;
+	}
+
+	fdout = -1;
+	if (fclose(outfile)) {
+		xlog(L_ERROR, "Error writing config file: %s", strerror(errno));
+		goto cleanup;
+	}
+
+	/* now swap the old file for the new one */
+	if (rename(outpath, filename)) {
+		xlog(L_ERROR, "Error updating config file: %s: %s\n", filename, strerror(errno));
+		ret = 1;
+	} else {
+		ret = 0;
+		free(outpath);
+		outpath = NULL;
+	}
+
+cleanup:
+	flush_outqueue(&outqueue, NULL);
+
+	if (buff)
+		free(buff);
+	if (infile)
+		fclose(infile);
+	if (fdout != -1)
+		close(fdout);
+	if (outpath) {
+		unlink(outpath);
+		free(outpath);
+	}
+	return ret;
+}
-- 
1.8.3.1



