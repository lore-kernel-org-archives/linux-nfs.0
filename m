Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.42
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793627817;
	b=e11Cl46l9celq3zXSsd1D5SNP7xRbiKB4QNv4Sc8w7ilBkROGM1LJYtEyFYNseDbvX+O
	 s+HNAvXX4IgjeydCl0KpBQawQz9NjZYsatdzXa6uaARzWZ66Rfko03MQzuucIiub3egKd
	 jXEkw4clk6+gyks1WlaLNiinMukceNvoNVympSXdTMqB6nL3RzAv5lFuxo8tg0qtLDA2y
	 /LpJdlJFXDiSBwj8IWVIg9hjE8CiqP82UBt+pft7PGZX/fnjHvCf7YwKlIbaGElh4Ad3c
	 qN1z1h2DCDtrEkiGU3bJGXJsgpe1vQ9n6z39w3QNzqPkha8RcmCy66sJ3qRQZP4lzWg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793627817;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Gm-Message-State:X-Gm-Gg:X-Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:X-Mailer:MIME-Version:Content-Transfer-Encoding;
	bh=au77HHa+Dty7tCJBh+bZ8vOUp/MMUb5GeVIUjXYA6QM=;
	b=e60Z6dqsRgkBWFvExB1To0Nvw1/07O7R0DjuIEZsyirBCBn5Y5zNx+4ZzQ75jPsf3KYQ
	 7fXCtgtRkYQ50USGXIcfFmIHqkK9dgbqiZFZk2N3XQ4lg41+mcCKEWzgulhMI8nSXZEfT
	 mkOTUFdrpCIjJvWaA5u9gcGhwuIdvfYHO5i2YjX0xak9lTTvtRGi94Y1v3aTVKOzL661L
	 vHvYQKp2p8zscYiLHzuDII30AoEZOsPBDwXUXOgGjeGFurcJgQzRn+kp3xT/mzw7Viula
	 wsNMHWWcwqrhouIn+BeGMtmBcWL4bvXr7/SIGtEhdan5Od0cPAy1/VEbFrVchhnj1sA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=BKcgnHhn;
	arc=none smtp.remote-ip=209.85.210.42
Received: from mail-ot1-f42.google.com (mail-ot1-f42.google.com [209.85.210.42])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E62CA606A326
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 13:56:56 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org E62CA606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=BKcgnHhn
Received: by mail-ot1-f42.google.com with SMTP id 46e09a7af769-843cf077f10so3643555a34.1
        for <linux-nfs@vger.kernel.org>; Mon, 02 Nov 2026 05:56:56 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793627816; x=1794232616; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=au77HHa+Dty7tCJBh+bZ8vOUp/MMUb5GeVIUjXYA6QM=;
        b=BKcgnHhng7RoD8aGKokd0HET70oB9lkR8PxeipSZeEZM66TVSrvYAL3W3i4CcOAz5F
         M3XoiQzNKcs6bo59o/14w8iz1OLTvVJ2EAY3r6WA7QI4EX8hLU7ubDHWHFi2x9xczf5U
         k3y3TTSin3WG4COwnyjurISdJq5Ada+nv0P1VwZhTgfUIIhewMvaDXRgtUmiPPDJQD1y
         jYjVtH4rXufJhKBiIYstQ00d35jUZKtkiXOS7yQ5RsG44czB6FbFFagyB2TnbV+Ce/rt
         81+Ok1O+cqlPN+8iwC7kHqQPLOsM77CgnYb1cJ/0DJUEpBEYcvFc9VU8r1efcM1qPn6O
         9lWw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793627816; x=1794232616;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=au77HHa+Dty7tCJBh+bZ8vOUp/MMUb5GeVIUjXYA6QM=;
        b=M2DVFuivuOH10MggEDTCAah4ladH1UVz7Kv86UrosqlybmdlEkcl1mdxXLsEWcY8Gh
         +xBZbN0OgCIkpAAcvVUinbtWdlvOzRE4BSdeFZHBkV/CjfDtFouUkPvJC+3VeLs35fdY
         /UTEEtyfToI3ft68l84QQKPgcy5QEOeVVK/CWBLqOYbmRIjsh8Wqn4H9Hc+xen0bO7oY
         WBaZRe8EM82y3iK8+kcWi9Eu9WKw4p6gF6OAF64NzRPKCBaxujlUx1ld65rHUAhGZzo7
         S7TrCpRKu3qxmuyDx4BSaP0CBYMDD04EeMDyCpDOCteLB1Yk1WH5d4c0FIJaCW38pSzi
         u7Og==
