Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13BC53DD521;
	Tue, 11 Aug 2026 19:14:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786475693; cv=none; b=Z2//cJhWerbiVZA5jYP1zRIPTfWY4lFRtlyIzvA2wv/fk7d2UhvuxCNvOKlPGnEY2Oh7D53ADsqMSJhAGuaip755Dr71OmrEvdIXVTnqafpik9CUM1VinUxmQmASUK9YheLxt/ka+7r+TCS1VQ6L+ApZoOjmDCWQDiBQMo4OC4c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786475693; c=relaxed/simple;
	bh=G5bqmNmbGt50A9O+l2Ln94Y3ZioxR+98H1NAiNMKX38=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=XOS0oQjhRq7qc1td7P/XnvlGmrFWxzPPpnJq28O/MJAobYP1fvmqz+LXn+AiPBPViQFNVH5oPbONDDBTsHcMUggdmfjpAyER0hxdiMJ2IfT2Sr4Do6PS7vQYD6rFRDLbAdLVJRPecOdQFxYpz34p4jlMuXVqJy2QINTlbB16Kro=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=T9hcWzba; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="T9hcWzba"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3EAB01F00A3D;
	Tue, 11 Aug 2026 19:14:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786475691;
	bh=yd2AqEC6qdcdBbah5fNDSAWTlSK5qf5bTdQ4yFD8b/I=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=T9hcWzbaGlEzQt+xrHk0R6bTr8E81Slf2aJv1AbXbFL27NJAs5Irwdbw+XMNnxIup
	 NxoHSCFBPjk+d6urKUPn4tRldLN6CAOA9+byOy1Pkwxh9aFdHzaeoa4BUAysyZ5b3o
	 h587llS3CbvOfrPcNg7lhHmefFvXTiw5U1FMncLH4ROXT4v1FPq+qtVmY9d+iVEIJc
	 F9VsO7LMbwCsBwbTy41JDhNbXkgMBBEAMUR7lVHiZWBwhBYIvrtCsP6VdJnybv6awu
	 QCZDnuzkPR7VOquaXCOUz4mlxDOg9/BEsFw/QDYVfUGO6O0bOtGfMlNwNvOMl/ZEAf
	 lZkwB9iGkmpHA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 593FEF40066;
	Tue, 11 Aug 2026 15:14:50 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 11 Aug 2026 15:14:50 -0400
X-ME-Sender: <xms:qnR7arSPO_Dw1KaC_qTQ4bE5pZO0BQQO6r5ock0nemQ994omNTlDzg>
    <xme:qnR7anm79jl_LY386t_ShWNL28UfUcixiwjVYgtVDuSQJ-XcGV_eDbvJE23sKyUip
    j0i74Xs4o1dCgt-XsugnzUadMMHLshPE_4Txs95jxse94xEZpKmKQ>
X-ME-Proxy-Cause: dmFkZTEXD6jQm04/NalG491FM3LmpXaIuseq+c+vIIL8ck81U3z4Ztt9qeBDlMZ1VlLTfI
    nmh/M19xvY//gDy0xLKJFjoOVrCRdIPm1Vm+UOsLB25U1P6eYHIx+QH9nGrL6mzQgwqHBu
    xE1RUYvtYG4e/P1MZn1hAaiy8wyrNhm6O4H1YyMw2HaEUE7eZ8KxARHb5iGS5mbBaN/WQd
    sUvnS1puV8e8UN7rh0bD4q73MbtM9w7e7i8pdQr7L5Ubn4/kXDdUERh45IZrmLwt5m8v3b
    iSHWWRZfl0LMfmEGFUo9LLUzA15A4dUVxmlDOLqWFY3MyNmO/ScVBnngl7U6wwCmvlq4V1
    QEUBJs0wr0l4cIEO5Ng9nN+NQ3WRcfg9UsUUoo18qoqUCtxBC0PZdhqWhdyKrbdTGgKhLB
    WZLuXpd6V4VJrgqYsMgtFxgvoKPj2zgFF3O6fueCHPVdzxFH/kpFU8AQagpWdKHCEzbrSl
    ta5Z0lZpOumpBcPFWrVnj8ck1Mi08hf39tam8WUAbM1MCtOoUzUeSpEIM4hvXRklSqK6pK
    zlnbR+mlymi07Kyq6CYnEZtpmz++lpD+6fnFI8JiasvM+7SAOf09OGVtFSaBihFwDySLol
    yAzUcoTdIbwVgP2b+XmtsHmmJCfnwJ1pmtzlHzcrlQW7Hs3tnw7n3+rFSksA
