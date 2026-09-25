Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 72BD74968E0;
	Fri, 25 Sep 2026 19:16:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790363800; cv=none; b=e/eNY5a4jzb0PNioJqC8+yUHBQQVpGs71qtpKRzEMKqGYN0//bZF+9VqOAvEWUvn7MTq6HPVDeVChHTksNKfpg6lILcQ/Dev+cp/LSqh4sWGFBh/eYZXcN9SFICz77xOmHLbTl8ZtuZtwTMUjc3bjHKE+edP2h+g0yE63cSN6QM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790363800; c=relaxed/simple;
	bh=FLfziQZLPnu6y3z2fWxofxw5KtIfaVhBmkfb5/S3Xb4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=MV5rIR5EjuziV/2pkzIKt5RkJdwI6OKEJbywZXdyRH05PK/wpFIVE8zR2kSEPbKcM//Lvg7M/c+S2c1UFN7rL9jdBiNP9f61+hS+hs0EqN4/J6dnx7HG4xmgKbl7tktyNVWDR8MTKM531i0oITFedgya0ozUGYTZ72BV9DMWe4I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iE36D90G; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iE36D90G"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CBF0D1F0089A;
	Fri, 25 Sep 2026 19:16:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790363799;
	bh=PVvkiHtxln9Mn3ExYwHOY9OExYSN010VAj8STzkHraI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=iE36D90GkOQ5VQGjlHSbA4qR6HwAHSYwNEJfndOmnlVrSkKpX0PHhlHO8qcUpL3Ay
	 1FJiyWit5m2jwQSEEVNSQe5o3aJ+KGzzixFVbUlpqxCc9vVnPiVJQSzMYm3hns32ME
	 MsjDdP8owOfhfjeBh6sHkmgdIMTykcDtZtcY3Vpm8eVDr8aN1/6HSe6sZLc93GkkGO
	 H2nGS4dqasoWBrIQGqCBD5LgloPGxjwmD8kfxahqg8qVM7Me3VuaE6dX0T6DgqDvQS
	 nFZcDTaFCOfgz/6SUs+BBWuOFPebxIJU/cZzW6xXHklKERXXCl5OtrP6VTLG0uYmte
	 mTTOMGeqqq59Q==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 25 Sep 2026 15:16:23 -0400
Subject: [PATCH RFC v2 1/5] NFS: name the init_nfs_fs() error labels
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260925-nfs-mtls-identity-v2-1-aa3ad17dd6c8@kernel.org>
References: <20260925-nfs-mtls-identity-v2-0-aa3ad17dd6c8@kernel.org>
In-Reply-To: <20260925-nfs-mtls-identity-v2-0-aa3ad17dd6c8@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 "David S. Miller" <davem@davemloft.net>, Eric Dumazet <edumazet@google.com>, 
 Jakub Kicinski <kuba@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, Jonathan Corbet <corbet@lwn.net>, 
 Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>, 
 Christian Brauner <brauner@kernel.org>, David Howells <dhowells@redhat.com>, 
 Sagi Grimberg <sagi@grimberg.me>
Cc: linux-nfs@vger.kernel.org, keyrings@vger.kernel.org, 
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org, 
 linux-doc@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2220; i=cel@kernel.org;
 h=from:subject:message-id; bh=FLfziQZLPnu6y3z2fWxofxw5KtIfaVhBmkfb5/S3Xb4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqtsiTMIr2nQ+5Qn4x+cy35dFtl0w5uHHSz8rCQ
 4wJe8xoNIuJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCarbIkwAKCRAzarMzb2Z/
 lwn9EACAYEGXPBIGuSAJa2ROFKDYJMJ5jVkihh+fED8Ij92KV/oFfV4rhtjKQwsNxexuhNC7OH/
 41O5peAuu+EQdeUD9ULtxXHnj7o98pUnOSMiThaQbGdrsTBAL6Dbqyj9vzxU84CNk/FyZsXunn1
 mR7f2iAJN221TJjWZ+a0YTnshMJp5qdWazE8cNplr9V8PttxVsFBd9ZkuEtojbbWE2BUGXKcNM3
 pCbBgX0+yk8/OGdaVTe1vVNQS75LuiAjawfyl0men4L3JWyuOjr1CxuQIEXRkQKlZdObiKZOf8z
 2E+w83ZlqdRHnPDdvqiUL/pU9AZ2smNrJh2PYyzL6jqMV1cnrCl+cfZj35T7gvCPL8FVGyEQtJm
 xAinRgpnV38Jh6/gH6IVxMevPCiD0vPSvKpT3k1NDf6SmzS0YaO870ojfboBOy0mf/QlVdgMpL2
 HNrLm6iZRW74TnGej2ndLoJjBVyg0fsGzi9hAeU41LPkRkb31WcgU5vWMb1PlvZoEtvAy7z/vjI
 +VJNWzk/Ujc7m2/vhfTR0PxxMS2fM3pxV54ldYNn0rvS4t1ngbLmKdCcUzhLAB0Tw0quIdv1fTe
 Dqneu7cI6ZzzRZLlvQnguRDmJrAXi1zVAYsoYotKDmlOZ69FiRAz5OmFcVzEXLtUtyxUN8qElAm
 Bn7jTfvTzcdSDUw==
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

