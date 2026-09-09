Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9D1F8559C9B
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 12:56:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788958615; cv=none; b=e9qbkoLhdwq3ZhoNn2ZGZ2xBkiMlCyub1tjGeWc4iH4MGY4Nj3J6dQhlw+altGzmxWbN/RHC15NY1J2Jt7nmumirix29cmnzKlcm0c3tQSwHrsc6yVFtCebfd7zLDjI/coWlqU8QjXMo28gRhWODddjdyf2u7Lfz+yktPaXRRgI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788958615; c=relaxed/simple;
	bh=WWXqIizNx1wKsl8iKH5g55MrjHDr7VF/nMiFhoPNZE4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=LJ1i8Zuw09PLYnQu4JUCSaJ/tVq46kknVnl5xT36j/CSDm/LZqsybqHZkdoAFIeZ1hsdtKyqdctUiURmMRvXsevywiqZVXNS8d5mAXi3tAg1Bk32AzV2fiyHuxm5jfU2+11uRo/avn5naBD5fFVc0lpd+VBdsBrAie3UaWprI20=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=njLcSopr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="njLcSopr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9D21D1F00ADB;
	Wed,  9 Sep 2026 12:56:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788958612;
	bh=l8H4UROvD14oU008hpbEoi7pp7cmWmVdtlWOeiVk+E4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=njLcSoprfFwDN62VlHA++YyT+BbNKzuSaX5w8uSwq6wcdJP6wO6ifat8nNhiF38WE
	 LT+dpyE3BPeS6cvQ0CtKBnJNui6l1Tscu2dhvJE7V6Xk2M+p25SXAoyfkvcYY+zu5o
	 nfpaOsF4p861U1L+r+cd4Y29+1qqZnBaz8jTYpiWJInVFGNVda00CNwjYmRrqsIp4w
	 giymkKGlY1SXWmdePn5B5VR0udBhTqx0SSYI+VNy0GybrFYm2zDpNTgwfHbZTuTUyC
	 dBLtPiAFBnBUWkQne3gaXuv9t0GiRNSa3FjF2c0B+h/YJ9RRu+x97Lm1InqkGStaKq
	 KTPzCabdmR6VA==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 09 Sep 2026 08:56:46 -0400
