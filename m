Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7D357481FA6;
	Tue,  9 Jun 2026 17:47:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781027265; cv=none; b=G+fIw4Q9xeM6Ljkk5CZhlGmI+nHDbzY8pQ7Xkvob8Gwz5p91OodVS62MEC8llUIphx/8PLx9viiFamGRgpNZGNTWDsBQn9OtHckmj/g8kQr3kH+GEk+irloRO4zNLHs01Hv8dx0dzm1uTrb0xJcY4CwRk7BJt5WGaIyJ5jg08Kk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781027265; c=relaxed/simple;
	bh=Njyudir1NCYRGXB06ZfKdv7N/igxUrpsbmhuHqB1M8U=;
	h=From:Subject:Date:Message-Id:MIME-Version:Content-Type:To:Cc; b=d0cCFksVbnQ6q0Ut4pi8jGLx25LSRHBwOa2mm1WKSKzr0yMN3UhykozK8KRcZ5xbFl2aH7hedZdjhOrzbfflSaeG7ugMZowS13ebTV9OGIQ3yXyAlraOs0u0qczdG19g/E3PdxmszuoI2zEWxafGVfqc/ioiY8j4kXc2GBIfv7I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HjBVdBOR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HjBVdBOR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 47A121F00893;
	Tue,  9 Jun 2026 17:47:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781027264;
	bh=aYFvkEwegwGP33gQAeUhTs7n9K746Dc8adRAuN+IpYM=;
	h=From:Subject:Date:To:Cc;
	b=HjBVdBORrKrYBtWgI/v+Hj3RoVzm1E86Tl++nMgA0QPbRUg/LqFJz7PqRjcZ0lu2n
	 ls4bzmYK/OU+Hx4GCuPqFOaBpIY45uc6yk+YDiZY+vjD6+g9CjV8JDxFDFOUFA77P1
	 Oj+TZhkZVjANIfFpnFat7QP6PGMyZwM/b4rn9xhD80m79+BACSUE4mQR/onxVBV6ei
	 +P+OucEWWcKsgNu9/bSsyEvL/hJYGXQ9xEpEUqZq0C8FuDBML8Rd8RNF8V4v8yeEpU
	 no7E/mnJJwovumiWm/dQOTg54P51hQMq5smCb4dPzUe3zVbqJfA86z2K/RslZ5+HdU
	 MXUYzGnRanqtw==
From: Jeff Layton <jlayton@kernel.org>
Subject: [PATCH 00/19] nfsd: more bugfixes
Date: Tue, 09 Jun 2026 13:47:21 -0400
Message-Id: <20260609-nfsd-testing-v1-0-e83acead2ae8@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x3MQQqAIBBA0avErBMmLZGuEi1Ex5qNhRMRhHdPW
 r7F/y8IFSaBuXuh0M3CR24Y+g7C7vNGimMzaNQWLTqVk0R1kVycN2Wd806PxoQJoSVnocTPv1v
 WWj+/H/uoXgAAAA==
X-Change-ID: 20260608-nfsd-testing-688a82433c50
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>, 
 Eric Dumazet <edumazet@google.com>, Jakub Kicinski <kuba@kernel.org>, 
 Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, 
 Christian Brauner <brauner@kernel.org>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Donald Hunter <donald.hunter@gmail.com>, 
 Lorenzo Bianconi <lorenzo@kernel.org>, Qi Zheng <qi.zheng@linux.dev>, 
 Andrew Morton <akpm@linux-foundation.org>, 
 Muchun Song <muchun.song@linux.dev>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 netdev@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2829; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Njyudir1NCYRGXB06ZfKdv7N/igxUrpsbmhuHqB1M8U=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKFGzpoFHMSR/DWKmekrR861w47rEW6osNo+Xu
 B6ql5v3KnKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaihRswAKCRAADmhBGVaC
 FdZKD/9pbvM4BL8zN1jHXyAsa3w5fOmC3olD996ngFRUjNsRhhYmzKTJ1ar+Qd4Nx+0pKH8nr6i
 I3cxHTU/R+8/P6am5TEWLbSdDKWWWv37NahaC6ivav+H59/jeeUybmqEh2znhncSpixITRRHf16
 7/WAhBnBaK5vXMCeBcGBDnUEBGSABBuywGi3ALFvWMB/2X/pjKIXAFmGCwLr+K8kwGo9A+E2vzQ
 N+AEbbUNTj36B0HRrVlFv4/wGIJzen1ZeoiXmeR1fEEhjiCcoLOoVIbZBJXZNapkHXVyJMhjDF3
 //fWmQKqFCHAd5kZ/STj1WbplhzYc8TcKEnXDcCGBRFAyBR1Mtb8kcnyCCZQp4+fzppjT4g61ij
 /BQ91L/pIUwbjVOxDXCwlqDLVgLJMyMh46d2ct2GTLgFM7bh3p/3qlSaSaHO9aQ2NM/Y1OKGESj
 eFgiKo7/HtMTRqQFfqnGLbxxhj3xlsvNOCWPv9k3Tt9MVkvLUbSVTHnBDI8bWcANKkWy6aZEMfe
 XU6lsn9QydWskQeJsOIKn12TAcSpseb/7TLDuzIMkiDsJ0c2AOMjmA0jObB7u5Un9RhoyDLPWtj
 R7g09oOx83MetnAEH7cnDVrDf9jQOWO9Z9VA7FusccGiuzDYkoagLLKGfmoAjMgvm5Zuelte+oP
 o4DlhDmSavF4Wjg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

