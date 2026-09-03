Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F064043BDCB
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:50:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457833; cv=none; b=dj8RRx+f1yeYPpfnr/G5zR1kFzD4pblIdhWq4LaeRJ1MHM1o5yT5N3QjYuLwCndFTfcICAgekePopmpH1PYvyEWTwMzvINRvlHRpR5H/EFLf0rdGw7siExtM56XJ5LUx4A3UUCtAIfDgSViF89WsD2s8DQLKZYfjkbQhYrm1/Kg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457833; c=relaxed/simple;
	bh=Y60/9v8LIyM0GvOi6u++FLluXsPUakcXWT3B080zk9E=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ZEGHbmG2qSsMxLk6YFDccnz4wvNkdynzVkzus1qjoyhVgjo1Z1IPGPVHJgRFXXpL5lV50XZYd77uFpbXMKePh90NA98L5vEebhsVi2tXDDZWlxRHv2wjs7/1jW5VLgb0v9HAgbe9SBm0wH+ibJbR0UtNhmD4chM0cQ05VX0DUAQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=MOpGhU1F; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="MOpGhU1F"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457830;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=OSxAJQYK5PLdHBsfobWkUX2mUZasMeroKffR3I1q7us=;
	b=MOpGhU1FlZMogAh1tm9AyUkj4GVhqwRXgch78MReg/4jZxps/kPAL8MG9ZrgDyPUnUmES+
	0B57ZGkgyPa58yEnwYuvLZaswEF2rwbxdNej+qCPmcphHLJhKTd0QVDy3H9t4U0IriYSuF
	hlY7dQ518E94IKBFw7mw64kXNhPZvj8=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-574-2W1Rc2zKPZiBdGR3DhKLsA-1; Thu,
 03 Sep 2026 13:50:29 -0400
X-MC-Unique: 2W1Rc2zKPZiBdGR3DhKLsA-1
X-Mimecast-MFC-AGG-ID: 2W1Rc2zKPZiBdGR3DhKLsA_1788457828
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id AF5F119541B0
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:50:28 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 8A7271800762;
	Thu,  3 Sep 2026 17:50:28 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id D59C15345B6F;
	Thu, 03 Sep 2026 13:50:27 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] fsidd: handle accept4() failures before creating client event
Date: Thu,  3 Sep 2026 13:50:27 -0400
Message-ID: <20260903175027.1213868-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

Handle failures from accept4() before creating a client event,
and add a short backoff on errors indicating resource exhaustion.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 support/reexport/fsidd.c | 28 ++++++++++++++++++++++++++--
 1 file changed, 26 insertions(+), 2 deletions(-)

diff --git a/support/reexport/fsidd.c b/support/reexport/fsidd.c
index 51750ea3..9b80b451 100644
--- a/support/reexport/fsidd.c
+++ b/support/reexport/fsidd.c
@@ -17,6 +17,7 @@
 #include "xlog.h"
 
 static struct event_base *evbase;
+static struct event *srv_ev;
 static struct reexpdb_backend_plugin *dbbackend = &sqlite_plug_ops;
 
 /* assert_safe() always evalutes it argument, as it might have
@@ -133,21 +134,44 @@ static void client_cb(evutil_socket_t cl, short ev, void *d)
 	}
 }
 
+static void srv_reenable_cb(evutil_socket_t fd, short ev, void *d)
+{
+	(void)fd;
+	(void)ev;
+	(void)d;
+	if (srv_ev)
+		event_add(srv_ev, NULL);
+}
+
 static void srv_cb(evutil_socket_t fd, short ev, void *d)
 {
 	int cl = accept4(fd, NULL, NULL, SOCK_NONBLOCK);
 	struct event *client_ev;
+
+	if (cl == -1) {
+		if (errno == EMFILE || errno == ENFILE || errno == ENOMEM ||
+				errno == ENOBUFS) {
+			struct timeval tv = {0, 200000};
+			event_del(srv_ev);
+			event_base_once(evbase, -1, EV_TIMEOUT, srv_reenable_cb,
+					NULL, &tv);
+		}
+		return;
+	}
 	
 	(void)ev;
 	(void)d;
 
 	client_ev = event_new(evbase, cl, EV_READ | EV_PERSIST | EV_CLOSED, client_cb, event_self_cbarg());
-	event_add(client_ev, NULL);
+	if (!client_ev || event_add(client_ev, NULL) == -1) {
+		if (client_ev)
+			event_free(client_ev);
+		close(cl);
+	}
 }
 
 int main(void)
 {
-	struct event *srv_ev;
 	struct sockaddr_un addr;
 	socklen_t addr_len;
 	char *sock_file;
-- 
2.55.0

