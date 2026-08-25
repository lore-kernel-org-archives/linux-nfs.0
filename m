Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E367C495042;
	Tue, 25 Aug 2026 22:16:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787696220; cv=none; b=TcPNia5AY4Zr2+Dy06eeuoHvNNddhKTlFqOaVp7Bqjsfe+CeN8P6IrwbEdT9DJ6kUdY0anouRCvo1Rf7FcrqsTryBtK2O1Q4xI3h63G4x4Z3pRXC3bnEBC9AD63Nfwe2w4ffJgi807wnoJ/0yUlFWV1MtZ/x8ygXpd5EWhX4LwY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787696220; c=relaxed/simple;
	bh=HDxxbvnKL+ov/G4Gf+VV6/PKhBoJBh7leGj7TWH7J54=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=sob4nhG6qp3MiHAdfexfxn/rXuPAipLurP8kQ4pbsJTH1MLOEZTe6kDwJhmTeUeuMbtEhl0u+t2JTRJDD4UNGyCqSTtJfuS9u9g5gFw5IMNlERGrlv0zpV6/qifMpaKYuhoDjqTUga6MYyeQW44Q7GLA/h7JhykRYACwdE8pFps=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Oy9fjj9E; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=kHitmo0G; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Oy9fjj9E";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="kHitmo0G"
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailflow.stl.internal (Postfix) with ESMTP id 45AE91300170;
	Tue, 25 Aug 2026 18:16:56 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Tue, 25 Aug 2026 18:16:56 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1787696216;
	 x=1787703416; bh=L8BfRwSOcOjHJq96pMoI0xfny+sOYLUqv3Ul5GwElQ8=; b=
	Oy9fjj9EIB0jkZrxklcpsSo+77j4uQS1o0cjgjEToIB7zryYmr/8B/n/6sBHjrHw
	w1FkN4xrhPHNy2iRJSMxHkSAVasJrBLhJnqwEhMXM+PQjXih+9iNCSozXR3yr+uj
	lVaVgi7tx70jlzzylKqcQxIlYy8QnUk9RyzwHlYZ1r1xS8YIkC7SyrWviOI8PWc6
	9itkifvNpqQ56HIEJbf+GoHhbTR3uz6kL/qlyhZpxBfqNa1b1uSbAFZTVMlaq8xF
	MMw64J9EEtNrjxaB5IGPfXOWefRgCcELCLcWxkSuUUeHadhjO+y4jtKrRI0Cw4ie
	69eUAuGwMBhuNeYeA+vSbg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1787696216; x=1787703416; bh=L
	8BfRwSOcOjHJq96pMoI0xfny+sOYLUqv3Ul5GwElQ8=; b=kHitmo0GwUpMH+RBG
	JvGKXKPissVedHYjaTOK3+u10FOC/nP3q9P5ZOQJmne89fSi5Rt45nib/oNiW7Tc
	bXy6G4frSUom42f2WtC/X0t6A/9vEXfWTzolYCJBcD9uyKRBNw/YgxMRzA6TPviC
	PsHvuzCUIAadg9D+1RSw1MyOVn85z8s1ixN5B9jBWZVOC0QTJIsqyWQEOOF6YvPR
	Rwd3nlIUBG0czU7DRMZLHcg8568A+0z84UyuPJIwW1c7NwsjCRQqNuPaHmVanlJW
	rJ07gkLOOJ3OyrHxkDSoKoHf+2fTjbsNDVRb29dMuUlwXXror5qu7PqWFQgZfAQS
	DrZuA==
X-ME-Sender: <xms:VxSOakMEifzxvLekVOmzZGyeUkp6XmCL_-EuaMt_9FQj_YkL-p-3Hw>
    <xme:VxSOal8TyxkvQ6YJLnfi4U_L91YNsF1_hV-5NKIkZ5h-BUDta2JpQRmmmaCiU4asC
    2auSe6gIjywgZi-B8UddGRcDjV9lzJh8r9G4InooCVKU-rfYBc>
