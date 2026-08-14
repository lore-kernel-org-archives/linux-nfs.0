Received: from mail-oa1-f48.google.com (mail-oa1-f48.google.com [209.85.160.48])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ACE1446D550
	for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 14:35:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.160.48
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786718156; cv=none; b=eDhPa0i/js+Uo1R3QbdwHhsl0zIGFk3mGd5dkvchN2Eku0E7HeypxH2Rs5yW5/rMKQ55yYVPIh1ynrZTV8qpYRIRXnWZAU3+ccdADgIUv/C4UExrkF5JF8ENh4tTOoKgo4+00yM0INAWNkAeirlLFfEPvdtDOTPEj7Gg+vxztis=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786718156; c=relaxed/simple;
	bh=kuGtmosN6o7UWWoIeWZZy822qABDgDJJqywyB9wxLBE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=lkrf5b9aM/i9A1/Wwo7BLH0SBDlx87j25ooVLK61qMB6/ecYNzP06geg48VHvcLnbLI/joHqSkxHlTqup/gOf8qsuCi8b+79FVaib5xc51bDvehXUp9QEUm3UkkCWqnabsfgeU2r133fkQfEMciAAf0JD30HkwwzK9X5DRPQwEA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=UmZPQ4FS; arc=none smtp.client-ip=209.85.160.48
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="UmZPQ4FS"
Received: by mail-oa1-f48.google.com with SMTP id 586e51a60fabf-4513435cdd2so810657fac.2
        for <linux-nfs@vger.kernel.org>; Fri, 14 Aug 2026 07:35:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1786718150; x=1787322950; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=r1jegNfMfrpCfz6YOWMLMu5hDdxKWBDSA/T8LSVpcTA=;
        b=UmZPQ4FSzk1Zd6OWEAYg0QMHVyXcqPOwWkd8c3Qhy6juMTcN/jf2lKHGmoibd3kTtu
         C/U6KJg8uOubMcBWB7izBaLav/E70h4mPIz9C9oiebNYhw5BHqbeAQ1Oz96hiOCxXwKo
         voNC/rTngUel8yS/ECbOeOQJL8EKheP6vg5Ji3sFwiBoW4oGWDlYyplB5JslnN7xeSQ6
         yf29wMawdwiAaJj16tngAFfRlQIm8eDKN8okeRw0arv5YykN9uX/YOw0HVxEDgIiAyJn
         KbnYrBeR+bKW6ee/tPfQigtLsHQ1fEsRPzfnttX/84CDZ3QlUk6/DMcrAqCw+7jFdfAA
         QFnQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786718150; x=1787322950;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=r1jegNfMfrpCfz6YOWMLMu5hDdxKWBDSA/T8LSVpcTA=;
        b=dTamMWCv5yqQoFwb5LSpj/caOJKjZX8nhn6mmmn1KIxRIikQt2KrwHchtE32p8otus
         G6i2AmLQy6dsJqT1fHiz5Q+SjcwyrxAvh4oDuxfFw9hvcf0CTbUK8H2RS0DxedHVoqmd
         JT/GcovPc4cYaVF3Qcp6l/p2iyU0v9APmE4uu2px3QIp/S1hzx+1EbJB1NTBALWrD4vz
         HOUS+geaB/PGM1TtSWPAzby95csTtdydevZjfzGC9Jz/0WbY26sU6vmil5C5JYfDcvo7
         ngM2el+BQ+C0uIJNO6CRYW2aCfnDH3Pvpm4UhsgcRVY+BGBvfmZrZgpDANwV4rxQt1bh
         r1UQ==
X-Forwarded-Encrypted: i=1; AHgh+Rqg6d/o3S67iRIrR3VxnzH9Xyr7GEJ73uUz0lCtGzEaQkgevVbhFdW1FFMyoRwKoK6Dl1hMI/bkRMo=@vger.kernel.org
X-Gm-Message-State: AOJu0YxTPlvkYYGBZZ6NX/8+5tfzpvnKzZZE0SHE9IcSlVs+/l66Sh2S
	3dKE1Qqk5l91feG1+GW/WguR29hSg0EBH6LQ/ZGv4ylSpe3dpK/G96nyjGctb58Up4M=
