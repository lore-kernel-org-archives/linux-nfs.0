Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 42E2D397343
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 23:03:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788217383; cv=none; b=FC3jnDE9DdCPDzeZ2rFhxTwhSlKjBr6TruauXOhDvfBrfnyPuuMKC/MrWXPXVKaAWtLz8UCsAnqK6LR0uz2PUyBS248WpAQin8ouH/Am9PeIQReTIFoTM/qmQFpb0a4VWeFpjrI/1xO8YhoZSkNG17U4FIA2sovjN0tkxmm27r8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788217383; c=relaxed/simple;
	bh=FlDDWiRSelJau5qmyDsb+4YM4uhDrhzX50oXA3qft0w=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=jHOfcE+Q6ToXgl2HoHL7WgIs9HGC/IwQB7EmUqiZCS0bCseJzYTJLG5fDYRuYXHxTAUCqjhWmiI+FNMDCFLVP9sdWEme/JYnRox7Dh15ArLNtydvjszzF8jmHgDWvp5rlWx1C8zjoxJ5WeqvQoz0Qb/7KlALKXVIvR+O+j2v3lo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=JmWzQIat; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="JmWzQIat"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788217380;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=AFlnAYkTzWxhBfsAsW14aG2XLujsocrbqMu51D1BaP4=;
	b=JmWzQIatuHjtPXzM5Us0DrsXiRJ/gP/jmlBvZCRRqfVJ+G4pX0zOss0ZXp9iXrcYoBDrql
	wB5jiNqds6s6hbjiv5FhhITwN9fspe6N4pXlt+P1de8oP3M27P9HuqMSlpqiGYE4nYbm/p
	Oz5wTtOEoavYUdqM8rfrInB0me4chfU=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-569-QNdYTe_hOG27BxsDzfWZ7w-1; Mon,
 31 Aug 2026 19:02:59 -0400
X-MC-Unique: QNdYTe_hOG27BxsDzfWZ7w-1
X-Mimecast-MFC-AGG-ID: QNdYTe_hOG27BxsDzfWZ7w_1788217378
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 60C711933F83
	for <linux-nfs@vger.kernel.org>; Mon, 31 Aug 2026 23:02:58 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet03.pony-001.prod.iad2.dc.redhat.com [10.2.32.114])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 2A6F45B1;
	Mon, 31 Aug 2026 23:02:58 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 0146B52FFF39;
	Mon, 31 Aug 2026 19:02:57 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] gssd: fix upcall_* leak when re-reading service info
Date: Mon, 31 Aug 2026 19:02:56 -0400
Message-ID: <20260831230256.814412-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

gssd_scan_clnt() calls gssd_read_service_info() whenever clp->prog == 0,
and the function's fail path leaves clp->prog == 0. If an initial read
fails (e.g. the "info" file is not fully populated when inotify fires),
the fail path strdup()s the parsed values into clp->upcall_address,
upcall_port, upcall_protoname and upcall_service. A subsequent re-scan
then calls gssd_read_service_info() again and overwrites those fields
without freeing them first: the success path sets them to NULL and the
fail path strdup()s fresh copies, leaking the previous allocations.

Free the upcall_* fields at the top of the function before repopulating.
clp is calloc()'d so the fields are NULL on the first call, making the
free() calls safe.

This fixes the following leak:

==1300== 5 bytes in 1 blocks are definitely lost in loss record 13 of 929
==1300==    at 0x4877826: malloc (vg_replace_malloc.c:447)
==1300==    by 0x4B7B9FE: strdup (strdup.c:42)
==1300==    by 0x400D08D: gssd_read_service_info (gssd.c:373)
==1300==    by 0x400D08D: gssd_scan_clnt (gssd.c:734)
==1300==    by 0x400D7C6: gssd_inotify_clnt (gssd.c:922)
==1300==    by 0x400D7C6: gssd_inotify_cb (gssd.c:988)
==1300==    by 0x48B9D9B: event_persist_closure (event.c:1623)
==1300==    by 0x48B9D9B: event_process_active_single_queue (event.c:1682)
==1300==    by 0x48BA5BE: event_process_active (event.c:1783)
==1300==    by 0x48BA5BE: event_base_loop (event.c:2006)
==1300==    by 0x400A431: main (gssd.c:1292)
==1300==

Assisted-by: Claude Opus 4.8 <noreply@anthropic.com>
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/gssd/gssd.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index e381c0f2..223d5dfe 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -276,6 +276,21 @@ gssd_read_service_info(int dirfd, struct clnt_info *clp)
 	char *port = NULL;
 	char *servername = NULL;
 
+	/*
+	 * This may be a re-scan of a client whose previous read failed
+	 * (gssd_scan_clnt only calls us while clp->prog == 0, which the fail
+	 * path below leaves set).  Free any upcall_* values left over from that
+	 * attempt so we don't leak them when we repopulate the fields below.
+	 */
+	free(clp->upcall_address);
+	free(clp->upcall_port);
+	free(clp->upcall_protoname);
+	free(clp->upcall_service);
+	clp->upcall_address = NULL;
+	clp->upcall_port = NULL;
+	clp->upcall_protoname = NULL;
+	clp->upcall_service = NULL;
+
 	fd = openat(dirfd, "info", O_RDONLY);
 	if (fd < 0) {
 		printerr(0, "ERROR: can't open %s/info: %s\n",
-- 
2.55.0

