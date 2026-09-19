Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CF1CD2F851;
	Sat, 19 Sep 2026 02:25:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784712; cv=none; b=U3JyXnzBKra6HAY/XLSGbOoLE96Tf4TAshBgKVinHsi7HsMrLR4XMMLX2rkQY3zvH95OBcyX7Po2jnvfuUoSEniExU5TWyv0Orr3siVJxs2tp099U4kKzHsktdUoolPirOAllGQS3xLKj2g+RWZzjZp7+oZ0TfoB2Vm9fehqY7A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784712; c=relaxed/simple;
	bh=dlswt6J03iRUIKNqJEAZJs9GKOTaJLNqykIETaqVq2k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KsULRtEDbgeoInMvaglNJYgSZfVWsYcOR8xZV2q7+G9UEP1SVTh9KfI/j/ZVxf7I3MXtjdlVu8XebKNejBvZTsMhWv5unyb10BiK3DwM0dvo91BMCm7vaO4aUjdO59YepiU+48wVhm/Uv2J8wkcLdqjKSqVQmGGjxQgbE8sY+hk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=b/7wNKlU; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=XF45eWQ7; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="b/7wNKlU";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="XF45eWQ7"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id A8F8B1D0010C;
	Fri, 18 Sep 2026 22:25:09 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Fri, 18 Sep 2026 22:25:10 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784709;
	 x=1789871109; bh=iQ5Erl9XDcUwgZPZnR0GWoin1/kQGUGBsl1Ei6JuSSI=; b=
	b/7wNKlUSYvTO3l7k67HORY7DAM4DiYk9n20doD7h+5GjivZbZOYVi4K8V8GSSAX
	Vy4tzoEyRMFLULrtqVN69Gq3Fc5ZDXdU+E8mwOtPSRW4yXMdrbaR4KwBKVIozJdA
	zDZKomLwmv+y+Wv/PBtZ6QyQU360ZQPxuaBdvT0qBZTxtD3MpxaTeTUoJEAZ3FMQ
	hVMdWoHb8dqlr2DoEPMcZ5HkLo8fmGK2Brjg4aBdSAcK4T4NCzSkKJxGPm+z0lnq
	uaq0+6sd+rze/MuNTcBd/aWXIZZbGbEDp6AhTp7ae5rCTbChSPJwanLyzJ3T7UWb
	SWvjFRJWN0fde8lE9tH0FA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784709; x=1789871109; bh=i
	Q5Erl9XDcUwgZPZnR0GWoin1/kQGUGBsl1Ei6JuSSI=; b=XF45eWQ7qG+tlaMyo
	EejSLlzbWQVzgG2SWKdeAOyelvQdf/wLrAeXQ7c7eVqN08fBqKg8CAuOCo0asFiB
	HfAOjeEhaduQSFrQpI+EDtzFYGpw45EeDWHMLWWLx97ZKfR0tkUg1AOzqZt3rjJj
	yONQzT0aGnwOWUuFRjYl41Z1P4NFtbmnYdI0hUbJ0bjWWm5HFN9iow6G0QeHRE4M
	ftJXzaKrfNNSWCuN2eXBAP0RGBG1McLKap6c7Ud7DLBAuiHRX2xDFzVzIOqpL/Ky
	xr4YcVxeiOk+S2XMiWA3yOwrSDLozkEl8Ccs1oRsCBhr7U2BMq2xnSu8wBoI6NdY
	ePyPg==
X-ME-Sender: <xms:hfKtaqdIjKH8Al_SIQtwpfKSqlnGAyg7tQkQYQ8jiD7C_95Wd7auBg>
    <xme:hfKtakmtA2jmI1UeYX8c0CQl8AvUIAbOyxisKAtPQxk0llK9GbPFtN0jVYXc6HtUx
    AXcGjHYkDTbt2wDnLfkpzPCB2r0Bzz6Df-3sT1rS5ZuZjWO0Ok>
