Received: from m16.mail.163.com (m16.mail.163.com [117.135.210.5])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 24A343446CB
	for <linux-nfs@vger.kernel.org>; Tue,  4 Aug 2026 12:18:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=117.135.210.5
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785845906; cv=none; b=mY4rhPjhfaMQ/dMzKE6haxX8/FugM2+38fARV6JMyYu7MyXsluLdcB7r4eQsLbzfKDWLeZedBUkodbIWwuP2XhU6PF1KKSHGn16asAw1BOZJqRbPOGH2oFeviyXDHPw3B+w4xEA/dn+QK99OViwhMEUjpZR+WqOaDvCUyx+LLxA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785845906; c=relaxed/simple;
	bh=agyW9CRJt8WFdZB7Pnm14cs8j+cZfih7PwDtZ0as8X4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=cfgRV5QXLL037IIUxjWoweM0AggXhinWjsVfwTSKJXR0pp51+oKmE2vmdUNex2OZXkZeUKehlpD2BIibcbSY6dj0BG7zUyIhQxf084k1NALAW+OiACIVOZWuhOE8M7F8XpCLF3NxQVVhJ0D0dbQ2sD/Y0mscPHVGzTx/NxTBf3o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=163.com; spf=pass smtp.mailfrom=163.com; dkim=pass (1024-bit key) header.d=163.com header.i=@163.com header.b=IwHIAFjc; arc=none smtp.client-ip=117.135.210.5
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=163.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=163.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=163.com header.i=@163.com header.b="IwHIAFjc"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
	s=s110527; h=From:To:Subject:Date:Message-ID:MIME-Version; bh=Mc
	WthLIJXlMotVqjMaT9jwjfao5WVLFYIAdhr5m9b7k=; b=IwHIAFjcbVr0hLHAgV
	PdqNZYCrxGkwRZdZmUxOi21d9bIkvB2Pt0b9ZPFUeXqm2GyUM2Rkmy1cf3TENb6G
	ehdx5Ko4Jq2GGeW/3Nglt4nrEQf31qmvbKnrp/m3S3heUx/QU1hQNk6YO/2ltJdR
	h06nfvGLvR7bsa9OO7OVIPCrA=
Received: from localhost.localdomain (unknown [])
	by gzsmtp5 (Coremail) with SMTP id QCgvCgCHGCCF2HFq08RuKg--.59880S2;
	Tue, 04 Aug 2026 20:18:13 +0800 (CST)
From: xuchenchen <xu18736995897@163.com>
To: linux-nfs@vger.kernel.org
Cc: xuchenchen <xuchenchen@kylinos.cn>
Subject: [PATCH v2] conffile: clear invalid section on unmatched quote
Date: Tue,  4 Aug 2026 20:18:13 +0800
Message-ID: <20260804121813.4197-1-xu18736995897@163.com>
X-Mailer: git-send-email 2.47.3
In-Reply-To: <20260804121401.4074-1-xu18736995897@163.com>
References: <20260804121401.4074-1-xu18736995897@163.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:QCgvCgCHGCCF2HFq08RuKg--.59880S2
X-Coremail-Antispam: 1Uf129KBjvdXoW7Gw18Ar48ZFWkKr1rXrWkZwb_yoWDZwc_KF
	93X3W8Z3yUJr1rt34Sqw18ZrnxCw1UGry5Gwn3tr1qvryFyw4DG390y393tw1kWrsIvFy3
	GrZ8uF1jkrW3ujkaLaAFLSUrUUUUjb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
	9fnUUvcSsGvfC2KfnxnUUI43ZEXa7IUbUGYtUUUUU==
X-CM-SenderInfo: t0xrmlytwzmkqyzxqiywtou0bp/xtbC9gVOLGpx2IV4vQAA3S

From: xuchenchen <xuchenchen@kylinos.cn>

When a section header contains an opening quote without a matching
closing quote, conf_parse_line() leaves the newly allocated section
name active. As a result, assignments following the malformed header
can be added to that invalid section even though the diagnostic says
they will be ignored until the next section.

Free and clear the section name before returning so subsequent
assignments are ignored as intended.

Signed-off-by: xuchenchen <xuchenchen@kylinos.cn>
---
 support/nfs/conffile.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index 8d242c2f..08d45f00 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -364,6 +364,8 @@ conf_parse_line(int trans, char *line, const char *filename, int lineno, char **
 			xlog_warn("config error at %s:%d: "
 				  "non-matched '\"', ignoring until next section",
 				filename, lineno);
+			free(*section);
+			*section = NULL;
 			return;
 		}
 		*ptr = '\0';
-- 
2.47.3

