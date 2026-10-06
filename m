Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 059AD49E121;
	Tue,  6 Oct 2026 15:31:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791300680; cv=none; b=UN665c0W+L6eG+LuAnVEZOrMtFp/eEE7TZJK76EJ7bqezys1c4t8/erk2gng508AquiesY5Ek7j4TdL0nKB8jedHlS/rqxE56WPvoaQhGJ6oMWEgj4tm9ggc+VWfRplpXy2JmI8bBLbwRM7OKf7I6NeJK/42rWM5EeDK1BBfR9k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791300680; c=relaxed/simple;
	bh=FLfziQZLPnu6y3z2fWxofxw5KtIfaVhBmkfb5/S3Xb4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=ZEvp4Oe+9bgt0let1PQFimsYBEQxZGjYGYc9KqdLqS8Y5Cb9ZvyGQ8ktyuGF24A98iJRIFD1tL41rCIxPmeFFdp3gQrfo66c0aNR68nd0S1DUREuE2a6inq/T90qih3ADENZtMy8CwNz9n+Kd0ySDpu72ZdHjT6FdBKgBJ7ut4I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PN20r44d; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PN20r44d"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 559601F0089D;
	Tue,  6 Oct 2026 15:31:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791300678;
	bh=PVvkiHtxln9Mn3ExYwHOY9OExYSN010VAj8STzkHraI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PN20r44dCv4oTFR/RMsOsLE5IOd0wNp9cnVP1PIOdy8i1LFLraP8AH1QqJIeKgsAz
	 cBW9C67OK6+A9Nn2MMLSOpiC3fGOxlZ56r2aLmkVrNIpux+Mx9hXj2y5sMz+8FH57d
	 zeY65KutYTIW1JYlYyDrz+H87YxnlO99Afijy79ha0q3mbPP37W72SPDgrVCj4ufCS
	 NsVCw21yfyQRt4NzbH8CNpWGAGBQmjUwZAUIDzJPFbowPmterd7Ge7YEei+5TrICv4
	 Oju+3RrOB2mticmXIqoYh4hZV1HPSyteR3elqkpH98kKVvA8Kh0Hc76aQn3MnGRMkd
	 8pt1XlUyAubZA==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 06 Oct 2026 11:31:12 -0400
Subject: [PATCH v4 1/5] NFS: name the init_nfs_fs() error labels
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261006-nfs-mtls-identity-v4-1-1fdf8cc65da7@kernel.org>
References: <20261006-nfs-mtls-identity-v4-0-1fdf8cc65da7@kernel.org>
In-Reply-To: <20261006-nfs-mtls-identity-v4-0-1fdf8cc65da7@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, 
 Christian Brauner <brauner@kernel.org>, David Howells <dhowells@redhat.com>, 
 Sagi Grimberg <sagi@grimberg.me>, Eric Dumazet <edumazet@kernel.org>
Cc: linux-nfs@vger.kernel.org, keyrings@vger.kernel.org, 
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-doc@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2220; i=cel@kernel.org;
 h=from:subject:message-id; bh=FLfziQZLPnu6y3z2fWxofxw5KtIfaVhBmkfb5/S3Xb4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqxRRDz2LsfW1nz2XOJ0SSgkqLtQVLTHpTcSiPl
 e+ZJE6dWD+JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasUUQwAKCRAzarMzb2Z/
 lwdqD/0Rt0PRlnKalMxGs1/xHp+upHchYXA1gAIv+xAKmaoUHPUfWXIkOmwjj3KeweXI8CyJ2T7
 FBC5UCPeMYBjVc8Se8zu86iUNjKOqOsh3pOn37IGeicQQIaf2CHuXIa0wwkaU0AZ6Yf00UphuCh
 PmdX3STj1GhkH/xWXMaRcvmCggMhxWjTxj0YzVf4l9XRR41jBRQTPZ7IollOujKFmy55Y8ZkGeU
 SUIAUynm1MPMtgSR2y9oIqCRyUjo93UYRIF9kjt1HApCqoBLrTx3NdIfy0Fh/XmBnFbZB2N84eI
 cbzYT0aoby+EmP1YGt/Ed/WV8NPCHA8vz21MdFsXHs8aKXpqP7/zk9DKWCxYkYbGqHyIap3t5a8
 pgWZlzs/X63NEBwDrAmBGibENAlYDjezNrIWbdh3QJ3X4QvBO4ae9mSlDuhrGzqELQiXxXR9eqw
 autGrKYi9FzNLkLqrKcAGqAoNbv9Vf/AC4eDI6KrFyhbLE/3XeZKqOLgP6HrO/PkKwmUIgig+X7
 M8ULKUJDFPpky7Ms1cRQ1KD+AhwFA3Cp3aVFT5/qSIx6nwhET8zXLqw4uKtHztUZPwiYva8nZ2l
 +xb1a0U7FWedEDyjMaTgfPiaLB1FfYz3Sr4um5jWfSdiHopEbpWI8rV8rcrd55pyVcgKsDgfnnG
 EAHlrGI7Bxhy+QA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The unwind labels in init_nfs_fs() are numbered, and the numbering
already skips out8, so a reader has to count the label block to
learn what each one undoes. Inserting an init step means either
renumbering every label below it or leaving the sequence out of
order, and a goto that picks the wrong number unwinds the wrong
step.

Name each label for the step it undoes, as coding-style.rst asks.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/inode.c | 40 ++++++++++++++++++++--------------------
 1 file changed, 20 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 3022454f7698..832923be43a9 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2722,64 +2722,64 @@ static int __init init_nfs_fs(void)
 
 	err = nfs_sysfs_init();
 	if (err < 0)
-		goto out10;
+		goto err_keyring;
 
 	err = register_pernet_subsys(&nfs_net_ops);
 	if (err < 0)
-		goto out9;
+		goto err_sysfs;
 
 	err = nfsiod_start();
 	if (err)
-		goto out7;
+		goto err_pernet;
 
 	err = nfs_fs_proc_init();
 	if (err)
-		goto out6;
+		goto err_nfsiod;
 
 	err = nfs_init_nfspagecache();
 	if (err)
-		goto out5;
+		goto err_proc;
 
 	err = nfs_init_inodecache();
 	if (err)
-		goto out4;
+		goto err_nfspagecache;
 
 	err = nfs_init_readpagecache();
 	if (err)
-		goto out3;
+		goto err_inodecache;
 
 	err = nfs_init_writepagecache();
 	if (err)
-		goto out2;
+		goto err_readpagecache;
 
 	err = nfs_init_directcache();
 	if (err)
-		goto out1;
+		goto err_writepagecache;
 
 	err = register_nfs_fs();
 	if (err)
-		goto out0;
+		goto err_directcache;
 
 	return 0;
-out0:
+err_directcache:
 	nfs_destroy_directcache();
-out1:
+err_writepagecache:
 	nfs_destroy_writepagecache();
-out2:
+err_readpagecache:
 	nfs_destroy_readpagecache();
-out3:
+err_inodecache:
 	nfs_destroy_inodecache();
-out4:
+err_nfspagecache:
 	nfs_destroy_nfspagecache();
-out5:
+err_proc:
 	nfs_fs_proc_exit();
-out6:
+err_nfsiod:
 	nfsiod_stop();
-out7:
+err_pernet:
 	unregister_pernet_subsys(&nfs_net_ops);
-out9:
+err_sysfs:
 	nfs_sysfs_exit();
-out10:
+err_keyring:
 	nfs_exit_keyring();
 	return err;
 }

-- 
2.55.0

