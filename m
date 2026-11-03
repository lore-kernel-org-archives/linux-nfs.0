Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.225
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793674904;
	b=ftHA39oqAd8wh25Sm7geKOieoUH1wtkIVX9l/zdloQPSDDaVSz9KdhdkTWyOqfDTGjX+
	 armFQvx3HmwixY3CHNkbhztvawOmQd2iCz+KvnNr/AkM109a04qhU1BPHangAJPaHdNZW
	 YgdGxbyfqRpjYbScmEekHVQADwDm1wbfsRbh8KYdDPBbV3a5MLFfAlb/KjNisEv6Qd93v
	 STXaoJZkCL99rfrZNKYzWavkbZK0rIDUuEfu0isAWjrL38CAEjJxP0FIO4A7lxtI/A4TT
	 p+FY3ZlFZgvJ8z9J9oXE6TEo8NtnO1083TlqKTL7dWgIPHSdR1tE4yrnA0f0jcdl+lA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793674904;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=eB1sE7Pq3QKF6dYlhdLcuSL9a7OBlMmlpjtwbXguLEo=;
	b=AW00RFtPDUus4/mmL4l/O6ghRltF1RacyB2ja/4F2o69DRpdmLgXHxPYqKaf1pfMvCvS
	 S61uI4zvn2Fjln09BQoA0JXLBLNnt2QZLid387eSbm13KF19JbXhHbgni9PStFqiL6S9L
	 QIuC0t/TsnPbtDZUUN58AoxDJ5f8JyidmRHitz5oQ1BGbCjw5SsiBVgTG13dnjzW00O9U
	 bhiDyUV00t8DVJ+tiGoAl5608w1FWTRNKiDwylYctkcSXL1zlDxRb/a84M8B+z/2p8W4F
	 gOp/LCVe03Peh2WV/UNLcIwtwbL2IaS9AP6bQ1gLoNjbfX7n75X/ym/9xxyfZZdiVig==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b="UnDX7r/S";
	arc=none smtp.remote-ip=113.46.200.225
Received: from canpmsgout10.his.huawei.com (canpmsgout10.his.huawei.com [113.46.200.225])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CB62606A324;
	Tue,  3 Nov 2026 03:01:41 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 3CB62606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=UnDX7r/S
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=eB1sE7Pq3QKF6dYlhdLcuSL9a7OBlMmlpjtwbXguLEo=;
	b=UnDX7r/SIntrBRDiJaEyYGGO0/bDXqZr4Z2DuPiQKaQoSHM8QdXowW6gKW3U6sNK0Tr83oi5q
	yPrdEaYKNznTbJ1DxdDbKIsSA3aHAyaIDJr6CmYPwPMGJjLtyAWkOT5h0uwWcJ7LZzSeYDXXz8a
	4OY12x2bX3C93pP6osBbLhM=
Received: from mail.maildlp.com (unknown [172.19.163.200])
	by canpmsgout10.his.huawei.com (SkyGuard) with ESMTPS id 4jJYHx2G1sz1K975;
	Tue,  3 Nov 2026 11:01:33 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 6BC1D4055B;
	Tue,  3 Nov 2026 11:01:37 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Tue, 3 Nov
 2026 11:01:36 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<stable@vger.kernel.org>, <yuehaibing@huawei.com>,
	<zhangchangzhong@huawei.com>, <weiyongjun1@huawei.com>
Subject: [PATCH v2 0/3] rpcrdma: Fix device removal races and endpoint cleanup
Date: Tue, 3 Nov 2026 11:27:55 +0800
Message-ID: <20261103032758.1302493-1-lixiasong1@huawei.com>
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
X-ClientProxiedBy: kwepems200001.china.huawei.com (7.221.188.67) To
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
remain asleep, preventing endpoint cleanup. Removal that races with
connection establishment can also be overwritten by a late ESTABLISHED
event, and releasing the endpoint from a removal callback or address
change can free its CM ID context before CMA has stopped dispatching
events to it.

Patch 1 serializes notification registration with the transition to device
removal and protects access to the per-device private data.

Patch 2 uses the same mutex to serialize notification reference acquisition
with unregister, and holds references across each removal callback. Each
notification records the references it acquires, so a partially completed
acquisition can be unwound without touching a freed owner or blocking on
XPRT_LOCKED under the device mutex. The client endpoint pin also takes a
reference on the RPC transport. Callbacks and reference release run outside
the mutex to allow teardown to unregister notifications.

Patch 3 records device removal in the endpoint connection status and wakes
a waiting connect worker. Atomic state transitions ensure the first path to
leave the established state forces a disconnect exactly once. It drops the
connection-management callback get/put pairs and destroys the CM ID in the
endpoint destructor, before freeing its context, so that active and future
callbacks are fenced. It also handles connection establishment racing with
removal.

The patches are ordered by dependency: patch 2 uses the serialization
introduced by patch 1, and patch 3 relies on the callback lifetime
protection added by patch 2.

Changes since v1:
- Pin the client RPC transport alongside the endpoint owner, and track
  acquired references separately so a partial acquisition can be unwound
  without accessing a freed owner or waiting for XPRT_LOCKED under the
  device mutex.
- Add kernel-doc for the new get/put callbacks and Context: sections to
  the notification registration interfaces.
- Rework client endpoint lifetime: remove the connection-management
  callback get/put pairs and destroy the CM ID in the endpoint destructor
  before freeing its context, closing the use-after-free window on
  teardown.
- Give UNREACHABLE and REJECTED the same atomic status handling as
  ADDR_CHANGE so a transition on an established connection forces a
  disconnect exactly once.
- Link to v1: https://lore.kernel.org/all/20261023125033.528835-1-lixiasong1@huawei.com/

Li Xiasong (3):
  rpcrdma: Serialize notification registration with device removal
  rpcrdma: Pin notifications during removal callbacks
  xprtrdma: Wake connect worker on device removal

 include/linux/sunrpc/rdma_rn.h           |  29 +++++-
 net/sunrpc/xprtrdma/ib_client.c          |  84 +++++++++++++++--
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  21 ++++-
 net/sunrpc/xprtrdma/verbs.c              | 114 ++++++++++++++++-------
 4 files changed, 203 insertions(+), 45 deletions(-)

-- 
2.34.1

