Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=74.125.82.170
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794171911;
	b=NImlebT8KgZP0UBsZyxRSpeXkszk26bkeTiHVKe5G9Bqr7NoYpDemU6GVBpeqQnoznU/
	 qp80EeyAAZJ5Uo5mC6RqXUwkElta1t0Hebl765vQILVy/vpeeU95kzVSRTkXr+lwEENGv
	 I7jbHOsOcxvx/WK6ytnR3H8DGNbKjxPcbb0gh3cnd7OPkc1xKM0hIFpHw4BWDPeSPEcYr
	 2rwFwFRceDpTCVtWSqH+hZvDbLzIzBa85Cbr3trXPhbKJuoHpPQkZn8eOhL5PRzeWMZkt
	 kECwyV9+mMqMH1NKibqm+NN9PdHu+xq+drWssw4sBBOm+wr7asamJ4TvzmBmCGg1bbw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794171911;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:MIME-Version:
	 Content-Transfer-Encoding;
	bh=Q9i7tR5s9CUBGsXLKzIqatReW7kAHiPt/K2J7j8OS20=;
	b=v3ZWR79+H6sud4uC0W0RpItiaRgoSzMpRefKs5IoOlL0V9HHZ4PflKYHZM+jnVcaVqFg
	 7hZuGh2d62F5mjkYbT+Sc4gbdjSCT+0rEUXTxq/pNxtYq+xMP5PF9X34op9ud+q30vCiv
	 nbtdutGpniDoLUt0i5er547g78PRnjZjFbVYLQjjawGr5frxQZM+X9ViM7mXltWoqzeZo
	 qGQqFpi3zNTEnEC3jx7kE6Ko3b60NnJQzfdFaRrIh/NXul4M4r1jmgGLfmOhSWDrJFtfQ
	 FsmaKhIQgO3FRpTvFsPEY4DzyhkY9tIrWmPOmMZAtVWSNtyOXydMpMJ6F9x+WhlF2Pg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=D+9YVNPC;
	arc=none smtp.remote-ip=74.125.82.170
Received: from mail-dy1-f170.google.com (mail-dy1-f170.google.com [74.125.82.170])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5B031606A323
	for <linux-nfs@vger.kernel.org>; Sun,  8 Nov 2026 21:05:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5B031606A323
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=D+9YVNPC
Received: by mail-dy1-f170.google.com with SMTP id 5a478bee46e88-33fb4680717so675475eec.1
        for <linux-nfs@vger.kernel.org>; Sun, 08 Nov 2026 13:05:11 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794171910; x=1794776710; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=Q9i7tR5s9CUBGsXLKzIqatReW7kAHiPt/K2J7j8OS20=;
        b=D+9YVNPCPU7fVRI5wlhs7CRsnvOYIwUkXjPyMHMNPIcYTxLSECBA0pFVV9zJ7GZIcX
         DcIdnNRps4BV4VtATk7aQkZLcrRKdgpzSm988uxOO7+8BPqwdV0e2EZGH6jvlHhgW6Ut
         s9wqRQGHgwsaD4sV84oYlhAnSsMMbqbect2bECo/ZKH0LApMIIfTL5ER8/v2FaJ5j9po
         1/bA6PxjJ3b3c1OpWRsyV4/aXYFc7kJqGAfrcbmYViawlQzaZQUz5kSqoqQpHQfQsv+M
         +5DOGGzAHlqVkjuUR4VpJn3AdcIleD2E59h8JO1+dEuyRUeLG9zDF7Vj9it/jMD/Mvph
         fYtg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794171910; x=1794776710;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=Q9i7tR5s9CUBGsXLKzIqatReW7kAHiPt/K2J7j8OS20=;
        b=q/MzG66+ofI6IkM6/18fZnFaU4tjPsDhiwMgEOmbissbEbGfdtHp4jSHrCvLv929nr
         zbDELegld/NIaIHuMIREwqO8l3GxI6PpoLSrBf25H+zucmFXUAcT1S5qDWhmIfH9vteV
         3MuhdgdWy1wnoHJ26egA4xJNdTdxxxAy6yz+pDSC75z0JhqGDnWXK5aud9S/heu/2y5M
         NVFwY9PY3la/Elzb739w3w2kfkMaLy7SNzNgx14641+fHTKYuHvUNL/XCSPfzIIb0iAR
         5vgLWZgORtB7TsS/76Y212F4Uj41nL1hGva8dVP0zFYGzEQLKM+fhktivXY5Cn/wR7+8
         SwWw==
