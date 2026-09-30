Received: from mail-pj2-f40.google.com (mail-pj2-f40.google.com [74.125.227.168])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C2AF26738C
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 05:49:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.168
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790747343; cv=none; b=jqV2wW+DT7JkVQtwigmPh8PU2LhwqqszIJHRWHzM2QxkGUY9wxVBj5qiqtGYQBx5CwxOn0BazcoVxXxzO4iWVHq+/iObnA+0Fu93i3gDyO0npAhb9dkErG3dF4T20km55Agy6zr4GzRM69DtRUHmwwWndJ9xWL2T8y0sNqwgMSM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790747343; c=relaxed/simple;
	bh=HI+kteWvxzuj93yp0C1N+Icv4IotXRP5idAhITxPX8Q=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=s8FcJsN1J2X+a1j+D9gAT4JVyEtQ8CRPvI2FrPWqpCghvhS3Dekk7L3FFvF2AtPdwyvhQGYYbNzEYBc/IGlaROwWEmfSRD4RTEH13UfeU8gH4thQ0T1FtDgjgUD8C8gzuRrD2txlNX5TWH0S7x0qE+ITm/Iesaa53b21XgxgheA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=BjabHzds; arc=none smtp.client-ip=74.125.227.168
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BjabHzds"
Received: by mail-pj2-f40.google.com with SMTP id d9443c01a7336-2e22e123350so16286575ad.1
        for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 22:49:01 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790747341; x=1791352141; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=nXZceqnchUHvbEMpdlhU7EPyGBOadxt8Fd7Zo9s/Bt0=;
        b=BjabHzds8AMCyJXtD1Q6+MYSuh5zy4LYrSAJ7Kh/yy0+s/HgwZMCAucInDCq7zeKrz
         9HPO3biNphM9iT5Ke0BC4cPEsPRs6JH6YDNls5tNdKC0GYdGH7i45XEuRi/a255GjuOE
         ti7elBmm+VBzw1hU2oiSi+agmpwOgw4ytUoSvKeBY/AUozXzjrEqXp0SgkW8hlq8FCgy
         2Qx74QPfJ1PaKrb069CNxDSLQr6NcBDRII+aS9E7vIBkVdz1UEXp5pIGQZd1ffY7EiPR
         kkJ2KF30bCwMzVFlzjaEU6uBlOKmcz3rJA6GFmkfsy9USedpOi4nYaC8KWBmEnPPxb4j
         eWlQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790747341; x=1791352141;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=nXZceqnchUHvbEMpdlhU7EPyGBOadxt8Fd7Zo9s/Bt0=;
        b=UfUbSYXA55zJxd3sTu2rS+EK3AKzQDTPRxiXKhanhfo+bgt7k+0LuEBe6jyceqy4Pf
         zz9K6zCHcuPtX4evRqijUXhDb+8rI6qse0LlYgd3+FdAL5Oo/E9SQ3T2shlTmjk+5IWs
         xux9L17sUxCGWYJz+6r43DXMyfUQyCxTdCsejwaV7fvLiwzINAGT1ODSV+TyKE7wsLK6
         qJBbALBfpW/rWGuC02h38eS8n6ovuv1X+VGT8zjxM6osoBWM5zp8VHOuE4zc+WmCSAwA
         CBaMO+B47zLxm2xNh+4eiVXC589jQnsRPtulf6usevvjsKqjS1XYrro/+OuOsCvLnwtE
         FyFg==
X-Gm-Message-State: AFq9FYKR3WCFPxVLyl2Lmur7c3QUXkfQ0+kRIOPapzCcJ3NYak2O8S/2
	j2BjiN//zKxC1DBr4yw4B4cWqzad1ysjHLtOJE0scZalzf9XTbwiU70pni3y8VAs1BM=
X-Gm-Gg: AYBFou1eQA+LmZDp8fsON4p6+u+YTJ65TJZWJW3ugwPi2laYftJSy7ifjew27vv79qW
	dKoz+hYMQMdZSR8qZMGrUU2hutLZAUxz+jkkE72bKnoUNVby3oiYQb/YCSk69UBEXJ0B3rxk9bL
	tqufQygtHX2wrx4D9ama8BRXigvNvQq4ZbDKBb6J4+S6g7KH8sUU12LCVoILVSajggjIbIVl75j
	8Vr4GbtUQdFqmkNrB4jeB69J8sABduZ4Wi5Vr5RdnLxU1x8mgSlgDtzH7g1Ei2McmZuDVcJdzZ9
	h3aeb9HNPPM+dnNJtDxrJ6B0ZqPfH1/qWH8kwCiJi0Ex3TD6vnED/IIuptkX9H+gKJINIxDlxfd
	xrQPtxOnozFqaRpwILpSML2vCsYlPxCfT9IgsPGpoeiFoLwF15u49cYBHquJKt79xNk2y9NY+2Q
	onU/Jr2rinyOAtvKerbSoDInS8k8xP19Mx218DczG4pYNoYmMNyDBLpOxDd6f6GiiypGSn0FF3Y
	t2YoyaOLwKGlD0=
