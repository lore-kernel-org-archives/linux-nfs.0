Received: from smtpcmd02102.aruba.it (smtpcmd02102.aruba.it [62.149.158.102])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 285B53CAE97
	for <linux-nfs@vger.kernel.org>; Tue,  7 Apr 2026 15:44:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=62.149.158.102
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775576675; cv=none; b=GqGzRqlOplidwKAAtC1R4SA9ht0Zbu6jtRML3/bCKx+S6y2He8XXChtodyzkqhhsXT8aWFYLqpcetvScVzG1AGhK/wma7jcz3ZnowuovShfQTv5m+W6Xu9xuquDJTVeEs6qAKX5KW6nrkGjEfD8j/TaZPulsPNbIfOlUfyqfPzY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775576675; c=relaxed/simple;
	bh=FvS1cipI4zjiETBk3hHlt7oRUaYxk+gTOM4AVOCQVD4=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=lWAdwtQTMLNeQ+gESEebfJIGS9kKmIMb9GacIQ//47DmbiwUPYoK4tL0memf0rG+KfDOn8O6RR9m6LziekPYnM6Wo5XEQZZyxeO7sAVy+17opu7O5AAFJBzHu7uZNztndRSvLwAhsFI3Rs5LpsApn+SdgP1JCBQ6QcYBQc6V5jM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=benettiengineering.com; spf=pass smtp.mailfrom=benettiengineering.com; dkim=pass (2048-bit key) header.d=aruba.it header.i=@aruba.it header.b=OBBqR/Mx; arc=none smtp.client-ip=62.149.158.102
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=benettiengineering.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=benettiengineering.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=aruba.it header.i=@aruba.it header.b="OBBqR/Mx"
Received: from localhost.localdomain ([84.33.84.190])
	by Aruba SMTP with ESMTPSA
	id A8YEwTugoxFXLA8YEwnsDU; Tue, 07 Apr 2026 17:41:15 +0200
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=aruba.it; s=a1;
	t=1775576475; bh=FvS1cipI4zjiETBk3hHlt7oRUaYxk+gTOM4AVOCQVD4=;
	h=From:To:Subject:Date:MIME-Version;
	b=OBBqR/Mx9qoSIuLdgdrJiSknnc6q2U9Jr/61sjejWc/6NIXnjKjUZEzGtwJo/mbF4
	 +9Zq/rneJMjaLjMGUHWR/xmUEHc4IjgOUojRPP1jSciJa9E5OUOAZz0SemvQazd64L
	 hw9O5kCT8Tx+Pzt2x3AkpBNF7YfcYZR0CSWMULIljU/XkF5zE0YfXDW0pleFwGd7nu
	 YotNxPfaPYZ2HSPs+Vbn+L1Ygh1D4ac8R4x2O0jFhZ2XWUotlqGHIbK1icfnPWM6ci
	 v1yxkACumEOHHUKIwTpayYeDYiNRdy2m0m4yBbCYsLCEYnL+HM+xtg/aMt3Q61m74b
	 lPsqemApgx4BQ==
From: Giulio Benetti <giulio.benetti@benettiengineering.com>
To: linux-nfs@vger.kernel.org
Cc: Giulio Benetti <giulio.benetti@benettiengineering.com>
Subject: [PATCH] fh_key_file: fix missing string.h inclusion
Date: Tue,  7 Apr 2026 17:41:13 +0200
Message-ID: <20260407154113.1152555-1-giulio.benetti@benettiengineering.com>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CMAE-Envelope: MS4xfBnob+F//YTkA9GASeIo5RjdeiwmK3l0K1PUqkH16fE/qtzurG5BpR4oOMfkoOi2fosrYCZlxExSa+T81/XVge/dFCbmqH57ilugr7q+EJFRKcyZ8NAC
 jMhoa7DadCmIq3zvK3lu0amhlMRIIjupGruKwPn0UB7frUjGaK8A/vkdp8RaHTmAFP2pnnIrCgICL6lAfvFTp9NHyvfuW2fQVlaaHMxHdf6Ulc28HqgIA5x1
 Pi+Cae0zV//hv8eEptLMpOp1VfX75yi+W91gtGFw3ifJ8+o+84eLBTIVNIAT5Vol

Add #include <string.h> to fix build failure.

Signed-off-by: Giulio Benetti <giulio.benetti@benettiengineering.com>
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

