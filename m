Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.181
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793299318;
	b=DPOPYYytSm7EDObGv4hpStu+kv0rV+tf6sDqO6aLovg4nS3HECUst/C/R3wjoPPVZK6Z
	 JEmv75lmdqs10MpjZdTPIcfSa59ErF09JZYSevxBX8KQWdeysbB9jIJ5JD74a++LaigQU
	 mNtJ1batJPhEXvVEEtQ1us2Pr7ON9KUV0kV+KM8aelsiNwAQUb5GNZ7NEhQYcUEaUi3dH
	 pQvb5J+wn/qsLuhbDpMga5bk+MZWmDKx7yZZoaW7UJuherPKEJWiqsuCfy3Gjk82aXoqK
	 NrMSHNr1/cl2LjHQcL2wZq5wmgYdmdUPs4E3UN1A5R5VS5SfnLy17ZE3I1QgpVI4HKQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793299318;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=K0Ok9TQI+SuNX/lPLG7KUa57f1lAuPS37E/kbzVt7FM=;
	b=OEq1z42xUIW6gozn7H5LojRbsomMdryuHjjSYymwOxv5oxjbsn/rFgTpXOt2rfY0bsAO
	 HeuYj4GUq+HSwdhbz5DDyhVlgeupf9mwxgAL7QGDf+QV2+ncMHNzgNGk11POf6ZKaNYpP
	 cBw+Q05t/t90mX1R/QuUk2yw3ZOcRGCKE1b7eX4hoiJ2M+C1qsaM/n2P7Uu5tX2UdfkdD
	 NcXpDn9aK7nrxn6ijfkeGfPx5R8vo0oLKUAZSza3yoemQckzh17zZvTaN418o3XForfts
	 mVtJNY0ZvU+F+MSMPxtYcVQYcwCUzGkmW0zOacqSi3IjIp4OiqbWiR67TsldfUI+fug==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=V61jNZIB;
	arc=none smtp.remote-ip=209.85.167.181
Received: from mail-oi1-f181.google.com (mail-oi1-f181.google.com [209.85.167.181])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 81ED2606A31C
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:41:58 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 81ED2606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=V61jNZIB
Received: by mail-oi1-f181.google.com with SMTP id 5614622812f47-4b28d9537bcso770024b6e.0
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:41:58 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793299317; x=1793904117; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=K0Ok9TQI+SuNX/lPLG7KUa57f1lAuPS37E/kbzVt7FM=;
        b=V61jNZIBBPRHebS0YmjDtSl7hjCCJDCCLgIE+o5hcO7uLpNhtwkY9wOpEZsdtYRvBq
         j6UscXxwbR+Vq47N1+PFDwXG+CIxZ+ZDZ2MyR+Gkaauukbx3JWNfYcfJI5pAuEli7eWG
         TeTR23xw2hdqNBquQtoJO/6PIpLuABPVky22avRNkOfpn8CoACRmc1fjNOZHxoXbEXqo
         C+9EDEv3Gf2nPLj+/CMFQ5XMaDKU2s2Gh4Qy8oM5PHZOU5+DjIVkztDR0u2uA8hKZcd1
         mPZrfHy7E6lTnB9s1TduqZQAm4HKmDZ+aX9v6FjlLPQgWIBKcCEieCLXAUtF0VQ/m5Xh
         1qmw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793299317; x=1793904117;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=K0Ok9TQI+SuNX/lPLG7KUa57f1lAuPS37E/kbzVt7FM=;
        b=mYcZPaegWtyVrtr221iD0dlTRE+gX8a41oj59TUSmdJf6vbh1/yW7G/YzirNMwRpnZ
         qMNoyQ4UpWRau65po7arPmEBNVVOSHK9TyPXpzzV1e/oVmyOPWj3y+1mpCYbRKJcZbFn
         jvR6TqWSuZLWpZYUsQPeq6ZsOBUg4CqkxZWr3j4Eynvq9FTsF6NoYBgMXD/Sl+vQ2Be9
         JJhiGFTHQN7uDFmbDhC68X8FyN9F8t8UGhLNNay05GgiCObvPB4DMZsZDf7Zm7Pfgnod
         aKegZAvzCH92EZdg21eHO0sYO2cIg2bV1YplmWI9Z8TOX1zJrHOvn9MmRKckEsyde+9w
         ZhiA==
X-Gm-Message-State: AFq9FYI6cGCaN0EWatgpHoVcv0gJJS4arAc6Jd69HeVKWmjaeERP5j3P
	7CYqrSeFXuZqktWPJ1vTzBv9A93YbTwHExexKPlYVYK8Y0lLobON7EN0UwfDagcAEALosEsxN6m
	NEe49
X-Gm-Gg: AYBFou0yFG23vpSZBvDEx0nkUpXHbYQzW6a3scP1aqLO+7YqAUT6ptxsUBbc8uTh076
	dT1EmoXooKHtgAXyIWV7LMvX4ayshwp6PJmwGEJfsFop6rwKmU24PbJwCFit26LGJZwAwgsW1QU
	ZzE+CxLVRKABhfGG8lrDpuIjES3Fb3zoG3oVxc4eqIb9yLm+WrNnttBmIYNE6qw3V7jk7edSGTG
	DAdD5ziRLQtfDA6+IgrTz9u6ax9MK+TEhsLW5rgC7KbafYaNVd1oov9/8UcajHGDQ6tRIEV4yaB
	u1X3z6im6I3VCflqxUJeci+gQJ/G+/M7fo7F2WsofbwFEAjc7XaA0UkV+CN56/v63NLsZOW9O5u
	xIk1bCduG5suK//G31cYabqnIb4GnVYaSRc0z3RfcBetwFZuw7A1DHcXWhw4Tq7RNCq4TI71hkw
	1UxSI0tN1Ovi0rQ+I8LtL7vg7w04Ei8DOlZPgK7wGGhqtg9+V4CE+mazX30OXWAJXzUQ3PURK48
	WWrmxtfYDn3NDiqZCW6bL+VN1vw12mv51/Syf4h6Mo8COkaIUhrUGUaHITbLNTy9UHulxdmQJWb
	vy63Tk71bkHq7kVKSMhydV5zW4UtukTjD9kJOUO5ngqvjSOKqoat3Bt6Q0G+AbSsBa7np7R/h1r
	aMjFhJgOoafUczyimbYKEsA==
