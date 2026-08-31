Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A30284A3F3C;
	Mon, 31 Aug 2026 18:22:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788200534; cv=none; b=CoB308hUZyKyRmmJanXhyFDp1UFQhfz+OINeKoOSUB9LKO8TqfP2QfIjUTE78XDVTKiexzlObF0rQ4x1l1Df/5Ue8fLpPrBs5dhlKzxcOSJOe72quZsFK3gnoN5hkbPkdPlisePDD5dlHh84MPKwboDWf0UgzOhZHYwiHKldz/k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788200534; c=relaxed/simple;
	bh=wz0MMyyCVaHC2FjQqTHwJ7v4CqEft8XGFBczTPxg0gc=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ahJHUOn25jg5FgCy5ty+QJSyIpqLz5Gl1tjV6TUBhSnQAEeskYCSQ4if9LF8tQ8ybHJt4bnvMDLQR0FyserbD1jbx0xidm1E5Qs3p8KOafDx6l2fOdrxHnW/k0Fy0kRWGNOylDYCg9qn+COtLGhIReCAuo4QplxZySR6kWj8QxY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IoPkQP6b; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IoPkQP6b"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BF2881F00A3D;
	Mon, 31 Aug 2026 18:22:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788200532;
	bh=N5/NvHDvb3vrI/xCSkZr3CvmB/0BWoH3Q+mf/sS77qk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=IoPkQP6bbTr2j8P4eUXGv/jtSoKApzuIa3olJamVyWdUAPIo/djbKp6F/NagL5l7l
	 IEhY4rrJEyE4KsMHNgq1dQ3aIyOidrBnXjs8/kChBLZGspKZ7t0uzR/bTIdkcWeIsA
	 jZh5hEGGmpYO6HP6sOvQh08Wd4Q/Ue3+kNLd80DRVkxqs+PHp+qJzzxrDljlRSZYKk
	 ChpSbnuWidS+3bXBokEn3MBPkHaNU7Vdjt4dj7LYpyUCa/DMQlyV2kK7dBRx8D7Q4H
	 66DrcBX4CNwlcssW1FYooiMDiUwZ6MxiKOoaGGqb0uZJumojK+38tJJ+xviEB+pws8
	 0eJ9m1RT8TdbQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 31 Aug 2026 14:22:01 -0400
Subject: [PATCH RFC 5/8] workqueue: Export the functions needed for WQ
 attribute modification
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260831-performance-v1-5-8d9fd9b67f96@kernel.org>
References: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
In-Reply-To: <20260831-performance-v1-0-8d9fd9b67f96@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Tejun Heo <tj@kernel.org>
Cc: Lai Jiangshan <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org, 
 open list <linux-kernel@vger.kernel.org>, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=1253; i=cel@kernel.org;
 h=from:subject:message-id; bh=wz0MMyyCVaHC2FjQqTHwJ7v4CqEft8XGFBczTPxg0gc=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqlcZPuhAhLHX7AWO8Ot4Np0II83BTgr62QTWg9
 kZMKeVQjVGJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCapXGTwAKCRAzarMzb2Z/
 lzCeD/4gztX07Z05+X9r+YuO8v22geySVkE3TEXIXsCeW5QmpcqaWCXnMKg6STUkYjBvDQ9vQNE
 dt5PQQ1pqsh44J9NiVg/sVBtdPXWvKBB+fvLQFN79Mn8Ee9NRzebJWv7l05GNxlCGoUvQibYQ9V
 eho8uiLGBXqARlC1+NGmeIu/Y9k8pXLB1oP6p2836u1LcDHuHM5gByqLrjUJDyrSqctHRVEmSsz
 eiY8U4t3vo2bwj4iJi7iDlXWl/SD77P9XLmPAQ0rrCSNEzpeA80rkvUMZuddRhY1/5q9dmnk3GD
 QKUmuPXvCPPqOjRdmAj9CO4hL1I0llgQOO5ECzheschTOf1AVg/rFqGvRYvicsPJgHwAfaJfo3N
 DFe6cILKBYaoezka8S76X9ABKZ6CIMnbGjp71vUCI+It36Z108SN7AYep2C9c6L5z0iFn1z2q1l
 TpxunTcuMOBuhp5FUio9OyVipCBSHZPQ6+pQYFu19TgjubqqTZB+iQ4tMk5ZMWSb3JywsdqUqc2
 svsfeg/Y87qIX6nC5amoBvWTfpzOKeJ/7vGfQS6BbIYW8hY3J2fbE/u/M+4asM9erRBcTzjvi4e
 EpS83qcftyDfZeBZzE80OGKtY4EGNzAdRlz5opjdDxwTPRQaJmT6d3lMT3xrzrBElgQXVjl7bOZ
 Sj92Ekwj+l8uKFg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Modules that create unbound workqueues currently have no way
to modify workqueue attributes at run time. Export the
allocation, application, and teardown functions so that
modules such as sunrpc can adjust affinity scope without
reloading.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 kernel/workqueue.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/kernel/workqueue.c b/kernel/workqueue.c
index 3c034cbc5bb3..fd76a875cf2d 100644
--- a/kernel/workqueue.c
+++ b/kernel/workqueue.c
@@ -4813,6 +4813,7 @@ void free_workqueue_attrs(struct workqueue_attrs *attrs)
 		kfree(attrs);
 	}
 }
+EXPORT_SYMBOL_GPL(free_workqueue_attrs);
 
 /**
  * alloc_workqueue_attrs - allocate a workqueue_attrs
@@ -4841,6 +4842,7 @@ struct workqueue_attrs *alloc_workqueue_attrs_noprof(void)
 	free_workqueue_attrs(attrs);
 	return NULL;
 }
+EXPORT_SYMBOL_GPL(alloc_workqueue_attrs_noprof);
 
 static void copy_workqueue_attrs(struct workqueue_attrs *to,
 				 const struct workqueue_attrs *from)
@@ -5609,6 +5611,7 @@ int apply_workqueue_attrs(struct workqueue_struct *wq,
 
 	return ret;
 }
+EXPORT_SYMBOL_GPL(apply_workqueue_attrs);
 
 /**
  * unbound_wq_update_pwq - update a pwq slot for CPU hot[un]plug

-- 
2.55.0

