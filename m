Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.216.97
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794007727;
	b=0ACMun5aTIk7pUnLGspK7e2mpjdovtoNITbELP+dVlC9PNhzpSojcYtlt7aHijQsm/st
	 j9GWGFFyCbCEeY/1ELOl+GMwt9mLDwm9X1bX4ID7+MKPnPZg3YT+etCxcmwYiQIcm7G4a
	 jarR+pBTp2B2jXaR9D8f4n5Fzz77j+yggefLS8neplqePMf+wK9xoRDDBtzsp39eI8UKT
	 fNT5qXmqE3dgz9v0b7sbBPuUM/yHaVYq70FqTjRpcdEMyFW/3Sydgnk6D1JHkgYJ67ybG
	 C6tmnw32gNo7OswwmKPMDAq6I3rstFCdTL5lX9xBB3Z5GcspsT7h+BH/VRwLCwuu/Zg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794007727;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=4Owt92U9/K297y9PboHuFVnZHHyIFy57q0eKvHeAnyg=;
	b=mPnWdfb2KoNNfMj2dxCg9sWmbWTVuLfkFKF8zLuhMIpsRQ1FRTuhlHi/mdBan3nm2bJ+
	 lnMBcyiWR7kI0r/r6Uvr6ZucKu1x9b67t1O8O0oUeqrIFGx4zGHoLBk9fZ8K6PTiInnAq
	 0ROnFpIBIKohukGNKPT9zVB7jRMPcY07FWVmKRLHKtpvsqokW3iuNrEWg/rOssCcOltPU
	 1ISe57gbSvHL5YyOByQtNaU1YbdMaIA6Ys6pXU8kUE0n+vR4eHo9exZkriEtV0tD1eyJ4
	 nkoj8ZnvaMyFqn2fUVH7p9yZfFYVdX/HaVu/Xu+h/svfFvfRUIRnCnWlpuw3u99iZ7A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	arc=none smtp.remote-ip=209.85.216.97
Received: from mail-pj1-f97.google.com (mail-pj1-f97.google.com [209.85.216.97])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A6CF9606A32C
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 23:28:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org A6CF9606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Received: by mail-pj1-f97.google.com with SMTP id 98e67ed59e1d1-3b0e0e65adbso554949a91.3
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 15:28:45 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1794007725; x=1794612525; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=4Owt92U9/K297y9PboHuFVnZHHyIFy57q0eKvHeAnyg=;
        b=FT3qLASnVzV2WkcjaX4fdn5pExpQa2aPIoICyH7HJcCgDJhoKHRKPnkqy3pfCM92Sz
         XrWxGI1XuggIzkunX6YXWHYVdIxzKz3wpEpEDEoKR1Vu0AnIV3DtJ27ClBpUhi2XBw1L
         SAW3B4URVCNC/VyXGQnobGy5TYxKKpHfB+Q6+WAuEldmafVCe2GSmAvwCuYHqfJ7q0w1
         OENfvn/lTsssfQz4AQTAI371aHjQTrmN1Uzoy8K60rhO3smeUkG/4QI3zbGpxuCD2Y4O
         tfMahpU+yjmKtI/aahOU9kepOVa0+zJZ8/W4BhQnsIDcLZdYU8FPOvKoysZOcJ5wIaY3
         y4Jg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794007725; x=1794612525;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=4Owt92U9/K297y9PboHuFVnZHHyIFy57q0eKvHeAnyg=;
        b=0b+1kJ1/I4yuecSMX65JfTmolLwsmBMwfsIEOYYEyZij8cjwBZkykQf6D4BA58N8Px
         O09OVMw8GUac8YK0qNL1DG2cGz7yBufVZShdmmsWrVLHSeDQf2gEZpRomciSlXGF6SLf
         pvHxP00bsYnQD7RImUBNNIv1A6OH1kHlfxtNhU8HkpCpF+NLInzsC1ctYebI7QI6Wv2l
         bpj8XGTDU9dC0+UGTnZsc0sVBoJYIh0yRcDBjdI/TDDvE6K21X6bYJJtWZw5VsiqOO3Q
         iMpnie7kksNyY20IBHLXyJ3JqUCKeAOIwDaJKjcTVSZWyUwBBzsweuRONJJMnyhCW3Zm
         /pag==
