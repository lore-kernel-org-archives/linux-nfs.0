Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 683144D7D46;
	Mon, 21 Sep 2026 16:31:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790008320; cv=none; b=WMBQjbr1PivyCa6M4bGrjkno7r3EOBuBZnPEOweDiOZ6/NqPxrlVojBOXtO2VncB86RrU6jG2hqr9mtjI+SOX/Xio2MYyMjsPwhSR+pQIoNnrzvl+HegzQ9A5Jbyb2Vq8HcG43Ct4FYGbE3PqrbMHwDOC8k9bv1sIOGnRLhxthg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790008320; c=relaxed/simple;
	bh=ImZu2rrTp3BgaUjvgrhT8+XgUZVUh9pI+IzGxU0cFQ8=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=iychUh9Z4xSfYdphMaNoNk8K66S63DpTJb4wp/LpBDJ8hVHP4cQ6Kl/EVWtkFB94kuyfC6y1TEADB203+sx2HN6iQTexS+UiC2CMVm6bgfEy5WTqM5IAPQf6CKdW2pTx7UyGyjUCs/xQKeUxKGThd2Zcz2QsOWCGtOeVRowQWiw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=N7Mu/+7z; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="N7Mu/+7z"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8AE771F00899;
	Mon, 21 Sep 2026 16:31:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790008319;
	bh=LsBdDva0KrdXCVvAA86ZG5+kA6vb0RfnH5D+cyesTgw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=N7Mu/+7zLBebL7Cb87rwH8C85hiRPSl3UiT8rJdyFTutJ6v6jEjg3e7+J4svw4jAt
	 b0qvjhF+mYFVs6uzSFdu6F4PjBQXliHIE56FWWJt9pDHj+yknXpQG8y2bvRegJvSeO
	 k/n/6M91i7o86YJLxBWaOspH9Ea3PC1LnQCxu5rsLNn12uaKCWN08PHKyoWH40CFVY
	 ONF2BRbHHpfn7u3NOrhctvtmTM5SFwBpUdLA2n8KpufZRLt6Ie6YSQUS0bUD06t2b4
	 xuZuIHiH4ig+VewqP9lTL6FdX1G7edW3zyBHzE0WxzQojGZ7JOf+SX5y2K2TgKahCs
	 0jdsFwxzqXrVw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 21 Sep 2026 12:31:41 -0400
Subject: [PATCH 2/8] nfsd: make max_blksize a per-namespace setting
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260921-nfsd-per-net-mutex-v1-2-4a7287f6504c@kernel.org>
References: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
In-Reply-To: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Shuah Khan <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-kselftest@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3112; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=ImZu2rrTp3BgaUjvgrhT8+XgUZVUh9pI+IzGxU0cFQ8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqsVv6fvQgwRe3JESJ9weNI1gHKPWD6N8saf/7/
 YVrAiJNGe2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCarFb+gAKCRAADmhBGVaC
 FWDiD/4yCQXRhYo4Hf8eBDOOtk8kvUCKMrbOGRYnxUhOt1vmNPqIerPcJZWbWxKi5tErbkSUygy
 pw8cchYJ/s112fYpQkH0opYehx5yYoMCx7vjkdYbC6iazyrax2YVpLtz3ve7pDeQenKI9zXNbuX
 W3fPAJ7NT4ClAnYUxsYAQkYEEFw1iVJBtbOXe+9vDiHeXII41RcbOilK8GpxtPtqz86pNUa/JnD
 hoyJyXeyr6JJKIVzx2v/LACZH4s0meuGi6jKzwlWhfCoXMnL9yfi9cnhiCXjrNRjeAjCu4qO1L0
 RUC6O9BLMEmo3N4NSm9Lx4vjl82RiC9iHWfWBNZQM8bvj/koLAu/8kkVR/JxhS02KBuY1rk1Zgi
 WIAaq1kPa8zxDaNP0+gaOLulePjq+bwTJV8fw8ugsCTSmsRXQi0bJdsnBsS6DnSuT9mws+3y2vf
 Be5BSUmz9Jp9UuEMKhZvPCzd6NU04eL8BcrxMxWUVJnlpBOBgxjH+5CiJbKu11gNAuZ1ox3Q0tY
 LehEvodsSUAOPsg/mm/m2qoeFwxWT1ulTszDAtA9BaeobWHEqLVTZTWwrAK4XZpunh4B7ot0sj/
 gJTPP0jM5ClJhFNOxgzdnAeILbADSYpn3su38wXN2aTGdKpTEJTfSAZE5RcUZ5dKoRDth6R6ar5
 FwqAa+zIxxc1oIw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_max_blksize is module-scope, but /proc/fs/nfsd/max_block_size is a
