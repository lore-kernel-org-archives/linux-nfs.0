Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 849CEB67E
	for <linux-nfs@vger.kernel.org>; Sat, 28 Mar 2026 07:16:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774682187; cv=none; b=nuSp0sJA8R+ZBXInUaEC5YSs5k23xhlNPXrVaWrKpH8OIOP+PtgZ0jNAbXK8Lmr9pcwI2IvOouzw1mPtbWAams6hQiOyjoU90eNqeIU8nf8+8ni7pt0KhgepiY/dRJI+SmvjeQAtzHEyhecVeTuK0kVH9tTD9ooD6eC2dXhY/WA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774682187; c=relaxed/simple;
	bh=+OAsvMc1WoQj9P3eOj+/rGpi0dRXJ2IdEqixE8o2Hwg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MtSSPs/AhHm/8OEBPlNFZVZr42rdCQS8PE2CoElcb4bVf+f/Qu93ewWXBrrTeOtphTINlr9W+KiMH1bW5JKeeTtfiGPiQgR4o9Ul69DSXKkPFrY55BkBrekwKkIKHflO3TntK/yqQAeCE83s+h51XtKlyKcZi8yh1QKZhtnwDNM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Ham9IJBy; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Ham9IJBy"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1774682185;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=dIMkP/f5LcHGS7CQzHbQpLJOnuWz2n7FoMMhO59VKSs=;
	b=Ham9IJByCc+zS7AJMIkfB1akJ7llW4qwHtfjh053YUFODLY1Z2QNzp3gQXOhygAg4X2UjC
	xXatAOly/1fkHPzMljcGEtWFTKorIMtupGQOIIpyqDOG++2cn+D+Kpbs4VrWZW/5jN1Fxh
	UGbkTkdRSfuOT3KitFERDqx9u+Ghas4=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-124-w9QPKiO_NZWldi1fytGKgA-1; Sat,
 28 Mar 2026 03:16:19 -0400
X-MC-Unique: w9QPKiO_NZWldi1fytGKgA-1
X-Mimecast-MFC-AGG-ID: w9QPKiO_NZWldi1fytGKgA_1774682178
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id BF9051800365;
	Sat, 28 Mar 2026 07:16:18 +0000 (UTC)
Received: from localhost (dell-per660-10.rhts.eng.pek2.redhat.com [10.73.4.30])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id D1FAC1800765;
	Sat, 28 Mar 2026 07:16:16 +0000 (UTC)
From: Jianhong Yin <jiyin@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: calum.mackay@oracle.com,
	jlayton@kernel.org,
	bcodding@redhat.com,
	smayhew@redhat.com,
	jiyin@redhat.com
Subject: [PATCH v3 3/4] pynfs: nfs4.1/nfs4server.py allow v4.2 mount
Date: Sat, 28 Mar 2026 15:15:32 +0800
Message-ID: <20260328071533.3135266-3-jiyin@redhat.com>
In-Reply-To: <20260328071533.3135266-1-jiyin@redhat.com>
References: <20260328071533.3135266-1-jiyin@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

Signed-off-by: Jianhong Yin <jiyin@redhat.com>
---
 nfs4.1/nfs4server.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/nfs4.1/nfs4server.py b/nfs4.1/nfs4server.py
index 16ef113..6422008 100755
--- a/nfs4.1/nfs4server.py
+++ b/nfs4.1/nfs4server.py
@@ -578,7 +578,7 @@ class NFS4Server(rpc.Server):
         self._fsids = {self.root.fs.fsid: self.root.fs} # {fsid: fs}
         self.clients = ClientList() # List of attached clients
         self.sessions = {} # List of attached sessions
-        self.minor_versions = [1]
+        self.minor_versions = [1, 2]
         self.config = ServerConfig()
         self.opsconfig = OpsConfigServer()
         self.actions = Actions()
-- 
2.53.0