X-Forwarded-Encrypted: i=1; AL+hErEEVQYG5ItZW8wFH4fYLkv/Iet1vkUKMVAI+PvQx6hHXwO0T91OHsbHPiNIqtQIgXJ6s2lfjRmFrJE=@vger.kernel.org
X-Gm-Message-State: APuU4Z9JJ9eEdm+nMHvNu61okrpJFbbJDlndhuXPD0eE+HcqvLuLNGAo
	Y8aUr+9qAwRiGyqCZrXby30yeMVawI2wuLSUhvvQpCXZ1DF8ziJOlolgnAf6P40VTsbPf7FBcEF
	Wv03u2Wk/lthseIFyTP9k/80fa+cK5gY5VXKV
X-Gm-Gg: AYBFou2ONfc43IdchM9pQvCqmuYIfop9jqi71QmJKIEpVhLtrbOrbRUnn1+AoStf16t
	27lEVNG7KNQc1RXvpyGnNY3MNRHbDevT2Q4rMFLopX0L+IMCgoOWuxxPSeZkNzu+ysmoOCrTgE6
	u9ctK+rEPz/lpPGEFfPYOVza4aOtAMNLeDrt//xMY7IJTEkdOtgRqO7t9Sxv9omEYMynPAucLhK
	CW1XZh7/rb52ZhOm8jRXcDGiMJTf5kQOQXAudPpAutQc7o7AWhHH08HUMT+Wu5NyCYtYaDsVyvc
	OeHD4yxfuSU6LNV5Tgwx7vkCq8rrSxphwLCFeIGCmcvJZqRmMW7mwTs6f+0VYnmnRYq2WtSrGG8
	LZWjmXoYdI9Q6yRgrTqrcapToh37pm5jWUlIXEwE=
X-Received: by 2002:a17:90b:5107:b0:3b0:ce1c:e74f with SMTP id 98e67ed59e1d1-3b0db6ee67bmr3731051a91.27.1794007724872;
        Fri, 06 Nov 2026 15:28:44 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id 98e67ed59e1d1-3b1057a07e4sm394446a91.2.2026.11.06.15.28.44
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 06 Nov 2026 15:28:44 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 4D12234039C;
	Fri,  6 Nov 2026 15:28:44 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: cel@kernel.org,
	ebadger@everpuredata.com,
	jcurley@everpuredata.com,
	jlayton@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	slingappa@everpuredata.com
Subject: [PATCH v3 2/2] NFSv4/flexfiles: limit transport disconnects when cancelling I/O
Date: Fri,  6 Nov 2026 23:28:43 +0000
Message-ID: <20261106232844.2176820-3-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261106232844.2176820-1-tmenninger@everpuredata.com>
References: <20261106232844.2176820-1-tmenninger@everpuredata.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

ff_layout_cancel_io() cancels RPC tasks associated with a recalled or
revoked layout segment. If any matching tasks are found, it then calls
rpc_clnt_disconnect().

rpc_clnt_disconnect() disconnects every transport attached to the RPC
client. A data server client can have multiple transports, while the
cancelled requests may have used only a subset of them. Cancelling I/O
for one layout segment can therefore disrupt unrelated I/O using other
transports belonging to the same data server client.

This is particularly disruptive with RPC/RDMA during data server
recovery, where unnecessary transport disconnects can result in repeated
reconnect activity on otherwise unaffected connections.

Use rpc_cancel_tasks_and_disconnect() instead. Matching tasks are still
cancelled, but only matching requests belonging to that client that
remain on the transport transmit or receive queues are marked for
disconnect. When such a request is released, SUNRPC conditionally
disconnects the connection generation on which that request was sent.

This preserves cancellation and draining of I/O associated with the
layout segment without disconnecting unrelated transports attached to
the same RPC client.

Fixes: b739a5bd9d9f ("NFSv4/flexfiles: Cancel I/O if the layout is recalled or revoked")
Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 4419ded8fe586..5c289737366f2 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -2611,10 +2611,9 @@ static void ff_layout_cancel_io(struct pnfs_layout_segment *lseg,
 			clnt = ds_clp->cl_rpcclient;
 			if (!clnt)
 				goto next;
-			if (!rpc_cancel_tasks(clnt, -ECANCELED,
-					      ff_layout_match_io, lseg))
-				goto next;
-			rpc_clnt_disconnect(clnt);
+			rpc_cancel_tasks_and_disconnect(clnt, -ECANCELED,
+							ff_layout_match_io,
+							lseg);
 next:
 			nfs4_ff_layout_put_deviceid(mirror_ds);
 		}
-- 
2.53.0