This is a pile of bugfixes found via LLM inspection. Most of these don't
seem to be easily triggerable or require specific conditions, but
they're still bugs nonetheless. Please consider these for v7.3.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
Jeff Layton (19):
      nfs/localio: fix nfsd_file ref leak on nfs_local_doio() init failure
      nfsd: clear opcnt on compound arg release to prevent OOB read
      nfsd: add missing read barrier to rpc_status_get dumpit seqcount retry
      nfsd: fix netlink dumpit error handling for rpc_status_get
      sunrpc: defer rq_argp and rq_resp free until after RCU grace period
      nfsd: check nfsd4_acl_to_attr() return value in nfsd4_create()
      nfsd: add filehandle match check to nfsd4_delegreturn()
      nfsd: validate nseconds in TIME_DELEG decode paths
      nfsd: remove premature NFS4_OO_CONFIRMED in CLAIM_PREVIOUS path
      nfsd: fix version mismatch loops in nfsd_acl_init_request()
      nfsd: fix FL_SLEEP being set unconditionally for all LOCK types
      nfsd: add fh_want_write() for early-verified SETATTR in nfsd_proc_setattr()
      nfsd: fix clock domain mismatch in clients_still_reclaiming()
      nfsd: use test_and_clear_bit for somebody_reclaimed to prevent lost update
      nfsd: reject reclaim LOCK after RECLAIM_COMPLETE
      nfsd: validate sockaddr length per family in listener_set
      lockd, nfsd: RCU-protect nlmsvc_ops dispatch
      nfsd: move nfsd_debugfs_init() after nfsd4_init_slabs() in init_nfsd()
      nfsd: initialize DRC hash table before registering shrinker

 Documentation/netlink/specs/nfsd.yaml |  4 +++
 fs/lockd/svc.c                        |  4 +--
 fs/lockd/svc4proc.c                   |  4 +--
 fs/lockd/svcproc.c                    |  4 +--
 fs/lockd/svcsubs.c                    | 52 +++++++++++++++++++++++++----
 fs/nfs/localio.c                      | 16 +++++++--
 fs/nfsd/lockd.c                       |  6 ++--
 fs/nfsd/netlink.c                     |  2 +-
 fs/nfsd/netns.h                       |  1 +
 fs/nfsd/nfs4callback.c                |  4 +++
 fs/nfsd/nfs4proc.c                    |  3 +-
 fs/nfsd/nfs4state.c                   | 22 +++++++++----
 fs/nfsd/nfs4xdr.c                     |  5 +++
 fs/nfsd/nfscache.c                    |  4 +--
 fs/nfsd/nfsctl.c                      | 61 +++++++++++++++++++++++++++++------
 fs/nfsd/nfsproc.c                     |  7 ++++
 fs/nfsd/nfssvc.c                      |  4 +--
 include/linux/lockd/bind.h            | 12 +++++--
 net/sunrpc/svc.c                      | 13 ++++++--
 19 files changed, 182 insertions(+), 46 deletions(-)
---
base-commit: dd886cc1628e04a21a34016635b2b833916a1003
change-id: 20260608-nfsd-testing-688a82433c50

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

