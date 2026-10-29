Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793275541;
	b=ZwFei7a4/FwxMC3JKXEOiAdPY3uPglSmIRDakpKkGq3uzkPEhLyrlLILJpEXO+y92+og
	 DHqUD7sj7ZW6PlE7Hq98MIGt6tCVgVlcgDbogW9+2GmdbN6b7ndF9bJTHUbHiqLXCKuWj
	 tEZTwfjDTTFJQnSGJ1GPd555HaO7Cf28GZInBhiSaBzkQ3QhHR6/WfwdHdQHhmRIdlduF
	 ww4BYyb4BVsWRO+hXUj6+fVN6YnjmBMyc0rMOf5q+Ooq0lS+9Q3BxfELY1VidbzMuRkws
	 JPCaYHz/kaVXuIF5kTLhtGnrvC3JPraI/nIXPCQK8k9GKtsfMtPce/mDEZvuOGJIQVw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793275541;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=m4q8IBv2Aq4VzMFmJ720i/Ha3K1G7dBBmg9TmL8Mktk=;
	b=PCEfaB3BA4LEhJGI4f4678i3eUOPJoXTXugtI0M2SByJLF3xji7ksHWsu9b2w1hKi7s7
	 2oiBmteo4pnLVNZsx2YuDOhBtKXpJmJN6u6hWnxVtDsIJxYeyrE4c7TsS476xtc7ot/cv
	 HhqbTzqFrEWTV78iS28Kzl/hFa2HdraWZK+xaaUVJdWfav9mCgiI5QgnpHh8gVxUV7Cat
	 nmZ3Rql+H1XObHyz3wwHyDr9g9QNIRWfmNxno9dlKcX0Zpb0L/5rki8US5YE/lcwOIscx
	 Mdw4n/bHA40B708hTO3Jz/RobIu2zlQo+ttfP2g8sbNhKFQl7n014db9xDtY04LXTsw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="G7W/lfVJ";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6758606A31C;
	Thu, 29 Oct 2026 12:05:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=G7W/lfVJ
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AF1A71F031E3;
	Thu, 29 Oct 2026 12:05:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793275540;
	bh=m4q8IBv2Aq4VzMFmJ720i/Ha3K1G7dBBmg9TmL8Mktk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=G7W/lfVJ/mkmNevRshufHxdNZdkNn0oDfCjkBzcVmMdjqEghf4d5IuZo4rMKRsisa
	 PEURw321EmWxCjd9H9Memh/0KSBVPBWNTcN+fJMVyBxJIiAoqXcJdqel5IqiH4lZ1P
	 WSc61J6HOsm1jZlyPm3cvyIKnICn+6HRkrw99VbHPqAdjtZrfaBnhT7OgdIcpGSELR
	 VT9F7kzHBv+/Vxa8eqxV3qHbZMNZtQr33E3AdMusJtjVb5+lcYEXiT+1bXorezcR9u
	 SOqNFY0qrRGqwprdCX7CyRfo8ja8PB1Mp4VTZH0oQoj/pv7cxXoazRN2No9ppnIVXH
	 NCVL3IMgfc3EQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Thu, 29 Oct 2026 08:05:15 -0400
Subject: [PATCH v2 2/6] NFSD: Apply per-export I/O modes to READ and WRITE
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
Message-Id: <20261029-export-iomode-v2-2-fe8ec6251a36@kernel.org>
References: <20261029-export-iomode-v2-0-fe8ec6251a36@kernel.org>
In-Reply-To: <20261029-export-iomode-v2-0-fe8ec6251a36@kernel.org>
To: Donald Hunter <donald.hunter@gmail.com>, 
 Jakub Kicinski <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@kernel.org>, Paolo Abeni <pabeni@redhat.com>, 
 Simon Horman <horms@kernel.org>, Chuck Lever <cel@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Randy Dunlap <rdunlap@infradead.org>
