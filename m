Received: from m16.mail.163.com (m16.mail.163.com [117.135.210.2])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57CC63C277B
	for <linux-nfs@vger.kernel.org>; Tue,  4 Aug 2026 12:14:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=117.135.210.2
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785845653; cv=none; b=dzPepEVv+CQf/1guJEYiio6XJEatS/qO3hdq7gZbDhmsgwshvHs48canYo3aR35cVY4wH8Ug1WA5DL9BXpbUFe7mlnDeuKUfAwU8zE+MNgBy78DxSAhPW1ZtkULGHlAvsYxBDyx8uRw1YM35yM7Yup8wCtfGH0I7uSe54l9DdUk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785845653; c=relaxed/simple;
	bh=KTdFQQ+hFAPR9wrKc4sOfv71hSUEb0OTMMVMn0G9XCs=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=NjKEzl5xVPZqlEF5Wzy7imbCJFuH0ygysizPxTPgAup16GeaTY9Fh2cgUPcegyQm4DcZmE9S/7unAhMxLs4XEvqzW9NFic/PsAMOKu16JtjhtxKtcCQ0g8DmuTS+o6lXa+lWFtSo5RiCjsheh8FyKYDGxBTUPa/zaxVDDKu6P8o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=163.com; spf=pass smtp.mailfrom=163.com; dkim=pass (1024-bit key) header.d=163.com header.i=@163.com header.b=d2spVXtC; arc=none smtp.client-ip=117.135.210.2
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=163.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=163.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=163.com header.i=@163.com header.b="d2spVXtC"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
	s=s110527; h=From:To:Subject:Date:Message-ID:MIME-Version; bh=TJ
	N3WkwvOA94zhMDGWSUhmomDNX2V0NzixI38zRYit0=; b=d2spVXtC3BUFzxiWRT
	twWQ4UIhiyqxvACM01me5gQttuWQ8WlY/XyZ6pKJirgAZ0YUIsYPv+GHKEALLt55
	NLlpLhRgQDWMOu4SLWXirLx05OZaTm9Z2uXxBpHONdargFz+6dYzxfjVBrnrd6dY
	h7kNl93aV+SPE4Z4TEPsDv9+k=
Received: from localhost.localdomain (unknown [])
	by gzga-smtp-mtada-g1-1 (Coremail) with SMTP id _____wBXd3OJ13Fq7mt_NA--.30113S2;
	Tue, 04 Aug 2026 20:14:02 +0800 (CST)
From: xuchenchen <xu18736995897@163.com>
To: linux-nfs@vger.kernel.org
Cc: xuchenchen <xuchenchen@kylinos.cn>
Subject: [PATCH] conffile: clear invalid section on unmatched quote
Date: Tue,  4 Aug 2026 20:14:01 +0800
Message-ID: <20260804121401.4074-1-xu18736995897@163.com>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:_____wBXd3OJ13Fq7mt_NA--.30113S2
X-Coremail-Antispam: 1Uf129KBjvdXoW7Gw18Ar48ZFWkKr1rXrWkZwb_yoWDZwc_KF
	93X3W8Z3yUJr1rt34Sqw18ZrnxCw1UGry5Gwn3tr1qvryFyw4DG390y393tw1kWrsIvFy3
	GrZ8uF1jkrW3ujkaLaAFLSUrUUUUjb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
	9fnUUvcSsGvfC2KfnxnUUI43ZEXa7IUb1EEUUUUUU==
X-CM-SenderInfo: t0xrmlytwzmkqyzxqiywtou0bp/xtbC9goP7Gpx14phkwAA3r

From: xuchenchen <xuchenchen@kylinos.cn>

When a section header contains an opening quote without a matching closing quote, conf_parse_line() leaves the newly allocated section name active. As a result, assignments following the malformed header can be added to that invalid section even though the diagnostic says they will be ignored until the next section.

Free and clear the section name before returning so subsequent assignments are ignored as intended.

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

