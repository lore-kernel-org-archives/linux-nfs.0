Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D719C4FB9AD
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:42:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457371; cv=none; b=U9nARPfHVjDSITxWgFaEb15OCYocZNpwmPtObt/zYsGK9SoKXQF8mbwzAxFdvULa9bqITqC9iQvCFlVll/jBHMjAZ5wGhObvJUPfQYB6EuDWp4XKt9i3h15+1kdoIuOJ9r7/58xKcvRIM41zacZpI6JbpMmv22+mt4A3SFcCNlo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457371; c=relaxed/simple;
	bh=3+Ri+hruoudikKvKG+3LVs5pCl29X90OuItGw6G40A8=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=Fy01wCgrBwfCYjO3jt9h6lmPxe+WJm4b/mrvjQzNSr/59dt9NJ9XBIaIsFJRkeEH/eKTpSmS+FsYSh0y+LUWj4BpwfaDh2MqHBRo1zUBf90J+MB/yV920S7RuxkvscNoNC9G6Uf3ti0SdNBwD4QVXetaexL8cV/c3VQKn0V3lnE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=FB23Pb6a; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="FB23Pb6a"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457369;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=o2m0b9vDzhXFUbhqICBC5UEyat7TPTU9ktthrnvd1R8=;
	b=FB23Pb6a1BCdQx+LOoWjghGTQ13NMshsKB6cDMK5p9MnZ53R4db1LAyAwgwuL8kgsn0zqP
	kAhBRYG7URDCJGBQ47BGKOFJSoWE0m9CSngnsNMxKVlCinks5yOvoN1LiCnEbGVMBahWSu
	c/li7QzIbSOLpw0YpxlLq+bz4T38NaU=
Received: from mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-191-pkTDERJsNni4FCToopQyEA-1; Thu,
 03 Sep 2026 13:42:47 -0400
X-MC-Unique: pkTDERJsNni4FCToopQyEA-1
X-Mimecast-MFC-AGG-ID: pkTDERJsNni4FCToopQyEA_1788457366
Received: from mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.4])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id ADE83190A085
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:42:46 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 879BD30001A2;
	Thu,  3 Sep 2026 17:42:46 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id BF9E653458C6;
	Thu, 03 Sep 2026 13:42:45 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [rpcbind PATCH 0/6] rpcbind: various hardening fixes
Date: Thu,  3 Sep 2026 13:42:39 -0400
Message-ID: <20260903174245.1213147-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.4

Various hardening fixes for rpcbind.  Many of these are related to
CALLIT/BCAST/INDIRECT processing, which in theory should be disabled
when --enable-rmtcalls was not passed to the configure script, except
currently that only prevents the forwarding port from being created.
Patch 3/6 addresses this by completely disabling remote call
functionality when --enable-rmtcalls is unset.

Scott Mayhew (6):
  rpcbind: only log failures in check_callit() if connection logging is
    enabled
  rpcbind: bound stats lists in rpcbs_getaddr() and rpcbs_rmtcall()
  rpcbind: fully disable remote calls when --enable-rmtcalls is unset
  rpcbind: restrict RPCBPROC_GETSTAT to loopback callers
  rpcbind: check for null netmask in addrmerge()
  rpcbind: only free the forward slot if the reply xid matched the
    request xid

 src/pmap_svc.c     |  2 ++
 src/rpcb_stat.c    | 37 ++++++++++++++++++++++++++++++++++---
 src/rpcb_svc.c     |  2 ++
 src/rpcb_svc_4.c   |  2 ++
 src/rpcb_svc_com.c | 24 ++++++++++++++++++++----
 src/rpcbind.h      |  5 +++++
 src/security.c     | 16 +++++++++++-----
 src/util.c         |  3 ++-
 8 files changed, 78 insertions(+), 13 deletions(-)

-- 
2.55.0

