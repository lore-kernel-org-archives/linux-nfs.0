Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A25B229408;
	Sat, 19 Sep 2026 02:25:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784721; cv=none; b=rI09ENPm+e0UN+4o8RiUWEgimv4hbEe7ewovITae0rS15qyCejQ6lc8mUPfC+WNPl8qm0ZbJnuhCqc9boV8vO7vtk53d+qaCkpc/7CCoF8fgLR3dLFFEIpmJxVOZZGjmzIuksDI+woml0mpJG+eeE5E1lJy2Tzb+eiBwPnP7zL0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784721; c=relaxed/simple;
	bh=eUJLgaFqf7utBq3fy7K/uuFQIbJR4LJ68wcr9M7AjrI=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=HXp5aTrKqLnH+iKBQzuOT24tVxLahAqK55Lfn1ZxpIBF4yxq6PSuyk2M2dzUQPHkkJEQ9fLj88hWnPt/OwSFAkHL2n4ru4RwMo6h3z+1SVKiGLI13LG/uX5aI2+K5PB+22pRwp9amEuOAkyBVXW/ZtCR+OBmtcUTeYRRIu60XYw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=V7f4HTni; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Cw9L5ubH; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="V7f4HTni";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Cw9L5ubH"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 8FAA87A00D1;
	Fri, 18 Sep 2026 22:25:18 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-02.internal (MEProxy); Fri, 18 Sep 2026 22:25:19 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784718;
	 x=1789871118; bh=Jd2/GqUOedZv7woO87lVSv8CLAHZ9v+ltB2JOKCjJFk=; b=
	V7f4HTniI55Zb0oSGNWr3uLaBhllPULnjLZs5Skf9rGINTc+GPz9lAWMZ7V6FGZ0
	qYtJSlFGIPbTMS2/Z0f/pQajRaTqAOwmxShfVu7bsYvxcqlKSyz+O7NRc2I67LNu
	CWDmAqmbe0eI6p7ZEFTOzdCunnkp+ODJqL+Th4HqQocuYfw7z1tcxbJLh4LejpbV
	IRLZKl4pmPbefRotY8UkbARSoYvaPZKKT9xMXVSzlBfkNxs6SwfY/c2JqiGy6OZW
	S1WBorTPWrdZVADPsXzxm4vTp0u7FCfi/kdBO2aAUbTX0tsu2IfpeWMB71g7wRlw
	eHFqsOUra8AA7Sk6R8qLEQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784718; x=1789871118; bh=J
	d2/GqUOedZv7woO87lVSv8CLAHZ9v+ltB2JOKCjJFk=; b=Cw9L5ubHkYzok/qF+
	SxY0daqQCf5rq8xD29vC9h+ZXpfiauKISOSWyYxOkU3TcWOpTAdN1QO3f4ILl+nX
	DcWilMeWXHCWFVvM0IVSFIyTdTfx2XUWV6zdip2b51HJw+6NZZU1Z+BguT40KOzS
	wB/M5TAZOpFOzV2M316b0mUqo/qH4Oiup087st28XxgreLbauODz6XrvTKYCalMl
	IeIen7tUh7/IWNqubdgpPnif69H0w46UqZPB5oQ/pP1WXLYJXqiiDsQ8u0i7oUXt
	+xXFTKYtqWQmI8b8fa1MEftDL35jQq2x+PbaTPad6f/MeLuLMjp6gylEZ/OnHGP4
	8aFSw==
X-ME-Sender: <xms:jvKtam4kFn0vVlB0ibWxvlhId1RjOSuU1Sod4X0sJngKVgS0SETtSw>
    <xme:jvKtagQLn-pC2s7vJY15kB-FAbaqtsoK4-3Hlt1KiugVXDJSPQVU996Hu3DV1IvJ2
    qyQ2v6F8RCPVUcUJjqjwK10Pq90jhq8Nvzu0yFUaGC7H4Gp4g>
