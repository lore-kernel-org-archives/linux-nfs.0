Received: from fout-a7-smtp.messagingengine.com (fout-a7-smtp.messagingengine.com [103.168.172.150])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 32CD93822A5;
	Mon,  1 Jun 2026 07:02:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.150
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780297328; cv=none; b=sSJ8ruwZ48XDjzabPmlRPAEJVy77vZHqpcyLHcR6pGOrN4S7tTlVd9UftfS6i6uOTnV8fuDM+W8yPDLYjF60c2NLrjjgP+j9cS3svIRGrWWq3rlOlNenqRrZ9h6PxK38GnR5nKLOVJcGkX6MMae9/qsSKdQdvsTry4j1aL21nws=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780297328; c=relaxed/simple;
	bh=FmtSz0obzMxnU2S7gO7wlb4OG+5oBXxfhOBi6UWbNGc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=CU4plFbABpdcOlLhUkYxzFxAihM9qlYHHdi3a/6vHcR2RwUqdBBnyxG6qJ8tAl2DVQkGQ/N/VkggDxHq/cZhHZMiVkhkN1E4VjmJlnd+AvJ5x5pd5B6k7RVQQJ5JEXc1WVC+WLos6PQy3H09EgYapihwP+m7qlxZyU1QryC4HCk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=dRjJ7h6e; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Gd87d5hT; arc=none smtp.client-ip=103.168.172.150
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="dRjJ7h6e";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Gd87d5hT"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.phl.internal (Postfix) with ESMTP id 6A694EC01B5;
	Mon,  1 Jun 2026 03:02:06 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Mon, 01 Jun 2026 03:02:06 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1780297326;
	 x=1780383726; bh=L0vZWHvmvipAl9d2tQWqJdTC+Ir4+F79S57ejDJ580Y=; b=
	dRjJ7h6eoNwqgqWA1PpdGI8jpKbr39hsHNxHEkeAXJHzzW+Chfet9jyk3V+LLmOq
	CkB91Yvc2HKBfnd7e4D1N+xhkMdzpJL8/HpTwhLK/ET+L0Br7tURw4MoFy/+sV06
	UlRc144p2QAiBjTsTU/SFXZchZdRL0KqjZ6aDaXkkgPRawtourkgK8HmhZGKx+ef
	pHKzfFAj+ZP8DEchDHPMhv2DGIAuo99RH9pPpyY9Hbkd/bdHouSsUVNv3I4sBGG1
	Fy7+oZbnftpmpnRHCJ7eCseF4uwUxms+t1L9m4ZhAYnofwDy73xC1cq+Zwjgmjf7
	7AyQ+SdqgPUv/qKbhzuOPw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1780297326; x=1780383726; bh=L
	0vZWHvmvipAl9d2tQWqJdTC+Ir4+F79S57ejDJ580Y=; b=Gd87d5hTcwbLd7qJA
	RV4ONOf0WR4fSK4SjLxTLITXG8QHYaCCY1uSQRMXpWlxhRQcCzhUP3WB7tVm1kwS
	G0n+cC2ZIbfKqJyq6hvbCw/K7VOqfyYqe1kqhe050kmNCHZhk//7XbOWnZJEi+QE
	W2RKsLr2k7xPV36CWOtiolTStLreSmPXqXQFI0v29EEk3KnH5WnfzRu9dn5en0P1
	Mqf91CuYXMY0JHFM8iMYr6hNg5bbdczP9r0ze6PLFDv0gCFELqLRcxbjXENBGUjW
	PBx93zU1O6MthLlTaiiZJGwybROltK6g6dK3x4RMVlh/pjKykTRyTXFAPGTZwzuD
	+wl0w==
X-ME-Sender: <xms:bi4dapGE5NUjQ5mGQZ-8aGaUQGoxFX5B08FmMbll34v1gH8ogJZsPg>
    <xme:bi4damjIhBfFTG08qaRJQBDb0LGyYGbtnLI-2mWwXX6Ttd7syGhx62Bhjldbjyak2
    7aiBT38wHz2ZawAjj7N0dK1HmWPZLt_WTdOnviImVK0LcFwZw>
X-ME-Received: <xmr:bi4damuG8cg87XPSGgYur7bgR_zYIjyvTOVIcN_MSZTvEz9o3UmcaGVvkv0QNgmmwjwe545AsjxHimqAIvvrFyY1BsMYsvE>
X-ME-Proxy-Cause: dmFkZTEt19F0SWOmsOMHfhjin8Ucu2EdGVXq1OJEBJ7RMmCKkCUMWjL3GkdDCaMKp3bMja
    U3fB97RKZtCzccgpgDvEVpFTtkH/0QZH/WFRMydkNuRo1IyEwrz45xGk1pShzk7Qcf2RtH
    zLZdS6y4HFTT6o0W2wkWMsi2PNuODiTCFgwnUWcs3amTJNRHn0/74gonMz8GwckD4TUV0t
    XES551bsx7Qe4R3x/ilu1ujkH3Rm2TcmRgjfcEIC0W7ypNyGxvpOn5vcjUuU5oGlaMLMdA
    ULdj97P8LVYkTTgpMivIbo/bhJ7vr3oTvMUS3uM47NT+1zHPUXL1ByKoBaQRE7sKGyhcpo
    zNnLKZJMhNnPkwkxQ1VbphymUGAxenq8qdeitbJgpveJM6uehYDapsAyq+5O88EvgjtmJl
    vqj/+JqYQ5+j2/kK10/XelNk5b8JHEJjRehqFzs2yPhlCHRX1K1GFQxVRRJAxEOAMtfdVA
    rc7MIyyerpdVscMDiM2LhJBy4XH7plvBr3sl14Nuz4g9mnRcDRLHi9kc5h8E41S+Gjo63B
    GUJPkFjZZ01b+z0Nv81Vr7sA6iG8MGDKmVQ1kvBMa9yJ+uycPl9ZrT2vdW5ttQUF/gvEJz
    l5cD8AoEQ9PADPm7HIPFWr6qtetpcnSb25dz5u7yAeCwTK+7C769PCpORUDw
