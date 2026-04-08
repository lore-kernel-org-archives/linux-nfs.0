Received: from smtpcmd0756.aruba.it (smtpcmd0756.aruba.it [62.149.156.56])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ECA612F39C2
	for <linux-nfs@vger.kernel.org>; Wed,  8 Apr 2026 17:38:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=62.149.156.56
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775669927; cv=none; b=ewcCmzo8u1miVX1OSb+1fBO6nFq9pT4kGIJ+nqV23oO0+I6JDgChwi0hjDUlctqWSiRRgHpOKW+6McmfbnyexNLE5cIN89nQguR5Uv75/GQxQU/oiAof2Rp5Nup85iCmdX/s1DSwC/a42yTzcR+qIx2QY/tM2cmCOSikAJWvloA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775669927; c=relaxed/simple;
	bh=g8wPaQIcVwtjW4TYlAhTcs8e09OK0Z4nLRpm4+WreBw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=HMc594577maT1h37Ihiczrhek4jTFcKVPmLFddfkIcFpa70rJejUXupQhaXea+8A4V2xpUfGQJWgHwYH0XnKMAIzUOhJKfEpojB5tZyFI+QIiVrkIgJL74GYalS4ljjQGFbtE9BUbfswPZGnOA6t9vXdL7IAVsQKcytiNaHbauc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=benettiengineering.com; spf=pass smtp.mailfrom=benettiengineering.com; dkim=pass (2048-bit key) header.d=aruba.it header.i=@aruba.it header.b=hb8GxVsC; arc=none smtp.client-ip=62.149.156.56
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=benettiengineering.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=benettiengineering.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=aruba.it header.i=@aruba.it header.b="hb8GxVsC"
Received: from localhost.localdomain ([84.33.84.190])
	by Aruba SMTP with ESMTPSA
	id AWoRwcrFktpTfAWoSwriP9; Wed, 08 Apr 2026 19:35:36 +0200
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=aruba.it; s=a1;
	t=1775669736; bh=g8wPaQIcVwtjW4TYlAhTcs8e09OK0Z4nLRpm4+WreBw=;
	h=From:To:Subject:Date:MIME-Version;
	b=hb8GxVsCaS3mWxd4APMtBWCfLbEUY/s2kftimqAvWwSinEzT4uW18Sj2Uz8O8MWAs
	 uLzFqMRbQVJnTJ2680Qh87KOMuefXUI2k/uQiyIuW4g+d1/gdsyyWnf76yhyDUbgeI
	 UfhHroJYWLvXEsnpnSc8QFHWJXC1HGkQsNGfD2adkVqQhjGRs5if+w4fcLUYs8Tgi8
	 1oiAbHLEM/hNlXkSmnsIe++7sMgTzL/T/MayBja3atWYtWag3R4HLkoU6Wbegcie2f
	 kWxG4DcXLZ5lGFsQBmYGEmOreTyeCRK8SIrQb3EK1Dfg1FbHio2bvfm/nBunTFQC+j
	 xv5bs8XqWhnLg==
From: Giulio Benetti <giulio.benetti@benettiengineering.com>
To: linux-nfs@vger.kernel.org
Cc: Giulio Benetti <giulio.benetti@benettiengineering.com>
Subject: [PATCH v2 1/3] fh_key_file: fix missing string.h inclusion
Date: Wed,  8 Apr 2026 19:35:33 +0200
Message-ID: <20260408173535.3992116-1-giulio.benetti@benettiengineering.com>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CMAE-Envelope: MS4xfAjrBg0BUJCKmUxMEiH5mL8ZtcXEoGQBwUT7zcvYngf+3AjddKmuTmX92KYDd5zc7tW5vKgoa+Svv8Inx5dhr2cIov/N92tYSM6AiLfysDRpj4/6TQEJ
 wgNDRlrcgb0R9JT2oDJpXuJMkcv9aziBEg3KT2/kWX6Fw7vzN8ReTxUWvD9iUxgItmP5RDUD86L9T2ybsqSPXGfa4XdcK+wwJMYw+dMqxuA+KY6bT8xLsW82
 /cIIeHyOPAz0qFDfyxmTnZyj77xSy9vVLy0ApoZfxkHiAPL+643mys/uVDeXfag/

Add #include <string.h> to fix build failure.

Signed-off-by: Giulio Benetti <giulio.benetti@benettiengineering.com>
---
V1->V2:
* no changes
---
 support/nfs/fh_key_file.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/support/nfs/fh_key_file.c b/support/nfs/fh_key_file.c
index 5f5eafc1..81ea1500 100644
--- a/support/nfs/fh_key_file.c
+++ b/support/nfs/fh_key_file.c
@@ -26,6 +26,7 @@
 #include <sys/types.h>
 #include <unistd.h>
 #include <errno.h>
+#include <string.h>
 #include <uuid/uuid.h>
 
 #include "nfslib.h"
-- 
2.47.3

