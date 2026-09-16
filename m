Received: from szxga01-in.huawei.com (szxga01-in.huawei.com [45.249.212.187])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3584141E6CD;
	Wed, 16 Sep 2026 07:15:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=45.249.212.187
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789542944; cv=none; b=tyjvi5+LVxS/SLkANinKm7/TdaI1zg+MZKOw6Ubi7IdVjfzeZh/n2ptvPJw++CD/v2Eo435D346doiz/LfumhnvzyyXwztpFPu7sDGLp7S8oNq7x/I4pxqNqQljOXV1AgjGqHS2FOkirOlRKO8OMbAwKA55b6IR3Lfr5rEl/99E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789542944; c=relaxed/simple;
	bh=qbaiVgf+FPhg9ry/RsD0C9yh5wWMVw6jOEGioOdbWqE=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=u+r+/PYjJ2xH5bc6o3eXL5v2+KoZB2Y8l+0wp2/KTboli4aZzbXAMmxHdIvAB6oQoVW/OQEtnu7Tn/BSIl6aQdsMq0oR9zQAiFI7KbDtZp+Vyb1HZwzbl2ex6K8LUwJZ8zcX0Jx0OXXa9zx8Efk3qcAB+bxv3TAzbnD4gFBqgUI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=sddbpjbj; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=sddbpjbj; arc=none smtp.client-ip=45.249.212.187
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="sddbpjbj";
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="sddbpjbj"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=qbaiVgf+FPhg9ry/RsD0C9yh5wWMVw6jOEGioOdbWqE=;
	b=sddbpjbjTNkjPD/h8yl9ZQPRMx1qGtmVtYzjSTlbG9GUdtNlf7wSR04H/9HDlfabW49JpmWWL
	SxWWAlxZGpOoWXj/LRqnoH38KB9Rx4FVm4iFd4q0OvCRSDzDx54x618c//99vBUeUAHU3YZFm+W
	l7DQ1gZUNSjXZ5iisFguYfA=
Received: from canpmsgout12.his.huawei.com (unknown [172.19.92.144])
	by szxga01-in.huawei.com (SkyGuard) with ESMTPS id 4hl99y3lPZz1BG4P;
	Wed, 16 Sep 2026 15:14:30 +0800 (CST)
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=qbaiVgf+FPhg9ry/RsD0C9yh5wWMVw6jOEGioOdbWqE=;
	b=sddbpjbjTNkjPD/h8yl9ZQPRMx1qGtmVtYzjSTlbG9GUdtNlf7wSR04H/9HDlfabW49JpmWWL
	SxWWAlxZGpOoWXj/LRqnoH38KB9Rx4FVm4iFd4q0OvCRSDzDx54x618c//99vBUeUAHU3YZFm+W
	l7DQ1gZUNSjXZ5iisFguYfA=
Received: from mail.maildlp.com (unknown [172.19.163.15])
	by canpmsgout12.his.huawei.com (SkyGuard) with ESMTPS id 4hl8yB3yvjznTZk;
	Wed, 16 Sep 2026 15:04:18 +0800 (CST)
Received: from dggpemr200001.china.huawei.com (unknown [7.185.36.96])
	by mail.maildlp.com (Postfix) with ESMTPS id A532040586;
	Wed, 16 Sep 2026 15:15:23 +0800 (CST)
Received: from huawei.com (10.50.85.155) by dggpemr200001.china.huawei.com
 (7.185.36.96) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Wed, 16 Sep
 2026 15:15:22 +0800
From: Ran Hongyun <ranhongyun1@huawei.com>
To: <jlayton@kernel.org>
CC: <anna@kernel.org>, <bcodding@redhat.com>, <cel@kernel.org>,
	<chengzhihao1@huawei.com>, <linux-kernel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>, <ranhongyun1@huawei.com>, <trondmy@kernel.org>,
	<viro@zeniv.linux.org.uk>, <yangerkun@huawei.com>, <yi.zhang@huawei.com>
Subject: Re: [PATCH 0/2] lockd: fix two bugs on nlmclnt_find_lockowner() failure path
Date: Wed, 16 Sep 2026 15:07:41 +0800
Message-ID: <20260916070741.350612-1-ranhongyun1@huawei.com>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <b17182c347ab5cc092a50cb16c9c11dc9fe449bc.camel@kernel.org>
References: <b17182c347ab5cc092a50cb16c9c11dc9fe449bc.camel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: kwepems200001.china.huawei.com (7.221.188.67) To
 dggpemr200001.china.huawei.com (7.185.36.96)

Friendly ping.