Subject: [PATCH nfs-utils 3/5] mountd: answer requests the kernel rejects
 on the netlink downcall
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260909-nl-crossmnt-v1-3-4064b5a3bd85@kernel.org>
References: <20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org>
In-Reply-To: <20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=13467; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=WWXqIizNx1wKsl8iKH5g55MrjHDr7VF/nMiFhoPNZE4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqoVeRtxjyF0iEEGqFIusVPBzC01gdfDOGbAdwv
 fF3v1FMLWKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqFXkQAKCRAADmhBGVaC
 FfsqD/oDQpxj780iLyFwCMEicUJFHy7vrW17fWK7wQAA7ze83Qowvms+9xeqxH8ajNMC09uTBRg
 aU1DwFT0lmSlcNwIaKynWMR42w+zAU745QiEu30uCAGbGCdDzPvcUoEbi/nEl2QLW88V7hRnBxK
 v/UPnyZgIW/eertBKiV8lXdKSaIIuYwujC5rcBXjA5ojRDSzhHpzJrfSfwMtY3Ooo+XpadzMR1i
 Gh9WgdKfGGGxoXHdk+TwMqOVtU7hpIVoZSlRAJKT/P6DES8ehkVFmyHth8zNG/lhBsyQkO51efB
 8PMpppImvVh53iMinK0gMvHyjFN9eKVmxEDKCY0L0EH7qO7dGrzE+RLQgHJ0X3+QC1Cj4Rz0LX9
 DK7fZncjpaa5RgRPTwiE6sTKallhOF3SvLQMziO2dRpx2mJULQL1+YXxTuTMDz1t0oVJY0PRJ7N
 T0s6ODOXi2KIibgabA+g7yifxu3XZPgwxQC2HaBVQe74AFNm3Qen+WI+JBsuOMSC/Qb+SeN7EEq
 9ydbp0/ZKbGSXzS2b0gQGOGxyOmq8on6wPMtY0hu+1Ihm8FoB6PQ/oHwhjHOIxZkYPIxn8XpSJe
 GivT8ODkkA4py1g7bMotWOJjKG9yFXbgJIKCjZDp+IkqdwC95EczMiqqDWgfXikz6iU8KaYaaPA
 RqaKBY+2z67WXEw==
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

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/cache.c | 249 +++++++++++++++++++++++++++++++++++--------------
 1 file changed, 177 insertions(+), 72 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index ed90a29a0ec7..d118834da29a 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -1623,18 +1623,55 @@ static struct nl_msg *cache_nl_new_msg(int family, int cmd, int flags)
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
 {
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
+ */
+static int cache_nl_set_reqs(struct nl_sock *sock, struct nl_msg *msg,
+			     int *kern_errp)
+{
+	struct set_reqs_status st = {};
 	struct nl_cb *cb;
-	int done = 0;
 	int ret;
 
+	if (kern_errp)
+		*kern_errp = 0;
+
 	cb = nl_cb_alloc(NL_CB_DEFAULT);
 	if (!cb)
 		return -ENOMEM;
 
-	nl_cb_set(cb, NL_CB_ACK, NL_CB_CUSTOM, nl_finish_cb, &done);
-	nl_cb_err(cb, NL_CB_CUSTOM, nl_error_cb, &done);
+	nl_cb_set(cb, NL_CB_ACK, NL_CB_CUSTOM, nl_set_reqs_finish_cb, &st);
+	nl_cb_err(cb, NL_CB_CUSTOM, nl_set_reqs_error_cb, &st);
 
 	ret = nl_send_auto(sock, msg);
 	if (ret < 0) {
@@ -1642,13 +1679,15 @@ static int cache_nl_set_reqs(struct nl_sock *sock, struct nl_msg *msg)
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
 		xlog(L_WARNING, "%s: SET_REQS failed: %d", __func__, ret);
 	return ret;
@@ -1660,23 +1699,21 @@ static bool nl_msg_has_reqs(struct nl_msg *msg)
 }
 
 enum export_result {
-	EXPORT_ANSWERED,
+	EXPORT_ANSWERED,	/* positive entry added */
+	EXPORT_DENIED,		/* negative entry added */
 	EXPORT_RETRY,		/* not resolvable yet, ask again later */
-	EXPORT_NOMEM,		/* *msgp is gone, caller must give up */
+	EXPORT_FULL,		/* did not fit, flush the message and re-add */
 };
 
-/*
- * Resolve one svc_export request and append the answer to *msgp, sending
- * and replacing the message if it fills up.
- */
-static enum export_result nl_add_export_req(struct nl_msg **msgp, char *dom,
+/* Resolve one svc_export request and append the answer to @msg */
+static enum export_result nl_add_export_req(struct nl_msg *msg, char *dom,
 					    char *path)
 {
 	struct addrinfo *ai = NULL;
 	nfs_export *found = NULL;
 	struct exportent *epp = NULL;
 	struct exportent *junction = NULL;
-	enum export_result res = EXPORT_ANSWERED;
+	enum export_result res;
 	int ttl = 0;
 
 	if (is_ipaddr_client(dom)) {
@@ -1722,25 +1759,90 @@ static enum export_result nl_add_export_req(struct nl_msg **msgp, char *dom,
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
 
+static void nl_export_negative(char *dom, char *path)
+{
+	struct nl_msg *msg;
+
+	msg = cache_nl_new_msg(nfsd_nl_family,
+			       NFSD_CMD_SVC_EXPORT_SET_REQS, 0);
+	if (!msg)
+		return;
+	if (nfsd_nl_add_export(msg, dom, path, NULL, 0) == 0)
+		cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, NULL);
+	nlmsg_free(msg);
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
+	res = nl_add_export_req(msg, dom, path);
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
+		nl_export_negative(dom, path);
+		return EXPORT_ANSWERED;
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
+	/* It refused a negative entry; a second one will fare no better */
+	if (res == EXPORT_DENIED)
+		return EXPORT_ANSWERED;
+
+	xlog(L_WARNING, "Cannot export %s, possibly unsupported filesystem"
+	     " or fsid= required", path);
+	nl_export_negative(dom, path);
+	return EXPORT_ANSWERED;
+}
+
 /*
  * is_mountpoint() can fail with a strange error - the ETIMEDOUT a re-exported
  * "softerr" NFS mount can give, say - leaving us unable to say whether the
@@ -1802,7 +1904,6 @@ static void nl_delay_export(char *dom, char *path)
 static void nl_retry_export(void)
 {
 	struct delayed_export *d = delayed_export;
-	struct nl_msg *msg;
 
 	if (!d || d->last_attempt + RETRY_SEC > time(NULL))
 		return;
@@ -1812,35 +1913,26 @@ static void nl_retry_export(void)
 
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
+static void nl_export_singly(struct export_req *reqs, int start, int end)
+{
+	int i;
+
+	for (i = start; i < end; i++)
+		if (nl_export_one(reqs[i].client, reqs[i].path) == EXPORT_RETRY)
+			nl_delay_export(reqs[i].client, reqs[i].path);
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
@@ -1853,29 +1945,42 @@ static void cache_nl_process_export(void)
 
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
+						reqs[i].path);
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
+		    cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, NULL) < 0)
+			nl_export_singly(reqs, start, i);
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
@@ -2145,7 +2250,7 @@ static void cache_nl_process_expkey(void)
 do_add_expkey:
 		if (nfsd_nl_add_expkey(msg, dom, fsidtype, fsid,
 				       fsidlen, found_path) < 0) {
-			cache_nl_set_reqs(nfsd_nl_cmd_sock, msg);
+			cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, NULL);
 			nlmsg_free(msg);
 			msg = cache_nl_new_msg(nfsd_nl_family,
 					       NFSD_CMD_EXPKEY_SET_REQS, 0);
@@ -2166,7 +2271,7 @@ do_add_expkey:
 		nfs_freeaddrinfo(ai);
 	}
 
-	cache_nl_set_reqs(nfsd_nl_cmd_sock, msg);
+	cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, NULL);
 	nlmsg_free(msg);
 
 out_free:
@@ -2456,7 +2561,7 @@ static void cache_nl_process_ip_map(void)
 		}
 
 		if (nl_add_ip_map(msg, class, ipaddr, domain) < 0) {
-			cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg);
+			cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg, NULL);
 			nlmsg_free(msg);
 			msg = cache_nl_new_msg(sunrpc_nl_family,
 					       SUNRPC_CMD_IP_MAP_SET_REQS, 0);
@@ -2486,7 +2591,7 @@ static void cache_nl_process_ip_map(void)
 		nfs_freeaddrinfo(tmp);
 	}
 
-	cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg);
+	cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg, NULL);
 	nlmsg_free(msg);
 
 out_free:
@@ -2704,7 +2809,7 @@ static void cache_nl_process_unix_gid(void)
 
 		if (ret < 0) {
 			/* Flush current message and retry with a fresh one */
-			cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg);
+			cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg, NULL);
 			nlmsg_free(msg);
 			msg = cache_nl_new_msg(sunrpc_nl_family,
 					       SUNRPC_CMD_UNIX_GID_SET_REQS, 0);
@@ -2721,7 +2826,7 @@ static void cache_nl_process_unix_gid(void)
 		}
 	}
 
-	cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg);
+	cache_nl_set_reqs(sunrpc_nl_cmd_sock, msg, NULL);
 	nlmsg_free(msg);
 
 out_free:

-- 
2.55.0