Cc: Steve Dickson <steved@redhat.com>, netdev@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 linux-doc@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=7163; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=fV/ivDZtC7maqaposCIkh9QAgY/9cod0K9Scn0wTVDU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq4zaNsGyrVblnPod+WLVyBaSTr157cGgZ7V0at
 1lWX5rNu7GJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCauM2jQAKCRAADmhBGVaC
 FRu8EAC9jAIDGiUFuhLqI08YBUK6POi5tJZBVcxU4MUULlLsFtgoNqiU6cWWBYi5HfiyQoO0Qgi
 kMz5Em5nqQ/4gYNPRZ0nK26LlQIVzVXGUHdkVFECx4YtyA2F4rm5wjcw28Wzn3r4n075Lsu8v1B
 D1hGbtzLrYhHQKTSKOAgreRdOqTDo7zqqFMG8XHsUj2FWFxIm46efv3TyKlbCoefZ1LuaNfDB/3
 g85CozTIt3gZJRp7QDp0aYHmz4cZSpW4ZXU4C0rxBgne1jXBWfrM+th9F9xK7dnfIdeyivXC2yq
 fLYDv5RU78nlq44Wn4EkMZrW/l+Ca++Xhp+3eVfjygPtCxagfGs8CocSZ4n6DeM5u24hFzPoiCy
 mU27rv2FtQQ2Q0+eyRgO0vGGqUN2WH8tDwQQU83RF3vxuzVsqJXrbmwqB777ZtDHvGuXTAvpsWh
 Wkx6Q8lb5Mqr77NPoTRDtmuQ/bmSkg4pJUbwbibnnmNDn4eqeZdulOfDrQ7IoOiDMYqWJymPbuQ
 p5mObi8d7A+w0ResJxqQM2pBRcyfoVOmkqqKn1WyeQfd7u/EQxdcM75i0JioTzUdpjNFmmOxcvJ
 YLy6OsyJwZ1adekXVWmT1nA6RHjBykZzhUP8JGiXGXyMWRT5dPPRy1owZnPpavP7jTGXR5wsUfH
 v4LF6bI/odKWAOQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Resolve each export's effective I/O mode (explicit setting, else the
global io_cache_read/write knob) in nfsd_iter_read and nfsd_vfs_write,
and skip splice for reads on exports whose effective read mode is not
buffered. Update the debugfs knob comments to match.

That per-export check makes the coupling between the debugfs knobs
unnecessary, and it defeats per-export settings, so drop it:

- io_cache_read=dontcache/direct no longer sets disable-splice-read,
  which kept read_io=buffered exports from ever using splice.
- disable-splice-read=0 no longer resets io_cache_read to buffered.

disable-splice-read is now only a global "never splice" override.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/debugfs.c | 23 ++++++++---------------
 fs/nfsd/nfs4xdr.c |  6 ++++--
 fs/nfsd/vfs.c     | 39 ++++++++++++++++++++++++++++++++++++---
 fs/nfsd/vfs.h     |  2 ++
 4 files changed, 50 insertions(+), 20 deletions(-)

diff --git a/fs/nfsd/debugfs.c b/fs/nfsd/debugfs.c
index 4af1e6b8b212..d48297e45d7d 100644
--- a/fs/nfsd/debugfs.c
+++ b/fs/nfsd/debugfs.c
@@ -16,6 +16,10 @@ static struct dentry *nfsd_top_dir __read_mostly;
  * The default value of this setting is zero (page splicing is
  * allowed). This setting takes immediate effect for all NFS
  * versions, all exports, and in all NFSD net namespaces.
+ *
+ * Splice is used only on exports whose effective read I/O mode is
+ * buffered, so this setting is independent of io_cache_read and
+ * read_io=.
  */
 
 static int nfsd_dsr_get(void *data, u64 *val)
@@ -27,12 +31,6 @@ static int nfsd_dsr_get(void *data, u64 *val)
 static int nfsd_dsr_set(void *data, u64 val)
 {
 	nfsd_disable_splice_read = (val > 0);
-	if (!nfsd_disable_splice_read) {
-		/*
-		 * Must use buffered I/O if splice_read is enabled.
-		 */
-		nfsd_io_cache_read = NFSD_IO_BUFFERED;
-	}
 	return 0;
 }
 
@@ -47,7 +45,8 @@ DEFINE_DEBUGFS_ATTRIBUTE(nfsd_dsr_fops, nfsd_dsr_get, nfsd_dsr_set, "%llu\n");
  *   %2: NFS READ will use direct IO
  *
  * This setting takes immediate effect for all NFS versions,
- * all exports, and in all NFSD net namespaces.
+ * all exports without an explicit read_io= setting, and in all
+ * NFSD net namespaces.
  */
 
 static int nfsd_io_cache_read_get(void *data, u64 *val)
