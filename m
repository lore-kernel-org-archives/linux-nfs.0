Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9ED8D49483A
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:42:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457372; cv=none; b=svt4H2lVzgO/x8VpokUqLTByrD6bnuwpvAd7MIYhTysPfussep29DZ4DxlsBdj9TO3S/7bBIwWwbWzHzq2gaNabFL5ll59fZxi1KMY0960AdYytjDRwFd/AI5WWVFUw1cQBp9RY2SZAXTnRg/aMX8QcvDliSZyJ5VSoeyl1Wbjk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457372; c=relaxed/simple;
	bh=UIiGjU9hw6nqZe/k3Ug4vxSBoij2CaV8+q20jM6c5zg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=A77sVX3sInr3OCao3b1kb1BEzNX+SlGdnGk9QzkZ0WIeHn/XVwaUTyi0N06QO2fNl02oXu7oLlFBGa3pmMAmaUzGlMq5bczNVTIyaTBUTvfcsTlKdnOReRaWYVK0HnhWp/6HDC+tMadCmYPdu5ILF28YQUWgXsQbPdnPhS41cao=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=EtTAXC5o; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="EtTAXC5o"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457369;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=P63bsNNDFVSutnTHs9np3EwRUpaSbIyh6B7UqMYFmuM=;
	b=EtTAXC5o05FQj6V/Uyji65j23OppT3aGBHUP8onoQ/C91A/6cKh3piDxSeTVxsbQNqxxQi
	kFG0cRIBKlkPZkGQDsqR3KkOfId47MqDCNuso60iJG9Xxwoc8M0gUdD5/rxaU7h/eZPlFi
	APPUJSLmbxqQzRGZqkoRIYtixoV7Di0=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-567-9NKa5ybBP8CXNHJyUPfryg-1; Thu,
 03 Sep 2026 13:42:48 -0400
X-MC-Unique: 9NKa5ybBP8CXNHJyUPfryg-1
X-Mimecast-MFC-AGG-ID: 9NKa5ybBP8CXNHJyUPfryg_1788457367
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 74969195395F
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:42:47 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 5098F1956056;
	Thu,  3 Sep 2026 17:42:47 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 2167353458E5;
	Thu, 03 Sep 2026 13:42:46 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [rpcbind PATCH 6/6] rpcbind: only free the forward slot if the reply xid matched the request xid
Date: Thu,  3 Sep 2026 13:42:45 -0400
Message-ID: <20260903174245.1213147-7-smayhew@redhat.com>
In-Reply-To: <20260903174245.1213147-1-smayhew@redhat.com>
References: <20260903174245.1213147-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

If remote calls are enabled and if the ephemeral forwarding ports are
exposed, it's possible to spoof replies to forwarded requests using a
bogus xid, causing the forward slots to be freed and potentially
interfering with sending replies to legitimate remote call requesters.

Only free the forward slot in handle_reply() if the reply xid matched
the original request xid.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 src/rpcb_svc_com.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/src/rpcb_svc_com.c b/src/rpcb_svc_com.c
index 0763fc4..2c007eb 100644
--- a/src/rpcb_svc_com.c
+++ b/src/rpcb_svc_com.c
@@ -1196,6 +1196,7 @@ handle_reply(int fd, SVCXPRT *xprt)
 	struct r_rmtcall_args a;
 	struct sockaddr_storage ss;
 	socklen_t fromlen;
+	bool_t matched_xid = FALSE;
 
 	buffer = malloc(RPC_BUF_MAX);
 	if (buffer == NULL)
@@ -1234,6 +1235,7 @@ handle_reply(int fd, SVCXPRT *xprt)
 	if (fi == NULL) {
 		goto done;
 	}
+	matched_xid = TRUE;
 	_seterr_reply(&reply_msg, &reply_error);
 	if (reply_error.re_status != RPC_SUCCESS) {
 		if (debugging)
@@ -1271,7 +1273,8 @@ done:
 		xlog(LOG_DEBUG, "handle_reply:  NULL xid on exit!\n");
 	}
 #endif
-	} else
+	}
+	if (matched_xid == TRUE)
 		(void) free_slot_by_xid(reply_msg.rm_xid);
 	return;
 }
-- 
2.55.0

