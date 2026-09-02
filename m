Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1978D39659A;
	Wed,  2 Sep 2026 19:29:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788377362; cv=none; b=UENrOAzhlvaHT/ZOvhvHErE6GiWHWwXw5VswqiWHVU5HcPJZsD1Cc3PViuprQl2rbdngc2kt7OrPMOkggeFE5AkN/TJo8LCUAd537mEKXwir7I6SfHficUW4n2BuMy3GHsgbDmqQvb98JxZ2K4/Oi7Pfbq5v8fY9Es2tzxNmGYU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788377362; c=relaxed/simple;
	bh=O3TNdnVPoa4rGbmi2tla4aohyiGvRmbOQcuo0rGfqKE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=EWX0gC8+YklMzUSv9qdtcbERiRju0NME/P7cv7An8bnRTFbHMpFTk25hU4j2bG4uPzj9ZuucTggQUq/LLTXcWfgAJFBbZ118J1TpryCge4ZhOB47goPbEQC5hG+vA1yFdyIZw3cCulZ8bDr4ilneNFwlTd8lkj2nZ8TL6lEwvl8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=E3uurmS+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="E3uurmS+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1BD6B1F00A3E;
	Wed,  2 Sep 2026 19:29:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788377348;
	bh=2Zj70FxOcUP0kW1TVIjjFDiwHX+7yaJeILXFSkVDfkg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=E3uurmS+zQ5o2UMdKcqhYNEqtDL4cYXvdfjzc1/Th6Fmdga4fFHSwKkSGC/P4184P
	 9YYrX5CF2ACkAo3HbcWmgQisz/QapiAh7M0jjjY5eGOl7bV1z9bdcwjXkkGKvcW4lf
	 NKEWQUnewUMZnbfwtE5abhXRFrknubUX6estY3S6onz4X6Mzt0l0FCzp5vwFpQhRLU
	 5lTVOsI/AoI5owNfDm2qhRH/5ZvFOu6hxqnE/dAsgPtqfTvXEmVZr5ybWoNIlgv0+p
	 Y2VFLrG9Tc2iLjsydyJh0vk7FUfx4aYIAiClj5sugl3r64GFgnZDwGDPltFsyXPtSF
	 4PbLJ0bGi87SA==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 02 Sep 2026 15:28:49 -0400
Subject: [PATCH RFC v2 4/8] NFS: Set WQ_SYSFS on nfsiod
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260902-performance-v2-4-b71c0c082f9d@kernel.org>
References: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
In-Reply-To: <20260902-performance-v2-0-b71c0c082f9d@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1001; i=cel@kernel.org;
 h=from:subject:message-id; bh=O3TNdnVPoa4rGbmi2tla4aohyiGvRmbOQcuo0rGfqKE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqmHkAaXKA35xguWdIO/e6pfBSBFjxh08mpsOrY
 N+Y7QYczUmJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaph5AAAKCRAzarMzb2Z/
 l8eoD/9A8+juOd72lLi5emkXSQ/DSEoNSJxur07U9V27h6RGDAHhe1Zm9eVrDhAI22QGpQEtG8P
 FTvduuIaEuclhpLNSV+qTxgFoxJpkdgJrx/oVy0841LYdrVE1wsWcu6nR/MOWhZZ693MGo/U/ct
 jCk4BmmnIRa5GbotbDXXDU1I8G5z/qV30D2gCdtlhBN36nCDxRXrb3Fr8qtX6t/jrrUQ3QV19wd
 5AhCJwYZ3ugMi2aeIvc0UCPv0JH/s/4ieERED2j8Nq9X9e3bPnVEEu0WDGyp3RAo7gM3WpRcAUf
 gJZMODuji1Usr+TwW8J1qFiqzzbVIDzqmf3Orn+CCLC7iWLou+rpvtp4dla/oACVxp/FzlQyf0D
 v+6SkQk7rEnusg296fNcv0VvlpglhmN4NyZAo84+iLuqSEi1QdW8Px57JYVDci7NzARHXY8t0SU
 NXuxLDCl9VN5AaX+FovYU29R8nizd2K4dZ6ogOb4H9EXAhf4sKOZaa9bSlG0j3mdcQBz33/SN3l
 Nmdfx0vBeZEYM6fc+DxsaQO2Z9fEPclqz+H/pRCgTBKiH3PXVsfC49fS93q+YRF819bDefxI9TI
 roXhTwPbqr08qnjNDQBlgPHRuleBOjPoRKCUsPzDDn2W3GHoffVNwyV9U31wCyoGS+Afxj07bNN
 7C3M7JbCRVB+lRg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

An unbound workqueue's attributes can be changed at run time only
through /sys/devices/virtual/workqueue/, and a workqueue appears
there only when it is created with WQ_SYSFS. nfsiod is created
without it, so its affinity scope cannot be tuned without reloading
the nfs module.

Create nfsiod with WQ_SYSFS.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/inode.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3022454f7698..107a2135029d 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2619,7 +2619,8 @@ static void nfsiod_stop(void)
 static int nfsiod_start(void)
 {
 	dprintk("RPC:       creating workqueue nfsiod\n");
-	nfsiod_workqueue = alloc_workqueue("nfsiod", WQ_MEM_RECLAIM | WQ_UNBOUND, 0);
+	nfsiod_workqueue = alloc_workqueue("nfsiod",
+				WQ_MEM_RECLAIM | WQ_UNBOUND | WQ_SYSFS, 0);
 	if (nfsiod_workqueue == NULL)
 		return -ENOMEM;
 #if IS_ENABLED(CONFIG_NFS_LOCALIO)

-- 
2.55.0

