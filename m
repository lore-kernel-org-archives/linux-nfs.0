Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.47
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795106908;
	b=3ym8aHssz9r+FL596N7DM4ckurPvuLVQP+XwW1XCeWkdfcXdPhmKl4fylany5gjLVzn3
	 rJ1sXQJeJl/FslWFouIj4X2BsDAXVB8kM83n3B/vR/eRhcPhr9PELfXiAHFlYL9P/gAbW
	 SD9J1lmX3+ymcVFKDq4VMlt7rJqY1nZNLnCR7xmO4vPfPkqm6ptMZPbrkxg1ez2JxVHML
	 KLJE5+u5ejFtdSoGlL6YJMf7r6HWUiCriTgSf/3chGKCTVNewyXy0vmBcV6cBBMRJ8Q2Y
	 9LljHDRRJ/+0biUlEaFhokQRCLvEe6VNw5WBuru9R0vqEKKL3eomblohTdBCzaQ6/sA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795106908;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:X-Google-Original-From:To:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=ITmnRSGm+SZNrHX5w09Tuht/srybBIYz4hEHB4zI8E4=;
	b=0pyItFfb5JJuEz1kluxx43LLQs5S7Yot78pl40GJIy0SQxeCusU5PWgweVhgAFDX4PU1
	 T9DlqWjprWeGau6M/SxuN+7E/tA7ye+BIA8v4dbFs9k4VNHMr5WEdjqtChMmHZpN3K9rD
	 25zbK/XPSeVEvvrA6oBtZW2k7+E5YW9KU2xy4Ay5qCMIwoNE124W7Egavl6HGJStSHlQH
	 p08LMtiN0tA77Mx+0JnR7visMSe2MI/zrR7w0CZXthzyIShIVNAjEP3DAUE/XnnDX4/TP
	 lGR42U9PgFX+Fbtppf0MhOLVEQNzzrmy/QhLb+xqZLzFpcl1cjLJSYndIfQ8bI9C7GA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b="hf7/9LQu";
	arc=none smtp.remote-ip=209.85.210.47
Received: from mail-ot1-f47.google.com (mail-ot1-f47.google.com [209.85.210.47])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1AAD0606A336
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 16:48:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1AAD0606A336
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=hf7/9LQu
Received: by mail-ot1-f47.google.com with SMTP id 46e09a7af769-85c1135c286so1858706a34.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 08:48:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1795106906; x=1795711706; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=ITmnRSGm+SZNrHX5w09Tuht/srybBIYz4hEHB4zI8E4=;
        b=hf7/9LQuM2+S1vIHSz7DUhJkCYmIgjvFF0cwxey2VwhVkec1n3tmwi/94kv9wR99YJ
         pL6b2vBSGLpx2/0YHvQnmit0qbClk3njqKN0MDH67mjxgwCzju2Xprjq67qMuaoxgCCo
         q63KvYekhqEPKZoqu9C3mEO8nTn2vsxY5ngQqBNMh6LhSMJPdctMlpvYTY9AMQCJg8iF
         qFRvaZFTd0Lc6V0SljB3eH5vpRI+/vEJ+VRhZj/3TSMrKy5bJaEL+uyc/rk2H0NxAYNh
         q5YF0SERveNlkBQrOnrAdRjN8v5I/8f/3Te3C4hWVqVp24BpJ0mmFY6JYrfFrbwPCW3R
         pVfQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795106906; x=1795711706;
        h=content-transfer-encoding:mime-version:message-id:date:subject:to
         :from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=ITmnRSGm+SZNrHX5w09Tuht/srybBIYz4hEHB4zI8E4=;
        b=JTPh/X9vMzYyRtFbWQlHUO1zChGbRGLSxP1RlgZRCpo7WbhQdzvtPl9TFPKLPQjHdg
         WAdzFdtsN75id4EJyNJQUHaPEq1AOS3ClSOC6u2bwHuwdwxdKNoC2FLPJ7XFr5/HFr92
         PvlLoCnWjL/t9hVUxeWBD9lZE1oKMKf1+l3KmzWpLvhuerDvWF2nGUZLeoFDTL1GAliQ
         za9WXEHNyZ6z91Mi/Py+3CHfV2PN2t82UWO9rZJb7U852wX1owkNeeZoab3qbhUs1O6J
         +g5j0r6DVdPfYTPtctMWeeYPq4K6Qao7f5s60mJVT4eln/VjVryEOvrrSANCMMOifS1T
         a7jg==
X-Forwarded-Encrypted: i=1; AL+hErGHgPlnzOfBmwi3clKHKOfHBApLpmJAaZa5HY8Gl4EYsmeni3CyQNzrJfO0oc6nH3VLbjeGZ+4umvo=@vger.kernel.org
X-Gm-Message-State: APuU4Z9xaeC8Xz6hHrJAo2AuUwIUi+Ywrf9LbAxzHLk5Dxbgmd2b8vBW
	WtZlFINee90Gsw1BKM2VsH55/r/8ULoz20E3pMfNfVP0+tMMgxIMpqOSmxVkSrpuAcdelN3vsB5
	uIVrq
