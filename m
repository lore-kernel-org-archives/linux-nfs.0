Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B3DE830B529
	for <linux-nfs@vger.kernel.org>; Tue,  7 Jul 2026 20:57:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783457880; cv=none; b=XnhnrcXOxDwhnZimFsl5Ruv7hqURM6kXkdEr/JPxB5CpjSfD/T2F+ZXIq6aa1HrTOUmA/Acbd8zHLoiX8pZI1TGdA9dyAZh73OMDhbWkGu2WRqa3oIMDS/QUzKCxGTIcFKT8UijHq2MsgRXOvbSnED99psbM4+fkpAcEGmXMnZI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783457880; c=relaxed/simple;
	bh=weVIrS/3y6NVo4sMV5WWcLapx58lwTamW2cF/2D5omo=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=fYFcAj7sXVIPhT0wXgrUyVGrNlKZLKyGMhYv/VYkVIPX+22n6SwAXEUHK72qDZ42H3OML5ai56XZlAsF03w/gzz1c9gH0y55IQEry1U8gYkBQP7xI0Yal0AivJqcnc18qOs+uHnGWIr4ZJ0fG087WtGBQb7vsV5IEQyAC8o/nEw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=NrpNBPbV; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="NrpNBPbV"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1783457877;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=/cXec0UB8SxJ0NoWCaBSkg0GuT85+NTisCBVanuLuY4=;
	b=NrpNBPbVNB+7zOQQpAKaB8Dx/bsStlWN59qv7TaIkHS3tGExa/YntsiJCn8hqrhi2LKNDO
	gvB0wutuR+GbjDVdGYPasvQFqCmTXw9l8rqjYXXJPCzBRkyyX2gfsyJc7b3SlLCS2DGXHk
	gA2cyJl2LnhBoIVLzVvVjR/YHvsQteY=
Received: from mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-250-VxW-0TzJMhmt9Q47TyVRHQ-1; Tue,
 07 Jul 2026 16:57:54 -0400
X-MC-Unique: VxW-0TzJMhmt9Q47TyVRHQ-1
X-Mimecast-MFC-AGG-ID: VxW-0TzJMhmt9Q47TyVRHQ_1783457873
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-03.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id A8BFF1955DAF;
	Tue,  7 Jul 2026 20:57:53 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (unknown [10.22.80.127])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 8430A1955D88;
	Tue,  7 Jul 2026 20:57:53 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id D85F44D4C113;
	Tue, 07 Jul 2026 16:57:52 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: jlayton@kernel.org,
	linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 0/3] mountd netlink fixes
Date: Tue,  7 Jul 2026 16:57:49 -0400
Message-ID: <20260707205752.313031-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

A handful of fixes for some issues I ran into on Fedora Rawhide.

Scott Mayhew (3):
  configure: update check of system netlink headers
  nfs.conf: add no-netlink option to exportd and mountd stanzas
  mountd/exportd: disable netlink when falling back to /proc

 configure.ac                 | 4 ++--
 nfs.conf                     | 3 +++
 support/export/cache.c       | 7 +++++++
 support/export/cache_flush.c | 1 +
 4 files changed, 13 insertions(+), 2 deletions(-)

-- 
2.55.0