X-ME-Received: <xmr:VxSOah7sOntGB12GQhYRtb4-BoA9Ro4jlV93IaIsTXM1QLqGisQmoPAYVr4SjCVeprg1ECD5HlfZsiKnaDO5wk9LPXsBJt0>
X-ME-Proxy-Cause: dmFkZTE1D9RHiQxYEMTZM66ZwYWPXMa5da/YLC+asllp2LW/9AzO59nDbIWZ/WJDafUyFp
    uQaTnJVoM5zeNV7PU3Y5Sxe6sA3KXuzbkNtIeFEk21vnmQNZ++SlHK1xc12Wi6N9bKT3Nd
    l2Jew0OcpEW6pknEcsl3U5kWlcxIcGyDVCcdakxFha864vAOuxadUTtnPo9vV8kQZOtGh4
    t615j3/PJH3yhet8tW8bKj0XWaL55deZWQpLJVbikNK8UvNeSeZ0y75HchjkQdooZXWGuR
    agEorB2pRIG2wLJFguZ3GUkqAvVfWJvN2myN34TtgOMsQRUTFpr+RStZVbDkRTC4KoXuFx
    VeC8Yg3v+N0Nu5TlT9cE1lVrtJFrL+tSoJY4P52D+mb0qquFS+9pivvmbtGYac/xucfuf/
    qpdzgzefP3uqtuCh4QlwWbGkU4wI72E7VUrTS6wqxODDy0kNhRa8JvQr/afZMfJTUARPz0
    1E19LtPysBCYCtPA898nMtkWlRIOhKSNw5OSF417wBSn2QC9YtvWNF3iUwSGqPYhV9qIwn
    AX+g5MZcMvNieMDmRATaeCA/GbJKvm3tcXYwTO53NeeNpHHO1bxirjhWsf7y7sj20YbSbv
    HHYd8U+5bVzM6PeiGhPnDzCVE5owJos1zkpfCDt2LuMnv6bIN2Ck9Nm7vHJg
X-ME-Proxy: <xmx:VxSOaqWOKhfdL5QkSXk9jt_87gwaMl9gNkBwuKpJ2YwzyjLyD85owg>
    <xmx:VxSOanIgVP97-i-QG_r93Suns2Awe_xNLysvvYj9syHlNr9-LOnxDg>
    <xmx:VxSOanRrsmlq-C8IMzqOqF-nw1vu96gq_j_ZviJzrl74mWKNOjvhOg>
    <xmx:VxSOarhEvBzEiJbIRiQf7Gn66IrlSfBowMrRS_DBfQtzKk7ATgJRLw>
    <xmx:WBSOarWEYCIUYENU3P3KnxbIOtf6Mku8v1bXNq8Nb2CkYBFKUQdxBzV1>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 18:16:49 -0400 (EDT)
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
Subject: [PATCH v3 08/11] nfs: Don't hold i_lock while walking ->d_children list
Date: Wed, 26 Aug 2026 08:06:25 +1000
Message-ID: <20260825221459.966875-9-neilb@ownmail.net>
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

Instead of taking i_lock in nfs_clear_verifier_delegated(), take it only
when it is actually needed.
This means i_lock isn't held while testing the type S_IFMT of the inode,
but that cannot change so it doesn't matter.

In nfs_clear_verifier_file(), simply take i_lock for the whole function
while enumerating the aliases.

In nfs_clear_verifier_directory(), use d_find_alias() (which takes
i_lock) to find and get the one alias, then dput() it when we are done.

The import result here is that we don't hold any other spinlock when
walking the d_children list.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 748c8388c4f0..a5f6fa57fa39 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1469,6 +1469,7 @@ static void nfs_clear_verifier_file(struct inode *inode)
 	struct dentry *alias;
 	struct inode *dir;
 
+	guard(spinlock)(&inode->i_lock);
 	for_each_alias(alias, inode) {
 		spin_lock(&alias->d_lock);
 		dir = d_inode_rcu(alias->d_parent);
@@ -1485,10 +1486,9 @@ static void nfs_clear_verifier_directory(struct inode *dir)
 	struct dentry *dentry;
 	struct inode *inode;
 
-	if (hlist_empty(&dir->i_dentry))
+	this_parent = d_find_alias(dir);
+	if (!this_parent)
 		return;
-	this_parent =
-		hlist_entry(dir->i_dentry.first, struct dentry, d_alias);
 
 	spin_lock(&this_parent->d_lock);
 	nfs_unset_verifier_delegated(&this_parent->d_time);
@@ -1503,6 +1503,7 @@ static void nfs_clear_verifier_directory(struct inode *dir)
 		nfs_unset_verifier_delegated(&dentry->d_time);
 		spin_unlock(&dentry->d_lock);
 	}
+	dput(this_parent);
 }
 
 /**
@@ -1519,12 +1520,10 @@ void nfs_clear_verifier_delegated(struct inode *inode)
 {
 	if (!inode)
 		return;
-	spin_lock(&inode->i_lock);
 	if (S_ISREG(inode->i_mode))
 		nfs_clear_verifier_file(inode);
 	else if (S_ISDIR(inode->i_mode))
 		nfs_clear_verifier_directory(inode);
-	spin_unlock(&inode->i_lock);
 }
 EXPORT_SYMBOL_GPL(nfs_clear_verifier_delegated);
 #endif /* IS_ENABLED(CONFIG_NFS_V4) */
-- 
2.50.0.107.gf914562f5916.dirty

