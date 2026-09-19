Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 970C82F851;
	Sat, 19 Sep 2026 02:26:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784809; cv=none; b=de+134JAKwsYlFX9COFQt4IgcRlZbOnv+E1ig/i7F33JJcKAsWU2wAoQuimVb6gdffZR0sKPv0Tkmzc+0CY0Jt/v4/1P+6GFanQ/TI7/Ha92u3ju4S25CoQ6CU4aCuzFqu5CpXKJEXVpOD5XaRxkArvFYFOlAHw7wR83tdRL9Zs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784809; c=relaxed/simple;
	bh=1yEjdq5Vo5OS53wWJkXRPnYsh2QIg/oED3oYaYDRrcE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=rEv/S4QjXGGqCsHeWRkQH2BERIDy1TrUtDUmbVjFvleFQ6z2UcPcwWKXC07AbICLFLy6NxEQ2M2UFGLhEnN3K7UMxRHEroCj6sUylCED62XlbqQqnEvUa74tNxOD0HmsA1s/RXEHRB9VmSdYXYfEClT1AJnsMgbst5XYDOxguFU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=K12XBHpn; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=C4mDWAkJ; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="K12XBHpn";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="C4mDWAkJ"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 9FF9B7A0105;
	Fri, 18 Sep 2026 22:26:46 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Fri, 18 Sep 2026 22:26:47 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784806;
	 x=1789871206; bh=Kk35wTCnG6qaH5kjEvCmWyGKPkYGw0HOge+XZtsWfao=; b=
	K12XBHpnwTh8ELIq5YiTeTTRRC5Q2+OxcfZ1ltNrybWm2yVAoC/Thx8IIzc/1odL
	zDBUcueOKU8uNX59oa/SBDi8GjuoXtZPHKH7NzM0Wa8Y5Tq1ejMcW491aW06xvKY
	dHXo8KbnoQApyRQQWsP/Ik1wre7k0Qc/i1HL45ZS/13jYuXJEHYsQy9/ELu67F+n
	ycnPdWdIX8x/d3A+w5vHNHoTSCBp6N4G3fst1bZmAiOm+kY4JXC35eCbgSYcdZZb
	DKs2juPkCOve2PUqQJDQ9B4fkdbdotU2Peou+W2zcF8QC3oi22HvGT7vUm7byfO3
	NwoyBFdcsSdzjUW0s4CUqA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784806; x=1789871206; bh=K
	k35wTCnG6qaH5kjEvCmWyGKPkYGw0HOge+XZtsWfao=; b=C4mDWAkJAg6admkc6
	94YjFSXaY78gRIBdEQjFXyRttLiCKniK1JGGY0kVUUQigwukNFiPMCBa9g8EvvwP
	uxS6WZZ2Dsr0nLiN2gnaDi4xacf7wDIZ4AaujPHJjkw98LuQmlwWmS4QlB31PEiS
	MS+f8gN167WAtrVGztnFsuXvA+aRKLUM+1hINyNZl5Cr2G+q9RaNMFzwQOxbrhmg
	2CmrnAC+iwMiRkJNwDfxRMBT+Yk/M4IZpXnxo3I5DoNcyrgsA1PUmapLjrJBHHAL
	Rn4N+/wUOZ5fiOml28nOtXUdBuTXLazzd1E4obOZ2nnSh06+Lqf2EnIZpYQUm0cV
	XhkQw==
X-ME-Sender: <xms:5vKtatSjHHy4u8KPdHvBqvoFcFZ8BUmhslr50vTzjP3Dqy0ysVbsDA>
    <xme:5vKtavlGjPFwpWopURNRHHOWCZFqQqNla4qwkQILKguDq2n-lNEt30_emusIR2HGT
    AgOYAxEHCClOK4SLpK7GyLsuy-eoVIVxxPELKSkDAAWVhSEZz4>
X-ME-Received: <xmr:5vKtakKf29nBsalQWvkOTo3B7mXzCYCBhzts6fAbDdAH4eT5wzbzNyow0VihCdY_SFSup3hVjJa-vRcQjpZUyJGwj100-6o>
X-ME-Proxy-Cause: dmFkZTGtAHYZ2fol9WZbijETZDg+7FCar+y/pMhv66kqsGspm17JsjzmN+wOfYd0at9xWa
    UpL1ir5F/oOkFsK7kqoauKKWs6eMpLCsbqi42s4tBHpUvxFMTRQDd6VYm/rcH4SZDwJWC1
    mB2gQF0uBqecUb/asRUVJ9E0aE/yCL6egEGowl11EY43/dVlVXINF3ezsrr6Mrs1epbIzK
    NTey6EyLFCy3wMucOF+e93SFzjCJr429VK3iHP1PO2ehW8CsCSMuTyO1dvmH6SPcex1cXA
    2lKZB+ZWUeNPLANmEUzEUzCIol0g7KWkEci5Ngi6tkJ54ALbt+FqCRsOFa/XWjWUcu92Wz
    ZMQro8XUuYyll17dZTLfVNELP8XVZdT2Hbt/2Pf9Ju4kHvToXTo8kTE5EOY5gPs6xzNiO5
    GB49oDW+WSFtZEC/dBG2xVW4uJsjIvpEBQrIj25OJZM5ZAIcNBkAX5sYGGwIqraJrdsGIM
    /tLZcDY31X5h2K5+MqTQWNsHK53NZKSbw2g4NquK+nyo63XE1EaqE0y+6k0+hCp0Vj1W8U
    h1P5A4xVjzZGLuHxYmbdJwW9jCDdNZqPl9z/Go/bstVzI9SwWo7XTn7NFRBwBiUan5cexr
    kNfAsBM3xa9U7Aw/QVU5NHpN79XDN/ZkBmBHF9SYgxjQVGIvZgGPhbIlUF6g
