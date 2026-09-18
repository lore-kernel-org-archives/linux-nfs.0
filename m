Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3AB314E73B5
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 12:21:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789734074; cv=none; b=mEpx7jG4H4N6XcJefjhX/8NuA6S5n1fhg/H7Z6TzeGFXOPdV8Q60c7UV1IWY/aYBMgTEpISfKXAD9twdYBCdJETM2lLE+IekJPth8MdmvFOcA0x0SbQqRIF/oY0VFWvM+oqUWiRCzxJYvlI8bWAkVY5h7IDO5/5uMiTHxgkx88E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789734074; c=relaxed/simple;
	bh=BJ5CwwFoBzhTy/n8keT/s08TBShQ9CU57iMihNNUEgQ=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=S8Oz6TJFkEIi7+I9M4kiD1RCVhCl58Q3GhzGxhilzb4sujJ9e01EOw1jOL31+yBOtppQ9d3Nd70DbwN6lS1OFWXusHnN8boUATICv7V2xewsmK9iguC2/F6OGYIiQ1PYuaNZgY47rm8MFx7uYaOv1EuXBRRtETaCTDNvb7zmwyY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=nImvXBSg; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="nImvXBSg"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4bf948737e1so496433b6e.2
        for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 05:21:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789734065; x=1790338865; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=mcmltT4kDUvzJZZ+gV7c3I1/pQhyzX7va3Ymdnlrghw=;
        b=nImvXBSgDaBG/tLZ1mvsiqYIWbnd9xVWfE15K6dK5O4/zdWSRm2u1gUtMxfxszh4lf
         CDb/Re5Rq12c9NN7ZUxZkVhcOkJoDCuB/etkBiZoezl6zMgPCC1uTJB1+p5StqcLDi3m
         +lGYj8VbSfGeB6deDe1guPjiaSDsNj857u+onzKnSiSQbzJvl3eFWZ4Ug2Zp9w6j2FlW
         iWUCV8Fmx+ZdbZt1Jjj5fGQFVU4mgd6s9AratHad4FaKVl/D9TxYvPj1zvyLmQnoxqOj
         4Wfqk+V3JkKGu/CZwr8QVDfoYpsOuPs2eG5mmv8pbYr4kJyM7uYygd5qOMXzA7wmSQsG
         RUBQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789734065; x=1790338865;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=mcmltT4kDUvzJZZ+gV7c3I1/pQhyzX7va3Ymdnlrghw=;
        b=EDHtEK15H2loN/5GdT1KNaCKuMOoEKzShZBd/VrEzjmGxewO/dZtSYsTxD4ZrmK4WG
         hv3skFt00uwpN+xIDDV0/jDqOSgoMvSxzLYM0MJamlrr/4mabZWtQVSfxa2F/UqS16Xe
         L35v7hcfJBgDH7Ls8AaVAroRlXPlPDb4xkRhp/XJnZ/6If9fAKnuhBigtpPcBPW4Y/TJ
         PwSBlk+RdgesHUe23RS9ek1oeBmOyR3VbXB1ppQRTuoHlXNB+6DyWObXQOeOdLPf3GnM
         4rWkvMusjMJEntOt5eX59qOluBGw9MHZ8atYIrXQqlCbZpeVJrf+ZQMo6HhS1jV9GQWg
         MN0A==
X-Gm-Message-State: AFuF++nNIO0QVC1h+54eXDsDP6Wmg5xMRKCKCGTOhVnqT29DMayhbLxz
	JpcYjVdarrbyXfTU+GO0TKiAzpezTFmhwd1rw43koy+UO/5r6m/lprUwqJzPL0hKCJauoHi42C1
	SesuA
X-Gm-Gg: AYBFou2Yygprr06+xF7AY4TLoaOTQppnQ4yraahGIg/NTcTPnWmHjO6ml0G3Y7O5Pzm
	3mqpgBIDHsOBTW+xGab6TymhD6hqGYckuLa7rCDUQw+8jHeMxQok8hDtlAnLJ510E8lWS2db4m6
	g8EQNNF+76U0GrKDtK52e9aZO27p3Hq7CCWHfI5VRkbMkprejXpPRLqb/3kND0f6VB6GL/Jn7Xz
	s+XLOpqLrUss2TP6KCHBr24uiM9fYoxhXDz/k7+WWaTNmYyK71AIAGUQCGZXC4ZUqedZtPdv0NM
	clT20LiD6botWuR0q3yIOcojB51ddsCqSzSBYh0fOZI2Eu/QaSwr3+UkZdzi2QEYnD9oliwrnrq
	Am+mZtKqUtVoJarg7OY9xxClrgyVmNz4YgrGpuPoZoXc+L6EerMHrCNhkx5kn1stzVzvX+z/sXv
	dvPyHUH+8cXKMLfMq/lRMKBklGCEOGXZktvkMjrpbN39yv/oZRl6YlCtRHI0M6T/Mjn616BfJGy
	ON5hUUXUIkPsV3Hku7Xz2+FmbsMr1Zlr7I=
X-Received: by 2002:a05:6808:4f2b:b0:4c5:238e:b14d with SMTP id 5614622812f47-4ccf6746423mr3109858b6e.6.1789734064674;
        Fri, 18 Sep 2026 05:21:04 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4cd6ab7d9d3sm883331b6e.18.2026.09.18.05.21.03
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 18 Sep 2026 05:21:04 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Mike Snitzer <snitzer@kernel.org>
Subject: [PATCH 0/2] NFSv4/pnfs: Keep data server connections across deviceid eviction
Date: Fri, 18 Sep 2026 08:21:00 -0400
Message-ID: <cover.1789733774.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

This applies on top of the flexfiles striping series:

  [PATCH v4 00/24] NFS: flexfiles device notifications and caching for
  wide striped layouts
  https://lore.kernel.org/linux-nfs/cover.1789474702.git.bcodding@hammerspace.com

and uses the hashed, address-keyed data server cache that series adds.

A metadata server that does not support deviceid notifications makes the
client set NFS_DEVICEID_NOCACHE, and a NOCACHE deviceid node is freed as
soon as the last layout referring to it is returned.  That takes the data
server's nfs_client and every transport underneath it along with it:

  nfs4_put_deviceid_node()
    ff_layout_free_deviceid_node()
      nfs4_pnfs_ds_put()
        destroy_ds()
          nfs_put_client()
            rpc_shutdown_client()

The next I/O rebuilds all of it: a synchronous connect and NULL ping
inline in pg_init(), plus the remaining nconnect-1 transports
reconnecting lazily as RPCs land on them.  I have a report of a wide
stripe at nconnect=16 spending upwards of ten seconds on this before I/O
can proceed, and paying it again on every layout cycle.

Keep the nfs4_pnfs_ds hashed once its last user goes away, and reap it later
if nothing claims it.

Benjamin Coddington (2):
  NFSv4/pnfs: Give the data server cache its own reference
  NFSv4/pnfs: Let unused data server connections linger

 fs/nfs/pnfs.c     |   4 +-
 fs/nfs/pnfs.h     |   4 ++
 fs/nfs/pnfs_nfs.c | 110 +++++++++++++++++++++++++++++++++++++++++++---
 3 files changed, 112 insertions(+), 6 deletions(-)

-- 
2.53.0

