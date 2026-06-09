Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A29D23C1080;
	Tue,  9 Jun 2026 17:48:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781027303; cv=none; b=cSGIdeOPcK12SVpJ+Fm8Yh95BR+HHVpoUXPTFSxum6ooUYlbHm9+ZShckZ1ftGdqJnm9VG7bizwuD7zP/5SoZXVuIgy0R8favsS4TlQu6FV9V/IItwrjTOhWg2fYTgFI0s8mXipkSw3jOTf0ukn5gzzvVR66VAJp0L+vGXRLAR4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781027303; c=relaxed/simple;
	bh=+BX/F5t6UbaW8f6cZR75zWLul5OcpS5cpITd0rvsxtg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=iEslCKESs0RO0kepbIU3tB9lNklMP2QqtYQzmF4hGZ5x0hZ+aLh88FWgBiK2bGtrZdnFzv5Am4r1U7G2Qcc0NzDDAy5mEj5RTaEyDVOVvdhzpI3KO+W3S9SBTcyVNB9T/SscdXJjKFcWHEKWDbW3/VIC1DvI1mIBSBYkgWB087o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QEl77KvL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QEl77KvL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A82611F00899;
	Tue,  9 Jun 2026 17:48:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781027302;
	bh=NAEvMwCPKo9IvCK1nLH/PJL4Fw8CuWJ5RzWY701L9xM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=QEl77KvLDsKCmp6gGSBKnkFj9V8ioOhzQcv8wPizgm7fmfF5qgnHec1PCtoLgXDPU
	 uUBYzM1lSUWnIKike9myNPMBsIemUv6YU67XYhDzbS/J0CDkuZUce+cxfLzsQVzLQm
	 GKRew/QFXtsCpXTCifSDA1rb0/9mdr/seVWAyNuzCG5FOFgZuifxpVaEZB0Q4zmJkW
	 BqCcjxIPpeyWEIdCyupA8E32yefp2mbnVL8EGS2NNNT+fs98J0Npc1FQta+1DSg7Hk
	 bijJhQjOWkuPVF3wHFwS2txlahiynE9LbZHgW5MSOOuVOdnXuayvEjC1t0NXRLawq5
	 z4W555iVl/xLA==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 09 Jun 2026 13:47:39 -0400
Subject: [PATCH 18/19] nfsd: move nfsd_debugfs_init() after
 nfsd4_init_slabs() in init_nfsd()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260609-nfsd-testing-v1-18-e83acead2ae8@kernel.org>
References: <20260609-nfsd-testing-v1-0-e83acead2ae8@kernel.org>
In-Reply-To: <20260609-nfsd-testing-v1-0-e83acead2ae8@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=1015; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=+BX/F5t6UbaW8f6cZR75zWLul5OcpS5cpITd0rvsxtg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqKFG9dCBaL/cvkqBCak7RJnMmxTv4ARyFTSfz+
 sw4cJCyfDOJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaihRvQAKCRAADmhBGVaC
 FatlD/4kLYC0tw7agDidFUAyET3IzP2Rbr5TmNekndcADManWYWNLTU6jUuLED2I358vLLtRDKI
 XPmj7xTn0JnZt7wrZZrS9Wt4XMOCMysAfjpA8Fs0GgqrcoBCucgrEsikZLLRvun6ESvT4C5RyQD
 7rmUNCNwGJo8Xy8FPM1BnSzXBW/ySW1mw14E4YXRWvBNrWUtLdnQDTUxL85jcihOK5tmipX1FQA
 swUrVSM4hHPixvS7xTKibkDWNbKxOHylVdTyGOivFZqh1zF5ecwjYYKZSOTIH+DyiyyDOs9jKD6
 ELGkQ6RUsGaqEY1Fy4pHpRzjPilb9iXhxv52zt2rFx0ij2lofhrlkfPHHMRyJ5n7BhqdZ+oVtx9
 6ccRTrDB9X6Ilc8+C1WrtSpMQUqTmbkKp4naWlA+a5f1DP1mX7cbxwwHJuJ239ydX+WpvR0hD0b
 zLWa1sbg8XmIeuvms5BtqbjEPV4EDXwIGZXqLlRu2zBvg3SJQ2KsqQ4W8zmNriuRCS3xH1/Q+NX
 rDIvFWd5/dRf2+P+o1+B6s/kijbW+ufEEOvtOYSd7Ec8qoSbVSinOlQR9x/ASKyEE70X3r8GkNu
 oZekwBBL9ZuHbn1kjPLewewnxZzFHlkq72H6jwH1KBVuveNunTvF4hCSDeuRRL/DM8VoLDEAJ+y
 Ho+9Ty3I9kHI4Ww==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_debugfs_init() runs before nfsd4_init_slabs() in init_nfsd().
If the slab allocation fails, the bare "return retval" bypasses
nfsd_debugfs_exit(), leaving orphan debugfs files with stale fops
pointers into the freed module text.

Move nfsd_debugfs_init() to after the slab init succeeds, so the
early return has no debugfs state to clean up.

Fixes: 9fe5ea760e64 ("NFSD: Add /sys/kernel/debug/nfsd")
Assisted-by: Claude:claude-opus-4-8
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfsctl.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index f3b3154b16c5..b69e5f686e9d 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -2557,11 +2557,12 @@ static int __init init_nfsd(void)
 {
 	int retval;
 
-	nfsd_debugfs_init();
-
 	retval = nfsd4_init_slabs();
 	if (retval)
 		return retval;
+
+	nfsd_debugfs_init();
+
 	retval = nfsd4_init_pnfs();
 	if (retval)
 		goto out_free_slabs;

-- 
2.54.0