@@ -62,15 +61,8 @@ static int nfsd_io_cache_read_set(void *data, u64 val)
 
 	switch (val) {
 	case NFSD_IO_BUFFERED:
-		nfsd_io_cache_read = NFSD_IO_BUFFERED;
-		break;
 	case NFSD_IO_DONTCACHE:
 	case NFSD_IO_DIRECT:
-		/*
-		 * Must disable splice_read when enabling
-		 * NFSD_IO_DONTCACHE.
-		 */
-		nfsd_disable_splice_read = true;
 		nfsd_io_cache_read = val;
 		break;
 	default:
@@ -92,7 +84,8 @@ DEFINE_DEBUGFS_ATTRIBUTE(nfsd_io_cache_read_fops, nfsd_io_cache_read_get,
  *   %1: NFS WRITE will use dontcache (buffered IO w/ dropbehind)
  *
  * This setting takes immediate effect for all NFS versions,
- * all exports, and in all NFSD net namespaces.
+ * all exports without an explicit write_io= setting, and in all
+ * NFSD net namespaces.
  */
 
 static int nfsd_io_cache_write_get(void *data, u64 *val)
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4d983444604a..d4a88bef8444 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -5366,7 +5366,8 @@ nfsd4_encode_read(struct nfsd4_compoundres *resp, __be32 nfserr,
 	maxcount = min_t(unsigned long, read->rd_length,
 			 (xdr->buf->buflen - xdr->buf->len));
 
-	if (file->f_op->splice_read && splice_ok)
+	if (file->f_op->splice_read && splice_ok &&
+	    nfsd_read_io_mode(read->rd_fhp->fh_export) == NFSD_IO_BUFFERED)
 		nfserr = nfsd4_encode_splice_read(resp, read, file, maxcount);
 	else
 		nfserr = nfsd4_encode_readv(resp, read, maxcount);
@@ -6264,7 +6265,8 @@ nfsd4_encode_read_plus_data(struct nfsd4_compoundres *resp,
 	maxcount = min_t(unsigned long, read->rd_length,
 			 (xdr->buf->buflen - xdr->buf->len));
 
-	if (file->f_op->splice_read && splice_ok)
+	if (file->f_op->splice_read && splice_ok &&
+	    nfsd_read_io_mode(read->rd_fhp->fh_export) == NFSD_IO_BUFFERED)
 		nfserr = nfsd4_encode_splice_read(resp, read, file, maxcount);
 	else
 		nfserr = nfsd4_encode_readv(resp, read, maxcount);
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f59a55f89c88..779ad3a61172 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -1266,6 +1266,38 @@ static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	return true;
 }
 
+/**
+ * nfsd_read_io_mode - effective NFS READ I/O mode for an export
+ * @exp: export being accessed
+ *
+ * An export without an explicit read_io= setting follows the global
+ * nfsd_io_cache_read knob.
+ *
+ * Returns one of NFSD_IO_BUFFERED, NFSD_IO_DONTCACHE, or NFSD_IO_DIRECT.
+ */
+int nfsd_read_io_mode(struct svc_export *exp)
+{
+	if (exp->ex_read_io == NFSD_IO_DEFAULT)
+		return nfsd_io_cache_read;
+	return exp->ex_read_io;
+}
+
+/**
+ * nfsd_write_io_mode - effective NFS WRITE I/O mode for an export
+ * @exp: export being accessed
+ *
+ * An export without an explicit write_io= setting follows the global
+ * nfsd_io_cache_write knob.
+ *
+ * Returns one of NFSD_IO_BUFFERED, NFSD_IO_DONTCACHE, or NFSD_IO_DIRECT.
+ */
+int nfsd_write_io_mode(struct svc_export *exp)
+{
+	if (exp->ex_write_io == NFSD_IO_DEFAULT)
+		return nfsd_io_cache_write;
+	return exp->ex_write_io;
+}
+
 /**
  * nfsd_iter_read - Perform a VFS read using an iterator
  * @rqstp: RPC transaction context
@@ -1300,7 +1332,7 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 
 	init_sync_kiocb(&kiocb, file);
 
-	switch (nfsd_io_cache_read) {
+	switch (nfsd_read_io_mode(fhp->fh_export)) {
 	case NFSD_IO_BUFFERED:
 		break;
 	case NFSD_IO_DIRECT:
@@ -1654,7 +1686,7 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
 	if (verf)
 		nfsd_copy_write_verifier(verf, nn);
 
-	switch (nfsd_io_cache_write) {
+	switch (nfsd_write_io_mode(exp)) {
 	case NFSD_IO_DIRECT:
 		host_err = nfsd_direct_write(rqstp, fhp, nf, nvecs,
 					     cnt, &kiocb);
@@ -1761,7 +1793,8 @@ __be32 nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		return err;
 
 	file = nf->nf_file;
-	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp))
+	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp) &&
+	    nfsd_read_io_mode(fhp->fh_export) == NFSD_IO_BUFFERED)
 		err = nfsd_splice_read(rqstp, fhp, file, offset, count, eof);
 	else
 		err = nfsd_iter_read(rqstp, fhp, nf, offset, count, eof);
diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
index 1f05c83a3ea6..3cac25adf16b 100644
--- a/fs/nfsd/vfs.h
+++ b/fs/nfsd/vfs.h
@@ -184,6 +184,8 @@ __be32		nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				struct nfsd_file *nf, loff_t offset,
 				unsigned long *count, u32 *eof);
 bool		nfsd_read_splice_ok(struct svc_rqst *rqstp);
+int		nfsd_read_io_mode(struct svc_export *exp);
+int		nfsd_write_io_mode(struct svc_export *exp);
 __be32		nfsd_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
 				loff_t offset, unsigned long *count,
 				u32 *eof);

-- 
2.56.0

