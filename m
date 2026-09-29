Received: from mail-wm2-f13.google.com (mail-wm2-f13.google.com [74.125.225.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1FBE223323
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 01:23:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.225.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790644985; cv=none; b=t6GVkKudIhH44vM54Q4Nfxb/jhfxysUwJ2uQ237WZKLV8SJAg8G1YBCTYZmb7BmLCqiyyerwv21svzHKRJ3fAFzzRZPVecQGyr71HU0PqSOSkWJMr9SeohalJGD3SXTThSN0GmKtJDYEc8E91y9wCQcynujGysgVH5yWd3l6MBQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790644985; c=relaxed/simple;
	bh=UrDecZI12+94q4z34LUJhWfm968wKF+DBtkoIPnqZsI=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=WvkIXrTKpX4zb6vtVjbo8KBmi+a4DUNpyK1wsSz6bIzgpRO4E/Da0IYBn/QCPfi/pvBdJSs0GB7PGogsk9IzCYak+iDcxV5hGOToSqwy0SFFytE614IIb69/5NUfe2TEz24adSaRkEHm2Axd6hLNLz6t89Sy5iiWPAogksYmri8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Sw90O9Q/; arc=none smtp.client-ip=74.125.225.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Sw90O9Q/"
Received: by mail-wm2-f13.google.com with SMTP id 5b1f17b1804b1-49b912d822dso27063445e9.2
        for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 18:23:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790644981; x=1791249781; darn=vger.kernel.org;
        h=content-disposition:content-type:mime-version:message-id:subject:cc
         :to:from:date:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=wqaGFKtzgq9wLRTl9BsQw2GDSHwlR9sUAXZct/I3hlY=;
        b=Sw90O9Q/AQgJmvR4VEsEifeVYgpZ48hFyZUIrC8+jlrGLHUbd+Bs3+7/oUh4Mphcp2
         gTfHmPeyYTaRnnXaXdw/Mt1lRW8F6G9YMVUIRADe7PJavi0mNIb7cUu96qqX/RQtRWnU
         NRnZHzW1UoDRnQcP4/uPMqBcvIRW9bwXtHTIcomH2xUyFk74Tp1X4CHS10BybCiIVOwo
         7bGU8lK/erJ+h/KDC6YCv7WxFh25PtG+N6Gxo0Wn2LkbukSfdeWkc5fbJzAjfb805GME
         YRvdR0sdFcziKPZujxVGIHVJ2oRUZ23VdREoVAc3ty4nYAqe6aYEGz1rrJLoyBSzjeJ3
         aOVg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790644981; x=1791249781;
        h=content-disposition:content-type:mime-version:message-id:subject:cc
         :to:from:date:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=wqaGFKtzgq9wLRTl9BsQw2GDSHwlR9sUAXZct/I3hlY=;
        b=SlAxf7LYF+HwWF7hdZSrM30dXUAz5FvHi6UBp9EH758psf+ql5UhYZCTnIWvFJTbss
         6h96zfTIGzuR11mhJ58d+d3sBu7f8ZzhHVZFFRvqyCdz5JC4G3K8tjJDKptPF4l9bgP/
         joGy0UueYdwKB/mN3gbC3hp0MKlYTbEOnvzpwgFTJTjd+wYD2h1ZFyXd8pjwQBN2Fb5x
         0IOYQ3e7OWmAkb3zka58qVlppj/fmBOoIPUKm5nymXZz5K138veq8w90slskRur1FmZ5
         X1e39Kas2fJOxV8t7CkfYe2qddEkp8TKWqHTbsCrcfjASvB6/0cJCciolE+QkXT/b/kt
         Zr2g==
X-Gm-Message-State: AFuF++lQPC0D56IDWsDzXqfs6xlPkBtUfZrbyOEEXte4NUFdgje/L2mv
	JP2vFR2EAlyP8U2QXMFNwUx/K/pc6PuY2kThbbIO/u7xboOdVuqtXm73swRiHQ==
X-Gm-Gg: AYBFou129h06K84UHdqlDyQvpVE6NFfEL+/MIImHwNZtJL4E/dGwrNXreRSXT41rr9q
	KFz75px+rugIKJ8pqKTuPVNuJSsJbiwPS3CD1X35VSYytJjhNl6rIPJ4ca4dZnmFZ1X8gDMmmIV
	2bGzbGtxm8UxJ82jQOuVbtnp9183RabU6jiQEbYjUY9lM6g715DX7lfmvSleh8WhBPIrxzP7SeI
	NJ4fdmyQ92iG32kMCleFWGEQX3v16icnuim1HVhwowEKLipAcdLVhxchlPkiOLB7Prpqs1meGA7
	kq5PRwK+2m3r3FKdN7XZur6lcXt+dqniP1zlZO+srdb7zyHlRNXLYbRYVOnli+zMMpkoasKZ879
	uOlQVAyoEtdxDkX+muFb+8DlWyzCPLzRwJ+f+2eQhV9zYFSwjqV3yhEOD2a1/AqRr/57Ujy9WJr
	O2dzra1sVbfkhsCf2qmZdJBwYSj05ojRApr7CvRrUAN4ESbw1oZ9ObWDJYSM6VLVvDdKeNkMfiM
	QhXs8FmKXrbvXoADW/avjO2QIS+hnHSkFAxvJQxlnLD0CiTg5uy
X-Received: by 2002:a05:600c:3b02:b0:4a0:c4:a1e0 with SMTP id 5b1f17b1804b1-4a000c4a238mr95771755e9.9.1790644980978;
        Mon, 28 Sep 2026 18:23:00 -0700 (PDT)
Received: from localhost ([192.41.125.249])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4887a2acb4dsm30962699f8f.0.2026.09.28.18.22.59
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 28 Sep 2026 18:23:00 -0700 (PDT)
Date: Tue, 29 Sep 2026 02:22:58 +0100
From: Karim Manaouil <kmanaouil.dev@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com
Subject: [PATCH] nfsiostat: display READ_PLUS statistics when available
Message-ID: <20260929012258.7objh6we7hdzqlzv@wrangler>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

NFSv4.2 mounts may report READ_PLUS operations separately from READ
in /proc/self/mountstats. nfsiostat parses these counters but does
not display them, leaving read activity out of its reports.

Display READ_PLUS in the default and page cache reports when the
operation is present. Document the conditional output.

Signed-off-by: Karim Manaouil <karim.manaouil@ed.ac.uk>
---
 tools/nfs-iostat/nfs-iostat.py | 4 ++++
 tools/nfs-iostat/nfsiostat.man | 5 ++++-
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/tools/nfs-iostat/nfs-iostat.py b/tools/nfs-iostat/nfs-iostat.py
index af04aac5..2a681bbe 100755
--- a/tools/nfs-iostat/nfs-iostat.py
+++ b/tools/nfs-iostat/nfs-iostat.py
@@ -436,6 +436,8 @@ class DeviceData:
 
         if which == 0:
             self.__print_rpc_op_stats('READ', sample_time, use_mb)
+            if 'READ_PLUS' in self.__rpc_data:
+                self.__print_rpc_op_stats('READ_PLUS', sample_time, use_mb)
             self.__print_rpc_op_stats('WRITE', sample_time, use_mb)
         elif which == 1:
             self.__print_rpc_op_stats('GETATTR', sample_time, use_mb)
@@ -449,6 +451,8 @@ class DeviceData:
             self.__print_dir_cache_stats(sample_time)
         elif which == 3:
             self.__print_rpc_op_stats('READ', sample_time, use_mb)
+            if 'READ_PLUS' in self.__rpc_data:
+                self.__print_rpc_op_stats('READ_PLUS', sample_time, use_mb)
             self.__print_rpc_op_stats('WRITE', sample_time, use_mb)
             self.__print_page_stats(sample_time)
 
diff --git a/tools/nfs-iostat/nfsiostat.man b/tools/nfs-iostat/nfsiostat.man
index 4f24318d..b06e65aa 100644
--- a/tools/nfs-iostat/nfsiostat.man
+++ b/tools/nfs-iostat/nfsiostat.man
@@ -10,6 +10,8 @@ nfsiostat \- Emulate iostat for NFS mount points using /proc/self/mountstats
 The
 .B nfsiostat
 command displays NFS client per-mount statistics. 
+The default report displays READ and WRITE statistics.  It also displays
+READ_PLUS when it is present in /proc/self/mountstats.
 .TP 
 <interval>
 specifies the amount of time in seconds between each report.
@@ -126,7 +128,8 @@ only print stats for first LIST mount points
 display throughput in megabytes per second
 .TP
 .B \-p " or " \-\-page
-displays statistics related to the page cache
+displays statistics related to the page cache, including READ_PLUS
+when it is present in /proc/self/mountstats
 .TP
 .B \-s " or " \-\-sort
 Sort NFS mount points by ops/second
-- 
2.47.3


-- 
~karim
