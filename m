Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=178.63.21.144
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795056465;
	b=IJUxDcBiNEOOKx2wUr2RLLVpks9QJy+Tw/emTalD7wE5YSZYEFn1pcuMnur8mCJg83sB
	 9pheR/mqgZJ4R9OC4cAS7yB0OTnb4rFWbNeTC24EKdzPFYTdHA9Mmou1xRMW6DnmpB+RO
	 MzTrhiTXoEilQ+5MsRwUmKXdfvK0v2i0eu+M9+CtVDihyzZ3e1fO/8cn4VRajoYYK3QXU
	 trZ/GgUGjRWc7Q04RsYWLeqEG+dCDEUByK13x3gFR3QK2/AFLjPaDpJpj7aqQ2SGEAtHi
	 EcqKYQGu9ickDGa6Fdr6rdyxBaauYQh+GQO43rxpsv2TdAevpGHY2MV6qb8ZqXCN9/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795056465;
	h=DMARC-Filter:DKIM-Signature:Received:Received:Received:X-ME-Sender:
	 X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:From:
	 To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding:X-Greylist;
	bh=2jeGcCvff3FYr4yBhfW30IpbVw3qLIA2PMro3i18Lds=;
	b=TpcDKThCVjcKpFM0G22EZWJAXdyZ6SDoRwsA4F2r/J8ZRtgJR3VE7LGRNkVSDbMouDrG
	 qqHNzmmW6zL7e3x1/ycn0aIKjXb4N5KcJlO1U4x+7NzH0AdriRr+lWTKrAaqvcs0lOz1s
	 GK6HUV2YUOnKNrnOOhxLwhzyRJQpufgpusF9RaQ7Z2DWAooHYIlXUWKYXu5ebL0oD+kf0
	 a87p5WVsAG1bLI5qDdeABOqr1rK30YKOqG+vU5Bz/zMOZduM7qUQx8cpsq5uCcdWuA5cE
	 9fmINIAANhHQezasZCN5mom873xbmWbxVlUFIvOirP/XqAUpQHFe4FRB6V0DcC5l+0w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=sericyb.com.au;
	spf=pass smtp.mailfrom=shining.glasswings.com.au;
	dkim=pass header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=Iz5B3m0V;
	arc=none smtp.remote-ip=178.63.21.144
Received: from shining.glasswings.com.au (shining.glasswings.com.au [178.63.21.144])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DCBC060A2601;
	Thu, 19 Nov 2026 02:47:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DCBC060A2601
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=sericyb.com.au
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=shining.glasswings.com.au
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=sericyb.com.au header.i=@sericyb.com.au header.a=rsa-sha256 header.s=shining header.b=Iz5B3m0V
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=sericyb.com.au;
	s=shining; t=1795056463;
	bh=lSZjBX78g4yXpKTw0U8IOCgq1ya1p5DWqHMcrlU4fEo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=Iz5B3m0VTX63pfpoktRd2/R/W8FCuzEG9g3xGC4EAsNHR8wRlEnIJk6FwLmHpos2B
	 VKz0/FPvPKrKfBK6e6/VUfu/byN4Pyvq4+6E0Tl3GReIRyzeiEBSL5zBPOe2ggjmAn
	 KexC8Q76j35vmn7z9RxZCIo/jZjzqJ9PihObr974hDowTIRrsm+pyTOD0SIpy7cIrF
	 nfjdIyISwtTzYBPqJ4bybER7wzYAZlodE7LsGb5yKD/oZEi7IEPvNHsDOLizrP8S27
	 i7vog1AfIAviA3jaf+PiUqkcVypj/EhEZBmQKMFI92YBdmJOqO9/js7/HVWJDXbyl3
	 +Vcx3vYwDLzfA==
Received: from fauth-a2-smtp.messagingengine.com (fauth-a2-smtp.messagingengine.com [103.168.172.201])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by shining.glasswings.com.au (Postfix) with ESMTPSA id E7C3410A47D1B;
	Thu, 19 Nov 2026 02:47:41 +0000 (UTC)
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfauth.phl.internal (Postfix) with ESMTP id A045BF40066;
	Wed, 18 Nov 2026 21:47:40 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Wed, 18 Nov 2026 21:47:40 -0500
