Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8859A29408;
	Sat, 19 Sep 2026 02:26:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789784764; cv=none; b=lLJft5tInUHvfpby51B6NoeH0bnUv9NpvlUsGrfkaOEvsnANQWlqnvOxvgcHySGOGf5qogufX9NPG/Ek9aILNDPMZ33VPcHJK9u59QElnlHbdM+wgBrOtRyXqGghYF51CoW+VMhYjtWH/052z2d25fTKfdvUxHBMH6hdTf4YP4I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789784764; c=relaxed/simple;
	bh=TVSozmx5LFrbr3L5ZI4OUBzaCnxlwtu1LBDaDccQd7Q=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=MUgVjhSpvNynZDF0oDYmfafOWiOPKlF3uyXvc3BO453of+aU5yzNF2BE3fhGk1pfga21P6TKqMIHvilbY5TRYmItAJ8GSx7OKyqzG1WPm6tvF7Kz6v1LWvTFNSl12ERFqCCCywXNHUHxMlkPoH1z4GcwAI2dXGceRaXsoRWqc/4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=I6WEBdAB; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=FL0hBgJ+; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="I6WEBdAB";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="FL0hBgJ+"
Received: from phl-compute-03.internal (phl-compute-03.internal [10.202.2.43])
	by mailfout.stl.internal (Postfix) with ESMTP id 951181D00111;
	Fri, 18 Sep 2026 22:26:02 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-03.internal (MEProxy); Fri, 18 Sep 2026 22:26:03 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789784762;
	 x=1789871162; bh=a1dvbCIXGTF+aXVYY4V7L9bSEi3TKPjz6Nuequ/+FvU=; b=
	I6WEBdABEuzXUbzGrYlECC5k6ALHztuxS1ToBtm0AN6ZQrX1kf/YvjSxD5t1O0Ra
	v8m2Y+27VbZ5+dvuIjkUGKMubyIbJu1vWjxqKOMsPvuILv1x0uquKZSd3EfWULUT
	+HbhVXphRrsJnOxzYncKkGuOV/uQnAgZum3im0Vvpv94xZFq+3l7qRVGQh3CZ3U3
	2nFy7lO3wirWumStmIWW5aANCzthOneuwz2X7YHq1MgUGnlACFb6YNY+dyzjVCqb
	U+3Jp6XNgK0LBlRtnf9vYZJaSpoXSFvRc8rfwuFgZ+0SO5ZLG7gFjwo1MjRGTM74
	apz1+KKjkG9bdSXTz4eUzw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789784762; x=1789871162; bh=a
	1dvbCIXGTF+aXVYY4V7L9bSEi3TKPjz6Nuequ/+FvU=; b=FL0hBgJ+46kNWo0n0
	UxJFJHKPjtyHfN0w7E0d3znCvIwwggu0u7a3BnHPjcf85K9DYWj+l+kh/2lSGq/z
	Q1ypr6pg4PqfBvp8wHQcpyUG0h7DaCYx+wmKIbe1eZ0MBkM4XvpjWw2MyF0dpRo8
	FyxXDUgtXhDDjS4fL84stcLM7nLjs+SqLP4I+fxb+ITB+CStGwA4vxVCF7DJNBOw
	elS3guj1BvrFpOcDuJ4rquCSVQ2NvnZq4dykKRcNdXcRYZn9KZdSS0qBfZ4qppaM
	jzaiPZU7Ba0fDcDY/+3LBYQGWvh6gJpXFbip/xuDfArGvZn10KdxH6ycBEo+pZWa
	0GOxQ==
X-ME-Sender: <xms:uvKtauRbr4Rbss-Buj1LCcOQQZ28ictr2ntBcaz-64cDIMQvvQeaWQ>
    <xme:uvKtakKsd0PRZxgH0THW2RKvRirUczBwyH8KYWNeNc9WhRvP4_3JOM4DyiPFYWhDt
    tzANkGcY_tPsaVgn0G0zRteoqpiz1OmrG9Pa80TCEQewnOBt-0>
