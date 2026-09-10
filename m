Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DAA5C2DECA8;
	Thu, 10 Sep 2026 00:30:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789000204; cv=none; b=km4/u7WCfLltYZHMBqrhAdnSGszwVQyMWYZRpQFNvcv3ZKM+mBcOfsyPsQEiuQUPcKUld9ouYZ8gEor68FRQuWA2J0p+bzSukckzkWKOnguwKhbf6tNOhTfzyt3MAQtTzepFBqZxOqXvuKIASBdVUEuRByqwIQRmcABJ4aKXtf0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789000204; c=relaxed/simple;
	bh=uX9P96TvFS6Z1moeFupw9yyxsHMY9YyUPTsR+DJP3bE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=NL416fC2EhRVXPBS57I2PeeMOPMSX2Z9lsdPf1U4dXyXWdEm1KUZ4ATmb3GTYytJIaBG4N3SM+RJ31u2m63t9QybS0IH+MIdY4WtDBBd/WV431B9f7BSs4Cb4iLUhvXkd8hQ9+u/VmMWdlqYAS2gX8/n/ADs5cQ1mpBLvxk+f7o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=YJ5PSaw4; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=nWB2xx7L; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="YJ5PSaw4";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="nWB2xx7L"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 0AB417A00DC;
	Wed,  9 Sep 2026 20:30:02 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Wed, 09 Sep 2026 20:30:02 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789000201;
	 x=1789086601; bh=c2GNI1HV5qqkMXUCaVzKanPM9GBQu5cCm0cyORdHlH4=; b=
	YJ5PSaw4zbds+IVLlI1Nd91la9y7gRXwFKMKx16YKFWZc3z5TEeQ5uTv/bTbD7Ny
	mK+051VVVH0iyfe8ikthKS6h9j8DIVPpxwP+zKvMAGbysE8JTTZXVkgEfbC943Pq
	s2m0d7xPtqnwQe7jDYXEv3bTIwWGYU0epV0MhJOyN8oqddQRHjtNqS5S0DL80rzr
	0/GNtFNym2gTBoJ+S9AviQgeLmvO7dd06H2+vKKfbVS5+4sUNSwcwrPZeV6BY9Vl
	wCWcX7r8GXRhEiAyJLIO3XCQDoDZq7vC5tIGL/jRsTWxiVVeAK+XxZ3wM5mIVBCL
	MrXIDsX8Hf703mdrBlQtdg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789000201; x=1789086601; bh=c
	2GNI1HV5qqkMXUCaVzKanPM9GBQu5cCm0cyORdHlH4=; b=nWB2xx7LfSvvUMfSM
	ttFaqN8n7nKNc0KfQ0tHcFjbphQBL9xmg1/306OH0YlNU8E/eyKCI6+1Sn/4kdWO
	LNjDBB1ji0Yd38z/TTiAKMMP9k5mJZnJ5kbsNBFOsfrO6NKnrpdUKsR33sooCORf
	JITNq68KhlAHRLNPHeQ87gk+mprARyrdksDfalyL7u+IeMiT7zKgqpSJb4kEd0/F
	P71V059b6GsoxAi2bmol9rHa9Y0EBbKUH3rTMOYUzzI9IpZMIAr+2EOzRaMUmxB9
	ZaNFgD+zOw5Z7RB/8K4g90jJHm3CkvCKG3/1BaLREaAgo02wBnNa+bO5WukjaUna
	4trgA==
X-ME-Sender: <xms:CfqhamHFihOiyxqzRiiGCONK56-QSRUWQFApoPyCGTIcinTXEMmo-w>
    <xme:Cfqhapk0pREI8145MWdkY3ZHHRm_ezSUtpdJ1ho6iOiiA4OwvFXQkeNrUVJ0sc6RH
    j2f-WKzx3qBVVwGqqkBA5H-dFj_eN7vmqlwjYihmg1qKV4uxvA>
