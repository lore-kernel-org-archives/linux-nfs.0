Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 691813B8948
	for <linux-nfs@vger.kernel.org>; Fri,  3 Apr 2026 13:27:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775222869; cv=none; b=MyoVfi1Nb3g4s1vPWruU+gCx9LwSPEKhCETdnKUce8HUOCrYmfAIi8RYPTXFBhaKhXDmZCWK9sXGXYGkyShMiOj/oH7FvAqYaafOYWLwfHZI0VH+LTGosN2YrFk4yzIa4SzfviSvRHWWWxiQuJr5bsqCV36mEcz6CLLEyoXgpnA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775222869; c=relaxed/simple;
	bh=DTkf9p+IGlx6vKM8SHLnDpTuDQJTqGtOUmppcFFvUfs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=hyUkRi7xDEXDuwurPTquWDuyVjNXxrOkkCT+mFWlpupSbwcZOwSYU6GkmCu6O9DdkBN1jo5pNglZqRMH6A/q+9TO1ybQDjQUaEYqnolhVNSMFUxFVLIVr3kMXPO6ECmYKxpPXtvhzbdH3UVngMvmeskl8VGT75EgneFMR/3fNug=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=WuekJqhD; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="WuekJqhD"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1775222867;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=MiCwDZstq5aJbe4LYzSx+3NktZ9S6qCBfqlln7xo4P8=;
	b=WuekJqhDNF+XoDa2IRbf3v2p068C2K4zRzj0mh9iB3x3xVulJYmpM8gDmGekLgKeu37uMs
	FfMXAQcYrvJHeprj28S/KUoF8rJ27dAwbkZZKFp5sbr75JeisZUp1MVKC7pFWqkDCVtmb6
	m2pnflIPHQpVo40pXeuRhT7rq3MtDAc=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-201-NRPfjFQzOG2XFJ4TBe6T7A-1; Fri,
 03 Apr 2026 09:27:44 -0400
X-MC-Unique: NRPfjFQzOG2XFJ4TBe6T7A-1
X-Mimecast-MFC-AGG-ID: NRPfjFQzOG2XFJ4TBe6T7A_1775222863
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 7886E1964CF9;
	Fri,  3 Apr 2026 13:27:39 +0000 (UTC)
Received: from aion.redhat.com (unknown [10.22.88.38])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 4873A1800998;
	Fri,  3 Apr 2026 13:27:39 +0000 (UTC)
Received: from aion.redhat.com (localhost [IPv6:::1])
	by aion.redhat.com (Postfix) with ESMTP id 38BDD749DED;
	Fri, 03 Apr 2026 09:27:38 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: calum.mackay@oracle.com
Cc: linux-nfs@vger.kernel.org,
	Chen Hanxiao <chenhx.fnst@fujitsu.com>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 2/5] pynfs: fix the check for delegated attribute support
Date: Fri,  3 Apr 2026 09:27:35 -0400
Message-ID: <20260403132738.1482011-3-smayhew@redhat.com>
In-Reply-To: <20260403132738.1482011-1-smayhew@redhat.com>
References: <20260403132738.1482011-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

The DELEG24 and DELEG25 tests should work regardless of whether the
server supports delegated attributes or not.  fattr4_supported_attrs is
a bitmap4, so FATTR4_OPEN_ARGUMENTS needs to be shifted when checking to
see if that bit is set.  Fix it, and remove the now unnecessary check
added by 3216fc3 ("pynfs: fix key error if FATTR4_OPEN_ARGUMENTS is not
supported").

Cc: Chen Hanxiao <chenhx.fnst@fujitsu.com>
Cc: Jeff Layton <jlayton@kernel.org>
Fixes: f684000 ("st_deleg: test delegated timestamps in CB_GETATTR")
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 nfs4.1/server41tests/st_delegation.py | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/nfs4.1/server41tests/st_delegation.py b/nfs4.1/server41tests/st_delegation.py
index d41f12d..934e558 100644
--- a/nfs4.1/server41tests/st_delegation.py
+++ b/nfs4.1/server41tests/st_delegation.py
@@ -345,10 +345,7 @@ def _testCbGetattr(t, env, change=0, size=0):
                 OPEN4_SHARE_ACCESS_WRITE |
                 OPEN4_SHARE_ACCESS_WANT_WRITE_DELEG)
 
-    if FATTR4_OPEN_ARGUMENTS not in caps:
-        fail("FATTR4_OPEN_ARGUMENTS not supported")
-
-    if caps[FATTR4_SUPPORTED_ATTRS] & FATTR4_OPEN_ARGUMENTS:
+    if caps[FATTR4_SUPPORTED_ATTRS] & (1 << FATTR4_OPEN_ARGUMENTS):
         if caps[FATTR4_OPEN_ARGUMENTS].oa_share_access_want & OPEN_ARGS_SHARE_ACCESS_WANT_DELEG_TIMESTAMPS:
             openmask |= 1<<OPEN_ARGS_SHARE_ACCESS_WANT_DELEG_TIMESTAMPS
 
-- 
2.53.0

