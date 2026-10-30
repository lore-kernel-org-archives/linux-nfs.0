Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793374225;
	b=E1xdJDab+aUZmXmSzjYJHPawMwf8sY6Zo7gSUL4wupZhbS6gH+xWttqiQkBDtCU2AwF9
	 gYm732UecnOwol5FHJq40Lt6g/3XxMm2HAnLH1jwadn9+nLgcN8Z3ocXZvctaHLzTHq5f
	 MhRIuZUm66ahVKztehcNViz/hLYGpavy1fslweY4i+I52battZC4Z/g8uKPx30k7dgAax
	 glWRf7EOR9JioRbNkJiahFBuun9LQIdml6zl/7jZA66t6y7iXZmQWQliPr5/SsyACuebQ
	 YuRzN0bcnvsbP5jZ74Jje2sRfoe9eZg0Y/tsbgH2SPiNe3mrbgJbyr4ICMwbTr/h8Iw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793374225;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=Cj10TEVlv60fC01PtBjn/3X3LG3F7w2N7jGbdCC0dGs=;
	b=MpYyQRt8irO2kiX2NtK30UCiYDiatDezK37LsrfXcA3kN6xWuGcVEP+Kp06mY9vKHuFz
	 8rqsKGFdG/QueqCtVAGCQXmh8ymXAWMAOI+W64BzzLFobdDoPO+0vCjcF5Y6wZz/xA7kO
	 N5NvXzYkEv6BuAxIs2Ki4v/PkeSLwib39TbJUdM18NpR4/WyOAr8DbxVTMQsKKT8h6j/c
	 CRnW6T4P/QopWgeo7bw+0Vc66q1/dNZ6ew7vJGNa9rg5BXl1ZEt24r53W47zg9Cr45nvD
	 PtJxZu8bvwpCCfT9ssaLCQYhqjsvvXawH1a92OINwfOKzhqV5y+zU4ryY51tX0xYx+g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=o+rPn0Bf;
	arc=none smtp.remote-ip=209.85.161.54
