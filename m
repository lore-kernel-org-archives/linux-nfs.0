Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A22AC2F851;
	Sat, 19 Sep 2026 02:26:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784775; cv=none; b=AZvf041ROPxXiShh2jMVaMS/BR80ft/00woGOiYDvjPpXfhKHsi2JkVJujvEO8evX6DVgnBYCk99GXDVMxG1bSxwD43hzMoZgNrp2Jq6nsC/7NKQGl0cidkIRTxZwpnEEeERheOBO41CMu2yKUdZ9rfM1O5AZ4UXdMnWLIsP4Nc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784775; c=relaxed/simple;
	bh=cxtmKlNVG4Xw2mxND8A2B6NsJi4o/gMPEhMEJRaJw3o=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=M8oM8R+KRwGjIAxkrTm16pL0ABD1lmjgsW5ozUgMnlt7Gn02bTkfNG1BtaVFodDs0VysEtDOomdEcZNse+f2ybAK3Fq8jH5v3Iz9077Y8EGbBB8egDt0IYnr7kzOFgWAKEcSrXFi2j8n16V5aoB4VvjCDT1IdQxtLzDLmRzzJJs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Oo+zBWjP; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=i61JrGLs; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Oo+zBWjP";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="i61JrGLs"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.stl.internal (Postfix) with ESMTP id 7E3321D00116;
	Fri, 18 Sep 2026 22:26:11 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Fri, 18 Sep 2026 22:26:12 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784771;
	 x=1789871171; bh=Zyu3DcbO+3qBIpROcTOO61Y8i5MbUANXndfp1aNLI+U=; b=
	Oo+zBWjPL4sGJaL582bHVQjfXQUvxJg+FGiKWEiKs6fUK+CdzVddkHxGeQT4Uf3L
	P/B5q0PLT+J1fbnogTYxBjeBPWmczQY2nlF+0ZJZ2tIPY+985dujROyLzu3ntcqG
	ptx7Q/YMtbD+x5NO1i63cGWzZUMzsniVYRI5bNjkFkwwTKmV+dmcd4/GjZrQ7MCw
	Er0DLHSSXElr4LKDMWYGoum5CEUHI8glPEe5zA5pR4UiUFkeG1pYsH47nOzn9AOI
	GWvbesDgQmYFf+7Kr8p48HHGVbkFBWsLwviVtuID+PchrlDiof3iCcILWXkWqId6
	Z44eZcfGqt95Uf7D4tspVw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784771; x=1789871171; bh=Z
	yu3DcbO+3qBIpROcTOO61Y8i5MbUANXndfp1aNLI+U=; b=i61JrGLsQAJFocV9D
	TiAveThSMmxqmvwTWXQrUvdgzR5cIORhwFxEQqWK6VdUNKO++mBqtiChbnbd5RhL
	FxrmSYKOvVqW+1lDksL/tgF7S2ssLcj/kh/kFtX7RLWsx14rjU0WAnfWJIFEWXs1
	WsIzH5NkeS9h60DYBg2XidXMzNHymR2IkgELR2fI5BWW438fWSDlSFuSAg7XbPJW
	zGZyezoX2VMscHjXAwwrUKKFF3qYigx7ozlnJzGMA5vzMwBiUgZa3/OZ2NEMxdSH
	vUVEzY+8l0yBFDabusY776OSK7pDN3M4DvF2CQry6CfUfIgSNlkj2b6uwfdpWs25
	E+Qhg==
X-ME-Sender: <xms:w_KtatpvfRcs1aJ3EobntgY2JuL71FWDfWP3OFUzdlQYzReWtEQ9aw>
    <xme:w_KtagAw7aVQTaZzex1nFSk0nQQ-R8iZqVfbTbsNokJLdETREZ61Fz5OAgWf8jWNQ
    -GRlefOyt1eqvCI-j9OjTLoL3OzO7i_JyQKNdOcvhbHWuv0kRs>
