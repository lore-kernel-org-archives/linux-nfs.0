Received: from mail-qv1-f43.google.com (mail-qv1-f43.google.com [209.85.219.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7C21C35B137
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 17:28:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784309306; cv=none; b=tjSuKuT5jd/zv5Q+L6DIqOl1M7V3pDYja0cqVAKtw0zow82EoY/fd/+aCMD4O/GzZvzvHIDl5E7+TTlLr//EhLjNZOcLxSw/bGvZPgSZsQBlvQ1wLBbFP32x/nMBiNoq9kzM4rWHv3Qe0V1cgaFY41y9O07S0xodD1TTxzCu1yw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784309306; c=relaxed/simple;
	bh=h9fj7i8AH506HFL/gfEtWIscVlLumPioFQmf4b+vdGc=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=ez6lKCvPfU+1+QkhErJfDUFpP/myLDOzoA9nAfrRGtoKIhHmrDFMJ018bFszoWwpLEAbIZT4M4LrdDBBAxek4+v4X/x37R1PaUZii7Nb6qyr5PB6ka7m/KUAwrUSzS9OKx8rR/yFgmeY5ztJv6SZAQdcXDNvZNVKVRs7TY3Xsw4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=r7xZOLG7; arc=none smtp.client-ip=209.85.219.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="r7xZOLG7"
Received: by mail-qv1-f43.google.com with SMTP id 6a1803df08f44-8eeb4508f29so82606156d6.0
        for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 10:28:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1784309304; x=1784914104; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=Kk0zvlROK4CGetKUdREFFy369z04aN1QAFj/lbaZkpI=;
        b=r7xZOLG7koitruLOmY7/1AI9nwVRrdJ5fpwl7pRjH4Z8906vcbtspZMhtLZ3mzhk9z
         82Z72OsdIBhXY0LKi46Pb8auAf4hjJT00fJ4s4IDcuzkZb8hm7fbYMC439aicxHmRJ84
         7VUiiAxxb5cCpzdypxvXZAiiZyzRNsbSLt6QmenNGGLon2Ij0NKCEGeBNg87xuApo88O
         egED9neqALBv9DD2yotR/Q81+DnYfidH2M990Ien9ijn15uARI+xco6F8dOryAOfItYH
         EOmvk/u25EJxnhvqSW3b+PnSAfQdFCtADwEES75UndyyzQ9cz1MB7aabOeEvhEXc6jJO
         auBQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784309304; x=1784914104;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Kk0zvlROK4CGetKUdREFFy369z04aN1QAFj/lbaZkpI=;
        b=RqBRZqLpgq2J8ITus1qa6zH1gwme7U+E6UjsXn9I8LSfKo+f2D/QRxoNNhm2U+y6cx
         fDwdRjr3VhLbG+zbUcimtEpAVbotQZlJZxZh/MfAuAD/cniw7l4M24tYp61gBkDVYfZj
         k6AfvLzB6IEkA92hJm2pfXRXlMhiFKoy6SnO6IlwFIAOudJYoYIta1uR0qJiODLyriFQ
         ZnuQFwX8xOdjjtI03ozntrEfEa9Q4W3+HF8r22FG2jvZutewlz1nCJ84j+SdM3kX2zzY
         0F6mXyL05IyclU6/Wl+dXSsq1FeeZbMwAHO7H+2K2gneQqEliRYR+ln5nZ+BaeTcMzne
         S67g==
X-Gm-Message-State: AOJu0YwcH5mQzZLCdazgySEkguIeoMX5krWQJKltcBvibvNFYtlt6HwM
	1Grsaxkfx9v39s6+CkHpdCjjaVnrx9kPRlMNKysJZiwr91YJg/tRUoDvUIPwyNdL
X-Gm-Gg: AfdE7ck+FCbTugsKRuwj/Z3TSHMd2w3mS2hobFnNDedJ2Sn6pB2Q3B2gcmvQqjPzWtW
	J93xcfwrO0fs9UvNsogzUY7m8ABEeAkgWAKZ29eC5WKV+oMS+gVg82eqB1wBPyge83kgiX+oo6p
	ru9S+2i8sfXCpl8+xhu/JH6xPCVJKmLZugcRkimWI4vghTjQAJs7hwG6h/vZtLNepvplG+qN1cW
	PLzBJS0rZqV3DRbEYfRjSelHZK/moza6OPSEMpENtiH+MLdGjJpXKD/GnFvrX0r5GI8y1ZatW5H
	L1OHF6GlbPHBgpt6VZPMD8b2YiyFeLSdo4SV3RxBssJx8jI7AejC357awjWk+dENAf4FBQLHgwf
	jLuh2oNcrjJD9W7zMFfWXwlO5J9B4v73d1TPDVY9KPyBizKizVbsJsOExvXXyBnxJLCfk+ivP+Q
	JvJDKqwPKAc62K7axNLkXb/gu4+AyWPP4VYmB7cOsM9g==
X-Received: by 2002:a05:6214:212f:b0:8f3:ba0f:e7de with SMTP id 6a1803df08f44-907783541a3mr39136046d6.11.1784309304275;
        Fri, 17 Jul 2026 10:28:24 -0700 (PDT)
Received: from i4-l-hqh5357-03.ad.psu.edu ([130.203.139.71])
        by smtp.gmail.com with ESMTPSA id 6a1803df08f44-907786f9de0sm21502666d6.40.2026.07.17.10.28.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 17 Jul 2026 10:28:24 -0700 (PDT)
From: Shuangpeng Bai <shuangpeng.kernel@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	trondmy@kernel.org,
	anna@kernel.org,
	Shuangpeng Bai <shuangpeng.kernel@gmail.com>
Subject: [PATCH] lockd: fix NULL dereference on lockowner allocation failure
Date: Fri, 17 Jul 2026 13:28:09 -0400
Message-ID: <20260717172809.1591290-1-shuangpeng.kernel@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nlmclnt_locks_init_private() installs NLM file lock operations even when
nlmclnt_find_lockowner() fails to allocate a lockowner. nlmclnt_proc()
then returns -ENOMEM, but the VFS still tears down the partially
initialized file_lock and calls locks_release_private().

That invokes nlmclnt_locks_release_private(), which dereferences
fl->fl_u.nfs_fl.owner and crashes because the owner was never installed.

Clear fl_ops before attempting to initialize the NLM private state, and
install the NLM lock operations only after a lockowner has been allocated
successfully.

Fixes: 1da177e4c3f4 ("Linux-2.6.12-rc2")
Cc: stable@vger.kernel.org
Signed-off-by: Shuangpeng Bai <shuangpeng.kernel@gmail.com>
---
 fs/lockd/clntproc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
index f06faf577cea..f8018bfe9c64 100644
--- a/fs/lockd/clntproc.c
+++ b/fs/lockd/clntproc.c
@@ -487,9 +487,12 @@ static const struct file_lock_operations nlmclnt_lock_ops = {
 static void nlmclnt_locks_init_private(struct file_lock *fl, struct nlm_host *host)
 {
 	fl->fl_u.nfs_fl.state = 0;
+	fl->fl_ops = NULL;
 	fl->fl_u.nfs_fl.owner = nlmclnt_find_lockowner(host,
 						       fl->c.flc_owner);
 	INIT_LIST_HEAD(&fl->fl_u.nfs_fl.list);
+	if (!fl->fl_u.nfs_fl.owner)
+		return;
 	fl->fl_ops = &nlmclnt_lock_ops;
 }
 

base-commit: fce2dfa773ced15f27dd27cd0b482a7473cdcf2a
-- 
2.43.0