X-Gm-Gg: AR+sD10Bbp/l64bsv/s20mgjzoltq5O4SCTBCLVOYRJz0rB7o+2eCCN2tzFRKbGsqNi
	BVAab0sg2odANgldtGS/VkNBxP7SI7mvm+km7Od4BwMu7X7TUaH8TlTXIjEH8+/owFOp4FPoQ/+
	PG/XCL3d6KISflIuO8IllfCr314tZWdZ2opr4D6gULjZlexIHwjoml1qN1d8otAlVaUHFP8DDTF
	F7JbZVIOvRr/fkFqvkwIUrQW3F1/zam+/Hos7QhuYWRnRb04uA2VCgBx13Sh4r9BeEoiI2yqBmo
	4nViOqVNpXfianNJhehn0s02s6fp+vNnh0pczDv1ALZ2+OSFTbtL/6CmNa01Q1t6D44qnN5DpL+
	9lRkbiMBPKZMa1a2VhVBx0rH9ox77E2YroLnl7PdOasyih4VoZWGgoQAog84H5BT7SVPVSS9IsW
	DMeXDy6MskYwup7CrHfIByckeihqOCnCgMaM5r3/vvx59H1O6CZcnREEU8diEVDSJYqi0WxvqbM
	p+ZWxTM
X-Received: by 2002:a05:6820:2916:b0:6aa:fa5f:ec48 with SMTP id 006d021491bc7-6b0d5db3aaamr5434631eaf.0.1786718150243;
        Fri, 14 Aug 2026 07:35:50 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7f3e849478esm1012442a34.6.2026.08.14.07.35.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 14 Aug 2026 07:35:49 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Benjamin Coddington <ben.coddington@hammerspace.com>
Cc: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 linux-nfs@vger.kernel.org, Jonathan Curley <jcurley@purestorage.com>,
 Mike Snitzer <snitzer@kernel.org>, Jeff Layton <jlayton@kernel.org>
Subject: Re: [PATCH 00/21] NFS: flexfiles device notifications and caching for
 wide striped layouts
Date: Fri, 14 Aug 2026 10:35:47 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <2D458D42-8968-4233-B18E-2B37DDA360E0@hammerspace.com>
In-Reply-To: <cover.1786653063.git.bcodding@hammerspace.com>
References: <cover.1786653063.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

Note to reviewers - this one had numerous problems identified by sashiko:
https://sashiko.dev/#/patchset/cover.1786653063.git.bcodding%40hammerspace.com

I'm working on a v2..

Ben

On 13 Aug 2026, at 16:42, Benjamin Coddington wrote:

