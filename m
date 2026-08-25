Received: from flow-b8-smtp.messagingengine.com (flow-b8-smtp.messagingengine.com [202.12.124.143])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D61CA490BE9;
	Tue, 25 Aug 2026 22:16:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.143
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787696182; cv=none; b=IHDA1MpHErUXrNeiL67D/vpc9sGQeUPdYchONtwAKgi6jLmhMbWs/AXe392jikBn1F/3VCyZz+WeqEuczxBmMwa5XvjaZTW86UILWdFZWFKhdKhjGPlVFOKBha6sIGcRaoqupvvYqfRjX9H84Gcgw3nbJfuOfzkmLFHG4DEBX0k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787696182; c=relaxed/simple;
	bh=5KrhxkfmhuYCFp8k0XOx8NDcmyJfXGghu8RtKBBMvWQ=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jKfFahblhT86Xf0gD4dIgEGMU3hOosVk8yg11eQPc2/Xu7Iq2+oi5EuctH9bL76yo7wFPlAT19HMbypS31C80BP66xhWy7DmXvuVi+SMYkgDM4Ug8N78H1Np1qzZvJMY2oaQADUUXgpiArymhgOnIDnpKmRHdYUfjmviBc2Lm50=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=LR0tMSb7; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=YYPKGSSR; arc=none smtp.client-ip=202.12.124.143
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="LR0tMSb7";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="YYPKGSSR"
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailflow.stl.internal (Postfix) with ESMTP id A048E1300170;
	Tue, 25 Aug 2026 18:16:18 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-12.internal (MEProxy); Tue, 25 Aug 2026 18:16:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm3; t=1787696178;
	 x=1787703378; bh=d8jSa3AAjciJsnljgFzbEoiUesnCHMntledjgHsqTTk=; b=
	LR0tMSb7OUQhawgtMd3vuUW/p1G2sGx4fH9oDpB+JfjSP2KT1qJVwdmvKScBVrXm
	XlSHxczcAg0q5eRO1emFv6ff6if4mpgwI8vQWUC7sDdkTOSJ19FxVwt3ngnV/JLx
	8SkfrwhLMaxPCQ+sBREWxy4VALj9gC3eKd+TY+DvyJCzEI0u+YCwGcDm3I0NYFHj
	Pfg+ZtBgroTg+5ebQFRW3F98dCK0p7K4uZ/ShS+MQ/pitXzgAHh1f92rHYt2lhDV
	WGOWWJPTgKaQMH6Offkveu1oJ1v3wVp2cKGEmQ8UEs0979BJh03SAW+HBcaLSt6d
	pwpLobogqSkU51Db13URgQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm3; t=1787696178; x=1787703378; bh=d
	8jSa3AAjciJsnljgFzbEoiUesnCHMntledjgHsqTTk=; b=YYPKGSSRWGOfY5Lrq
	pE8yuMnoSS/eb6KuZ1MQLGwCc45g1mdDII7dc/8dCQEefJ3+DoYacnmNZ5lHx1CQ
	ePdCJrM25AGEWS281LEKEamzCCLX6mNvt8wSI47r7ZLl5uawBxAzV07S1dS7rd9x
	9sI70zWssKaLJmESDmWtaS1nTq2ujGD4tix4MOgCK8toGy0Qpz1WxHNTVGLrg7Yw
	mJHcdJ1iv1hm4TZjMf1zlcZS6TQFwerqbPf09MFF9qfR08en2rIdsOm2P8C1rwKl
	3/byMzEyy9Wtlm3ONo+LkwpI5Fppw52AKJXgm0Yg2yKRHNKrMZZp6xVMhOh7d6dH
	by/NA==
X-ME-Sender: <xms:MhSOaq--bofTpR9Ziz17HEaLMAhvkQg-pz_1GPkQ8DttSNtuqKe6Kg>
    <xme:MhSOalt7qCZ6ym6CBHpr1JUtu_F2lu4Nbq2Yy-E_InsnvpeG6w2spPJNUPFtUsXGc
    AaPik92G5E4tE3cn4ERWAwacx2B9He4Ly4mIdVkdtBC1x8KXw>
