Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 780D52F851;
	Sat, 19 Sep 2026 02:25:37 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784738; cv=none; b=YSnZDVx6fnI2QKHd0hD+6TaYQaJUI2pBzfb5izY7XrHKspPgdCU80fd+SQpK90HdMIgvF8MbWPY4tlj4gRp5gnh91f7Z+0uPbY3dbwGGrn/QvLZurRp062kKdj0VlFtuGKBNLtRzuMyi/37iOLWzV42Tb05H+7DB2uBIfELEYrQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784738; c=relaxed/simple;
	bh=y5ozCMpQ6FSrFkQlaY69PFI2hEBCUwhCVMCveB27H30=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=jc5aHdLy3o2fCM1xx+8yEKks77J/Qjpz3M53rXeDfbTW8ISVXp+JHXqKeGsxrVDCYQuVvVQY07uldRf/ZJgXTbrO7sLKOWCHvhwHSUai961+32Rx/mzzMc9CmljnpctF3U1TC5YQB8OITaJozr+LCg+fy1G/UZYRxrslocOc/Lk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=G9wD1nh0; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=xDlJUwaB; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="G9wD1nh0";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="xDlJUwaB"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 4AEFA7A007E;
	Fri, 18 Sep 2026 22:25:36 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Fri, 18 Sep 2026 22:25:36 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784736;
	 x=1789871136; bh=iiwgVmXkwy1VcvFZGCPdg6frKZWpCoTTWrXqbQRI+V0=; b=
	G9wD1nh0RW2kKm1TkfuZaahBtFMz7w73demJ8lNsadAt5CuWAiAiILdHC7b1NLBs
	R5MG+935j5Tm0ES/wA3yfYS9QuF8BNPkozHgBTiOuCKIoFEazxlTZAZ5evTc4nPW
	pOSkvJfPDHQQEHLeDr8aTRMKPiysOpL8vIb1j+mJ5EvRX88/bXOGppv8cTJixiEn
	f2zD7OE8USmwDB7jWXWyHxK14+IB2iEwOrQNTjphcoU0aZ7ddrzVDJQbGLDa5TIv
	4FjiKWwDKLkmYAfxt6X0miHsbQ25GhS4SWUhyeJQoJIurjaVjXoG/AZkpS5OaTrt
	50kz5v0X0iA5Dk4raoXdAw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784736; x=1789871136; bh=i
	iwgVmXkwy1VcvFZGCPdg6frKZWpCoTTWrXqbQRI+V0=; b=xDlJUwaBWn+W5Voie
	4Afg6JUL6+NFOx1OGnv7wNa9Jc848+PJMgMvvT1WksOMmpwsrlwQwUp+tcqGpwl9
	w/RfoQm/MeFoYO4M66qU/YuXsVv8YEoAalLsfKp77HkYAsKUxy405rsdydK0f/kS
	4r3wfW8pq2kdV4LEe1odTLDprmHqkZ1hLsbfZp32hB2URF//BkY91PIyWUfY3XMn
	RjaFONbRQh6gh1d+rjadT9SWLMDep0c3rOBiQRA7roY2K/CbpI+98pAA/GlBD5pS
	L5/fzacDCyl/UsWkelQjz3DiyuBQ2p2y5a8IojMaNSON9wG4wzebkGYy7YAjKlyn
	7Djbw==
X-ME-Sender: <xms:n_KtakQi0ojp6KxbO98rnoiAm1y8shVR-ma6zmPyhMxwyNETHjpwSQ>
    <xme:n_KtaiJjAGVyNRUTdVDwVkdHsYIAovv-dzYVIknUbZ7zcXiHXrydOMsQ2aJpKUqHp
    JcrxHQktGlj12oDlWTuC7Bz0Bv4DBP125Pd0p8M3Qknayfk>
