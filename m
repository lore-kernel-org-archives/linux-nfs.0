Received: from mail-qk1-f182.google.com (mail-qk1-f182.google.com [209.85.222.182])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 44E66439F75
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 12:56:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.222.182
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788526578; cv=none; b=ffPVQu8oA+cPQBBk8Ure16CDhevFGGbCi8/JN/xa2hvva5AE3Lxgrr2aXFY/nEl3s/TR9Ajx02MBbyf3soPt35OX+3oIoiiaBkHQwGFKSxwYl1UV/arrS2yR2yTseasac0Mxx9SB4X5i/OHjmdm3v6gEzp3KbkJZ/SX4YGhz6jY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788526578; c=relaxed/simple;
	bh=ytdSuRBvIB6enQ8tkEpMUPvp+7F9ASQExjc0blfaFHw=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=qnEwhX0fCqA46dp3U1I6JrvHOd2Pi11HeTR6iJNVRnhmgHNBEQ+YHfCcrs5QlNPQJIRx9wTY84nR0z7ss1g19C4MtNKPmGRAfRckeLtjxqOkbAbvKoa1Sc3UlmL6hJONrHupczKfaUCeWsGwtpezQ4MIt0S8GjYfy2baBfItWSQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=AljISWEY; arc=none smtp.client-ip=209.85.222.182
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="AljISWEY"
Received: by mail-qk1-f182.google.com with SMTP id af79cd13be357-93959320373so79821485a.1
        for <linux-nfs@vger.kernel.org>; Fri, 04 Sep 2026 05:56:17 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1788526576; x=1789131376; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=sYeJoh+HXZY3Wgc8j/hwcwa+lL/vgfzsxhnFdDOF4Fk=;
        b=AljISWEY34qIH4AEPeFonYC5gREI3xWq3OdClU0ui7V7s4pAL7VUHgEdF7elb0gEYF
         xdd282VEBja1MvfmlnJokDjHRTTx3n7a2zjVE0saTS+yGYASMzvry5/We+MzXKIjBw5x
         XdjGHBwwMKfHa2qkEU0UsKIplrHPHFzzYBEgE/JC0xSMXVviFgQ5KHgcgnMIb1YUMqBq
         jwUaXglXDe6dmAhJMXF4OlCO1YUdkAsUydSP9skGfI2+ukY9GEi2sNaL3jVPIRFq2eGt
         EjSShG6/e6ODlHS15J0l58jdugR4niAkpJ8I5dNK9U9NjlRRmc0HXvvBDoQZRMeL1JP8
         w5xQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1788526576; x=1789131376;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=sYeJoh+HXZY3Wgc8j/hwcwa+lL/vgfzsxhnFdDOF4Fk=;
        b=fDZcDE9WCrBeeJntLstBB6ctbpFJzYPWvzRxSOt0PKaYDBosPsB5jFWMP7CrOVBO+a
         vPV4WIiEc7RrNguXgkeyeQgOFQFK8emFYPkgeu0bf/rkGyibRCb5XNyusfP0OHjdMtMi
         oksRd97Mz55ocfen8cWt4RP9OGqpuOsd9zP3y1SHUcu8pxFKAIpz+Vt3pCiCoJ5jTpZj
         gCxJNtb3Y6DIgIG+KfTX52PBmCfxyXHoVO4uSKDYTMC7J2lEgyrxrVpNeYrlAnSmBF6d
         rUeUVil53s5zCYUxFHr4+OksWdaeAgXXtVE6+V4d/x7c+P1eV44NF4mTnRCPOrRWBIGd
         5Ngg==
X-Gm-Message-State: AFuF++mUHW9T13w9OCIcVPcUv+yNUqCtga0sFGNDFPmviWaMTgWMNilE
	9jWolDSSQp1stEkqiD7u21QaS/NW0VLJwi2LdkXe9kBj6PTSTJCo7xWzRgK6N07cDbqbqgB8oO0
	qU0o1
X-Gm-Gg: AYBFou3/cLLXJsCDIJ3VJV9tRMKuVDVIGs6wSyX+i1Czx5FaNhhG6iuNcOdg5QLIA+Z
	x1UpNGGsQuAnDswyFxNdRbNIckClYvjccxA167dcRYb3oNyaWsqg0PHB+v0+BaW+g4QKuOdaId5
	WMBbfvsbIeQgIVOpl7ytLagumvTBEEMDXHcyz1Rb5pDxXtVM9056Ejohe01aARWje5kQIHhofCM
	sOHkSVy12jtWEs7+MEowYgvhxWAEcoo0NKYWFvPnjIykBn39/wRfUUg8UxGksCr/7vChfqQ3RaH
	3moEwSfgXVtWpJ34fMR36vWOP790rFZy3f5DF1HW9/cnGS31yZ3pvqcWPSvJh9Z1V394EiNtDkb
	tNsY+vwgUlw0foaUlzUQ/Qf107eSH/PgxlMV0shu3KV+KSG3CI/FZbMSdxPLjoW8Ue0BGgcQ4rD
	xiMsd3+yC48vRn3Wy2hGJSM95l+EtOG9mzOTNpwANrCq6KAk3BVcDHBgbk3KGES3O+Ir+yTxWE9
	MQNTZq9FPGrGHRCo55m2m4P
