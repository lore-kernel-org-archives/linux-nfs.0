Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2E85533939F
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 23:02:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788217374; cv=none; b=cP9lHD0rA3hrGHppOuSSe6x2rpoyu5J9G92611HZlEk/HhZOmod9KoyVzcLmq3OqTV6L/dXaQeOu7FFbSHflHiM1iQ/tMbhJGLAdntEM/wy0sNQcngE3aGQytwX9Ms8vAKR9/UDj21GzTlzPvbfMx7i80MPSlg1CwmOE9oSwLHg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788217374; c=relaxed/simple;
	bh=47DNV+mr1CirzUHJ8K5dK9jzj6L6FHHuZqvX+VQ8PjU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=t08+E8h2XnFhhcqB+KgFHzMPdJM3aqHzCIE5FeQ07O6LE4hWGc3SDL51TpVw8mzh4E5by4Ae0asqNAJrivadz9QsEROJB8ZW6jcEbFT+2R3vcc3SbyVbSae0Znsqx8bYrU85DoVaHv09raMdrJAQa0Z3jUUrxFP7vEcmgVNvO/s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=BaJRtHLH; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="BaJRtHLH"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788217371;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding;
	bh=SEgYasCLxqwMuyP663MUzrse53H5bb9FMPGlcbRVARA=;
	b=BaJRtHLH+QTTP5RDAS3LqSGcSEBfLotWJorkfClzn9n0yjw90YbGv0NOEo0fTT1htHKnEQ
	aJC7huIMHGVKc7YuLX7CfPUIY7/WkQCyhyMybK8iUKMWeZGKotZ65YIcIjkh3P1THQ41Di
	d4J4vHhuOcY8pbCZvu88yYyjrmEgaV0=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-388-CamXENn1Mn2sS-MrCG0rsA-1; Mon,
 31 Aug 2026 19:02:50 -0400
X-MC-Unique: CamXENn1Mn2sS-MrCG0rsA-1
X-Mimecast-MFC-AGG-ID: CamXENn1Mn2sS-MrCG0rsA_1788217369
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 2121919772FF
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 23:02:49 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet03.pony-001.prod.iad2.dc.redhat.com [10.2.32.114])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 7674D1956049;
	Mon, 31 Aug 2026 23:02:48 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 4E14752FFF2B;
	Mon, 31 Aug 2026 19:02:47 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] gssd: clean up threads on shutdown
Date: Mon, 31 Aug 2026 19:02:47 -0400
Message-ID: <20260831230247.814387-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Valgrind reports leaks such as the following:

==1781== 736 bytes in 2 blocks are possibly lost in loss record 831 of 926
==1781==    at 0x487F36B: calloc (vg_replace_malloc.c:1616)
==1781==    by 0x403A75F: calloc (rtld-malloc.h:44)
==1781==    by 0x403A75F: allocate_dtv (dl-tls.c:477)
==1781==    by 0x403B2E5: _dl_allocate_tls (dl-tls.c:734)
==1781==    by 0x4B6579E: pthread_create@@GLIBC_2.34 (in /usr/lib64/libc.so.6)
==1781==    by 0x400E531: start_upcall_thread.constprop.0 (gssd_proc.c:971)
==1781==    by 0x400EC34: handle_gssd_upcall (gssd_proc.c:1117)
==1781==    by 0x48B9D9B: event_persist_closure (event.c:1623)
==1781==    by 0x48B9D9B: event_process_active_single_queue (event.c:1682)
==1781==    by 0x48BA5BE: event_process_active (event.c:1783)
==1781==    by 0x48BA5BE: event_base_loop (event.c:2006)
==1781==    by 0x400A431: main (gssd.c:1292)
==1781==

This is due to the thread-local storage allocated by pthread_create() as
well as the upcall_thread_info struct allocated by
start_upcall_thread().  Those do eventually get freed by the watchdog
thread in scan_active_thread_list().  The thread-local storage gets
freed when pthread_tryjoin_np() succeeds and the upcall_thread_info gets
freed via TAILQ_REMOVE() + free().  But since the watchdog thread sleeps
between iterations (30 seconds by default), from the perspective of
tools like valgrind there’s a leak.

Add logic to clean up the threads on shutdown to make tools like
valgrind happy.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/gssd/gssd.c | 60 +++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 60 insertions(+)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 6a41fc5d..e381c0f2 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -98,6 +98,7 @@ static struct event_base *evbase = NULL;
 
 int upcall_timeout = DEF_UPCALL_TIMEOUT;
 static bool cancel_timed_out_upcalls = false;
+pthread_t watchdog_tid;
 
 TAILQ_HEAD(topdir_list_head, topdir) topdir_list;
 
@@ -498,6 +499,61 @@ gssd_clnt_krb5_cb(int UNUSED(fd), short UNUSED(which), void *data)
 	handle_krb5_upcall(clp);
 }
 
+static void
+cleanup_active_thread_list(void)
+{
+	struct upcall_thread_info *info;
+	bool cancelled = false;
+	void *tret, *saveprev;
+	int err;
+
+	pthread_mutex_lock(&active_thread_list_lock);
+	TAILQ_FOREACH(info, &active_thread_list, list) {
+		err = pthread_tryjoin_np(info->tid, &tret);
+		switch (err) {
+		case 0:
+			saveprev = info->list.tqe_prev;
+			TAILQ_REMOVE(&active_thread_list, info, list);
+			free(info);
+			info = saveprev;
+			break;
+		case EBUSY:
+			pthread_cancel(info->tid);
+			do_error_downcall(info->fd, info->uid, -ETIMEDOUT);
+			cancelled = true;
+			break;
+		default:
+			/* EDEADLK, EINVAL, and ESRCH... none of which should happen! */
+			printerr(0, "watchdog: attempt to join thread id 0x%lx returned %d (%s)!\n",
+					info->tid, err, strerror(err));
+			break;
+		}
+	}
+	if (cancelled) {
+		TAILQ_FOREACH(info, &active_thread_list, list) {
+			err = pthread_tryjoin_np(info->tid, &tret);
+			switch (err) {
+			case EBUSY:
+				printerr(0, "watchdog: thread id 0x%lx still busy on shutdown\n",
+					 info->tid);
+				/* fall through */
+			default:
+				/* EDEADLK, EINVAL, and ESRCH... none of which should happen! */
+				printerr(0, "watchdog: attempt to join thread id 0x%lx returned %d (%s)!\n",
+						info->tid, err, strerror(err));
+				/* fall through */
+			case 0:
+				saveprev = info->list.tqe_prev;
+				TAILQ_REMOVE(&active_thread_list, info, list);
+				free(info);
+				info = saveprev;
+				break;
+			}
+		}
+	}
+	pthread_mutex_unlock(&active_thread_list_lock);
+}
+
 /*
  * scan_active_thread_list:
  *
@@ -628,6 +684,7 @@ start_watchdog_thread(void)
 		printerr(0, "ERROR: pthread_create failed: ret %d: %s\n",
 			 ret, strerror(errno));
 	}
+	watchdog_tid = th;
 	return ret;
 }
 
@@ -1290,6 +1347,9 @@ main(int argc, char *argv[])
 
 	printerr(0, "event_dispatch() returned %i!\n", rc);
 
+	pthread_cancel(watchdog_tid);
+	cleanup_active_thread_list();
+
 	gssd_destroy_krb5_principals(root_uses_machine_creds);
 
 	while (!TAILQ_EMPTY(&topdir_list)) {
-- 
2.55.0

