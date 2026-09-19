Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 85C102F851;
	Sat, 19 Sep 2026 02:25:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784729; cv=none; b=IeZQqfgNPZh4ggN5CpFcpNffuU9oSauBoeJ7DdxuIaIWLyDYTCSZEoRWgJ6gOEM9NUETzWfxPwP5RHDXcWgQk1/6Ela2+mFHhQ2m3CoOJE0O4Q0te59Aa8soNnytEFrm3+mtAJpAvuIYA3X3VQ1i60wVMkw3voU3YdW67t96CLs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784729; c=relaxed/simple;
	bh=R68Ab22McsnrNMw53sPZRWd0IwIzsvOtCqg6GYZuRbE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Ru5arqfJBvAaGD7ih+tqf7KR1hw41BzaoqeiUGTai0h6a3O/Z+fPjg+twWmc24llsiNe+FgPxAtZMKVT/xbaRzFKyQkuCe6J73/k00+9xdX4Elr8jAyYreXU++wlSVMYvOLfeqPTnRNGdsUiPnSAJnxmSgRj+clVqLAbjzO7OM0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Yq77+tV+; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=kkVeDv9Q; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Yq77+tV+";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="kkVeDv9Q"
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailfout.stl.internal (Postfix) with ESMTP id 64DF21D000E8;
	Fri, 18 Sep 2026 22:25:27 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-12.internal (MEProxy); Fri, 18 Sep 2026 22:25:27 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784727;
	 x=1789871127; bh=9BEetyl3z+L1c1CCuAY9Ai/K0sCBSwmRh0/nqNlKIf8=; b=
	Yq77+tV+WZtnLCfuY8+3VojzQuTCCigDC/RIfAQZop3VnD2HRh86sYhFdrDwT4RI
	Fv4P8hudtikRH98fwvRI1Xx10g6aGmLm2nY9fRodKnRKARbcbbZDzAaeBxt4rizn
	DLWUfZpgfpUagnz8wGwZyqNVgWX3kDPzEdjgxfC2d45jttEYJV1SVSNpQp5PE2fm
	h/4fCyZKLIjGux0srrVgH3MCFwhfISUW5uM0eaMk8KolROetVGkKn0rorTeorGFQ
	QS9ZV7W6Cm1SFaKyW6BaZrF+G9iTDvqKdU2byvVPVM9YAeqADi2hkwtguwf3xUfg
	vzk+kwa2lwEnSjxE89rZ4A==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784727; x=1789871127; bh=9
	BEetyl3z+L1c1CCuAY9Ai/K0sCBSwmRh0/nqNlKIf8=; b=kkVeDv9QaXz/L79pe
	krdkCF3RHV4Jx/0sQJKU9m4M1s+mpRKaaHtu+h/HGcJSvJzGOQDCjKUeaPa6N3cs
	BsMGZoT3UwbFi5AZxKME+F16L3Aui+6mRwMF8qN9KYkvy4kLUFnYTYoAYELx+CrO
	Z1YcQTKBaiO0KWjvn9NSgEU9kMIYXGjQS3kwPkAGRK2UkipEC3AxwU7ILJMHOs4b
	R15/oPXP6CAbs1UXYsz1iWplCE7pXTM1qZ1dFZ0EeX8ZnqL+Bbm0ulojdXSqjRzW
	VLdqkQZQ/4mRN8g1kyHjI0KpYFxc25nKnsD4sh5Q8PQ2d24Y8Jebn+Sb9Q4MIJWJ
	1C9+g==
X-ME-Sender: <xms:l_KtatE1qGq7f_9C81Uiddvmp38SGsf-PyddT4fRoWgcZXLH_ERUBA>
    <xme:l_Ktaitksy65Gem5eW6k8vwfcHOR65jTSPamPDRzh9ldj6iOSeDNpOeXvs7MV9bnK
    4g2790szHZ4-Yv3_t8Bupw6rkcQyuVd9sgq3vdjppoZXFKWyrU>