X-ME-Sender: <xms:TGP-aizmBIYbM0ReW53DyJEQY6HBd4kl8w0WBjn9Q12xSiMRIa6-Eg>
    <xme:TGP-amKTHOq3ZFcyMOewqY3NesgxIV4gTJHfIIR328-smYOG4aH-80kFly0eUNmKQ
    fEmLnf2tHbQQDY3DDw-eM3XtkXYswTgC8-BYz1Yt-KT13U1PhpUWpg9>
X-ME-Received: <xmr:TGP-ajssoOhKPgiO7jB0HoRxUBnzKPOM3W17KHKCfySc-xv43oIqRamnao0ujytUEjCmuiPpTP426TOICFwsDkyQ_sHHCU50ZtogDs4LJNANF5EKs7rnAm3ckOyU>
X-ME-Proxy-Cause: dmFkZTEMW7OahI9n0RVWD/hEubSqpcQIBbWb4/r2ccfp0OXDKdxdLkclumBQpPQpsWSFRz
    CyE05zdXdLxHyUOnM8STj+8klDTwibnvrXrxa12jA6qpgCRv+xKm3yFC8OcswY4vGfkYsv
    SKEGdxYytFYwghqrklhTNNMG/B+TOlqN+EunxyzzR2HoEcNSnJBZzfM9YM12kISOaXhkZy
    BstzFQwoevOJ+Neex9Aw7uWNFFB1AAxVP5En+KR/69ZtRNOgfCTLN+egjGK1fsy6P2N9O/
    6xoRVkcHyjNJXQPClJdTeivWGLoKkiKQguqMMO0QUoYTf7YmlnaD+MMjVLmDqtjqvcLrH1
    tbfyxZCavGwWec6UJD+KbRtD+04RHDO+hbjawiAt9Pvgd8s/4HspU7TShchiWrpEIh/ph2
    kNfRL4hlpH3R9dzkgaYUWfRRbxd+BycaB7FjTRFpfUuF+XOUd4LB8gFUnt8R79CNUfzlWQ
    9aDodkc3cRz0wgmUx3bBkWSTwrZzn5+iaLdAA9ufYx1ToZA1VS82Xto6HhnMH0ExMmqAbD
    ugUwDmWpSv61sPo7aq6AqoIopmAAQTT0QvPaboVj0imKIa+UugUdpPIZQh2YmE1HRlmiH/
    5qj5D3xNG4pkTbRHLIDglYzm8GnpLs1Co1X6W2WJStybRCTTTIRb1lbP18+w
X-ME-Proxy: <xmx:TGP-agRfpfjtuYkrJ9LaNJPLqe-BPn4oHsR08mj0M50SAvgxv2tpOw>
    <xmx:TGP-asRK_WBy8JqVm0sJgPU1X-PpycarQZuWdG5-oRhyTEy9c1WqlQ>
    <xmx:TGP-akoJsTdi_VWyhh8VKfn8XQhVj_e1knVqPVi0EdOQJajSi5sj3w>
    <xmx:TGP-akC8V1L6TVCJBnzdixcmtO61iPDHxVoenUr0MV6bJsO4obwZCA>
    <xmx:TGP-ahvle73T3uqls3ghVjJ92_xolng6rm0wxQHG7VbbMPsftkITjNTq>
Feedback-ID: i558e4b61:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 18 Nov 2026 21:47:35 -0500 (EST)
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
Subject: [PATCH v3 2/3] NFSv4: run lease renewal on a freezable workqueue
Date: Thu, 19 Nov 2026 13:47:17 +1100
Message-ID: <20261119024719.311474-3-andrew@sericyb.com.au>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20261119024719.311474-1-andrew@sericyb.com.au>
References: <20261119024719.311474-1-andrew@sericyb.com.au>
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
X-Greylist: Sender succeeded SMTP AUTH, not delayed by milter-greylist-4.6.2 (shining.glasswings.com.au [178.63.21.144]); Thu, 19 Nov 2026 02:47:43 +0000 (UTC)

The renewal work is queued on system_percpu_wq, which is not frozen
during system sleep. During hibernation it can therefore fire after the
snapshot has been taken, while the image is written. It then queues
renewal and DELEGRETURN RPCs and can wake the state manager, all on
behalf of a kernel image whose state is about to be discarded.

With rpciod frozen across system sleep (previous patch) those RPCs are
not transmitted until after resume. Run the renewal itself on
system_freezable_wq too, so it does not run in that window at all; the
delayed work fires after thaw if its time has passed.

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

