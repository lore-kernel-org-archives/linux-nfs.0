Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA42446985B
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 13:14:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789391674; cv=none; b=c9TXmq3OOFI2Lw04rLdoOyoWTxr5JhuzthX9IcRPhHzU3RcA554AQJkakFlUlQCy+uaxZEbMXs9rWZ/+RCRW+LrhVISr9k1fWhfnYWTlnMiDEl+xOof8rzEFSjTUvzfNE2glxxdG94OXt222nvpuAr78LGSFozq/baXeHd+xVz0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789391674; c=relaxed/simple;
	bh=cEoyYUSCqpy9xHNNPLH0k5W09P/luoUcw2prGHhms/Y=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=FFVr98Rlr9H4aDF7HRDXsE1q+KGbSHsWPOirAx/7CkHYYxMA0FffbZUfc8a+NpBLgq25iGxEmH6tlYbum6JeU+rbXl/BPOV5P/64L4pIzfRzwl/yKBpV4im4qrj9w7/33He8QhJHOYqUI7uorTRzvFdCMVGwW1z0rffF/39KhQc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RIj1PWUa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RIj1PWUa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0DF5C1F00899;
	Mon, 14 Sep 2026 13:14:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789391671;
	bh=ewdJEhdGHO4holkG9YzAeCHEEI3Hg/9VtHWty0n9S2I=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RIj1PWUazqEX8Qtli2oLH8gZ/S/E9f0LHVzR/KrAJRBt8k6Kh3J8EVtYFbVcKfGY3
	 GJL2jxdxsR3zNEjEx0iVwgGrbpAiH/tKHETJbjF7c98BqKK8l9GDY8Ek/Azq1hJi7R
	 k/Ic8I3OjxRJyjW4u0Sq5FE1svQVqLcaunHsOYoVpp2pA0lYKWR0hvvIwj4clKuTfK
	 0eUEjgHjcos7qu9in5ZatXL/NhEe3Tgf7rtZ1eM9laOhXe1+8ZFGJ5fxzpr2eh/YXl
	 n8osng5BcUBydNrwcltait5qJIaKUf9FFIN/Ktf409RsRKQ24aO7LB7uxTPk3zoi3u
	 UyNJGMwtw4itg==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 09:14:12 -0400
Subject: [PATCH nfs-utils v3 03/11] mountd: answer requests the kernel
 rejects on the netlink downcall
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260914-nl-crossmnt-v3-3-a984a6c94829@kernel.org>
References: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
In-Reply-To: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=18734; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=cEoyYUSCqpy9xHNNPLH0k5W09P/luoUcw2prGHhms/Y=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqp/MyliaENaFrU3U7hCWWz7lLZ+eC4ed1bQmRv
 5zBE4VTSX+JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqfzMgAKCRAADmhBGVaC
 FTZ0D/40zGdt1+sNyCzSj7+KkQG0SHz9XVZW+EBSbuxZORB8AbeP1fiTgHTq4HiXSjkaFfC230s
 0A1oyjWWWXSEMa5pKpG3/kS3sU1UCj1Lt1aLqCpYaNt4r8L/MfRFy4B7sTmH5sJ3Ri/Kk/0lq1k
 Ny85ci/ZVSsTVRi22ECo7q68V7t3EP9cgVDZet/TfK2CHesxlU3HlRcFHrSguThs2d+rpqMl3gX
 7k2DjzgngKqdcXpPI6hoFx4k/MjrYjMTYd878lIzctu2TUnRiaUV3sJYvgKU2cpIeFIi9E+ZudJ
 MKAV6dl5H5cpJZACjL6+3pcsaPZXx4J2jn0gn/sp6VnUOGw5QPUVmZ1YhYUdMIk/lRHLerWlt3i
 qzHGNwXhmFoObmZO3hX88me0xBoVIGQnnNT3zBwaxF8EVjn2u3qoxbq9kiTcMCLcDH/vWpFuTsY
 nyBQq6ndy8WYF6RZvNwc0kiz2+xla1I5UC66TGMpkoXylZGh7vuuUL7PzdZiG1ntpSGZTvS55Qz
 r2SPyhoWc2Ukth2GMZ9jllubt37oWC4JAt9D77Jk7MHexxmejEfXkmG7kEbmb65S/moQNdl7hZb
 XM17xFkVpN9M1bAWluDTAPudhIZ45wJI094zSlXLfAz0rVs6pzoE71xI+LCPQjqM2Abepua7awM
 LH7seAzTnGxct5Q==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The kernel refuses an svc_export it cannot build a filehandle for - a 9p