X-ME-Received: <xmr:l_KtagRWvi6XZ3kwXd1Wk19YJ7xMS9H9APiuf_0mlQ1NfLfBY7IOWq3Pq6xTnVQDlC70nKvY9i4RfiVjHtHq-HfqoI-Bqbc>
X-ME-Proxy-Cause: dmFkZTFLgyyrvnMhFmYCoJfNGebDNGcHqUeGIiw02nB9GfHFGjzZEEpoPB8yFh+lfcAfoT
    ZsKrrVjfOxqzmiP7eTn/n2mccnQ7GMLsuJ0poDjTPggF0rDuGyfgzwYCsrMedCtwxXFSpc
    liDl8cBm/buIJ5SnOZxfqXtnf/cc9igXp+DsvTtzyWWqoLH8cS15BmA0iulNSKshtF5YXS
    nP8kFduV9rNb0xQrN7KMLaO3qhW5cVpFfoz7Xul4/hJXLDOLBANLw7bX2U4sYp7p6ES8Jy
    PGxsHzxRHKaSswbjCJiS593oHxVlUwMe+9vnDG4OL4hPKelxIPDDR/f6RONYfqLWkorhGv
    AWb+ikjEYCauEY3PjX+/9WEETekp5spaS1ZAHZlLepJ9qOBgN86d2KysQqfPnN+c79Wjbz
    L61hBCmVMRzRiRw0YXYT99btdTkgvirui/x/fQP/RIYaNKn238xYG64KqeAWeYUeNE+HMQ
    FrFx6L1bmWnGMPr7eOxI06GIC6h+AFFzYunX+/Dz50U5a0mu1M3RcR7aLE01jzrhBCl+5n
    hlHLBXrWOzEvuHUbFWEfIr38jf3CIbN054z1+eXXFBINLBXSUpG3ccvv4qJBxFPEatF+Rw
    /aTb3bk+IaEjWER+VKDh+F+PF7SmVzYEDHNV2OSJ0HiR38G+b4PIvw3fbijQ
X-ME-Proxy: <xmx:l_KtavHo00ku2WPTDfhm1I8VY_BH_F-l1Gyl4D3QKTtDDsCQBUGCOA>
    <xmx:l_Ktaie53Sm3TASGHy2beOJrm5cUfxHwfZRaXLi8gxqpZWfIog-0EA>
    <xmx:l_KtamuHcDRmN_fqhtdrSERTeeJeky2w4zaoEwXkW6OBR4l0PTDfRw>
    <xmx:l_KtagdoXVTK5s6ca2cQ74R2Iy_WqKuWnabqeIEs-P7In_bI4JsAnA>
    <xmx:l_Ktaj7lly5N1F2b-DHqcT9P0nUDX4KnYhTWz55sa-bO5NUnBIUnireJ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:25:21 -0400 (EDT)
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
Subject: [PATCH v2 03/14] gfs2: simplify atomic_open handling.
Date: Sat, 19 Sep 2026 12:06:07 +1000
Message-ID: <20260919022441.3305170-4-neilb@ownmail.net>
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

gfs2 incorrectly returns -EFTYPE for any non-regular when __O_REGULAR is
in force.  A symlink might not be an error, and nfsd needs to know if a
directory was found.

Neither this check, or the following check for a directory is needed.
Both cases are handled correctly by instantiating the dentry and passing
it to finish_no_open() - the caller will interpret the type.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/gfs2/inode.c | 17 ++++-------------
 1 file changed, 4 insertions(+), 13 deletions(-)

diff --git a/fs/gfs2/inode.c b/fs/gfs2/inode.c
index f361876c5583..7aa92bb31cf4 100644
--- a/fs/gfs2/inode.c
+++ b/fs/gfs2/inode.c
@@ -738,19 +738,10 @@ static int gfs2_create_inode(struct inode *dir, struct dentry *dentry,
 	inode = gfs2_dir_search(dir, &dentry->d_name, !S_ISREG(mode) || excl);
 	error = PTR_ERR(inode);
 	if (!IS_ERR(inode)) {
-		if (file && (file->f_flags & __O_REGULAR) &&
-		    !S_ISREG(inode->i_mode)) {
-			iput(inode);
-			inode = NULL;
-			error = -EFTYPE;
-			goto fail_gunlock;
-		}
-		if (S_ISDIR(inode->i_mode)) {
-			iput(inode);
-			inode = NULL;
-			error = -EISDIR;
-			goto fail_gunlock;
-		}
+		/*
+		 * This can only happen if "S_ISREG(mode) && !excl" so "file"
+		 * cannot be NULL.
+		 */
 		d_instantiate(dentry, inode);
 		error = 0;
 		if (file) {
-- 
2.50.0.107.gf914562f5916.dirty

