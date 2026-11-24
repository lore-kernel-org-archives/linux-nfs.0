Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795539145;
	b=X59Y9RqeVGosaPRplzdyR7Zzd22K/dDB2Z88PSz9xn8Csa9QAuR5ySpqSvRmWL8Hhcil
	 cWIaSCYTko8EVnpPISAoY0HrYIxIqHvZEdoPzcFGyRfaoAeCawnZkeZS5/pPVx6+kb6Ns
	 eGxd32ZJteM7RYnm9LttkhF2SFQTnnJdhQGHaT81Rm9CZ+eFpkvfmCki5T5Lc+/7uj4mf
	 /c0vQ5e77DYO6s7hVZWPibMgCksDP9x09/HTHoVkYeTXL8tAC54giPMEsrMtC5ZIvTRYL
	 IOANGo2pbTX+HGCnAPyiiXcvLSNtLWI4Qjfuf+kGJzjLXTaXXUynqrmNKqIV9E7URCg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795539145;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=e9/oR9mWS1WKPmGomi/5W0W8MOD9LULGfpTOrsM0bLc=;
	b=n5NpMYICqXulP/wQDmJgTEEdP1TUVt/h74pyMFjzn6hj7wfwbJP7e9o9Ki90ep6240GU
	 R7v6RDGrtzgH9TL574S6dIOVngGIhxWlJW2Thk1xLldGIcxJgUn5Y3tXTvmLbqQGYVVjl
	 EPlYHV9APUoTW/XnQat3Ii8MOhcS4sM0vgtvW5WYoEGTKqStG3rV0QhTpUlcmlLzYynl0
	 524G4Kr6gTgiDzyMCL7L7H1/SygYCJhI2qodJtK8NXvFn/aK8KWHcit3mDLS9apFssae2
	 GMkHpC1FGjXGuelt8G++KOeRKcTYk36GZOusG99TyJqn4pYOiOqNhNHvLHunbM8Aiww==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hYPFXsrX;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 38DB1606A335
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 16:52:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hYPFXsrX
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 909661F00ACF;
	Tue, 24 Nov 2026 16:52:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795539145;
	bh=e9/oR9mWS1WKPmGomi/5W0W8MOD9LULGfpTOrsM0bLc=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=hYPFXsrXghBqH6mfx3ndkHjU12+gDMAb1sr7k1LS0vOWG+qbyHR+NJyLaM95nK15Z
	 eAJfukZPkOXTBTyVzCRGb5c2E1zR7p9yuxzac1j9ZB4TgeJVoaPZ8gbp/OmEAOV9l4
	 r+LnISYAMAV/nbTq2TotFQuU4tC5uKmRK/noXdSJyoC/lxWZz5mGGToMlOysz1wV72
	 IG6bcCttB12KQXu2X3vKC+SUKvWhvHF4lWs5OZJWSCddstSEOq6jq9o5znHapoDjoq
	 hO6xQwaFYBDCGl0Ab859runx3djBwZs/O9DVVboav/QC80A/hPmH1AbwzreFdRzK7V
	 SrU2IYJm7jaSw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 7D259F40066;
	Tue, 24 Nov 2026 11:52:23 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 24 Nov 2026 11:52:23 -0500
X-ME-Sender: <xms:x8AFa0JvY8eIhhhuqEEGFPYZYeE5SH4sMYrcY5WFCogeGX64IB5utw>
    <xme:x8AFa-9-suNJopYKr85HOjeHYXllf0uiMrmtUbm4THOU1sHLYzE-HTdjn5CBrPdqA
    HDXOigWeDKQJ2VUK5SBgLHPH4TJr3X6VdFqJyqvKqrUtl2MpGkWSRM>