submount picked up by crossmnt, say - and it fails the whole SET_REQS
message when it does.  cache_nl_process_export() batches every pending
request into one message and never looks at the result, so:

 - every entry queued behind the bad one is dropped
 - nothing downgrades the bad path to a negative entry
 - the request stays pending and the client hangs on the lookup

Pending requests then pile up on each notification:

  cache_nl_process_export: 5 pending export requests
  cache_nl_set_reqs: SET_REQS failed: -7

nfsd_export() has no such hole: a rejected dump_to_cache() write returns
-1 and it answers negative instead.

Keep the batch for the fast path, but resubmit it one entry at a time
when the kernel rejects it, and answer negative for whichever entries it
still refuses.  nfsd_nl_svc_export_set_reqs_doit() commits each entry as
it parses it and stops at the first failure, so the resubmit re-sends
some entries the kernel already took; that is harmless, as the update is
idempotent, and it is the only way to find the one that failed.
nl_add_export_req() no longer flushes the message itself; the caller
owns the batch so it knows what to resubmit.

Only fall back to a negative entry when the kernel actually answered.
libnl folds its own errors into the same NLE_* space as the kernel's, so
cache_nl_set_reqs() now reports the kernel's errno separately: a broken
socket must not cache "not exported" for default_ttl.  A negative entry
the kernel already refused - the path or the client's auth_domain went
away - is not resent as another negative either.

An entry too large for a message of its own is a third case.  mountd
never sent it, so the kernel never refused it.  Log the size failure and
answer negative, rather than blame the filesystem for it.

The resubmit makes a refusal routine, and the kernel tends to notify one
request at a time, so warning about it printed the same failure twice per
bad path.  Trace it at D_NETLINK instead, with nl_geterror() and the
kernel's errno rather than a raw number: the -7 above is NLE_INVAL, libnl's
own code for the kernel's EINVAL, not an errno.  Callers that have no
fallback keep their warning through the new cache_nl_flush_reqs(), which
ip_map and unix_gid now use, and the -ENOMEM in cache_nl_set_reqs() becomes
-NLE_NOMEM so the value is in the space nl_geterror() reads.

A path nobody asked to export - /proc or /sys below a crossmnt "/" - is
expected to be refused and the admin cannot act on it, so the negative
fallback only warns for a path exported in its own right.

Reported-by: Mantas Mikulėnas <grawity@gmail.com>
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/cache.c | 367 +++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 294 insertions(+), 73 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index 0ad98c539407..5bdc00c5847f 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -1623,18 +1623,59 @@ static struct nl_msg *cache_nl_new_msg(int family, int cmd, int flags)
 	return msg;
 }
 
-static int cache_nl_set_reqs(struct nl_sock *sock, struct nl_msg *msg)
+/* State for one SET_REQS round trip */
+struct set_reqs_status {
+	int	done;
+	int	kern_err;	/* errno the kernel answered with */
+};
+
+static int nl_set_reqs_finish_cb(struct nl_msg *UNUSED(msg), void *arg)
+{
+	struct set_reqs_status *st = arg;
+
+	st->done = 1;
+	return NL_STOP;
+}
+
+static int nl_set_reqs_error_cb(struct sockaddr_nl *UNUSED(nla),
+				struct nlmsgerr *nlerr, void *arg)
+{
+	struct set_reqs_status *st = arg;
+
+	st->done = 1;
+	st->kern_err = nlerr->error;
+	return NL_STOP;
+}
+
+/*
+ * Send @msg and wait for the kernel to ack it.  Returns 0 on success.
+ *
+ * libnl folds the kernel's errno into its own NLE_* space, and a local
+ * failure lands in the same space, so the return value cannot say whether
+ * the kernel looked at the message at all.  When @kern_errp is given it is
+ * set to the negative errno the kernel replied with, or left at 0 if it
+ * never got that far.
+ *
+ * A refusal is routine - the batch path uses one to find the entry the
+ * kernel would not take - so only trace it here and leave it to the caller
+ * to decide what is worth a warning.
+ */
+static int cache_nl_set_reqs(struct nl_sock *sock, struct nl_msg *msg,
+			     int *kern_errp)
 {
+	struct set_reqs_status st = {};
 	struct nl_cb *cb;
-	int done = 0;
 	int ret;
 
+	if (kern_errp)
+		*kern_errp = 0;
+
 	cb = nl_cb_alloc(NL_CB_DEFAULT);
 	if (!cb)
-		return -ENOMEM;
+		return -NLE_NOMEM;
 
-	nl_cb_set(cb, NL_CB_ACK, NL_CB_CUSTOM, nl_finish_cb, &done);
-	nl_cb_err(cb, NL_CB_CUSTOM, nl_error_cb, &done);
+	nl_cb_set(cb, NL_CB_ACK, NL_CB_CUSTOM, nl_set_reqs_finish_cb, &st);
+	nl_cb_err(cb, NL_CB_CUSTOM, nl_set_reqs_error_cb, &st);
 
 	ret = nl_send_auto(sock, msg);
 	if (ret < 0) {
@@ -1642,15 +1683,19 @@ static int cache_nl_set_reqs(struct nl_sock *sock, struct nl_msg *msg)
 		return ret;
 	}
 
-	while (!done) {
+	while (!st.done) {
 		ret = nl_recvmsgs(sock, cb);
 		if (ret < 0)
 			break;
 	}
 
 	nl_cb_put(cb);
+	if (kern_errp)
+		*kern_errp = st.kern_err;
 	if (ret < 0)
-		xlog(L_WARNING, "%s: SET_REQS failed: %d", __func__, ret);
+		xlog(D_NETLINK, "%s: SET_REQS failed: %s (kernel: %s)",
+		     __func__, nl_geterror(ret),
+		     st.kern_err ? strerror(-st.kern_err) : "no answer");
 	return ret;
 }
 
@@ -1659,24 +1704,54 @@ static bool nl_msg_has_reqs(struct nl_msg *msg)
 	return genlmsg_attrlen(nlmsg_data(nlmsg_hdr(msg)), 0) > 0;
 }
 
