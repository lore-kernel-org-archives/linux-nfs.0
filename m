Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 72ED038F22D
	for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2026 17:04:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769101452; cv=none; b=oM+2S7YCg7Pi8b8GzvDH+ns/6YsuzMMuWmf0MMW4cYjEmB8DSK77TUnF8BTzI/A9AoFsDh5QZYT2iGA13g8sZjW+fJtZ8p+31H5uC/XfxptfRWFwU2YNBYso4iYBKK82JCXOViE/7hxUOVsR8Q44KeP0IopvLN/gQzvV58nEtWY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769101452; c=relaxed/simple;
	bh=jaGvwTWxjoibl+hF+/HKZ7RVONAmDKA0FnLrtV87aZQ=;
	h=From:To:Subject:Date:Message-ID:MIME-Version; b=I0jF0CH3fIa6l4JMQbilbcZl8TxOsufONKlGVBiMvMn2/EulhprZ21xfvwrLP/z0M19o04NgvbUe7BbMtPSsa3QzUPJ1LdJQYBBL262yisN/oDwdFbkEjPz84qE6N64qpmCyy0ATl6pABuwZiIdFTG287yOo/0IOr/GY9n/IIZI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=UgbKJmgq; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="UgbKJmgq"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1769101442;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=j3oaQ3qCn4axm4H45fF4qQoqo+U5d3pvNtWx59keFSM=;
	b=UgbKJmgqOiO5m+LwYGMIb7+6lj/LnwHokHPHjJm1nvXd35z0RAhZdZCdFE6lPRPoKP1U6/
	osp7M1JXgk6bhQFANRbHkej/f8FRF+xJ+m3MnK32+qP5I/E6oZdKZ15hK5SoeKq2QiRxu/
	BdDgUOOQz84zC/xYCWVELy+6PEi0feg=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-636-WRskBtYJPTG9vnkhh4Z4ag-1; Thu,
 22 Jan 2026 12:04:01 -0500
X-MC-Unique: WRskBtYJPTG9vnkhh4Z4ag-1
X-Mimecast-MFC-AGG-ID: WRskBtYJPTG9vnkhh4Z4ag_1769101440
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 72F5718005BD
	for <linux-nfs@vger.kernel.org>; Thu, 22 Jan 2026 17:04:00 +0000 (UTC)
Received: from aion.redhat.com (unknown [10.22.88.133])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 417AA30002D1;
	Thu, 22 Jan 2026 17:04:00 +0000 (UTC)
Received: from aion.redhat.com (localhost [IPv6:::1])
	by aion.redhat.com (Postfix) with ESMTP id 778E05D1019;
	Thu, 22 Jan 2026 12:03:58 -0500 (EST)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com,
	linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] nfsiostat: normalize the mountpoints passed in from the command line
Date: Thu, 22 Jan 2026 12:03:58 -0500
Message-ID: <20260122170358.1121341-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

If the mountpoint passed in from the command line contains a trailing
'/' character, then nfsiostat winds up printing statistics for all
mounts instead of printing statistics for the specific mount that was
requested.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 tools/nfs-iostat/nfs-iostat.py | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index e46b1a83..69d24a11 100755
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -589,8 +589,8 @@ client are listed.
 
     (options, args) = parser.parse_args(sys.argv)
     for arg in args[1:]:
-        if arg in mountstats:
-            origdevices += [arg]
+        if os.path.normpath(arg) in mountstats:
+            origdevices += [os.path.normpath(arg)]
         elif not interval_seen:
             try:
                 interval = int(arg)
-- 
2.52.0

