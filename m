Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793275828;
	b=IMG5l52VsP9CCvoOnn1FqwWDeGtxnYxnrcYw+taKTpL4l0r0suDMB7bb9OzFkAkHEkDh
	 HuVP/+VRCMt4wuVIilVVhHM42nWt5UNuzLXZQTW9aHLpNSPfBFdWw4HCGJkLbn5KqkHri
	 oebThPyVtas9zchjOdFCTg6uQQVVnvcc7kEdGo1SJPFUng3CZB8IEBvx0EdU856t2UNUD
	 8uRW9kSkq+EidFDANSmER4FxrmwO2J1Rovz0hcK7+eT0bk154XhPU8ownROqPWqkMAZo9
	 eNMhxK/bDXjqTRmFJ8mIC/v1YzUPqL6md8d0CzQLvsYckCly+dGv6kvhltC75CV+rAQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793275828;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=GOAne2sx3wJAqW2xQbXcwoy9DwlGnrr6anTccFQ02/w=;
	b=LamMZlnD9o5oar9tNkVBFRkrsSgV63+CrZLVgxgKotEARJjlPgfOv1tCe5KpDELTJW0n
	 1hIArRhZfV+X9Ap6WfblHxR6xxP844SDFoRgwdBrOqJwX0Hhxvx5Bn8Ud8tT+2i9Jpbmv
	 W/uEpzZSMloSnNTPrLGNiOEhyy8YY2eeVO2GFz10ulzs2K4SWxAkG8UNfhUgWqwgKyTxP
	 qDoM/wwZ3S4qIItsWP+wx5x5FN2zCML1CQeHxlJXL4Rh8RaXh+qJET5DFRGiR0TIapqsx
	 0OtyLOP60JHCpA9WyizNndOAdAc976CO30X1DmBxCwBCfq2BXEz1SWS9uvvAe2aDZ0Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XvgIluxX;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96C31606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 12:10:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XvgIluxX
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 59EBD1F031E2;
	Thu, 29 Oct 2026 12:10:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793275828;
	bh=GOAne2sx3wJAqW2xQbXcwoy9DwlGnrr6anTccFQ02/w=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=XvgIluxXOi2OtzidIQ00d38h6NrK8lQ93OZ4doE5NKKb1xyGJ2HGrJO76JEdbjVzH
	 GBxZSSYDz6Owm8cfU5EEx1iMLJ1ikgwddudwNQi2ErCpkK1bRR28DUN3Y0p9uAjFa/
	 Q3XZFkoawHnCp3bQIJeu0h0+eO2z6ferQ1TlYHT8C6Nyf81TuGlqYfpPxw3fCpirUS
	 LPMTdKJDfVlao5iSjcD9K0kuTAr0JbC1BbuvX7OTkUDd2d9OhgZWR8gvqu5Z1UEQ86
	 jOK0vLjh1O+PNdr0IM+oZy33CsbJDmWkBtX8t+FBx4c8oN8zx7saXSiOBKKnvLlwK+
	 d1LR3bvFXWgwg==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 29 Oct 2026 08:10:10 -0400
Subject: [PATCH nfs-utils v2 3/4] exportfs: Display and document read_io=
 and write_io=
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261029-master-v2-3-32bfc6ac16da@kernel.org>
References: <20261029-master-v2-0-32bfc6ac16da@kernel.org>
In-Reply-To: <20261029-master-v2-0-32bfc6ac16da@kernel.org>
To: Steve Dickson <steved@redhat.com>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3920; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=MhMZDsg5ENWy7VRyMX/dt5i+qmKrYq94eAGlweazmE0=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4zevW7vnz+VJnoDMIvEPR0xq7ofElvJBzFaj1
 1XxDkeupIWJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauM3rwAKCRAADmhBGVaC
 FaoED/9GP8QucEsbPWPBr0yAZIYJ5yxv33SlNnrzVEF/AOc8z93+H7x5FDJwF2ubtNUGVDzV2yO
 mfnN4HLudrR5qQiQ+d2x1zJaahbhjnWoReSeJqXlw4oFru5u30L+AdiLta4u9GCF7Mug1cMcKbn
 33mcyj/amgFbkgjrT85YVxAarAO7YZU0R9VU1PJ6FgjcXhiD+A+p2ld+eFSYTZpal4oeIx6JDGe
 RgsYFxK0b0acjqJOoyXPlpt7J+Fc3y+sew1ud+2lC27PAhnLIrtUwiChO3rQsioCox04b5ecmyQ
 XYluS0n66fbhZvbVs0HZnACARAGuQp1K+vfXNwpzcJZEaq0BGebaDrKKFZRqzXREiOeQefXITR7
 DisrZ8UoZnwTgxjD7jZTA92EbmXSnLsUH/ERfnm0jeC4WD/ZiCL+Sx0R+iSwf8kdyKAr4Hi0SOM
 SGF3tX/G5bwrWwAopNGW1MiDKTTCPJZXaUT58JzhmELvyJcVE3g7MDA7uBNzMtEvlnSVAji9MBi
 aOqOTUeWa2bZaNQfZfT2NNAIW9j6VAFuNGwkGoLWZq/0zC/IeLEJECtN8RYS7l0yw7/dHFfO52M
 JoGou7hKZ7ITETFZJCKf+5jwJq7icE8cp+o+6EVXc1GkKyQI7XPZAwIbGvatvYYuuXSrnF15mL4
 fFKhLA0+q/IkGXQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Show explicitly-set I/O modes in "exportfs -v" output and document the
