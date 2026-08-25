Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8759C3C1978;
	Tue, 25 Aug 2026 22:16:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787696163; cv=none; b=kiJFmhfXUv3rXy57ja6+PPF3WOyPZYGuhxxAq7po4vgeMWC/cgDq07O2KI956bSrVWP1iBJ5lR/3/UvrraCSrG+5VYb83cL/W2PbAU00xJ9vBHOM+s+TaUbTWCrhfzWgGvassidRIQ09VVllJL1MXa6GbicFNid8PZ1aFzCH4l0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787696163; c=relaxed/simple;
	bh=fK4pkggTgr/GElrO3rxQO1XcrT9ZojAb5qmiikH1sBw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=UAcNVq6NMGTyf+QZpB9POB0IHrPcEfHdtwUwG8S9yJVqz/NuNggYPINLYOAmpqndIyx9OuFLmVzElw+vFFPA4Rb6cnC36KT0g8SdGCl/hEJQ3Z6DDi0kNdrLz+ob4ukigk3wYiaucz+RGd96caR494ezmXOBzYhrYC92UYufBMY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=gC96cYpw; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=RA38Tfi/; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="gC96cYpw";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="RA38Tfi/"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailflow.stl.internal (Postfix) with ESMTP id 374251300170;
	Tue, 25 Aug 2026 18:16:00 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Tue, 25 Aug 2026 18:16:00 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1787696160;
	 x=1787703360; bh=rYYlq9O8ZKV8pwZJch2/bKtl/152Z5a/VSK8IJLw7bE=; b=
	gC96cYpwyw5gZtHDIyDhIlq6pRAYKjK1H3hXyvpBJqqPQupOt/8F2M946t4xWjoX
	FLARhrEvc1FauUM4jT2jDCQ+j0+7KlqPY49DuccUn6fRdb2p6Bb/uSEtGU9BDDX7
	XKKttKUau6YZNifWDo1VC/4KVm3uje2j+ZpyvqYXNcke9OSTIgD+tV6TkmRxM/1A
	8Rzvg34QdbJdtM26v8AzYIumx/c5LWlOPNsaqqWLgL/3GJV6LLcMLaf5C4CixLJx
	V5mdIS4EJ1IT9HPa7zriX3B7f/N+tUFW34cgrVSdXlV5FT5RgKvjV8IAdkjdOaJ9
	CIThAp6aojyfC+gyPzaTYw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1787696160; x=1787703360; bh=r
	YYlq9O8ZKV8pwZJch2/bKtl/152Z5a/VSK8IJLw7bE=; b=RA38Tfi/EZMCAjgM4
	nRt/D8Dackq1cFjR6fFseS4K/hg8q09S6jnmH8rsnKtnBbUwPyUlCskknsUMNbRO
	4zSzbXzlPF8u0B+IsgrkQw0eXXONz7CRW3pKdTyKWsY69iXHA9/W/1L6N/uJ/pIY
	oTuHEgmPsoKIciVCbqoYpzfgIOtbYs1wKanERib4hPuYdlShhcUFjnHbOW9QL287
	4nMp2MY4mlMszia8QXOpvuZi5bxXFa6dRVVy6j/amnIwc3LCr5utYGEbjyFOGn4p
	4E+/yPAlQRYY+GcVK3MMWSnIhkj3g2yApf0obhQnWVkqeRMdBycWj1KAarkBLzs5
	h1SDg==
X-ME-Sender: <xms:HxSOanWOTPDuUI4mmDQZA5ibJAruw_aSm4Q9pKh-2tyEOkxcsv5UhA>
    <xme:HxSOaqnWTVSpZhjGH-82iUI5IyNBeNE_U48wQUwfcukGw2iDUOBk0XOl8Vf7w8orZ
    gjJi8xRq9dCvo9dChKK7nLFY7utFwjHDtxBTdYwrSx6pQtp>
X-ME-Received: <xmr:HxSOaqCOlBQmsVrlVYtl9aTvIdstXcnWPEz41Z_udMEReM6rlasfmLS2eL4uSmFnYkaS9VNj0BNR-5_7JvR_ke7LbANF46U>
X-ME-Proxy-Cause: dmFkZTFZyCPQuUwX0w0Z5hHkugwPAowg8ZqRL0EUJUZiPtXvJZRipsV2j6GBoH6/2TolcI
    pIaDSXfa9UL+P1e7YKejjhDTypimUgVJWoibsJ08J+UNxZEAN2M0rOKL/X2wAaG6VdROGH
    2js0dJSUyrM5O8KgDYoSJa8xImUdoiHPExG98WcYEBg60nxF8P79mFkDGnnVr4BQbxlwj1
    PAe2OlHy/75wfPm0Pmi7hlaD4pY0uUf78uU2ncPd1qs8u2hWhVIjcVVzgLy9cfnBm8i5PC
    k2pldhiFO3LmqWOFjSIfTkKphRFaKcy4gfk1PpVptC5Un0yBMNfjnnvXMkLw/Gt5SLS8Kw
    UDx78Tb0LoOerx05v1pd9d5gBvtcuLk4VuQ+QNrNBkSK/AJ29mtbCFILa7XNk9+TgsMV7r
    Q3fGEghRLGZ42/wRjciEeK42uqIUIF8/SAIb8k6TsOIbzqwtOCqqgDpT8rmDTwZu8l7Zte
    lyKnRkUwAHtCHh2ptzOqWy10BLsA6Xn9BXIgTtujnbH7SpqcBD6cqopruCaaJuvsy0Bmq6
    0Z2SnpUHkvu/F+dkDC14qVxluXp1ISRw0KfPNZiTyFTXTQpa3Ryy25Dh0mxUJl4kMRkJm7
    EC+W1K855jLBlOqNQ9Io/kvsu6A27+mp+MPIapFs6OY+9aVnUCpH1bBADaLA