X-ME-Received: <xmr:Cfqhaia36AZs-RxwDQO5-cSlchkGDsTPOKw7EZ1K16TmXAO0jI3zTaXrOGvJeT9XAXqDIiZtYQwDJl3EAm5Jo1thKRCN6LY>
X-ME-Proxy-Cause: dmFkZTG2ZuPEN34R+utP3ESxb9Vdcejdvq1qn0GN2MsSCwESAHSyvwppLG2Yu+T030L2Os
    C8wXU3PxCkVzFW4dp/42EieFv6R0T70CdXif1RWlK2b+xBeP4D18DTQhJEghKWlRjrKyUb
    GdlNnxTgZ+lDp+o1Kz2BsylhbrNhfAZgPcMxHnaH8xn6D8vPLCsNPSG5ApS8ATGgHc/HWj
    wRdbCBCalK8qL4He0aXC4Lyqu1cVz74DhCxPFDqYj/33GFHQ6XxHNgTamDOpUZSq1ebJcO
    0bZ7djSj1c7whFp8Heq+QUaxe+WPB/b+6uiBLPfuZqukj1/5KZnVgOb+3nKerXH+iKGBEO
    JNH5oc2pBY7vnpy3gOYAM9x/cwSqcKYTGSXMfOgKCMFlVG4uSvf6XhiRwgmGA3ponezgOE
    KV0xjFhJ4cfMSR7OrafsKzffGdc5jvjfOAvSgz02mbCeXb7r9bYj7kucZuC+FIGbi6bZVI
    2u3Hsd+L3D7gNAmUJqn5czC6Q/1RzKlCfF5Gz6R3FT3gEfA+gl/PSWChcvv5/Tq3PuncgR
    Od5ffuv5FX4Qf38Nduz0qr1mbYh9sfuSjG5SmafIQGGL+6SUAUvSmMrEh/sFNRJ2RBvAIu
    LMYVZzhGBVNhX6D/YquSyL/zdKAsaY2EPD8PfRYS9xVjDx9jhjYz4kXAwU9g
X-ME-Proxy: <xmx:CfqhamGNWV906pBx-QxE7qUT0lM2NqHmUU6TiEDh1ZjhK85vZ3Qn8A>
    <xmx:CfqharIsR8n2i5b__ZjLBgONMCyJ0-BWeDgYbTR6bs4zpXB1IjK4ug>
    <xmx:CfqhapNT24dAkgNdnrTW60zCNh25xbhRQHnjCwdnofjmqlyCH_IV4Q>
    <xmx:CfqhajkD194EdcZw76mq-a-XkRWcmcuFhSWqdSlLkTNPTDvvndoa1Q>
    <xmx:CfqhahwEdQy73SFwlPhOrGgzNL1l6B3Cqc7SkQZlxy22ESgvDYRD_RBo>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 9 Sep 2026 20:29:59 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 3/7] vfs: vfs_lookup_open() should only return -EFTYPE for non-regular files
Date: Thu, 10 Sep 2026 10:20:49 +1000
Message-ID: <20260910002934.192979-4-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260910002934.192979-1-neilb@ownmail.net>
References: <20260910002934.192979-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

Decoding the non-regular type into over-loaded error codes doesn't
really help nfsd much and it isn't particularly elegant.
It also isn't reliable as some filesystems may return -EFTYPE
from their atomic_open() for any non-regular file, given that
__O_REGULAR was passed.

So change to only return -EFTYPE for non-regular files.
Also use d_is_reg() to detect this case.

Caller can repeat the lookup in the dcache to determine what sort of
object was there.  This might find a different dentry if there is a
race, but that is not significant.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/namei.c | 30 ++++--------------------------
 1 file changed, 4 insertions(+), 26 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index c4be59213352..0c787363b101 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4616,14 +4616,8 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
  * nfsd.
  * It uses ->atomic_open or ->lookup / ->create / ->open as appropriate.
  *
- * If the fs object found is not a regular file then an error is returned.
- * In some cases, related errors are repurposed so that the caller can
- * determine the type of file found from the error.
- * -EISDIR : a directory was found
- * -ELOOP  : a symlink was found
- * -ENODEV : a block or character device special file was found
- * -EFTYPE : any other non-regular file was found, such as FIFO or SOCK.
- *           or ->atomic_open responded to __O_REGULAR.
+ * If the fs object found is not a regular file then -EFTYPE is
+ * returned.
  *
  * Returns: the opened struct file, or an error.
  */
@@ -4671,24 +4665,8 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
 		error = -ENOENT;
 	} else if (!(file->f_mode & FMODE_CREATED) && (open_flag & O_EXCL)) {
 		error = -EEXIST;
-	} else if ((dentry->d_inode->i_mode & S_IFMT) != S_IFREG) {
-		switch (dentry->d_inode->i_mode & S_IFMT) {
-		case S_IFDIR:
-			error = -EISDIR;
-			break;
-		case S_IFLNK:
-			error = -ELOOP;
-			break;
-		case S_IFBLK:
-		case S_IFCHR:
-			error = -ENODEV;
-			break;
-		case S_IFIFO:
-		case S_IFSOCK:
-		default:
-			error = -EFTYPE;
-			break;
-		}
+	} else if (!d_is_reg(dentry)) {
+		error = -EFTYPE;
 	} else if (!(file->f_mode & FMODE_OPENED)) {
 		nd.path.dentry = dentry;
 		error = vfs_open(&nd.path, file);
-- 
2.50.0.107.gf914562f5916.dirty

