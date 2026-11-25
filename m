Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.128.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795601848;
	b=ewEtX5JAdGA6OGS699q4rvpSkybircrFl+FUzmhCkzX1iI9dN/Plt2SbyPse1HNAq5Vg
	 VbdyDm5pp0ZRP5MLaev0vZ/giecTAUjJEy1SHTacKN/LVHG5dX/zeXyeguVkQtcHbStZ1
	 Kg7x8wrxtK7Opaptcw4LGnTEFxMm/tSdLmWeOD71PBftiuTdjCql2ggEBGbwGgy//5E6g
	 LRicsmqt27THVf3vFzh3x0un/8LgCPnzGicrpR7emCV+nQcclczA7TUDX4QtOwXQN9mUe
	 o02tjUYDA1nFU81j9XcuHi78XROmkqeR7Exb5yB+Okz1usmtpK+3kNmiKKmF7njjRbA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795601848;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=DwvC3/Uc/Q4JTglnun5WSsaA4EcGf3iK2OxV4jCGl18=;
	b=jGEMzFE1vqsmdKA+bPD/SgzLctqorCSzs3pywg2W9LDxiLlm3r1C66mYFHojAvg/ztMZ
	 KLO6/YBknlT5wsfhut/PLWX1E6UGu8DpWPKbm8h5gXhKf/u9qpZM1wGo2rd/UQp0XY+cw
	 dEPAdoJ2GxYa+2ic0/i8d8ulmCGLJayHMY/l9kqd9K4dwN/JdzTtmPeyCXEkRVwOvfWkI
	 tKyi47RZ+JUQrMb7UpCZbkIu47r0ObFto0kCMEveoGbaSS0gm9amdl9wAwyXJMSD5+VgB
	 vJcstTbJBwppIi0b1vS3KXkBSUhWCvnY1RlVuyjfZIlU0csX5f4gwjruDT1e+/a9WWA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=HXxiItM2;
	arc=none smtp.remote-ip=209.85.128.42
