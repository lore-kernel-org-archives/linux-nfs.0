Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7245C559CB5
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 12:56:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788958616; cv=none; b=lLV9zoa1rAammlTKQFdgWEC/n7+EiQiklxDysOXnYlOVUsNHdIgmetEApJAUgTgilbuOf8mv3DhAFB6kBrrHN9uwmfortz8D7s6Bh+qmGoDpQEWRl1PMx/5qJTKZrxW2KO+c40HgGPBf3KQFurZxCXPw8nRBWv/ROmyR1MqAtEQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788958616; c=relaxed/simple;
	bh=QBeqgo5zKZ1VlRKtU4cNLqdT9xW/AL9itReD9ihuiNU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=tk3IexomixnBvJTUg2Ml/TMSVpVH8JHD5CZnKmegBnf+ZElooKwypRNC7alGG6S2WqB5SnJptS+7Emd6A8/1szL4qeP44Lts8zab0J6Urzu3ud09UpTl74MFCHvmy1K/S/5qBk/vfE88JM+V+h9ECasb4FxNWPatssY1ZU6JPxU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Pwn4a9Wg; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Pwn4a9Wg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D53671F00A3E;
	Wed,  9 Sep 2026 12:56:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788958613;
	bh=xkwWad1yXp05hKAIsmZb0MNWjzrrURihB0ajpXGEBd8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Pwn4a9WgubNFJ3BtNS91yPmKeCOJ/BaSHW1cUX6T1awe4Z4CNZQ4FPVpeGIh2OhC1
	 2GjAVG01AJKbUGMzASW2RK67y+JA86VfbnYxoDZfWU5q3d6QJZYWPxytxYvOq5r3vW
	 g9WSfxlg5UD1s6y9Q/FrtNIM50PHNn7Kn7MLSCC/YQMBPWqKF/SX4cTAsm9q/LDWEz
	 i/X4cTLTijwDo/JHSTmV5yezlXJsiTmxVoGbGZlO2WS05ReL0ASFPsxypbPEqatICj
	 qXKTOlxpIchyrH4wvszlSQxc5odgOZHqXKY2h1IHdXV5PRgvXsi6jnIfwOmVe0nqzZ
	 KdS33Qwiny4DQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 09 Sep 2026 08:56:48 -0400
Subject: [PATCH nfs-utils 5/5] mountd: retry unresolvable fsid lookups on
 the netlink downcall
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260909-nl-crossmnt-v1-5-4064b5a3bd85@kernel.org>
References: <20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org>
In-Reply-To: <20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=16073; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=QBeqgo5zKZ1VlRKtU4cNLqdT9xW/AL9itReD9ihuiNU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqoVeRLZKYihklok6mn80oc7Z9Xpux1cesATUju
 xRZAVdes6SJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqFXkQAKCRAADmhBGVaC
 FRu8EACxCSg2OwnrQHBbCTsqVoKvGBGQmJmpEn2p4oDfMyj+3lhZhhte5oSQxKtb2A0UiVLPmIw
 VSLom8Y3sQGxkh15HquLpRk4XvEcKklF+k25p/JsL9Vh4FitJD/2KovOsctU32WxxoqGTAARsyf
 AO/kroJOVni8Uia6MEzz6RtCjbyTxa2d4PmQkTUhDbxC3HahFCxLvcL8l7yYrwXGKqzvaZ04tCH
 9RTNoC6XMVtcRGkSnc6A5Vjynph18LowCFYCJkSWtWnP4vuuRUPa85CABeHURvVf2a0RR6h/1ZV
 1yumS4/pZtMyenI/hGqbhlgY7CvxmM79Z7gA4ogf8vySZDO0e/IO755wXsiHuqKMcgDp6eCZtUR
 dckWRexnr1gcBiigBy8qXststd8+PhUI6eduSQ6puNoblvCpy66Y9aAzDZswHt4NWNvkGpMDN74
 env3I+9z2KM11rg7wL1Rm0CqZTrU3GsXqQ4j6AupjjX4Mhll77YwiBgBXIqczkb1fXO6V3GFhUM
 k33NJHvkOPdH/xmtLWkSqFMQqND9rkCTvbt5EMD+uxxYa3bGCcOjudndW/nq44jM+FjwsB47qZQ
 q8iYjDmC+X6eRzj3rsb7GrUsc59LD+jiuKPMK07DW0Drqx17cHQJd0ceCl79f655Puhac5PAI9D
 1fQ4jBj24YpCfaw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_fh() defers a request instead of an answer in two cases:

 - the fsid names a device that is not present
 - the export has a "mountpoint" that is not mounted

