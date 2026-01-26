Received: from cstnet.cn (smtp21.cstnet.cn [159.226.251.21])
	(using TLSv1.2 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 46D011AC44D;
	Mon, 26 Jan 2026 02:10:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=159.226.251.21
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769393459; cv=none; b=jXPHk5MEg/p2Y7INhoH/pMndjq//G4ESs4+UB7skMJVf9qoqGT7hGgwDFP8rD4RQ4eaLvgyTmvRDJ+MmfKXsDaetudjnIR100qxFPq2pt+zZ5h3pMlCW3+v+tKQKqMCL+zRwKsRH1GbJ6lZuYNvlgERs8ylE9XqeTlQcSxhD2rA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769393459; c=relaxed/simple;
	bh=kONB/iYaRl0XbyXiSod9ipd+ztmVUUWg295pQet6IYE=;
	h=From:To:Cc:Subject:Date:Message-Id:MIME-Version; b=VjkLr6RG1so/BDeHe3lxNtygJJ/We+Xrv5hHqut7HClQN6RczdjZEXczFaKz76S3DGGotjIN+0I02TwNvksr9plwl8/fZIH/11mzLBw8VirBSON1aqdPUliaxA9tE2YhrTLsyXOeBSwpY0FzMbstWzxqRQYCRq7A8QjWN867gGI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=isrc.iscas.ac.cn; spf=pass smtp.mailfrom=isrc.iscas.ac.cn; arc=none smtp.client-ip=159.226.251.21
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=isrc.iscas.ac.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=isrc.iscas.ac.cn
Received: from localhost.localdomain (unknown [36.112.3.223])
	by APP-01 (Coremail) with SMTP id qwCowACHMm4nzXZpURdABg--.35965S2;
	Mon, 26 Jan 2026 10:10:48 +0800 (CST)
From: Haoxiang Li <lihaoxiang@isrc.iscas.ac.cn>
To: trondmy@kernel.org,
	anna@kernel.org,
	davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com,
	horms@kernel.org,
	llfamsec@gmail.com,
	simo@redhat.com,
	bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Haoxiang Li <lihaoxiang@isrc.iscas.ac.cn>,
	stable@vger.kernel.org
Subject: [PATCH] sunrpc: fix a resource leak in gss_proxy_save_rsc()
Date: Mon, 26 Jan 2026 10:10:47 +0800
Message-Id: <20260126021047.2478741-1-lihaoxiang@isrc.iscas.ac.cn>
X-Mailer: git-send-email 2.25.1
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-CM-TRANSID:qwCowACHMm4nzXZpURdABg--.35965S2
X-Coremail-Antispam: 1UD129KBjvdXoWrKw48Xr47Aw4xKr1UAr1rXrb_yoWfuwb_WF
	9rWFs8Xr4fu3W7Zw43JwnIvrWxG345JF18Gr9xKFyayr45tF1vyaykurn8Jr1Dury8Cws3
	Jr1kZr9Iqwn7KjkaLaAFLSUrUUUUjb8apTn2vfkv8UJUUUU8Yxn0WfASr-VFAUDa7-sFnT
	9fnUUIcSsGvfJTRUUUb3xFF20E14v26r4j6ryUM7CY07I20VC2zVCF04k26cxKx2IYs7xG
	6rWj6s0DM7CIcVAFz4kK6r1j6r18M28lY4IEw2IIxxk0rwA2F7IY1VAKz4vEj48ve4kI8w
	A2z4x0Y4vE2Ix0cI8IcVAFwI0_Jr0_JF4l84ACjcxK6xIIjxv20xvEc7CjxVAFwI0_Gr0_
	Cr1l84ACjcxK6I8E87Iv67AKxVWUJVW8JwA2z4x0Y4vEx4A2jsIEc7CjxVAFwI0_Gr0_Gr
	1UM2AIxVAIcxkEcVAq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xfMcIj6xII
	jxv20xvE14v26r1j6r18McIj6I8E87Iv67AKxVWUJVW8JwAm72CE4IkC6x0Yz7v_Jr0_Gr
	1lF7xvr2IYc2Ij64vIr41lF7I21c0EjII2zVCS5cI20VAGYxC7M4IIrI8v6xkF7I0E8cxa
	n2IY04v7MxkF7I0En4kS14v26r1q6r43MxAIw28IcxkI7VAKI48JMxC20s026xCaFVCjc4
	AY6r1j6r4UMI8I3I0E5I8CrVAFwI0_Jr0_Jr4lx2IqxVCjr7xvwVAFwI0_JrI_JrWlx4CE
	17CEb7AF67AKxVWUtVW8ZwCIc40Y0x0EwIxGrwCI42IY6xIIjxv20xvE14v26r1j6r1xMI
	IF0xvE2Ix0cI8IcVCY1x0267AKxVW8JVWxJwCI42IY6xAIw20EY4v20xvaj40_Jr0_JF4l
	IxAIcVC2z280aVAFwI0_Jr0_Gr1lIxAIcVC2z280aVCY1x0267AKxVW8JVW8JrUvcSsGvf
	C2KfnxnUUI43ZEXa7VUbGQ6JUUUUU==
X-CM-SenderInfo: 5olkt0x0ld0ww6lv2u4olvutnvoduhdfq/1tbiDAgTE2l2MUTgkAABsf

In gss_proxy_save_rsc(), if gss_import_sec_context() fails,
call gss_mech_put() to release the reources acquired by
gss_mech_get_by_OID().

Fixes: 030d794bf498 ("SUNRPC: Use gssproxy upcall for server RPCGSS authentication.")
Cc: stable@vger.kernel.org
Signed-off-by: Haoxiang Li <lihaoxiang@isrc.iscas.ac.cn>
---
 net/sunrpc/auth_gss/svcauth_gss.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/auth_gss/svcauth_gss.c b/net/sunrpc/auth_gss/svcauth_gss.c
index a8ec30759a18..cdae1f23adfc 100644
--- a/net/sunrpc/auth_gss/svcauth_gss.c
+++ b/net/sunrpc/auth_gss/svcauth_gss.c
@@ -1268,8 +1268,10 @@ static int gss_proxy_save_rsc(struct cache_detail *cd,
 						ud->out_handle.len,
 						gm, &rsci.mechctx,
 						&expiry, GFP_KERNEL);
-		if (status)
+		if (status) {
+			gss_mech_put(gm);
 			goto out;
+		}
 
 		getboottime64(&boot);
 		expiry -= boot.tv_sec;
-- 
2.25.1

