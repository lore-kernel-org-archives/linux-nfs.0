Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A43BF4FB9C5
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:42:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788457372; cv=none; b=pMTD/2sFwDPdNhHFIrShnteU+llhYXwN4kXIIUsvpSxV1JWiCSNV9DmfFwo2QTUhwvJ5RtJ2u2UMN4i3J6GQevnKslLbRHWHXoXO7G3BuY3G9vYgdN4bSe8f+5vbjeMFo6QoV+nTn3i0c6LjikITLNJltK/6Eg6E7VgNnjJEPYo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788457372; c=relaxed/simple;
	bh=FjchqrC25VZkCW+UDxdr4WdgFMzVEquoMHnip+Ni5B4=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=bfPqtgw2xWcdFEt9ACREGULKHWsMl3zU71d/c+gwLB7xNHegPEtRi2MQwOaITHfJJH/MNXAgXx3C4Gpd8wJV9CaDVS7oLidRISiGXdBMDPdUTc6rdWPP7hEtQ9OVd+ks6+hbMvcDaj9DoshGGk1+0S7+OAioVgekH3NV5Ho+SLw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=JcUpHNuQ; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="JcUpHNuQ"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457369;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=+Cj+OqKlMd2XpTWosarFC0qvhv7I0XccHZp6xQJH9C0=;
	b=JcUpHNuQsRJh3mELQ4sauUI7amY3PVyep2mprWxt+q2+CChTaQqhBXO7R5CAZ1z6kV2dnA
	Rii5GVwLrdQkFX9tnqnRL+bPbekMO0ZirIwoWdj+6PqIcyrgqtsFU0K9sUpg6pjHaJ6QXY
	on/FA3t9jsPux5men3L7hRFykFi8fp8=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-50-3OlzmWOiMs6I00xYfaxZPg-1; Thu,
 03 Sep 2026 13:42:48 -0400
X-MC-Unique: 3OlzmWOiMs6I00xYfaxZPg-1
X-Mimecast-MFC-AGG-ID: 3OlzmWOiMs6I00xYfaxZPg_1788457367
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 48A17184BAB9
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:42:47 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 1FE8E1800643;
	Thu,  3 Sep 2026 17:42:47 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 130D753458E4;
	Thu, 03 Sep 2026 13:42:46 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [rpcbind PATCH 5/6] rpcbind: check for null netmask in addrmerge()
Date: Thu,  3 Sep 2026 13:42:44 -0400
Message-ID: <20260903174245.1213147-6-smayhew@redhat.com>
In-Reply-To: <20260903174245.1213147-1-smayhew@redhat.com>
References: <20260903174245.1213147-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

getifaddrs(3) states that ifa_netmask may contain a null pointer, so we
should skip interfaces where ifa_netmask is null to avoid triggering a
null dereference in bitmaskcmp().

This is mainly a defensive change - we only call bitmaskcmp() for
AF_INET/AF_INET6 addresses, and I'm not sure it's possible for an
interface to have an IP address but no netmask.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 src/util.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/src/util.c b/src/util.c
index ead4899..a61a8c6 100644
--- a/src/util.c
+++ b/src/util.c
@@ -165,7 +165,8 @@ addrmerge(struct netbuf *caller, char *serv_uaddr, char *clnt_uaddr,
 		ifsa = ifap->ifa_addr;
 		ifmasksa = ifap->ifa_netmask;
 
-		if (ifsa == NULL || ifsa->sa_family != hint_sa->sa_family ||
+		if (ifsa == NULL || ifmasksa == NULL ||
+		    ifsa->sa_family != hint_sa->sa_family ||
 		    !(ifap->ifa_flags & IFF_UP))
 			continue;
 
-- 
2.55.0

