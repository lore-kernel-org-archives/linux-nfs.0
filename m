Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A05B4584946;
	Tue,  8 Sep 2026 16:35:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788885304; cv=none; b=RAjekguYFxN83KcEDSZA8ZctonJYFT4l2DL3R1v3oI07XAbUUgv9a4Ihkho4x4f7XiTvmcgSdlwhmUR6qRP5zDpLOSQkQixoUW2rmdr7cI0azoPLJyUZHsyCj1Myzv0cSLeAlTHKmGOIqG1MHCmPQPEjdMQ6xBzVCxhYyAuYlPs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788885304; c=relaxed/simple;
	bh=0Not1TXFbFmnqHx64sOVTMcYgwsAjN+xwkbeGUos++U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=O4GLS8vPZyee/BsyLCVX/LurCmAP6KDBTjnoBw/pg9gBE29SqjZbRuc7Nyy2+zFyyAwziFdi4eYwAUyfJlpWX1H5rQUlvDDPWRSlXu+B9ds/P11c2tEYVW8jz4OFOwr++J+OmoMKk7WFlepB8O9ZqS8gvriPivcrBdXjQwznk58=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hm6JJjEa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hm6JJjEa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C06ED1F00A3D;
	Tue,  8 Sep 2026 16:35:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788885303;
	bh=CgfInR4bNBFp08djpHdR7qiQM69GVpLcw8tBDqFMA8c=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hm6JJjEaBbRp9K431Z2Gxx3CD5vW2StQKnno0n80L/yoxRG1hpgYWFjeQ1NDdkrKK
	 rW1osPFAjJgBLmRqOjoTdkLgG5Ug+Cry6q0wH7bcrYEHP003gYQWkGRZMK2//y9V3t
	 7vmEr57XDOKKBT63W/iNxZ+JPdbE1ck7b9J8o7T7I8yrKajMCeg59RhOBiBWxuSOMB
	 BcODoM7+nXySFonjUSM0lS2Xm6/f4tRgdPmyqGt+clStN90zw32Ru3equx3GrKjJn4
	 EM7FhEEgEPsTIal9BqfrFs4yk7WxptG7UKygG1uC/CO0FnvFsfjSPuubsN2R48XPiG
	 CGrQYxCQpKvTg==
From: Mike Snitzer <snitzer@kernel.org>
To: linux-nfs@vger.kernel.org,
	linux-block@vger.kernel.org
Cc: dm-devel@lists.linux.dev,
	axboe@kernel.dk,
	cel@kernel.org,
	jlayton@kernel.org,
	david.flynn@hammerspace.com
Subject: [PATCH 3/4] nfsd: fetch direct I/O alignment for files handed to the filecache
Date: Tue,  8 Sep 2026 12:34:46 -0400
Message-ID: <20260908163448.30841-12-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260908163448.30841-1-snitzer@kernel.org>
References: <20260908163232.30774-1-snitzer@kernel.org>
 <20260908163448.30841-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: David Flynn <david.flynn@hammerspace.com>

nfsd_file_do_acquire() fetches a file's direct I/O alignment
attributes (nf_dio_mem_align, nf_dio_offset_align and
nf_dio_read_offset_align) only on the branch where NFSD opens the
file itself. The other branch, taken when the caller supplies an
already-open struct file, stores that file in the nfsd_file and
leaves the three alignment fields zero.

NFSv4 OPEN with CREATE takes the supplied-file branch:
nfsd4_create_file() creates the file with dentry_create() and passes
the resulting struct file as open->op_filp, which nfs4_get_vfs_file()
hands to nfsd_file_acquire_opened(). The cached nfsd_file therefore
keeps zero alignment for its whole life, and
nfsd_write_dio_iters_init() refuses direct I/O for every WRITE to a
file the client has just created.

Observed on an export whose backing device reports a dio_mem_align of
4: all 16 of 16 1 MiB NFSv4.2 writes that followed an OPEN(CREATE)
took the buffered path, while 16 of 16 writes to the same file
reopened without CREATE went direct.

Hoist the nfsd_file_get_dio_attrs() call out of the open branch so
that it runs once, for both branches, whenever the acquire has
otherwise succeeded. A getattr failure now fails the acquire on the
supplied-file branch exactly as it already does on the open branch.

Fixes: d11f6cd1bb4a ("NFSD: filecache: add STATX_DIOALIGN and STATX_DIO_READ_ALIGN support")
Assisted-by: Claude:claude-fable-5.1
Signed-off-by: David Flynn <david.flynn@hammerspace.com>
Signed-off-by: Mike Snitzer <snitzer@kernel.org>
---
 fs/nfsd/filecache.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
index b9548eb17c77..e80f88787ef7 100644
--- a/fs/nfsd/filecache.c
+++ b/fs/nfsd/filecache.c
@@ -1285,9 +1285,9 @@ nfsd_file_do_acquire(struct svc_rqst *rqstp, struct net *net,
 			}
 			status = nfserrno(ret);
 			trace_nfsd_file_open(nf, status);
-			if (status == nfs_ok)
-				status = nfsd_file_get_dio_attrs(fhp, nf);
 		}
+		if (status == nfs_ok)
+			status = nfsd_file_get_dio_attrs(fhp, nf);
 	} else
 		status = nfserr_jukebox;
 	/*
-- 
2.52.0