X-Forwarded-Encrypted: i=1; AL+hErETNy+P0ECqIQkupuN8mXIGPY0NbgFBFWX1CNffF3dTQFpK5bQesombW0UIrgFlTUUKStabU9SFp6M=@vger.kernel.org
X-Gm-Message-State: APuU4Z+5RXAcOAFWJsWWMd8aGpFfzEgfpljf0Q4moxJPoM6btXyjsvJm
	o1X+jQFCG9nIUrj1QKVqaIwhU98ZxOspynHcydFHTa5MWAIE1PWAPXvH
X-Gm-Gg: AYBFou0BDvXBnJIiAGhadHa8x9Srgsu0cl6CjQVZy2oegP+VRG0cU7Jpf/XH7ULY0Pi
	2x/lT3Nvc2pgbPQqTmVGn8qo8/Z7fHwXuJUJ9XE7U0ewN/CUyGn0+mU34Tgs6Uyhv/qLYG48YO9
	c60+0ICCcbFwQNlRm08HZT0csUHLeDvUSmTLX12pidS1rZ/Cq/la6XoQwB/HFM5nxUVA13w8L5S
	Ve16QiDUbXFH3uJWs247FIgtDRWXGTKfiTeg7X7be1BvSWP8iu0BK4+g+APRtnQ5J4+lhEVyn+y
	/rZ3pEWjruO0ZA0yNqPM9U8yG9VRnTxaM09UsTHubN1W2pYBYL3NKaJFsgd1eYfWTqRJW119Ut+
	SY3ype+yjNiCoMzG+H5u9i/qEZUwzxcvzs4BpHxZqxsVe+qKJLFAB5Pm4PaGjd05mYZfzOngCEz
	oz2ofKHEpim5JpzA6V1ZVdJITkOUtqMQxsvernEgDEhdIs0bI8BoodJZa8JX3INHTbSBigbnKBw
	82uI3AzohmD85hsJISiOsZwjZdRwu9f4W0dMihbf9tUDPPj9d4N5qVLQFEauiXk3r/offn/zccm
	/Si7mmY++u/TOeoK5XSBzv2pPKAls+sccOFlbg==
X-Received: by 2002:a05:693c:69da:b0:368:2548:c08b with SMTP id 5a478bee46e88-372569033d2mr4333877eec.21.1794171910458;
        Sun, 08 Nov 2026 13:05:10 -0800 (PST)
Received: from user.. ([2405:201:c052:b00b:a46f:2762:f97e:59a4])
        by smtp.gmail.com with ESMTPSA id 5a478bee46e88-372656187f8sm6963475eec.5.2026.11.08.13.05.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 08 Nov 2026 13:05:09 -0800 (PST)
From: pavankumaryalagada@gmail.com
To: trondmy@kernel.org,
	anna@kernel.org
Cc: skinsbursky@parallels.com,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>,
	syzbot+8cbdf9aa6c281a4e6bbe@syzkaller.appspotmail.com
Subject: [PATCH] NFS: Destroy callback transports on initialization failure
Date: Mon,  9 Nov 2026 02:34:52 +0530
Message-ID: <20261108210452.84550-1-pavankumaryalagada@gmail.com>
X-Mailer: git-send-email 2.43.0
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

From: Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>

During NFSv4 callback initialization, the IPv4 listener is created
successfully, but the IPv6 listener fails to start. The error path
returns without cleaning up the IPv4 listener. As a result, the
transport remains attached to serv->sv_permsocks, causing svc_destroy()
to trigger a warning.

Call svc_xprt_destroy_all() when IPv6 listener creation fails to
close any transports that were already created. This ensures all
transports are cleaned up before the service is destroyed.

Reported-by: syzbot+8cbdf9aa6c281a4e6bbe@syzkaller.appspotmail.com
Link: https://lore.kernel.org/all/6aee17c4.8be4ead1.3b45e1.0199.GAE@google.com/T/
Fixes: c946556b8749 ("NFS: move per-net callback thread initialization to nfs_callback_up_net()")
Signed-off-by: Yalagada Pavan Kumar <pavankumaryalagada@gmail.com>
---
Note: Tested by syzbot using the reproducer. The kernel built successfully,
and the original WARNING was no longer reproduced.
---
 fs/nfs/callback.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index bc282b744f34..29134e2c56cd 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -61,9 +61,11 @@ static int nfs4_callback_up_net(struct svc_serv *serv, struct net *net)
 		dprintk("NFS: Callback listener port = %u (af %u, net %x)\n",
 			nn->nfs_callback_tcpport6, PF_INET6, net->ns.inum);
 	} else if (ret != -EAFNOSUPPORT)
-		goto out_err;
+		goto out_destroy_xprts;
 	return 0;
 
+out_destroy_xprts:
+	svc_xprt_destroy_all(serv, net, false);
 out_err:
 	return (ret) ? ret : -ENOMEM;
 }
-- 
2.43.0