+/*
+ * Send a message the caller has no fallback for.  There is nothing to try
+ * instead when the kernel refuses an ip_map or unix_gid answer, so warn.
+ */
+static void cache_nl_flush_reqs(struct nl_sock *sock, struct nl_msg *msg,
+				const char *what)
+{
+	int ret;
+
+	if (!nl_msg_has_reqs(msg))
+		return;
+
+	ret = cache_nl_set_reqs(sock, msg, NULL);
+	if (ret < 0)
+		xlog(L_WARNING, "failed to answer %s requests: %s",
+		     what, nl_geterror(ret));
+}
+
 enum export_result {
-	EXPORT_ANSWERED,
+	EXPORT_ANSWERED,	/* positive entry added */
+	EXPORT_DENIED,		/* negative entry added */
 	EXPORT_RETRY,		/* not resolvable yet, ask again later */
-	EXPORT_NOMEM,		/* *msgp is gone, caller must give up */
+	EXPORT_FULL,		/* did not fit, flush the message and re-add */
 };
 
 /*
- * Resolve one svc_export request and append the answer to *msgp, sending
- * and replacing the message if it fills up.
+ * Did the admin ask for @path itself, or did we get here from a crossmnt
+ * parent or the v4 pseudoroot?  A filesystem nobody asked to export - /proc
+ * or /sys below a crossmnt "/", say - is expected to be unexportable, and
+ * saying so once per TTL is just noise.
+ */
+static bool export_is_explicit(nfs_export *found, char *path)
+{
+	return found && !strcmp(found->m_export.e_path, path);
+}
+
+/*
+ * Resolve one svc_export request and append the answer to @msg.  @explicitp,
+ * when given, says whether @path is an export in its own right.
  */
