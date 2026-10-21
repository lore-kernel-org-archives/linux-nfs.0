Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=170.10.133.124
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792622410;
	b=epYxDhh3ZWslSlHcgwyP8ThGwuS/N/HmbxBc4y1thjfD2xqQo1lOjq8jyUAoAIME14U9
	 kMFXEVrN/DRZb0IX5Da5aOcNtM06rfCdwe2ttWZfD3cce0p01J01i74+bK3W2WJk5UojS
	 /WDGmPJsDM6kflnYmBxVIUPtgM1bHZ/swCHyWE07C+PKJ9MJHPs8cNnGhJAf5BSV3rlVS
	 MD1TAbrHPC2WqLav/xiynJLaxbS0QIw06kN9IDD8J4wGdJ0q1zltqTM9S/hUYpELreS6F
	 iTenObKi+hau92Gc0SBtt4bRvnMpUPUbOWSHNnLXzMryFIw1kN5LemMXg0hG/+vcqKw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792622410;
	h=DMARC-Filter:DKIM-Signature:Received:X-MC-Unique:
	 X-Mimecast-MFC-AGG-ID:Received:Received:Received:From:To:Cc:Subject:
	 Date:Message-ID:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding:X-Scanned-By;
	bh=n2Q1EdFwAwOX6CLBzvDGepdzr+LwaMi2ZRBWr+fxOgw=;
	b=0XLv0WQOLGr2ka/SXR/+dzh/XKHBDCdbk2unNs8U4FBUA2MvxVWF2k/I783kGUl2rfC+
	 j8k5O3LW4y1Q9yt3pOeYRW4Oku9a6Dqxki4m4Igvf0Wz+VRE2bvVPlnlwU9tEOP1AGX7x
	 83GuKqHHYJ/gz11K86ALc5CloLZZFvD6z8dodMEs1sg9mX4MdmOz3YbgN72IpZbeRFS9D
	 rzNMHWi5cgy/w5BdgpeqEJvyTbbNbOfDu9cRRx7SpLqmTrLBIU+xs74gkLw1oYrCr3g4e
	 l8PPUsIWvDrX9HY7TrOQ7f0vzoY+48xoXc2SbsBApHYA6CurCwoTaNCnBhBXkVKclbA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=redhat.com;
	spf=pass smtp.mailfrom=redhat.com;
	dkim=pass header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=LWeJa+0y;
	arc=none smtp.remote-ip=170.10.133.124
Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 742DD60A2613
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 22:40:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 742DD60A2613
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=redhat.com header.i=@redhat.com header.a=rsa-sha256 header.s=mimecast20190719 header.b=LWeJa+0y
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1792622408;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=n2Q1EdFwAwOX6CLBzvDGepdzr+LwaMi2ZRBWr+fxOgw=;
	b=LWeJa+0y7VI+x5nINid4KStbsdmzD1dH00rTw3vxD6awRELvJrEfSIeEKpgVxdvLKZD+7i
	xiVTB+mq3zaLy/blKfyTwSoVi7i2n1MpllZcVs1OXnRBMk+gwReqz4h2LKtZyQD1WHTQLx
	Nz+Z2bTFeA9kZ25m7PI7OVpbV2L2aLs=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-552-f2URTtcfO5mdi-T4oHEcNg-1; Wed,
 21 Oct 2026 22:40:06 +0000
X-MC-Unique: f2URTtcfO5mdi-T4oHEcNg-1
X-Mimecast-MFC-AGG-ID: f2URTtcfO5mdi-T4oHEcNg_1792622406
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 29A0518001FB
	for <linux-nfs@vger.kernel.org>; Wed, 21 Oct 2026 22:40:06 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet04.pony-001.prod.iad2.dc.redhat.com [10.2.32.116])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id B5DEE1800677;
	Wed, 21 Oct 2026 22:40:05 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id F30D558CD885;
	Wed, 21 Oct 2026 18:40:04 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 1/2] sm-notify: fix multihomed address rotation and first-attempt address choice
Date: Wed, 21 Oct 2026 18:40:03 -0400
Message-ID: <20261021224004.2273010-2-smayhew@redhat.com>
In-Reply-To: <20261021224004.2273010-1-smayhew@redhat.com>
References: <20261021224004.2273010-1-smayhew@redhat.com>
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

notify_host() rotates through a host's addresses after 4 retransmits so
that all addresses of a multihomed peer are tried. Two defects prevented
this from working for dual-stack hosts:

1. The "find the end of the list" loop started from &first->ai_next,
   which had just been set to NULL, so instead of appending the removed
   head to the tail of the (new) list it set first->ai_next = first,
   orphaning that address. For a 2-address host this collapsed the list
   to a single entry after the first rotation, after which the
   ai_next != NULL guard was never true again and no further rotation
   could occur. Walk from &host->ai so the removed head is re-appended.

2. smn_alloc_host() initialized host->retries to 100 to "force address
   retry" on the first notify_host() call. That made sense when the code
   transmitted to 'first' (the original head) after rotating, but since
   commit e132bb5d ("sm-notify: Replace RPC code") the transmit uses
   host->ai->ai_addr (the new head). As a result the very first packet
   was sent to the second address returned by getaddrinfo(3), skipping
   the preferred first address. Combined with defect #1, a host whose
   name resolved to both an IPv6 and an IPv4 address had its IPv6
   address rotated out and orphaned before any packet was sent, pinning
   sm-notify to an unreachable IPv4 address. Initialize retries to 0; a
   freshly resolved addrinfo already has port 0, so the first call still
   performs an rpcbind lookup without forcing a rotation.

Fixes: e132bb5d ("sm-notify: Replace RPC code")
Assisted-by: LLM
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/statd/sm-notify.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/utils/statd/sm-notify.c b/utils/statd/sm-notify.c
index ed82b8f2..affaea28 100644
--- a/utils/statd/sm-notify.c
+++ b/utils/statd/sm-notify.c
@@ -235,7 +235,7 @@ smn_alloc_host(const char *hostname, const char *mon_name,
 
 	host->last_used = timestamp;
 	host->timeout = NSM_TIMEOUT;
-	host->retries = 100;		/* force address retry */
+	host->retries = 0;
 
 	return host;
 
@@ -722,13 +722,13 @@ notify_host(int sock, struct nsm_host *host)
 		/* don't rotate if there is only one addrinfo */
 		if (host->ai->ai_next != NULL) {
 			struct addrinfo *first = host->ai;
-			struct addrinfo **next = &host->ai;
+			struct addrinfo **next;
 
 			/* remove the first entry from the list */
 			host->ai = first->ai_next;
 			first->ai_next = NULL;
-			/* find the end of the list */
-			next = &first->ai_next;
+			/* find the end of the (new) list */
+			next = &host->ai;
 			while ( *next )
 				next = & (*next)->ai_next;
 			/* put first entry at end */
-- 
2.55.0

