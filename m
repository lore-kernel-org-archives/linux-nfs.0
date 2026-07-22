Received: from mail-pl1-f175.google.com (mail-pl1-f175.google.com [209.85.214.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2C7D93126B2
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 18:21:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.214.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784744523; cv=none; b=bviUdWqQEYaVKfwY/Wb+tziITN8et5O4tC6ngO1Ne4coWKStvIjLLtMcdi3+K2DUTU+KwZUsZ3eqkvaULzujj7zx5tdQi/R0ACSSrN6mlY0odMbkZszHVQ+Adg5FY1Wv3OxiPAJpuGsVSJpUPyCWT5rkmf168BLPPX3pbHfizDQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784744523; c=relaxed/simple;
	bh=P8FWy1tUNZy254/t3Q2SdlHTPBy6/tOA7OG8L5olLgM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=hOZsycRYxptjiwSFpB46Z+U23c6ZOUYjA8W1Mygjte8yZf/5kpVgTyNDFsvtR3hcqeYuEZKIbE4q0g7fflERVh43oyA3SRjr4pU4qbJNgFdisp/AjsfpgsUWPIDkfDS5m9YDYf375PwFvhCIeho4Vn29ldFegqmlhzTywTTNyJk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=WgISf6CO; arc=none smtp.client-ip=209.85.214.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="WgISf6CO"
Received: by mail-pl1-f175.google.com with SMTP id d9443c01a7336-2caea3f742bso154133885ad.0
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 11:21:59 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1784744519; x=1785349319; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=6370lSCMfomCtQziBDgTY+lShjBYnGlG2dgy/Dr1HuI=;
        b=WgISf6COxU57iNyDQNgpFvhLZWdj/Lvt48ZT/YATYf+HScj7kKHJI+LTPxW1KuIlG0
         snR1Mc5AT7LCOUNJNCvK178q4zFtTFAd15SaLBYD+idAWTDG7PSdquSUkwMVeslZ3/Pp
         p/5nAkm9F72v1vf4TrfM3iZ5Ry//VuTa1zo4nFJii/ewI3ejOxq7ct15BsqxtVYbkLKz
         JKeW7dkpC/G0HT7eIVNcaNE6OwswryLjU2JC4Jkc6DEimR+GFunGvN0APM/VZVIru2cQ
         Hj/HauwVDs+sMipgs0FQah/mVENyT0dx63Z4mCQPIWRIkNODsQ58aSwSyQsPF4tPO2/2
         FV8w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1784744519; x=1785349319;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=6370lSCMfomCtQziBDgTY+lShjBYnGlG2dgy/Dr1HuI=;
        b=dC5gM7w7nttuSBraAkCgj0C25Cham5G3hUJ+A5dR9M4hBw45KdDzFLCqkGoQ/VbqdJ
         G3Osq2hwotmHyD1pKfZAc3eLdwK2DBNbrNakxpEfzQNc5G802o/+r03CwY9VdgaBoifP
         FnzEy7S0PlYigwiGlGFOIUvWVC0t3dgZIdf/RUe8fZFlchr8RLHE+bOqyPeHUh7xlSxr
         w4WGSR+Q4Wm1pkaeyKUae4OxooIrU0Udpg6lVX2/IP+fMxstcEOW7h3jr/hsNHUjeBly
         J7zPPvVbtb1mJJr7DsySx47bFLBO2+Dp+UilIGJKvi5IrnwrSVXDtcnn0mL/2pR1zYXN
         l5wg==
X-Forwarded-Encrypted: i=1; AHgh+Ro/v2OPOiqzgT0Dladrk6FTVucd/V4QwH0sQQQhtRD1xsb8N69IKcnnGJylnzz7f/iXjHe7Oxq2WUE=@vger.kernel.org
X-Gm-Message-State: AOJu0Yy4u0nUlVnzi/easF5ztgdpiERbg1ZkV/qaFXYnAnc1UXDz2OiB
	vqjKhIWVfDBGEgT+d9VJnZoW60wt7+UDpcf5rjNsa2JkMZwGBuG6knuwvABI51pzjQ==
X-Gm-Gg: AR+sD12e1oDYz64XkF50/DJ0WQr1QwxbkmxPwke4Fm0YQWHhW2CHgDZb06+ucCQOrg6
	ropPcYNqCoLL81lFPStnqZ7NZhB6PMY9+ZnKCiLHFzDLWuznazDNqajVMT3FH8wVbSBssmT5Wvk
	m01mJCl8QrUibRK0A2hknOpFLhlfNoCfDmCfRnZrHIWLLCIlwCrVhhI6MbL5Af3FVaBMDJMLxiA
	cBryCqcYTNbXwWZmzgk8PetB1w0mZyHQ1NTn3d3b2TktBM8KWpveK1b7NH6kKOLQnaw7qcZeiaI
	+D6UXNey3Z1P9U4kM5CE6iL/nGx5/wCALVf9CffvYNxiPr43v3lWOGwAcwIbAnZoOu8N00b7mAP
	3NKNmXdQj5bB7kr7Azf8gASkdVVrDRme5DmolDSGA+Gj70cZlNhO5KZXby/xrLpaDObw2ujAzYj
	5vdew9
X-Received: by 2002:a17:90b:1c8e:b0:37f:ed7e:7e42 with SMTP id 98e67ed59e1d1-38e4b410b8bmr23878928a91.14.1784744519428;
        Wed, 22 Jul 2026 11:21:59 -0700 (PDT)
Received: from hamza-PC ([2400:adc1:158:c700:28c8:66ff:fe97:3f21])
        by smtp.gmail.com with ESMTPSA id a92af1059eb24-13d130f55c6sm14443009c88.15.2026.07.22.11.21.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 22 Jul 2026 11:21:58 -0700 (PDT)
From: Ameer Hamza <ameer.hamza@truenas.com>
To: cel@kernel.org,
	jlayton@kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Cc: trondmy@kernel.org,
	anna@kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	frederic@kernel.org,
	alexander.motin@truenas.com,
	caleb.stjohn@truenas.com,
	Ameer Hamza <ameer.hamza@truenas.com>
Subject: [PATCH] SUNRPC: Restore NUMA_NO_NODE for svc thread allocations in global mode
Date: Wed, 22 Jul 2026 23:20:11 +0500
Message-ID: <20260722182012.2063936-1-ameer.hamza@truenas.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Commit d57e43b72bf2 ("SUNRPC: Update svcxdr_init_decode() to call
xdr_set_scratch_folio()") changed svc_pool_map_get_node() to return
numa_mem_id() instead of NUMA_NO_NODE, because __folio_alloc_node()
cannot accept NUMA_NO_NODE. That return value is not equivalent: it
is evaluated in the context of the task creating the nfsd threads,
once per thread created, and it is passed to kthread_create_on_node()
and to the per-thread allocations in svc_prepare_thread().

Since commit d1a89197589c ("kthread: Default affine kthread to its
preferred NUMA node"), the node argument of kthread_create_on_node()
no longer only places the task structure and stack: a kthread created
with a real node id normally affines itself to that node's CPUs when
it is first woken to run its thread function. All nfsd threads are
typically started together, by one task writing to
/proc/fs/nfsd/threads, so under the default pool_mode=global each
nfsd thread is now affined to the local-memory node of the CPU its
creating iteration happened to run on - typically the same node for
every thread. The CPUs of the other nodes are then unable to run
nfsd at all, and the threads' allocations - svc_rqst structures,
page pointer arrays, newly allocated task stacks, and the per-RPC
pages allocated at run time - all prefer that one node.

Restore the NUMA_NO_NODE behaviour that global mode has had since
commit 11fd165c68b7 ("sunrpc: use better NUMA affinities"), and
handle NUMA_NO_NODE at the one call site that cannot take it by
resolving it to numa_mem_id() there, exactly as alloc_pages_node()
did for the scratch page before the conversion. The mapped percpu
and pernode branches are unchanged. Unpooled services such as lockd
and the NFS client callback service also take this fallback when no
percpu or pernode map is active, restoring their thread placement in
that case.

A bisect of a 2x NFS READ throughput regression between v6.17 and
v6.18 converged on d57e43b72bf2. On the affected 4-node server every
nfsd thread comes up with its CPU affinity restricted to the CPUs of
a single node; with this change the threads are runnable on all CPUs
again and the observed regression is resolved.

Fixes: d57e43b72bf2 ("SUNRPC: Update svcxdr_init_decode() to call xdr_set_scratch_folio()")
Signed-off-by: Ameer Hamza <ameer.hamza@truenas.com>
---
The pool-mode rework in nfsd-testing already removes global mode,
so this fix is based on nfsd-fixes and aimed there and at stable
(v6.18+), where the regression ships. Tested on a v6.18-based
4-node server: without this patch all nfsd threads come up affined
to one node; with it they are runnable on all CPUs.

 net/sunrpc/svc.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index ae9ec4bf34f7..16b1ca1a7ae3 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -352,7 +352,7 @@ static int svc_pool_map_get_node(unsigned int pidx)
 		if (m->mode == SVC_POOL_PERNODE)
 			return m->pool_to[pidx];
 	}
-	return numa_mem_id();
+	return NUMA_NO_NODE;
 }
 /*
  * Set the given thread's cpus_allowed mask so that it
@@ -711,7 +711,9 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
 	rqstp->rq_server = serv;
 	rqstp->rq_pool = pool;
 
-	rqstp->rq_scratch_folio = __folio_alloc_node(GFP_KERNEL, 0, node);
+	rqstp->rq_scratch_folio = __folio_alloc_node(GFP_KERNEL, 0,
+						     node == NUMA_NO_NODE ?
+						     numa_mem_id() : node);
 	if (!rqstp->rq_scratch_folio)
 		goto out_enomem;
 

base-commit: 5c4851e4cdfc3204128f88991be64a6e3929d3d0
-- 
2.53.0