-static enum export_result nl_add_export_req(struct nl_msg **msgp, char *dom,
-					    char *path)
+static enum export_result nl_add_export_req(struct nl_msg *msg, char *dom,
+					    char *path, bool *explicitp)
 {
 	struct addrinfo *ai = NULL;
 	nfs_export *found = NULL;
 	struct exportent *epp = NULL;
 	struct exportent *junction = NULL;
-	enum export_result res = EXPORT_ANSWERED;
+	enum export_result res;
 	int ttl = 0;
 
 	if (is_ipaddr_client(dom)) {
@@ -1694,6 +1769,9 @@ static enum export_result nl_add_export_req(struct nl_msg **msgp, char *dom,
 		}
 	}
 
+	if (explicitp)
+		*explicitp = export_is_explicit(found, path);
+
 	if (found) {
 		char *mp = found->m_export.e_mountpoint;
 
@@ -1722,25 +1800,137 @@ static enum export_result nl_add_export_req(struct nl_msg **msgp, char *dom,
 		}
 	}
 
-	if (nfsd_nl_add_export(*msgp, dom, path, epp, ttl) < 0) {
-		cache_nl_set_reqs(nfsd_nl_cmd_sock, *msgp);
-		nlmsg_free(*msgp);
-		*msgp = cache_nl_new_msg(nfsd_nl_family,
-					 NFSD_CMD_SVC_EXPORT_SET_REQS, 0);
-		if (!*msgp) {
-			res = EXPORT_NOMEM;
-			goto out;
-		}
-		if (nfsd_nl_add_export(*msgp, dom, path, epp, ttl) < 0)
-			xlog(L_WARNING, "%s: skipping oversized entry for %s",
-			     __func__, path);
-	}
+	if (nfsd_nl_add_export(msg, dom, path, epp, ttl) < 0)
+		res = EXPORT_FULL;
+	else
+		res = epp ? EXPORT_ANSWERED : EXPORT_DENIED;
 out:
 	free_junction(junction);
 	nfs_freeaddrinfo(ai);
 	return res;
 }
 