X-Received: by 2002:a05:6808:11c9:b0:4f4:e6eb:128a with SMTP id 5614622812f47-5640df8e030mr25325b6e.25.1793299317126;
        Thu, 29 Oct 2026 11:41:57 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([12.117.181.174])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640e23b76asm7161b6e.11.2026.10.29.11.41.56
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:41:56 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/6] pNFS: don't reply NOMATCHING to a layout recall with I/O in flight
Date: Thu, 29 Oct 2026 14:41:48 -0400
Message-ID: <cover.1793298149.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
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

From: Benjamin Coddington <bcodding@hammerspace.com>

A client can reply NFS4ERR_NOMATCHING_LAYOUT to a CB_LAYOUTRECALL while
flexfiles DS I/O on that layout is still outstanding.  The server then
treats the layout as returned, and that I/O can reach the storage device
after the recall has completed.  We found two ways to get there:

 - A bulk recall (FSID or ALL) that finds segments pinned by I/O
   invalidates the layout stateid and replies NFS4ERR_DELAY.  The resent
   recall skips layouts with an invalid stateid, finds nothing, and gets
   NFS4ERR_NOMATCHING_LAYOUT.

 - If another path has already invalidated the stateid without a
   LAYOUTRETURN, for example pnfs_destroy_layout() after an ESTALE, then
   either kind of recall gets NFS4ERR_NOMATCHING_LAYOUT right away.

Patch 1 adds a tracepoint for bulk recall replies.  Patch 2 clears
NFS_LAYOUT_BULK_RECALL once an invalid layout's last segment is freed;
flexfiles marks every segment for return when its I/O completes, so the
flag otherwise stays set until the layout header is freed.  Patch 3 fixes
a leak of segment references when ->prepare_layoutcommit() fails, which
would otherwise leave the next two patches answering NFS4ERR_DELAY
forever.  Patch 4 has the bulk walker collect invalid layouts that still
have segments, so the resent recall gets NFS4ERR_DELAY until they drain.
Patch 5 does the same for a file recall, and sets NFS_LAYOUT_BULK_RECALL
so that I/O needing a new layout doesn't wait on a LAYOUTGET the server
won't grant while the recall is outstanding.  Patch 6 lets flexfiles
writes go through the MDS while that recall drains, even when the layout
carries FF_FLAGS_NO_IO_THRU_MDS, which RFC 8435 makes a hint; without it
those writers retry without any delay until the drain finishes.

Patch 4 was posted earlier on its own; its changelog is below the fold.

Tested by sending FSID, ALL and FILE recalls on demand, resent every
second after NFS4ERR_DELAY, while the client's DS traffic was held (DS
stopped, or dropped with iptables) during a 64MB O_DIRECT write:

 - Unpatched, an FSID recall gets NFS4ERR_DELAY, then
   NFS4ERR_NOMATCHING_LAYOUT on the first resend with the write still
   held.

 - Patched, FSID and ALL recalls get NFS4ERR_DELAY until the DS I/O
   completes or times out, then NFS4ERR_NOMATCHING_LAYOUT.  With no I/O
   outstanding the first reply is NFS4ERR_NOMATCHING_LAYOUT.

 - Patched, with the layout invalidated by NFS4ERR_STALE on an
   OPEN_DOWNGRADE, a file recall gets NFS4ERR_DELAY until the I/O
   drains.  With clora_changed set the I/O is cancelled and the resend
   gets NFS4ERR_NOMATCHING_LAYOUT.

 - With FF_FLAGS_NO_IO_THRU_MDS, a second O_DIRECT writer to a file
   whose recall was draining wrote its 8MB through the MDS in 23ms with
   patch 6.  Without it, the writer retried about 330,000 times in ten
   seconds until the hold was released.

Patch 2 was not exercised directly: in these runs the layout header was
freed once the I/O drained.

Benjamin Coddington (6):
  NFSv4: add a tracepoint for bulk CB_LAYOUTRECALL replies
  pNFS: clear NFS_LAYOUT_BULK_RECALL when an invalid layout's last
    segment is freed
  pNFS: don't leak layout segments when prepare_layoutcommit fails
  pNFS: don't send _NOMATCHING_LAYOUT if still doing IO on a layout
  pNFS: answer a file recall with NFS4ERR_DELAY while I/O drains
  pNFS/flexfiles: write through the MDS while a recalled layout drains

 fs/nfs/callback_proc.c                 | 19 ++++-
 fs/nfs/flexfilelayout/flexfilelayout.c |  5 +-
 fs/nfs/nfs4trace.h                     | 49 +++++++++++++
 fs/nfs/pnfs.c                          | 97 ++++++++++++++++++++++----
 fs/nfs/pnfs.h                          |  4 ++
 5 files changed, 158 insertions(+), 16 deletions(-)

-- 
2.53.0

