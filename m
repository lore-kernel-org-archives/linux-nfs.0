Received: from mail-qv1-f41.google.com (mail-qv1-f41.google.com [209.85.219.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F056928C037
	for <linux-nfs@vger.kernel.org>; Wed, 19 Aug 2026 00:00:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.219.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787097617; cv=none; b=bEVJK98B6rbG/AZ+EdbxS8R4i4U3SxovV0PwUVnNw3cAE7AzS6NtwSEXP/+gISKWPJvhHg/3UGkio+daLe6GjPL0qGvOgXECH8KDiX2zfoUQOlftGn1huYhDfUU7LQOj91U7zm9oQwq0NCUtWrlZhXTDCSLqWatl98ZaNd9ujIo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787097617; c=relaxed/simple;
	bh=RGcF+u9DUavHVUXEAyTYRPC2JvtFSIsGnRlyN4lI1r0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=R7o8uggM+CeJBVfdjxPsS5Q3gtMbJpptgHRVw73xNFv4I/JTliBA68QlsbfErOK3wH1BKhngxBB2sd4k+v/pPYwutCvNbFam08AZr+Bgu/T7r/RanEfcTjlIxWz7t0QH1+iDOPotyKNsyvSdmPI+Z96Iyf35pN+wnvaZwuIAEZc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=ColxfEZ8; arc=none smtp.client-ip=209.85.219.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ColxfEZ8"
Received: by mail-qv1-f41.google.com with SMTP id 6a1803df08f44-8f29ec73064so3792936d6.1
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 17:00:15 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787097615; x=1787702415; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=bhMmjxVOtiNQPWpFJIbQMFC0gpto3yw0yEJp5AQOy60=;
        b=ColxfEZ8pO5DIFHtVbvW5GUKNKrVHrwO0NkOQc1Md9LkGQevZdSBiN/NSTIwFTKJfH
         +LUGwAAY1UTpx7fUMQQVICDNKz+M4P9kj+JGv1VWnjL3lLqyvC+0nQxp12kHcX7tWOUp
         1iwZBv1OaK+dogCwQ01y88b1KMZKy8/0ePnV3sql4KFIV17Biz8sY8XwdRqozJd/vdzc
         +xSE/70+V4mBWQZaRkGQt+uuS5ULkPPP737NZBPQr4EgZjLqQyttXIVMoIx6qKoqpw3F
         O7ug3TVkttTp5ZbpZm7rD6MYq9hQIpScIITtkkrGDWFdn2PKgYHdpcSo23x+QCdBBpEO
         s8Yg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787097615; x=1787702415;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=bhMmjxVOtiNQPWpFJIbQMFC0gpto3yw0yEJp5AQOy60=;
        b=IK+jIfk0IykRcYjhYV7zlaAy2DBM3XHYnUQWN3Loz52waGxEfaQShWlmpXVxVvLCGc
         pDs6x5+QIBcy3aBO9TDQPtMAlplI1EQQSoR9p4YaNWa3aUHSqRHkAeXX8o5FWbueZTTL
         NRC3ZIgytIm1CaXBTlbL0PUONh0azTlOfirvcJzm1alNFYnbL2b6iOkCq4aAFs8hnrqW
         HCkBDtWMq/aCaOSZw2n3dqGfINGz/pEoABHCa9blKxaYgusK3MBTAWtG5XHxrPqDCG4/
         7uGNRa+Eg+ZF5kExidNYfRNmIxIY6PFqWbswMlcObX61a9l/ZrGiHxQo+EW3I4eqstvQ
         Oj3Q==
X-Forwarded-Encrypted: i=1; AHgh+RqNBq+WBsXy0/d/9I5SSlW+hhyiIEffa1/0/nCzapkSrgrRI8KLWiZsh2wzF7xGIy2vPVwzyeLOa24=@vger.kernel.org
X-Gm-Message-State: AOJu0YwrrKC2JyjtGo/J4eD0MflNnaDYbvwjjAelBBLpfbVGj1TqkF4k
	jkc57oKShrGPA42DJ9Tzw4G/PNjEx1v2GT5QVWBlqhvu/aiaRXDdFdmN
X-Gm-Gg: AR+sD119PWy2M0rzPfYuxArR1F4xzarOU/G5+AwKkmz17oSAYdsmMa4DiPzUrOE6k9H
	diJccllDAxMOd5IZ0pOEHAZHziFsqghTlMU3FC/BlS3PZHf6if9TrYjUxiuV5SUMoRrCCjBx6IR
	n7tJ2hr62QBIrQN5oC+Y23e8H0tVXjkeSXI4yASr0t4MPRI6lGTbdh58EjiAQmH17q3K5fQ884M
	Cv8d/DeCy1yWyj2ValMJq7PLzqyc6pDEwQsaB2NnJFzx3CS+HbhaHHN1VuybFhcQcVJTbmezzTY
	yvgK4p5kPXg/x1E+UKuh4Dun7hKaoaV11W54ILzKk/HjIfvJe6TahwqKtVb9YmXMiUOx7uYo7KQ
	SG5kmUweeG7e9dyfUBcMfVSHZIsKGO0NMDIhD0CdbR1ufXy3uEzBy3UUwG+XnpKS0iBxaWkNRdO
	zqc6c5Dc/rwssE4zab6IUC4GLaZBP3aKlwH7+3Zld6fy9/HYFBSG4Tf8k472bqIxITVo3Tu8WSd
	lw5GvyKJAim4HAtkg==
X-Received: by 2002:a05:620a:839a:b0:92e:7ba3:73e5 with SMTP id af79cd13be357-9371e670fdfmr120525385a.42.1787097614629;
        Tue, 18 Aug 2026 17:00:14 -0700 (PDT)
Received: from i4-l-hqh5357-03.ad.psu.edu ([130.203.139.71])
        by smtp.gmail.com with ESMTPSA id af79cd13be357-9372058d4f2sm12424185a.40.2026.08.18.17.00.14
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 18 Aug 2026 17:00:14 -0700 (PDT)
From: Shuangpeng Bai <shuangpeng.kernel@gmail.com>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Shuangpeng Bai <shuangpeng.kernel@gmail.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [BUG] lockd: KASAN: slab-use-after-free in nlm_async_call
Date: Tue, 18 Aug 2026 19:58:06 -0400
Message-ID: <20260818235808.3458075-1-shuangpeng.kernel@gmail.com>
X-Mailer: git-send-email 2.43.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Kernel Maintainers,

I hit the following report while testing current upstream kernel:

KASAN: slab-use-after-free in nlm_async_call

on commit: 3aa1dcaa4f6f5ae08936491e08bd456f331f2d40 (2026-08-13)

To help trigger the bug more reliably, we applied a minimal diagnostic patch
that only adds delays and print statements.

The reproducer and .config files are here.
https://gist.github.com/shuangpengbai/e0569a211da5a1738fb91b1833465662

I'm happy to test debug patches or provide additional information.

Reported-by: Shuangpeng Bai <shuangpeng.kernel@gmail.com>

[  193.891339][ T8377] BUG: KASAN: slab-use-after-free in nlm_async_call+0xd6/0x230
[  193.893522][ T8377] Read of size 8 at addr ffff88811b04c808 by task lockd/8377
[  193.895154][ T8377]
[  193.895574][ T8377] Call Trace:
[  193.895578][ T8377]  <TASK>
[  193.895581][ T8377]  dump_stack_lvl+0x26/0x80
[  193.895592][ T8377]  print_report+0x147/0x790
[  193.895619][ T8377]  kasan_report+0xc3/0x100
[  193.895631][ T8377]  nlm_async_call+0xd6/0x230
[  193.895688][ T8377]  nlmsvc_retry_blocked+0x61c/0x800
[  193.895695][ T8377]  lockd+0x144/0x1c0
[  193.895702][ T8377]  kthread+0x2f2/0x3c0
[  193.895722][ T8377]  ret_from_fork+0x27d/0x670
[  193.895747][ T8377]  ret_from_fork_asm+0x1a/0x30
[  193.895754][ T8377]  </TASK>
[  193.913276][ T8377] Allocated by task 8377 on cpu 1 at 181.704904s:
[  193.914652][ T8377]  __kmalloc_cache_noprof+0x248/0x4b0
[  193.915123][ T8377]  nlm_alloc_call+0x4b/0x1b0
[  193.915527][ T8377]  nlmsvc_lock+0x3d2/0xfc0
[  193.915922][ T8377]  nlm4svc_do_lock+0x291/0x480
[  193.916341][ T8377]  nlmsvc_dispatch+0xac/0x1b0
[  193.916752][ T8377]  svc_process_common+0x1229/0x1700
[  193.917211][ T8377]  svc_process+0x26b/0x560
[  193.917601][ T8377]  svc_recv+0x1690/0x1c70
[  193.917986][ T8377]  lockd+0x14e/0x1c0
[  193.919766][ T8377] Freed by task 8392 on cpu 1 at 192.290946s:
[  193.921551][ T8377]  kfree+0x134/0x450
[  193.921895][ T8377]  nlmsvc_release_block+0x231/0x290
[  193.922345][ T8377]  nlmsvc_traverse_blocks+0x139/0x1b0
[  193.922816][ T8377]  nlm_traverse_files+0x1aa/0xa00
[  193.923250][ T8377]  nlmsvc_free_host_resources+0x12/0x60
[  193.923726][ T8377]  nlm_shutdown_hosts_net+0x127/0x280
[  193.924193][ T8377]  lockd_down+0xd5/0x1c0
[  193.924561][ T8377]  nfsd_destroy_serv+0x265/0x400
[  193.924994][ T8377]  nfsd_shutdown_threads+0xbb/0x100
[  193.925443][ T8377]  nfsd_umount+0x3b/0xc0
[  193.925815][ T8377]  deactivate_locked_super+0x9c/0x230
[  193.926279][ T8377]  cleanup_mnt+0x3a8/0x420


Best,
Shuangpeng
