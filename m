Received: from canpmsgout01.his.huawei.com (canpmsgout01.his.huawei.com [113.46.200.216])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E4C083FBED8
	for <linux-nfs@vger.kernel.org>; Tue, 14 Jul 2026 08:43:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.216
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784018595; cv=none; b=U+UDHittmUjvtrzF9a6BzZr/ZU//NC3pLmrWHXmofW2PozZA0sP1QXE62g2bxDknXGoi19uGsferFz8jHEdqaQ68ZDAQCAlvQ4W9JKgGn6BGdy0TMBGYV3xAqRQFmPfcbX9qo5N4UTgMUpZce9sEC1EKocbXX334oTR53N5SQD0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784018595; c=relaxed/simple;
	bh=ly7bQ4BAnAOC8P9fjgAl9GIS2fX6P0BTqvr7CwPzgS0=;
	h=Message-ID:Date:MIME-Version:From:To:CC:Subject:Content-Type; b=nBVYzed2MMbb+Y7m1yc4lCuXakfi+VP/sGTRigLafl+NYdBuERubgQtvxCWD+k4qjvJAkproH6thFlXQv3SxYQxgABufQWgdj6WI5Kk0Y6+t9mJSHeJYF20yBeqL6MIQm+/wHbIItqvk/3GRL89h0WmXEMLoQkNk3FsP9pU3BFc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=h-partners.com; dkim=pass (1024-bit key) header.d=h-partners.com header.i=@h-partners.com header.b=Utf51hUD; arc=none smtp.client-ip=113.46.200.216
Authentication-Results: smtp.subspace.kernel.org; dmarc=fail (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=h-partners.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=h-partners.com header.i=@h-partners.com header.b="Utf51hUD"
dkim-signature: v=1; a=rsa-sha256; d=h-partners.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=sUKQH4VdGipxeXjGUWsLEH0zhGUCBwnfMjsCPjNx1EE=;
	b=Utf51hUDz+WQ9d29LQZ4k3Ycp9Uym5CLgesz8TbAVCjDVOabOGx9y3aupiq4wT83JcFu0Ca5x
	pvI10KwSujLDe0uQIixcIGIfSPL19FeW5Cn06XR/59G0+e6l3YnbE6K9qKLt0omc8QmECQCGkUd
	dT4NbhQC4TyMf/K9LDrMbJY=
Received: from mail.maildlp.com (unknown [172.19.162.197])
	by canpmsgout01.his.huawei.com (SkyGuard) with ESMTPS id 4gzsz94Djpz1T4HL;
	Tue, 14 Jul 2026 16:33:57 +0800 (CST)
Received: from dggpemr100013.china.huawei.com (unknown [7.185.36.198])
	by mail.maildlp.com (Postfix) with ESMTPS id BEE1740579;
	Tue, 14 Jul 2026 16:43:06 +0800 (CST)
Received: from [10.174.186.66] (10.174.186.66) by
 dggpemr100013.china.huawei.com (7.185.36.198) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.1544.36; Tue, 14 Jul 2026 16:43:06 +0800
Message-ID: <356736aa-25d8-4b79-a50f-33b4e7035856@huawei.com>
Date: Tue, 14 Jul 2026 16:43:05 +0800
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
Subject: nfsd: fix memory overflow for haddr
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: kwepems100002.china.huawei.com (7.221.188.206) To
 dggpemr100013.china.huawei.com (7.185.36.198)

when hcounter is not 0, haddr memory is not enough.
asan report heap-buffer-overflow error in following scene:
CFLAGS="-fsanitize=address -g" ./configure && make
./utils/nfsd/nfsd -H 192.168.1.1 -H 192.168.1.2

Signed-off-by: zhangjian <zhangjian496@huawei.com>
---
 utils/nfsd/nfsd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index c95d32f4..e3fcdde4 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -185,7 +185,7 @@ main(int argc, char **argv)
 				hcounter = 0;
 			}
 			if (hcounter) {
-				haddr = realloc(haddr, sizeof(char*) * hcounter+1);
+				haddr = realloc(haddr, sizeof(char*) * (hcounter+1));
 				if(!haddr) {
 					fprintf(stderr, "%s: unable to allocate "
 							"memory.\n", progname);
-- 
2.33.0