X-ME-Received: <xmr:uvKtas-xScZ61xmfifQRQF5HPQqyNARw6EAxLvkDWTsYZIEGUlcofat4SmpJWAnIGproPaft86_KH-lpBpVLZxnuBMvJgYc>
X-ME-Proxy-Cause: dmFkZTFLgyyrvnMhFmYCoJfNGebDNGcHqUeGIiw02nB9GfHFGjzZEEpoPB8yFh+lfcAfoT
    ZsKrrVjfOxqzmiP7eTn/n2mccnQ7GMLsuJ0poDjTPggF0rDuGyfgzwYCsrMedCtwxXFSpc
    liDl8cBm/buIJ5SnOZxfqXtnf/cc9igXp+DsvTtzyWWqoLH8cS15BmA0iulNSKshtF5YXS
    nP8kFduV9rNb0xQrN7KMLaO3qhW5cVpFfoz7Xul4/hJXLDOLBANLw7bX2U4sYp7p6ES8Jy
    PGxsHzxRHKaSswbjCJiS593oHxVlUwMe+9vnDG4OL4hPKelxIPDDR/f6RONYfqLWkorhjc
    8wBi/3Lusy5ZTGWqbb/gzaG7iVBClRmgFDJvP8g610GGFx/jKpQIPNXkptUoqq8kqCeb0d
    02N2Df8iP1egjlFdJeR2Yhb6JkUmLU9U/hufpXXP0LL10AWGTx3O7r1AcM8CPzZkrWgbMl
    ShXD5vE1E5ivY1lFpanViwzUDVt3ssFTYU0MvS6+nXFqB5zJPTaNxVCtBPIZPVn2CRg3Sg
    RpmqNZJjW11Wd/FnmOOAIUc/Z7kFNQQc0d5C56tDdTT9kQGec2DRYwJRC39VRvUrP3m2Vm
    8WoFNBrGmVvM94wY8fAYcqk1Y2AUvX3pjXMjfSP0DC2CWNWNrpQLcgGkw3NA
X-ME-Proxy: <xmx:uvKtamBgxq3dW25jXo5F9OIc1YvQIDvc92vRKCe_FrKLszbHMPVHJw>
    <xmx:uvKtampNvOuw_q5u51Uf6os20L_fDz2bNfbQI4j8Z-kfE4mx2ohrHw>
    <xmx:uvKtavLZLYEGvT6_vT_oY5H-6-M6_B297gUSK0dgr5YWb4VRtJTXQQ>
    <xmx:uvKtaoLVkj9tWPVwCy9mSgWVNfJsXywUMtwBQzDvlhZBTelxLx0TTg>
    <xmx:uvKtavHIBxY5stqgvNescjVYtbQs6CHG4W535fL2BxKiQglWVWbqMIwn>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 22:25:56 -0400 (EDT)
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
Subject: [PATCH v2 07/14] vfs: O_NONBLOCK|O_CREAT open shouldn't wait for directory delegation
Date: Sat, 19 Sep 2026 12:06:11 +1000
Message-ID: <20260919022441.3305170-8-neilb@ownmail.net>
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

An open() of a regular file can block if there is an active lease on that
file, but this can be prevented by opening with O_NONBLOCK.
An open(O_CREAT) of a non-existent file can block if there is an active
delegation on the parent directory but this CANNOT be prevented with
O_NONBLOCK.

If nfsd is to use common VFS code for open/create it needs to be able to
prevent this blocking.  It is conceivable that a user-space application
might need this too.

So extend O_NONBLOCK protection to not block on a directory delegation
when creating a file.

Fixes: 134796f43a5e ("vfs: break parent dir delegations in open(..., O_CREAT) codepath")
Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/namei.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/namei.c b/fs/namei.c
index a08f37aca3e1..b9fca38ad489 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4554,7 +4554,12 @@ retry:
 		goto out_dput;
 	}
 
-	error = try_break_deleg(dir_inode, LEASE_BREAK_DIR_CREATE, &delegated_inode);
+	if (op->open_flag & O_NONBLOCK)
+		error = try_break_deleg(dir_inode, LEASE_BREAK_DIR_CREATE,
+					NULL);
+	else
+		error = try_break_deleg(dir_inode, LEASE_BREAK_DIR_CREATE,
+					&delegated_inode);
 	if (error)
 		goto out_dput;
 
-- 
2.50.0.107.gf914562f5916.dirty

