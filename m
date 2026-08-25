Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BCBEC496914;
	Tue, 25 Aug 2026 22:16:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787696172; cv=none; b=uF5ty1TyXqJ6HyvjODCbnsQkG6P0X2RlrFSUW42oReI03QN3xmKdmXklQW5aWwY3dJXtc+OMBcNTpGZnzDhkI5Z84H/Or1Wiihr2xewUo+bwv1Cqk2nTNXfU1xQ9Mdr/amTfxn2ZF8XP9QECCwyLAsO279b4LRzDL9i5ueGZE7s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787696172; c=relaxed/simple;
	bh=yIHtNJ55MhE2MaPIfXvzHiwBMs0J+NWpXiu+PMzC4oQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=M/XyRiulyJH7ypzhzjALG8+h0Cf+xqA28EkgyBSKpwu3xyuDE1+l+b4F1OZD3PIxK4xQEIr1KXdnyNyn9xoUEJaWS/5SKMZDF8xTFeX+iTXjYR6AH1dSUT0C/rNFPPdpAirFza4MeIjLu+0Db4bPnKOvGySawVF/9+gymPTSGlQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Qc1mAlMd; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Dn3CPRJb; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Qc1mAlMd";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Dn3CPRJb"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailflow.stl.internal (Postfix) with ESMTP id 57038130017A;
	Tue, 25 Aug 2026 18:16:09 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Tue, 25 Aug 2026 18:16:09 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1787696169;
	 x=1787703369; bh=QBxhcF/9xx0fJVzCRbVatWLSoovuhY6RZpsb7+BVY1I=; b=
	Qc1mAlMd5IaIWN3dP6CN1WK1l6E6INgVITrFBuVLiKxXSAE9cE0moT9cRNwk8mcJ
	t31yE7l1Ip8TaNx0UumKBiP9vzapL4EaE8+eUsB3iJ9wBPgJBU606xpYdCx2PC/d
	Yq9pomzsj3c8006YPA8WprD6sLIsS+xYA+FBXSTRhDvD/wTLT29KacwRaSmRy6/c
	l5Kk6+suPdMiCSFYgdeZ0QCQsCXWTgunJmyuZcmv7d8A1Bd0rFz4fVmGKUTwIolY
	J/yQw7D9430RGymy4k0FtaFefYDDntPK/MBreCV3LErhxZf+dNLj63URdgC47uRo
	3lWyFPtEyCB7TLxNotJdlg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1787696169; x=1787703369; bh=Q
	BxhcF/9xx0fJVzCRbVatWLSoovuhY6RZpsb7+BVY1I=; b=Dn3CPRJbdsYQIDuwb
	/CNxBZ6k5sV5a9vt20sEmXGJg0eb3NMpbOE51s2MXNnmZYbJTFXojWYhY/q80By5
	I2tjAOfvtlJAdcH4FUGYQwQD1z5zLQvaNONzWvlhE2szDGEzT6xaaOOiupN4GhK9
	HF0TSkZPDZlfl6ylezFo0VOza4v3XYhvn4ZtS1xcTsNBsRkybYlU9TAqWmwsrW9G
	a8h5enkX0QCJ2a6cLkhD1Sshx7iHv5cnL0IO/ZbLqI2ukEDnftzA0dfThi+9xJ2p
	4EuuKJY9HbHzcfJdYGZsFcvguSlnwffFEUEFNefyyfbDh6/VAsR9CTPB3x1K03A2
	IIsow==
X-ME-Sender: <xms:KRSOakkvNfr8r667E9bQwO1jmFiMVMcdEDbVhrolC5sUf9sH9eBzTQ>
    <xme:KRSOau3ISKj8yVf1s1WPQ_sSo133VQaytxhuLYOZaLkUvI5wmvShzgY34l1Y6de-a
    jNnTE1_H5xR61OyJPC7VPJLrE1_JQuxSfAxMkC9lHnwzYA>