Received: from mail-wm1-f42.google.com (mail-wm1-f42.google.com [209.85.128.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DFE93606A321
	for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 10:17:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DFE93606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=HXxiItM2
Received: by mail-wm1-f42.google.com with SMTP id 5b1f17b1804b1-4bb69f5b161so36142975e9.0
        for <linux-nfs@vger.kernel.org>; Wed, 25 Nov 2026 02:17:27 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1795601846; x=1796206646; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=DwvC3/Uc/Q4JTglnun5WSsaA4EcGf3iK2OxV4jCGl18=;
        b=HXxiItM21uvFZ1UiM9CyPnY1K8te/jWgmGGDlAK8Lz/uLh7dPzOilpVnm2xb0THECp
         N94lZG8XJoddlrBAp6VSSpTmBLcw7Irx3TFh00qiRFrFfQC4UkNQQQpCv89Dw+yPmdNM
         tVRw/aVj6RZFdju4hLhnMRzulD474Ku7c1WgllztmBOPNWvbxqD0FoujirK0n7NiQdk0
         dQEJpHWwX158luWUAtuHRoBgZkPioGOcx5k0reVQbGcD170lhsZacVZIDFSFVBCxyd+B
         JTLaao5ILNwWWtbWhgTWUtc+xxmu1cIoiNZc1UZ7+PEPv8ct9x9zRgTvcwR5qZs9dZDG
         ssaQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795601846; x=1796206646;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=DwvC3/Uc/Q4JTglnun5WSsaA4EcGf3iK2OxV4jCGl18=;
        b=V5Q/eEMw0G7nQaw48QmhZh0ipTc6r0K8o5L0PH/aJGlX2Q9CnUZi79CVnAKcDnRnPC
         mm7MG+0dy55YgLlgD9uigLObsCAZE9iFeuAu6MU4mrBlSIY3evCF5sGSkpP14L8cNpn2
         9SedoDFYh9Rc4/uQlPYifw/fV5XSXPth2yTFfQc1W7PVw6MmJseizFkJXx3+p8ju7TIq
         lAjnX1u60vQWklyt1UDLU7OiYFH29ULCNf5ilqqnCvNCtI2z4R99sdYzFj2bPDLn25bn
         nKRKnYuyjjX25twNF8DmeHxPDZQVav553oENB6eEeSRp4D+RuqIHvmJ2rB9Tpq2xQRQg
         Yd/A==
X-Forwarded-Encrypted: i=1; AL+hErGIcHIm+iu4ByV9cIZzBGt+0NbRHFHAXyqgkmjoq1h7xBlPHToAnu3sX117rOoCRQoo929qz/aBXts=@vger.kernel.org
X-Gm-Message-State: APuU4Z/YLgx+Qw+N9S4l3f93zOoLAwLPRQIRmU646zvlcWDxcmv952kd
	XOWX/Pv09EkUZYCi69awofkeCkrPOSeKb/CTlUMuDKhXQaX7nUHZXs81
X-Gm-Gg: AZFdTZfNhLRJwvqEbAZD/GPLCfUa/bPSk/aAZ+O/FmHvvIARk4Tml2H+eCJKFsaV9DA
	Z315xSPjEVx/7s6o/5XGm56vb1vXAltsYwbauaexf8QTgxSiFgQbE4vTEv8qLhjUKrt3bQm6vR6
	7Qdoff43t1snqOMXAs30EExgN1ulfVFTt8QkZYWTdrOp0xZvBDCpePPpLWMwFKhO5TpsrV8dFHF
	CGamb+e6cBB8BQhGW/neZ2FUOctTU5yd5f3MylQUPRWja476RPT3f84Ow8CXbtfKN1Ck9yB4sX5
	lkq+PBpyMrnN4wapMghySEaOdTqT7uEV6BF58RupRC2E+FM9NUroxsBkFT9K1nnQ1rbiGR3lzV3
	XqTMBzwFCYJ5JCjsW4MKX5QUhrZNlYI3+ERFslLzeK2CS0eYrofmqJnC1QuW/BLicR8wntTsllC
	FYBU0gavDGdci1iM5aWZD/U+uaUVEZjkZ0dsNHsoN7yMmdLSkF6wS2pQNSdCI2XTe9OrZTA87us
	fMebwvuQnArGIf12P9cd4CMbqefLOSyZltH6QYAKYinOoDxBCIa+lwPhPAOFBD9HEUF2D/ReJ7s
	4z7/X0G2AxJK4k+QNNvtXAfUbRYEbC7AD8kZrt/+B7zdVFDUYGRGWipqquQO+Mqle25iq6TBDUT
	nVAD0FuQ4nd+VCwBxw7WtpS0jW5qoXMksMHyR9pWVSo+ZaxNJYRu7FpLkx5Zt5gIgkOhoIA==
X-Received: by 2002:a05:600c:1d09:b0:4bb:6fd3:5ac0 with SMTP id 5b1f17b1804b1-4bb88816c7emr380804395e9.28.1795601846161;
        Wed, 25 Nov 2026 02:17:26 -0800 (PST)
Received: from DESKTOP-0KSTGNI.localdomain ([197.52.150.30])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4ab69bf630esm33897093f8f.16.2026.11.25.02.17.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 25 Nov 2026 02:17:25 -0800 (PST)
From: Temitope obabi <obabitemitope765@gmail.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: jlayton@kernel.org,
	linux-nfs@vger.kernel.org,
	rostedt@goodmis.org,
	obabitemitope765@gmail.com
Subject: [PATCH] NFSv4: Remove unused nfs4_rename tracepoint
Date: Wed, 25 Nov 2026 12:16:00 +0200
Message-ID: <20261125101601.2946-1-obabitemitope765@gmail.com>
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

The nfs4_rename tracepoint has had no callers since commit 33912be816d9
("nfs: remove synchronous rename code") removed the last call to
trace_nfs4_rename(). The event definition was left behind.

Remove this unused tracepoint.

Fixes: 33912be816d9 ("nfs: remove synchronous rename code")
Signed-off-by: Temitope obabi <obabitemitope765@gmail.com>
---
 fs/nfs/nfs4trace.h | 43 -------------------------------------------
 1 file changed, 43 deletions(-)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index b5c89eeef2bc..22365115b3d6 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1199,49 +1199,6 @@ TRACE_EVENT(nfs4_lookupp,
 		)
 );
 
-TRACE_EVENT(nfs4_rename,
-		TP_PROTO(
-			const struct inode *olddir,
-			const struct qstr *oldname,
-			const struct inode *newdir,
-			const struct qstr *newname,
-			int error
-		),
-
-		TP_ARGS(olddir, oldname, newdir, newname, error),
-
-		TP_STRUCT__entry(
-			__field(dev_t, dev)
-			__field(unsigned long, error)
-			__field(u64, olddir)
-			__string(oldname, oldname->name)
-			__field(u64, newdir)
-			__string(newname, newname->name)
-		),
-
-		TP_fast_assign(
-			__entry->dev = olddir->i_sb->s_dev;
-			__entry->olddir = olddir->i_ino;
-			__entry->newdir = newdir->i_ino;
-			__entry->error = error < 0 ? -error : 0;
-			__assign_str(oldname);
-			__assign_str(newname);
-		),
-
-		TP_printk(
-			"error=%ld (%s) oldname=%02x:%02x:%llu/%s "
-			"newname=%02x:%02x:%llu/%s",
-			-__entry->error,
-			show_nfs4_status(__entry->error),
-			MAJOR(__entry->dev), MINOR(__entry->dev),
-			(unsigned long long)__entry->olddir,
-			__get_str(oldname),
-			MAJOR(__entry->dev), MINOR(__entry->dev),
-			(unsigned long long)__entry->newdir,
-			__get_str(newname)
-		)
-);
-
 DECLARE_EVENT_CLASS(nfs4_inode_event,
 		TP_PROTO(
 			const struct inode *inode,
-- 
2.53.0

