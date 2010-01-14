From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/24] libnsm.a: Add support for multiple lines in monitor
	record files
Date: Thu, 14 Jan 2010 12:31:19 -0500
Message-ID: <20100114173119.26079.34352.stgit@localhost.localdomain>
References: <20100114172457.26079.66627.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: chris.mason@oracle.com, linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet11.oracle.com ([148.87.113.123]:43879 "EHLO
	rcsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757365Ab0ANRbq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Jan 2010 12:31:46 -0500
In-Reply-To: <20100114172457.26079.66627.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To support IPv6, statd must support multi-homed remote peers.  For our
purposes, "multi-homed peer" means that more than one unique IP
address maps to the one canonical host name for that peer.

An SM_MON request from the local lockd has a "mon_name" argument that
statd reverse maps to a canonical hostname (ie the A record for that
host).  statd assumes the canonical hostname is unique enough that
it stores the callback data for this mon_name in a file named after
that canonical hostname.

Because lockd can't distinguish between two unique IP addresses that
may be from the same physical host, the kernel can hand statd a
mon_name that maps to the same canonical hostname as some previous
mon_name.  So that the kernel can keep this instance of the mon_name
unique, it creates a fresh priv cookie for each new address.

Note that a mon_name can be a presentation address string, or the
caller_name string sent in each NLMPROC_LOCK request.  There's
nothing that requires the caller_name to be a fully-qualified
hostname, thus it's uniqueness is not guaranteed.  The current
design of statd assumes that canonical hostnames will be unique
enough.

When a mon_name for a fresh SM_MON request maps to the same canonical
hostname as an existing monitored peer, but the priv cookie is new,
statd will try to write the information for the fresh request into an
existing monitor record file, wiping out the contents of the file.
This is because the mon_name/cookie combination won't match any record
statd already has.

Currently, statd doesn't check if a record file already exists before
writing into it.  statd's logic assumes that the svc routine has
already checked that no matching record exists in the in-core monitor
list.  And, it doesn't use O_EXCL when opening the record file.  Not
only is the old data in that file wiped out, but statd's in-core
monitor list will no longer match what's in the on-disk monitor list.

Note that IPv6 isn't needed to exercise multi-homed peer support.
Any IPv4 peer that has multiple addresses that map to its canonical
hostname will trigger this behavior.  However, this scenario will
become quite common when all hosts on a network automatically get both
an IPv4 address and an IPv6 address.

I can think of a few ways to address this:

1.  Replace the current on-disk format with a database that has a
uniqueness constraint on the monitor records

2.  Create a new file naming scheme; eg. one that uses a truly
unique name such as a hash generated from the mon_name, my_name, and
priv cookie

3.  Support multiple lines in each monitor record file

Since statd's on-disk format constitutes a formal API, options 1 and 2
are right out.  This patch implements option 3.  There are two parts:
adding a new line to an existing file; and deleting a line from a file
with more than one line.  Interestingly, the existing code already
supports reading more than one line from these files, so we don't need
to add extra code here to do that.

One file may contain a line for every unique mon_name / priv cookie
where the mon_name reverse maps to the same canonical hostname.  We
use the atomic write facility added by a previous patch to ensure the
on-disk monitor record list is updated atomically.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/nsm.h   |    6 +-
 support/nsm/file.c      |  161 ++++++++++++++++++++++++++++++++++++++++++++---
 utils/statd/monitor.c   |    6 +-
 utils/statd/sm-notify.c |    5 +
 4 files changed, 162 insertions(+), 16 deletions(-)

diff --git a/support/include/nsm.h b/support/include/nsm.h
index ce9e294..fb4d823 100644
--- a/support/include/nsm.h
+++ b/support/include/nsm.h
@@ -58,8 +58,10 @@ extern unsigned int
 
 extern _Bool	nsm_insert_monitored_host(const char *hostname,
 			const struct sockaddr *sap, const struct mon *m);
-extern void	nsm_delete_monitored_host(const char *hostname);
-extern void	nsm_delete_notified_host(const char *hostname);
+extern void	nsm_delete_monitored_host(const char *hostname,
+			const char *mon_name, const char *my_name);
+extern void	nsm_delete_notified_host(const char *hostname,
+			const char *mon_name, const char *my_name);
 extern size_t	nsm_priv_to_hex(const char *priv, char *buf,
 				const size_t buflen);
 
diff --git a/support/nsm/file.c b/support/nsm/file.c
index 10769d9..8796705 100644
--- a/support/nsm/file.c
+++ b/support/nsm/file.c
@@ -625,6 +625,56 @@ nsm_create_monitor_record(char *buf, const size_t buflen,
 	return buflen - remaining;
 }
 
+static _Bool
+nsm_append_monitored_host(const char *path, const char *line)
+{
+	_Bool result = false;
+	char *buf = NULL;
+	struct stat stb;
+	size_t buflen;
+	ssize_t len;
+	int fd;
+
+	if (stat(path, &stb) == -1) {
+		xlog(L_ERROR, "Failed to insert: "
+			"could not stat original file %s: %m", path);
+		goto out;
+	}
+	buflen = (size_t)stb.st_size + strlen(line);
+
+	buf = malloc(buflen + 1);
+	if (buf == NULL) {
+		xlog(L_ERROR, "Failed to insert: no memory");
+		goto out;
+	}
+	memset(buf, 0, buflen + 1);
+
+	fd = open(path, O_RDONLY);
+	if (fd == -1) {
+		xlog(L_ERROR, "Failed to insert: "
+			"could not open original file %s: %m", path);
+		goto out;
+	}
+
+	len = read(fd, buf, (size_t)stb.st_size);
+	if (exact_error_check(len, (size_t)stb.st_size)) {
+		xlog(L_ERROR, "Failed to insert: "
+			"could not read original file %s: %m", path);
+		(void)close(fd);
+		goto out;
+	}
+	(void)close(fd);
+
+	strcat(buf, line);
+
+	if (nsm_atomic_write(path, buf, buflen))
+		result = true;
+
+out:
+	free(buf);
+	return result;
+}
+
 /**
  * nsm_insert_monitored_host - write callback data for one host to disk
  * @hostname: C string containing a hostname
@@ -657,9 +707,18 @@ nsm_insert_monitored_host(const char *hostname, const struct sockaddr *sap,
 		goto out;
 	}
 
-	fd = open(path, O_WRONLY | O_CREAT | O_SYNC, S_IRUSR | S_IWUSR);
+	/*
+	 * If exclusive create fails, we're adding a new line to an
+	 * existing file.
+	 */
+	fd = open(path, O_WRONLY | O_CREAT | O_EXCL | O_SYNC, S_IRUSR | S_IWUSR);
 	if (fd == -1) {
-		xlog(L_ERROR, "Failed to insert: creating %s: %m", path);
+		if (errno != EEXIST) {
+			xlog(L_ERROR, "Failed to insert: creating %s: %m", path);
+			goto out;
+		}
+
+		result = nsm_append_monitored_host(path, buf);
 		goto out;
 	}
 	result = true;
@@ -848,9 +907,15 @@ nsm_load_notify_list(nsm_populate_t func)
 }
 
 static void
