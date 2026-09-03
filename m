Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.133.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 790D4476CD2
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:53:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.133.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788458000; cv=none; b=PmqhxQGTAuAviXYvk46a/iEfH0IQVTph8yTO8pYkAlKdTr5AQa+FVRtvEMmBxQWCBNhCm71E1NfbcpjMSMxzKyA4d7j5LGL81FlON7ZbTvHwhmuuAWtyin8m78fBa89pcltAXdhcQjZiAlJIDYbicxdZs3XSg7t9ytTZ+iaBDHE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788458000; c=relaxed/simple;
	bh=Gnf7cvfwwMgs0dqfEioa4kFoifQq+gzpdas4fNfBdsI=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=TjVzDg7LQY43ElQbMS1E7ZibQ9KoTJwCd+mjWrejnwR0DSUC+cI6CoMtnA7zGePvK3TU50OJJlJPzHtCSb1ZpeTrQvZ+2MFazLI3inG1uSMpkdWLiTwjLu052CtmGH68TJQEc5AC1KhMLtqQXo+KKQXqkL7W8ZzLyhW5FntyVXM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=Xd8qCHBw; arc=none smtp.client-ip=170.10.133.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="Xd8qCHBw"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788457997;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=rKkce7w9OCOfHc6Dm+lcvgJJcQJvOuZ26HZLVsqjCAA=;
	b=Xd8qCHBwnCH/ccVrHk+yhEohf2ykED3hI6zITMMpmrBGJRoXsBX7wy2LyB87wkXdDanZk0
	qnPPQEbHZDOickptiysFRO6eV6/MWAkD4tWaOcjt43BYKVfgH7jV51WwXexQ/HYNdrCeOC
	2IeB33BB1Nccu1DEFTIDv3lO+GI4dHc=
Received: from mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-35-165-154-97.us-west-2.compute.amazonaws.com [35.165.154.97]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-218-bpekY4yVN5-EEZV5ZsjR3g-1; Thu,
 03 Sep 2026 13:53:15 -0400
X-MC-Unique: bpekY4yVN5-EEZV5ZsjR3g-1
X-Mimecast-MFC-AGG-ID: bpekY4yVN5-EEZV5ZsjR3g_1788457995
Received: from mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.95])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 14B12185513C
	for <linux-nfs@vger.kernel.org>; Thu,  3 Sep 2026 17:53:15 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (headnet05.pony-001.prod.iad2.dc.redhat.com [10.2.32.117])
	by mx-prod-int-10.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id E72D37E3;
	Thu,  3 Sep 2026 17:53:14 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.redhat.corp (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 269515345B8E;
	Thu, 03 Sep 2026 13:53:14 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 0/2] Two hardening fixes for junction handling
Date: Thu,  3 Sep 2026 13:53:11 -0400
Message-ID: <20260903175313.1214070-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.6 on 10.30.177.95

The first patch fixes a buffer overrun in junction_parse_xml_read()
and the second fixes a use-after-free when parsing multi-location
junctions in locations_to_fslocdata().

Scott Mayhew (2):
  junction: fix buffer over-read in junction_parse_xml_read()
  junction: fix use-after-free in locations_to_fslocdata()

 support/export/cache.c      | 6 ++++++
 support/junction/junction.c | 3 ++-
 2 files changed, 8 insertions(+), 1 deletion(-)

-- 
2.55.0

