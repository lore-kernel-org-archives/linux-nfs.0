Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.220
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792758232;
	b=daVvtYS+NCAv9HO/Mde2PTTgxEn0Z/6zvXawBFeRJMLA4xEb7AdczdyYbYy0NLTDgxeK
	 hTMizT6CF5FKGNO/JhkAvwDdLbbBJPAHHuutLBAR7jZ8UyAxjjCJ3xHxHNVb9BGGmQrlv
	 K9IrUNTYMLzWCMB3p3JmdWQ8poPPrkhtFSMN8yxPQn0X01x/+YCSpKX4q6q3W440GygwJ
	 YvCs6AnUC5dIg0hiJnn1b42+hr5DSSeHXVJG+9gB1lgBqhYe0nwOOPd/t89w0NJ0Olgs3
	 DyxO0f2DES/Y33brRTwA2smDRDee9DqrtAdLDIMa+ejZ91+7zDGO6aIibf6Psx3RIdg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792758232;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=wk3324vvbrlF1HvcgQMN7mpDc727JcjF7E1+c41AfH8=;
	b=h58M2+seX8WQ3nwq25FxL9YrKFgAj1te7aV0QojIqGy2CYZVIKnW70vjsWsCMZK2gdFQ
	 9i2G7xzNKTSS2DR2yEen9t13beBk3CjpaxbohnvFDSE5/KVjyf5M4PDU2DNQPSdhssqQk
	 NOGYq8dtQgov5AsIIKbinkTcGaODA4qR787O29RPwsxV+CjUPTzjo7N6G/T6vrH16/bmc
	 ok+zndNbE03Kf+cbk9DFDxo9vcI23WoQ+XTT1jqDesBLXK5HXuFWLNgsg1RiwZn94C9pf
	 ESyUEhRr68v7MYBDQHzMWlUSxpH/81Zm5bcZM5Mq6U7lE/CW96TLB+AQfPRHYQECDKg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=yzt8kfNk;
	arc=none smtp.remote-ip=113.46.200.220
Received: from canpmsgout05.his.huawei.com (canpmsgout05.his.huawei.com [113.46.200.220])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1C05D606A31F;
	Fri, 23 Oct 2026 12:23:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 1C05D606A31F
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=yzt8kfNk
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=wk3324vvbrlF1HvcgQMN7mpDc727JcjF7E1+c41AfH8=;
	b=yzt8kfNk0oTyQy+AXUGorgCXXI0VEg/6p0l1U0nV+ORVrZsROmcT5k0verxjfAWe37iunFazd
	f9lNpUnt5C1jgzZzzBJR87PDw+4mG34xKqt2pCvlYEDOQaUgBmZ7lP8tAJipkiJgnAQme6dUpHI
	zKN+Jf2wlfI0nv34nogSXqs=
Received: from mail.maildlp.com (unknown [172.19.162.144])
	by canpmsgout05.his.huawei.com (SkyGuard) with ESMTPS id 4jB2Hm4shcz12LFP;
	Fri, 23 Oct 2026 20:23:48 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 46D674056D;
	Fri, 23 Oct 2026 20:23:46 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Fri, 23 Oct
 2026 20:23:44 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<stable@vger.kernel.org>, <yuehaibing@huawei.com>,
	<zhangchangzhong@huawei.com>, <weiyongjun1@huawei.com>
Subject: [PATCH 0/3] rpcrdma: Fix device removal races and endpoint cleanup
Date: Fri, 23 Oct 2026 20:50:30 +0800
Message-ID: <20261023125033.528835-1-lixiasong1@huawei.com>
X-Mailer: git-send-email 2.34.1
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain
X-ClientProxiedBy: kwepems500001.china.huawei.com (7.221.188.70) To
 whupemk300014.china.huawei.com (7.152.185.8)

This series fixes races and endpoint cleanup issues in the RPC-over-RDMA
device removal paths.

Notification registration is not serialized with device removal. Removal
can free the per-device private data while registration is still using it,
or finish walking the notification array before a new registration is
published. In addition, the notification walk does not hold references to
the objects containing the notifications, allowing concurrent unregister
and teardown to free an object before its removal callback is invoked.

On the client side, the device removal callback only forces a transport
disconnect. A connect worker waiting for re_connect_status to change can
remain asleep, preventing endpoint cleanup. An established endpoint can
also retain its connection reference because CMA suppresses subsequent
DISCONNECTED callbacks after entering the device removal state.

Patch 1 serializes notification registration with the transition to device
removal and protects access to the per-device private data.

Patch 2 uses the same mutex to serialize notification reference acquisition
with unregister, and holds a reference across each removal callback.
Callbacks and reference release run outside the mutex to allow teardown
to unregister notifications.

Patch 3 records device removal in the endpoint connection status and wakes
a waiting connect worker. For an established connection, atomic state
transitions ensure that the first path to leave the established state
releases the connection reference exactly once. It also handles connection
establishment racing with removal and propagates final endpoint release
to CMA where needed.

The patches are ordered by dependency: patch 2 uses the serialization
introduced by patch 1, and patch 3 relies on the callback lifetime
protection added by patch 2.

Li Xiasong (3):
  rpcrdma: Serialize notification registration with device removal
  rpcrdma: Pin notifications during removal callbacks
  xprtrdma: Wake connect worker on device removal

 include/linux/sunrpc/rdma_rn.h           |  6 ++-
 net/sunrpc/xprtrdma/ib_client.c          | 56 +++++++++++++++++----
 net/sunrpc/xprtrdma/svc_rdma_transport.c | 19 +++++++-
 net/sunrpc/xprtrdma/verbs.c              | 62 +++++++++++++++++++-----
 4 files changed, 119 insertions(+), 24 deletions(-)

-- 
2.34.1