The filesystem can appear soon, and an answer now gives a spurious
ESTALE.  cache_nl_process_expkey() answered negative in both cases, so
a not-yet-mounted autofs submount failed immediately.

Move the fsid lookup out of nfsd_handle_fh() into lookup_fsid().  Call
it from both downcalls.  The netlink path then also gets:

 - dev_missing accounting for unmatchable and unmounted exports
 - reexpdb_uncover_subvolume() for re-exported fsidnums
 - the V4ROOT tie-break and duplicate-filehandle warning
 - the fsidtype range check

Deferred netlink requests use their own list.  cache_process() retries
them on the same RETRY_SEC cadence as the pipefs ones.  The kernel keeps
the upcall pending until then.

expkey has the same batching hole that svc_export had.
nfsd_nl_expkey_set_reqs_doit() stops at the first entry that it refuses.
It refuses an entry when kern_path() on the path fails.  It also refuses
an entry when auth_domain_find() on the client fails.  The kernel never
processed the entries behind the refused one.  Those clients hung.
Resubmit a rejected batch one entry at a time, as the svc_export path
now does.

A refused entry gets no negative fallback.  The kernel builds a negative
expkey entry from auth_domain_find() alone, so a negative answer would
replace a path that kern_path() refused.  But nfsd_nl_add_expkey() sets
an expiry of 0x7fffffff.  A path that disappeared for a moment would
become a denial until the next "exportfs -f".  Log the entry and leave
it pending for the next upcall, which is what pipefs does when the
channel write fails.

A libnl or socket failure is a different case.  The kernel never saw the
message, so the request is still unanswered.  cache_nl_set_reqs()
reports the kernel's errno separately, and nl_expkey_one() returns such
a request to the retry list.

Reported-by: Mantas Mikulėnas <grawity@gmail.com>
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/cache.c | 415 +++++++++++++++++++++++++++++++++----------------
 1 file changed, 280 insertions(+), 135 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index 1f81a67e35cf..94d253565ab5 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -796,17 +796,19 @@ static time_t retry_delay(time_t *last_attempt, time_t now, time_t delay)
 	return d < delay ? d : delay;
 }
 
