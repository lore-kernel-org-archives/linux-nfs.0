Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2DBCD4A3867
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 16:25:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789143945; cv=none; b=kRPejGlH27D5MrC2cilE3ZQfHuoq1AdYs+2rf47Nqk9MX7FhtRSpfaDCFyvgh7CX9Dx+8rx6Fk5GzLq1Rgpb6dx23lv3V7S1s5R5FHSG3LduhjV5SM/cMqiHBceiCkY8PKFQSzFIrJdaIxEpqIPV7Jb+Gr7XMUuwyBCYa2HO9eo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789143945; c=relaxed/simple;
	bh=QYlf+JesxBlJSYauupuIY/ODUtZ3uo3pez2Y2EJfcm0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=txRTPLeApZZbLipO8sGQ83hC5aVEoq3ujhG2fkSEyM5PCA1v7X/0Vws4VE1IAfyzsAxzsxlMNB2qFkyEr4Hx5SSL0+XUjcKty62+6Zyl7K5HHcK37k7f+vyDevbZfXAkbblmsFfqdbzVAUyt1K6kYwZZi8irTTy1ylSkE+6x+0c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=guG2TAWR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="guG2TAWR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 878221F0089A;
	Fri, 11 Sep 2026 16:25:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789143942;
	bh=+O+MoTCqoo37+x56CACMyxN7wU2AAWtuDfrRWVBgcQk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=guG2TAWRqJMvYWMeQUp1UHFfb65efl8Xk0b9zmQ99opE4ZfSAzRn9ofFxdv1gw/le
	 hharhUyNMGeNlbORIoDvYOvxT3fZTFE2yVKDtOHFNfnAJKV7KD4JFsweS2kLUQBbRu
	 kf2/GU9n89s9KQXZLIRcpD42OSQZpSvor41ndmPJioYgGbC80XWbAF3PodxjOS1lYH
	 SdbXT+PKAw8XlGmGEuv6+sZaCOYn+pmF3aPSXfbyarTbS2Fh1t7pXg8H3W79mNJonC
	 pkKNLbO+wPePhbd9RSiWP8ifN3Uo2QI7C6beCS6LiCyvagbKlpId0M7qQDtmxNDlNE
	 KNccN8l/oL4KA==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 11 Sep 2026 12:25:27 -0400
Subject: [PATCH nfs-utils v2 02/10] mountd: handle unmountable paths and
 junctions in the netlink downcall
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260911-nl-crossmnt-v2-2-f4d869951c5e@kernel.org>
References: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
In-Reply-To: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=11825; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=QYlf+JesxBlJSYauupuIY/ODUtZ3uo3pez2Y2EJfcm0=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqpCuDTMaTimKCZuGVT+q8Up6WToqKvesZBbhwG
 H9esVOi9MKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqQrgwAKCRAADmhBGVaC
 Fa1OD/9mi3R+Awz9D6GGJs0giOl37iSExAXPMsExPo9+RuBatt0COsxfX8H41dxuZq7RZCrtJrB
 ZZJ1muzQtxt71y7mAkFHd6HQMP8u8zkQ9cRLNht99IdOYjQzEdBHnyw5XFqEKlpxOX8RmspyB0v
 NulauDYh+Elifyw+TVV8Df8gWRLF2lfAEIfX44/NDVc+qCXQxE2vaSzTaxsASV95r9FChBoGLwd
 J3XuHWIFnRxRYC/PceTTkHnv6Fdn+ogJu0ILlItNoTPByypiPtMvfalu1gEb7xvTXRM9IzBeNRb
 IBaH/Cyc+zB9FnN3U9rz3hjngyegznsaZrWLU8jZ5q7yJu/a13szEIUTWe3r8jt6NsvWMVN16f/
 mMpogT7FyBcxxOY3rnIHXr3b/iuxa0WDKiYeOpbWdrzH9BstFGdLCtTGy8ri5R5ogVbpzlMqz4g
 2TP9/fHuZE0X1avTU3gBm5iJm7RkxWgu/Vsj4Deq2w5CCJuU1u+FcyxXgRWbhwZn5O5NxRYxWL0
 o6aCchDan8LtxvloFdOJwUGC8WfeWRLGOaL/+U01T4KEhP9/Jp+8Lz2O7fbLvOqs4I6V/dhqL1Z
 x+MIW5UpU0PJIoK+ef6BNNKc7zzPBp4p+TtKD4Cy4r4lAMuyrc2t0bND7+jPZ6X0dUh8E/zezpe
 lyJdi0giC//ritg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Two things nfsd_export() does that cache_nl_process_export() did not:

 - If is_mountpoint() fails with an error that isn't a plain lookup
   failure, we can't tell whether the export is available.  Defer the
   request instead of answering "not exported".

 - When no export matches, check for a junction before denying, so
   referrals still work.  Only when the client resolved, as nfsd_export()
   does: client_check() dereferences the addrinfo for wildcard and
   netgroup clients.