X-ME-Proxy: <xmx:qnR7avRP4zIqeSmJ7eHLOXiRaS5OW6qYLVPWuJZf49djkKouRyPhwA>
    <xmx:qnR7agB7RFbe6tmuLi_G2X4XpW-0sM_xIKBVYb90-JA-tnfi3eTQwA>
    <xmx:qnR7anpTCcA1-I2PDpofbhJ6b9YRivh95Tx1bPJYWqbpDMIzCM8e_g>
    <xmx:qnR7amj-QWK5sjfnJ-G-jutQxI2Q6Zm1oZ78ajA42si0RTPhhOeg8g>
    <xmx:qnR7aswK1wveI8ZZEMkYSfyWAmoFH_nT2mLOmdbjfIKLzhtEIOh_KuMK>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 30BCE780362; Tue, 11 Aug 2026 15:14:50 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AuefP2vVSn_o
Date: Tue, 11 Aug 2026 15:14:33 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "J. Bruce Fields" <bfields@fieldses.org>, "Shuah Khan" <shuah@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, "Trond Myklebust" <trondmy@gmail.com>,
 linux-kselftest@vger.kernel.org
Message-Id: <59d69859-6a41-40e6-957c-23159313956f@app.fastmail.com>
In-Reply-To: <20260811-nfsd-nl-hang-v2-8-c0c92b3953c3@kernel.org>
References: <20260811-nfsd-nl-hang-v2-0-c0c92b3953c3@kernel.org>
 <20260811-nfsd-nl-hang-v2-8-c0c92b3953c3@kernel.org>
Subject: Re: [PATCH v2 8/8] selftests/nfsd: add a per-netns rpcbind stub and the
 listener round-trips
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Aug 11, 2026, at 8:03 AM, Jeff Layton wrote:
> Creating a listener registers with rpcbind: svc_xprt_create_from_sa() passes
> flags of 0, so pmap_register is true in svc_setup_socket(), and
> nfsd_version3 is enabled by default and does not set vs_rpcb_optnl, so a
> registration failure aborts listener creation. A fresh netns has no rpcbind,
> and reaching the host's is not an option -- svc_rpcb_setup() opens by
> calling svc_unregister(), which would clear the host's nfsd entries.

>  /* --------------------------- fixture --------------------------- */
> 
>  FIXTURE(nfsd_listener) {
> -	int placeholder;
> +	pid_t rpcbd;
>  };
> 
>  FIXTURE_SETUP(nfsd_listener)
> @@ -369,14 +665,35 @@ FIXTURE_SETUP(nfsd_listener)
>  	nfsd_family = genl_resolve_nfsd();
>  	if (nfsd_family < 0)
>  		SKIP(return, "nfsd genl family not found (modprobe nfsd?)");
> +
> +	if (rpcb_stats_alloc() < 0)
> +		SKIP(return, "mmap(rpcbind stub counters): %s", strerror(errno));
> +
> +	self->rpcbd = rpcb_stub_start(RPCB_STUB_ACCEPT);
> +	if (self->rpcbd < 0)
> +		SKIP(return, "cannot start the rpcbind stub: %s",
> +		     strerror(errno));
>  }
> 
>  FIXTURE_TEARDOWN(nfsd_listener)
>  {
> +	if (self->rpcbd > 0) {
> +		kill(self->rpcbd, SIGKILL);
> +		waitpid(self->rpcbd, NULL, 0);
> +	}
> +	if (rpcb_stats) {
> +		munmap((void *)rpcb_stats, sizeof(*rpcb_stats));
> +		rpcb_stats = NULL;
> +	}
>  }

The fixture appears to leak the network namespace for the tests that
finish with a listener still up. Would something along these lines in
FIXTURE_TEARDOWN() cover it?

	/* A live listener pins the netns; drop any serv the test made. */
	if (listener_set(NULL, 0) == -EBUSY)
		threads_set(0);


-- 
Chuck Lever