X-ME-Received: <xmr:MhSOamqaPEVaYCZ470tJXAi52DGtryW5Fnqxi3lZDWBleY_oqapcDqX3xT0pxxmv9v9YzDyAwj6zya1G-WZ7RWXo-6e5TdE>
X-ME-Proxy-Cause: dmFkZTEp9gD1tNJOvQDhtypWMDariy1lQZzyPCbTbVWnxI6bdpy2XSc1MIE8cjy3IG5prk
    7eXXKQ1+AzawqwVafFnkSQVq3nCftIMNELyf+GmUuKYTB18VwsCSA8x1h9bnf7yYLuIe9s
    5/khboCUq8wQeamlgoG70tpcU6O9vPbdw1ApHAaCVlIPXTbjfAhkfSz569KefjxusIkwqg
    JSlqRrJD0X07dcItAiTmSeecqH/sccyG90oRqGAhsyPnna+gbbNa6u+OTNC0+oiLPN9Hl5
    FMsl0L+8C6nVE/5D5EiMbFYLm13buMsfddxLmGjqhI2v2n1p1xvAzA+rwFt4OQHM6ek8uH
    U0kWh0PSng0n/7kgd88VBnv4FmmolfwPYxMoLALKFpD9myUJvzhPG5+NrIzXHlw55S5gMS
    RPhsBuJfGgrlpos1CAwVtuIqakLJQGIyvDmYd91NL0MWNGZF4SJrdWA+pjV/B92AxsD6cJ
    pGkpPmIvE9kVMx+IAmePgwcm8z+0nmkdkP9GBkvl2GagzTWTXouRizUopXo6IINaOlpY7w
    1BRIqDp/mN38b+Cr8ns3obBbArHjI4LWw6O2DjP82vhfPXPIY1R2DF8F+E3SiI7k2Xz490
    UUUZOOl17nqMYhju8F6CGQfwTtLydYiQ4xS3EUHQw8fzTqvuT85j+MCSp15g
X-ME-Proxy: <xmx:MhSOagENijKtlxWWrVWgDd9dIBfByEGeDOruYn3qXR226pNMqfu0jQ>
    <xmx:MhSOap6VU7fbg-xLyXpyLODOx-k5iCBXZlYgScBz5LHY7Y2vFk9pgw>
    <xmx:MhSOajDXTHGj7ZscLia6HXLM5Ced-HvERI31PQd-bYwJtZYy7NLwEw>
    <xmx:MhSOasQLl2-1XOVWjEu6DugBDTQBB5d6ouQx4hsEEiej6pXqUGBuNA>
    <xmx:MhSOaisRY6d22vrEQjNw4dTF1j0zWqMYihE5EJjoSbj1Sss-sIyzJQc3>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 25 Aug 2026 18:16:12 -0400 (EDT)
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
Subject: [PATCH v3 04/11] nfs: separate locked regions in nfs_clear_verifier_directory()
Date: Wed, 26 Aug 2026 08:06:21 +1000
Message-ID: <20260825221459.966875-5-neilb@ownmail.net>
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

nfs_clear_verifier_directory() locks the dir to call
  nfs_unset_verifier_delegated()
and also to walk the d_children list.
These are two separate needs and they don't need to both
be in the same locked region.

Subsequent patches will use a helper for walking the d_children list and
that helper may drop the lock temporarily.  To simplify this transition,
split the locked range by dropping and retaking the lock between to make
two separate locked regions.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 36f2e8588922..ef708bbb8acc 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1492,6 +1492,9 @@ static void nfs_clear_verifier_directory(struct inode *dir)
 
 	spin_lock(&this_parent->d_lock);
 	nfs_unset_verifier_delegated(&this_parent->d_time);
+	spin_unlock(&this_parent->d_lock);
+
+	spin_lock(&this_parent->d_lock);
 	dentry = d_first_child(this_parent);
 	hlist_for_each_entry_from(dentry, d_sib) {
 		if (unlikely(dentry->d_flags & DCACHE_DENTRY_CURSOR))
-- 
2.50.0.107.gf914562f5916.dirty