X-ME-Received: <xmr:hfKtasprRiP1bcNj64yqmSjkZOyOU-CMMLEw9hnzNU9CkFjwMieLZBrz7IlJOrD8rDocb7NilgisPegmnEIl25HTC_42gXY>
X-ME-Proxy-Cause: dmFkZTFLgyyrvnMhFmYCoJfNGebDNGcHqUeGIiw02nB9GfHFGjzZEEpoPB8yFh+lfcAfoT
    ZsKrrVjfOxqzmiP7eTn/n2mccnQ7GMLsuJ0poDjTPggF0rDuGyfgzwYCsrMedCtwxXFSpc
    liDl8cBm/buIJ5SnOZxfqXtnf/cc9igXp+DsvTtzyWWqoLH8cS15BmA0iulNSKshtF5YXS
    nP8kFduV9rNb0xQrN7KMLaO3qhW5cVpFfoz7Xul4/hJXLDOLBANLw7bX2U4sYp7p6ES8Jy
    PGxsHzxRHKaSswbjCJiS593oHxVlUwMe+9vnDG4OL4hPKelxIPDDR/f6RONYfqLWkorhkz
    ihFKXbox4317Fz8b7VoX4t9Afn4fpzTcJvOW15Wsxx+MZpKji3QE3ofkwVSTIKO7r9dmNH
    llmT8Ksee6kbpCgnSzvwHfLuWLgWDGKp36zioNcY4/M/8+CPQKkVid0o8vhDa7qspXQo5k
    4lQh13NC59qRbrG7fhHPzBifsZUWpQtFCCRMUbkh8dTsKg+rDj9drd8QCYZ76NZpA3qSo5
    q5KjmO2wQjXMdyFqYljYQgfeonlLA4XRy0YzYJDirI5RkHvkS0fGkn7NSBDGnv3KxexJe9
    BviUci+6UuL/TgOSSumClbudVbPbowYWsBz4he1cIyAuvgceEpq+mF569J1Q
X-ME-Proxy: <xmx:hfKtaj8S3XEr1VJmHlWlH_z7cssKvAe8YyeseyhYGaYgSh1pKDuJww>
    <xmx:hfKtal1jyCjMcru-phIILKRbOvIuLMhSeAuoqhFblHTzBtNRaWOgWw>
    <xmx:hfKtammED1GD0Z2MfyJJQQ7qDsouaR9eHxBLFlZKXUItfckOYaUF2A>
    <xmx:hfKtai1Ug9m-GoSDlOM3FsncQcGu2D3aUmUi3zvLOF5kXwYsvyewUQ>
    <xmx:hfKtalSdLK_RXNdmbr4FWbHbCowIZTFNsCslALOOgWG4yBPBT0bN97UM>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:25:03 -0400 (EDT)
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
Subject: [PATCH v2 01/14] VFS: revise and expand documentation for atomic_open.
Date: Sat, 19 Sep 2026 12:06:05 +1000
Message-ID: <20260919022441.3305170-2-neilb@ownmail.net>
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

atomic_open is a complex operation which different filesystems implement
quite differently.  The available documentation doesn't give clear
guidance on how it should be implemented.

nfsd has a particular need to open only regular files, but to get
precise information about what was found if it wasn't a regular file.
This is slightly different to the syscall calling needs.  In particular
it suggests that __O_REGULAR shouldn't always result in -EFTYPE.

In any case that does involve creating open state, using
finish_no_open() is simplest as it reduces the need to check
__O_REGULAR, O_DIRECTORY, O_NOFOLLOW.

So refresh the documentation to give guidance on the choice between
finish_no_open, finish_open, and an error.  Efficiency always wins, but
when that isn't an issue, prefer finish_no_open().

Also clarify the required behaviour when __O_REGULAR is given.  This
should return -EISDIR if a directory is found as nfsd needs this.  If a
symlink is found then __O_REGULAR does NOT apply: O_NOFOLLOW must be
used to decided if it is safe to not return the looked-up dentry.

Signed-off-by: NeilBrown <neil@brown.name>
---
 Documentation/filesystems/vfs.rst | 67 ++++++++++++++++++++++++++-----
 fs/namei.c                        |  3 ++
 2 files changed, 59 insertions(+), 11 deletions(-)

diff --git a/Documentation/filesystems/vfs.rst b/Documentation/filesystems/vfs.rst
index d3a93eec3945..00ada8cc85ae 100644
--- a/Documentation/filesystems/vfs.rst
+++ b/Documentation/filesystems/vfs.rst
@@ -599,17 +599,62 @@ otherwise noted.
 
 ``atomic_open``
 	called on the last component of an open.  Using this optional