X-ME-Received: <xmr:w_KtarV9130meqAm1z6uqs8ZiJYd_Z5CdTSFGjFlMg4e-MYw3_Z5WrBEEaK2xGVkkpOt0s6Q5O3ilW_Ux19JK-YtHnqY8rY>
X-ME-Proxy-Cause: dmFkZTFLgyyrvnMhFmYCoJfNGebDNGcHqUeGIiw02nB9GfHFGjzZEEpoPB8yFh+lfcAfoT
    ZsKrrVjfOxqzmiP7eTn/n2mccnQ7GMLsuJ0poDjTPggF0rDuGyfgzwYCsrMedCtwxXFSpc
    liDl8cBm/buIJ5SnOZxfqXtnf/cc9igXp+DsvTtzyWWqoLH8cS15BmA0iulNSKshtF5YXS
    nP8kFduV9rNb0xQrN7KMLaO3qhW5cVpFfoz7Xul4/hJXLDOLBANLw7bX2U4sYp7p6ES8Jy
    PGxsHzxRHKaSswbjCJiS593oHxVlUwMe+9vnDG4OL4hPKelxIPDDR/f6RONYfqLWkorhTt
    wkawggax5EQAXJNtbBZ5G5XGETb00UaJMfnI9YKhciBYfv0L64NAYDBiGqcqhV7rQbbVuT
    AFErVdmUjoVlp898Ga5ITsc/4+GAZogwFrn0NFp33mge7Frm9mJaxdCiP+1rrWD0JhAAkC
    0n6gS23r+8vvGnd1dbOXi9ue/nCv1WqDNPxQ+3gqQUqUhhgBrFPQsYDe210fxJfr7XGCF8
    S6JmGzLzEmBF6l3pgvI6LBX3zdEVZ1LyEli04NYT+WJJvA5TwJUfn/Y3x8VW3eWN3EMHgn
    yMA5DP28ynNDOLwu68lpSDyRfjIghw13qk481IaY+OQOpQLoD7XjT7OkHlCA
X-ME-Proxy: <xmx:w_Ktak7VXqZEyyEF4nVPn-BKykEKOwVZlH8imJFogTULbHGbAtE4JA>
    <xmx:w_KtasDqG-3KB_xHHRLnWMorBIXdxKH4xbakuDviaISaHI65eC46Qw>
    <xmx:w_KtapAbh51-ACpgv3T3sARt06AQ7pIJZ28i5m_Rn8EdVbdEMTTH4A>
    <xmx:w_Ktasi5LwTKySjLedOam5eLzjA7ZxVfjSB7M2dYHkLjSEPlBKoo_Q>
    <xmx:w_KtaideVqcuweAuano2RrzQgc_MFMbmRIXk41F2h-Xd_n2Uhv5l2gE8>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:26:05 -0400 (EDT)
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
Subject: [PATCH v2 08/14] vfs: don't return -ENODEV from vfs_lookup_open()
Date: Sat, 19 Sep 2026 12:06:12 +1000
Message-ID: <20260919022441.3305170-9-neilb@ownmail.net>
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

-ENODEV is not generally an error meaning "the object is a device"
and nfsd - the only intended caller of vfs_lookup_open() - does not
benefit from knowing it was a device file.  So return -EFTYPE in
that case.
Also switch to testing the dentry type rather than dereferencing the
inode to get the type.

-EISDIR is widely used to mean "the object is a directory which is
   not what is wanted".
-ELOOP is sometimes used elsewhere to mean "a symlink was found but
   cannot be handled".

Also remove note about ->atomic_open returning -EFTYPE as that now only
happens for non regular/dir/symlink.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/namei.c | 24 +++++-------------------
 1 file changed, 5 insertions(+), 19 deletions(-)

diff --git a/fs/namei.c b/fs/namei.c
index b9fca38ad489..ba3e7e4b5fdb 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4621,9 +4621,7 @@ out_dput:
  * determine the type of file found from the error.
  * -EISDIR : a directory was found
  * -ELOOP  : a symlink was found
- * -ENODEV : a block or character device special file was found
- * -EFTYPE : any other non-regular file was found, such as FIFO or SOCK.
- *           or ->atomic_open responded to __O_REGULAR.
+ * -EFTYPE : any other non-regular file was found, device-special, FIFO or SOCK
  *
  * Returns: the opened struct file, or an error.
  */
@@ -4671,24 +4669,12 @@ struct file *vfs_lookup_open(struct path *parent, struct qstr *last,
 		error = -ENOENT;
 	} else if (!(file->f_mode & FMODE_CREATED) && (open_flag & O_EXCL)) {
 		error = -EEXIST;
-	} else if ((dentry->d_inode->i_mode & S_IFMT) != S_IFREG) {
-		switch (dentry->d_inode->i_mode & S_IFMT) {
-		case S_IFDIR:
+	} else if (!d_is_reg(dentry)) {
+		error = -EFTYPE;
+		if (d_is_dir(dentry))
 			error = -EISDIR;
-			break;
-		case S_IFLNK:
+		if (d_is_symlink(dentry))
 			error = -ELOOP;
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
 	} else if (!(file->f_mode & FMODE_OPENED)) {
 		nd.path.dentry = dentry;
 		error = vfs_open(&nd.path, file);
-- 
2.50.0.107.gf914562f5916.dirty

