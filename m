Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8639F456E0C;
	Tue,  4 Aug 2026 10:55:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785840927; cv=none; b=VdRCAR2YPxQ6QrgQ+pATvbAkEVf9slyRIP2tmg/PT4UFsyyusNCnSm+INfs+n+MEyebMJfjTF36+0hWNUVm7tyGT/+BYIAZHR+/5lJj+ansaASTqqZNs4YW9LzbyqLl1fXIcqx93jDPVaOOvdI/EhE9iq2FHPLwvHQXwMAvxX2Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785840927; c=relaxed/simple;
	bh=L4HfWEiYw6glmwU2i2GuDQ80x6FTEYKOYzeaisiQX2U=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=BxG8EhvSB57pkFDW49Bm1VPeHqkkpMIZ7lf2JVKAsWd2k1DIhVH3twWi47blyywJxHgRNGszFprXVmqP9WLKBS7h6xQGxFsD/tpY7YA3dm5491vWJX9NP6shnw3ylBHckm2YQaczFJM6+Jl2AN75YJ1AmQRZPTuEJM0Bfo+xjp0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EyPAmK8e; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EyPAmK8e"
Received: by smtp.kernel.org (Postfix) with ESMTPS id C2F87C2BCFD;
	Tue,  4 Aug 2026 10:55:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1785840926;
	bh=L4HfWEiYw6glmwU2i2GuDQ80x6FTEYKOYzeaisiQX2U=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=EyPAmK8eXdtdHciBsJAQG9q5jSfFQ9doJ0O+LQG0lWiF7/VwOcEe35aY6psxvpFNS
	 FTKSvlpyIjp3mvg4PuqQ9NoDuSNtXRlhZmuiNbuIvVT+oy4eAgYcd7fjjJuVZQmMMZ
	 FPKz9u+oiie5aUyJKy4DOWQXCS1veMsAT/UstMejwU4euji0wEY3yjzK+9v6FV+3ho
	 7C+k+PVbsa3qFtuB+22e8P731IlaS6tefyztB3M6rybyXraZUmPtSu7+XEKLNmshXC
	 lFWO/rzQPno82gU7HZGPz0Us9gqvbZq2V63yiQTuVQfbDSsv/0RVbx/kJhzlycZZWe
	 5HVvhr8qWx1sQ==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A7408C561E6;
	Tue,  4 Aug 2026 10:55:26 +0000 (UTC)
From: Junrui Luo via B4 Relay <devnull+moonafterrain.outlook.com@kernel.org>
Date: Tue, 04 Aug 2026 18:55:03 +0800
Subject: [PATCH 3/5] NFSv4/pNFS: check the sscanf return in
 nfs4_decode_mp_ds_addr
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260804-nfs-fixes-v1-3-1544df970e7c@outlook.com>
References: <20260804-nfs-fixes-v1-0-1544df970e7c@outlook.com>
In-Reply-To: <20260804-nfs-fixes-v1-0-1544df970e7c@outlook.com>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jonathan Curley <jcurley@purestorage.com>, 
 Michael Bommarito <michael.bommarito@gmail.com>, 
 Junrui Luo <moonafterrain@outlook.com>, Yuhao Jiang <danisjiang@gmail.com>, 
 stable@vger.kernel.org
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1786;
 i=moonafterrain@outlook.com; h=from:subject:message-id;
 bh=NlRN6hKnIpiIx0oge92JnJ9wPbGlz66/OhgU3FbRdvI=;
 b=owJ4nJvAy8zAJVb4wiKgu++DA+NptSSGrMKjMt+v1r9OV1p6mvu5FF/T4rC/618WR2rcd1F2a
 Gjckr66VLmjlIVBjItBVkyR5XjBpW8Wvlt0t/hsSYaZw8oEMoSBi1MAJnJ6A8MfzskVJ5uLgl1y
 txy+vDVi0yrfuc8yjlREuG76+qGny6/LnOGvvLaV/rnNN3velCcuCf7Wtl32dHyWlMy77IT5x7c
 y+d7lAACChE6c
X-Developer-Key: i=moonafterrain@outlook.com; a=openpgp;
 fpr=C770D2F6384DB42DB44CB46371E838508B8EF040
X-Endpoint-Received: by B4 Relay for moonafterrain@outlook.com/default with
 auth_id=909
X-Original-From: Junrui Luo <moonafterrain@outlook.com>
Reply-To: moonafterrain@outlook.com

From: Junrui Luo <moonafterrain@outlook.com>

nfs4_decode_mp_ds_addr() splits the r_addr opaque of a netaddr4 into an
address part and a trailing ".ABC.DEF" port pair using two strrchr()
passes. The address part is validated by rpc_pton(), which is passed an
explicit length of portstr - buf and never inspects the port octets.

The port octets are converted with sscanf(portstr, "%d-%d", &tmp[0],
&tmp[1]) and the return value is discarded. tmp[] is uninitialised and
nothing constrains the characters after the last two dots, so an r_addr
such as "192.168.1.1.x.y" leaves both elements unwritten. The stale
stack contents then become the destination port of the data server
connection and are rendered into da_remotestr, potentially leaking
client stack memory to the metadata server.

Fix by requiring both conversions to succeed and rejecting the address
otherwise via the existing out_free_da path, matching the port octet
validation in rpc_uaddr2sockaddr().

Fixes: 16b374ca439f ("NFSv4.1: pnfs: filelayout: add driver's LAYOUTGET and GETDEVICEINFO infrastructure")
Reported-by: Yuhao Jiang <danisjiang@gmail.com>
Assisted-by: Claude:claude-opus-5
Cc: stable@vger.kernel.org
Signed-off-by: Junrui Luo <moonafterrain@outlook.com>
---
 fs/nfs/pnfs_nfs.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs_nfs.c b/fs/nfs/pnfs_nfs.c
index 648c95b78eea..63fb3695fdb9 100644
--- a/fs/nfs/pnfs_nfs.c
+++ b/fs/nfs/pnfs_nfs.c
@@ -1114,7 +1114,8 @@ nfs4_decode_mp_ds_addr(struct net *net, struct xdr_stream *xdr, gfp_t gfp_flags)
 	}
 
 	portstr++;
-	sscanf(portstr, "%d-%d", &tmp[0], &tmp[1]);
+	if (sscanf(portstr, "%d-%d", &tmp[0], &tmp[1]) != 2)
+		goto out_free_da;
 	port = htons((tmp[0] << 8) | (tmp[1]));
 
 	switch (da->da_addr.ss_family) {

-- 
2.51.2