new options in exports(5). Warn when exporting if the running kernel,
or no-netlink, means they will be ignored.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/include/nfslib.h   |  1 +
 utils/exportfs/exportfs.c  | 34 ++++++++++++++++++++++++++++++++++
 utils/exportfs/exports.man | 22 ++++++++++++++++++++++
 3 files changed, 57 insertions(+)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index 7d7aadaed159..51094886a19e 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -79,6 +79,7 @@ struct xprtsec_entry {
  * Per-export I/O modes for read_io=/write_io=. Values must match the
  * kernel's NFSD_IO_* enum (fs/nfsd/nfsd.h). NFSD_IO_UNSET means no
  * option was given; the export follows the server's global setting.
+ * It matches the kernel's NFSD_IO_DEFAULT value.
  */
 #define NFSD_IO_BUFFERED	0
 #define NFSD_IO_DONTCACHE	1
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index ecf66fd07fd1..eb08ce4662f8 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -614,6 +614,32 @@ try_proc:
 	return 1;
 }
 
+/*
+ * mountd passes read_io= and write_io= to the kernel only over netlink, and
+ * only to a kernel that takes them.  @test_result is from can_test().
+ */
+static void
+validate_iomode(nfs_export *exp, const char *path, int test_result)
+{
+	static int supported = -1;
+
+	if (exp->m_export.e_read_io == NFSD_IO_UNSET &&
+	    exp->m_export.e_write_io == NFSD_IO_UNSET)
+		return;
+
+	if (supported < 0)
+		supported = test_result == 2 ?
+			    nfsd_export_iomode_supported() : 0;
+	/* nfsd is not loaded, so there is no telling yet */
+	if (supported < 0)
+		return;
+
+	if (!supported)
+		xlog(L_WARNING, "%s: ignoring read_io= and write_io=: %s", path,
+		     no_netlink ? "no-netlink is set" :
+				  "not supported by the running kernel");
+}
+
 static void
 validate_export(nfs_export *exp)
 {
@@ -642,6 +668,8 @@ validate_export(nfs_export *exp)
 	if (!test_result)
 		return;
 
+	validate_iomode(exp, path, test_result);
+
 	/*
 	 * When netlink is available, skip the export_test() probe.
 	 * mountd/exportd will validate exports at cache-fill time.
@@ -838,6 +866,12 @@ dump(int verbose, int export_format)
 				c = dumpopt(c, "no_acl");
 			if (ep->e_flags & NFSEXP_PNFS)
 				c = dumpopt(c, "pnfs");
+			if (ep->e_read_io != NFSD_IO_UNSET)
+				c = dumpopt(c, "read_io=%s",
+					    iomode_name(ep->e_read_io));
+			if (ep->e_write_io != NFSD_IO_UNSET)
+				c = dumpopt(c, "write_io=%s",
+					    iomode_name(ep->e_write_io));
 			if (ep->e_flags & NFSEXP_FSID)
 				c = dumpopt(c, "fsid=%d", ep->e_fsid);
 			if (ep->e_uuid)
diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index 7f0278fb8d33..ac8bce905573 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -477,6 +477,28 @@ devices. The default can be explicitly requested with the
 .I no_pnfs
 option.
 
+.TP
+.IR read_io= buffered|dontcache|direct
+This option selects the I/O mode the server uses for NFS READ requests
+to this export:
+.I buffered
+uses the page cache,
+.I dontcache
+uses the page cache but drops the data behind on completion, and
+.I direct
+uses direct I/O.
+If the option is not specified, the export follows the server's global
+setting, which defaults to
+.IR buffered .
+If the kernel does not support per-export I/O modes, the option is
+ignored and a warning is logged.
+
+.TP
+.IR write_io= buffered|dontcache|direct
+This option selects the I/O mode the server uses for NFS WRITE requests
+to this export, with the same values and default as
+.IR read_io= .
+
 .TP
 .IR security_label
 With this option set, clients using NFSv4.2 or higher will be able to

-- 
2.56.0

