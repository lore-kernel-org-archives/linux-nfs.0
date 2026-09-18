Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ED3C037A82E;
	Fri, 18 Sep 2026 14:05:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789740336; cv=none; b=GC3hpCa8KrZiH8oR0vp0VF0Dldj6P4UxwJtU69dAimnFBR1EGHOtV9rlv5U9O9g2uNsQcYnKL8w4hC3MUIsYlERlDOZRwzwAYAX4u8vypusejq6AUNigGJLX/+SyieI06wLY4aOTbGGazWIMybitAL8MbmshUW04i1tel0zi4B0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789740336; c=relaxed/simple;
	bh=FLfziQZLPnu6y3z2fWxofxw5KtIfaVhBmkfb5/S3Xb4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=p+od3P3gvMpB3W2i4HL4+Ov1o7Z/ia3GbkPs4X5AxQ/Jv5op4XkMZmjrh1+QMGB/wRjfWiTuAmqE6vnqP9mY2FxZoOO59HtKJd5tlP8fQMlXbK/ytzfUYN0aUYa6IlROkSICu8W967+P0LUHpkQ2BVyW9B/oLuc8I18CFX4VHl0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=S/cC6A/n; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="S/cC6A/n"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 458A91F00898;
	Fri, 18 Sep 2026 14:05:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789740334;
	bh=PVvkiHtxln9Mn3ExYwHOY9OExYSN010VAj8STzkHraI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=S/cC6A/nrJTs7aq8JRYZFwVl4gHOFYAWPCPLYHiA6Wc7K+wFSi1NX0yPLlj1BBr15
	 hb3ztg93GxURfbxSsdrps3RPG/jUdORYG4TE699sPOA2koYSuqa/b7LwtF5FU3rEJW
	 xwFaMWsPei/6zTJyxRejPUBhyP2DVIb9wLUg0KlBitRx3t4ykfigfVzL83B+rjVaKv
	 pHA8YJ0U3H1PPB9TwEpoD8ZaFTVQeyzNRdcfpxPZBrM2QtwfHvgcD48b11jeBwFllY
	 x/oWIgeDrRXucBbAhgsQPFz7+qSkcxaInq9CO5PIqnYY95Z+KapoEH6f+KHSVS2QkV
	 UjWwxBXsJKyYw==
From: Chuck Lever <cel@kernel.org>
Date: Fri, 18 Sep 2026 10:05:16 -0400
Subject: [PATCH RFC 1/5] NFS: name the init_nfs_fs() error labels
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260918-nfs-mtls-identity-v1-1-197e568d78a7@kernel.org>
References: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
In-Reply-To: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
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
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqrUUr3M/4BLomPV4E3P3yrqEN5jG1Qx8Cen9H5
 juILwG+Az6JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaq1FKwAKCRAzarMzb2Z/
 l2rlD/45snVh7EZMYqnPhroRSf4vZKy83RJy9xI5qwJ59LuQXKP121Y4pgEhJk3KNr6Y2C/sKVz
 q8hGXJ4ehx/N+61v7tMpdRcuclUkL+OeRBJS+oTj2cXV/fDlBtaGk2GEKWhQgpqB5KgZ31ibcz+
 km1atmfnsA9igllsEVIp1qfqcQqq3z7BJTh2BkmogW7HElx/kZ/3clpAmw1ixS9/Fb6B0lIVOgZ
 z1W8p1k8QBQndFCUIRymEeU+TJIl8sFgJPff1nNM9CRZ7ydhYBBDdOWNaOFatKskpFcuIh+AQ0f
 Yz1TbhGd273O7dddbx6rdOB5keVSj4sTVqhEmRz/OdzHeg/S9+ky//X6fri1xAHRNfA7bNvyWAI
 8ZgKCcSGuI4J1yQkKsGKlm2iM2MoCX1l5S02ubOFW4bNzWX4s39mQUoGs/0CQg5gy0ZhJrb2J1B
 K3vA0/Z7xcW9ilHEApnNurBjvUJkRcsSPJQpY8g7QQyOhZik/77tDge0vrmAWjhzNsRChXfyYnO
 p7m//WAnndjv7y9epVOXse4an6ckXERHCSKRN+40uu0XSh2RQH/u72mmqMTM6dj1e5CFNmDw/Bn
 2ATYdFSejRmlNNzd05I195cX9PN1KhbI0mYcvkYZnb+tGEdZ5mCiRVTKKDXK+KTF3MsGRxJ2i1J
 1/EjI008SgURIiA==
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