X-Received: by 2002:a17:903:2f8e:b0:2e1:2ce5:677a with SMTP id d9443c01a7336-2e2e49f7832mr3392965ad.16.1790747341188;
        Tue, 29 Sep 2026 22:49:01 -0700 (PDT)
Received: from bintable.tail83b815.ts.net ([123.215.20.10])
        by smtp.gmail.com with ESMTPSA id d9443c01a7336-2e2e5befd46sm1270055ad.54.2026.09.29.22.48.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 29 Sep 2026 22:49:00 -0700 (PDT)
From: Jinpyo Lee <bint4b13@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	bobtobabz@gmail.com,
	Jinpyo Lee <bint4b13@gmail.com>
Subject: [PATCH v2] nfs/localio: hold auth domain while opening a local filehandle
Date: Wed, 30 Sep 2026 14:48:49 +0900
Message-ID: <20260930054849.133920-1-bint4b13@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfs_open_local_fh() stabilizes uuid->net under RCU, but uses uuid->dom
after leaving the read-side critical section without holding uuid->lock
or an independent auth-domain reference.

Concurrent LOCALIO invalidation can clear uuid->dom and release the
association's reference before nfsd_open_local_fh() uses the domain.
Generic KASAN reported a four-byte use-after-free write in expkey_init()
when it attempted to acquire a reference through the stale pointer.

Read uuid->dom while holding uuid->lock and take an auth-domain reference
before releasing the lock. Pass the retained domain to NFSD and release
the reference after the server-side open and local-file bookkeeping are
complete.

The reproducer races a LOCALIO open with administrator-driven export and
cache invalidation. It demonstrates the lifetime error, but does not
establish an unprivileged end-to-end trigger. A source reproducer and the
complete KASAN log are available privately on request.

On current nfsd-testing, the unpatched KASAN kernel reproduced the
use-after-free in expkey_init() through nfsd_open_local_fh(). With this
patch applied, the same reproducer could not free the retained auth domain,
and no KASAN report was observed during the patched reproducer run.

The patched kernel also passed basic NFSv4.2 and NFSv3 read, write, and
unmount tests. A full kernel build with GCC 13.3 completed without a new
warning.

The vulnerability research and validation were conducted by members of
the Tobabz team as part of the Best of the Best 15th program.

Fixes: 70ba381e1a43 ("nfs: add LOCALIO support")
Assisted-by: LLM
Signed-off-by: Jinpyo Lee <bint4b13@gmail.com>
---
Changes in v2:
- Regenerate the patch in merge-ready format with the contributor's
  personal identity and DCO sign-off.
- Expand the lifetime analysis and runtime validation description.
- No code changes.

 fs/nfs_common/nfslocalio.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/nfs_common/nfslocalio.c b/fs/nfs_common/nfslocalio.c
index 85aa03a..e0a4273 100644
--- a/fs/nfs_common/nfslocalio.c
+++ b/fs/nfs_common/nfslocalio.c
@@ -269,6 +269,7 @@ struct nfsd_file *nfs_open_local_fh(nfs_uuid_t *uuid,
 		   const fmode_t fmode)
 {
 	struct net *net;
+	struct auth_domain *dom;
 	struct nfsd_file *localio;
 
 	/*
@@ -282,14 +283,19 @@ struct nfsd_file *nfs_open_local_fh(nfs_uuid_t *uuid,
 	 * make 'nfs_to' calls.
 	 */
 	rcu_read_lock();
+	spin_lock(&uuid->lock);
 	net = rcu_dereference(uuid->net);
-	if (!net || !nfs_to->nfsd_net_try_get(net)) {
+	if (!net || !uuid->dom || !nfs_to->nfsd_net_try_get(net)) {
+		spin_unlock(&uuid->lock);
 		rcu_read_unlock();
 		return ERR_PTR(-ENXIO);
 	}
+	dom = uuid->dom;
+	kref_get(&dom->ref);
+	spin_unlock(&uuid->lock);
 	rcu_read_unlock();
 	/* We have an implied reference to net thanks to nfsd_net_try_get */
-	localio = nfs_to->nfsd_open_local_fh(net, uuid->dom, rpc_clnt, cred,
+	localio = nfs_to->nfsd_open_local_fh(net, dom, rpc_clnt, cred,
 					     nfs_fh, pnf, fmode);
 	if (!IS_ERR(localio) && nfs_uuid_add_file(uuid, nfl) < 0) {
 		/*
@@ -309,6 +315,7 @@ struct nfsd_file *nfs_open_local_fh(nfs_uuid_t *uuid,
 		nfs_to_nfsd_file_put_local(&tmp);
 		localio = ERR_PTR(-ENXIO);
 	}
+	auth_domain_put(dom);
 	nfs_to_nfsd_net_put(net);
 
 	return localio;
-- 
2.50.1 (Apple Git-155)
