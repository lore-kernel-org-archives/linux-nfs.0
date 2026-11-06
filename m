Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.63.21.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793945280;
	b=D449t6j+7j9DuCMHpkjGeyi3bbVjeanDDdbJffcXG44CT/2ThekAr606GeokxS7FMh/b
	 XqcZlc1BBTNZXEHbLJrG0f8DEnp27EE3pSUlLIymgLEdNy27Vh3/Ipdd5ClUPkc8EQ3nS
	 wdxfVNQVa/2zWWyvjywiwZaE0JOdt4iBd73nRgQhtAFoQXfUI07DYD9FI8U5k46vd71ZA
	 upYuYS0e8XDht4vrEwFHwQwl1nGyWYHdDb9fupOYqhYroYe499J8F6T+Nc9P3+Nx/9rSl
	 6peU6XgtilzuqiqRqrAr93UGg0pQTfkmu52zs24i1E/CeSk/mL39lyNcyxb7VQTIGFw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793945280;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:X-ME-Sender:
	 X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding:X-Greylist:X-Virus-Scanned:
	 X-Virus-Status;
	bh=SepUVTq2N4VVCfgWeYpf575GziiRtal/AKtf++9qbSw=;
	b=ZSe6GWKS0XipPmo7szl4RzcIOKHsuIKi/iZ3ChKn5a+jP1So6klXg/DkuulAQRLOawWK
	 XVzqp18Xa+tIfiaYCyZogiC6gv3wf/ZdBp1AenD/BVohOgCG1M4dmQBmV8mL9CaVlukDB
	 R7vVbci/8tUbS4oiP0xINpOHC880NicF3XJYjt0oWt+wx1mCsKfAbaGUlxkmVms0mtQKn
	 SXquPprXFXxENCytceP2kKHQAGyVefNeO7NBMo1+ZPp+RHFVeQ4bOvWhoFOejAuO0zc63
	 XF0C8bCHUzD57f+gGqWyPRpjVHBiUVCm2wwP1FOWM1MsTDYyes4PXigm8YViRARf8Hg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sericyb.com.au;
	spf=pass smtp.mailfrom=shining.glasswings.com.au;
	dkim=pass header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=B6OhUVBB;
	arc=none smtp.remote-ip=178.63.21.144