X-Gm-Gg: AYBFou0aG3qEWag3TsK17etx1zjUbtC6I9TJv7ygJso8BQqU8+MQJAkgSHsP1c7wpP4
	6O07TlQcZvRBSoPnJSXM4XiCCEGXjuExIcSl5h5pCslMefsk2eT33qmLJOLpFTJQdrUlIFTOngw
	bfQ97fnNDWcC/ebV969OV3hEv/Gqqnw0oFsG3akLUpOGgynTnF/Io0CitPfY6/RxPysrScHOevD
	7w197HzOGy3ven1qXwQIxQRKKFi15JmiOnOxM4fHYYLvyTsdkh5dsyuVws6bNeR6hcBI7gobL5C
	e3LB09+141rdJ2RNzunqemT5rCdW1r66SrymZYZQsVQVkpUj65eQ3en6SbvD7Zh/QDw0u2JkE1k
	5w273WLH9HCmGmR1l9dDx93QDhOTBG+sxqgFHjANRgUVLWbFUWIq+kDaI21cv4p9L04OzhtTPHY
	XoZ2N24Eb0Vbf3b3rBIDKamlBccNgEb1T9HZ3HbqJOTkyfAeGuRESx7uhVmtJECaMcXYI12IIB/
	TutyXJNHjq7XMajyi0Nk6EUW+ST8zwKrr1bVKCHgyIW34ZBWSoj0L/FeFCSVKiptPQNaWV+uMy6
	hzMGljtIKiQQzlGVFLDqv0kEMMPm0E2eYsSdFDBJb3vQ+o3B01nn8+9ItoEr1Cz+MoT8
X-Received: by 2002:a05:6830:6410:b0:862:ba3a:f04b with SMTP id 46e09a7af769-86315a79781mr637288a34.31.1795106905759;
        Thu, 19 Nov 2026 08:48:25 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-8631692d9f7sm17041a34.24.2026.11.19.08.48.24
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 19 Nov 2026 08:48:25 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: steved@redhat.com,
	linux-nfs@vger.kernel.org
Subject: [PATCH] nfsdcld: stop polling a dead cld pipe after nfsd shuts down
Date: Thu, 19 Nov 2026 11:48:22 -0500
Message-ID: <18b45da6abb51186d62cc0f8fb559fe8fa2bd0d2.1795106790.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
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

When nfsd shuts down, the kernel removes rpc_pipefs/nfsd/cld. The next
read on the open pipe fails, and cld_pipe_read_msg() tries to reopen it.
That open fails with ENOENT, cld_pipe_open() leaves the old fd and event
in place, and cldcb() re-adds the event on the dead fd. The fd always
reports HUP, so nfsdcld spins at full CPU and floods syslog with "pipe
read failed: Broken pipe" until nfsd comes back.

If the reopen fails, close the dead pipe and drop its event. The
inotify watch on the pipefs directory reopens the pipe when nfsd
recreates it.

Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 utils/nfsdcld/nfsdcld.c | 26 ++++++++++++++++++++++++--
 1 file changed, 24 insertions(+), 2 deletions(-)

diff --git a/utils/nfsdcld/nfsdcld.c b/utils/nfsdcld/nfsdcld.c
index 772cf3147e88..3ffecb5a28f7 100644
--- a/utils/nfsdcld/nfsdcld.c
+++ b/utils/nfsdcld/nfsdcld.c
@@ -186,6 +186,19 @@ cld_pipe_open(struct cld_client *clnt)
 	return 0;
 }
 
+static void
+cld_pipe_close(struct cld_client *clnt)
+{
+	if (clnt->cl_event) {
+		event_free(clnt->cl_event);
+		clnt->cl_event = NULL;
+	}
+	if (clnt->cl_fd >= 0) {
+		close(clnt->cl_fd);
+		clnt->cl_fd = -1;
+	}
+}
+
 static void
 cld_inotify_cb(int UNUSED(fd), short which, void *data)
 {
@@ -753,7 +766,15 @@ cld_pipe_read_msg(struct cld_client *clnt)
 	return 0;
 
 fail_read:
-	cld_pipe_open(clnt);
+	/*
+	 * If the pipe is gone, re-arming the dead fd would spin on HUP.
+	 * Drop it and let cld_inotify_cb reopen the pipe when it returns.
+	 */
+	if (cld_pipe_open(clnt) < 0) {
+		xlog(D_GENERAL, "%s: waiting for %s to reappear",
+			__func__, pipepath);
+		cld_pipe_close(clnt);
+	}
 	return -1;
 }
 
@@ -794,7 +815,8 @@ cldcb(int UNUSED(fd), short which, void *data)
 		cld_not_implemented(clnt);
 	}
 out:
-	event_add(clnt->cl_event, NULL);
+	if (clnt->cl_event)
+		event_add(clnt->cl_event, NULL);
 }
 
 int

base-commit: 79770ef91411cc2d3f97eb5efdd43a7d39b0070e
-- 
2.53.0