Split lookup_nonexport() so both downcalls share the junction lookup, and
factor the per-request work into nl_add_export_req() so the deferred path
can reuse it.  Deferred requests go on their own list, deduped on
(client, path) and retried from cache_process() every RETRY_SEC.  The
kernel keeps the upcall pending in the meantime.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/cache.c | 324 +++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 258 insertions(+), 66 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index e8b13409ad7a..0ad98c539407 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -784,6 +784,18 @@ struct delayed {
 	struct delayed *next;
 } *delayed;
 
+/* Fold one retry queue head's deadline into the running minimum */
+static time_t retry_delay(time_t *last_attempt, time_t now, time_t delay)
+{
+	time_t d;
+
+	if (*last_attempt > now)
+		/* Clock updated - retry immediately */
+		*last_attempt = now - RETRY_SEC;
+	d = *last_attempt + RETRY_SEC - now;
+	return d < delay ? d : delay;
+}
+
 static int nfsd_handle_fh(int f, char *bp, int blen)
 {
 	/* request are:
@@ -1162,8 +1174,18 @@ static int export_attrs_build(struct export_attrs *ea, char *path,
  * NFSD_CMD_SVC_EXPORT_SET_REQS.
  */
 static nfs_export *lookup_export(char *dom, char *path, struct addrinfo *ai);
+static struct exportent *lookup_nonexport_ent(char *dom, char *path,
+					      struct addrinfo *ai);
 static struct nl_msg *cache_nl_new_msg(int family, int cmd, int flags);
 
+static void free_junction(struct exportent *eep)
+{
+	if (!eep)
+		return;
+	exportent_release(eep);
+	free(eep);
+}
+
 static struct nl_sock *nfsd_nl_notify_sock;	/* multicast notifications */
 static struct nl_sock *nfsd_nl_cmd_sock;	/* GET_REQS / SET_REQS commands */
 static int nfsd_nl_family;
@@ -1632,6 +1654,197 @@ static int cache_nl_set_reqs(struct nl_sock *sock, struct nl_msg *msg)
 	return ret;
 }
 