-nsm_delete_host(const char *directory, const char *hostname)
+nsm_delete_host(const char *directory, const char *hostname,
+		const char *mon_name, const char *my_name)
 {
-	char *path;
+	char line[LINELEN + 1 + SM_MAXSTRLEN + 2];
+	char *outbuf = NULL;
+	struct stat stb;
+	char *path, *next;
+	size_t remaining;
+	FILE *f;
 
 	path = nsm_make_record_pathname(directory, hostname);
 	if (path == NULL) {
@@ -858,30 +923,106 @@ nsm_delete_host(const char *directory, const char *hostname)
 		return;
 	}
 
-	if (unlink(path) == -1)
-		xlog(L_ERROR, "Failed to unlink %s: %m", path);
+	if (stat(path, &stb) == -1) {
+		xlog(L_ERROR, "Failed to delete: "
+			"could not stat original file %s: %m", path);
+		goto out;
+	}
+	remaining = (size_t)stb.st_size + 1;
 
+	outbuf = malloc(remaining);
+	if (outbuf == NULL) {
+		xlog(L_ERROR, "Failed to delete: no memory");
+		goto out;
+	}
+
+	f = fopen(path, "r");
+	if (f == NULL) {
+		xlog(L_ERROR, "Failed to delete: "
+			"could not open original file %s: %m", path);
+		goto out;
+	}
+
+	/*
+	 * Walk the records in the file, and copy the non-matching
+	 * ones to our output buffer.
+	 */
+	next = outbuf;
+	while (fgets(line, (int)sizeof(line), f) != NULL) {
+		struct sockaddr_in sin;
+		struct mon m;
+		size_t len;
+
+		if (!nsm_parse_line(line, &sin, &m)) {
+			xlog(L_ERROR, "Failed to delete: "
+				"could not parse original file %s", path);
+			(void)fclose(f);
+			goto out;
+		}
+
+		if (strcmp(mon_name, m.mon_id.mon_name) == 0 &&
+			 strcmp(my_name, m.mon_id.my_id.my_name) == 0)
+			continue;
+
+		/* nsm_parse_line destroys the contents of line[], so
+		 * reconstruct the copy in our output buffer. */
+		len = nsm_create_monitor_record(next, remaining,
+					(struct sockaddr *)(char *)&sin, &m);
+		if (len == 0) {
+			xlog(L_ERROR, "Failed to delete: "
+				"could not construct output record");
+			(void)fclose(f);
+			goto out;
+		}
+		next += len;
+		remaining -= len;
+	}
+
+	(void)fclose(f);
+
+	/*
+	 * If nothing was copied when we're done, then unlink the file.
+	 * Otherwise, atomically update the contents of the file.
+	 */
+	if (next != outbuf) {
+		if (!nsm_atomic_write(path, outbuf, strlen(outbuf)))
+			xlog(L_ERROR, "Failed to delete: "
+				"could not write new file %s: %m", path);
+	} else {
+		if (unlink(path) == -1)
+			xlog(L_ERROR, "Failed to delete: "
+				"could not unlink file %s: %m", path);
+	}
+
+out:
+	free(outbuf);
 	free(path);
 }
 
 /**
  * nsm_delete_monitored_host - delete on-disk record for monitored host
  * @hostname: '\0'-terminated C string containing hostname of record to delete
+ * @mon_name: '\0'-terminated C string containing monname of record to delete
+ * @my_name: '\0'-terminated C string containing myname of record to delete
  *
  */
 void
