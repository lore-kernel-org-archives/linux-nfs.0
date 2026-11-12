Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=62.149.158.132
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794504457;
	b=O1d91QDymhvkgyLxCZR4+NEGKvJE0v6NNngRFhu3OduMSpMt2Zh0gDuOSvlkAnI5dQ1Z
	 tn377HkTi2Q2EIKWoxesp0A66jVwNxcYXq2UuZeF8+9AMZP9VaXB7Z51DpKXYvIH2rdGz
	 7XDAYBBafuFLLXoul4vxc8QhxGS+6N1bzhKrrXv5ijFizQ3e2EamNjrnrlyK8TmJ6S3Cm
	 hX4B22e2N5dxVGGXUAjOAKYD8uOt7W6hhdg0y8WXZp+jF5DWH9phFWsuN4hDLobuTtQPR
	 SU3i03cOH+W0jmHeQoKYXYibSIe4o9WpeCqsWtGJd9gyCW1zM358osivHAXOpwNe2/Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794504457;
	h=DMARC-Filter:Received:DKIM-Signature:From:To:Cc:Subject:Date:
	 Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding:
	 X-CMAE-Envelope;
	bh=2KptuAQwrNk4xbuZh/I6e3msgM3ob6P+ME/333AlGDQ=;
	b=XTBpDo+uDEiSfWPH74yu+JKKx2/YzAWgQfU8+9t7DIm6p4F3M7/l7L1M8NoidT1yndpU
	 07MeapzHx5iO4Lt9dxrKK1p7vw5Jqna7/g/+eejkS1Hh8RIowx506YDKWMkzNbfO8ftED
	 cckQTxL0BWifpVEuEEJwTeAp/2rHkPsoiB0ADAqnxq+hOq1BksrUPUAIJgfF7HfoJGryL
	 0OWgvjIGz1e1oz61TrJB+g6ENqE64jicQWioz6Wi6p6GdEqhz0PXWyuAB1RDDt4vZh72d
	 zSknBEXygiBoqFiEFxlFg9oqEXQZ/KOOqry3TlERyGBhhTE1Wc8J7Wa8jZQwcZoAIKw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=benettiengineering.com;
	spf=pass smtp.mailfrom=benettiengineering.com;
	dkim=pass header.d=aruba.it header.i=@aruba.it header.a=rsa-sha256 header.s=a1 header.b=DJrMhjYX;
	arc=none smtp.remote-ip=62.149.158.132
Received: from smtpcmd04132.aruba.it (smtpcmd04132.aruba.it [62.149.158.132])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D3F34606A32D
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 17:27:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org D3F34606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=benettiengineering.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=benettiengineering.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=aruba.it header.i=@aruba.it header.a=rsa-sha256 header.s=a1 header.b=DJrMhjYX
Received: from localhost.localdomain ([151.95.84.63])
	by Aruba SMTP with ESMTPSA
	id RYaDx66OStleFRYaDx8S2B; Thu, 12 Nov 2026 18:27:33 +0100
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=aruba.it; s=a1;
	t=1794504453; bh=m0B1o877mQk1cYgb0QOACN9Z3jkzKnejp3mwo7KZw1A=;
	h=From:To:Subject:Date:MIME-Version;
	b=DJrMhjYXjQsMp0UH+GcrO6ADUE9ouQW3pzj9X1gu7m7FCrqJwdh4B4DXAjLyUx3cZ
	 5DdG0p1LODNbVAKfCavaLTKRt9coBx54HKfRBwnhfgs4810sIth6xvLoZYLQSER+N4
	 6XmciyDQrWmPkDy9/k3/qVXT+0n8dLUjp2HqKnFOu+nihh7Fi4hxvF2YEeUksuMBN5
	 cZ3nAv7hpLNdsOdKfWojRszHo8hImVhT/dBSRikcV8cs1sVTvUW+dR8PAfCotxpw3n
	 WfiM7Om5zusfy3VfL4Kbk0Xiy+APFSw9XlTyJLEeaMPDM+c7ZU0nzEqFrgOzcehfQu
	 9FqwdP0/fi3Vw==