-	method the filesystem can look up, possibly create and open the
-	file in one atomic operation.  If it wants to leave actual
-	opening to the caller (e.g. if the file turned out to be a
-	symlink, device, or just something filesystem won't do atomic
-	open for), it may signal this by returning finish_no_open(file,
-	dentry).  This method is only called if the last component is
-	negative or needs lookup.  Cached positive dentries are still
-	handled by f_op->open().  If the file was created, FMODE_CREATED
-	flag should be set in file->f_mode.  In case of O_EXCL the
-	method must only succeed if the file didn't exist and hence
-	FMODE_CREATED shall always be set on success.
+	method the filesystem can look up, create, truncate, and open
+	the file in one atomic operation.  This is needed if the
+	filesystem content can be changed asynchronously and
+	specifically if a negative dentry is not a guarantee that the
+	object doesn't exist.  It is also useful if it is possible to
+	perform combinations of revalidate, lookup, create, open, and
+	truncate more efficiently what with a sequence of individual
+	operations.
+
+	If the object found is not a file or directory, or if
+	lookup/create succeeded without establishing any "open" state,
+	then finish_no_open() should be called to confirm that the
+	dentry is ready to be handled by normal VFS processing.
+	FMODE_CREATED should be set in the "file" if the object was
+	created, and this will prevent further access permission checks,
+	or handling of O_TRUNC and O_EXCL.
+
+	If the lookup/create operation established some open state for a
+	file or directory, the open should be completed by calling
+	finish_open().  Passing NULL as the "open" function to
+	finish_open() is unlikely to be useful as that assumes that no
+	open state has been established.
+
+	atomic_open() may generate errors related to O_DIRECTORY,
+	__O_REGULAR, O_EXCL, O_NOFOLLOW but is not required to as the
+	caller will check those against the resulting dentry and
+	generate any error needed, possibly closing the file if it was
+	opened by finish_open().  atomic_open() is encouraged to handle
+	these flags only when doing so is more efficient than not.
+
+	If __O_REGULAR is handled, it should generate -EISDIR if the
+	name is known to be a directory or -EFTYPE if it is some other
+	non-regular file other than a symbolic link.  Handling of a
+	symbolic link should be guided by O_NOFOLLOW, not __O_REGULAR:
+	-ELOOP can be return if O_NOFOLLOW is set, otherwise the symlink
+	should be returned through finish_no_open().
+
+	The focus for atomic_open() is to provide the correct dentry and
+	to set FMODE_CREATED as accurately as possible.  If O_EXCL was
+	set, FMODE_CREATED should only be set if this operation
+	certainly created the object.  If O_EXCL was not set,
+	FMODE_CREATE should be set if it is possible that this operation
+	created the object.
+
+	This method is only called if the last component is negative or
+	needs lookup.  Cached positive dentries are still handled by
+	f_op->open().
+
+	If the dentry provided is negative (not in-lookup) and O_CREAT
+	isn't set, then there is no guarantee of exclusive access to the
+	dentry - another thread might call ->atomic_open() on the same
+	dentry at the same time.  If needed a filesystem can ensure this
+	doesn't happen by returning 0 from ->d_revalidate when that is
+	called with LOOKUP_OPEN on a negative dentry.  This will ensure
+	that ->atomic_open() only receives an in-lookup dentry, which
+	always ensures exclusive access.
 
 ``tmpfile``
 	called in the end of O_TMPFILE open().  Optional, equivalent to
diff --git a/fs/namei.c b/fs/namei.c
index d95249dd527c..0f69abb3743b 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -5007,6 +5007,9 @@ static struct file *path_openat(struct nameidata *nd,
 		error = -EINVAL;
 	}
 	fput_close(file);
+	if (error == -EISDIR &&
+	    (op->open_flag & __O_REGULAR))
+		error = -EFTYPE;
 	if (error == -EOPENSTALE) {
 		if (flags & LOOKUP_RCU)
 			error = -ECHILD;

base-commit: 9189e6a6f89e32d3a604b221ea64e67e1a35957c
-- 
2.50.0.107.gf914562f5916.dirty

