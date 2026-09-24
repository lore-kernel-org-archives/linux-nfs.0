Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DE2243F0BF
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 21:22:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790284969; cv=none; b=pWiNzrl2aRy1vKBvGOgCtXKcydGYSGKEvCiOE8KyjllgkBt9nngzNCBXnILdl5cpCU/f/FX8iOfNRQmwyu5vVSsRE3u/9aos4Lqgb/1k1bzkgEG5BlKV4ni2BuJDhrPJ7wQm6qLZ5/kTKLcl4dKU2nb4xdoLGdcU2ImJIjuq+MQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790284969; c=relaxed/simple;
	bh=guOul3OZzsr5X5/DbHj+ZE+dZUtfh58jQrP3j95D3A8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=qw7FTXRWzie25Wxbon1MEt3mPxJ2o+k7A/qqwuE8XXDKwaaJ77kqiqoLQPfeY9R2Kdz711etUPA64pm5OXqemr32Fj+lRCrFIEBhQrhVV12OBNtYcpHYOctMOlscZrAO4jA23+mr4ugiU9kU2JAZ8tZYC1oua1qZB9jwiTM8WE8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=keqzcdWA; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="keqzcdWA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C29CE1F000FF;
	Thu, 24 Sep 2026 21:22:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790284968;
	bh=P9uniVPvzqWD6nV2/L1x9hIJEtYPhBTlJd5K8v1EfRs=;
	h=From:To:Cc:Subject:Date;
	b=keqzcdWACf512zPUrwYaRC1aMdXaJ6stmK02XJNfI4xUXB9UiPH4MnMAj5VFC1HX8
	 vKuFtqJGUWSrsmnGqqPJeVykE+x4fVpuM2W+sJpQ/zk5pehy2arhAGl3b0RjUw2nLp
	 0BDL0VgQ2tOXA5iydSZGxBzuri58ZqpiJlCPKCnqVYGUqawn614QCgBkv8mGfK1AB9
	 6zleWP9zBRfrSveNEyp1ihLd3vOs4LtHezDn1nP6uVz81vZQ22N4RQ5Exj6lOJMKYP
	 d1lb8zwA49+kWfp8Kq6DEY33r2p6HD+bW3CYYLwKECEnE7PqCAm1BtKe4jrUpPsoSa
	 iq5wmGx7DWuaQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna@kernel.org>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 0/2] nfs_common: Encode an ACL with fewer than three entries as empty
Date: Thu, 24 Sep 2026 17:22:44 -0400
Message-ID: <20260924212246.114355-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Both ACL encoders in fs/nfs_common report at least four wire entries
for any ACL that has entries, then walk a_entries[] up to that count.
An ACL with one or two entries sends the walk past the end of the
posix_acl allocation.

nfsacl_encode() builds only the NFS client's SETACL arguments, and
nfs_stream_encode_acl() builds only NFSD's GETACL replies. The fixes
are separate patches because a combined one does not apply to the
stable trees that predate nfs_stream_encode_acl().

The NFS client still caches a GETACL result without validating it.
This series does not change that.

Neither over-read has been observed at runtime. Both paths were
traced from the code, and the patches are build-tested only.

Patch 1 changes what the NFS client sends in SETACL, so it needs an
Acked-by from the NFS client maintainers before it goes through the
nfsd tree.

Chuck Lever (2):
  nfs_common: Do not encode an ACL with fewer than three entries
  nfs_common: Do not stream-encode an ACL with fewer than three entries

 fs/nfs_common/nfsacl.c | 6 ++++--
 include/linux/nfsacl.h | 5 +++--
 2 files changed, 7 insertions(+), 4 deletions(-)

-- 
2.55.0