X-Received: by 2002:a05:620a:618e:b0:939:1483:55c with SMTP id af79cd13be357-9398034757emr580339085a.19.1788526570101;
        Fri, 04 Sep 2026 05:56:10 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9397fb2fd82sm203324985a.17.2026.09.04.05.56.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 04 Sep 2026 05:56:09 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 0/6] NFS: size the LAYOUTGET reply buffer for wide flexfiles layouts
Date: Fri,  4 Sep 2026 08:56:01 -0400
Message-ID: <cover.1788453839.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The flexfiles layout driver caps its LAYOUTGET reply buffer at a single
page, which limits a striped layout segment to roughly 28 ff_data_server4
entries -- far below the 4096-stripe decode limit the client otherwise
advertises.  A server striping wider than that has no way to hand the
client a layout: it returns NFS4ERR_TOOSMALL, the client falls back to
I/O through the MDS, and pNFS never engages for those files.

This series first makes the client behave sanely when a layout does not
fit the size it advertised in loga_maxcount, and then lets the reply
buffer grow on demand up to the session's maximum response size.

Patch 1 is a standalone fix (Cc: stable).  A server's NFS4ERR_TOOSMALL
is mapped to -ETOOSMALL at decode and then handled nowhere, so the
client falls back to the MDS for that one request and re-sends a doomed
LAYOUTGET on every subsequent pageio attempt.  Suspend pNFS via the
layout fail bit instead, the way NFS4ERR_LAYOUTUNAVAILABLE already does.

Patches 2-5 make wide layouts work.  loga_maxcount is derived from the
reply buffer actually allocated rather than a fixed 4096 (block and SCSI
layouts were advertising 4KB against a session-sized buffer, so a server
whose extent list encodes larger than a page got a needless TOOSMALL).
A TOOSMALL LAYOUTGET is then retried once with the buffer raised to the
session's maximum response size -- the same bound GETDEVICEINFO already
uses -- and a non-conformant server that ignores loga_maxcount and
overruns the buffer outright takes that same recovery path instead of
today's -EINVAL.  Finally the escalated size is remembered per-server, so
subsequent opens skip the attempt that is known to fail; this is also
what lets the LAYOUTGET attached to OPEN succeed against a wide-striping
server, since that path is best-effort and has no retry of its own.

The common path is unchanged throughout: the first LAYOUTGET for a
layout still goes out with the layout driver's default reply buffer, and
larger buffers are only ever allocated against servers that actually
hand out wide layouts.

Patch 6 moves the decoded per-mirror stripe array to kvzalloc_objs(), so
that a wide stripe array does not depend on a high-order allocation
succeeding.

Wire-validated against reffs at stripe widths 2 and 64, exercising both
the conformant NFS4ERR_TOOSMALL path and the buffer-overrun path.

Two known gaps are deliberately left for follow-up work:

  - The decoded per-stripe footprint is heavy: nfs4_ff_layout_ds_stripe
    is roughly 300 bytes and embeds localio and layoutstats state that
    most stripes never use.  Both the structure and its array container
    want rework before very large stripe counts are comfortable.

  - The client decodes only the first logr_layout entry of a LAYOUTGET
    reply and silently discards the rest, so it can accept less coverage
    than it asked for in loga_minlength, and cannot amortize a
    multi-segment reply.

A related series, "NFS: flexfiles device notifications and caching for
wide striped layouts", handles CB_NOTIFY_DEVICEID and scales the device
caches for the layouts this one makes fetchable.  The two are
independent and apply cleanly in either order.

Changes on v2:
	Rebased on v7.3-rc1
	Jeff: trim the comment on the NFS4ERR_TOOSMALL case in patch 1
	Collected Jeff's Reviewed-by

Based on v7.3-rc1.

v1: https://lore.kernel.org/linux-nfs/cover.1786653456.git.bcodding@hammerspace.com/

Benjamin Coddington (6):
  NFSv4.1/pnfs: suspend pNFS on NFS4ERR_TOOSMALL from LAYOUTGET
  NFSv4.1/pnfs: derive loga_maxcount from the LAYOUTGET reply buffer
  NFSv4.1/pnfs: retry LAYOUTGET with a larger reply buffer on
    NFS4ERR_TOOSMALL
  NFSv4.1/pnfs: treat an oversized LAYOUTGET reply as -EMSGSIZE
  NFSv4.1/pnfs: remember when a server needs a larger LAYOUTGET reply
    buffer
  NFSv4/flexfiles: allocate the per-mirror stripe array with
    kvzalloc_objs

 fs/nfs/flexfilelayout/flexfilelayout.c |  6 +--
 fs/nfs/nfs4proc.c                      |  8 ++++
 fs/nfs/nfs4xdr.c                       |  2 +-
 fs/nfs/pnfs.c                          | 54 +++++++++++++++++++++++---
 include/linux/nfs_fs_sb.h              |  4 ++
 5 files changed, 64 insertions(+), 10 deletions(-)

base-commit: cee9395acd8043be0644b25c34bfa86623f2b935
-- 
2.53.0

