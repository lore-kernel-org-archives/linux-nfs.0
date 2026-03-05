Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6FFB437475C
	for <linux-nfs@vger.kernel.org>; Thu,  5 Mar 2026 12:42:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772714547; cv=none; b=qzvdrlm0ySK0vbKB51WW7C20NakTlGMhp58SJjgEDxPDcmET6CnTiT/zWd91s7UTwIdMmHIWMmXTuAv+fBTLRW9hocPMJvrB+Jud9nfzXxJSRqCw1MB5Z4L2W3iuo6WqYVogS4YSpbiwwfTtfqGxytcX0ddEzNX2n6BQyqEvw14=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772714547; c=relaxed/simple;
	bh=x94KP+rItaRNnoG6udAZWHz6Zn+enaW1zUybnyS9rJk=;
	h=From:To:Subject:Date:Message-ID:MIME-Version; b=hz/5++gsDxzheWZ4S4XVtwg2sXRvwRg4cgTXO92G0VbDK3U+bu03fGNnLpxO4gmgg+3qXlXDh6MUnFlegscRjcDSZji4Glba/lZ+vTFlm957aPOwwfY3pANiNTGZ3ma2V8H29CAXt9N/IyxKhcxV5Oes3QajDKFnEe1HrUY6o6U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=GnXIHT8P; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="GnXIHT8P"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1772714545;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=4vEoWBP9RHuEOFYvdqAUTsjkxJTUUpQjIJKiWvALPHE=;
	b=GnXIHT8P2WGE/264QN8Cp4wQEXhKjpssszmzBqJSk5c8jkT5WNkLkNkxzO5guDStvpdqG7
	DoWq1NsMiJwHW+qVPH2muiUoXnTGFsnuhKC3RPFMRS89XvqmFe+4ZbaQc5jkdHuYl4QwPf
	l+t72QWcCV0GOJXklVxEeNzy7IL4BI0=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-117-wyWjsFNbM7-cNVqnlnIwIw-1; Thu,
 05 Mar 2026 07:42:24 -0500
X-MC-Unique: wyWjsFNbM7-cNVqnlnIwIw-1
X-Mimecast-MFC-AGG-ID: wyWjsFNbM7-cNVqnlnIwIw_1772714543
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 67DEE195608F
	for <linux-nfs@vger.kernel.org>; Thu,  5 Mar 2026 12:42:23 +0000 (UTC)
Received: from bighat.com (unknown [10.22.80.84])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id EF40B18001FE
	for <linux-nfs@vger.kernel.org>; Thu,  5 Mar 2026 12:42:22 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH] Revert "nfsrahead: enable event-driven mountinfo monitoring"
Date: Thu,  5 Mar 2026 07:42:21 -0500
Message-ID: <20260305124221.55407-1-steved@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

This reverts commit 2b62ac4c273a647df07400dc1126fceb76ad96c0.
---
 tools/nfsrahead/main.c | 35 +----------------------------------
 1 file changed, 1 insertion(+), 34 deletions(-)

diff --git a/tools/nfsrahead/main.c b/tools/nfsrahead/main.c
index 64953346..b7b889ff 100644
--- a/tools/nfsrahead/main.c
+++ b/tools/nfsrahead/main.c
@@ -16,7 +16,6 @@
 
 #define CONF_NAME "nfsrahead"
 #define NFS_DEFAULT_READAHEAD 128
-#define MNT_NM_TIMEOUT 10000
 
 /* Device information from the system */
 struct device_info {
@@ -118,39 +117,7 @@ out_free_device_info:
 
 static int get_device_info(const char *device_number, struct device_info *device_info)
 {
-	int ret;
-	struct libmnt_monitor *mn = NULL;
-	int timeout_ms = MNT_NM_TIMEOUT;
-
-	ret = get_mountinfo(device_number, device_info, MOUNTINFO_PATH);
-	if (ret == 0)
-		return 0;
-
-	mn = mnt_new_monitor();
-	if (!mn)
-		goto fallback;
-
-	if (mnt_monitor_enable_kernel(mn, 1) < 0) {
-		mnt_unref_monitor(mn);
-		goto fallback;
-	}
-
-	while (timeout_ms > 0) {
-		int rc = mnt_monitor_wait(mn, timeout_ms);
-		if (rc > 0) {
-			ret = get_mountinfo(device_number, device_info, MOUNTINFO_PATH);
-			if (ret == 0) {
-				mnt_unref_monitor(mn);
-				return 0;
-			}
-		} else {
-			break;
-		}
-	}
-	mnt_unref_monitor(mn);
-	return ret;
-
-fallback:
+	int ret = get_mountinfo(device_number, device_info, MOUNTINFO_PATH);
 	for (int retry_count = 0; retry_count < 5 && ret != 0; retry_count++) {
 		usleep(50000);
 		ret = get_mountinfo(device_number, device_info, MOUNTINFO_PATH);
-- 
2.53.0

