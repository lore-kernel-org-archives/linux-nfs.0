Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CAE2455931D
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 12:56:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788958616; cv=none; b=qd77tHd9q1GgFogFi026AGN6dDRpIkuoLyhZUJcJjtltlyA6798wEFKjAQ57PE8vRcrSWUf8a07Ysera7zuUMhf/0NaCe/fRN6Gz4bxrBabRwgtQ2Uv5rcNLAi5RHTSd7LpJ2eBjHmYzX3FbY9x+WGylDYlB7D986aUKEP8zcL4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788958616; c=relaxed/simple;
	bh=/dzsKgvhCV9rM4n2WCl/fy/UtWIWncBd3MS+qUa3910=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=eu7tynrJMKXKx0ACk5SYE+Lt3+1GjxOm4E+W4JakBCRQ2ileWBg7IDRXBz2IsafpkG8xWd8ZOmCAcdN2TohhfQmdhod+3NRe1fwrWTMpXu4v5rGimejrjhQtW3woAV1xRtc59N/+gPQwPAJNs46iOUcv9K9lI9/xXosp6Xc7qLk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=cjtxVQU8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="cjtxVQU8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 073071F00AC4;
	Wed,  9 Sep 2026 12:56:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788958611;
	bh=+8RUE4BNvpdVuHObR87ZaQu4SA8UXTBxPLAtztu3bhQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=cjtxVQU8nrinMu4xUwhj0S0Hq+dVOC2JEMPquZs4wu+PUnkHzVJ/4cN01lS7bVCkY
	 7U/tgNoOcc0j+UhJjVpCO3+jcCX/iKmulzr0/JT7damgK6jHbjMP1dZKrWIkOt+Bk8
	 JdnqRKuM/JK39UmYI1D89hZfiCXQhwnHkA+qzHBejNLpTthVgt87ZWfnP6zNlrlV4i
	 pgeHA8S/R2h2KwiEx/CZerRc97Nx2CrbXp6d0p49NJiDwwLcBxBJEPmS3QGPXA67Bb
	 wLtukHXsa8DCjAhMd312I5KYrpBGd7dBEpCfgpgdBlGYAe+Jxhj4EvHb5N92hIVv+I
	 zgze6vMxEJuHg==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 09 Sep 2026 08:56:45 -0400
Subject: [PATCH nfs-utils 2/5] mountd: handle unmountable paths and
 junctions in the netlink downcall
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260909-nl-crossmnt-v1-2-4064b5a3bd85@kernel.org>
References: <20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org>
In-Reply-To: <20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=11018; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=/dzsKgvhCV9rM4n2WCl/fy/UtWIWncBd3MS+qUa3910=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqoVeQe07chqtINjZ3Oi/ni2ilwBIOfiChEJ+0k
 L+jbRMs/e2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqFXkAAKCRAADmhBGVaC
 FZW6EACYLZJQ25eFFgJ31HiUGF69vz5URL1pPJP9kpXjrmW9Dk93OV5ucwERveojcZxtlOd1kH0
 SG29o0uoFrJFoS3Vc8keqQ+zwYuNQARmkqTUbrm7eHnCumFlbRZp2OCLAQsqqQuP56QKmh285sK
 f/KAXTDc/s2OREylCckP7DofJO984RgoOFopRpHkP8TeEXFPrIK+7/l04IbOI2jWMMdy6EQaqMx
 Nz181IcsqyE5aHcvrre/yaDQHUDd6eNNZjz9lVT3kInabDxUB3s0KtoenOw95N6l4ORoah1yjOQ
 DCRW2voP7/YvZt6GII9jImLm0gkIagM5uT5VD/CFIff5OWrBWUxNdlYznL5B+xm9xyZCXs/9mu8
 XEWW0ezM2CfEUhS8FwNaiFENVcFXHse1fTP4rC+BmdiF6zNBXZt/4/e4yUrKyHJ67+qr16x99iD
 dDvirEy7nwQxZDrjZr4FoXhKcc+cpAjZJ0kff+CjgtnHYl1zB/RNr1Wcr7DIECIkF87mHloVxNJ
 //GNheNSPxehRwVNwh03NqwntHGOHERl8KUg9PCb0oc+d9CRSufDYhFAcRg4BQaW/ou90sowcWl
 /kMH1Mw/BlV5zRO6WcNHoCqWqGRGidLKpQAogH4Ih3TcZogDNAk4Ov0Fq2gl1ggUy+vFv93/Q1t
 ziv/Kha7EBXvrFA==
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
 support/export/cache.c | 304 ++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 238 insertions(+), 66 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index e8b13409ad7a..ed90a29a0ec7 100644
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
@@ -1632,6 +1654,187 @@ static int cache_nl_set_reqs(struct nl_sock *sock, struct nl_msg *msg)
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
@@ -1657,57 +1860,19 @@ static void cache_nl_process_export(void)
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
@@ -2971,29 +3136,32 @@ out:
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
@@ -3201,13 +3369,15 @@ int cache_process(fd_set *readfds)
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
@@ -3225,6 +3395,8 @@ int cache_process(fd_set *readfds)
 		}
 	}
 
+	nl_retry_export();
+
 	switch (selret) {
 	case -1:
 		if (errno == EINTR || errno == ECONNREFUSED

-- 
2.55.0

