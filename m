Received: from mail-ot1-f44.google.com (mail-ot1-f44.google.com [209.85.210.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BA3F142C51D
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 20:43:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786653827; cv=none; b=MnQKQi5F//1ah79YquCr8ic3GL4TyxXUD9XEVbNbBewHDY8rPoh/7JAAjKDCuqlIxKJUvSlWlpAjM08LZ2qOfQkbm03rdeDp9Gpg9lpix7h7QKV3/+R2gc7pbpbdYvVdaW3HR4uLB99iDAIP7X7ZTEQ/bu6u3qd68jmp6eMB86s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786653827; c=relaxed/simple;
	bh=EIvCgoWQkWytA5MGMgi3qyxTBZZkOOwHQvloQ76tzTY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ez/MveD0UAKJqw5Nc2o/fQ7VW61u5Q87pmrSoi/Pb6F1j0ffMAqJryyTZSbBzJD8MwniVqIc7DpzP8THVg8opKkimpPY01KrlfFgr4aJjIdI4Tmz5rJmjVMvzoI7p7LhtkaqGpBn445nk13kP8HZN1Lupz4bVKy7g31dD0xarLI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=pD/p8K9K; arc=none smtp.client-ip=209.85.210.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="pD/p8K9K"
Received: by mail-ot1-f44.google.com with SMTP id 46e09a7af769-7eb5bdb50fcso252125a34.1
        for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 13:43:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786653824; x=1787258624; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=ulnKnS3jehSybCYQ1SFSPWYkPCPlxM2/qx+2NL9lbOs=;
        b=pD/p8K9KNjkC9D7qI3AJybDERhLbOygiWJuBg7gFLjMbeqt3+Jq1IPsFgujVy3m2uW
         Y4tx9zkj/RmcWoiOnGrGsmqpnB1M0kWpwp4hYGA3swIP9vSQNHrbtE1X4YfqKBQnsOcj
         bVNhNIg2J1huDc37yXZn9h766HeJrTVQzfcCn2/x93GSyD0dvkhbvhAdc+AmH+i8NsNi
         3tQDQ+OyvFYHmsN3kBILsITfF8r7ZE+89R2Itgm31LebeWiKDDJxGhtfTRawLizl3kYa
         QHt/JwbwkVEdu9z8vC9MOlCgitbX2l/+eTm8U3ALo8amTdyYMDNjQ8vwliNxAuwUcmS4
         DSVA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786653824; x=1787258624;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=ulnKnS3jehSybCYQ1SFSPWYkPCPlxM2/qx+2NL9lbOs=;
        b=PYbhbxaLQz3+KEK9l6nZBnbrcHOHpQrnAUhZ7QF2NK6lVngUvaJ3RJ6htfTCcblu5I
         q8vy3Tdd9F+IvYtgYuKMfDqNNfMoKBRGp0ruhp3Grq2t1+mb7E3LLW9C7sg/wu+HlovB
         X+280xQ22csnSwS9CYHrnKWzxzdNjuM7Asx1JN1+OO7qfFJFUNKRGwvCPdokAZrZ1bM8
         KCbuEEHb52xGf3oyfHFygLijrzCjVIfblxCUnxjnhkGOAjUhftkb72ygdhLBT6sJEZks
         Ynwk2QGpux9YpLNyjauqKC8jzJEWnnbsVTqaGfbPnwFXkwbxmMSyY+4LLYy8TZPjf/N6
         2a/g==
X-Gm-Message-State: AOJu0YyryCTJYBRZ5extrMLIGm+SurM2Cxlz0DvhHZvrn4XSp31owNDI
	kp8wWaWBqkbWb/TXRrX1BR+T0VhieD2onZjXAnxhAxNycvfqiWQKb54uEEwUA+0QtV0=
X-Gm-Gg: AR+sD138ByqoQs98qvAQlzyoUKnEBdsVaHOQ8ilTeFUkXsn3K0c/PCUuLuIFej7RXJ7
	Z7hCHFk5zb1qWDmwppE4mwB39qAPZayLwAQxG2uTme8JaVhYWcscvXThSZ5r9vf2/82AGT/eIfO
	Bw39LTRpVgnmN1p2JHwKGzlw3ltJuNmk+VEW5/FxU2U0kNvuB7lsZesTWLBrZrgA1Stvoe2W0o/
	t6KM74G1NnH/Qkr6g1wEjNNNNaxQI/gvg3y4b52yJpXUTGL3ObmQ/BPIZrTrmDaLotVNVQ4iS+f
	02HSFJ0ZBPmDfs+sSKfaFNKBavq8rgeRfcc8+idY+Z8REX4ehZ+T8CaBYErZXGgfrmEEDvn83KL
	XY+kl21J6QO0N8iz3mPloy1I5kHMs4oaNVwAOdBb5RyE+B/txbzwTnrFGN6zO5YHq25pSHpmJhz
	XkgmhpZcWV1XfuKd8353aZLNRbsb2X1RqvUWn9p8375j/BMspjFijG0ohHUyC0nhgkA8nDWRQQZ
	66yzffl1OUGn62URmh66hXJ
X-Received: by 2002:a05:6808:c3cb:b0:487:61da:70fb with SMTP id 5614622812f47-4b241ccc82fmr670088b6e.10.1786653824504;
        Thu, 13 Aug 2026 13:43:44 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b22c8c09e4sm2484254b6e.0.2026.08.13.13.43.43
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 13 Aug 2026 13:43:43 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 17/21] NFSv4/pnfs: Dispatch CB_NOTIFY_DEVICEID DELETE to race recovery
Date: Thu, 13 Aug 2026 16:43:13 -0400
Message-ID: <bf8e5b4ab1539a6ec0c9735605cd228ebc3c5935.1786653063.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1786653063.git.bcodding@hammerspace.com>
References: <cover.1786653063.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Turn on the RFC 8881 Section 18.40.4 DELETE handling: a DELETE for a
deviceID that no live layout references keeps today's cheap behavior
(drop the cached device, no state-manager wake).  A DELETE for a
deviceID that live layouts still reference -- which a conformant
server never sends (Section 20.12) -- is deferred to the state
manager, which TEST_STATEIDs the referring layouts, recovers revoked
ones, and confirms or refutes the delete with GETDEVICEINFO.

The deferred case no longer unhashes the device immediately: if the
recovery concludes the DELETE was erroneous (the deviceID still
exists and a referring layout is still valid), the client keeps
using the cached device.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/callback_proc.c | 31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 1721c6dd2250..df4cbe7670e7 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -391,19 +391,34 @@ __be32 nfs4_callback_devicenotify(void *argp, void *resp,
 				continue;
 		}
 		/*
-		 * Unhash the cached device first so re-resolution cannot
-		 * re-pin the stale node, then re-point any references
-		 * pinned under live layouts (RFC 8881 Section 12.2.10).
-		 * The epoch bump lets an in-flight GETDEVICEINFO detect
-		 * that its reply may predate the change.
+		 * CHANGE: unhash the cached device first so re-resolution
+		 * cannot re-pin the stale node, then re-point any
+		 * references pinned under live layouts (RFC 8881 Section
+		 * 12.2.10).  The epoch bump lets an in-flight
+		 * GETDEVICEINFO detect that its reply may predate the
+		 * change.
+		 *
+		 * DELETE: a deviceID still referenced by a live layout
+		 * must never be deleted (Section 20.12), so a referenced
+		 * one may be racing layout revocation -- defer to the
+		 * state manager for the Section 18.40.4 recovery (this
+		 * thread cannot issue the fore-channel RPCs it needs).
+		 * Unreferenced: "no harm is done" -- drop the cached
+		 * device as before.
 		 */
-		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
+		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE) {
 			nfs4_deviceid_bump_change_epoch();
-		nfs4_delete_deviceid(ld, cps->clp, &dev->cbd_dev_id);
-		if (dev->cbd_notify_type == NOTIFY_DEVICEID4_CHANGE)
+			nfs4_delete_deviceid(ld, cps->clp, &dev->cbd_dev_id);
 			pnfs_layout_reresolve_deviceid_byclid(cps->clp, ld,
 							&dev->cbd_dev_id,
 							dev->cbd_immediate);
+		} else if (pnfs_layout_deviceid_referenced_byclid(cps->clp,
+						ld, &dev->cbd_dev_id)) {
+			pnfs_deviceid_delete_mark(cps->clp, ld,
+						  &dev->cbd_dev_id);
+		} else {
+			nfs4_delete_deviceid(ld, cps->clp, &dev->cbd_dev_id);
+		}
 	}
 	pnfs_put_layoutdriver(ld);
 out:
-- 
2.53.0

