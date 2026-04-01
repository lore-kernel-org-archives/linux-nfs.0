Received: from mail-dy1-f176.google.com (mail-dy1-f176.google.com [74.125.82.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B76301A9F82
	for <linux-nfs@vger.kernel.org>; Wed,  1 Apr 2026 06:09:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.82.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775023788; cv=none; b=f1YLRMmEVrweJNFkdd/wlyefZ8gEXziBOsBwPNp2aSgf+Jo5PgyIEfYStRKUcVqZQLB2Yh39MvnijteTk9p2rOiGEQHPgCkydzYs4ka3hRGRJFjGcI13P+S3wo/5AWSXzVk6vzSU5hBWn+DjPyR5tZIfkf8SlDkEY84TUc8s5BM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775023788; c=relaxed/simple;
	bh=xC7ZXbKHLNyW9hlfqb4OCB0vMyv4Wl/Y9itCSoJwA8s=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=fC0nR7LccvyUT0L7BumAsI/e7gOv4YkxEIBGAdBcTeprL60YeVFBe2YtaJMg4J124aEZ+ulq5CcUFeisAE+WloVvSdKrSPPUWs2yq9Aw9N7wu/V3wiQp4vWdM7xK0wmnfoNI8PWsQXUr2fk3Bk47dQ1AdNy4OFIkJoOh46t9qFA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=LqsU58kh; arc=none smtp.client-ip=74.125.82.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="LqsU58kh"
Received: by mail-dy1-f176.google.com with SMTP id 5a478bee46e88-2c156c4a9efso6297184eec.1
        for <linux-nfs@vger.kernel.org>; Tue, 31 Mar 2026 23:09:47 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1775023787; x=1775628587; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to;
        bh=HaxOYM5NSgipeJBxMot0WA1Pel+2rzlhUWFMzERDxxY=;
        b=LqsU58kh0tJ/0j70sW0HyPv7sJZVPJ+uoTtrDnOdI0JaqKdimhoSZ/bLZKRxjGpDig
         SKysKHbxUMfiQK7A3F0Mz7gu4G2SVK8xx4yTOpvS0DPYY+8bPSHJFGXX5fLZqPga0SPT
         0qQmNGzfbT0uptTTCUmkEmr3Pb02EWU7F2ud8qqtU/kU+ScI7bpR9hYo7VzTPEU+wKtN
         GNQI/WsZs9ql+BQDng7cQC8EknoRgiKf92P1svoTM/mPRgk8u6YZ9CHQ+6p1rkdNyYRT
         pxNYtrx+k3FEtI3l8mytbh4RCdF/0QkeTDx44bIOP+zApy3U5sV9ES9zZRybhcGmMdN5
         f3wA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1775023787; x=1775628587;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to;
        bh=HaxOYM5NSgipeJBxMot0WA1Pel+2rzlhUWFMzERDxxY=;
        b=O2cQePbkSPePUHVcnsmSWl7/+jg8/g1vWp81TIFJrAFBLYKjrIDHAJG1u8PDJVcEor
         ljMIA4RUIWMuB44J3WhI0LGgudu4xOVxpHlrH13eMalyfN7D4UAT3T7UyICtbl0/E+an
         b4WSR5e6jysV8CMUBD5bOyPkHyfU0qWMj+v8wPQkucxdxbFd5ZL/yllFO4tWhCWH2vTY
         RGVlCj2N7B6UWM+V7IwZOLWbmlqdOWBYWhFgDfndXi+vLG6V4fv2XJLDPEdu2AMUQWO5
         SVugVMhCx56YJM4HR16J+S69WxGM8cFBOC8vo2/PA3wfcJiTswKgTZ8/zs7GK8grF3Jc
         By1g==
X-Gm-Message-State: AOJu0Yw39+B6X3ERxZ5ekySVwJEOufbZDrqa275xwjc+ITb00dXSl72n
	BiyqsxKrCZC/G54tcOleD9oaIj5FP+qWqnpxL7hlC/moZNuYiIZ0x9hz
X-Gm-Gg: ATEYQzwdfQDta0Eqxd1ASZmwyP+p71tUDYXuD4rdcwXe+fdEdVkxWf6SoQsi1HmHrmL
	5RAuQeRm8Emeo7Bd+YxPWE2DbBq3OsNrRr+ve5eACux7iOlTBum9YFHZfnBBdgzKq/zRkCY1oBy
	C0bslmsXrwu5Y8DxSvWfyLJ4xeywN3l568TCiu1qx3S1w3rNyyeHh9KRg8rkPaSQfGZXUbdKUY+
	H/N10bM37SbFXAcUAgpSI3qnLgQ/6DYYqgWSYYhyE1IrZzL+9XlSoYW/JuysZgjHP2q5NtTVROq
	BxR1ds//VrHiVawbrO2I/7RFGszFVKARbROayddJKNvUDOTyt2PiF3PnALp8U9xyjNh2ZUlYswB
	y1mWaqvTgthhifvL0WLC9jAFoIFGvKpcgIJaY/317QGjvXaFTL4DbZCuHQh7VEDVL+5pgjtGU4a
	PqZ+qSQTXVtyPNuzbolBJ4KycCuJO04MY4QYAM3FSELw0VLmtA37KvamM/DuUpjIEkSx75uJNGZ
	gD/VIVq5nJY3daAWdSUjynhbZnHazJ2zKZ0YWt02zj9uL9JmsHNjZBOhs/S
X-Received: by 2002:a05:7300:dc8c:b0:2ba:a60a:15e6 with SMTP id 5a478bee46e88-2c9328ac3a9mr1097791eec.16.1775023786576;
        Tue, 31 Mar 2026 23:09:46 -0700 (PDT)
Received: from apollo.localdomain ([208.95.233.74])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-2c3c41c1513sm12386074eec.8.2026.03.31.23.09.45
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 31 Mar 2026 23:09:46 -0700 (PDT)
From: Khem Raj <raj.khem@gmail.com>
X-Google-Original-From: Khem Raj <khem.raj@oss.qualcomm.com>
To: libtirpc-devel@lists.sourceforge.net
Cc: linux-nfs@vger.kernel.org,
	Khem Raj <khem.raj@oss.qualcomm.com>
Subject: [PATCH] libtirpc: fix bindresvport build with clang-22/C23
Date: Tue, 31 Mar 2026 23:09:43 -0700
Message-ID: <20260401060943.2578248-1-khem.raj@oss.qualcomm.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

bindresvport() is defined using old K&R-style syntax, which breaks when
building libtirpc with clang-22 in gnu23 mode.

Convert it to a prototype-style definition. This is a no-op change
intended only to restore compatibility with modern C compilers.

Signed-off-by: Khem Raj <khem.raj@oss.qualcomm.com>
---
 src/bindresvport.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/src/bindresvport.c b/src/bindresvport.c
index 7b2056d..eea6589 100644
--- a/src/bindresvport.c
+++ b/src/bindresvport.c
@@ -57,9 +57,7 @@ extern pthread_mutex_t port_lock;
  * Bind a socket to a privileged IP port
  */
 int
-bindresvport(sd, sin)
-        int sd;
-        struct sockaddr_in *sin;
+bindresvport(int sd, struct sockaddr_in *sin)
 {
         return bindresvport_sa(sd, (struct sockaddr *)sin);
 }