-static int nfsd_handle_fh(int f, char *bp, int blen)
+enum fsid_lookup {
+	FSID_LOOKUP_ANSWER,	/* definitive; *pathp NULL means deny access */
+	FSID_LOOKUP_RETRY,	/* not resolvable yet, ask again later */
+	FSID_LOOKUP_IGNORE,	/* unusable request, no reply possible */
+};
+
+/*
+ * Find the export path that @fsid refers to for client @dom.  On
+ * FSID_LOOKUP_ANSWER the caller owns *pathp.
+ */
+static enum fsid_lookup lookup_fsid(char *dom, int fsidtype, int fsidlen,
+				    char *fsid, char **pathp)
 {
-	/* request are:
-	 *  domain fsidtype fsid
-	 * interpret fsid, find export point and options, and write:
-	 *  domain fsidtype fsid expiry path
-	 */
-	char *dom;
-	int fsidtype;
-	int fsidlen;
-	char fsid[32];
 	struct parsed_fsid parsed;
 	struct exportent *found = NULL;
 	struct addrinfo *ai = NULL;
@@ -814,21 +816,13 @@ static int nfsd_handle_fh(int f, char *bp, int blen)
 	nfs_export *exp;
 	int i;
 	int dev_missing = 0;
-	char buf[RPC_CHAN_BUF_SIZE];
 	int did_uncover = 0;
-	int ret = 0;
+	enum fsid_lookup ret = FSID_LOOKUP_IGNORE;
+
+	*pathp = NULL;
 
-	dom = malloc(blen);
-	if (dom == NULL)
-		return ret;
-	if (qword_get(&bp, dom, blen) <= 0)
-		goto out;
-	if (qword_get_int(&bp, &fsidtype) != 0)
-		goto out;
 	if (fsidtype < 0 || fsidtype > 7)
 		goto out; /* unknown type */
-	if ((fsidlen = qword_get(&bp, fsid, 32)) <= 0)
-		goto out;
 	if (parse_fsid(fsidtype, fsidlen, fsid, &parsed))
 		goto out;
 
@@ -923,7 +917,7 @@ static int nfsd_handle_fh(int f, char *bp, int blen)
 		 * quiet rather than returning stale yet
 		 */
 		if (dev_missing) {
-			ret = 1;
+			ret = FSID_LOOKUP_RETRY;
 			goto out;
 		}
 	} else if (found->e_mountpoint &&
@@ -935,8 +929,55 @@ static int nfsd_handle_fh(int f, char *bp, int blen)
 		   xlog(L_WARNING, "%s not exported as %d not a mountpoint",
 		   found->e_path, found->e_mountpoint);
 		 */
+		ret = FSID_LOOKUP_RETRY;
+		goto out;
+	}
+
+	ret = FSID_LOOKUP_ANSWER;
+	*pathp = found_path;
+	found_path = NULL;
+out:
+	if (ret != FSID_LOOKUP_RETRY)
+		xlog(D_CALL, "%s: found %p path %s", __func__,
+		     found, found ? found->e_path : NULL);
+	free(found_path);
+	nfs_freeaddrinfo(ai);
+	return ret;
+}
+
+static int nfsd_handle_fh(int f, char *bp, int blen)
+{
+	/* request are:
+	 *  domain fsidtype fsid
+	 * interpret fsid, find export point and options, and write:
+	 *  domain fsidtype fsid expiry path
+	 */
+	char *dom;
+	int fsidtype;
+	int fsidlen;
+	char fsid[32];
+	char *found_path = NULL;
+	char buf[RPC_CHAN_BUF_SIZE];
+	int ret = 0;
+
+	dom = malloc(blen);
+	if (dom == NULL)
+		return ret;
+	if (qword_get(&bp, dom, blen) <= 0)
+		goto out;
+	if (qword_get_int(&bp, &fsidtype) != 0)
+		goto out;
+	if ((fsidlen = qword_get(&bp, fsid, 32)) <= 0)
+		goto out;
+
+	switch (lookup_fsid(dom, fsidtype, fsidlen, fsid, &found_path)) {
+	case FSID_LOOKUP_RETRY:
 		ret = 1;
 		goto out;
+	case FSID_LOOKUP_IGNORE:
+		goto out;
+	case FSID_LOOKUP_ANSWER:
+		break;
 	}
 
 	bp = buf; blen = sizeof(buf);
@@ -952,21 +993,16 @@ static int nfsd_handle_fh(int f, char *bp, int blen)
 	 * line.
 	 */
 	qword_addint(&bp, &blen, 0x7fffffff);
-	if (found)
+	if (found_path)
 		qword_add(&bp, &blen, found_path);
 	qword_addeol(&bp, &blen);
 	if (blen <= 0 || cache_write(f, buf, bp - buf) != bp - buf)
 		xlog(L_ERROR, "nfsd_fh: error writing reply");
-	if (!found)
+	if (!found_path)
 		xlog(D_AUTH, "denied access to %s", *dom == '$' ? dom+1 : dom);
 out:
-	if (found_path)
-		free(found_path);
-	nfs_freeaddrinfo(ai);
+	free(found_path);
 	free(dom);
-	if (!ret)
-		xlog(D_CALL, "nfsd_fh: found %p path %s",
-		     found, found ? found->e_path : NULL);
 	return ret;
 }
 
@@ -2161,12 +2197,192 @@ nla_failure:
 	return -1;
 }
 
