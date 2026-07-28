Received: from m16.mail.163.com (m16.mail.163.com [117.135.210.2])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B136740A947
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2026 08:34:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=117.135.210.2
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785227663; cv=none; b=u+28yiZ+ZOaqs1oxSVf9cm/Iotzk8oK6OhN+p6mCioFOFnB3atLQEHi5IIrMYAjCHH1lZBes4t96DMtWmjKyD2kkvC6k47URKObZIxGjuYZYt6G6p9K6/o5PBUpRq9//mknhqQydW+Jl8dvPuohxAPTkz8+2S1GrZi+tOgyXHrM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785227663; c=relaxed/simple;
	bh=mP697S+R6LaRq1V40Gt8McfhypQllxaxUX3OUXwnCAQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Q94ir3MEXDPHjc6GcqaCCpKFYAZUV+8zJcAXEZ0eVcduGKJj+EfpyrNtmfGnm2cUXzbXdFeHtWqIGUR55JBKcVxD0V5/hkJbM9GOCFTpIBIMrz+gu3kZSGwirxOz5L5M1qJXCR1NynKFgV/kMbUnxfM283W1Ry196npxHj1BQeM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=163.com; spf=pass smtp.mailfrom=163.com; dkim=pass (1024-bit key) header.d=163.com header.i=@163.com header.b=HU16IlHH; arc=none smtp.client-ip=117.135.210.2
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=163.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=163.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=163.com header.i=@163.com header.b="HU16IlHH"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=163.com;
	s=s110527; h=From:To:Subject:Date:Message-ID:MIME-Version; bh=bH
	zGzX6Qzj5JD2KLoEadOSuzSvrrAnACd1jSYDetT3Y=; b=HU16IlHHXRGBZNiYZr
	zfZ38IbfkgvatLkIxm/ft6cMLYvbYBY3cAbFVXAlqNxJGryFfQ0eItAyoc204y+u
	XYPZEVZcDmwoSobzlmGHlCMpT7jA5Hgy3cMaEGhHtk8rXt/qncBEr5hlXGDhL/+h
	HvL/zAD7UI2wPomyGpkYIn8Qw=
Received: from localhost.localdomain (unknown [])
	by gzsmtp2 (Coremail) with SMTP id PSgvCgBX8_9uaWhq5t3LIg--.41897S2;
	Tue, 28 Jul 2026 16:33:53 +0800 (CST)
From: xuchenchen <xu18736995897@163.com>
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com,
	xuchenchen <xuchenchen@kylinos.cn>
Subject: [PATCH] statd: fix memory leak in sm_mon_1_svc() when existing host re-monitors
Date: Tue, 28 Jul 2026 16:33:47 +0800
Message-ID: <20260728083347.6132-1-xu18736995897@163.com>
X-Mailer: git-send-email 2.47.3
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:PSgvCgBX8_9uaWhq5t3LIg--.41897S2
X-Coremail-Antispam: 1Uf129KBjvdXoW7Gw18WFW7Wr4rKFy7WFy7trb_yoWDKwcEk3
	97t397tr4DAw4ftw4DA3Z5JF12qw4I9Fy0krsrAr1UAayFyayvqFy2vrs2kasrur429FZx
	AwsrW345Cw1xKjkaLaAFLSUrUUUUjb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
	9fnUUvcSsGvfC2KfnxnUUI43ZEXa7IU1YhF3UUUUU==
X-CM-SenderInfo: t0xrmlytwzmkqyzxqiywtou0bp/xtbC9RErCWpoaXGoFAAA3g

From: xuchenchen <xuchenchen@kylinos.cn>

When an already-monitored host sends a new SM_MON request with a
different priv cookie, the code sets existing=1 and reuses the
existing notify_list entry. However, clnt->dns_name is overwritten
with the newly allocated dnsname without freeing the old value,
causing a memory leak.

Since statd is a long-running daemon, repeated SM_MON requests with
changing cookies will accumulate leaked strings.

Fix by freeing the old dns_name before overwriting it.

Signed-off-by: xuchenchen <xuchenchen@kylinos.cn>
---
 utils/statd/monitor.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/utils/statd/monitor.c b/utils/statd/monitor.c
index c76589ca..76ef16f1 100644
--- a/utils/statd/monitor.c
+++ b/utils/statd/monitor.c
@@ -187,6 +187,8 @@ sm_mon_1_svc(struct mon *argp, struct svc_req *rqstp)
 	NL_MY_VERS(clnt) = id->my_vers;
 	NL_MY_PROC(clnt) = id->my_proc;
 	memcpy(NL_PRIV(clnt), argp->priv, SM_PRIV_SIZE);
+	if (existing)
+		free(clnt->dns_name);
 	clnt->dns_name = dnsname;
 
 	/*
-- 
2.47.3

