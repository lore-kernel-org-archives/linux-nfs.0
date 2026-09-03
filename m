Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1FFAA4F6466
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:53:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457999; cv=none; b=NtU6tGGwVAnLJcoZw2CIo9LgkeljrASSWvxswkcZ+E2F2kaKwb2AIrxrpAsT9Jl2PqmyOq6zp5l+TSzkwvlUht+WDFHMlkungI5vavM0baS3e6ZmUAQpn9VD9imV0ryLLVeQdyKVEWQCI4wsDYw1smLiIqg4cvGLpBtmEo5Yo/A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457999; c=relaxed/simple;
	bh=RkntlZrKbxpkHFI6QWFEM7cXzcuDF5OiHIuWSZVwzm8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sqFIltDNc631QnE+wnL9E1f1Gtqm7KHZmYkLXXGBBoLvTXJ5rLrrhw94YRt3m+/hlNvWND5/T/bnBSS0117T8yJQrWROex0fV9v2+y3OmqocD4dYDzm8Na7DJx8c5vXrEIsjDUWaXyuChxr7TM6yl4WeQO6vBbiMuKM4589Z7vM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=IQ3n66Mb; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="IQ3n66Mb"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457997;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Ai+g2tZlYUtIwYcEi5NR9XtvK5f3zPzd+bVg5oY3UNs=;
	b=IQ3n66MbQJ0RyMqfGY5805OrVWj+KdiK3nET1x6eSkYnqLkcRRdr8s5mOV9e3CCc+t5QUT
	D+C2EgaKqNg6g/TN4l3aiVW1tehxveGCr6TLkBd9+V215jYbbshsAfK4umCQxKz0AVKA5G
	AqsXJ7lM3G1p0ALi4UC+BkNpWhd55RI=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-447-UZg0-uZcPjis5l69XDDBSQ-1; Thu,
 03 Sep 2026 13:53:15 -0400
X-MC-Unique: UZg0-uZcPjis5l69XDDBSQ-1
X-Mimecast-MFC-AGG-ID: UZg0-uZcPjis5l69XDDBSQ_1788457995
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id F28BC18655A5
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:53:14 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id D07D018005BD;
	Thu,  3 Sep 2026 17:53:14 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 42A8A5345B90;
	Thu, 03 Sep 2026 13:53:14 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 2/2] junction: fix use-after-free in locations_to_fslocdata()
Date: Thu,  3 Sep 2026 13:53:13 -0400
Message-ID: <20260903175313.1214070-3-smayhew@redhat.com>
In-Reply-To: <20260903175313.1214070-1-smayhew@redhat.com>
References: <20260903175313.1214070-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

While parsing a multi-location junction, locations_to_fslocdata() sets
last_path = root_path and then frees root_path, leaving last_path
dangling.  On the next iteration, strcmp(rootpath, last_path)
dereferences freed memory.

Fix it by transferring ownership of root_path to last_path when they
should be aliased.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 support/export/cache.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/support/export/cache.c b/support/export/cache.c
index 059f48a7..9f71c1dd 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -2806,19 +2806,25 @@ static bool locations_to_fslocdata(struct nfs_fsloc_set *locations,
 			}
 			remaining -= (size_t)len;
 			ptr += len;
+			free(last_path);
 			last_path = rootpath;
+			rootpath = NULL;
 		}
 
 		seen = true;
 		free(rootpath);
+		rootpath = NULL;
 		free(server);
+		server = NULL;
 	}
 
+	free(last_path);
 	xlog(D_CALL, "%s: fslocdata='%s', ttl=%d",
 		__func__, fslocdata, *ttl);
 	return seen;
 
 out_false:
+	free(last_path);
 	free(rootpath);
 	free(server);
 	return false;
-- 
2.55.0

