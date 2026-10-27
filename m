Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793119844;
	b=MZuxI9Mg/JfmRPouj+o5FrTyX8AdgaFycoi5yGDdvEpsnANmX9zevVvwX66KP6VHwCvh
	 U8p8J8e9GbCt7tp5bmiPpxJHhzEM78SBSghziN/yYWwi2IVJ8ihJh1YdHx+K5N2uahaKG
	 sab1NvvVRAnS79DWiNhP/ZqL/ecBBv8dp/VHdnBqGQNAEX7NZdIgDQymEGbBLckTn7usl
	 cb59OZpRnvqAq1DoPKVhEFLa6Be4yPXpqzEp6LPDl5LsvlC5yBk3H/e3zAsb6dsyCeXhj
	 jrmeWQ8nxDrybeADpFB4BjctkW+iWvQ/rscRZlRKltWhhpeARz3wYTinboT5qUAqDZQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793119844;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=p8RCQRk1boN+0YE4f74QHZM30PlHviQhIS1T0f1gdHU=;
	b=FL4rui9Ft4ssca69Yr+ZFdvlQec+FC/VBTpXo+k7XAW6P2JN58fWbsi9rGyrdeNsndgc
	 EC2vteln9XQkQqqzHbmV/rClM/jvr8ZrJzfbPQxi6mK1JMnIedFn6Qugbb0CVNQyRf+bJ
	 fmaGyvqDIVb+fNYvPGfKNR1NVihiPoV2wt060xWL+uMtqp458dcLDkszcatKldCA7HNn+
	 FLAnB79Q/Q5sENYACtzsM6SNM2ht0nXYUR8zdau2CtY/IkAhxTfKQ+jEBgROSArodG4Kj
	 rGMr72QjCQm3SGGFcaU1NokgILAx3IrZUPVknT3FqnmMpbcMTVkUPUkD2d0eU8XKZLg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dvd7HHX0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17B59606A32A
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 16:50:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dvd7HHX0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D038A1F01828;
	Tue, 27 Oct 2026 16:50:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793119843;
	bh=p8RCQRk1boN+0YE4f74QHZM30PlHviQhIS1T0f1gdHU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=dvd7HHX0AxjxT6vLGmPvSORmpGghcTuo2hHcBQLICh3ky/AwGXHAty50pImEXktyf
	 5R4NfHpuPKbRy7lssexh6CvxBFYN6ZdNoENHPTQOFA9z1ew8jpY7XFUHzJbh5+qIeq
	 9SphFHtz00sIixK0BcGt58Yfvs5/pMQn1bNlHGGwf2lDuN3ePOnZQSiw6+MUBe+XS5
	 v8qQbgquyLkGh9F6TsD2EUJh3Gwmx0fCczqHECG0oIbHxTJdVI/8CLtaEYdLMizx1G
	 3EzuWdE5iWyoHMhxdRP+cSi6d5fmkyYcfEmhkb72F1UBasJN3Fm4ws/AYtAxDDtG7e
	 MjVmS1ozqHvbA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 27 Oct 2026 12:50:25 -0400