X-ME-Proxy: <xmx:bi4dapvjtqSVZBw5s6WwEyRYogTqNsLdx5mp11AStIio9agXLHV2Hw>
    <xmx:bi4darFujqZgJF0qqwgzd7NIWhJc5ZTS62WF1wJM3DmsQhYhr1ePfQ>
    <xmx:bi4dakP6KGKfv4CjXXLiMciecZzIF3WEsRMbm5Vp6s4MnjeAR_6pSw>
    <xmx:bi4daqLb2TvD6w1-NAotZZVHTli5SlDg-yiCa8-BjxMc6Pj-abcung>
    <xmx:bi4davrQGzN34ykdO0ZHrnhiGAskzNPiRXXXIemcOdAbXSaPhDydtaTK>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 1 Jun 2026 03:02:03 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Christian Brauner <brauner@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	"Jori Koolstra" <jkoolstra@xs4all.nl>,
	Benjamin Coddington <ben.coddington@hammerspace.com>,
	"Mateusz Guzik" <mjguzik@gmail.com>
Subject: [PATCH 13/18] nfsd: open-code nfsd4_vfs_create() into nfsd4_create_file()
Date: Mon,  1 Jun 2026 16:38:01 +1000
Message-ID: <20260601070042.249432-14-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260601070042.249432-1-neilb@ownmail.net>
References: <20260601070042.249432-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Having this sub function separate doesn't really add clarity, and merging
allows for some refactoring and ultimately using a different VFS
interface.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 70 +++++++++++++++++++++-------------------------
 1 file changed, 32 insertions(+), 38 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c4d874b9aab5..6a564f1dc2f8 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -201,41 +201,6 @@ static inline bool nfsd4_create_is_exclusive(int createmode)
 		createmode == NFS4_CREATE_EXCLUSIVE4_1;
 }
 
-static __be32
-nfsd4_vfs_create(struct svc_fh *fhp, struct dentry **child,
-		 struct nfsd4_open *open)
-{
-	struct file *filp;
-	struct path path;
-	int oflags;
-
-	oflags = O_CREAT | O_LARGEFILE;
-	if (nfsd4_create_is_exclusive(open->op_createmode))
-		oflags |= O_EXCL;
-
-	switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
-	case NFS4_SHARE_ACCESS_WRITE:
-		oflags |= O_WRONLY;
-		break;
-	case NFS4_SHARE_ACCESS_BOTH:
-		oflags |= O_RDWR;
-		break;
-	default:
-		oflags |= O_RDONLY;
-	}
-
-	path.mnt = fhp->fh_export->ex_path.mnt;
-	path.dentry = *child;
-	filp = dentry_create(&path, oflags, open->op_iattr.ia_mode,
-			     current_cred());
-	*child = path.dentry;
-
-	if (IS_ERR(filp))
-		return nfserrno(PTR_ERR(filp));
-
-	open->op_filp = filp;
-	return nfs_ok;
-}
 
 /*
  * Implement NFSv4's unchecked, guarded, and exclusive create
@@ -332,12 +297,41 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	}
 
 	if (d_really_is_negative(child)) {
-		status = nfsd4_vfs_create(fhp, &child, open);
+		struct file *filp;
+		struct path path;
+		int oflags;
+
+		oflags = O_CREAT | O_LARGEFILE;
+		if (nfsd4_create_is_exclusive(open->op_createmode))
+			oflags |= O_EXCL;
+
+		switch (open->op_share_access & NFS4_SHARE_ACCESS_BOTH) {
+		case NFS4_SHARE_ACCESS_WRITE:
+			oflags |= O_WRONLY;
+			break;
+		case NFS4_SHARE_ACCESS_BOTH:
+			oflags |= O_RDWR;
+			break;
+		default:
+			oflags |= O_RDONLY;
+		}
+
+		path.mnt = fhp->fh_export->ex_path.mnt;
+		path.dentry = child;
+		filp = dentry_create(&path, oflags, open->op_iattr.ia_mode,
+				     current_cred());
+		child = path.dentry;
+
+		if (IS_ERR(filp)) {
+			end_creating(child);
+			status = nfserrno(PTR_ERR(filp));
+			goto out;
+		}
+
+		open->op_filp = filp;
 		open->op_created = open->op_filp->f_mode & FMODE_CREATED;
 	}
 	end_creating(child);
-	if (status != nfs_ok)
-		goto out;
 
 	status = fh_compose(resfhp, fhp->fh_export, child, fhp);
 	if (status != nfs_ok)
-- 
2.50.0.107.gf914562f5916.dirty

