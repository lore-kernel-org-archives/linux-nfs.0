Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793340707;
	b=pbiPQHe8iQi8bx/kYpc3lDIt3iMWnRis8fAv9N6Le7S2N1Al20FwxabAJhxa+yCRaWyB
	 CJU46xJN4AoN7Xk6KeXjSVCcEM4qseq69JWznKWvFmu9TRDFVirFlneMEQf8SpVwcHFIV
	 Dzy28DgaWZ2dcX+TixYPN0SFp3tfiaIQH4btrGklxoD29E7AcejC8pc5g5Yrky1r7wey6
	 IbjfavPxU/Eox5/jKGlKPXYQ4UqDr/FZKwE6XDwF9UnD23h5ZGJX4B5BvmwjR0WHEtjxU
	 tAUbFiTTV8rLtO+xE6ekgg9KidOlB6XdBmToJ8+zpbeHYLMZSQOp96wmO6D9TkV93Sg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793340707;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:MIME-Version:Content-Transfer-Encoding:X-Scanned-By;
	bh=JW+8j1gVsBuL3NOVGjGGJ/ooFH2/UDGWo9lpehjzu2I=;
	b=dG5/gotX6QDvb3BI4K4y73YDrcEg7rtzimpGhsghtNeMc14joHR7LFnlnUalVLca1pAg
	 prVQ8B9SYiI3EXY8c9Of6VN0AT5wkgeSMDDj0yWB7uOHKKoE4ZFtcPUu/JJW3jKjQrt8D
	 6fp1uXF4PLccWhY/6vPXc/jLnqlFNGrIlft2cQyilQt1KL3NQfJXVEYc9nfiWgXKGmrQ2
	 Bgf3uzLUmSvGPmSRp8ai6ttoc7M/gfeq+n9TNzikDckcjsNU7V/aV+cQ+pp/I6jN1XPHm
	 vsyfV9SOs8JQQKP1QN6TleWJllAiWX6W6UbPObtGja3WHhPlFP4+m7cEiFacSS9j5/A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=g3fnxoXn;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8F85D606A31A
	for <linux-nfs@vger.kernel.org>; Fri, 30 Oct 2026 06:11:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 8F85D606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=g3fnxoXn
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1793340705;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=JW+8j1gVsBuL3NOVGjGGJ/ooFH2/UDGWo9lpehjzu2I=;
	b=g3fnxoXnUgnLt+uaBGaDVn3V3vMnc3zx5g9TB6sSC+3Ti/yPF2axFD3FNZW7z6mv42HHCs
	Qy7VYke6lxkYCEICCBusivSh7S1eEfeXEk2IgdMQc+V7HiI4UBGud7Jaqj5JkFkQQC32TL
	Zb/l1AJXeGhKAWCA2ad/lUHOkZ/uySs=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-656-MqsprQjZMjC6FsmE2PGPIw-1; Fri,
 30 Oct 2026 02:11:41 -0400
X-MC-Unique: MqsprQjZMjC6FsmE2PGPIw-1
X-Mimecast-MFC-AGG-ID: MqsprQjZMjC6FsmE2PGPIw_1793340700
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 569D81956078;
	Fri, 30 Oct 2026 06:11:40 +0000 (UTC)
Received: from fs-i40c-01.fast.eng.rdu2.dc.redhat.com (fs-i40c-01.fast.eng.rdu2.dc.redhat.com [10.6.54.119])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 8572930002C9;
	Fri, 30 Oct 2026 06:11:39 +0000 (UTC)
From: Abhinandan Ekande <aekande@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: dhowells@redhat.com,
	linux-nfs@vger.kernel.org,
	aekande@redhat.com
Subject: [PATCH v2 0/2] NFS: Fix netfs read subrequest range and retry accounting
Date: Fri, 30 Oct 2026 02:11:36 -0400
Message-ID: <20261030061138.237833-1-aekande@redhat.com>
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
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

While addressing an issue where netfs repeatedly reads whole folio when
rsize is smaller than the folio size, a related bug was identified in how
nfs_netfs_put() handles retried or reissued subrequests that already have
transferred bytes.

This series fixes both issues:
- Patch 1 fixes an accounting bug in nfs_netfs_put(): it assigns the
  current ->issue_read() call's byte count to sreq->transferred instead of
  adding to it, discarding progress from an earlier attempt such as a
  partial cache read, so the subrequest under-reports what it holds.
  Accumulate instead, with the existing min_t() clamp now bounding the
  cumulative total.
- Patch 2 ensures nfs_netfs_issue_read() requests only the subrequest's
  byte range rather than repeatedly submitting the whole folio.

Changes in v2:
- Added patch 1 to fix sreq->transferred accumulation on completion,
  following review feedback from Sashiko.
- Patch 2 is unchanged from v1.
  
Abhinandan Ekande (2):
  NFS: Accumulate transferred bytes on netfs read completion
  NFS: honour the netfs subrequest range when issuing reads

 fs/nfs/fscache.c  | 21 ++++++++++++++----
 fs/nfs/fscache.h  |  1 +
 fs/nfs/internal.h |  4 ++++
 fs/nfs/read.c     | 56 ++++++++++++++++++++++++++++++-----------------
 4 files changed, 58 insertions(+), 24 deletions(-)

-- 
2.55.0