> A flexfiles layout striped across many data servers puts hundreds to
> ~1000 distinct deviceIDs in play for a single mount.  This series makes
> the client's CB_NOTIFY_DEVICEID handling actually work under live
> layouts, implements the deviceID-deletion race recovery RFC 8881 asks
> for, and scales the device caches to that number of devices.
>
> Patches 1-4 are standalone fixes (Cc: stable) for latent bugs in the
> striped-layout paths.  The CB_NOTIFY_DEVICEID decoder gated consuming
> ndc_immediate on the layout type instead of the notification type, so
> the flag was silently lost and any multi-item cnda_changes<> array
> misaligned after the first entry.  Read data-server selection truncated
> the file offset to 32 bits, picking the wrong stripe's DS for
> availability probing and coalescing above 4 GiB.  And page coalescing
> was bounded on a segment-relative offset in both the flexfiles and files
> layouts, so an unaligned segment let a coalesced I/O straddle a stripe
> boundary and send the bytes past it to the wrong data server.
>
> Patches 5-13 make CHANGE notifications work under live layouts.  RFC 8881
> Section 12.2.10 has CB_NOTIFY_DEVICEID CHANGE exist precisely so a server
> can re-point a deviceID without recalling the layouts that reference it,
> but the client's only response today is to unhash the cached device --
> which never reaches the references pinned inside the layout driver's
> segments, so I/O keeps going to the old mapping until the layouts are
> freed.  Each in-flight I/O is given its own device-node reference, the
> mirror's pinned pointer becomes RCU-managed, and a new layout-driver
> hook re-resolves the device in place, honoring ndc_immediate.  A
> GETDEVICEINFO reply that raced a CHANGE is discarded rather than
> installed stale.
>
> Patches 14-17 implement the deviceID-deletion race of RFC 8881 Section
> 18.40.4: layouts still referencing a deleted deviceID are tested with
> TEST_STATEID, revoked state is recovered, and the deletion is confirmed
> with GETDEVICEINFO before escalating to lease recovery.  A DELETE that
> no live layout references keeps today's cheap path.
>
> Patches 18-21 scale the device caches.  The global deviceid hash grows
> from 32 to 256 buckets (a load factor of ~31 at 1000 devices today), and
> the per-net data-server cache moves from a single list to hash buckets
> keyed by the DS address set -- which also fixes a latent aliasing bug,
> since the old comparator matched on subset rather than equality and
> merged two data servers whenever one's address set contained the other's.
> Last, the flexfiles driver gains a dataserver_nconnect module parameter
> alongside its existing dataserver_timeo and dataserver_retrans knobs:
> data-server clients otherwise inherit the MDS nconnect, which at ~1000
> DSes and nconnect=16 means ~16k sockets and their slot tables for little
> gain on a workload striping across the DSes anyway.  It defaults to 0,
> preserving today's inherit-from-MDS behavior.
>
> Tested end-to-end against reffs, a notification-capable reference
> server, at 256 and 1000 devices, including KASAN and lockdep runs under
> concurrent notification storms.
>
> A related series, "NFS: size the LAYOUTGET reply buffer for wide
> flexfiles layouts", lifts the single-page LAYOUTGET reply buffer that
> today caps a segment at roughly 28 stripes.  The two are independent and
> apply cleanly in either order.
>
> Benjamin Coddington (21):
>   pNFS: Fix CB_NOTIFY_DEVICEID CHANGE to consume ndc_immediate
>   NFSv4/flexfiles: Use the full 64-bit offset for read DS selection
>   NFSv4/flexfiles: Bound page coalescing on the absolute stripe offset
>   NFSv4/filelayout: Anchor page coalescing on pattern_offset
>   NFSv4/flexfiles: Reference the device node across DS setup
>   NFSv4/flexfiles: Carry the device node reference across each I/O
>   NFSv4/flexfiles: Hold a device node reference for layoutstats encoding
>   NFSv4/flexfiles: Make the pinned device node pointer RCU-managed
>   pNFS: Add a reresolve_deviceid layout driver hook
>   NFSv4/flexfiles: Implement in-place device re-resolve on CHANGE
>   NFSv4: Dispatch CB_NOTIFY_DEVICEID CHANGE to an in-place refresh
>   NFSv4/flexfiles: Honor ndc_immediate on CB_NOTIFY_DEVICEID CHANGE
>   pNFS: Discard a GETDEVICEINFO reply that raced a CHANGE notification
>   pNFS: Add deviceid reference query and collection walkers
>   NFSv4/pnfs: Recover revoked layouts on a deleted deviceID
>   NFSv4/pnfs: Confirm a deviceID delete via GETDEVICEINFO
>   NFSv4/pnfs: Dispatch CB_NOTIFY_DEVICEID DELETE to race recovery
>   NFSv4/pnfs: Grow the deviceid cache hash table
>   NFSv4/pnfs: Re-home the data-server cache onto hash buckets
>   NFSv4/pnfs: Key the data-server cache by its address set
>   NFSv4/flexfiles: Add a dataserver_nconnect cap
>
>  fs/nfs/callback_proc.c                    |  30 +-
>  fs/nfs/callback_xdr.c                     |   2 +-
>  fs/nfs/client.c                           |   6 +-
>  fs/nfs/filelayout/filelayout.c            |   8 +-
>  fs/nfs/filelayout/filelayoutdev.c         |   2 +-
>  fs/nfs/flexfilelayout/flexfilelayout.c    | 383 ++++++++++++++--------
>  fs/nfs/flexfilelayout/flexfilelayout.h    |  44 +--
>  fs/nfs/flexfilelayout/flexfilelayoutdev.c | 193 +++++++----
>  fs/nfs/internal.h                         |   3 +-
>  fs/nfs/netns.h                            |   5 +-
>  fs/nfs/nfs3client.c                       |   9 +-
>  fs/nfs/nfs4_fs.h                          |   2 +
>  fs/nfs/nfs4client.c                       |   7 +-
>  fs/nfs/nfs4proc.c                         | 113 +++++++
>  fs/nfs/nfs4state.c                        |   3 +
>  fs/nfs/pnfs.c                             | 292 +++++++++++++++++
>  fs/nfs/pnfs.h                             |  81 ++++-
>  fs/nfs/pnfs_dev.c                         |  35 +-
>  fs/nfs/pnfs_nfs.c                         |  93 +++++-
>  include/linux/nfs_fs_sb.h                 |   2 +
>  include/linux/nfs_xdr.h                   |   2 +
>  21 files changed, 1069 insertions(+), 246 deletions(-)
>
> base-commit: db2ddb87143519e20a95aa36c60b36107b736a58
> -- 
> 2.53.0
