Received: from mail-oi1-f176.google.com (mail-oi1-f176.google.com [209.85.167.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 419B1496D4D
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 20:58:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.176
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792097895; cv=none; b=SnM17mwAimDB9VWleUUBVHKcFWtWbkRLp1tkCDCtS+P8yrZKbsLKO6L3hTs5wggsrtNbNWbmH9lxpnA9ruNlkQYmHnSZWx6BJnz5/Zq2EeAumwx5xMrgM4V6e7CnsDb2IdtzUzczfy+pXeMuRjBuTcxKt3//zhOulU0ewJ1/y04=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792097895; c=relaxed/simple;
	bh=nCKDNskQgRigeljd/YsgxGQZ30y+7MbLSCectVCf/Ug=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=pjsflKLXSKHi+0e2MNYcTuO2WGLhZE9fJQGKppNPYEFp4DbsNNgoK7+i03FTAxAP/uQ2NlvBnAdwi5A0bbHTShfq/9urpUrm5lI8qYnRsbKF1GlWuO2HQG/5NuzlANTEe6x7eUGKoLXyw4nz50IX3S9adjqhw4wEhqXRp7dMgKM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=nmdMNqDr; arc=none smtp.client-ip=209.85.167.176
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="nmdMNqDr"
Received: by mail-oi1-f176.google.com with SMTP id 5614622812f47-4af81963f35so3383341b6e.0
        for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 13:58:12 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792097892; x=1792702692; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=456p2b+tQjGBu+3Gc2xF56g2mffnukN0mQdmeABBIS0=;
        b=nmdMNqDrG/jicXZmXGEFr6qw9M/VGiSM5uUufhLUudUmEl79AbIoE4eakAKs3CDsFy
         xmyxOq96J+tcCzzIw0bYIUZcXw5IzsB/Tgw9XdcWMKhFPclY6C56yozTG2YfK3kkHT9w
         HHOXawiTOzdnNIpTN3UBBPpN+d3UybHRyPc/irJimBKhWDXpkqPcVj6/rEpjEfDM7VdB
         Mx8/JovPAAYseyTWRLb7co/M8XW+PbQ4wvp58ctUcolV2pjpWrbrXPdensWmO7GI9fqQ
         ZwA0uXRBuBw20oaShqfn6ItS8PSbXWynCxlRWqQZ9ecFLrcytoHEGxyLgn1wAMiAfRyK
         wzMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792097892; x=1792702692;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=456p2b+tQjGBu+3Gc2xF56g2mffnukN0mQdmeABBIS0=;
        b=pbFplBcJ1b5Mtw6f0YNzjrswfHaafJvbihkgo7vdqxJcOIe9plUNF9lshx5r1VcDlH
         m0P8WsSxJ4TL8Cp2LInSt5p8YVOweJ/HSfkdW5nhSW34Ixynz+d3DeWfRfIfFfEcrnyV
         DXDwd1LUdIJ+bIWrIP6bAeSoSFk2MIZbG/KwLpza6HQVr2tdUDca77Ynp8wp4EUxjUeh
         yVLhRE7646bGRIdEJW8EEBXf8m5W3PwZiCz/A9hVkwYIFvgOMBvCcy7JuZZy8rjT8BkX
         s95YyfaXuvw5rbEXZ7OFy5WYdaKVXp6wooKK/C/xlYadhbRK4r1Ss8uUTa9KZOaCZLwU
         OCcg==
X-Gm-Message-State: AFq9FYJuIhOQtibwuQ8fTAmUp8vwi3oqyIZNRj8NtsygqvWVzbKM/xzJ
	sbIM0hD2xGRJwUZiCKVU0XTFR+zPVerKqeqzZChDqwP8hylm1Pq6mczRAFPzzYLfl9A=
X-Gm-Gg: AYBFou2Cu8qq224nsJoSN9VDnh0F44NPbUWHF347o2H9BOSJfvFlZsGlaSdQZohoDT/
	HSr3ntjTwp7XcGqt7oXFQIg5E49esQAMPDHhqlejNBuqujaCRxlP5WG3S2ILmD4SvN3kre0vOLG
	fz+Oc4Jor2OVq5un1yhJdKsc4o4Sr0dq+IO/MjmXzxfIR7xpItUiWUZUTnLpljc/nzWhaaeEq/k
	XFC2koiNyGkyrn6xf3Hy9KDJ0QsplZ9h89e73UeCnRXS6w3wXayyoAbx638gTHKbJGbac7A5vmS
	rzNs9ebEnFOuQIyFhHCaZqlN0E4PrAQCZi1ATg3TRCVlHLIxV9kw1jXFhgnaeKO/RUiA6bSNIjH
	q0ry7x7hPvptqa+jWAyunWZ3gwHr5fdjCTS0p0mNTwLgU/Efm5yc/RgIysZQwHTMV1w4bX6K8L2
	Wkm3MDRoq/M9gZUd3zN3nVFNO5HWuhqt7ulQt3jJgTjK9N7cNv/sRBItXrM5qznV8SgyXnTlhM5
	tmzQIrKy90KehukTGUFCiBjDn0WfFTcqF53DxkbbQ==
X-Received: by 2002:a05:6808:3096:b0:4e9:eb70:b8a with SMTP id 5614622812f47-50c52a3ba9fmr21131833b6e.45.1792097891851;
        Thu, 15 Oct 2026 13:58:11 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-5388c1654e9sm25514b6e.8.2026.10.15.13.58.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 15 Oct 2026 13:58:11 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] NFS: layout changes while building mirrored writes
Date: Thu, 15 Oct 2026 16:58:07 -0400
Message-ID: <cover.1792097624.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Benjamin Coddington <bcodding@hammerspace.com>

These two fix trouble the pageio code has when a flexfiles layout is
recalled and comes back with a different mirror count while a write is
being built.  The first is data loss: an O_DIRECT write drops one
mirror's share of the bytes and still returns success.  The second is
a WARN_ON_ONCE in __nfs_pageio_add_request() that the same race trips
when a request has to be split, which looks like a pg_test bug but
isn't.

I reproduced this against a server that alternates each RW layout
between three mirrors and two and recalls it about a millisecond after
granting it, with mirrors at different wsizes (1M and 64K).  Without
these, 5 of 10 64MiB O_DIRECT rewrites left the 1M mirror holding the
previous data in 64K multiples.  With them I haven't seen a loss the
client was responsible for in a few hundred iterations, buffered or
O_DIRECT.  Buffered writes weren't affected by the first problem since
nfs_async_write_error() redirties on -EAGAIN.

Benjamin Coddington (2):
  NFS: Resend unsent mirror requests when an O_DIRECT write hits -EAGAIN
  NFS: Don't warn when a changed layout refuses a split subrequest

 fs/nfs/direct.c         | 28 ++++++++++++++++++++++++++--
 fs/nfs/pagelist.c       | 20 ++++++++++++++++----
 fs/nfs/read.c           |  3 ++-
 fs/nfs/write.c          |  5 +++--
 include/linux/nfs_xdr.h |  5 ++++-
 5 files changed, 51 insertions(+), 10 deletions(-)

-- 
2.53.0

