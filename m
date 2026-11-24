Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.225
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795485201;
	b=XLa3s4WmVWbWdzjfyPSxpU5vMUxspwcuxAd9CjNhS3JsllaFB7ZJQ/gJTEOxS5gsk3mm
	 YWpmGOJTBTtgbu8OrtEjDuqparCm1LYpBygg+mNKATF5gpfgifhS7Kqg7oxHsmJDjsc5T
	 6Bt5Kvihze3Y0t703wz+JkuD2pTYZNUuln9FXcbO76ZDoHfx0MxnC/rTutdkpuqcypA/f
	 ZyPlpGcwID47rih2ZYSkcrG4lxyNKDrSH7txGawBZwS/Pkw94Eqysf2z8A1zWR2h5Y2Vj
	 wrXjPRG3dn6qbbwnJKJubL6KP7qwGYWAwwWamHIWrqN9hRjM9m/WRSQpny/wbV7yCkQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795485201;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:From:To:CC:
	 Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding:Content-Type:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=tkucSQ4byPvhiJwUrA8Yq4ByYevkQkVNvkxbqT3c11M=;
	b=OxH0QIFKtIn+mJlQIEmJLCZaNv2KrrsMiPLb8qo5FJAR3I7W3X/wRZf8MADUcEnGEXKK
	 H3gJL2nmihXD8lsLJkxXDvsY1R8H4Qz5Mj3cjQuKN+RwnVfBf+JV2qilxRb+LKGKrCYFO
	 fjTbPs+kA5dOHDOGIgVyF81mEWyRZrOEBfPcwQOM57Vanr+h1yn+0Sn7ge0csPcb6kK0O
	 VH6voazAZ2Zc/lfq8DsisxgVj5v7/C5BTcVUVddvs84H4WrdvqvJe3ZI66IG0CNPOS13d
	 Mf/GjsePiJ1gPoqp9Gc1G9TNdOqq+YY+W2LKDlhApNHz7pPbKKGeaOf3tLrUNbXNy4A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=oPMgnupr;
	arc=none smtp.remote-ip=113.46.200.225
Received: from canpmsgout10.his.huawei.com (canpmsgout10.his.huawei.com [113.46.200.225])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DDC38606A321;
	Tue, 24 Nov 2026 01:53:18 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DDC38606A321
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=oPMgnupr
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=tkucSQ4byPvhiJwUrA8Yq4ByYevkQkVNvkxbqT3c11M=;
	b=oPMgnuprLaUiyQR1swM21wyMOTyPwddx9g6ITfEvHdhCjuMRUjowWpQUMK6TuZlKXq5L8lYQd
	SxFY96YHAcpZ0r8Vi0InTgaGvyMyk4Vy6B7LfpMUGYtbRcCWbdHnjfQaNb/neDgcTZCVNh/esAj
	HjACZHx+fB0mRBVEjrl4wIs=
Received: from mail.maildlp.com (unknown [172.19.162.92])
	by canpmsgout10.his.huawei.com (SkyGuard) with ESMTPS id 4jYQn61jslz1K9BF;
	Tue, 24 Nov 2026 09:52:58 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 6585640586;
	Tue, 24 Nov 2026 09:53:15 +0800 (CST)
Received: from huawei.com (10.50.85.128) by whupemk300014.china.huawei.com
 (7.152.185.8) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Tue, 24 Nov
 2026 09:53:14 +0800
From: Li Xiasong <lixiasong1@huawei.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
CC: <linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>,
	<stable@vger.kernel.org>, <yuehaibing@huawei.com>,
	<zhangchangzhong@huawei.com>, <weiyongjun1@huawei.com>
Subject: [PATCH v3 0/3] rpcrdma: Fix device removal races and endpoint cleanup
Date: Tue, 24 Nov 2026 10:18:39 +0800
Message-ID: <20261124021842.130141-1-lixiasong1@huawei.com>
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
removal and protects access to the per-device private data. The critical
section runs in a NOIO allocation scope so reclaim cannot wait for RPC I/O
on a transport whose reconnect needs the same mutex.

Patch 2 serializes removal callbacks with unregister. Short removal
callbacks run under the device mutex, so an owner cannot be unregistered
and freed while its callback is running. Callbacks that must release a
reference do so outside the mutex through an independently owned release
callback, keeping a final transport put from waiting on a connect worker
that needs the mutex.

Patch 3 records device removal in the endpoint connection status and wakes
a waiting connect worker. Atomic state transitions give -ENODEV precedence
and force an established connection to disconnect without a late
ESTABLISHED event masking the error. It drops the connection-management
callback get/put pairs and destroys the CM ID in the endpoint destructor,
before freeing its context, so that active and future callbacks are fenced.
Device removal during setup is translated to -ENOTCONN so pending RPCs
retry.

The patches are ordered by dependency: patch 2 uses the serialization
introduced by patch 1, and patch 3 relies on the callback lifetime
protection added by patch 2.

Changes since v2:
- Run the registration critical section under memalloc_noio_save()/
  memalloc_noio_restore() so the module-wide mutex is never held across
  reclaim that may wait for RPC I/O.
- Drop the rn_get/rn_put callbacks and rpcrdma_notification_ref. Removal
  callbacks now run under the device mutex (they are short and do not
  sleep), so a pinned owner is unnecessary. Transport references are moved
  back into verbs.c and svc_rdma_transport.c and released outside the
  mutex via a new rpcrdma_notification_release output parameter.
- Make rpcrdma_ep_disconnect() use a try_cmpxchg loop so a connection that
  is already established transitions to the error state and is forced to
  disconnect, instead of leaving re_connect_status at 1.
- Have RDMA_CM_EVENT_ESTABLISHED return early when the status is already
  non-zero, avoiding a forced disconnect on an unpinned transport.
- Translate the -ENODEV connection status to -ENOTCONN so pending RPCs
  retry on a hard mount when the device disappears during setup.
- Link to v2: https://lore.kernel.org/all/20261103032758.1302493-1-lixiasong1@huawei.com/

Li Xiasong (3):
  rpcrdma: Serialize notification registration with device removal
  rpcrdma: Serialize removal callbacks with unregister
  xprtrdma: Wake connect worker on device removal

 include/linux/sunrpc/rdma_rn.h           |  27 ++++-
 net/sunrpc/xprtrdma/ib_client.c          |  86 +++++++++++---
 net/sunrpc/xprtrdma/svc_rdma_transport.c |  24 +++-
 net/sunrpc/xprtrdma/transport.c          |   2 +-
 net/sunrpc/xprtrdma/verbs.c              | 138 +++++++++++++++--------
 5 files changed, 208 insertions(+), 69 deletions(-)

-- 
2.34.1

