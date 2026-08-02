Received: from mout.gmx.net (mout.gmx.net [212.227.17.22])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9379733372A;
	Sun,  2 Aug 2026 19:53:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=212.227.17.22
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785700441; cv=none; b=BEZ9P0/PwncKSwt78y/euoUSms30A6Wc3pVM3ruAklG5jUXe1HvvJ4w5pFQcj3K7RB1St6+gzcIEgZUMcKPgukM+TsEw7iP2V3Uu4O/18VuEMUkn+n5Yf4nv0qsObZx1ClFzIThMv3FurjRHF0Wj/MhuMxBedolgGQuFs1dNJX4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785700441; c=relaxed/simple;
	bh=tOyL1MX/wrLgobpgrKYAPsa6BdEV4e/5Vj4kKXXEwtU=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=stWBV60XAVFo05KHmCOSVSKwV9hy1nY0RoWlufAhzOrHp3ptL2M/5Jcn9aX7cy0kvvN9DW46aoj4WG7ZW564pyovUWq/ypkzY9Lx49OLVe2y1kzS8TQWSyiALHn6eLpTYOjq/dwfFwTW4RHCeEGmogK/+djpzwpbHM5CeDw0L2w=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.de; spf=pass smtp.mailfrom=gmx.de; dkim=pass (2048-bit key) header.d=gmx.de header.i=f3lix.dev@gmx.de header.b=Bsts+v3W; arc=none smtp.client-ip=212.227.17.22
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=gmx.de
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmx.de
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmx.de header.i=f3lix.dev@gmx.de header.b="Bsts+v3W"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmx.de;
	s=s31663417; t=1785700416; x=1786305216; i=f3lix.dev@gmx.de;
	bh=y9Zv9UpFpTKW3PFQAXIO0YB9OSuAlzqIekC9g9ZXVy0=;
	h=X-UI-Sender-Class:From:To:Cc:Subject:Date:Message-ID:
	 MIME-Version:Content-Transfer-Encoding:cc:
	 content-transfer-encoding:content-type:date:from:message-id:
	 mime-version:reply-to:subject:to;
	b=Bsts+v3WC11a5/RmQ84wW/c7UTahjmx1zQm2aPUFLeOi78ffVEbw4ejVy6ozixNY
	 pjybKp97TNlvl0r4wn4C54GXJ+Z5FktruZXWinH0VaTXWAH04oVs9nE5NRV4DAGEt
	 JlNF9YIi4VtFarztjg3YDQ/am8QmCCbrSPVUsFp25KGZ+yfeGRodlsjWOMRenaoc0
	 kD9pr4hF4fZ/736TB41RoUUwlhiP7My74PN5gkX8wMWHjuwVh2wyZsTXCJx61VAX2
	 eFWAtVuqpNWqWXA/ZSjxL3pH1IVCpH+zUVKbB8zXwlXSAvKD6FvmVwYdKwj3fXc2m
	 9mSNjtQp6NZTYBnYbA==
X-UI-Sender-Class: 724b4f7f-cbec-4199-ad4e-598c01a50d3a
Received: from client.hidden.invalid by mail.gmx.net (mrgmx104
 [212.227.17.168]) with ESMTPSA (Nemesis) id 1N2V4J-1wvCiV19Fn-00vnO4; Sun, 02
 Aug 2026 21:53:36 +0200
From: Felix Hoffmann <f3lix.dev@gmx.de>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Peng Tao <tao.peng@primarydata.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] NFSv4.2: request mode after CLONE
Date: Sun,  2 Aug 2026 21:53:28 +0200
Message-ID: <20260802195328.175328-1-f3lix.dev@gmx.de>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: quoted-printable
X-Provags-ID: V03:K1:ITsA7HnDJ31piaBdi8ltGLagdBx0I87PCdFnC/2MSq1+tDj88DB
 Opb0h38hP0MvAdFC21YakXPp7a8Wd8yxiM1XUAqhafKf0YEUGvb3oOCtDRj1Pm9b2cqZ16S
 ILiVHbdtcNM+rgj3diBiyifbgrs1eFZKySDMDCfanLkEbN5nzZwMegfq2UBRUoHa8ybco6w
 lxIPQgZqrF7tJTYVeEFrA==
X-Spam-Flag: NO
UI-OutboundReport: notjunk:1;M01:P0:NhsNSUC8QEs=;GAucF6F4t0bgjrZXYKYGxGMRH8G
 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

The NFS server can clear setuid and setgid bits when CLONE modifies the
destination.  The client currently omits mode from the post-operation
attributes, so the cached mode can retain setid bits after the server has
removed them.  A local process can then execute the file using those stale
privilege bits.

Request mode in the CLONE compound's GETATTR.  This lets the ordered
post-operation update install the server's mode before CLONE returns.

Fixes: e5341f3a5762 ("nfs42: add CLONE proc functions")
Cc: stable@vger.kernel.org
Assisted-by: Codex:gpt-5
Signed-off-by: Felix Hoffmann <f3lix.dev@gmx.de>
=2D--
Tested on x86-64 using an NFSv4.2 loopback mount with Linux NFSD and a
Btrfs export:

  - before this change, the client retained mode 04775 while the server
    stored mode 0775, and the privilege transition reproduced in 10/10
    non-debug runs
  - with this change, both client and server reported mode 0775 and no
    privilege transition occurred in 10/10 non-debug runs or 3/3 KASAN
    runs

The reproducer requires write authorization to the destination; NFSD
rejected the same operation against a non-writable 04755 file with EACCES.
A working reproducer is available privately on request.

 fs/nfs/nfs42proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index ab86246fc364..35a4909d51b7 100644
=2D-- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -1302,7 +1302,8 @@ static int _nfs42_proc_clone(struct rpc_message *msg=
, struct file *src_f,
 		return -ENOMEM;
=20
 	nfs4_bitmask_set(dst_bitmask, server->cache_consistency_bitmask,
-			 dst_inode, NFS_INO_INVALID_BLOCKS);
+			 dst_inode,
+			 NFS_INO_INVALID_BLOCKS | NFS_INO_INVALID_MODE);
=20
 	status =3D nfs4_call_sync(server->client, server, msg,
 				&args.seq_args, &res.seq_res, 0);
=2D-=20
2.43.0
