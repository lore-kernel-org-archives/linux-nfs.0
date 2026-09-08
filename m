Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 27DBE58125D;
	Tue,  8 Sep 2026 16:34:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788885300; cv=none; b=KnqxCwTn0bXzNaYmLpyFWbbs1PIbJNroEQvNrVO7hk4j7V8Jgd38c82k3QcRZvJeohdUBfhABhUS63fJ46fAak5sJfwY3Ah6khmJJpOpDXouwXCPWt2SXEPkLVMRDm3YVoIoHoEMHb2nmOruni4Xm0MOa6H5r2l1OrabmgEE19Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788885300; c=relaxed/simple;
	bh=0Not1TXFbFmnqHx64sOVTMcYgwsAjN+xwkbeGUos++U=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=odOua/V6rAd2gEPZ9tYsac90XBWY9n5qYb4DDEAy2eU0lxdj3yHC6BZCpso3xRQI3LPTvRLsFNW/4Uc4UVx3TJqt7n4US8p9TldxM/70YFyNDUGTBM5B00hTV0MjQOJ8T2OEn0S7Mfpr9QUR6edxZVj01SLw6VRMbfgrFbd3klo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=l6k/CdR0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="l6k/CdR0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D21911F00A3A;
	Tue,  8 Sep 2026 16:34:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788885299;
	bh=CgfInR4bNBFp08djpHdR7qiQM69GVpLcw8tBDqFMA8c=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=l6k/CdR0JLXOIQKsolwMYA5Qe5KyW2bSPHeXrk35YOfD9UtpMVc7xg8rsg9u/1FM2
	 CBUgle0q7O4sVRVRHk+RgAs8tToFQPfkYspyX5qSW6dRdRsrg+eG+crpvQPlmOJQAU
	 2ZRNEGgK5mTY+yJlHIL9DCr0kY79Qjxx/WLXJhelM3URehypWeKV0dDHwqxV9lXnTk
	 gKG04Do63P1ogMm3cljTNE9Z0j5IEMYQ276f3MyCY84hJcUJPWj02oCkr92qk/+QMZ
	 iFGNaV2zrWjIl3Yy0xFrbwNrGB3zmdzDXHVfGSt2GB25Y4Si/bxLhdQIBoyST2vtzc
	 cqZ/jeWaqiszg==
From: Mike Snitzer <snitzer@kernel.org>
To: linux-nfs@vger.kernel.org,
	linux-block@vger.kernel.org
Cc: dm-devel@lists.linux.dev,
	axboe@kernel.dk,
	cel@kernel.org,
	jlayton@kernel.org,
	david.flynn@hammerspace.com
Subject: [PATCH 3/4] nfsd: fetch direct I/O alignment for files handed to the filecache
Date: Tue,  8 Sep 2026 12:34:43 -0400
Message-ID: <20260908163448.30841-9-snitzer@kernel.org>
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

