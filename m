Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6704B48C402
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 12:33:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791808437; cv=none; b=uwNpXjleQTI9Jp+VwFi8AVLH8xciVhvpKpVzibzjh0BPqzIBajDYC66pkRNU4rUsVcvOMzIbcWwPKenMiSpsPsYYbEcy7u+uE4h0HorGgpPrZWA7MZLF8np/5UOd+Scvpd1NtwUry2pjUFNJaPcL+T8YjN5lRMa9qZMuQ7ePJvQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791808437; c=relaxed/simple;
	bh=7ntQqVHFrCtLgAEvE25V4biuKGyUxv2yj/hH/nUXmaA=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=YzY3o++2+5Mu9BVJUZBWsVUOKG+rCIH0uv6qnG5DpHEeBJtyV9DobqBV2OEjld+jObyV2WkZiRiUiESJDelKeXCkDi5feN0cXqrGGFL7yNRRhOlxnYlTFIZ82Pv9PlUpuU/72O2HUqKDP3jdnYXlNHMO0rQe6bMu4RJwYLWygwU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=m4dEzw8N; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="m4dEzw8N"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AD45A1F0089B;
	Mon, 12 Oct 2026 12:33:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791808436;
	bh=rnEy07uMgofJLjy4nczp53885oSLGhBq6K7PeFBWkQ8=;
	h=From:To:Cc:Subject:Date;
	b=m4dEzw8N1PoSeIpsusnXibFapbozTV/SicULNQ+QxccHCvUxKYa4/xzulkDUwiyA2
	 iBiHS0VwsBPYoRRd3BBvH4LGgJhWRUGh6tTqcuEaOVyVSHbgJ6kEBmY02IKA6fcdw6
	 6fXzoKY+UAmFcP6DQ0lj4nLVLjCFIkMGKJ59kxM/Y7pkY0gMwTJcqTqE2KW1RaQDmB
	 a/uPqmZJhRZ1NyrkKPaz4NHZaU9CDhpC9qStVPCL8Fuat06V2gU0eWYkmjQ8tHeFot
	 LuVuUTMiRfFVEnOXOoWzQU0stlDANqLm+9kbn0eJtud8+lbfxhNsTXXpO3WipVzpNs
	 ib4VTVBCJsXWQ==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH 0/3] NFS: Modernize decoding uint32 arrays
Date: Mon, 12 Oct 2026 08:33:43 -0400
Message-ID: <20261012123346.123126-1-anna@kernel.org>
X-Mailer: git-send-email 2.56.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@hammerspace.com>

We've had several reports over the last few months people have tried to
add bounds checking to the various places that need to decode a uint32
array. None of them update the callsites to use
xdr_stream_decode_uint32_array(), which has all the proper bounds
checking already implemented. These patches make that change.

Thoughts?
Anna

Anna Schumaker (3):
  NFS: Have decode_pnfs_layout_types() use XDR's decode_uint32_array()
  NFS: Modernize the callback decode_bitmap() function
  NFS: Modernize decode_getdevinfo() bitmap decoding

 fs/nfs/callback_xdr.c | 24 ++++++-------------
 fs/nfs/nfs4xdr.c      | 55 +++++++++----------------------------------
 2 files changed, 18 insertions(+), 61 deletions(-)

-- 
2.56.0

