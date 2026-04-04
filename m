Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 800FF24293C
	for <linux-nfs@vger.kernel.org>; Sat,  4 Apr 2026 00:30:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775262658; cv=none; b=Id7Dgvum6TTD7Y7CgBfP7rE3SeS3Ovz+woYMklxFROwOJLw9HDgt4pE+p46OsHAIIYUGI93e6h6Tcj7hxkvbZye5t5gwPA35irynWNjiSNUxLxe7dBiQ0T8h4LUCXHTLtSVR1fPi869LRszJncRhxjaGQIKM7XoHEu/BL05mi3Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775262658; c=relaxed/simple;
	bh=PvctZ8V3rLn+9gvc571j3taIJKeArAGr3uyzVQHTQ0U=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=HDlMMfCmyTS7RbWZfukYBEgPyZFTmxI0bpOzJeCA3bVJ+8kn3JrdJ8iJrR0yiGDCbWWzTZTTkT7/Vzbwan6n3MHTU0gthxkRYT2GjFiojkS55Ybc+4ZfQLMUGpNLtpm77W2PR5XHuaV1DaWQD/sPTawum2UEZBHmlEEX6oL64vk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=hqB/H+iF; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="hqB/H+iF"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1775262656;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=p17pLvTfPviWK1jd8n66dF2x/6Y4yywfmnLYRpXmRX4=;
	b=hqB/H+iFw/T83iJVdQPv6mwt8VW5kKnnuK8U/vMIbH7cug3I42Gm6WyRbHBcUOXVnSWgWC
	Fd55tAVNuUnIj/cdhgJ4cF+nN6Ib3S0EDSRVHTFIEd0PeRugVrfwA99qM+ICv/XGzvkAgi
	bdE27QFC8i86FbZeTH13IMy+ip1oSZY=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-8-ne24lMdzMcWxpfh3xNlsaw-1; Fri,
 03 Apr 2026 20:30:53 -0400
X-MC-Unique: ne24lMdzMcWxpfh3xNlsaw-1
X-Mimecast-MFC-AGG-ID: ne24lMdzMcWxpfh3xNlsaw_1775262652
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 3A09A1800372;
	Sat,  4 Apr 2026 00:30:52 +0000 (UTC)
Received: from aion.redhat.com (unknown [10.22.88.38])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 148C130030D6;
	Sat,  4 Apr 2026 00:30:52 +0000 (UTC)
Received: from aion.redhat.com (localhost [IPv6:::1])
	by aion.redhat.com (Postfix) with ESMTP id D1D4B749EAB;
	Fri, 03 Apr 2026 20:30:50 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: calum.mackay@oracle.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 0/5] pynfs: a handful of fixes and a new CB_GETATTR test
Date: Fri,  3 Apr 2026 20:30:45 -0400
Message-ID: <20260404003050.1560149-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

Patches 1-4 are fixes/cleanups.

Patch 5 simulates an actual application issue where the application is
failing because it's getting a unexpected/surprise mtime update for a
file that it's tracking.

v2 changes:
- Reordered patches 3 & 4
- Patch 4 now fixes the erroneous check instead of removing it, fixes
  issues w/ the initialization of cbattrs, and calls compareTimes()
  to compare the mtimes
- Patch 5 now calls compareTimes() to compare the mtimes

Scott Mayhew (5):
  pynfs: ensure tests clean up after themselves
  pynfs: fix the check for delegated attribute support
  pynfs: _testCbGetattr() should check the delegation that was received
  pynfs: fix erroneous test in DELEG24 and DELEG25
  pynfs: add delegation test for CB_GETATTR after sync WRITE

 nfs4.1/server41tests/st_courtesy.py   |   2 +
 nfs4.1/server41tests/st_delegation.py | 247 ++++++++++++++++++++++----
 nfs4.1/server41tests/st_sparse.py     |  10 +-
 3 files changed, 228 insertions(+), 31 deletions(-)

-- 
2.53.0

