Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.129.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795196928;
	b=0fY7CGlArpPazUW0LrH+qLKgc0n0DEnMDK2QF9MajAs26tbhQx1x1TZyOJsUdDe1Z32I
	 pC+NF1veKZpqhFBpoHys1uw4NdCc3vCZxsXbirLYTa9sUoaIwBvfBuqCnYgSUIWhSUFkY
	 39DI0kdwu5k1ANOpxFnHUaE5aKJQCDhUL4iRlcc7BbI/zB12DEldG1CGsRjIO8Zd3KKgU
	 1sHvWa5q7Kdk18rXG/+Iusw/FzAPUm+AB/jVa8zDueugb9NPfa+WmZUSUI0/TJtF3FnbJ
	 G7YQgQJABRsz4H+jEKeBzdHvHvwvufeZ6hOjhmG2ht2U5akQfFmXsfkJlKgImFQPy5Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795196928;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:MIME-Version:Content-Transfer-Encoding:X-Scanned-By;
	bh=o84fsAMTRlrH2Byy0Pd39NzVX6kvW0DR92m/U+OCbKQ=;
	b=S+myy5uu1g/OndXemjHvbTYXPFx0v7+MPNLrVAbqr4cbPgk/3LVsMSujX9PTzBUNH2WV
	 nZUzfNCCYXy4/HAsnCuLU34SzAbpPMsBApVKrK9ywYjHg/xCNbio/mr/Fj0JYxvJjCp0c
	 pbfU36e/6DzO0YGma8QdT/QPB10MH9N3jSMQrIlCcpXMO3AUZeOrwolzzdrWhei+9c4Oj
	 2seBvgu8buHxd+VkpqXqfN4xGigPRiT2RktnJrPDfjtXkDeCymO9X/zwz2QOd85SDWr6d
	 FXF5YhKKXHHvbRuEfEwvwxVdrHUK33y18Wr662GRkkLGJw+GRLE4cGE4TgiN47lH4kA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=TsoOvmij;
	arc=none smtp.remote-ip=170.10.129.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4E79060A260B
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 17:48:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4E79060A260B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=TsoOvmij
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1795196924;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=o84fsAMTRlrH2Byy0Pd39NzVX6kvW0DR92m/U+OCbKQ=;
	b=TsoOvmijQkzcz9Un9/aTVuwzKibBeYqlM3Lv6ricXV6tDMsVfNj/2MtVaMOlge2tVMJwj5
	cigc0R9ifvB6YrnxPXLLFAN8bApCTbEPoq0G9h1/7dK/zjZxbkeQN7Cwszov1/45aJtaKf
	t0JFmdd8LibJ/UaBkG07QHBPbMoSPEo=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-457-IlkPKf1FNSGxAn3UxgsmKQ-1; Fri,
 20 Nov 2026 17:48:41 +0000
X-MC-Unique: IlkPKf1FNSGxAn3UxgsmKQ-1
X-Mimecast-MFC-AGG-ID: IlkPKf1FNSGxAn3UxgsmKQ_1795196920
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 9E6F91954233;
	Fri, 20 Nov 2026 17:48:40 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 5E703343;
	Fri, 20 Nov 2026 17:48:40 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 665F75C0636B;
	Fri, 20 Nov 2026 12:48:39 -0500 (EST)
From: Scott Mayhew <smayhew@redhat.com>
To: calum.mackay@cdmnet.org,
	jlayton@kernel.org,
	cel@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] pynfs: fix testLeasePeriod sleep with short lease periods
Date: Fri, 20 Nov 2026 12:48:38 -0500
Message-ID: <20261120174838.45668-1-smayhew@redhat.com>
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
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

testLeasePeriod() computed its in-lease sleep as min(lease - 10, 1),
which goes negative when the server's lease period is less than 10
seconds, causing time.sleep() to raise "ValueError: sleep length must
be non-negative". Clamp the sleep to a non-negative value.

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
Note: knfsd doesn't allow the lease time to be less than 10 seconds, but
Hammerspace does.

 nfs4.1/server41tests/st_exchange_id.py | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/nfs4.1/server41tests/st_exchange_id.py b/nfs4.1/server41tests/st_exchange_id.py
index acb1a93..66053fa 100644
--- a/nfs4.1/server41tests/st_exchange_id.py
+++ b/nfs4.1/server41tests/st_exchange_id.py
@@ -498,7 +498,7 @@ def testLeasePeriod(t, env):
     # CREATE_SESSION
     chan_attrs = channel_attrs4(0,8192,8192,8192,128,8,[])
     sec = [callback_sec_parms4(0)]
-    time.sleep(min(lease - 10, 1))
+    time.sleep(max(0, min(lease - 10, 1)))
     # Inside lease period, create_session will success.
     res1 = c1.c.compound([op.create_session(c1.clientid, c1.seqid, 0,
                                         chan_attrs, chan_attrs,
-- 
2.56.1