X-ME-Received: <xmr:jvKtamlWB-hNlXon-JCuceAtxIlKs8uwIsw5GXKVa_S_0L6mTsyId9tS_NpMgE2d9GZZxwx1dEEg-4F83Q-FAgf85LjeRkY>
X-ME-Proxy-Cause: dmFkZTFLgyyrvnMhFmYCoJfNGebDNGcHqUeGIiw02nB9GfHFGjzZEEpoPB8yFh+lfcAfoT
    ZsKrrVjfOxqzmiP7eTn/n2mccnQ7GMLsuJ0poDjTPggF0rDuGyfgzwYCsrMedCtwxXFSpc
    liDl8cBm/buIJ5SnOZxfqXtnf/cc9igXp+DsvTtzyWWqoLH8cS15BmA0iulNSKshtF5YXS
    nP8kFduV9rNb0xQrN7KMLaO3qhW5cVpFfoz7Xul4/hJXLDOLBANLw7bX2U4sYp7p6ES8Jy
    PGxsHzxRHKaSswbjCJiS593oHxVlUwMe+9vnDG4OL4hPKelxIPDDR/f6RONYfqLWkorhQx
    bLdh+957B/b0OsW2+e53ZFptMYK/LHSk4cEsX2qDb7XChjOOsVaFjJyVU0VTpFLpb7okun
    foNZj8pomaVKdZixz+hVyTrVbn+ZsoiRILnR689Phos6NQw1GdNsFazSIykGC2vsxbCMXr
    jvYwVklLZwHOu5v9ilh628lUYp6KqCGIHCejI0Y45s9ZbO1n4zbx9N4OALUfGzl5wmHT8F
    9ffIwQ1sXSbu79RkkOYBBIQd3UgbaI2P7dQI1Ikzk/ba5WGgNMrH8AyXyZ1Q4kd8hYHKqP
    PhSnzxeKG7jQg0dlisMaAMIaPWS+G2/85sKq8sEmv06V53/CRkUHNVtpFsjg
X-ME-Proxy: <xmx:jvKtavLRX7cO_xblM6esCFZPfiHrVbfjTeqH5v54hgOUBtKiWA4JtQ>
    <xmx:jvKtapTUsizY6q68bYmMH3ZC-XNNNpJUwcFjgwdIjcIcz1T9Tc_R3A>
    <xmx:jvKtatQiTa4XN9tSgLncEbfR9O6XF3rYW2AS2OhJJ6o_gJcu_WRaNQ>
    <xmx:jvKtarzpt70GJdmb2HQHUoIGRNTIz9Svcd-O_QQK0AV14-MB7MxSoA>
    <xmx:jvKtajuAkv0ZwvPIupT7W3K82FBz_MKE1un_VQXfq4krRBnLEdp1eBEg>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:25:12 -0400 (EDT)
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
Subject: [PATCH v2 02/14] nfs: correctly handle NFS4ERR_WRONG_TYPE from v4 OPEN request
Date: Sat, 19 Sep 2026 12:06:06 +1000
Message-ID: <20260919022441.3305170-3-neilb@ownmail.net>
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

Now that we have the -EFTYPE error code, we can return it from
->open_context when the server returns NFS4ERR_WRONG_TYPE.
This can be directly returned when __O_REGULAR is in effect,
or can trigger a lookup and finish_no_open().

Also don't over-ride the err code when __O_REGULAR is in effect - nfsd
wants the see the original error, and VFS code will map when needed.

Finally don't consult __O_REGULAR for -ENOTDIR.  It isn't clear what
that means and is safest to leave the original handling.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c           | 8 ++++----
 fs/nfs_common/common.c | 1 +
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 49394123bd09..11bcc922198e 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2191,11 +2191,11 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 			d_splice_alias(NULL, dentry);
 			break;
 		case -EISDIR:
-		case -ENOTDIR:
-			if (open_flags & __O_REGULAR) {
-				err = -EFTYPE;
+		case -EFTYPE:
+			if (open_flags & __O_REGULAR)
 				break;
-			}
+			goto no_open;
+		case -ENOTDIR:
 			goto no_open;
 		case -ELOOP:
 			if (!(open_flags & O_NOFOLLOW))
diff --git a/fs/nfs_common/common.c b/fs/nfs_common/common.c
index 0778743ae2c2..24add750c8d5 100644
--- a/fs/nfs_common/common.c
+++ b/fs/nfs_common/common.c
@@ -102,6 +102,7 @@ static const struct {
 	{ NFS4ERR_BADTYPE,	-EBADTYPE	},
 	{ NFS4ERR_SYMLINK,	-ELOOP		},
 	{ NFS4ERR_DEADLOCK,	-EDEADLK	},
+	{ NFS4ERR_WRONG_TYPE,	-EFTYPE		},
 };
 
 static const struct {
-- 
2.50.0.107.gf914562f5916.dirty

