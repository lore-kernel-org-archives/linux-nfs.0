Received: from canpmsgout12.his.huawei.com (canpmsgout12.his.huawei.com [113.46.200.227])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4810242A7B8
	for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2026 08:42:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.227
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784018557; cv=none; b=Hgde0eu1ns7vHr1xcRiqxXIEMdKhptjhlqijS2ke6TcFAONFt2y1T2IMAqSgLvzd/mN8NLs3axheD6mO8K0IIx4ei+GEpqSTd+ixRIKrttalX+g2Pxs+oHOMsKJbi1+vkb5fVlnnncOihUpon9UYUvMWYNkv5B7UIWa2lIMRTEE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784018557; c=relaxed/simple;
	bh=uWljBgjEE3fb+0wRjCOcCGvvXFS6ubaWiiO+T+PsZ54=;
	h=Message-ID:Date:MIME-Version:From:To:CC:Subject:Content-Type; b=UaOcWFQeDWdovXS4f2Fh/215eQAkFVL+pj/ts9Z0Otwilj8jHJVEIwcuTkDKYtVJ7bP3cpr5uJVa9hTUBPq5qzMMGuTx+0IYQxHcff/8i74Fb1tH2RiEEQ0phCwZ+RzZSkpxinAX1Yz7dhK27O8EyhZpX3xue7ZNJ0N19ay2Dmg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=h-partners.com; dkim=pass (1024-bit key) header.d=h-partners.com header.i=@h-partners.com header.b=inHaSLqI; arc=none smtp.client-ip=113.46.200.227
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=h-partners.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=h-partners.com header.i=@h-partners.com header.b="inHaSLqI"
dkim-signature: v=1; a=rsa-sha256; d=h-partners.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=EK225dw/rHp/dKPo8dHbhnALHKbmt8SrRzJOnJpB660=;
	b=inHaSLqIo7QJeC7OE6k7n9xF98mszfeSLst4IAKKwawpCXLFT3miVUuz3gJClgN2hmh5IgVyA
	0sBmwUi17s6ArWNOKaPRJ7ioQEAAO4qTJ7k+tL+C61a+B+GiE3X0oi2YojvTuzN5bcEQ29+XwkE
	cH5kVi38SUUA5cSdESjByCw=
Received: from mail.maildlp.com (unknown [172.19.163.214])
	by canpmsgout12.his.huawei.com (SkyGuard) with ESMTPS id 4gzsxn6RR5znTVd;
	Tue, 14 Jul 2026 16:32:45 +0800 (CST)
Received: from dggpemr100013.china.huawei.com (unknown [7.185.36.198])
	by mail.maildlp.com (Postfix) with ESMTPS id B18594056C;
	Tue, 14 Jul 2026 16:42:21 +0800 (CST)
Received: from [10.174.186.66] (10.174.186.66) by
 dggpemr100013.china.huawei.com (7.185.36.198) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1544.36; Tue, 14 Jul 2026 16:42:21 +0800
Message-ID: <a0df2e1c-27fe-44cd-9a97-f04134f029f5@huawei.com>
Date: Tue, 14 Jul 2026 16:42:20 +0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
From: "zhangjian (CG)" <zhangjian496@huawei.com>
To: <steved@redhat.com>, <chuck.lever@oracle.com>
CC: <linux-nfs@vger.kernel.org>
Subject: gssd: fix memory leak in gssd_free_client
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: kwepems100002.china.huawei.com (7.221.188.206) To
 dggpemr100013.china.huawei.com (7.185.36.198)

clp->servername is always not null, so upcall_* is never free.

Signed-off-by: zhangjian <zhangjian496@huawei.com>
---
 utils/gssd/gssd.c | 24 ++++++++++++++----------
 1 file changed, 14 insertions(+), 10 deletions(-)

diff --git a/utils/gssd/gssd.c b/utils/gssd/gssd.c
index 1c901991..bad92321 100644
--- a/utils/gssd/gssd.c
+++ b/utils/gssd/gssd.c
@@ -360,6 +360,10 @@ gssd_read_service_info(int dirfd, struct clnt_info *clp)
 	clp->prog = program;
 	clp->vers = version;
 	clp->protocol = protoname;
+	clp->upcall_address = NULL;
+	clp->upcall_port = NULL;
+	clp->upcall_protoname = NULL;
+	clp->upcall_service = NULL;
 
 	goto out;
 
@@ -414,16 +418,16 @@ gssd_free_client(struct clnt_info *clp)
 	free(clp->servicename);
 	free(clp->servername);
 	free(clp->protocol);
-	if (!clp->servername) {
-		if (clp->upcall_address)
-			free(clp->upcall_address);
-		if (clp->upcall_port)
-			free(clp->upcall_port);
-		if (clp->upcall_protoname)
-			free(clp->upcall_protoname);
-		if (clp->upcall_service)
-			free(clp->upcall_service);
-	}
+
+	if (clp->upcall_address)
+		free(clp->upcall_address);
+	if (clp->upcall_port)
+		free(clp->upcall_port);
+	if (clp->upcall_protoname)
+		free(clp->upcall_protoname);
+	if (clp->upcall_service)
+		free(clp->upcall_service);
+
 	free(clp);
 }
 
-- 
2.33.0

