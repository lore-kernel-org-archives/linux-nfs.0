Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8CE5C34888F
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2026 20:28:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783974495; cv=none; b=QON71HKRP8jGtlKz/RgFizeh0wKOCt8D5zXPXxczP6oU3GlDSNLgvoUFpdLj3bch5mIXKTWqOAq/Fp3gVSxAtPbjC0aqY1Kzs5T85LbmaGcx554ncFTHHHjoZ3V05cU/H2HhRUCP+LSDSTPTKJldDKexp0Wl5DTSmoWBkDqUYoo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783974495; c=relaxed/simple;
	bh=zsUnbOuS7l68vfmpqTCKIKIrBRGzC6ZwG5sdXCdVxqY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=QgEzuvp+eC1vShhlDtnIkweyB8mdCzW4IAR952tfGTwoJQLX3WeHArzpepjtKPxHHWqMBnp+1n7BxAffa0rCBawFxxm5gAvklPBDmF05uDbqqLWRQA64H56c9ch7Y1qcEyCMwprySVEYP2xHFEw9fikRaai8wixofTXkj2+LSJY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=VF6JraUN; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="VF6JraUN"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1783974493;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding;
	bh=AmLeFcg7l3LAx2IWeaVg50nD0eWRdYHexKwJhq8VxdY=;
	b=VF6JraUN+SvmR+RhErhJnd1wmlTzSEyOZ4shyX5kfZIt354i2PhelFafrzZxIGQuHg0LVD
	HsbyRLAfKFG9WoWlDkp4v6wEIdhog9FngOa8ViLUXurPG+I5ZPP1GW8rWITECXfiUn7J/V
	dy/VJFjE6loAuPHvXK9/PO5xs5FyD1M=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-271-SBrX4do_NkqdpujqIbi3JQ-1; Mon,
 13 Jul 2026 16:28:12 -0400
X-MC-Unique: SBrX4do_NkqdpujqIbi3JQ-1
X-Mimecast-MFC-AGG-ID: SBrX4do_NkqdpujqIbi3JQ_1783974491
Received: from mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.93])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 63CA21955EBC
	for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2026 20:28:11 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (unknown [10.22.80.127])
	by mx-prod-int-06.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 2C69B1800593;
	Mon, 13 Jul 2026 20:28:11 +0000 (UTC)
Received: from smayhew-thinkpadp1gen4i.remote.csb (localhost [IPv6:::1])
	by smayhew-thinkpadp1gen4i.remote.csb (Postfix) with ESMTP id 6D6544DEF896;
	Mon, 13 Jul 2026 16:28:10 -0400 (EDT)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH] Pass ignore_hosts to export_create() in export_read()
Date: Mon, 13 Jul 2026 16:28:09 -0400
Message-ID: <20260713202809.786079-1-smayhew@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.4.1 on 10.30.177.93

Commit 8f3d12ce ("nfs-server-generator: avoid using external services.")
added the 'ignore_hosts' flag to export_read() so nfs-server-generator
can bypass DNS queries when calling it.  If the export doesn't
already exist, export_read() calls export_create() with the 'canonical'
argument hard-coded to 0, triggering a DNS query in client_lookup().
An unresponsive DNS server can cause delays in nfs-server-generator and
can even lead to 'systemctl daemon-reload' timing out, leading to
further administrative issues.

nfs-server-generator only cares about *what* is exported, so it can
create the order-with-mounts.conf config drop-in.  It doesn't need to
know *who* those filesystems are exported to, so it has no need to
perform DNS queries.

Pass the 'ignore_hosts' flag from export_read() to export_create() to
avoid the unnecessary DNS queries.

Fixes: 8f3d12ce ("nfs-server-generator: avoid using external services.")
Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 support/export/export.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/support/export/export.c b/support/export/export.c
index 2c8c3335..3caee043 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -122,7 +122,7 @@ export_read(char *fname, int ignore_hosts)
 	while ((eep = getexportent(0)) != NULL) {
 		exp = export_lookup(eep->e_hostname, eep->e_path, ignore_hosts);
 		if (!exp) {
-			if (export_create(eep, 0))
+			if (export_create(eep, ignore_hosts))
 				/* possible complaints already logged */
 				volumes++;
 		}
-- 
2.55.0