From: Giulio Benetti <giulio.benetti@benettiengineering.com>
To: linux-nfs@vger.kernel.org
Cc: Giulio Benetti <giulio.benetti@benettiengineering.com>,
	"Claude Opus 5.5" <noreply@anthropic.com>
Subject: [PATCH v2] gssd: fix build failure with musl libc
Date: Thu, 12 Nov 2026 18:27:32 +0100
Message-ID: <20261112172732.397411-1-giulio.benetti@benettiengineering.com>
X-Mailer: git-send-email 2.47.3
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CMAE-Envelope: MS4xfKbiANUI3az+ffU+fk/EQmbsBrQjPPzgQQkEllUuQoDTCb4m//ZzdAVJ4PjZxnKbM06wDL86XnA4IMDs8puJjyDY//mRcWf4ycqDsDqS1Wfkg03n23cr
 Er3rqSmcNKfkxZLYAGGkR0Zb1303gPYyxRRsjqakbQu1EszxiICzih096yb2CZENwXHRg9PjpjOftpjvg/bJNS4Vnjw4ZC0ptpMyo+i7cwQPYOCDVPgpcU6U
 TPDwqCMqYs9nGkMfJdf1niduUwuiLXF2vAzmOaOBrZEOM94Gqh88Hq9nxgpvm3DuO38v6PY5tmDqJqbDZSpN/Q==

gssd prints thread IDs with the '%lx' format specifier, which assumes
pthread_t is an unsigned long. This holds on glibc, but on musl
pthread_t is an opaque pointer type ('struct __pthread *'), so building
with -Werror=format fails:

gssd.c:546:78: error: format '%lx' expects argument of type 'long unsigned int', but argument 3 has type 'pthread_t' {aka 'struct __pthread *'} [-Werror=format=]

Fix this by explicitly casting pthread_t to unsigned long wherever it
is printed with '%lx' in gssd.c, gssd_proc.c and krb5_util.c. The cast
is safe since the value is only used for logging and unsigned long is
pointer-sized on all Linux ABIs. The output is unchanged on glibc.

Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>
Signed-off-by: Giulio Benetti <giulio.benetti@benettiengineering.com>
---
V1->V2:
* fixed and improved commit log
---
 utils/gssd/gssd.c      | 14 +++++++-------
 utils/gssd/gssd_proc.c | 18 +++++++++---------
 utils/gssd/krb5_util.c | 10 +++++-----
 3 files changed, 21 insertions(+), 21 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 022f0a89..5203d0a7 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -544,7 +544,7 @@ cleanup_active_thread_list(void)
 		default:
 			/* EDEADLK, EINVAL, and ESRCH... none of which should happen! */
 			printerr(0, "watchdog: attempt to join thread id 0x%lx returned %d (%s)!\n",
-					info->tid, err, strerror(err));
+					(unsigned long)info->tid, err, strerror(err));
 			break;
 		}
 	}
@@ -554,12 +554,12 @@ cleanup_active_thread_list(void)
 			switch (err) {
 			case EBUSY:
 				printerr(0, "watchdog: thread id 0x%lx still busy on shutdown\n",
-					 info->tid);
+					 (unsigned long)info->tid);
 				/* fall through */
 			default:
 				/* EDEADLK, EINVAL, and ESRCH... none of which should happen! */
 				printerr(0, "watchdog: attempt to join thread id 0x%lx returned %d (%s)!\n",
-						info->tid, err, strerror(err));
+						(unsigned long)info->tid, err, strerror(err));
 				/* fall through */
 			case 0:
 				saveprev = info->list.tqe_prev;
@@ -611,7 +611,7 @@ scan_active_thread_list(void)
 			 */
 			if (tret == PTHREAD_CANCELED)
 				printerr(2, "watchdog: thread id 0x%lx cancelled successfully\n",
-						info->tid);
+						(unsigned long)info->tid);
 			saveprev = info->list.tqe_prev;
 			TAILQ_REMOVE(&active_thread_list, info, list);
 			free(info);
