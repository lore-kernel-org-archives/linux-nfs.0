Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=159.226.251.21
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793759294;
	b=Oy2o8pCsgiN4B9iom4Qrm2roHb3YIoVgVjqulbY37pwEbBRAV0fOz7B2M535OT+2kKLl
	 v7MmR18YaM30CPZxj14yuGAqsIWBVh8bjDAb1dsmWhrjBQm5CYSSvR6S7PT0hXtvKiQ28
	 EtwGgdtucGKZU4aKZhXgu0AJX+T1tlwaAloOxgNvftogUsiIcgIEquTYcaoqqXO612hz3
	 LimzrAonELiq7p3mg2x7mkZjQM1xq1xaIxLDhRNucqNwlJolSowlhUOMpSgpS8w/HIZEQ
	 6A8ErH2pRonj+2i5uERn0TpepAGvHD85sUhLQO0sMyH9l8tk4bStth5nr60VWn1aq4w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793759294;
	h=DMARC-Filter:Received:From:To:Cc:Subject:Date:Message-Id:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding:X-CM-TRANSID:
	 X-Coremail-Antispam:X-Originating-IP:X-CM-SenderInfo;
	bh=RW27rarhmOaQKiYQHMV7THA839lB5vfI425J1Najwbo=;
	b=TVMuumDrbw4TM31bm84reVn3Rx2Dm0Vc8eS3xKZKgxVSroWwaudSwm2ViuVrgsL3AF6X
	 JfjGj862/XS0y3WRIxCwREHkIFYwU0ZCsj3M3t1Rkz6iODrFD+WUrNHZ0Mj1G/IKJ/j2B
	 p91nxB1El1W7IITX8evTtAUCa5+XUrOPVQvTVCbW7bq6hr+jq8vX6XM0I+9atQQT+hokt
	 lkwtBQlu/9kozregrpTrqQm+WMIxBFTSeyACFC8w80VvTaWc+kPBVmzS1h8Uo39V6h/lN
	 9QNSCTH4m6GyFyDocOX05aYTw5Mmk0xSIzdfw1WmRbLBheeC6qhYGb70Bxn601VYJHA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=none header.from=iscas.ac.cn;
	spf=pass smtp.mailfrom=iscas.ac.cn;
	arc=none smtp.remote-ip=159.226.251.21
Received: from cstnet.cn (smtp21.cstnet.cn [159.226.251.21])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 98753606A32F;
	Wed,  4 Nov 2026 02:28:13 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 98753606A32F
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=iscas.ac.cn
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=iscas.ac.cn
Received: from dfae2b116770.home.arpa (unknown [36.110.52.2])
	by APP-01 (Coremail) with SMTP id qwCowABHb_k0mOpqyps+AA--.29079S2;
	Wed, 04 Nov 2026 10:28:04 +0800 (CST)
From: Wentao Liang <vulab@iscas.ac.cn>
To: Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@kernel.org>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org
Subject: [PATCH] svcrdma: drop the extra reference on the backchannel transport
Date: Wed,  4 Nov 2026 02:28:13 +0000
Message-Id: <20261104022813.1484267-1-vulab@iscas.ac.cn>
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
X-CM-TRANSID:qwCowABHb_k0mOpqyps+AA--.29079S2
X-Coremail-Antispam: 1UD129KBjvJXoW7tw1Dury5GF15XFWrurWDXFb_yoW8WrW8p3
	yakrW8X3srKrWfAFsrtw109F45Aw4xta1rGr4qka1kAr15XFykAFyIva1j9rWDArs3Wr1k
	tr1kta15ZFZ8A37anT9S1TB71UUUUU7qnTZGkaVYY2UrUUUUjbIjqfuFe4nvWSU5nxnvy2
	9KBjDU0xBIdaVrnRJUUUB0b7Iv0xC_Kw4lb4IE77IF4wAFc2x0x2IEx4CE42xK8VAvwI8I
	cIk0rVWrJVCq3wAFIxvE14AKwVWUJVWUGwA2ocxC64kIII0Yj41l84x0c7CEw4AK67xGY2
	AK021l84ACjcxK6xIIjxv20xvE14v26w1j6s0DM28EF7xvwVC0I7IYx2IY6xkF7I0E14v2
	6r4UJVWxJr1l84ACjcxK6I8E87Iv67AKxVWxJr0_GcWl84ACjcxK6I8E87Iv6xkF7I0E14
	v26rxl6s0DM2AIxVAIcxkEcVAq07x20xvEncxIr21l5I8CrVACY4xI64kE6c02F40Ex7xf
	McIj6xIIjxv20xvE14v26Fy26r45twAv7VC2z280aVAFwI0_Gr1j6F4UJwAm72CE4IkC6x
	0Yz7v_Jr0_Gr1lF7xvr2IYc2Ij64vIr41lFIxGxcIEc7CjxVA2Y2ka0xkIwI1lc7CjxVAa
	w2AFwI0_Jw0_GFyl42xK82IYc2Ij64vIr41l42xK82IY6x8ErcxFaVAv8VW8GFyrJr1UJw
	CFx2IqxVCFs4IE7xkEbVWUJVW8JwC20s026c02F40E14v26r1j6r18MI8I3I0E7480Y4vE
	14v26r106r1rMI8E67AF67kF1VAFwI0_Jw0_GFylIxkGc2Ij64vIr41lIxAIcVC0I7IYx2
	IY67AKxVW7JVWDJwCI42IY6xIIjxv20xvEc7CjxVAFwI0_Gr1j6F4UJwCI42IY6xAIw20E
	Y4v20xvaj40_Jr0_JF4lIxAIcVC2z280aVAFwI0_Cr0_Gr1UMIIF0xvEx4A2jsIEc7CjxV
	AFwI0_Gr1j6F4UJbIYCTnIWIevJa73UjIFyTuYvjxUyXo2DUUUU
X-CM-SenderInfo: pyxotu46lvutnvoduhdfq/1tbiBgMBA2rqY4LLPgAAsT

xprt_setup_rdma_bc() takes two references on the new rpc_xprt: one for
the xpt_bc_xprt link, which svc_xprt_free() drops, and a second one
whose final put used to live in __svc_rdma_free().  That put was
removed when svc_xprt_free() took over releasing the backchannel
transport, but svc_xprt_free() only drops the reference belonging to
the xpt_bc_xprt link.  The second reference is therefore never
released: the rpc_xprt outlives the callback client and the
connection, and the net namespace reference taken by xprt_alloc() is
leaked with it.

Keep only the reference that svc_xprt_free() releases, the same way
the TCP backchannel transport does, and drop the comment pointing at
the function that no longer performs the put.

Fixes: 729580ddc53e ("svcrdma: xpt_bc_xprt is already clear in __svc_rdma_free()")
Cc: stable@vger.kernel.org
Assisted-by: DeepSeek-V4.1-Flash and OpenAI Codex
Signed-off-by: Wentao Liang <vulab@iscas.ac.cn>
---
 net/sunrpc/xprtrdma/svc_rdma_backchannel.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
index e5a78b761012..6a504806165c 100644
--- a/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
+++ b/net/sunrpc/xprtrdma/svc_rdma_backchannel.c
@@ -269,9 +269,6 @@ xprt_setup_rdma_bc(struct xprt_create *args)
 	xprt_get(xprt);
 	args->bc_xprt->xpt_bc_xprt = xprt;
 	xprt->bc_xprt = args->bc_xprt;
-
-	/* Final put for backchannel xprt is in __svc_rdma_free */
-	xprt_get(xprt);
 	return xprt;
 }
 
-- 
2.34.1

