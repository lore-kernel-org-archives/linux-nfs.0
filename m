Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 63447189F43;
	Tue, 29 Sep 2026 02:27:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790648834; cv=none; b=JNGIEwU8X9KDOt7hliI5GO2oK0xIM1YaqIhWOOZKsDvtQnk9Z8MXqYgCUQ4hrPsQ930xAWUeTb2THTyf5EMSexpMQ7esB3GJ3ghdt03fS+JNw00y8NcDzyehAN9kscXse6oRrcWXFl8v0iP0CzYoDeMBqBOGlK7YByrhiKLz0yE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790648834; c=relaxed/simple;
	bh=KtRwiL3N4971G6gTBe1RIHOmZT63DiI/gVET0wrqITk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=uSWeQhXPu5p5zbvH9IhJPHo4eSc+wm/vJOwnEgo8NrDQC6Udjdvay0h3cLRi5RvWHeuzKqcJhKIFB87lHqoJMy2VMkNRqz7c3s/bqty2gIhssmajlQ653sseEFAGM5t7Wo965RX2rJ1aMSd1sYCk53v1OqpIeIw2RgBVc7ylwi4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=BpgGSAHO; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=vV8hWay1; arc=none smtp.client-ip=202.12.124.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="BpgGSAHO";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="vV8hWay1"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 868CF7A0155;
	Mon, 28 Sep 2026 22:27:12 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Mon, 28 Sep 2026 22:27:12 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790648832;
	 x=1790735232; bh=ULssTMyngJWTwzUNg1WBnYZFIiYdZw6JcDo5XOLsYSY=; b=
	BpgGSAHO2zDiZVgbOetZ8vPGGy3wKBDZvzK9aRFnxmJCPtmDI5iTb7gA6OVQCn6g
	OQM2aB94cEBJ5Un1992OiAGrfwVxV1CODZDZFgXLFqsowz7xQFtPGMlNVHJJiRqo
	iOnSDZjh/wSnc0F7nj5O1W7iUf/th9XffYIYrMHCggnvTpGC8tZH/LpSZJ3yaLe5
	kMIIBudtS3Wi+5GrE4tRrDOexseNe4I7K4Akxl4fXF9JngV0pbz5WlgzJOl70Xnj
	yq9Suxnhz7viU8lWdNh6F7e3R213gKsznFvh4Cw9xqlGbY4m08mrFut0s7XEizMn
	dAnCLIqTakFNezatl+G89w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790648832; x=1790735232; bh=U
	LssTMyngJWTwzUNg1WBnYZFIiYdZw6JcDo5XOLsYSY=; b=vV8hWay1CF4CUEvEf
	aKnjHfphqdyrAGLjBXqJ4gvrvldB+GVeMMknelx7ZOTGBo14wiaLSg7TPbSfOuyN
	8uVqDgaUXctdoAMmpAE1EmzXDj7znGn5H3e+VjTsz5By0i392UlJsQmmvCfVRah+
	bavRAxmGyYMotMT2flpqGMFqhRe4vaezSdP8Zu4hZx9YEv7eZm+lisfCOr0jWZ00
	KPd+gXqsEAEAkLmzJ+QPMGbJZHQjS/SLZT7SkrQElmh65l8imNEPA+EzFtLb0Vqd
	xH9ET4KMdTXYDaYVv14YoGVYccKEoRlV7nR0tjxTnRpYbzHTvlk2afF0Gx68+IlV
	hIz+A==
X-ME-Sender: <xms:ACK7atX8yuKeoVXrkdjwkeaN3iKY5ZYAxMZklAxHiYkcKpiVetaWIw>
    <xme:ACK7agoGZur-oUBiJyFU85oXNblqkY0HkN2fmcpEJcKDDq3aFINGTcdn6ktAd46MI
    nK147OrvokND2WZvY5MJ8b0H3DmcF-3DLE2VrKaIMEBq7wX>
X-ME-Received: <xmr:ACK7akBmMxA7B8VeStzs9-P5BkL_M5dN8tcyKd4qmH8LH31CLsLhN-_Vh0Iwt_eW7w3R9EmVF6aqT0_ozrJYuoB4EI54svo>
X-ME-Proxy-Cause: dmFkZTGVDNnzESBYR3mA0mj4J/oiPo94sEVuvz2NPFNMdz9kYeMQUYNSOMDonD5x5v1lxt
    Y3YKxth5y+5AcelhmbqoVXV3FsLexQGqy6ySfBbZdX3XOiA0j0ixOwBQ7YQLMW11urS7Nn
    P7GcHAm+fnGGsK6eRyjpaEjaW3wGzOUhgHmF6172kXxhvNqw5t03JcHMsDIg5eCzkcfYMp
    gzeksANsqYigaEYw/3+s/BCzhblwneuYn20KFgS0pcn7Y6OCynIfFAyFrn+uVtT1eBj7is
    YWaEDBls78d1VVrgCXv67Nm8xKS7Zaj2d89K8kC6IirWCBlABYeoWupGoWlHVy0aKpr4lp
    mlEiG8NZ0ezDOI/g1xhwPWJFP3VEhtNEXmJ93Wqcjh9PFKl+oLRk0ChEz52zy6JFoCzCAq
    OTpjgIqH5lUQd2ZxpwoyxLqkOc5xlglun4/PVF2GldNW1qKvWmqJC+AjlFynkwJMQ9OcV9
    ssRMDwXJHP/ophFAvFBns5aN+Qn+jWGWqzBPvms93MGcWpuRJ09vyuT+5RQV4fUhWtAb+H
    mtZSpwRdaWiPAu7T1UBtqDRxvAzTTIjc3826p6e+8z0Uj0GbxcfEak8qDUstdEfv5jbSis
    H+butSpKIUPArMSjIsLD9aEB+8CRNqffe2b2sheSlvtpTi5xQ077lzyesosw