+/*
+ * Answer @path negative in a message of its own.  Returns EXPORT_ANSWERED once
+ * the kernel has seen the answer - including when it refused it, as a second
+ * attempt would fare no better - and EXPORT_RETRY when the answer never got
+ * that far and is worth sending again.
+ */
+static enum export_result nl_export_negative(char *dom, char *path)
+{
+	struct nl_msg *msg;
+	int kern_err = 0;
+	int ret;
+
+	msg = cache_nl_new_msg(nfsd_nl_family,
+			       NFSD_CMD_SVC_EXPORT_SET_REQS, 0);
+	if (!msg)
+		return EXPORT_RETRY;
+
+	if (nfsd_nl_add_export(msg, dom, path, NULL, 0) < 0) {
+		nlmsg_free(msg);
+		return EXPORT_RETRY;
+	}
+
+	ret = cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, &kern_err);
+	nlmsg_free(msg);
+
+	if (ret < 0 && !kern_err)
+		return EXPORT_RETRY;
+	return EXPORT_ANSWERED;
+}
+
+/*
+ * Errors the kernel gives for an export it can never accept.  check_export()
+ * answers EINVAL for a filesystem with no export ops, one that needs an fsid=
+ * and has none, and an idmapped mount; ENOTDIR is an inode that is neither a
+ * directory, a symlink, nor a regular file.  Anything else it can return -
+ * ENOENT for an auth_domain or a path that is not there yet, ENOMEM, ENODEV
+ * while nfsd shuts down - may well work on the next try.
+ */
+static bool kernel_refused_for_good(int kern_err)
+{
+	switch (kern_err) {
+	case -EINVAL:
+	case -ENOTDIR:
+		return true;
+	}
+	return false;
+}
+
+/*
+ * Answer one request in a message of its own.  The kernel rejects an export
+ * it cannot build a filehandle for - a 9p or other filesystem with no export
+ * ops, say - so fall back to a negative entry rather than leaving the request
+ * pending, which is what dump_to_cache() does when the channel write fails.
+ */
+static enum export_result nl_export_one(char *dom, char *path)
+{
+	bool explicit_export = false;
+	enum export_result res;
+	struct nl_msg *msg;
+	int kern_err = 0;
+	bool sent;
+
+	msg = cache_nl_new_msg(nfsd_nl_family,
+			       NFSD_CMD_SVC_EXPORT_SET_REQS, 0);
+	if (!msg)
+		return EXPORT_RETRY;
+
+	res = nl_add_export_req(msg, dom, path, &explicit_export);
+	if (res == EXPORT_RETRY) {
+		nlmsg_free(msg);
+		return res;
+	}
+
+	/*
+	 * An entry that does not fit a message of its own can never be sent,
+	 * and this is not the kernel refusing it.  Answer negative rather
+	 * than leave the client hung on a request we cannot satisfy.
+	 */
+	if (res == EXPORT_FULL) {
+		nlmsg_free(msg);
+		xlog(L_WARNING, "%s: entry for %s is too large to send",
+		     __func__, path);
+		return nl_export_negative(dom, path);
+	}
+
+	sent = cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, &kern_err) == 0;
+	nlmsg_free(msg);
+
+	if (sent)
+		return EXPORT_ANSWERED;
+
+	/*
+	 * The kernel never answered - a broken socket, or a message we could
+	 * not send - so we cannot tell whether the export is usable.  Retry
+	 * rather than cache a negative entry for default_ttl.
+	 */
+	if (!kern_err)
+		return EXPORT_RETRY;
+
+	/*
+	 * It may recover from this one.  Denying the path would hide a working
+	 * export for default_ttl, and a negative entry needs the very
+	 * auth_domain the kernel may have just failed to find, so it would
+	 * likely be refused as well.  Ask again later instead.
+	 */
+	if (!kernel_refused_for_good(kern_err)) {
+		xlog(D_GENERAL, "%s: kernel refused %s: %s, will retry",
+		     __func__, path, strerror(-kern_err));
+		return EXPORT_RETRY;
+	}
+
+	/* It refused a negative entry; a second one will fare no better */
+	if (res == EXPORT_DENIED)
+		return EXPORT_ANSWERED;
+
+	xlog(explicit_export ? L_WARNING : D_GENERAL,
+	     "Cannot export %s, possibly unsupported filesystem"
+	     " or fsid= required", path);
+	return nl_export_negative(dom, path);
+}
+
 /*
  * is_mountpoint() can fail with a strange error - the ETIMEDOUT a re-exported
  * "softerr" NFS mount can give, say - leaving us unable to say whether the
@@ -1783,6 +1973,23 @@ static void delayed_export_flush(void)
 	}
 }
 
+/* Forget any deferred request for @dom and @path; it has been answered */
+static void delayed_export_remove(char *dom, char *path)
+{
+	struct delayed_export **dp = &delayed_export;
+
+	while (*dp) {
+		struct delayed_export *d = *dp;
+
+		if (!strcmp(d->client, dom) && !strcmp(d->path, path)) {
+			*dp = d->next;
+			delayed_export_free(d);
+			return;
+		}
+		dp = &d->next;
+	}
+}
+
 static void nl_delay_export(char *dom, char *path)
 {
 	struct delayed_export *d;
@@ -1812,7 +2019,6 @@ static void nl_delay_export(char *dom, char *path)
 static void nl_retry_export(void)
 {
 	struct delayed_export *d = delayed_export;
-	struct nl_msg *msg;
 
 	if (!d || d->last_attempt + RETRY_SEC > time(NULL))
 		return;
@@ -1822,35 +2028,33 @@ static void nl_retry_export(void)
 
 	auth_reload();
 
-	msg = cache_nl_new_msg(nfsd_nl_family,
-			       NFSD_CMD_SVC_EXPORT_SET_REQS, 0);
-	if (!msg) {
+	if (nl_export_one(d->client, d->path) == EXPORT_RETRY)
 		delayed_export_enqueue(d);
-		return;
-	}
-
-	switch (nl_add_export_req(&msg, d->client, d->path)) {
-	case EXPORT_ANSWERED:
-		if (nl_msg_has_reqs(msg))
-			cache_nl_set_reqs(nfsd_nl_cmd_sock, msg);
+	else
 		delayed_export_free(d);
-		break;
-	case EXPORT_RETRY:
-		delayed_export_enqueue(d);
-		break;
-	case EXPORT_NOMEM:
-		delayed_export_enqueue(d);
-		return;			/* msg is already gone */
-	}
-	nlmsg_free(msg);
+}
+
+/*
+ * Answer [@start, @end) one at a time.  Building the batch may already have
+ * deferred some of these, so an entry that resolves this time has to come back
+ * off the retry queue, or it gets answered a second time.
+ */
+static void nl_export_singly(struct export_req *reqs, int start, int end)
+{
+	int i;
+
+	for (i = start; i < end; i++)
+		if (nl_export_one(reqs[i].client, reqs[i].path) == EXPORT_RETRY)
+			nl_delay_export(reqs[i].client, reqs[i].path);
+		else
+			delayed_export_remove(reqs[i].client, reqs[i].path);
 }
 
 static void cache_nl_process_export(void)
 {
 	struct export_req *reqs = NULL;
 	int nreqs = 0;
-	struct nl_msg *msg;
-	int i;
+	int i = 0;
 
 	/* Fetch all pending requests from the kernel */
 	if (cache_nl_get_export_reqs(&reqs, &nreqs)) {
@@ -1863,29 +2067,46 @@ static void cache_nl_process_export(void)
 
 	xlog(D_CALL, "cache_nl_process_export: %d pending export requests", nreqs);
 
-	/* Build the SET_REQS response */
-	msg = cache_nl_new_msg(nfsd_nl_family,
-			       NFSD_CMD_SVC_EXPORT_SET_REQS, 0);
-	if (!msg)
-		goto out_free;
+	while (i < nreqs) {
+		int start = i;
+		struct nl_msg *msg;
 
-	for (i = 0; i < nreqs; i++) {
-		switch (nl_add_export_req(&msg, reqs[i].client, reqs[i].path)) {
-		case EXPORT_ANSWERED:
-			break;
-		case EXPORT_RETRY:
-			nl_delay_export(reqs[i].client, reqs[i].path);
+		msg = cache_nl_new_msg(nfsd_nl_family,
+				       NFSD_CMD_SVC_EXPORT_SET_REQS, 0);
+		if (!msg)
 			break;
-		case EXPORT_NOMEM:
-			goto out_free;
+
+		for (; i < nreqs; i++) {
+			enum export_result res;
+
+			res = nl_add_export_req(msg, reqs[i].client,
+						reqs[i].path, NULL);
+			if (res == EXPORT_FULL)
+				break;
+			if (res == EXPORT_RETRY)
+				nl_delay_export(reqs[i].client, reqs[i].path);
 		}
-	}
 
-	if (nl_msg_has_reqs(msg))
-		cache_nl_set_reqs(nfsd_nl_cmd_sock, msg);
-	nlmsg_free(msg);
+		/*
+		 * One bad entry fails the whole message, so resubmit the
+		 * batch singly to find out which and answer the rest.
+		 */
+		if (nl_msg_has_reqs(msg) &&
+		    cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, NULL) < 0) {
+			xlog(D_CALL, "%s: batch refused, answering %d request%s"
+			     " singly", __func__, i - start,
+			     i - start == 1 ? "" : "s");
+			nl_export_singly(reqs, start, i);
+		}
+		nlmsg_free(msg);
+
+		/* First entry did not fit an empty message: answer it alone */
+		if (i == start) {
+			nl_export_singly(reqs, i, i + 1);
+			i++;
+		}
+	}
 
-out_free:
 	for (i = 0; i < nreqs; i++) {
 		free(reqs[i].client);
 		free(reqs[i].path);
@@ -2155,7 +2376,7 @@ static void cache_nl_process_expkey(void)
 do_add_expkey:
 		if (nfsd_nl_add_expkey(msg, dom, fsidtype, fsid,
 				       fsidlen, found_path) < 0) {
-			cache_nl_set_reqs(nfsd_nl_cmd_sock, msg);
+			cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, NULL);
 			nlmsg_free(msg);
 			msg = cache_nl_new_msg(nfsd_nl_family,
 					       NFSD_CMD_EXPKEY_SET_REQS, 0);
@@ -2176,7 +2397,7 @@ do_add_expkey:
 		nfs_freeaddrinfo(ai);
 	}
 
-	cache_nl_set_reqs(nfsd_nl_cmd_sock, msg);
+	cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, NULL);
 	nlmsg_free(msg);
 
 out_free:
@@ -2466,7 +2687,7 @@ static void cache_nl_process_ip_map(void)
 		}
 
 		if (nl_add_ip_map(msg, class, ipaddr, domain) < 0) {
-			cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg);
+			cache_nl_flush_reqs(sunrpc_nl_cmd_sock, msg, "ip_map");
 			nlmsg_free(msg);
 			msg = cache_nl_new_msg(sunrpc_nl_family,
 					       SUNRPC_CMD_IP_MAP_SET_REQS, 0);
@@ -2496,7 +2717,7 @@ static void cache_nl_process_ip_map(void)
 		nfs_freeaddrinfo(tmp);
 	}
 
-	cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg);
+	cache_nl_flush_reqs(sunrpc_nl_cmd_sock, msg, "ip_map");
 	nlmsg_free(msg);
 
 out_free:
@@ -2714,7 +2935,7 @@ static void cache_nl_process_unix_gid(void)
 
 		if (ret < 0) {
 			/* Flush current message and retry with a fresh one */
-			cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg);
+			cache_nl_flush_reqs(sunrpc_nl_cmd_sock, msg, "unix_gid");
 			nlmsg_free(msg);
 			msg = cache_nl_new_msg(sunrpc_nl_family,
 					       SUNRPC_CMD_UNIX_GID_SET_REQS, 0);
@@ -2731,7 +2952,7 @@ static void cache_nl_process_unix_gid(void)
 		}
 	}
 
-	cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg);
+	cache_nl_flush_reqs(sunrpc_nl_cmd_sock, msg, "unix_gid");
 	nlmsg_free(msg);
 
 out_free:

-- 
2.55.0