X-ME-Proxy-Cause: dmFkZTFvffRiS/ihXQ+YlJikK6/tQ9o9zou164jyx6LFNSPLtLOpM/z5pCkpE2k7W5A3uY
    +dtSa7IoGmWq+8CMRVel6H4toMv+YitB6FZdwMpEDoazElCpx7m2KIlcpn2sL7NohjG0Yq
    WvJdSa1jfUXhcEojoCwPdW4vT/1LueE5TbPt7GryfKu+nNw4pddnqHDAUe4SUTvPZ3Y2T/
    42PewF4uInOOZu4uOgiCJre05f2aQr54265zJnw7xRS2eSB/NRaaX2/MSNa8dzZEGFsbSr
    chZtgtOh3e1Az8tqkIgzb0HJKtQ+PBlZ5J4RGZ0Fmdty3rtOTzVZeGFIokBDDZ8j039OXC
    K+vyK2cu7Go+E9WkYANqiHpGQhIKl6UsZD4Fk0Xvh9x4C9d1BF+YusJV7/hcbnmlYsVRWa
    v7cEouQoimmSnscH4TsZPo5Gs+GToxlmoX4ZifoAD7F3KRtSs9r+YTAtSFeMRjzArKLkRk
    3EF2r4jiFjIdv8jxpexdM2doAvbGVCUNPgqTUxB6LAMRdN/w+YNM59VmvJ0sBMwHjhF608
    HVqNUnEuyrDD07bPcdLaoqDir+/Xw5Js9nUthGb8OOyLduKdxdBH3cHKabdAjQd4GJzbpt
    Zxi4Fsu34vPtZ4SM66WKD7bsfI6F/fRT+9BJPvIGaDfBuPVz4rWyRGNAv3Sg
X-ME-Proxy: <xmx:x8AFa4YpndLo0kCYSEOENU5U8F7agU7DYGm_X-RBfOgSzVC7kbByuw>
    <xmx:x8AFa_yRoZz0IKTZpY5nhhbU-8zI9sq4LFih-wGEqoViJ1RziplYag>
    <xmx:x8AFa3Yh_zjshc_CDNFtEik9ECnVmJlV9qOT3OTutJM_7Up6PZ4x_A>
    <xmx:x8AFawxYrjCHo7Hf8ABGNsBTQeOXPu1uVyW0xkCUGksK8Is2dLVLDw>
    <xmx:x8AFawHlLJ1rJI-As23fi1xTxX1CPxcu8lRrulIZhNFmTILUPWSCvVh7>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 53CB4780070; Tue, 24 Nov 2026 11:52:23 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AK3k8V--uDCJ
Date: Tue, 24 Nov 2026 11:52:03 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Li Xiasong" <lixiasong1@huawei.com>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 stable@vger.kernel.org, yuehaibing@huawei.com, zhangchangzhong@huawei.com,
 weiyongjun1@huawei.com
Message-Id: <187e2fd0-165a-4dc5-a542-6d87d4750bf7@app.fastmail.com>
In-Reply-To: <20261124021842.130141-2-lixiasong1@huawei.com>
References: <20261124021842.130141-1-lixiasong1@huawei.com>
 <20261124021842.130141-2-lixiasong1@huawei.com>
Subject: Re: [PATCH v3 1/3] rpcrdma: Serialize notification registration with device
 removal
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Mon, Nov 23, 2026, at 9:18 PM, Li Xiasong wrote:
> Registration can race with device removal between the client-data
> lookup, the removing-state check, XArray publication and device
> reference acquisition. Serialize these operations and client-data
> teardown with a module-wide mutex, keeping callbacks and completion
> waits outside it.
>
> Enter a NOIO allocation scope before taking the mutex to prevent reclaim
> from waiting for RPC I/O on a transport whose reconnect needs the same
> mutex.
>
> Fixes: 7e86845a0346 ("rpcrdma: Implement generic device removal")
> Signed-off-by: Li Xiasong <lixiasong1@huawei.com>

> @@ -187,8 +209,11 @@ static void rpcrdma_remove_one(struct ib_device *device,
>  	}
> 
>  	trace_rpcrdma_client_remove_one_done(device);
> +	mutex_lock(&rpcrdma_device_mutex);
> +	ib_set_client_data(device, &rpcrdma_ib_client, NULL);
>  	xa_destroy(&rd->rd_xa);
>  	kfree(rd);
> +	mutex_unlock(&rpcrdma_device_mutex);
>  }

Nit: The conventional practice in the kernel is to release resources outside
the mutex. AFAICT that is safe to do so here; only the ib_set_client_data()
call needs serialization.


-- 
Chuck Lever
