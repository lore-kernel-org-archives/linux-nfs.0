Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794021160;
	b=qhC+AA9enCvCzex2egcq8oy7TslJ69ec2jtPDM/48OV0XNpmfk4FnIgSRjel1i5U4pE/
	 v3zuc4PZOY9I0Ctj3v8QVvg8U+tvauVxRjgYuiaim6Cf4ui94eesCbeb2txes2ld8QRSw
	 TYGtgJuR/KEC0F9sl2T9+BIx0g5iE1zRLXwh7q407NTsFlWvwJ0DW3jhxwBZjUXK1TCmj
	 /mBPws5XFIxBs60TzE+iU8nrU1mlOMCaY2xiCc8jrxMeRolGRHvmBQKyf8cjaplzd61Xw
	 EPXVtWIKSj1sbC+YMhv13cP2kTT0Jq//iF5jUiiDTg63Au6Scu/Bi9HWZzfovOuMlEA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794021160;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:From:To:Cc:Subject:Date:
	 Message-ID:MIME-Version:Content-Transfer-Encoding:X-Scanned-By;
	bh=J2lV//bc1TggjRT3bFWXt+yH8QO1hT7IDi6qP0XbCVo=;
	b=PJ7/VWyp8BdSR/oGKCYck+x+a9jYXQdwsGOjdEi+wGD643LSYUjHjZhSPYyk3lAcD65S
	 Ke2TSOpSdUBKdyzudLwMS5Mxp0lKCXTFUrlliwNQAGNMfmewv82q0Ss3iCDmRj/XIEP0O
	 XDi8oq87ffEXG+3jAN4nppEDo3nsu90eUQIvpg2Dq+1A4tB2M3LQIMV43Tv7dt7f2dwVe
	 IzoJwj6ei1QqI4BNmy/0PIb5EdaKC/G2wS9ngb0aC8pdQajAJhAvXr+z15skchgJS/TbA
	 6Q457ks/HjXVjDDVqY9hrmQwtWSMXb4D/cR4n3+Bfnv1BMQCyLy5rlUQfhBkNJAxs3A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=K0ntF4Kn;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2D71A606A32E
	for <linux-nfs@vger.kernel.org>; Sat,  7 Nov 2026 03:12:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 2D71A606A32E
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=K0ntF4Kn
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1794021159;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=J2lV//bc1TggjRT3bFWXt+yH8QO1hT7IDi6qP0XbCVo=;
	b=K0ntF4KnN8Uu7jgg+n6tP6/EwXSqiiXJ/FnpKtW+WR/V7c6GCTLlgnF0V9VAS7vrcuYfuf
	RU6xNASe8uBoY4Sz8vpK6ye5AMJM933C98wLoc8yi31osvvSN6L8s3W3CMfo4RbmtBqtiI
	ps+QKy5KTaIsCJ4MzKjEW5L4cdtTH9Q=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-376-UxxPEOrCOxihqelSi7IcgA-1; Fri,
 06 Nov 2026 22:12:35 -0500
X-MC-Unique: UxxPEOrCOxihqelSi7IcgA-1
X-Mimecast-MFC-AGG-ID: UxxPEOrCOxihqelSi7IcgA_1794021154
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 56EFF1955F2A;
	Sat,  7 Nov 2026 03:12:34 +0000 (UTC)
Received: from okorniev-mac.redhat.com (unknown [10.22.64.6])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 9FE17187C364;
	Sat,  7 Nov 2026 03:12:33 +0000 (UTC)
From: Olga Kornievskaia <okorniev@redhat.com>
To: trondmy@kernel.org,
	anna@kernel.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 0/2] NFSv4: fix blocking lock stalls under a delegation
Date: Fri,  6 Nov 2026 22:12:30 -0500
Message-ID: <20261107031232.97464-1-okorniev@redhat.com>
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
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

A test on a single client runs two processes that repeatedly acquire and
release a POSIX lock on the same file on an NFSv4.1 mount, so that they
compete for it, and measures how long each acquisition takes. When the
open is granted a delegation, some acquisitions take unexpectedly long -
almost exactly 1, 3 or 7 seconds - although the holder releases the lock
within microseconds.

Over 20s and 2.4M acquisitions the slowest five were 3119404us,
3119248us, 1040679us, 1040288us and 1040212us. When the server grants no
delegation, nothing exceeds 12ms.

The delegation case breaks the notification of waiters on the unlock
path, in two independent places:

 - NFS_STATE_MAY_NOTIFY_LOCK can only be learned from an OPEN reply, and
   an open satisfied from a delegation produces none. The waiter is
   therefore not on clp->cl_lock_waitq at all, and polls instead with a
   doubling 1s/2s/4s backoff - which is where the 1, 3 and 7 second
   acquisitions come from.

 - Nothing wakes cl_lock_waitq when such a lock is released, since the
   server never saw it and cannot send a CB_NOTIFY_LOCK. A waiter that
   does reach that queue sleeps out the full 30s NFS4_LOCK_MAXTIMEOUT.

Both need fixing: one puts the waiter somewhere reachable, the other
reaches it. They are ordered so that no halfway point regresses - the
wake comes first, since adding it alone is harmless, whereas routing
waiters onto the queue first would turn the 1-7s stalls into 30s ones.

With both applied the same test shows no acquisition over 2476us, total
throughput up 23%, and the two processes splitting the work evenly
(1464283/1464448, against 1029148/1355029 before).

Olga Kornievskaia (2):
  NFSv4: wake blocking lock waiters when a delegated lock  is released
  NFSv4: remember that the server may send CB_NOTIFY_LOCK

 fs/nfs/nfs4proc.c         | 21 ++++++++++++++++++---
 include/linux/nfs_fs_sb.h |  1 +
 2 files changed, 19 insertions(+), 3 deletions(-)

-- 
2.52.0

