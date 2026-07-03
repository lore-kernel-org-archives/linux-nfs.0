Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D043B30674D
	for <linux-nfs@vger.kernel.org>; Fri,  3 Jul 2026 16:39:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783096796; cv=none; b=CZFC0KPrzQnTpJwzfNu0utJWis94ykVp08D+3bJ0ats1pvaViUgGSP5VDkk0MtL3yWcstz/gxJfCpwTRGM4xF0bz6mjcL8lJ5+pO6BV5FwtqyR2rfWzoeNIhZD1Jr2KAY2VE19J7wbbDB4cJuRD1nK9ZVSnR6RPNT2UDOMgL2/0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783096796; c=relaxed/simple;
	bh=c313eWX+HUxrl7Ak9o8MadWTLW6nw1J9etR8W+jm01U=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=oo5lIlKhxdOncOpEFfYGJrYYQJM/QOcfXW04sOA5SYKDyqQ2yw7y0yfCzfMvkhDgP/jAgm7/ZtmKw1ovlhInXfego7J7LtWQNmUWGylbttCIHT1Ut1i3U0RVmU/PuOY1hIxE4s6deW1wEz/iTZbQHlz6oHOc6SE3KV74DQ71vC0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=YYKWQ7dS; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="YYKWQ7dS"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1783096793;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=+a0uAHP9myJ+gO0b8A3AG/XAsI83zio/5KtRajDPf3w=;
	b=YYKWQ7dSTZqcTFglWyliJO76T9DELEsMYxiIsR1WsKHBZNt1RelCc9C7FHsSPCrE4ada3b
	ELo3YaM6up85gA2gytLb2dNsb+DFPCx5nsICxGyqgu8WoH8UeUmUeQrNxRzrl/l3IMVsKQ
	zhzvwfy7YYamxbqboRWgbT6eSuJ/DXA=
Received: from mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-156-d2FWqxD7Or-wqq8Ev_qs4g-1; Fri,
 03 Jul 2026 12:39:52 -0400
X-MC-Unique: d2FWqxD7Or-wqq8Ev_qs4g-1
X-Mimecast-MFC-AGG-ID: d2FWqxD7Or-wqq8Ev_qs4g_1783096791
Received: from mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.111])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 9473018C107E
	for <linux-nfs@vger.kernel.org>; Fri,  3 Jul 2026 16:39:51 +0000 (UTC)
Received: from tbecker-thinkpadp16vgen1.rmtbr.csb (unknown [10.96.134.41])
	by mx-prod-int-08.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 55A401800869;
	Fri,  3 Jul 2026 16:39:50 +0000 (UTC)
From: tbecker@redhat.com
To: linux-nfs@vger.kernel.org
Cc: steved@redhat.com,
	Thiago Becker <tbecker@redhat.com>
Subject: [PATCH 0/2] rpc.gssd: Two resource leaks
Date: Fri,  3 Jul 2026 13:39:43 -0300
Message-ID: <20260703163946.2185163-1-tbecker@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.111

From: Thiago Becker <tbecker@redhat.com>

Patch 1 drops a reference to clnt_info when alloc_upcall_info fails.
Patch 2 frees the thread attributes before returning from
start_upcall_thread.

Both leaks were identified by claude sonnet 4.5, among some amount of
false positives that were hand filtered.

Thiago Becker (2):
  rpc.gssd: Decrement client referece count on error paths
  rpc.gssd: Call pthread_attr_destroy before returning from
    start_upcall_thread

 utils/gssd/gssd_proc.c | 4 ++++
 1 file changed, 4 insertions(+)

-- 
2.54.0