+static bool nl_msg_has_reqs(struct nl_msg *msg)
+{
+	return genlmsg_attrlen(nlmsg_data(nlmsg_hdr(msg)), 0) > 0;
+}
+
+enum export_result {
+	EXPORT_ANSWERED,
+	EXPORT_RETRY,		/* not resolvable yet, ask again later */
+	EXPORT_NOMEM,		/* *msgp is gone, caller must give up */
+};
+
+/*
+ * Resolve one svc_export request and append the answer to *msgp, sending
+ * and replacing the message if it fills up.
+ */
+static enum export_result nl_add_export_req(struct nl_msg **msgp, char *dom,
+					    char *path)
+{
+	struct addrinfo *ai = NULL;
+	nfs_export *found = NULL;
+	struct exportent *epp = NULL;
+	struct exportent *junction = NULL;
+	enum export_result res = EXPORT_ANSWERED;
+	int ttl = 0;
+
+	if (is_ipaddr_client(dom)) {
+		ai = lookup_client_addr(dom);
+		if (!ai)
+			xlog(D_AUTH, "%s: failed to resolve client %s",
+			     __func__, dom);
+	}
+
+	if (ai || !is_ipaddr_client(dom)) {
+		found = lookup_export(dom, path, ai);
+		if (!found) {
+			junction = lookup_nonexport_ent(dom, path, ai);
+			epp = junction;
+		}
+	}
+
+	if (found) {
+		char *mp = found->m_export.e_mountpoint;
+
+		if (mp && !*mp)
+			mp = found->m_export.e_path;
+		errno = 0;
+		if (mp && !is_mountpoint(mp)) {
+			/*
+			 * A strange error means we can't tell whether it is a
+			 * mountpoint.  Retry later rather than answer wrongly.
+			 */
+			if (errno != 0 && !path_lookup_error(errno)) {
+				res = EXPORT_RETRY;
+				goto out;
+			}
+			/* Exportpoint is not mounted, so tell kernel it
+			 * is not available.  This will cause it not to
+			 * appear in the V4 Pseudo-root, so a "mount" of
+			 * this path will fail, just like with V3.
+			 */
+			xlog(L_WARNING,
+			     "Cannot export path '%s': not a mountpoint", path);
+			ttl = 60;
+		} else {
+			epp = &found->m_export;
+		}
+	}
+
+	if (nfsd_nl_add_export(*msgp, dom, path, epp, ttl) < 0) {
+		cache_nl_set_reqs(nfsd_nl_cmd_sock, *msgp);
+		nlmsg_free(*msgp);
+		*msgp = cache_nl_new_msg(nfsd_nl_family,
+					 NFSD_CMD_SVC_EXPORT_SET_REQS, 0);
+		if (!*msgp) {
+			res = EXPORT_NOMEM;
+			goto out;
+		}
+		if (nfsd_nl_add_export(*msgp, dom, path, epp, ttl) < 0)
+			xlog(L_WARNING, "%s: skipping oversized entry for %s",
+			     __func__, path);
+	}
+out:
+	free_junction(junction);
+	nfs_freeaddrinfo(ai);
+	return res;
+}
+
+/*
+ * is_mountpoint() can fail with a strange error - the ETIMEDOUT a re-exported
+ * "softerr" NFS mount can give, say - leaving us unable to say whether the
+ * path is exportable.  Set the request aside and try again later.
+ */
+struct delayed_export {
+	char			*client;
+	char			*path;
+	time_t			last_attempt;
+	struct delayed_export	*next;
+};
+
+static struct delayed_export *delayed_export;
+
+static void delayed_export_enqueue(struct delayed_export *d)
+{
+	struct delayed_export **dp = &delayed_export;
+
+	d->last_attempt = time(NULL);
+	d->next = NULL;
+	while (*dp)
+		dp = &(*dp)->next;
+	*dp = d;
+}
+
+static void delayed_export_free(struct delayed_export *d)
+{
+	free(d->client);
+	free(d->path);
+	free(d);
+}
+
+static void delayed_export_flush(void)
+{
+	while (delayed_export) {
+		struct delayed_export *d = delayed_export;
+
+		delayed_export = d->next;
+		delayed_export_free(d);
+	}
+}
+
+static void nl_delay_export(char *dom, char *path)
+{
+	struct delayed_export *d;
+
+	for (d = delayed_export; d; d = d->next)
+		if (!strcmp(d->client, dom) && !strcmp(d->path, path))
+			return;
+
+	d = calloc(1, sizeof(*d));
+	if (!d)
+		return;
+
+	d->client = strdup(dom);
+	d->path = strdup(path);
+	if (!d->client || !d->path) {
+		delayed_export_free(d);
+		return;
+	}
+
+	delayed_export_enqueue(d);
+}
+
+/*
+ * Retry the oldest deferred request if it is due.  Entries are queued in
+ * time order, so only the head can be ready.
+ */
+static void nl_retry_export(void)
+{
+	struct delayed_export *d = delayed_export;
+	struct nl_msg *msg;
+
+	if (!d || d->last_attempt + RETRY_SEC > time(NULL))
+		return;
+
+	delayed_export = d->next;
+	d->next = NULL;
+
+	auth_reload();
+
+	msg = cache_nl_new_msg(nfsd_nl_family,
+			       NFSD_CMD_SVC_EXPORT_SET_REQS, 0);
+	if (!msg) {
+		delayed_export_enqueue(d);
+		return;
+	}
+
+	switch (nl_add_export_req(&msg, d->client, d->path)) {
+	case EXPORT_ANSWERED:
+		if (nl_msg_has_reqs(msg))
+			cache_nl_set_reqs(nfsd_nl_cmd_sock, msg);
+		delayed_export_free(d);
+		break;
+	case EXPORT_RETRY:
+		delayed_export_enqueue(d);
+		break;
+	case EXPORT_NOMEM:
+		delayed_export_enqueue(d);
+		return;			/* msg is already gone */
+	}
+	nlmsg_free(msg);
+}
+
 static void cache_nl_process_export(void)
 {
 	struct export_req *reqs = NULL;
@@ -1657,57 +1870,19 @@ static void cache_nl_process_export(void)
 		goto out_free;
 
 	for (i = 0; i < nreqs; i++) {
-		char *dom = reqs[i].client;
-		char *path = reqs[i].path;
-		struct addrinfo *ai = NULL;
-		nfs_export *found = NULL;
-		struct exportent *epp = NULL;
-		int ttl = 0;
-
-		if (is_ipaddr_client(dom)) {
-			ai = lookup_client_addr(dom);
-			if (!ai)
-				xlog(D_AUTH, "cache_nl_process_export: "
-				     "failed to resolve client %s", dom);
-		}
-
-		if (ai || !is_ipaddr_client(dom))
-			found = lookup_export(dom, path, ai);
-
-		if (found) {
-			char *mp = found->m_export.e_mountpoint;
-
-			if (mp && !*mp)
-				mp = found->m_export.e_path;
-			if (mp && !is_mountpoint(mp)) {
-				xlog(L_WARNING,
-				     "Cannot export path '%s': not a mountpoint",
-				     path);
-				ttl = 60;
-			} else {
-				epp = &found->m_export;
-			}
-		}
-
-		if (nfsd_nl_add_export(msg, dom, path, epp, ttl) < 0) {
-			cache_nl_set_reqs(nfsd_nl_cmd_sock, msg);
-			nlmsg_free(msg);
-			msg = cache_nl_new_msg(nfsd_nl_family,
-					       NFSD_CMD_SVC_EXPORT_SET_REQS, 0);
-			if (!msg) {
-				nfs_freeaddrinfo(ai);
-				goto out_free;
-			}
-			if (nfsd_nl_add_export(msg, dom, path,
-					       epp, ttl) < 0)
-				xlog(L_WARNING, "%s: skipping oversized "
-				     "entry for %s", __func__, path);
+		switch (nl_add_export_req(&msg, reqs[i].client, reqs[i].path)) {
+		case EXPORT_ANSWERED:
+			break;
+		case EXPORT_RETRY:
+			nl_delay_export(reqs[i].client, reqs[i].path);
+			break;
+		case EXPORT_NOMEM:
+			goto out_free;
 		}
-
-		nfs_freeaddrinfo(ai);
 	}
 
-	cache_nl_set_reqs(nfsd_nl_cmd_sock, msg);
+	if (nl_msg_has_reqs(msg))
+		cache_nl_set_reqs(nfsd_nl_cmd_sock, msg);
 	nlmsg_free(msg);
 
 out_free:
@@ -2971,29 +3146,32 @@ out:
 	return exp;
 }
 
-static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path,
+static struct exportent *lookup_nonexport_ent(char *dom, char *path,
 		struct addrinfo *ai)
 {
-	struct exportent *eep;
-
-	eep = lookup_junction(dom, path, ai);
-	dump_to_cache(f, buf, buflen, dom, path, eep, 0);
-	if (eep == NULL)
-		return;
-	exportent_release(eep);
-	free(eep);
+	return lookup_junction(dom, path, ai);
 }
 
 #else	/* !HAVE_JUNCTION_SUPPORT */
 
-static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path,
-		struct addrinfo *UNUSED(ai))
+static struct exportent *lookup_nonexport_ent(char *UNUSED(dom),
+		char *UNUSED(path), struct addrinfo *UNUSED(ai))
 {
-	dump_to_cache(f, buf, buflen, dom, path, NULL, 0);
+	return NULL;
 }
 
 #endif	/* !HAVE_JUNCTION_SUPPORT */
 
