Received: from canpmsgout05.his.huawei.com (canpmsgout05.his.huawei.com [113.46.200.220])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 047514D6C4F;
	Fri,  9 Oct 2026 12:36:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.220
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791549381; cv=none; b=ljDJ5AIqxkQVgFf1J8gDMRNbVKGXUiyZrjnDgilDlKxcWZPEBV7fCJ9B+0J1n1LoLWR/jtFp95dQJfb1aapWR9D5YMZjse9/0v+dLCLzNzfZKXkZ697nE9kFNxhEeyq0hFFSkVdSABkh3Y0kLaES3925wqPLBE1S+NtWr6VE3vk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791549381; c=relaxed/simple;
	bh=vPuve5cUAgJg25Ymjks0ybEo8axdVfR+niqyzZu0duk=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=PfTaFdTXX5R+NTGH4PdbhwRC15v8PMgnFgcpLjPZrCi7ITU2S6tobfr96zlHmEICKNQ9UIWL45e9uVtR1gx8FZ2txPWqiEyld6HlgCDr5zjqj98GshdhqVIcAXqRdjjaVCuoxXrTb6h2UfKRATr6n4kgNBdsmrWevfItXyPPw1k=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=AKEaPhxS; arc=none smtp.client-ip=113.46.200.220
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="AKEaPhxS"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=vPuve5cUAgJg25Ymjks0ybEo8axdVfR+niqyzZu0duk=;
	b=AKEaPhxSHyx84DiQXDaO37VGX+2KL2PBaqi/7K+hyNiY+AE2Tsxq/XhI6yOeCaZdlskmU65zD
	Q+X2IejEWe2j6Iw00YwgtwbYTExIw8VDRhmP4xmHER9F4ocIxKmEYzG7C9Py3bw9x0rPifwuqZZ
	pQ6KbTl/YQgAUav+5YrmdPw=
Received: from mail.maildlp.com (unknown [172.19.163.0])
	by canpmsgout05.his.huawei.com (SkyGuard) with ESMTPS id 4j1Qyb3yfjz12LD9;
	Fri,  9 Oct 2026 20:24:07 +0800 (CST)
Received: from dggpemr200001.china.huawei.com (unknown [7.185.36.96])
	by mail.maildlp.com (Postfix) with ESMTPS id 5EFBF40537;
	Fri,  9 Oct 2026 20:36:04 +0800 (CST)
Received: from huawei.com (10.50.85.155) by dggpemr200001.china.huawei.com
 (7.185.36.96) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.46; Fri, 9 Oct
 2026 20:36:03 +0800
From: Ran Hongyun <ranhongyun1@huawei.com>
To: <bsdhenrymartin@gmail.com>
CC: <anna@kernel.org>, <linux-kernel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>, <stable@vger.kernel.org>, <trondmy@kernel.org>,
	<ranhongyun1@huawei.com>, <chengzhihao1@huawei.com>, <yangerkun@huawei.com>,
	<yi.zhang@huawei.com>
Subject: Re: [PATCH] NFS: map TCP_TLS to TCP for mountd transport
Date: Fri, 9 Oct 2026 20:29:26 +0800
Message-ID: <20261009122926.3924424-1-ranhongyun1@huawei.com>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <20260309132253.1393804-1-bsdhenrymartin@gmail.com>
References: <20260309132253.1393804-1-bsdhenrymartin@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: kwepems100001.china.huawei.com (7.221.188.238) To
 dggpemr200001.china.huawei.com (7.185.36.96)

Friendly ping.

I hit the same issue and was wondering whether this patch is the proper fix.

Thanks
Ran Hongyun
