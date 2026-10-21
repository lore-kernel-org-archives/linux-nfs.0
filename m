Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792622410;
	b=EYEId3cnNndI82L66lvhhTtVkbfj6Ip/wRNT29iuX2F1psiVtK6WUShK4d+810e0T/yv
	 KH7Oo7W7orLgTRgAXMtg5fpIU+eKdBtivTm0JI5TJz/XewZ0dazpzSMpr06TOWqfawf/a
	 ppemPyFoOl1bfoWbdaZM8uBRXJ21JLti6UZT7yHS4h5PL62nfHpSNgEA4wzbAVKzARaKy
	 5AEOuX42lev2UbsbYq7XPrmFPYjoWTNzWOH75QwPjxQY6UPJVJ+eYtjSfbUL5ZzgzCyF1
	 ypUZv5VdMcUHE/uws1sEn/eT5A2h5joqs3M0U8sno3Jl55wGUIgoeuy3aEJZ+tjWq+Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792622410;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:MIME-Version:Content-Transfer-Encoding:X-Scanned-By;
	bh=DfdxfCxsJTAhzjB2afrqvl/LRsuDYWBDNzzii4cZ/oc=;
	b=BNru5Mww/fAPC3wfkr3mSSA2+SupSYRXXOROzg89K0gnaDTS8BxwDEtCF389pfqjlb3S
	 51PajczkrsW49Yg1omO+lvDh0uiU14zEe0cflQFYCzNdWfeiVRRxm4UIfNczyM7TA2Ord
	 dzE5s6EC/KCWLQgRbcPnND1Wr4S1CUGmIitBiwU1h/A9l5kwWrAajXCYIwZtLjuZPj447
	 9yiQglleYfqw67VXfzfdFE0/a59Mihrk/S74AbA5i4OeFmsI7XZGEL+yIDL65SG4lLLhU
	 qSXiTVVaVXKr5igaFxeScHxm2AcR0PYJrwqtUlhjB2RUzGDipdoDKPtr8PmRJoR5RKw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=GSlV5buy;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7429A60A2611
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 22:40:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 7429A60A2611
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=GSlV5buy
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792622408;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=DfdxfCxsJTAhzjB2afrqvl/LRsuDYWBDNzzii4cZ/oc=;
	b=GSlV5buynjw8emrx99FZIRYBtAAdGqV5+SxPM+OsPteX+M4Unby+6USm+DFYwQd3s+nLZR
	oe019YXYMTW0LtBnYcCV9D2b8p0LFvxND5lSqfZ2bONpSvQPAA3/hWgCIRuPxG0GGFNRP6
	ZL+3doPnklIwkqZurHWX3Ub69AiuJXw=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-264-PHua7FgvOGiXz3DSpa9YZw-1; Wed,
 21 Oct 2026 18:40:06 -0400
X-MC-Unique: PHua7FgvOGiXz3DSpa9YZw-1
X-Mimecast-MFC-AGG-ID: PHua7FgvOGiXz3DSpa9YZw_1792622406
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id E3A4A1800365
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 22:40:05 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id B63767DD;
	Wed, 21 Oct 2026 22:40:05 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id E400A58CD884;
	Wed, 21 Oct 2026 18:40:04 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 0/2] sm-notify: fix IPv4/IPv6 host notification
Date: Wed, 21 Oct 2026 18:40:02 -0400
Message-ID: <20261021224004.2273010-1-smayhew@redhat.com>
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
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

This series fixes sm-notify failing to notify peers in mixed IPv4/IPv6
setups.

Patch 1 fixes the address-list rotation in notify_host(), which orphaned
addresses and sent the first packet to the wrong address, so a host with
multiple addresses could never be reached.

Patch 2 reworks sm-notify to use a separate socket per address family
instead of a single IPv6 socket relying on IPv4-mapped addresses.  This
removes the dependence on IPv4-mapped IPv6 addresses and lets a specific
source address (-v / outgoing-addr) notify peers of both families.

Scott Mayhew (2):
  sm-notify: fix multihomed address rotation and first-attempt address
    choice
  sm-notify: use a separate socket per address family

 utils/statd/sm-notify.c | 255 ++++++++++++++++++++++++++--------------
 1 file changed, 164 insertions(+), 91 deletions(-)

-- 
2.55.0