X-ME-Proxy: <xmx:HxSOav-LLXY99y0iZd8Hfiss4kv90JIJhWFyDQ7E2TLl2TZbO3TLcA>
    <xmx:IBSOasTbML5D_cmh7nl0_44D0EufzzSJCDnW3ScSZiMykcZeJ4Nc5w>
    <xmx:IBSOal7Zkcn1IA4klc_0v42-5vFs3w7J9rdnn9fQpAxJ7Ddh_AY0dQ>
    <xmx:IBSOalpNVutBAvBWvZJkq9PB1Z_E4VVLonZywHIPmND956Lxi2FWFQ>
    <xmx:IBSOaj-Cf0NXjzssWbYBVDMqbuEF9P2mHXwvr25PGGe-R19d8EjeeS35>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 18:15:54 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Ian Kent <raven@themaw.net>,
	Chuck Lever <cel@kernel.org>,
	Jake Edge <jake@lwn.net>,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	Jan Harkes <jaharkes@cs.cmu.edu>,
	coda@cs.cmu.edu,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Miklos Szeredi <mszeredi@redhat.com>
Cc: autofs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	ceph-devel@vger.kernel.org,
	codalist@coda.cs.cmu.edu,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v3 02/11] autofs: change positive_after() so it takes d_lock rather than the caller
Date: Wed, 26 Aug 2026 08:06:19 +1000
Message-ID: <20260825221459.966875-3-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260825221459.966875-1-neilb@ownmail.net>
References: <20260825221459.966875-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Moving the d_lock from caller to callee simplifies the code.

The only non-trivial code that is no longer locked is
		parent = p->d_parent;
and as autofs doesn't support rename, ->d_parent is stable
and this doesn't need to be protected.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/autofs/expire.c | 10 +++-------
 1 file changed, 3 insertions(+), 7 deletions(-)

diff --git a/fs/autofs/expire.c b/fs/autofs/expire.c
index 5c2d459e1e48..bc2be7428158 100644
--- a/fs/autofs/expire.c
+++ b/fs/autofs/expire.c
@@ -70,9 +70,9 @@ static int autofs_mount_busy(struct vfsmount *mnt,
 	return status;
 }
 
-/* p->d_lock held */
 static struct dentry *positive_after(struct dentry *p, struct dentry *child)
 {
+	spin_lock(&p->d_lock);
 	child = child ? d_next_sibling(child) : d_first_child(p);
 
 	hlist_for_each_entry_from(child, d_sib) {
@@ -80,10 +80,12 @@ static struct dentry *positive_after(struct dentry *p, struct dentry *child)
 		if (simple_positive(child)) {
 			dget_dlock(child);
 			spin_unlock(&child->d_lock);
+			spin_unlock(&p->d_lock);
 			return child;
 		}
 		spin_unlock(&child->d_lock);
 	}
+	spin_unlock(&p->d_lock);
 
 	return NULL;
 }
@@ -98,9 +100,7 @@ static struct dentry *get_next_positive_subdir(struct dentry *prev,
 	struct dentry *q;
 
 	spin_lock(&sbi->lookup_lock);
-	spin_lock(&root->d_lock);
 	q = positive_after(root, prev);
-	spin_unlock(&root->d_lock);
 	spin_unlock(&sbi->lookup_lock);
 	dput(prev);
 	return q;
@@ -119,7 +119,6 @@ static struct dentry *get_next_positive_dentry(struct dentry *prev,
 		return dget(root);
 
 	spin_lock(&sbi->lookup_lock);
-	spin_lock(&p->d_lock);
 	while (1) {
 		struct dentry *parent;
 
@@ -127,12 +126,9 @@ static struct dentry *get_next_positive_dentry(struct dentry *prev,
 		if (ret || p == root)
 			break;
 		parent = p->d_parent;
-		spin_unlock(&p->d_lock);
-		spin_lock(&parent->d_lock);
 		d = p;
 		p = parent;
 	}
-	spin_unlock(&p->d_lock);
 	spin_unlock(&sbi->lookup_lock);
 	dput(prev);
 	return ret;
-- 
2.50.0.107.gf914562f5916.dirty

