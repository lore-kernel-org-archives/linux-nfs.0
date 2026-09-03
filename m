Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2CB3D4A33E1
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:50:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457809; cv=none; b=rwwpat6GZmcdxGowh4krahZVFN1W0E9L7N9hCps4fBq9A732FIwNdCI5QojMpHfd/PGtKntGdkShRUuEJ5Iv1ME3jgaL9Mx3id/u+/7XUqK7ooMcUCT9Qp2IB+Rohp8XFFQq/mTHf0aU1VS8EL2nhJJFjsl9Gb6b2JBx2OHa2mU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457809; c=relaxed/simple;
	bh=HggqaxW/3co+iPiE4MbvnlDvFS0/BjocCO0bib0PW6c=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ngvQJNgkbEkMxuZW9i6UR5iRQ2FUXjl0fdUST7ekCdBYJJGBeAStcHayCtY3ykPkee0vwgjv9m6/npG3Czhu4LpARMi/okNS/0JyqLWXPwNpiU7Uc1d/KRN8qewpUpJsX34q01gBR/R5Pa28SpH/d8CwS1MEXqvvRO9xS6O7T1w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=hP4wB4HA; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="hP4wB4HA"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457806;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=dFZkaRRjhhUv5JdTD0PT7bzBQf2XK9IqpkWNtgfZr00=;
	b=hP4wB4HAu4/MgsfcSOgs18O1dYFiVXiC+3zZ3HcpTyiwH85dgIIgWRSJ25LZCsTFTfh0aX
	f3fIGqWzwDakycwzyaZG0WUtNPqCBZD5ihAU+ohFO5TV+j0Xh0kQOt40KXAWVFshKtISjz
	HZbPW17noVVR3oowGpI2EFkoddehKLc=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-312-MoxQKvqIP7meIt4NpELcBw-1; Thu,
 03 Sep 2026 13:50:05 -0400
X-MC-Unique: MoxQKvqIP7meIt4NpELcBw-1
X-Mimecast-MFC-AGG-ID: MoxQKvqIP7meIt4NpELcBw_1788457804
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 147021843AE7
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:50:04 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id E657118005BB;
	Thu,  3 Sep 2026 17:50:03 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 38E7A5345B60;
	Thu, 03 Sep 2026 13:50:03 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] statd: fix notify_list struct leak in nlist_free
Date: Thu,  3 Sep 2026 13:50:03 -0400
Message-ID: <20260903175003.1213806-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

nlist_free() freed an entry's string members but never the notify_list
struct itself, despite its name and comment ("Destroy an entry ... and
free the memory"). Every caller was expected to free the struct
separately, but several did not:

  - process_reply() and process_notify_list() (rmtcall.c) clean up
    entries cloned onto the notify list during SM_NOTIFY handling.
  - sm_unmon_1_svc() and sm_unmon_all_1_svc() (monitor.c) leak the same
    way on the SM_UNMON paths.

Fix the root cause by having nlist_free() free the struct, and drop the
now-redundant free() calls in sm_mon_1_svc() and load_one_host() that
would otherwise double-free.

nlist_kill() previously called nlist_free(head, *head) followed by
free(*head); since nlist_remove() (called from nlist_free) already
advanced *head to the next entry, that free(*head) freed the wrong,
still-live element. Pass NULL so nlist_free() only frees the entry and
advance the list manually.

Assisted-by: Claude Opus 4.8 <noreply@anthropic.com>
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/statd/monitor.c | 2 --
 utils/statd/notlist.c | 4 ++--
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index 76ef16f1..f7f4342a 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -225,7 +225,6 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 
 failure:
 	xlog_warn("STAT_FAIL to %s for SM_MON of %s", my_name, mon_name);
-	free(clnt);
 	return (&result);
 }
 
@@ -245,7 +244,6 @@ load_one_host(const char *hostname,
 	clnt->dns_name = strdup(hostname);
 	if (clnt->dns_name == NULL) {
 		nlist_free(NULL, clnt);
-		free(clnt);
 		return 0;
 	}
 
diff --git a/utils/statd/notlist.c b/utils/statd/notlist.c
index 45879a43..91030d85 100644
--- a/utils/statd/notlist.c
+++ b/utils/statd/notlist.c
@@ -210,6 +210,7 @@ nlist_free(notify_list **head, notify_list *entry)
 	if (NL_MON_NAME(entry))
 		free(NL_MON_NAME(entry));
 	free(entry->dns_name);
+	free(entry);
 }
 
 /* 
@@ -222,8 +223,7 @@ nlist_kill(notify_list **head)
 
 	while (*head) {
 		next = (*head)->next;
-		nlist_free(head, *head);
-		free(*head);
+		nlist_free(NULL, *head);
 		*head = next;
 	}
 }
-- 
2.55.0