X-ME-Proxy: <xmx:5vKtaqQfn7siKzwsTACnj6_Re1-7U5ZqfU29Bx3TvOnoUEe4SA1kYw>
    <xmx:5vKtaqR4GedprlJRr4JCxNyF9elT8qA3Q3zdFwTivJ9h9yICPCdQTw>
    <xmx:5vKtakxTkf2smNs_jHTR4BuMbNLK-4EmFOUE2khmmTpY8RHsUmHuaw>
    <xmx:5vKtaouGM1U9wvNIvXeTJTMr8Qy878JqnRQ65-0rZeXcTgCOvl8Waw>
    <xmx:5vKtais2RuQOVdPzTaNdeAmHxi5aveyjEgMno_e-CpWYXkNfRRdciDuG>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:26:40 -0400 (EDT)
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
Subject: [PATCH v2 12/14] nfsd: switch NFS4 OPEN to use vfs_lookup_open()
Date: Sat, 19 Sep 2026 12:06:16 +1000
Message-ID: <20260919022441.3305170-13-neilb@ownmail.net>
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

The functionality that was recently gathered into do_lookup_open() is
now available from the vfs as vfs_lookup_open().  So nfsd4_create_file()
can call that, with a few adjustments.

This implementation shares more code with syscall open paths and so uses
some filesystem interfaces slightly more correctly. Specifically:
 - it doesn't call ->lookup before ->atomic_open is called
 - it does pass LOOKUP_OPEN to ->d_revalidate
 - only gets exclusive lock on parent if name is NOT in dcache
These are minor.  The main benefit is code-sharing. In particular
it takes responsibility for locking out of nfsd so that planned changes
can happen entirely in VFS code.

We need to pass O_NONBLOCK so that that EWOULDBLOCK errors from
break_lease of try_break_deleg() get passed back.

We need to mask any type out of "mode" else vfs_lookup_open() will warn.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 58 +++++-----------------------------------------
 1 file changed, 6 insertions(+), 52 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 3d37754f787b..50baf125d5f9 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -250,52 +250,6 @@ static inline bool nfsd4_create_is_exclusive(int createmode)
 		createmode == NFS4_CREATE_EXCLUSIVE4_1;
 }
 
-static struct file *do_lookup_open(struct path *parent,
-				   struct qstr *name,
-				   unsigned int oflags,
-				   umode_t mode)
-{
-	struct file *filp = NULL;
-	struct path path;
-	struct dentry *child;
-	int want_write_err = 0;
-
-	want_write_err = mnt_want_write(parent->mnt);
-
-	child = start_creating(&nop_mnt_idmap, parent->dentry, name);
-	if (IS_ERR(child)) {
-		filp = ERR_CAST(child);
-		goto out;
-	}
-	path.mnt = parent->mnt;
-	path.dentry = child;
-
-	if (d_really_is_positive(child)) {
-		/*
-		 * open the file so that we consistently have a valid
-		 * op_filp and consequently a valid ->f_path.dentry.
-		 */
-		int err = nfsd_check_obj_isreg(child);
-
-		if (err)
-			filp = ERR_PTR(err);
-		else
-			filp = dentry_open(&path, oflags, current_cred());
-	} else if (!(oflags & O_CREAT)) {
-		filp = ERR_PTR(-ENOENT);
-	} else if (want_write_err) {
-		filp = ERR_PTR(want_write_err);
-	} else {
-		filp = dentry_create(&path, oflags, mode, current_cred());
-		child = path.dentry;
-	}
-	end_creating(child);
-out:
-	if (!want_write_err)
-		mnt_drop_write(parent->mnt);
-	return filp;
-}
-
 /*
  * Implement NFSv4's unchecked, guarded, and exclusive create
  * semantics for regular files. Open state for this new file is
@@ -312,7 +266,7 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		.na_iattr	= iap,
 		.na_seclabel	= &open->op_label,
 	};
-	int oflags = O_CREAT | O_LARGEFILE;
+	int oflags = O_CREAT | O_LARGEFILE | O_NONBLOCK;
 	struct dentry *child = ERR_PTR(-EINVAL);
 	struct path parent = {
 		.mnt = fhp->fh_export->ex_path.mnt,
@@ -412,11 +366,11 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		/* Might still succeed if no create is needed */
 		oflags &= ~O_CREAT;
 
-	open->op_filp = do_lookup_open(&parent,
-				       &QSTR_LEN(open->op_fname,
-						 open->op_fnamelen),
-				       oflags,
-				       open->op_iattr.ia_mode);
+	open->op_filp = vfs_lookup_open(&parent,
+					&QSTR_LEN(open->op_fname,
+						  open->op_fnamelen),
+					oflags,
+					open->op_iattr.ia_mode & S_IALLUGO);
 	if (IS_ERR(open->op_filp)) {
 		int hosterr = PTR_ERR(open->op_filp);
 
-- 
2.50.0.107.gf914562f5916.dirty