per-netns file. A container writing it therefore changes the payload size
that every other namespace's next server start will use.

Move it into struct nfsd_net as ->max_blksize. The lazy
nfsd_get_default_max_blksize() fill-in now happens per namespace on first
nfsd_create_serv().

User-visible change: max_block_size no longer leaks across namespaces.

Fixes: 11f779421a39 ("nfsd: containerize NFSd filesystem")
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/netns.h  | 6 ++++++
 fs/nfsd/nfsctl.c | 8 +++-----
 fs/nfsd/nfsd.h   | 2 --
 fs/nfsd/nfssvc.c | 6 +++---
 4 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 0ce7da20aba3..374ce83e2ba0 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -154,6 +154,12 @@ struct nfsd_net {
 	 */
 	unsigned int min_threads;
 
+	/*
+	 * Maximum size of an NFS READ or WRITE payload.  Zero until the
+	 * first server start in this namespace picks a default.
+	 */
+	unsigned int max_blksize;
+
 	u32 clientid_base;
 	u32 clientid_counter;
 	u32 clverifier_counter;
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f32311f2d7cf..330d0f12e199 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -885,8 +885,6 @@ static ssize_t write_ports(struct file *file, char *buf, size_t size)
 }
 
 
-int nfsd_max_blksize;
-
 /*
  * write_maxblksize - Set or report the current NFS blksize
  *
@@ -931,12 +929,12 @@ static ssize_t write_maxblksize(struct file *file, char *buf, size_t size)
 			mutex_unlock(&nfsd_mutex);
 			return -EBUSY;
 		}
-		nfsd_max_blksize = bsize;
+		nn->max_blksize = bsize;
 		mutex_unlock(&nfsd_mutex);
 	}
 
-	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%d\n",
-							nfsd_max_blksize);
+	return scnprintf(buf, SIMPLE_TRANSACTION_LIMIT, "%u\n",
+							nn->max_blksize);
 }
 
 #ifdef CONFIG_NFSD_V4
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index d1e413d21e76..0864d6d564e2 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -143,8 +143,6 @@ enum {
 extern u64 nfsd_io_cache_read __read_mostly;
 extern u64 nfsd_io_cache_write __read_mostly;
 
-extern int nfsd_max_blksize;
-
 bool nfsd_v4client(struct svc_rqst *rqstp);
 
 /*
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index d75fe1523436..77e1e6ba686d 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -630,12 +630,12 @@ int nfsd_create_serv(struct net *net, bool no_rpcbind)
 	init_completion(&nn->nfsd_net_free_done);
 	init_completion(&nn->nfsd_net_confirm_done);
 
-	if (nfsd_max_blksize == 0)
-		nfsd_max_blksize = nfsd_get_default_max_blksize();
+	if (nn->max_blksize == 0)
+		nn->max_blksize = nfsd_get_default_max_blksize();
 	nfsd_reset_versions(nn);
 	serv = svc_create_pooled(nfsd_programs, ARRAY_SIZE(nfsd_programs),
 				 &nn->nfsd_svcstats,
-				 nfsd_max_blksize, nfsd);
+				 nn->max_blksize, nfsd);
 	if (serv == NULL) {
 		percpu_ref_exit(&nn->nfsd_net_ref);
 		return -ENOMEM;

-- 
2.55.0