Received: from mail-oo1-f54.google.com (mail-oo1-f54.google.com [209.85.161.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 86031606A324
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 15:30:25 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 86031606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=o+rPn0Bf
Received: by mail-oo1-f54.google.com with SMTP id 006d021491bc7-6deb848ddd7so661079eaf.0
        for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 08:30:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793374224; x=1793979024; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=Cj10TEVlv60fC01PtBjn/3X3LG3F7w2N7jGbdCC0dGs=;
        b=o+rPn0BfR2yWZBIr7llE/tDg+IpPzUJ/qr+jLbw+TzVkX89b1ChugcHBmIanwxSJGl
         pEWcrf6PQPRoxZpbRNBk5HVIytZ2qbGr/R5bI5SUVc6wLl7646r9Dmqxz8JfMSq0hHkB
         Bxbyd2IPBzzuCWiVTuwhEAaw4Ndxxb+JYtnIoxyuuIkxjrYF5Pcqnmf04nyTGurDF6z8
         Cx6fCxZI+9iAardNsGhSdAWSjmyLcaA+CBBelhdVsXhpyiysYzFBfWBB1oUZ1gIFV4k+
         xyT6vJALPd89aH1ieQt8c77XKDzhx0g1ydtHeGr6ZCFf6A7L8+3GBeonQ+YL9aYYltMi
         mgMQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793374224; x=1793979024;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Cj10TEVlv60fC01PtBjn/3X3LG3F7w2N7jGbdCC0dGs=;
        b=t9l5yHMl9W3aKRCAPMuX91Ymh2O6qAPvCWZshp05CzqTxHFLGAbv63a0r0ZcQM3opN
         0vdqmhOBE8G2jpkNWTpb30Bdo+LwtJLMQiO5eyw9rOy4hXVwOKevYaIMdDG2nIW2IGvr
         qIEE/NiRjiQlhuMwzqvZyIiAQ0bFlSnjKO9H4nGen2g8B6nr3hbnFTU2rxynnxgf3fvU
         d0/5gLNvnLasYkm4pxZ68cE28fBTGQC519id7tK4lU8zPooX1gEq1bQLQBgoAzUbL9uy
         9MiOAtpftsPKE2icJIPVXVu4+YgqRmKJtbH8p2Sqgi7t/yh1e9yHMRE4xlodnDxMVBlx
         hSyw==
X-Gm-Message-State: AFq9FYIPVC2bbfOWBxuZDmuAsiY8hmoXRM0KmGWkLFzQHfGelcXaO8S/
	o/Rtoer92IZhRc0buJpZVdhjNqCzbPO4fBNQRzDW8W8qhxBMJMU7C5G4OJfiJfydF4M=
X-Gm-Gg: AYBFou2XZANSFJGzS3Q4YdVi4CVT3q7tjLYtdSooMJudSqPAgOO/AUiKP+ze7aV4v+S
	P5RHJ/jv0SHV7UpWy2G86UiXk0Rgt5LluvdToiLSuL7FV8ZQFkTWfmyNjjJ0LhrpNkHvJC5aD+M
	IQnSGAOWkeO3+9cG645l9A3FPW/HmxGUGysWxWb8PSKs6+/bm1vfRL5j1l+f/9DDUNAc6E9jLJW
	CCP84Q5UQ4nEjEfXThJ/0LWphPYPhkjvlIo9BsiYIvkfxJGpaTXXVOXM1heLfJ1Mqn8x7nWROEn
	J9eCG7HicNPiF4FnH5AhOi9KRmQctOK6JMAizfwiZKEB8keofTmf1ePGjOW+ydu6paOnc6blQEV
	RSTfWRyVXpiHMLTsM8t3F2vnnmlLZjb34AFKwcmEPNJmJyEy9J2Ev0U1WmL2jFnlk2MfEqtYlov
	/hXmV7upx8RR9koErV/QgS/eK31KLFzFwvJ8QsBuiLbyZ0unUV6eXfQjRDSoxOGYrbVtwIdfUG7
	RnUx6cRCCtfr0DZZqZ+QiBFwPZ0YI8NgRLZ9/sPXPVGB3m67rZFGevhUppN8An8ppg6RPfsVBWp
	tP7R5hNDXY7Jryij4i08S+oPv2uTIBhVRgiXL1fZL5Eef3xxG77srFPxz1LKADfgVqk4omiPzgF
	bnFTIzJHaydTMPGUK+Y+o1FAaOsempzk=
X-Received: by 2002:a05:6808:c413:b0:4c0:12f3:6007 with SMTP id 5614622812f47-5640d91b989mr1875965b6e.4.1793374224348;
        Fri, 30 Oct 2026 08:30:24 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com (219.sub-174-201-19.myvzw.com. [174.201.19.219])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fe0fda0sm1840376b6e.13.2026.10.30.08.30.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 30 Oct 2026 08:30:23 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/6] pNFS: don't reply NOMATCHING to a layout recall with I/O in flight
Date: Fri, 30 Oct 2026 11:30:16 -0400
Message-ID: <cover.1793373378.git.bcodding@hammerspace.com>
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

Changes in v2:
 - Patch 3: only reschedule the LAYOUTCOMMIT if the layout stateid is
   still valid.  Putting the segment references could free the layout
   header and leave NFS_INO_LAYOUTCOMMIT set, so the next
   pnfs_layoutcommit_inode() dereferenced a NULL nfsi->layout.

v1: https://lore.kernel.org/linux-nfs/cover.1793298149.git.bcodding@hammerspace.com/

Benjamin Coddington (6):
  NFSv4: add a tracepoint for bulk CB_LAYOUTRECALL replies
  pNFS: clear NFS_LAYOUT_BULK_RECALL when an invalid layout's last
    segment is freed
  pNFS: don't leak layout segments when prepare_layoutcommit fails
  pNFS: don't send _NOMATCHING_LAYOUT if still doing IO on a layout
  pNFS: answer a file recall with NFS4ERR_DELAY while I/O drains
  pNFS/flexfiles: write through the MDS while a recalled layout drains

 fs/nfs/callback_proc.c                 |  19 ++++-
 fs/nfs/flexfilelayout/flexfilelayout.c |   5 +-
 fs/nfs/nfs4trace.h                     |  49 ++++++++++++
 fs/nfs/pnfs.c                          | 105 +++++++++++++++++++++----
 fs/nfs/pnfs.h                          |   4 +
 5 files changed, 163 insertions(+), 19 deletions(-)


base-commit: ef30b3efb7e8bae94d790a6503a595e1051323e7
-- 
2.53.0

