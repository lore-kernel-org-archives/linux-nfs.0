Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 741ED4AA3EE;
	Wed,  2 Sep 2026 18:54:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788375283; cv=none; b=kO8rTf/d2XwH7TevkY/omERNC37u/shqrfF3qpWlRyIg9Kaio/3Fu5SMFBC6Y5NUgsORKLMjEUuA9CCElbzFM4s4chpYWPqKCLeF7f40qfG5tqlHJpwq9UiB1DYSyc3m7bTYOA4bOWt3zhNOLj2PL4gbh7sKW2Mv3367gm3+6+M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788375283; c=relaxed/simple;
	bh=VWgUMRv5aJ2zjeS6YKsq3e8KbhjttMaS/aYVwuLYaKM=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=f0zfDcyhIztopwNPZ1R7yZHvMvzXx1DcPSCNQSpNDDwT486ihhvOi3qYjESHhMZnQAqmpw9vJsKR6ciFRhsjyAw14QCMB7h+YhGnCYoUU+o5wnjnKcdiI16BkCzGFT24E6IXwZmmYrqA33XbyP0KSLBUtRUzoFMQ+zAcx3FhJdE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nefYLobx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nefYLobx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 39F071F000E9;
	Wed,  2 Sep 2026 18:54:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788375278;
	bh=QFNn0+4QGU00NAAtvmof5gk2veLhV+oZ9VVmbEJ3P/g=;
	h=From:Subject:Date:To:Cc;
	b=nefYLobx0m9CGX/fsjrt4ygYygVL1Yg1by1oNuBPJ/PS4f05YC5ChwCdUMIxEg5ZM
	 +AgvJcAQMmRjqiX5Rob5lfMYFUQehE2n8a9DGMgUNZkLtt+O51ixXm5dG1Rhl6/GHG
	 H315XIOfvn7PZmH9rnlhgLVDhiQz7/1/Sb8Y/uU2NT0qR/JD1IxTV1KQHnGhIq4I/t
	 823V7MlS6SN5sOoG+KDhJTeWgwDDOIDgoya+XH56pJcX3ZS2cS7ex725t6vNJbzBPd
	 eLEg837//aa0ZGk4WfiPURx/p+JTAVk/w3lQpw7Mo5zjNGawl8le/k68Ley5NNno7v
	 ifr+5FqHvqa/A==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 0/3] fs/nfsd: accept a backdated timestamp from a
 delegation holder
Date: Wed, 02 Sep 2026 14:54:13 -0400
Message-Id: <20260902-delegts-v2-0-383cb289ce88@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/2XMQQ7CIBCF4as0sxbDUFLElfcwXTR2oBMbMNAQT
 cPdxW5d/i8v3w6ZElOGa7dDosKZY2ihTh08lil4Ejy3BiXVIK1EMdNKfsuCLE6DvjjUykB7vxI
 5fh/SfWy9cN5i+hxwwd/6bxQUKKztjTNEujfy9qQUaD3H5GGstX4BOsfMCJ8AAAA=
X-Change-ID: 20260901-delegts-e91a648f1427
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>
Cc: Thomas Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1911; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=VWgUMRv5aJ2zjeS6YKsq3e8KbhjttMaS/aYVwuLYaKM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqmHDnL6hKHcWD5eBuA+RCSO4OqpRWJvo0HQ4nH
 kJDb+AuVQmJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaphw5wAKCRAADmhBGVaC
 FQVYEADSQgFPnkQEOvGA2reWex1OlWPAU8ib9UtQ1ZzqD+B2G91AHFsYWS2+LuQiaEsd7/BIP91
 REr/ekspNWmfnxkLGc56JVZ2zoSiCdxcylNa4aEqz4ghpcVIDUI4f2xJSRI1HxVTu2fsY315nV3
 l3V1OyE+Wc7hrw2BwW08z6uJROurKPbPZGP7+4YY7cBic/R3KGKjpJ18ORf+EbEPbN4SFFmm6u9
 0AHjQFtNft6YijoN4D3h2iz3nRnsWwIA5qtdabFMBmJrROLlD0UZoWhN3qrhPs6ALmeHV+BMMKX
 sfLs87jriZtzOwIhI+DFcL55qcJuU9AidBneeTJuyQm+5ZLkIXGU00WDcCa0ZhdxgQqSGQXJA01
 iodfMv8au1/ts6TEmUlj3Q9IAUw0LtoW8hKHCXitza8X8hLimuZYVQ5M5ar1IbJ9kprONXOiwws
 iT4httCeEgA+Ka8Bxf/EV6TdqFIzlzpP5femhra1azc5NfIZZ5vjYnZGyWshA6TvdYEvHQFL6zk
 m1Lr6YBUuBi9YeEj3rjzPHVWbL2v5AoBYaglL8goS7hTnDCF7KjHPUJXDnTt1lgw8mRKy8xODBa
 uHUUZxstVZ3yN0K/3vuPzG8eJs7roGfbceGCgmI9zK5i5mJLiiBj0NdpUstjgX2M1juAI1fb/EZ
 kc57WkhluA8GsBA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

The main problem is that an attribute delegation has strict rules about
updates can be done, and that prevents applications that backdate
timestamps on files after writing them, (e.g. tar -x, cp -p, etc.) from
setting them properly.

We could fix this on the client by making it always issue an RPC for the
SETATTR, but that would harm performance in these common use-cases.
This set allows the server to accept some of these backdated mtime
updates, by changing how the ctime is handled.

It'd be nice to see this in v7.4.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Changes in v2:
- Split the change into three patches
- Stamp now in inode_set_ctime_deleg() for a stale update, so nfsd need
  not compare
- Drop a SETATTR report that matches the inode, so an untouched file
  keeps its change attribute
- Set dl_setattr only on the branch that carries a c/mtime update
- Compare against the inode, not the grant-time snapshots (Chuck)
- Set the ctime whenever a CB_GETATTR moves the mtime
- Take i_rwsem before the CB_GETATTR comparison
- Drop the unused dl_atime, dl_mtime and dl_ctime, and make
  nfsd4_vet_deleg_time() static
- Link to v1: https://lore.kernel.org/r/20260901-delegts-v1-1-9937f7ee4370@kernel.org

---
Jeff Layton (3):
      fs: stamp the current time for a stale delegated ctime update
      nfsd: accept a backdated timestamp from a delegation holder
      nfsd: compare CB_GETATTR times against the inode

 fs/inode.c          | 17 +++++++++++----
 fs/nfsd/nfs4proc.c  | 63 +++++++++++++++++++++++++++++++++++++++++++----------
 fs/nfsd/nfs4state.c | 49 ++++++++++++++++++++++++++---------------
 fs/nfsd/state.h     |  8 -------
 4 files changed, 95 insertions(+), 42 deletions(-)
---
base-commit: ac579868af0c900d8fd9c8cfe9e10db46ccc5a75
change-id: 20260901-delegts-e91a648f1427

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

