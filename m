Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C90343901F
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:43:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457390; cv=none; b=lFviQiY6DbRrH++1L73CJsjzuWtPzb5drkNmjrY8dHcfq0kCxkCk/g6emOD1xcJ+ONZn0beMHK8G1nzM9QnzSvaZaxRRi1mE1M1iFXAuNTyfWWAAaUMiFHHoEIWmNzREaE8CGG2Ejk9c8uDzkqtFa6zz/luz6mJFcNeEWgWAzo0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457390; c=relaxed/simple;
	bh=pdCqoiI+EFIYqU3lggraDan7EV21jyA/8db4q/RuEy8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ek3Z9HGD+89qnKyzRw7mFhVO/7eayFfBfCiH09XO1HB6/FegcbF3JXI/tuW+ecsGkk4uMSTV2VgSYZQdFhfIUWp1fvPNJQwQ9HBa+KxfjfWoyuyO/w3ouO0hHqPvelFfBTxd+EUDNiYFjVNMwZQQWTfT4wHQYSD5R2IU5pKxPnU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=faWYbMXz; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="faWYbMXz"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457386;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=lbL9bQ0pEY55PXg7drkquh/ZrJwbSCV9exHGcUondDQ=;
	b=faWYbMXzPF6k4+xCQCj2/tKlzLBJuJswvRFmmfZv0Pw7JUKWxryfxqS5wrjZy9TJtlWHN1
	RTfHTgQMWsCD2CE5uD8BH0n1DBQveSnbunQ9CUTtcMD6W5koblLfF9jM2GzpCBNETzgtW4
	0UjuwK4puEr0WNL1eXPrDr2vhlf5Dmw=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-568-nWnh9xecMI6_FbUiQ_Hlug-1; Thu,
 03 Sep 2026 13:42:55 -0400
X-MC-Unique: nWnh9xecMI6_FbUiQ_Hlug-1
X-Mimecast-MFC-AGG-ID: nWnh9xecMI6_FbUiQ_Hlug_1788457366
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id A525D1860975
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:42:46 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 7F76C7DF;
	Thu,  3 Sep 2026 17:42:46 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id DB82B53458C8;
	Thu, 03 Sep 2026 13:42:45 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [rpcbind PATCH 2/6] rpcbind: bound stats lists in rpcbs_getaddr() and rpcbs_rmtcall()
Date: Thu,  3 Sep 2026 13:42:41 -0400
Message-ID: <20260903174245.1213147-3-smayhew@redhat.com>
In-Reply-To: <20260903174245.1213147-1-smayhew@redhat.com>
References: <20260903174245.1213147-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

Limit addrinfo and rmtinfo linked lists to 4096 entries by trimming
the oldest entries from the tail after prepending a new one. This
prevents unbounded memory growth from a large number of unique
program/version/netid combinations.

Assisted-by: Claude:claude-opus-4-6
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 src/rpcb_stat.c | 35 ++++++++++++++++++++++++++++++++---
 1 file changed, 32 insertions(+), 3 deletions(-)

diff --git a/src/rpcb_stat.c b/src/rpcb_stat.c
index 2e5226c..0799a47 100644
--- a/src/rpcb_stat.c
+++ b/src/rpcb_stat.c
@@ -50,6 +50,8 @@
 #include <string.h>
 #include "rpcbind.h"
 
+#define MAX_STAT_BUCKETS 4096
+
 static rpcb_stat_byvers inf;
 
 void
@@ -104,8 +106,9 @@ void
 rpcbs_getaddr(rpcvers_t rtype, rpcprog_t prog, rpcvers_t vers, char *netid,
 	      char *uaddr)
 {
-	rpcbs_addrlist *al;
+	rpcbs_addrlist *al, *cut = NULL, *tmp;
 	struct netconfig *nconf;
+	int listlen = 0;
 
 	if (rtype >= RPCBVERS_STAT)
 		return;
@@ -121,6 +124,9 @@ rpcbs_getaddr(rpcvers_t rtype, rpcprog_t prog, rpcvers_t vers, char *netid,
 				al->success++;
 			return;
 		}
+		listlen++;
+		if (listlen == MAX_STAT_BUCKETS - 1)
+			cut = al;
 	}
 	nconf = rpcbind_get_conf(netid);
 	if (nconf == NULL) {
@@ -142,14 +148,25 @@ rpcbs_getaddr(rpcvers_t rtype, rpcprog_t prog, rpcvers_t vers, char *netid,
 	}
 	al->next = inf[rtype].addrinfo;
 	inf[rtype].addrinfo = al;
+
+	if (cut) {
+		al = cut->next;
+		cut->next = NULL;
+		while (al) {
+			tmp = al;
+			al = al->next;
+			free(tmp);
+		}
+	}
 }
 
 void
 rpcbs_rmtcall(rpcvers_t rtype, rpcproc_t rpcbproc, rpcprog_t prog,
 	      rpcvers_t vers, rpcproc_t proc, char *netid, rpcblist_ptr rbl)
 {
-	rpcbs_rmtcalllist *rl;
+	rpcbs_rmtcalllist *rl, *cut = NULL, *tmp;
 	struct netconfig *nconf;
+	int listlen = 0;
 
 	if (rtype >= RPCBVERS_STAT)
 		return;
@@ -170,6 +187,9 @@ rpcbs_rmtcall(rpcvers_t rtype, rpcproc_t rpcbproc, rpcprog_t prog,
 				rl->indirect++;
 			return;
 		}
+		listlen++;
+		if (listlen == MAX_STAT_BUCKETS - 1)
+			cut = rl;
 	}
 	nconf = rpcbind_get_conf(netid);
 	if (nconf == NULL) {
@@ -194,7 +214,16 @@ rpcbs_rmtcall(rpcvers_t rtype, rpcproc_t rpcbproc, rpcprog_t prog,
 	rl->indirect = 1;
 	rl->next = inf[rtype].rmtinfo;
 	inf[rtype].rmtinfo = rl;
-	return;
+
+	if (cut) {
+		rl = cut->next;
+		cut->next = NULL;
+		while (rl) {
+			tmp = rl;
+			rl = rl->next;
+			free(tmp);
+		}
+	}
 }
 
 void *
-- 
2.55.0

