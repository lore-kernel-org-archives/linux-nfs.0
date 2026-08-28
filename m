Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B459F379EFE
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 23:18:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787959125; cv=none; b=YBYoKF5qbgVTZ4jtANwMOyFcXT0kdDULkeiThsWXdkFaU08/IyRQ2TUmsJS5vCS4zTF0hujikD3clmBmMq0ja3CQrMQ5/jEruZIjp6u3kO4XB2HxLdFbxc07fyec2+VAOAsttYNVwMz9cZjgcIk0T0OMqsBuJveSs34OriOKW88=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787959125; c=relaxed/simple;
	bh=Uc66l1/B5eIJqe+U2QUN66waait18Wg7RfTpudO7ZPM=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=PgA5F0ZZfD4gpQiXT4YLfGvQXLJYW+b0IO4Q7zVr0U3MOF1NIsT+x+vbrauMjFV+ZMeNslN0xwHBwozQk9/F3F6uOT79d0Q8eZywTIgjrtHrtbmTbaysYy4iw16r46gRU8BY6yluQtc4rgPJu+PSCRFYudtaojsTRjc0G1XzKdU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dk96jsfv; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dk96jsfv"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 08FAE1F000E9;
	Fri, 28 Aug 2026 23:18:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787959124;
	bh=hixWKFqiKgIC1ET7LsEhz1GJETNWXYCDEhEEgxdiu1s=;
	h=From:To:Cc:Subject:Date;
	b=dk96jsfvF11ntoDc+XSWMEV9ugqMcs1cz01F0I3fwyUG3Gwru8gGXpzb+J/cozb2+
	 I6uQpgBwg1p6xtbShQwqgLvwLcUgtfH7Spj09h6OPor8TLtN5AzoNAJEc+1VjapGeA
	 TBpyioYXo78EMtI2nj1imvRkA1Q6MhBe5VtASSFDWJkek+gCFhHg2mcgAgb0lTDKa5
	 ZlPNkeKPJU6Pxs+pFzElfI+qksExAePQw4FH1cri2msZn70sBUihAHVWK0z0hRzt2q
	 3fV6RsYfufzxDXgL6lmUDox/q+2AzocgGjh1I7MI5ZCmpdkI+6lLGDY2gDlRDtaix9
	 ChsXIh+ZnUsEg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	=?UTF-8?q?J=C3=B6rg=20Sommer?= <joerg@jo-so.de>
Subject: [PATCH v1] NFSD: Return NFSERR_ISDIR for NFSv2 READ and WRITE on a non-regular file
Date: Fri, 28 Aug 2026 19:18:41 -0400
Message-ID: <20260828231841.282003-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

Commit 0ac903d1bfdc ("NFS: NFSERR_INVAL is not defined by NFSv2")
changed the status NFSD returns for an NFSv2 READ or WRITE of a
symlink or other non-regular file from NFSERR_INVAL to NFSERR_IO.
RFC 1094 defines neither an INVAL nor a SYMLINK status.

U-Boot's NFS client follows a symlink only when READ fails with
NFSERR_ISDIR or NFSERR_INVAL. Since that commit it cannot load a
boot image through a symlink exported by a Linux NFS server: the
load completes with zero bytes transferred.

Solaris returns NFSERR_ISDIR when the target of an NFSv2 READ or
WRITE is not a regular file. Return the same status from NFSD.
Other NFSv2 procedures continue to return NFSERR_IO.

Fixes: 0ac903d1bfdc ("NFS: NFSERR_INVAL is not defined by NFSv2")
Reported-by: Jörg Sommer <joerg@jo-so.de>
Closes: https://lore.kernel.org/linux-nfs/apE90ZRZB8IW_AiS@jo-so.de/
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 19 +++++++++++++++++--
 1 file changed, 17 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index 48541ef7644f..09d360839825 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -40,6 +40,21 @@ static __be32 nfsd_map_status(__be32 status)
 	return status;
 }
 
+/*
+ * Because NFSv2 does not have an NFSERR_SYMLINK, Solaris returns
+ * NFSERR_ISDIR when the target of a READ or WRITE is any object
+ * that is not a regular file.
+ */
+static __be32 nfsd_map_io_status(__be32 status)
+{
+	switch (status) {
+	case nfserr_symlink:
+	case nfserr_wrong_type:
+		return nfserr_isdir;
+	}
+	return nfsd_map_status(status);
+}
+
 static __be32
 nfsd_proc_null(struct svc_rqst *rqstp)
 {
@@ -238,7 +253,7 @@ nfsd_proc_read(struct svc_rqst *rqstp)
 		resp->status = fh_getattr(&resp->fh, &resp->stat);
 	else if (resp->status == nfserr_jukebox)
 		set_bit(RQ_DROPME, &rqstp->rq_flags);
-	resp->status = nfsd_map_status(resp->status);
+	resp->status = nfsd_map_io_status(resp->status);
 	return rpc_success;
 }
 
@@ -271,7 +286,7 @@ nfsd_proc_write(struct svc_rqst *rqstp)
 		resp->status = fh_getattr(&resp->fh, &resp->stat);
 	else if (resp->status == nfserr_jukebox)
 		set_bit(RQ_DROPME, &rqstp->rq_flags);
-	resp->status = nfsd_map_status(resp->status);
+	resp->status = nfsd_map_io_status(resp->status);
 	return rpc_success;
 }
 
-- 
2.55.0