+/*
+ * An fsid can name a filesystem that isn't mounted yet - an autofs
+ * mountpoint, or a re-exported NFS server that is slow to answer.  Set the
+ * request aside and try again later rather than declaring it stale, which
+ * is what nfsd_fh() does with the "delayed" list on pipefs.
+ */
+struct delayed_expkey {
+	char			*client;
+	char			*fsid;
+	int			fsidlen;
+	int			fsidtype;
+	time_t			last_attempt;
+	struct delayed_expkey	*next;
+};
+
+static struct delayed_expkey *delayed_expkey;
+
+static void delayed_expkey_enqueue(struct delayed_expkey *d)
+{
+	struct delayed_expkey **dp = &delayed_expkey;
+
+	d->last_attempt = time(NULL);
+	d->next = NULL;
+	while (*dp)
+		dp = &(*dp)->next;
+	*dp = d;
+}
+
+static void delayed_expkey_free(struct delayed_expkey *d)
+{
+	free(d->client);
+	free(d->fsid);
+	free(d);
+}
+
+static void nl_delay_expkey(struct expkey_req *req)
+{
+	struct delayed_expkey *d;
+
+	for (d = delayed_expkey; d; d = d->next)
+		if (d->fsidtype == req->fsidtype &&
+		    d->fsidlen == req->fsidlen &&
+		    !strcmp(d->client, req->client) &&
+		    !memcmp(d->fsid, req->fsid, req->fsidlen))
+			return;
+
+	d = calloc(1, sizeof(*d));
+	if (!d)
+		return;
+
+	d->client = strdup(req->client);
+	d->fsid = malloc(req->fsidlen);
+	if (!d->client || !d->fsid) {
+		delayed_expkey_free(d);
+		return;
+	}
+	memcpy(d->fsid, req->fsid, req->fsidlen);
+	d->fsidlen = req->fsidlen;
+	d->fsidtype = req->fsidtype;
+
+	delayed_expkey_enqueue(d);
+}
+
+enum expkey_result {
+	EXPKEY_ANSWERED,
+	EXPKEY_RETRY,		/* not resolvable yet, ask again later */
+	EXPKEY_FULL,		/* did not fit, flush the message and re-add */
+};
+
+/* Resolve one expkey request and append the answer to @msg */
+static enum expkey_result nl_add_expkey_req(struct nl_msg *msg,
+					    struct expkey_req *req)
+{
+	enum expkey_result res = EXPKEY_ANSWERED;
+	char *found_path = NULL;
+	char *dom = req->client;
+
+	switch (lookup_fsid(dom, req->fsidtype, req->fsidlen, req->fsid,
+			    &found_path)) {
+	case FSID_LOOKUP_RETRY:
+		return EXPKEY_RETRY;
+	case FSID_LOOKUP_IGNORE:	/* answer negative rather than hang */
+	case FSID_LOOKUP_ANSWER:
+		break;
+	}
+
+	if (nfsd_nl_add_expkey(msg, dom, req->fsidtype, req->fsid,
+			       req->fsidlen, found_path) < 0)
+		res = EXPKEY_FULL;
+	else if (!found_path)
+		xlog(D_AUTH, "denied access to %s", *dom == '$' ? dom + 1 : dom);
+
+	free(found_path);
+	return res;
+}
+
+/*
+ * Answer one request in a message of its own.  The kernel refuses an entry
+ * whose path or whose client's auth_domain has gone away, and fails the
+ * whole message when it does, so a rejected entry must not take the rest of
+ * a batch down with it.
+ */
+static enum expkey_result nl_expkey_one(struct expkey_req *req)
+{
+	enum expkey_result res;
+	struct nl_msg *msg;
+	int kern_err = 0;
+
+	msg = cache_nl_new_msg(nfsd_nl_family, NFSD_CMD_EXPKEY_SET_REQS, 0);
+	if (!msg)
+		return EXPKEY_RETRY;
+
+	res = nl_add_expkey_req(msg, req);
+	switch (res) {
+	case EXPKEY_ANSWERED:
+		if (cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, &kern_err) < 0) {
+			/*
+			 * The kernel never answered - a broken socket, or a
+			 * message we could not send - so the request is still
+			 * unanswered.  Ask again later rather than drop it.
+			 */
+			if (!kern_err) {
+				res = EXPKEY_RETRY;
+				break;
+			}
+			/*
+			 * Nothing to fall back on: a negative entry needs the
+			 * same auth_domain the kernel may have just failed to
+			 * find, and we cannot tell that apart from a path it
+			 * refused.  Leave the request pending for the next
+			 * upcall, as pipefs does when the channel write fails.
+			 */
+			xlog(L_WARNING, "%s: kernel rejected the fsid answer"
+			     " for %s: %d", __func__, req->client, kern_err);
+		}
+		break;
+	case EXPKEY_FULL:
+		xlog(L_WARNING, "%s: skipping oversized entry", __func__);
+		break;
+	case EXPKEY_RETRY:
+		break;
+	}
+	nlmsg_free(msg);
+	return res;
+}
+
+static void nl_expkey_singly(struct expkey_req *reqs, int start, int end)
+{
+	int i;
+
+	for (i = start; i < end; i++)
+		if (nl_expkey_one(&reqs[i]) == EXPKEY_RETRY)
+			nl_delay_expkey(&reqs[i]);
+}
+
+/*
+ * Retry the oldest deferred lookup if it is due.  Entries are queued in
+ * time order, so only the head can be ready.
+ */
+static void nl_retry_expkey(void)
+{
+	struct delayed_expkey *d = delayed_expkey;
+	struct expkey_req req;
+
+	if (!d || d->last_attempt + RETRY_SEC > time(NULL))
+		return;
+
+	delayed_expkey = d->next;
+	d->next = NULL;
+
+	req.client = d->client;
+	req.fsidtype = d->fsidtype;
+	req.fsid = d->fsid;
+	req.fsidlen = d->fsidlen;
+
+	if (nl_expkey_one(&req) == EXPKEY_RETRY)
+		delayed_expkey_enqueue(d);
+	else
+		delayed_expkey_free(d);
+}
+
 static void cache_nl_process_expkey(void)
 {
 	struct expkey_req *reqs = NULL;
 	int nreqs = 0;
-	struct nl_msg *msg;
-	int i;
+	int i = 0;
 
 	if (cache_nl_get_expkey_reqs(&reqs, &nreqs)) {
 		xlog(L_WARNING, "cache_nl_process_expkey: failed to get expkey requests");
@@ -2178,116 +2394,41 @@ static void cache_nl_process_expkey(void)
 
 	xlog(D_CALL, "cache_nl_process_expkey: %d pending expkey requests", nreqs);
 
-	msg = cache_nl_new_msg(nfsd_nl_family, NFSD_CMD_EXPKEY_SET_REQS, 0);
-	if (!msg)
-		goto out_free;
-
-	for (i = 0; i < nreqs; i++) {
-		char *dom = reqs[i].client;
-		int fsidtype = reqs[i].fsidtype;
-		char *fsid = reqs[i].fsid;
-		int fsidlen = reqs[i].fsidlen;
-		struct parsed_fsid parsed;
-		struct addrinfo *ai = NULL;
-		struct exportent *found = NULL;
-		char *found_path = NULL;
-		nfs_export *exp;
-		int j;
-
-		if (parse_fsid(fsidtype, fsidlen, fsid, &parsed))
-			goto do_add_expkey;
-
-		if (is_ipaddr_client(dom)) {
-			ai = lookup_client_addr(dom);
-			if (!ai)
-				goto do_add_expkey;
-		}
-
-		for (j = 0; j < MCL_MAXTYPES; j++) {
-			nfs_export *prev = NULL;
-			nfs_export *next_exp;
-			void *mnt = NULL;
-
-			for (exp = exportlist[j].p_head; exp;
-			     exp = next_exp) {
-				char *path;
-
-				if (exp->m_export.e_flags &
-				    NFSEXP_CROSSMOUNT) {
-					if (prev == exp) {
-						path = next_mnt(&mnt,
-							exp->m_export.e_path);
-						if (!path) {
-							next_exp = exp->m_next;
-							prev = NULL;
-							continue;
-						}
-						next_exp = exp;
-					} else {
-						prev = exp;
-						mnt = NULL;
-						path = exp->m_export.e_path;
-						next_exp = exp;
-					}
-				} else {
-					path = exp->m_export.e_path;
-					next_exp = exp->m_next;
-				}
-
-				if (!is_ipaddr_client(dom) &&
-				    !namelist_client_matches(exp, dom))
-					continue;
+	while (i < nreqs) {
+		int start = i;
+		struct nl_msg *msg;
 
-				switch (match_fsid(&parsed, exp, path)) {
-				case 0:
-					continue;
-				case -1:
-					continue;
-				}
+		msg = cache_nl_new_msg(nfsd_nl_family,
+				       NFSD_CMD_EXPKEY_SET_REQS, 0);
+		if (!msg)
+			break;
 
-				if (is_ipaddr_client(dom) &&
-				    !ipaddr_client_matches(exp, ai))
-					continue;
+		for (; i < nreqs; i++) {
+			enum expkey_result res;
 
-				if (!found ||
-				    subexport(&exp->m_export, found)) {
-					found = &exp->m_export;
-					free(found_path);
-					found_path = strdup(path);
-					if (!found_path)
-						goto do_add_expkey;
-				}
-			}
+			res = nl_add_expkey_req(msg, &reqs[i]);
+			if (res == EXPKEY_FULL)
+				break;
+			if (res == EXPKEY_RETRY)
+				nl_delay_expkey(&reqs[i]);
 		}
 
-do_add_expkey:
-		if (nfsd_nl_add_expkey(msg, dom, fsidtype, fsid,
-				       fsidlen, found_path) < 0) {
-			cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, NULL);
-			nlmsg_free(msg);
-			msg = cache_nl_new_msg(nfsd_nl_family,
-					       NFSD_CMD_EXPKEY_SET_REQS, 0);
-			if (!msg) {
-				free(found_path);
-				nfs_freeaddrinfo(ai);
-				goto out_free;
-			}
-			if (nfsd_nl_add_expkey(msg, dom, fsidtype, fsid,
-					       fsidlen, found_path) < 0)
-				xlog(L_WARNING, "%s: skipping oversized "
-				     "entry", __func__);
+		/*
+		 * One bad entry fails the whole message, so resubmit the
+		 * batch singly to find out which and answer the rest.
+		 */
+		if (nl_msg_has_reqs(msg) &&
+		    cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, NULL) < 0)
+			nl_expkey_singly(reqs, start, i);
+		nlmsg_free(msg);
+
+		/* First entry did not fit an empty message: answer it alone */
+		if (i == start) {
+			nl_expkey_singly(reqs, i, i + 1);
+			i++;
 		}
-		if (!found)
-			xlog(D_AUTH, "denied access to %s",
-			     *dom == '$' ? dom + 1 : dom);
-		free(found_path);
-		nfs_freeaddrinfo(ai);
 	}
 
-	cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, NULL);
-	nlmsg_free(msg);
-
-out_free:
 	for (i = 0; i < nreqs; i++) {
 		free(reqs[i].client);
 		free(reqs[i].fsid);
@@ -3487,12 +3628,15 @@ int cache_process(fd_set *readfds)
 	cache_set_fds(readfds);
 	v4clients_set_fds(readfds);
 
-	if (delayed || delayed_export) {
+	if (delayed || delayed_expkey || delayed_export) {
 		time_t now = time(NULL);
 		time_t delay = RETRY_SEC;
 
 		if (delayed)
 			delay = retry_delay(&delayed->last_attempt, now, delay);
+		if (delayed_expkey)
+			delay = retry_delay(&delayed_expkey->last_attempt, now,
+					    delay);
 		if (delayed_export)
 			delay = retry_delay(&delayed_export->last_attempt, now,
 					    delay);
@@ -3513,6 +3657,7 @@ int cache_process(fd_set *readfds)
 		}
 	}
 
+	nl_retry_expkey();
 	nl_retry_export();
 
 	switch (selret) {

-- 
2.55.0

