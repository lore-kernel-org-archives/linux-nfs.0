Received: from canpmsgout06.his.huawei.com (canpmsgout06.his.huawei.com [113.46.200.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 006AC3F5BE4;
	Wed, 16 Sep 2026 07:09:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.221
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789542586; cv=none; b=CZqVWdmyvwbPg5wDMgE4cjeMXqajTcKGcdjKQNoe5f1oMiRdfuFYEr6ueAI6zlAgIN1dwHvSxf5UhmeU3QPm+A+ggCfquXQyJ1FSKAbhA3bI8pc2+xDYjuydEADTZ18Q8FFDakVQuC4oj+3BY0/+60j8a8lf0d1A/1Hqo8Xoe4E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789542586; c=relaxed/simple;
	bh=47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=WzUxZECDfvGi7/eKUuf8GzhsXKRJKaq7Fw8C0dh47JeWsGPYhkOAdQLkw9BNgb8E5FEK6dJwer6qWzoenosQSTVl+klLySDl4H29JF//z7yqZiGW0asAbtrqbClTPcEc5h1g9kFp4IYzJILN8pAUXaYRasKJkCTD+30D4OWzOqs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=Z9HQkU9I; arc=none smtp.client-ip=113.46.200.221
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="Z9HQkU9I"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=47DEQpj8HBSa+/TImW+5JCeuQeRkm5NMpJWZG3hSuFU=;
	b=Z9HQkU9IlC0lyh8tqAssUAmJEzXtPshdXzCBmilh1pdBu9wkH/xwq31yQ1lz0i4x3M5Xiy0MP
	Z3y6nFX20E595iQn31Mw1Y+x4YXptGpZhYlEZaju1dcB0ngMCkSbLWlj4s9zOTQjMa9ThZfFe5s
	oBcJnnBOUNCLP/LpxmXnPjk=
Received: from mail.maildlp.com (unknown [172.19.163.0])
	by canpmsgout06.his.huawei.com (SkyGuard) with ESMTPS id 4hl8qh4TBJzRhQs;
	Wed, 16 Sep 2026 14:58:40 +0800 (CST)
Received: from dggpemr200001.china.huawei.com (unknown [7.185.36.96])
	by mail.maildlp.com (Postfix) with ESMTPS id C2ACC40561;
	Wed, 16 Sep 2026 15:09:36 +0800 (CST)
Received: from huawei.com (10.50.85.155) by dggpemr200001.china.huawei.com
 (7.185.36.96) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Wed, 16 Sep
 2026 15:09:35 +0800
From: Ran Hongyun <ranhongyun1@huawei.com>
To: <jlayton@kernel.org>
CC: <anna@kernel.org>, <bcodding@redhat.com>, <cel@kernel.org>,
	<chengzhihao1@huawei.com>, <linux-kernel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>, <ranhongyun1@huawei.com>, <trondmy@kernel.org>,
	<viro@zeniv.linux.org.uk>, <yangerkun@huawei.com>, <yi.zhang@huawei.com>
Subject: Re: [PATCH 0/2] lockd: fix two bugs on nlmclnt_find_lockowner() failure path
Date: Wed, 16 Sep 2026 15:01:54 +0800
Message-ID: <20260916070154.302915-1-ranhongyun1@huawei.com>
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
X-ClientProxiedBy: kwepems500001.china.huawei.com (7.221.188.70) To
 dggpemr200001.china.huawei.com (7.185.36.96)