Subject: [PATCH nfs-utils 3/4] exportfs: Display and document riomode= and
 wiomode=
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
Message-Id: <20261027-master-v1-3-6f1f7a35a83b@kernel.org>
References: <20261027-master-v1-0-6f1f7a35a83b@kernel.org>
In-Reply-To: <20261027-master-v1-0-6f1f7a35a83b@kernel.org>
To: Steve Dickson <steved@redhat.com>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3912; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=1koUkRDTpXYtACVZLM3NN1eF3eu+T5fBUP/Bt/MHpE4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4NZfKl4a2ezfa/7TzSdWJtFQSSqGqThDDyl1t
 IjggCuIG1yJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauDWXwAKCRAADmhBGVaC
 FXJGEACJIXvINqqfXtVqI05TMjiwgl7jlNVKG5Nvuxcgu0YJT6XWhKHlNh98tpVGmLUhFbzFvx2
 P8mqLH5iv9BkRlqUqJKqEg+prjbY4vGnQeSgkkBDpuWP21jgJP82EUBQGG/6r6IevamKJCbuIBu
 7lpffwcHpQw22SvGQ7P+ltqktvE1XPS3fnHgX/CsSi2PBv9aQSBS2Pe/fEHJHzIM4y7w16Zd1PC
 PPVfmdGLsLhjLkeFyyyLJCwSYjehtNOpAw7SSzxCiuMBbwdvT0SDh532GfHbYAcIvOCYqX/UMhP
 CBE2tV+wJso0ZjLU00C6HC4VLVBcASHh5PvhO9jj9Zj3ZKOFF9/xPUmlsD4+PqF/nJcvIgUOMHh
 nMQhL+f+PMOsTYoH4zcrY+AZY0TBNqEe6tFOI/toUaOpzrpgu1sxVciifSkjK7EVsw7gTmIMDJ8
 2O9ARZa6KJSJ+f3dDFHzf21X+MODU+E8KbOCdqMIxl7D7jgCshV/tf2y7iBaxmazeDxixE9NqMX
 6uzndB/3AwRtqQxFoWv96qmzUcOAQAcDvENk+8H44ucGFDXA9MMjY7t/9iLXP93Mim0/tWYGslD
 ++maAZQ0tX7BOajH5DW/w8VDi+qhR4HH0mvpxuW2JEUd8IypcPXqNMuH5mhkF7bclDdB2emJ9fP
 rw7KYfedS15DVRA==
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
index f2be65b55f8c..8b515eb1fd5e 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -79,6 +79,7 @@ struct xprtsec_entry {
  * Per-export I/O modes for riomode=/wiomode=. Values must match the
  * kernel's NFSD_IO_* enum (fs/nfsd/nfsd.h). NFSD_IO_UNSET means no
  * option was given; the export follows the server's global setting.
+ * It matches the kernel's NFSD_IO_DEFAULT value.
  */
 #define NFSD_IO_BUFFERED	0
 #define NFSD_IO_DONTCACHE	1
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index ecf66fd07fd1..6061b2f03d7f 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -614,6 +614,32 @@ try_proc:
 	return 1;
 }
 
+/*
+ * mountd passes riomode= and wiomode= to the kernel only over netlink, and
+ * only to a kernel that takes them.  @test_result is from can_test().
+ */
+static void
+validate_iomode(nfs_export *exp, const char *path, int test_result)
+{
+	static int supported = -1;
+
+	if (exp->m_export.e_riomode == NFSD_IO_UNSET &&
+	    exp->m_export.e_wiomode == NFSD_IO_UNSET)
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
+		xlog(L_WARNING, "%s: ignoring riomode= and wiomode=: %s", path,
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
+			if (ep->e_riomode != NFSD_IO_UNSET)
+				c = dumpopt(c, "riomode=%s",
+					    iomode_name(ep->e_riomode));
+			if (ep->e_wiomode != NFSD_IO_UNSET)
+				c = dumpopt(c, "wiomode=%s",
+					    iomode_name(ep->e_wiomode));
 			if (ep->e_flags & NFSEXP_FSID)
 				c = dumpopt(c, "fsid=%d", ep->e_fsid);
 			if (ep->e_uuid)
diff --git a/utils/exportfs/exports.man b/utils/exportfs/exports.man
index 7f0278fb8d33..2dfb12c6a4db 100644
--- a/utils/exportfs/exports.man
+++ b/utils/exportfs/exports.man
@@ -477,6 +477,28 @@ devices. The default can be explicitly requested with the
 .I no_pnfs
 option.
 
+.TP
+.IR riomode= buffered|dontcache|direct
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
+.IR wiomode= buffered|dontcache|direct
+This option selects the I/O mode the server uses for NFS WRITE requests
+to this export, with the same values and default as
+.IR riomode= .
+
 .TP
 .IR security_label
 With this option set, clients using NFSv4.2 or higher will be able to

-- 
2.56.0