Received: from shining.glasswings.com.au (shining.glasswings.com.au [178.63.21.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 60295606A32D;
	Fri,  6 Nov 2026 06:07:59 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 60295606A32D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sericyb.com.au
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=shining.glasswings.com.au
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=B6OhUVBB
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=sericyb.com.au;
	s=shining; t=1793945277;
	bh=h/gem5cWBy2JkhJFBmHdSYLh5/sSnfA/F7jEYlU9fBg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=B6OhUVBBMuMYerNKo0y8fa1/4w15Cn5/HsbwLAlO5PirhRGdAiycwde2XjQSVDsPF
	 /4upDWNX1+wq8qWAMf+3hdXowVKh4JYAICQv4MaWLJXCaqEsMxs0f4tDUNbDX6JUXb
	 2EhdXimTZ7BQDk53x80K0jjVFQcJRVQ8AJuKUchizqKi40cpEEF74d3aTdxikzks1A
	 toLVzkY7WnmbXtuk8Yj0L0+LRBmXkaWXgw7JUUr/JIpWhOZvSSOQ9pcbVMtLZAwitm
	 hmkIKqQ6MFznx947btnVver4ETcYwRMOWhnIm2egIfSWIKRKZ4rqUYbmnKheX/g9D8
	 bGOWa9GzBG8og==
Received: from fauth-a2-smtp.messagingengine.com (fauth-a2-smtp.messagingengine.com [103.168.172.201])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by shining.glasswings.com.au (Postfix) with ESMTPSA id 742E51092412D;
	Fri,  6 Nov 2026 06:07:56 +0000 (UTC)
Received: from phl-compute-12.internal (phl-compute-12.internal [10.202.2.52])
	by mailfauth.phl.internal (Postfix) with ESMTP id 5E38AF40066;
	Fri,  6 Nov 2026 01:07:55 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-12.internal (MEProxy); Fri, 06 Nov 2026 01:07:55 -0500
X-ME-Sender: <xms:u27tap9peZAK4VUS7esiftm9obq_gvtvCS9qwel1L5eEjYCjXeVxAQ>
    <xme:u27taoHnX2ARUKlQUmbWHl7gNEgmU1A_FBl0MzpKGiXXLa6a92RaccRtID0yoJBhs
    -0i6cjs69mpD-FD9SP9gSXmeXSPQKRLW5HZ4hOfiE8wj11BDMgvyIc>
X-ME-Received: <xmr:u27tatIXhijhu0GqllOvp7tnvbIS9Ey37LktP1d1TfFgxFkQGLY6gO8nvym0lhWm-W3PERknG1fQG_vU32wc8SC5-mjySqv_-P4kqgyXMdM>
X-ME-Proxy-Cause: dmFkZTFgaTEQimESg58k8cu3KtqpUgcGphn1FhhA26HFlWWqA1QMqAZ2a863IucRjBhUU3
    dG/FWv4wgeITjyGbItMbuxun3pWBFwlkmhfR/c9nrJoUsy/UmIsquVO/HSfo1SyHHSzdAu
    69HI6unygSag1qCvPyV23CZXkv46z1HPFgboMb39m+tR2wQq1h8CKPqDJP269vGGuO3+ss
    ozmryUgVMBHt2vLg2SY1ZRm522i3o4BUFaMQJwrnSiktxOeVVZ0ykm0+VbdBFhMaAi3OWt
    XD5k6FYLz4ptQPHJ7pU/7Hxx3tlHKcHh1GW4kY29J0h11dJJigUOU94ypl4LmALfbu7EPw
    ya8b9RSI6pzHCioZ7xE89qCpc5kgXl2My1ryCgTUcTHH/vKU7bXirPLbpyL6VG9ZDoZzB1
    DqAUetOZvN85OLpm1mabj4CVgvj5duZwTqhzGXLm0aWTIgZrHW++7fPx3U8eLkVUTFIlDS
    c1N49KYl6UzENe7hsM6SDQ12ykhuG2uBgoxhlaxKUv1KKGd+twkQUUqd9FjfUz6Gtk7Xwa
    smOOZcinMTgiogN/AJ6g59hQfMf7LWG8PV970CniRpHzeO13rqQHqsQ01ZNo6Npzk22Y4c
    tTk98WjlUsVr3GPmRLFdAEFp/VlyDk8O/VEeH8lMG/r2gRRGzlCOMVcBWXKw
X-ME-Proxy: <xmx:u27taon0fee1dwKeoFFDpfd35_JTwlHqqGssZjUbAIhu124kvt9aiw>
    <xmx:u27tamw5y4o8TLMJ67KfKSVZSa5UCyw8E_GULMTC14WiGGCfqz_iKw>
    <xmx:u27taivuWHl8aDi-alc2IqGnm64rnouUgzxLHIOn3d78spArt-bcQA>
    <xmx:u27taoF6X8swv4AFaMa1lf-_pU-3o29PikoePfyYiAD4uw9C-vAYGA>
    <xmx:u27tao7eNIOD_4bvKH492bHwT6Y_H5oFO1Fa8dEZcVnXknnYBssvnkNx>
Feedback-ID: i558e4b61:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 6 Nov 2026 01:07:51 -0500 (EST)
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
	"Rafael J . Wysocki" <rafael@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-pm@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 2/3] NFSv4: run lease renewal on a freezable workqueue
Date: Fri,  6 Nov 2026 17:07:30 +1100
Message-ID: <20261106060735.637295-3-andrew@sericyb.com.au>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261106060735.637295-1-andrew@sericyb.com.au>
References: <20261106060735.637295-1-andrew@sericyb.com.au>
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
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (shining.glasswings.com.au [178.63.21.144]); Fri, 06 Nov 2026 06:07:57 +0000 (UTC)
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