-nsm_delete_monitored_host(const char *hostname)
+nsm_delete_monitored_host(const char *hostname, const char *mon_name,
+		const char *my_name)
 {
-	nsm_delete_host(NSM_MONITOR_DIR, hostname);
+	nsm_delete_host(NSM_MONITOR_DIR, hostname, mon_name, my_name);
 }
 
 /**
  * nsm_delete_notified_host - delete on-disk host record after notification
  * @hostname: '\0'-terminated C string containing hostname of record to delete
+ * @mon_name: '\0'-terminated C string containing monname of record to delete
+ * @my_name: '\0'-terminated C string containing myname of record to delete
  *
  */
 void
-nsm_delete_notified_host(const char *hostname)
+nsm_delete_notified_host(const char *hostname, const char *mon_name,
+		const char *my_name)
 {
-	nsm_delete_host(NSM_NOTIFY_DIR, hostname);
+	nsm_delete_host(NSM_NOTIFY_DIR, hostname, mon_name, my_name);
 }
diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index 5bedb3e..fb32196 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -315,7 +315,8 @@ sm_unmon_1_svc(struct mon_id *argp, struct svc_req *rqstp)
 			/* PRC: do the HA callout: */
 			ha_callout("del-client", mon_name, my_name, -1);
 
-			nsm_delete_monitored_host(clnt->dns_name);
+			nsm_delete_monitored_host(clnt->dns_name,
+							mon_name, my_name);
 			nlist_free(&rtnl, clnt);
 
 			return (&result);
@@ -369,7 +370,8 @@ sm_unmon_all_1_svc(struct my_id *argp, struct svc_req *rqstp)
 			temp = NL_NEXT(clnt);
 			/* PRC: do the HA callout: */
 			ha_callout("del-client", mon_name, my_name, -1);
-			nsm_delete_monitored_host(clnt->dns_name);
+			nsm_delete_monitored_host(clnt->dns_name,
+							mon_name, my_name);
 			nlist_free(&rtnl, clnt);
 			++count;
 			clnt = temp;
diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index 70d94a8..3259a3e 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -130,9 +130,10 @@ out_nomem:
 
 static void smn_forget_host(struct nsm_host *host)
 {
-	xlog(D_CALL, "Removing %s from notify list", host->name);
+	xlog(D_CALL, "Removing %s (%s, %s) from notify list",
+			host->name, host->mon_name, host->my_name);
 
-	nsm_delete_notified_host(host->name);
+	nsm_delete_notified_host(host->name, host->mon_name, host->my_name);
 
 	free(host->my_name);
 	free(host->mon_name);