X-Gm-Message-State: AFq9FYIUflksRCepl07/m5JtrLryoYjXYpStarK3JUOrq5UXImmi3/DF
	Y09Fw9N1ChNso6luD58LFBBqtc8nsHe4ju5WX97KFuhd8fCyV66zCYhEefpfodsm7vU=
X-Gm-Gg: AYBFou3ijU9uIN7YOY5GrUsxKvNs1U7t1w6z+P3BxKp7Jx6fnY6N0+87uF/a4wgFqjW
	xawynJiGotsX6HywZH/d7xdQxRVNn1bCAul7JcX9LjWeH+9HDDN5P4bU+4n/lgAOFtrRbgozxC3
	WRBkyV7wdPb8Pi52YAePNgug+FGXLea5krDawl0ivtAUZTab5hB6aZwvoVAP4nNEtGyMwpXumNd
	A1Man9JUHFjMOMK3J8EzRTvijCXFzzdYcuODxUVfPHyQ0xjAv45GfdXyoEvj07CWEI7XmU7ibBK
	XqOF0w3fVE6JBgWnHKTqrZjc9uZeG8msUkUiTDXVPTSoswMov/FkugA87m4D+q+1ortXoKq08Dz
	rVHQszjrtW+xaW7ZCHxkoqG3KkFIEUvn19pGsITchdUh09irxxIcvpx1MEDPRVTykeL/gmHqPfh
	hzrfaCN1kGhnRQvmS38Wk3TlMQveGqEl1c+flPDq1HzHQUIqOrJERwBYhshDAVu7Vu72O9+Qq0i
	h3zUi5yu8qwDxn+dC3HhiszXJJK3hwY9UERkAwASTHZh3IxvgX8xddYEcGu2XcFgbu67xxAFulM
	llKBIPPl/KHSgHLAFaE96MYSQjl7e7z/oEQgkHs1kDan+qMuiavLFGB5xV29XcwCxsekbSoV
X-Received: by 2002:a05:6808:670d:b0:4d6:90f3:74a4 with SMTP id 5614622812f47-5640def68demr6770088b6e.47.1793627815604;
        Mon, 02 Nov 2026 05:56:55 -0800 (PST)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5640fd95562sm7980806b6e.4.2026.11.02.05.56.54
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 02 Nov 2026 05:56:54 -0800 (PST)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v3 0/6] pNFS: don't reply NOMATCHING to a layout recall with I/O in flight
Date: Mon,  2 Nov 2026 08:56:47 -0500
Message-ID: <cover.1793627813.git.bcodding@hammerspace.com>
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

Changes in v3:
 - Patch 3: also require the layout stateid to be the one the LAYOUTCOMMIT
   was built with.  A LAYOUTGET during ->prepare_layoutcommit() can make
   the same header valid again with a new stateid.

Changes in v2:
 - Patch 3: only reschedule the LAYOUTCOMMIT if the layout stateid is
   still valid.  Putting the segment references could free the layout
   header and leave NFS_INO_LAYOUTCOMMIT set, so the next
   pnfs_layoutcommit_inode() dereferenced a NULL nfsi->layout.

v2: https://lore.kernel.org/linux-nfs/cover.1793373378.git.bcodding@hammerspace.com/
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
 fs/nfs/nfs4trace.h                     |  49 +++++++++++
 fs/nfs/pnfs.c                          | 110 +++++++++++++++++++++----
 fs/nfs/pnfs.h                          |   4 +
 5 files changed, 168 insertions(+), 19 deletions(-)


base-commit: ef30b3efb7e8bae94d790a6503a595e1051323e7
-- 
2.53.0