X-ME-Proxy: <xmx:ACK7asiAwq_wZpda4FmMmQmgWBx_nn0xZt32nUmJ9D7G1MKO9rzE8A>
    <xmx:ACK7aibupFHCUN1XKcMGKzFQyBuRGuxKnK_2Wv8fzx80eXaPq5hL9A>
    <xmx:ACK7atmaqTLcDlVseGrp_7JQZAUPVQ3Upi_bnlQxpSDZByP6Wf3hjw>
    <xmx:ACK7aoim3GorStR17bIG0JtT2LJVg7IpJoDM0UOWqooExgap2Ao4dA>
    <xmx:ACK7anfAW058jiGYfKXRzGNlWN_tJ266AmjArPCLpTS1wQN8lIPk68MK>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 28 Sep 2026 22:27:09 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 8/9] nfs: use d_alloc_trylock() in silly-rename
Date: Tue, 29 Sep 2026 12:21:18 +1000
Message-ID: <20260929022547.1428036-9-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260929022547.1428036-1-neilb@ownmail.net>
References: <20260929022547.1428036-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Rather than performing a normal lookup (which will be awkward with
future locking changes) use d_alloc_trylock() to find a dentry for an
unused name, and then open-code the rest of lookup_slow() to see if it
is free on the server.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/unlink.c | 57 ++++++++++++++++++++++++++++++++-----------------
 1 file changed, 37 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 11a46a993e11..7e01f3d2207b 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -451,7 +451,7 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 	static unsigned int sillycounter;
 	unsigned char silly[SILLYNAME_LEN + 1];
 	unsigned long long fileid;
-	struct dentry *sdentry;
+	struct dentry *sdentry, *old;
 	struct inode *inode = d_inode(dentry);
 	struct rpc_task *task;
 	int            error = -EBUSY;
@@ -468,26 +468,43 @@ nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 
 	fileid = d_inode(dentry)->i_ino;
 
-	sdentry = NULL;
-	do {
+newname:
+	sillycounter++;
+	scnprintf(silly, sizeof(silly),
+		  SILLYNAME_PREFIX "%0*llx%0*x",
+		  SILLYNAME_FILEID_LEN, fileid,
+		  SILLYNAME_COUNTER_LEN, sillycounter);
+
+	dfprintk(VFS, "NFS: trying to rename %pd to %s\n", dentry, silly);
+	sdentry = d_alloc_trylock(dentry->d_parent, &QSTR(silly));
+	if (sdentry == ERR_PTR(-EWOULDBLOCK))
+		/* Name currently being looked up */
+		goto newname;
+	if (IS_ERR(sdentry))
+		goto out;
+	if (!d_in_lookup(sdentry)) {
+		if (d_really_is_negative(sdentry)) {
+			/* try to get an in-lookup dentry */
+			d_drop(sdentry);
+			sillycounter--;
+		}
 		dput(sdentry);
-		sillycounter++;
-		scnprintf(silly, sizeof(silly),
-			  SILLYNAME_PREFIX "%0*llx%0*x",
-			  SILLYNAME_FILEID_LEN, fileid,
-			  SILLYNAME_COUNTER_LEN, sillycounter);
-
-		dfprintk(VFS, "NFS: trying to rename %pd to %s\n",
-				dentry, silly);
-
-		sdentry = lookup_noperm(&QSTR(silly), dentry->d_parent);
-		/*
-		 * N.B. Better to return EBUSY here ... it could be
-		 * dangerous to delete the file while it's in use.
-		 */
-		if (IS_ERR(sdentry))
-			goto out;
-	} while (d_inode(sdentry) != NULL); /* need negative lookup */
+		goto newname;
+	}
+	/* This name isn't known locally - check on server */
+	old = nfs_lookup(dir, sdentry, 0);
+	d_lookup_done(sdentry);
+	/*
+	 * N.B. Better to return EBUSY here ... it could be
+	 * dangerous to delete the file while it's in use.
+	 */
+	if (IS_ERR(old))
+		goto out;
+	if (old || d_is_positive(sdentry)) {
+		dput(old);
+		dput(sdentry);
+		goto newname;
+	}
 
 	ihold(inode);
 
-- 
2.50.0.107.gf914562f5916.dirty