X-ME-Received: <xmr:KRSOapTNxpr44XvOn8k7o3JKuq2GSpMG9vNfmXaTKUL4r3hXoJf9Uan1QaBSZFGHOFL3Uan9coqstN6FN7SElk35GikZSZg>
X-ME-Proxy-Cause: dmFkZTEp9gD1tNJOvQDhtypWMDariy1lQZzyPCbTbVWnxI6bdpy2XSc1MIE8cjy3IG5prk
    7eXXKQ1+AzawqwVafFnkSQVq3nCftIMNELyf+GmUuKYTB18VwsCSA8x1h9bnf7yYLuIe9s
    5/khboCUq8wQeamlgoG70tpcU6O9vPbdw1ApHAaCVlIPXTbjfAhkfSz569KefjxusIkwqg
    JSlqRrJD0X07dcItAiTmSeecqH/sccyG90oRqGAhsyPnna+gbbNa6u+OTNC0+oiLPN9Hl5
    FMsl0L+8C6nVE/5D5EiMbFYLm13buMsfddxLmGjqhI2v2n1p1xvAzA+rwFt4OQHM6ek8GL
    e9rrbDQ14nKf3dquBu2TzJSJilvbxCdNj7is/ITM7c8Dt4h8Xt30EdKD0bln2z5Q6Bo7tP
    J/yt0PQNWAcTycIzGri4Ckg4gyf3nsXROSzyRB6hxabcACL2pxZYIysh9xoqVx4y6VeDub
    oMOn3VbdtqX8NOHz+c8DzaD3AL7QbChk8Ufbi56osxVyU7AKVKyZsJ6xm091Qq12IgiMHM
    qs/JW2I3jJ3jB1PsMfg6Xbv/P/3VYTs0YSfV4blY0jyOZmptQ34BMrAWNmNRPC7uJW8AeZ
    lPdZ5gohfpRZQMb4nBDWEsR3mqJhdf6Qc+PrmgO3d8Pg5iYGnQsrNOmcldNQ
X-ME-Proxy: <xmx:KRSOauOREV9KICs78J360Y3nWSDB9nJvqXR5jvvwNJ1eqjZZKcfU9A>
    <xmx:KRSOatg1wuoi3USuhdjCqViwxXdsUDa6HYcUoSrlQef-4c5gmxnE5w>
    <xmx:KRSOauIr07yQqMPO_BYxZa86Nz97iZWwfKamP3Niq3EIuFIO2Us3fw>
    <xmx:KRSOao4H-beqxl9dj3N2SNbd5hM_-udr8pepSwK7iUTPY5uyKmnQXg>
    <xmx:KRSOagPXOM2JLeSq4SB-QxZnyFTe2X7HNVm28UUC6_h44wd2gNNEW-K5>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 18:16:03 -0400 (EDT)
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
Subject: [PATCH v3 03/11] coda: don't take rcu_read_lock() in coda_flag_children()
Date: Wed, 26 Aug 2026 08:06:20 +1000
Message-ID: <20260825221459.966875-4-neilb@ownmail.net>
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

As described in Documentation/RCU/whatisRCU.rst sections on
rcu_read_lock() and rcu_read_unlock(), spinlocks prevent the RCU grace
period from ending so there is no need to call rcu_read_lock/unlock
inside a spinlock protected section of code.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/coda/cache.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/fs/coda/cache.c b/fs/coda/cache.c
index 245131296300..970f0022ec52 100644
--- a/fs/coda/cache.c
+++ b/fs/coda/cache.c
@@ -93,14 +93,12 @@ static void coda_flag_children(struct dentry *parent, int flag)
 	struct dentry *de;
 
 	spin_lock(&parent->d_lock);
-	rcu_read_lock();
 	hlist_for_each_entry(de, &parent->d_children, d_sib) {
 		struct inode *inode = d_inode_rcu(de);
 		/* don't know what to do with negative dentries */
 		if (inode)
 			coda_flag_inode(inode, flag);
 	}
-	rcu_read_unlock();
 	spin_unlock(&parent->d_lock);
 }
 
-- 
2.50.0.107.gf914562f5916.dirty