@@ -628,14 +628,14 @@ scan_active_thread_list(void)
 			if (now.tv_sec >= info->timeout.tv_sec) {
 				if (cancel_timed_out_upcalls && !(info->flags & UPCALL_THREAD_CANCELED)) {
 					printerr(0, "watchdog: thread id 0x%lx timed out\n",
-							info->tid);
+							(unsigned long)info->tid);
 					pthread_cancel(info->tid);
 					info->flags |= (UPCALL_THREAD_CANCELED|UPCALL_THREAD_WARNED);
 					do_error_downcall(info->fd, info->uid, -ETIMEDOUT);
 				} else {
 					if (!(info->flags & UPCALL_THREAD_WARNED)) {
 						printerr(0, "watchdog: thread id 0x%lx running for %lld seconds\n",
-								info->tid,
+								(unsigned long)info->tid,
 								(long long int)(now.tv_sec - info->timeout.tv_sec + upcall_timeout));
 						info->flags |= UPCALL_THREAD_WARNED;
 					}
@@ -656,7 +656,7 @@ scan_active_thread_list(void)
 		default:
 			/* EDEADLK, EINVAL, and ESRCH... none of which should happen! */
 			printerr(0, "watchdog: attempt to join thread id 0x%lx returned %d (%s)!\n",
-					info->tid, err, strerror(err));
+					(unsigned long)info->tid, err, strerror(err));
 			break;
 		}
 	}
diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index d59c8a19..6bf5f2b5 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -186,7 +186,7 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 
 	if (get_verbosity() > 1)
 		printerr(2, "do_downcall(0x%lx): lifetime_rec=%s acceptor=%.*s\n",
-			tid, sec2time(lifetime_rec), (int)acceptor->length, (char *)acceptor->value);
+			(unsigned long)tid, sec2time(lifetime_rec), (int)acceptor->length, (char *)acceptor->value);
 	buf_size = sizeof(uid) + sizeof(timeout) + sizeof(pd->pd_seq_win) +
 		sizeof(pd->pd_ctx_hndl.length) + pd->pd_ctx_hndl.length +
 		sizeof(context_token->length) + context_token->length +
@@ -212,7 +212,7 @@ do_downcall(int k5_fd, uid_t uid, struct authgss_private_data *pd,
 	return;
 out_err:
 	free(buf);
-	printerr(1, "do_downcall(0x%lx): Failed to write downcall!\n", tid);
+	printerr(1, "do_downcall(0x%lx): Failed to write downcall!\n", (unsigned long)tid);
 	return;
 }
 
@@ -225,7 +225,7 @@ do_error_downcall(int k5_fd, uid_t uid, int err)
 	int	zero = 0;
 	pthread_t tid = pthread_self();
 
-	printerr(2, "do_error_downcall(0x%lx): uid %d err %d\n", tid, uid, err);
+	printerr(2, "do_error_downcall(0x%lx): uid %d err %d\n", (unsigned long)tid, uid, err);
 
 	if (WRITE_BYTES(&p, end, uid)) goto out_err;
 	if (WRITE_BYTES(&p, end, timeout)) goto out_err;
@@ -388,7 +388,7 @@ create_auth_rpc_client(struct clnt_info *clp,
 	/* create an rpc connection to the nfs server */
 
 	printerr(3, "create_auth_rpc_client(0x%lx): creating %s client for server %s\n", 
-		tid, clp->protocol, clp->servername);
+		(unsigned long)tid, clp->protocol, clp->servername);
 
 	protocol = IPPROTO_TCP;
 	if ((strcmp(clp->protocol, "udp")) == 0)
@@ -432,7 +432,7 @@ create_auth_rpc_client(struct clnt_info *clp,
 		tgtname = clp->servicename;
 
 	printerr(3, "create_auth_rpc_client(0x%lx): creating context with server %s\n", 
-		tid, tgtname);
+		(unsigned long)tid, tgtname);
 #ifdef HAVE_TIRPC_GSS_SECCREATE
 	memset(&req, 0, sizeof(req));
 	req.my_cred = sec.cred;