+static void lookup_nonexport(int f, char *buf, int buflen, char *dom, char *path,
+		struct addrinfo *ai)
+{
+	struct exportent *eep;
+
+	eep = lookup_nonexport_ent(dom, path, ai);
+	dump_to_cache(f, buf, buflen, dom, path, eep, 0);
+	free_junction(eep);
+}
+
 static void nfsd_export(int f)
 {
 	/* requests are:
@@ -3201,13 +3379,15 @@ int cache_process(fd_set *readfds)
 	cache_set_fds(readfds);
 	v4clients_set_fds(readfds);
 
-	if (delayed) {
+	if (delayed || delayed_export) {
 		time_t now = time(NULL);
-		time_t delay;
-		if (delayed->last_attempt > now)
-			/* Clock updated - retry immediately */
-			delayed->last_attempt = now - RETRY_SEC;
-		delay = delayed->last_attempt + RETRY_SEC - now;
+		time_t delay = RETRY_SEC;
+
+		if (delayed)
+			delay = retry_delay(&delayed->last_attempt, now, delay);
+		if (delayed_export)
+			delay = retry_delay(&delayed_export->last_attempt, now,
+					    delay);
 		if (delay < 0)
 			delay = 0;
 		tv.tv_sec = delay;
@@ -3225,6 +3405,8 @@ int cache_process(fd_set *readfds)
 		}
 	}
 
+	nl_retry_export();
+
 	switch (selret) {
 	case -1:
 		if (errno == EINTR || errno == ECONNREFUSED
@@ -3430,6 +3612,16 @@ cache_fork_workers(char *prog, int num_threads)
 		if (pid == 0) {
 			/* worker child */
 
+			/*
+			 * cache_open() drains the netlink downcalls before we
+			 * get here, so anything it deferred is now on the retry
+			 * queue of every worker.  Let the first worker own
+			 * those, or they get answered once per worker over the
+			 * shared command socket.
+			 */
+			if (i > 0)
+				delayed_export_flush();
+
 			/* Re-enable the default action on SIGTERM et al
 			 * so that workers die naturally when sent them.
 			 * Only the parent unregisters with pmap and

-- 
2.55.0

