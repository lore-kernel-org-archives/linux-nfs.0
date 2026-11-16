Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.63.21.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794834901;
	b=YNdiZQyagLrwI4Q9PCav1BG/4t6WmHHqdXD+6MqXr/Y1jHQQfCjZWmzWEWLAvtpMoJbM
	 ZBLPIGUFeGKM1LjZfEqv11wn2YpNVEiq7uIgCjnr62qjVZifWGIZhPkEs4GUKl1ricipF
	 cbJ71/lpLeM1ndZ1a2pKLr4Z5kN/X5AGL4ujvuylcZ5JuAVHEW8SrfdstmMBDMgX7Ezgw
	 iGhmkjvAG5I++IK2eJ7lj9xR1a0d9DoPuM4tLFv5NS964nQZfq3XpOGXhqZX6011rlMsT
	 ES1fZRf9sP6hTCISNKR27vEOt/boWGadhfxQiLtRrQs8YMCjRA7uKSpeZ8GDtoJz51A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794834901;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:X-ME-Sender:
	 X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding:X-Greylist:X-Virus-Scanned:
	 X-Virus-Status;
	bh=SepUVTq2N4VVCfgWeYpf575GziiRtal/AKtf++9qbSw=;
	b=jkosLHoQnckyyeUBLiwvVNPwWooJIhWJ8eqnn1OYj2qkxE3bCcY3cokN3rYxtI7FSsRl
	 rYnmIE2/cPmEJBDnKp4d4IghhYvZbBqBMAtmJslvr/lcfAdOVyi2tY/jFwxFUfFgTLOA8
	 6FZTFma5bhsSlmUT8sCXcwz98y5bYOiYJWnKmJ3hCoRjCJ9pcF8omWc1U7bfUb4iQhy0U
	 UDnkF7ZQfFVpZyVNpc2yxMZ6TN6WlgJg1RY8iG/7L9je9/gNT0Dm2uXkCjifjgmYbRHuB
	 JGaCRjCsTGVFvsjrYIo9hcmm8HEV5FoyHLuzavfct+hcGYO2anOhqZ9K0RFiRud/0Qg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sericyb.com.au;
	spf=pass smtp.mailfrom=shining.glasswings.com.au;
	dkim=pass header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=G8+wkoyV;
	arc=none smtp.remote-ip=178.63.21.144