@@ -583,7 +583,7 @@ krb5_not_machine_creds(struct clnt_info *clp, uid_t uid, char *tgtname,
 	pthread_t tid = pthread_self();
 
 	printerr(2, "krb5_not_machine_creds(0x%lx): uid %d tgtname %s\n", 
-		tid, uid, tgtname);
+		(unsigned long)tid, uid, tgtname);
 
 	*chg_err = change_identity(uid);
 	if (*chg_err) {
@@ -632,7 +632,7 @@ krb5_use_machine_creds(struct clnt_info *clp, uid_t uid,
 	pthread_t tid = pthread_self();
 
 	printerr(2, "krb5_use_machine_creds(0x%lx): uid %d tgtname %s\n", 
-		tid, uid, tgtname);
+		(unsigned long)tid, uid, tgtname);
 
 	do {
 		gssd_refresh_krb5_machine_credential(clp->servername,
@@ -976,7 +976,7 @@ start_upcall_thread(void (*func)(struct clnt_upcall_info *), struct clnt_upcall_
 		return ret;
 	}
 	printerr(2, "start_upcall_thread(0x%lx): created thread id 0x%lx\n", 
-		tid, th);
+		(unsigned long)tid, (unsigned long)th);
 
 	tinfo->tid = th;
 	pthread_mutex_lock(&active_thread_list_lock);
@@ -1041,7 +1041,7 @@ handle_gssd_upcall(struct clnt_info *clp)
 	}
 	lbuf[lbuflen-1] = 0;
 
-	printerr(2, "\n%s(0x%lx): '%s' (%s)\n", __func__, tid,
+	printerr(2, "\n%s(0x%lx): '%s' (%s)\n", __func__, (unsigned long)tid,
 		 lbuf, clp->relpath);
 
 	for (p = strtok(lbuf, " "); p; p = strtok(NULL, " ")) {
diff --git a/utils/gssd/krb5_util.c b/utils/gssd/krb5_util.c
index 7ad67131..0e8f889b 100644
--- a/utils/gssd/krb5_util.c
+++ b/utils/gssd/krb5_util.c
@@ -435,7 +435,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 	pthread_mutex_lock(&ple_lock);
 	if (ple->ccname && ple->endtime > now && !nocache && !force_renew) {
 		printerr(3, "%s(0x%lx): Credentials in CC '%s' are good until %s",
-			 __func__, tid, ple->ccname, ctime((time_t *)&ple->endtime));
+			 __func__, (unsigned long)tid, ple->ccname, ctime((time_t *)&ple->endtime));
 		code = 0;
 		pthread_mutex_unlock(&ple_lock);
 		goto out;
@@ -495,7 +495,7 @@ gssd_get_single_krb5_cred(krb5_context context,
 
 	code = 0;
 	printerr(2, "%s(0x%lx): principal '%s' ccache:'%s'\n",
-		__func__, tid, pname, ple->ccname);
+		__func__, (unsigned long)tid, pname, ple->ccname);
   out:
 	if (opts)
 		krb5_get_init_creds_opt_free(context, opts);
@@ -631,7 +631,7 @@ get_full_hostname(const char *inhost, char *outhost, int outhostlen)
 	retval = getaddrinfo(inhost, NULL, &hints, &addrs);
 	if (retval) {
 		printerr(1, "%s(0x%lx): getaddrinfo(%s) failed: %s\n",
-			 __func__, tid, inhost, gai_strerror(retval));
+			 __func__, (unsigned long)tid, inhost, gai_strerror(retval));
 		goto out;
 	}
 	strncpy(outhost, addrs->ai_canonname, outhostlen);
@@ -642,7 +642,7 @@ get_full_hostname(const char *inhost, char *outhost, int outhostlen)
 
 	if (get_verbosity() && strcmp(inhost, outhost))
 		printerr(1, "%s(0x%0lx): inhost '%s' different than outhost '%s'\n", 
-			 __func__, tid, inhost, outhost);
+			 __func__, (unsigned long)tid, inhost, outhost);
 
 	retval = 0;
 out:
@@ -990,7 +990,7 @@ find_keytab_entry(krb5_context context, krb5_keytab kt,
 					tried_upper = 1;
 				}
 			} else {
-				printerr(2, "find_keytab_entry(0x%lx): Success getting keytab entry for '%s'\n",tid, spn);
+				printerr(2, "find_keytab_entry(0x%lx): Success getting keytab entry for '%s'\n", (unsigned long)tid, spn);
 				retval = 0;
 				goto out;
 			}
-- 
2.47.3