X-ME-Received: <xmr:n_Ktai_PTLhxHp_70I9of2cgMrWd8H_Hz89Uay2zqx4tkauQsANrHkl9o1baBmFo4ikWdqN5uvNe0zlxwRia3L7AvJHHBjw>
X-ME-Proxy-Cause: dmFkZTFLgyyrvnMhFmYCoJfNGebDNGcHqUeGIiw02nB9GfHFGjzZEEpoPB8yFh+lfcAfoT
    ZsKrrVjfOxqzmiP7eTn/n2mccnQ7GMLsuJ0poDjTPggF0rDuGyfgzwYCsrMedCtwxXFSpc
    liDl8cBm/buIJ5SnOZxfqXtnf/cc9igXp+DsvTtzyWWqoLH8cS15BmA0iulNSKshtF5YXS
    nP8kFduV9rNb0xQrN7KMLaO3qhW5cVpFfoz7Xul4/hJXLDOLBANLw7bX2U4sYp7p6ES8Jy
    PGxsHzxRHKaSswbjCJiS593oHxVlUwMe+9vnDG4OL4hPKelxIPDDR/f6RONYfqLWkorhVv
    fH5qB7ueKHa5DYsvWgliAnPEuZm6iROzZO0pqdT6yu31lYHJE7kL+O9AxFSFbOrNzWjrhN
    MZMYBvrz5McRgYl9OqDdtAfvwv0esf83FCSO0OipJgIMv5uI7eCDO/BMfmmDj6kZnf2Khc
    a75lPeQVKqTeBPHDEkOPkn9kz6z6JLqdSQHjd5clWM7Mc7V2UZ7mNx4d/X591O1gobRM9Z
    9GuCcP+fpZnz9mw5FBXQRxv8SZf5NzolPogTGviGeRj27okPcTt4/qTRGSlACBhuKZEkdy
    aZ9ssV+ys6FJh41rQTBrIUZdsLgK617jPsWqOaqCh/GgGpRy/XAGF2JazEpA
X-ME-Proxy: <xmx:n_KtakAi_tnXr_VELxxi4rw9eYURkaq-oxadblNfGSPgKKBeMm2EAg>
    <xmx:n_KtasoZKdLHLO4T1D0Hg249uW9AdXLvi4jbvumw6LEySDNHug1BFQ>
    <xmx:n_KtatIenwV8FFal0mFyrXhBUKBoUqzlvq3iSUVAQP6vqSP5uhfOZw>
    <xmx:n_KtauJoLibfRGW402Lyr0yQ3Liw8FuqfJeviTbWtykKAmPOhSAHcw>
    <xmx:oPKtalHDgRGppW6szD0pmPHYG6tLO7YmVLrpl9WYnMMJl8jGZQ_GLUNF>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:25:30 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Jori Koolstra <jkoolstra@xs4all.nl>,
	Mateusz Guzik <mjguzik@gmail.com>,
	Dorjoy Chowdhury <dorjoychy111@gmail.com>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Andreas Gruenbacher <agruenba@redhat.com>,
	gfs2@lists.linux.dev,
	Ilya Dryomov <idryomov@gmail.com>,
	Alex Markuze <amarkuze@redhat.com>,
	Viacheslav Dubeyko <slava@dubeyko.com>,
	ceph-devel@vger.kernel.org,
	Paulo Alcantara <pc@manguebit.org>,
	Namjae Jeon <linkinjeon@kernel.org>,
	linux-cifs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH v2 04/14] ceph: simplify atomic_open to use finish_no_open()
Date: Sat, 19 Sep 2026 12:06:08 +1000
Message-ID: <20260919022441.3305170-5-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260919022441.3305170-1-neilb@ownmail.net>
References: <20260919022441.3305170-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

The cephfs protocol does not combine lookup/create and open into a
single request/response.  atomic_open() first performs the lookup/create
and then if a positive dentry results, this is passed to
finish_open(..., ceph_open) which simply performs a normal open.

The same effect can be achieved more simply be calling finish_no_open().
VFS code will call file_operations->open which is exactly ceph_open.