Received: from shining.glasswings.com.au (shining.glasswings.com.au [178.63.21.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 522CC606A88A;
	Mon, 16 Nov 2026 13:15:01 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 522CC606A88A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sericyb.com.au
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=shining.glasswings.com.au
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=G8+wkoyV
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=sericyb.com.au;
	s=shining; t=1794834899;
	bh=h/gem5cWBy2JkhJFBmHdSYLh5/sSnfA/F7jEYlU9fBg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=G8+wkoyVu2uaOzuX4HJnSBKYIB0qoiATgHDHj7R2tJhU2rIxcUKYu/DZWsFWSCn9H
	 pfwLLEsC0ddC4OFr12ipjyRLxjqRp+gXvNjD1OJQok5mak7F2M06jzToj3ZDNMSuNK
	 +H8H2bzjki3i41jc6PJKKqv9jpm2L2i0Z65HcCxChmUbCzDfALAlj3d5UUzGKX5Q4k
	 5qyt7norSQ5SUNafcCrJq3vN6OvpQRd+Ki5HodlBgZX5sztB5jeoenqEDDVAyBniVA
	 8WGo6Gl6u5Kl5bOJP3a3LtP/Wqe3j54ZIl18hyQ9h//r9RPi+bMDVqtgCe4wsLtR2Z
	 Z4QQA02je/g5Q==
Received: from fauth-a2-smtp.messagingengine.com (fauth-a2-smtp.messagingengine.com [103.168.172.201])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by shining.glasswings.com.au (Postfix) with ESMTPSA id 48A6E109F9858;
	Mon, 16 Nov 2026 13:14:58 +0000 (UTC)
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfauth.phl.internal (Postfix) with ESMTP id 1A27BF40068;
	Mon, 16 Nov 2026 08:14:57 -0500 (EST)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-01.internal (MEProxy); Mon, 16 Nov 2026 08:14:57 -0500
X-ME-Sender: <xms:0QH7asUPfRFe_7WGOvGIdgz5bovBIKz0n7K0pb2axiEcx-_TNbo5Kg>
    <xme:0QH7aoKEmIQl7MlpC2nTN26_ul22aEFBQTMNxhGfaxMzGRYGNlH9uKSvA6SzeUCwY
    lH77WlI82odWpBk9-Oor7BrCE3z_twYAarXVH8gdJAoEjIlkkEh3sWe>
X-ME-Received: <xmr:0QH7agBCgHqbgfl9i7rWVYua9PbmOcbORQzL8Ld6plViMFYpMttwBYDvCNXD3f_Z8QtLxS9VJYeBnLKXY_KQjxmEtMygkdYKnAbOF5fdtvY>
X-ME-Proxy-Cause: dmFkZTEcQ7HaM/hpcCTQfUEaNny0O5jxx5o3WnzHv/XFS2fakyMpYeXdYfBO0gMb9zSxV1
    BnNeb6ga78cEj4hK5iQUCn6HU3DQnpmYKflSGyK1d44OV3c+437Krlu8LXltk8GmYqOTjJ
    bBPpJFi+mkGtgld/foukHz6xTfGXZMHCWYSeLqDx3RqDST/UlEQmytGALYF16y16PfziAU
    8hLzTJykUZFSicLoVweRwEH54qDoKNbopNRjUMc0t/C0tLvzy2sUV4Y5ePlmpZhIfeidOY
    JCneSGogN/MfkeEbPz4lTwAzbpWkbDCFmKQH7zWem6VgJb8F/XXvzjC2o00+1maLu/UzI3
    0sxYuXIIbto7yr3FY7mrUUtDQdJlb7v/h2X5kScsYf9/CSxz1Mfbl8eaN9tL0RMHkjaSBO
    o2mCSsqyN5oTY0BYAsY1qc9Ownm/ctbjaLQupGky2S+jmWyNBFi/B/AE4ethRfQichbyRn
    MiKSYyHYRd1gVA0xfyBKmxv3rAF2QFdIRrI6Ab/y9ct2hrNPATJOXGQ9DOnz/Dw9bRxb5B
    MMtWkGRfygiM9Q04Nd37illqo9vrjyES4wxzdO3Bb6/WWH7iy/GKbyynVsE23/nh00xjUT
    z1VIJDrYMdrJ7W05fwwO4rhCrB1i0WzIrJ8LKSbeWooMXeE6LcT7Wj7hMIpg
X-ME-Proxy: <xmx:0QH7aoF5m-9wKYLX507Q8uiMIJRyC81sPd40TQV-uCZD4l-98pIHSg>
    <xmx:0QH7atIpmqnaNHQHNObQ0tUL8Pj5MhYRtJIQMpBqDj_0KGE-YXd5oA>
    <xmx:0QH7anq4VEEIJMfVsGOHHFAsaEnUh9c3NgUiVfQ6JY1N33kzw76eJA>
    <xmx:0QH7ashDREFf8E_3ujBtY0RtRFGdute3DrEDcj_VxYCV31sUavmDlA>
    <xmx:0QH7aubXvNxd0bBm97tTOmaSSeBNAzxUpfm5OJgwl4YNcVkDQ8Ql5wBl>
Feedback-ID: i558e4b61:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 16 Nov 2026 08:14:52 -0500 (EST)
From: Andrew Pam <andrew@sericyb.com.au>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Andrew Pam <andrew@sericyb.com.au>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"Rafael J. Wysocki" <rafael@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-pm@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 2/3] NFSv4: run lease renewal on a freezable workqueue
Date: Tue, 17 Nov 2026 00:14:26 +1100
Message-ID: <20261116131428.1024230-3-andrew@sericyb.com.au>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261116131428.1024230-1-andrew@sericyb.com.au>
References: <20261116131428.1024230-1-andrew@sericyb.com.au>
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
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (shining.glasswings.com.au [178.63.21.144]); Mon, 16 Nov 2026 13:14:59 +0000 (UTC)
X-Virus-Scanned: clamav-milter 1.4.6 at shining
X-Virus-Status: Clean

The renewal work is queued on system_percpu_wq, which is not frozen
during system sleep. During hibernation it can therefore fire after the
snapshot has been taken, while the image is written. It then queues
renewal and DELEGRETURN RPCs and can wake the state manager, all on
behalf of a kernel image whose state is about to be discarded.

With rpciod frozen across system sleep (previous patch) those RPCs are
not transmitted until after resume. Run the renewal itself on
system_freezable_wq too, so it does not run in that window at all; the
delayed work fires after thaw if its time has passed.

Tested together with the previous patch, as described there.

Drafted with an AI coding assistant (Claude).

Signed-off-by: Andrew Pam <andrew@sericyb.com.au>
---
 fs/nfs/nfs4renewd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4renewd.c b/fs/nfs/nfs4renewd.c
index 30065df1482e..a0326f830bca 100644
--- a/fs/nfs/nfs4renewd.c
+++ b/fs/nfs/nfs4renewd.c
@@ -122,7 +122,7 @@ nfs4_schedule_state_renewal(struct nfs_client *clp)
 		timeout = 5 * HZ;
 	dprintk("%s: requeueing work. Lease period = %ld\n",
 			__func__, (timeout + HZ - 1) / HZ);
-	mod_delayed_work(system_percpu_wq, &clp->cl_renewd, timeout);
+	mod_delayed_work(system_freezable_wq, &clp->cl_renewd, timeout);
 	set_bit(NFS_CS_RENEWD, &clp->cl_res_state);
 	spin_unlock(&clp->cl_lock);
 }
-- 
2.53.0

