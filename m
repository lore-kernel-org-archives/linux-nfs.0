Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9E73546C821;
	Tue,  6 Oct 2026 15:24:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791300272; cv=none; b=lcNyUs1RX6m1XvD2FF3BLk+URWSXnwbwFiE6KVRYSWVSNQLeT1bqr+eqcVFOJBPxuM/3hdKPNZnnDVb8KY6XOVESZWDEiFaufb8NSvLdxyMuV2y2nqPdysp8x5kY1kKozirhs1GGa9gjmUiih5Nq84pjIWD4da1soyzFqaQ6Hxs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791300272; c=relaxed/simple;
	bh=FLfziQZLPnu6y3z2fWxofxw5KtIfaVhBmkfb5/S3Xb4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=iZL1pbyNGFKViU6GA8dU2zdXLgvQYQ5hi2wXKndFQispIj0tNKt9ziprWJZSxuXYMgEfKPkd+5VOLv1vsyUXNK6LEyIUxNZbuhN7PJ2wLH8jqbg+WorSf8FqRe9r3n0s6M76lmk5Wrces1hOzr8EB0dLbnYVCum+gFH9F/RjXjM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=N1sU4RoP; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="N1sU4RoP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9636D1F0089C;
	Tue,  6 Oct 2026 15:24:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791300270;
	bh=PVvkiHtxln9Mn3ExYwHOY9OExYSN010VAj8STzkHraI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=N1sU4RoPVLpu9rsKw8RkFOxgwoJSNA3WqTUK/wPxHoAdizPqCusscolEeKXO4COw4
	 xlBIx68fBBZxApunbKJKSQ7afYlO1DFF86F03aUfSHm9kiBy0JYny9cyplH9FEy4s9
	 SXtbNFOtKcSRvxIxi1stI/57ov7E5vnt6PVEhYMDHqxGrs6NsOr3upENKGlAUJPG+i
	 MVcw+n21dVrhAuENXY49G1gYAcJl/xTgDDtS3yUizoJ+75aQHinUMnriirDwSIFv0Z
	 gqQcms0oN41FzPVCiUfjQeXhLlwmldEDFM9Sq8JAGyllhdOP+TD2DgK6g1in64xwdE
	 M5EtvSB2Rb+rA==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 06 Oct 2026 11:24:02 -0400
Subject: [PATCH RFC v3 1/5] NFS: name the init_nfs_fs() error labels
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261006-nfs-mtls-identity-v3-1-58a69fb107cc@kernel.org>
References: <20261006-nfs-mtls-identity-v3-0-58a69fb107cc@kernel.org>
In-Reply-To: <20261006-nfs-mtls-identity-v3-0-58a69fb107cc@kernel.org>
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
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqxRKqjJYzq8z155Qz9eW2KzYfr33fKWjWGXrC+
 z/nOWKZTeeJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCasUSqgAKCRAzarMzb2Z/
 l43mD/9Gcicn6SdVyF5GBt06A9c7IdQCIzYrelBebc4k3LSz+vljg9SUw2LtISKuaJkcI3NiCx4
 l9ou/If83HzAOsQecblM9OA01qjVSKQCVoo4iW7J1VcRhdcyjUV+b9iQxIsF9iLr9kXVw6byHz1
 Y0mc03aVrWtjEgIaOoXbHdHG8/1P1HJhc7NfF7h3N7SH+YR4zMdiWLXpT0FxjU/hPk7hu/ojxJm
 w8Z7ftsXgSseQ3HIkaiS8WqFk8woDQfA3+CKBpXM/4zcJvxsOpDz5rvjGTq6zg+IRykePKkYGi/
 catn02IXTPkSuXPozGmC3KovWQLL9gDXBreS8JxX4CX4wawFqcVl8+1qoN/aUUCm0jJzB0zHZaG
 EPm/7yQgirg7+awTv/kdMXCOTUG43rU/gVkGzGRgk46LWaC8635sKIQ4riNl2XABfq065GobcZL
 k7lxrvclkzPpmMKXBfSJ5WQ0JJCs78EHfMkaQyq2Gw3sJs525JAoWAEspN2fe9b08xZzhINuc+w
 xN/k6ao9q3rT7AR0xCs2te5wYqNSR0X0LFJCFGcJudH6uADQ/kPWiKrJr99GMUbUE5vZZ1MTSUe
 UgUuRwVE+eod3Idno0K1ImOc4/OMN3TyhVkkcJ21Muqh70x3EZ3LhmN4BTtH/fXbArxu2DNQNbG
 d3hpvHZMgifW17Q==
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

