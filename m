Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 725CD3093B8
	for <linux-nfs@vger.kernel.org>; Fri,  3 Jul 2026 16:39:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783096798; cv=none; b=oRGxxhfYirL/fC+SpzoJwCJ5yK1Yk/NkeZUl6jPYrsbfyyN6cWlXz/xsio2MW50UU5N/rpZuUnzTog9ZnmyLQ/bQw2r+AxH8WNywlLVKkwxNofpuR52blvMILqdiQt5D58bUufTG/rpUwPlbJyToJpRqMiBKeD7fDMVpFJbKIJA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783096798; c=relaxed/simple;
	bh=DKhPh0Op5Nv+TPxb5fU3xICaTUTBsK9whbLeWkREHKM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=QPbWSanc7j5SJsINe1N/cIf3Ke7IGBweot68iGf9AhTEwgHRciDocZXEqfn58SQ81r0vrQFk/YVr+Aiv9JWMboZouIuCbiZiQv9D9lyEIHy2pcyeA/gDdPoV/09wNhfJxrmKpO/pwv7zJWR0lDJdUG8mfwSlquRbsSEohN0x6Y0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=dVkkX8BG; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="dVkkX8BG"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1783096795;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=u+XBwq6bGwAbDe/8Fw1Bnv+/J/Kqdp6g4pkaoorSGco=;
	b=dVkkX8BGrWept+8/X6XbBLHD1mwhei3jMP8LgJHH8v0plNJvzrTxKjiLNqyxYD/XcJ0ACV
	bCmwwl83z5EJ3EJXoRmefpaoKDdPxNKcSQvGScA2yPPKXOk5eBPz9vc8+939JRb/auCb2l
	dKQiybmvZgtXtWcm7I9SrMfr16jLJKg=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-319-osKVrVS-OFyR7j13KupcqQ-1; Fri,
 03 Jul 2026 12:39:54 -0400
X-MC-Unique: osKVrVS-OFyR7j13KupcqQ-1
X-Mimecast-MFC-AGG-ID: osKVrVS-OFyR7j13KupcqQ_1783096793
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 4C497187958A
	for <linux-nfs@vger.kernel.org>; Fri,  3 Jul 2026 16:39:53 +0000 (UTC)
Received: from tbecker-thinkpadp16vgen1.rmtbr.csb (unknown [10.96.134.41])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 0F94C1800846;
	Fri,  3 Jul 2026 16:39:51 +0000 (UTC)
From: tbecker@redhat.com
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com,
	Thiago Becker <tbecker@redhat.com>
Subject: [PATCH 1/2] rpc.gssd: Decrement client referece count on error paths
Date: Fri,  3 Jul 2026 13:39:44 -0300
Message-ID: <20260703163946.2185163-2-tbecker@redhat.com>
In-Reply-To: <20260703163946.2185163-1-tbecker@redhat.com>
References: <20260703163946.2185163-1-tbecker@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

From: Thiago Becker <tbecker@redhat.com>

Assisted-by: Claude:claude-sonnet-4-5
Signed-off-by: Thiago Becker <tbecker@redhat.com>
---
 utils/gssd/gssd_proc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
index e060bee3..27b6fe4f 100644
--- a/utils/gssd/gssd_proc.c
+++ b/utils/gssd/gssd_proc.c
@@ -897,6 +897,9 @@ out_srchost:
 	if (info->srchost)
 		free(info->srchost);
 out_info:
+	pthread_mutex_lock(&clp_lock);
+	clp->refcount--;
+	pthread_mutex_unlock(&clp_lock);
 	free(info);
 	info = NULL;
 	goto out;
-- 
2.54.0