This fixes a potential bug where an open with __O_REGULAR but not
O_NOFOLLOW may treat a symlink as an error, and also avoids any
possibility of passing a non-regular file to ceph_open()
in ceph_finish_async_create() if __O_REGULAR were set.

It also ensures correct handling of any alias returned by
d_splice_alias().

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/ceph/file.c | 45 ++++++++++++++++++---------------------------
 1 file changed, 18 insertions(+), 27 deletions(-)

diff --git a/fs/ceph/file.c b/fs/ceph/file.c
index bd3e3f5c269e..83ceb2906f85 100644
--- a/fs/ceph/file.c
+++ b/fs/ceph/file.c
@@ -754,7 +754,7 @@ static int ceph_finish_async_create(struct inode *dir, struct inode *inode,
 			d_drop(dentry);
 		discard_new_inode(inode);
 	} else {
-		struct dentry *dn;
+		struct dentry *dn = NULL;
 
 		doutc(cl, "d_adding new inode 0x%llx to 0x%llx/%s\n",
 		      vino.ino, ceph_ino(dir), dentry->d_name.name);
@@ -775,10 +775,9 @@ static int ceph_finish_async_create(struct inode *dir, struct inode *inode,
 			if (!d_unhashed(dentry))
 				d_drop(dentry);
 			dn = d_splice_alias(inode, dentry);
-			WARN_ON_ONCE(dn && dn != dentry);
 		}
 		file->f_mode |= FMODE_CREATED;
-		ret = finish_open(file, dentry, ceph_open);
+		ret = finish_no_open(file, dn);
 	}
 
 	spin_lock(&dentry->d_lock);
@@ -977,33 +976,25 @@ retry:
 	}
 	if (err)
 		goto out_req;
-	if (dn || d_really_is_negative(dentry) || d_is_symlink(dentry)) {
-		/* make vfs retry on splice, ENOENT, or symlink */
-		doutc(cl, "finish_no_open on dn %p\n", dn);
-		err = finish_no_open(file, dn);
-	} else {
-		if (IS_ENCRYPTED(dir) &&
-		    !fscrypt_has_permitted_context(dir, d_inode(dentry))) {
-			pr_warn_client(cl,
-				"Inconsistent encryption context (parent %llx:%llx child %llx:%llx)\n",
-				ceph_vinop(dir), ceph_vinop(d_inode(dentry)));
-			goto out_req;
-		}
 
-		doutc(cl, "finish_open on dn %p\n", dn);
-		if (req->r_op == CEPH_MDS_OP_CREATE && req->r_reply_info.has_create_ino) {
-			struct inode *newino = d_inode(dentry);
+	if (IS_ENCRYPTED(dir) &&
+	    !fscrypt_has_permitted_context(dir, d_inode(dentry))) {
+		pr_warn_client(cl,
+			       "Inconsistent encryption context (parent %llx:%llx child %llx:%llx)\n",
+			       ceph_vinop(dir), ceph_vinop(d_inode(dentry)));
+		goto out_req;
+	}
 
-			cache_file_layout(dir, newino);
-			ceph_init_inode_acls(newino, &as_ctx);
-			file->f_mode |= FMODE_CREATED;
-		}
-		if ((flags & __O_REGULAR) && !d_is_reg(dentry)) {
-			err = -EFTYPE;
-			goto out_req;
-		}
-		err = finish_open(file, dentry, ceph_open);
+	doutc(cl, "finish_no_open on dn %p\n", dn);
+	if (req->r_op == CEPH_MDS_OP_CREATE && req->r_reply_info.has_create_ino) {
+		struct inode *newino = d_inode(dentry);
+
+		cache_file_layout(dir, newino);
+		ceph_init_inode_acls(newino, &as_ctx);
+		file->f_mode |= FMODE_CREATED;
 	}
+	err = finish_no_open(file, dn);
+
 out_req:
 	ceph_mdsc_put_request(req);
 	iput(new_inode);
-- 
2.50.0.107.gf914562f5916.dirty

