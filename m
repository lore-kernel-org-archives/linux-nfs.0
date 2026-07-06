Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 331CF3C3C0C;
	Mon,  6 Jul 2026 20:50:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783371053; cv=none; b=pQWEKPfqiP1sZv41QxagZUaE19zocpDDarfqlgb/GoX1V8Y5defEbuLxpwMgcNuu26kNMIvxz6mrAWvbA2NktYYy2yuEffIQvGIka0vArMTF1Fl7xlYx6WTkdAkrnpxRABzhWTvTvrWEzFd/Oski0RaSlsJdfbE83gpQDFIcSr4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783371053; c=relaxed/simple;
	bh=ttXfcZcqzRmqdNi99/dP+I/JEJS6UuTKJ97SyR1AdHs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=fB1c4PJlUeVW9JDLX1jUT80D5bF4yEhfgF17v+Fs9CKwk1BoajoGj41PU5izzTJJ2xt7UMWzJHKjJhAbyzXpeWGdy5OVdrdL5g74Lopv0M45JZVit+O+fy0wTlyUUB/MdJAofuqQjv7Q+BCLhXC44VhWpMbpwicPGQWbU9uFkSE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=R3q2v8Ni; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="R3q2v8Ni"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 12C151F000E9;
	Mon,  6 Jul 2026 20:50:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783371051;
	bh=66d8tsxlbloJEBgmrcausbM+o2xvg8AHk4c1SBMMT9I=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=R3q2v8NiyCcquyZ4kQQn8pH8tB4CFWI/qV4T3y7TvpXTeDRdWsFVdkoOAAEghRx6F
	 LJLC79blykxMh1YDHX8aJKM6OHHFYawFMzbRoGHdFSnpLhdOYtM56J11ND/QlzftvL
	 kvh0/PL9C2VXDNIsvooXKvYPgHUgEHC3jBtplzkIOQKG1c6V1SDq6a16pOcGrr0T7e
	 j0A2oxGfs+GKeSRgVxNb4qCcVK5EtYNxVqzivfcPcRjbYXv7zmy4W/2czSel6mufFL
	 VrcjAwg/40phj+Pq/GdJXv934Y3H3dy0VNZyK7vkX1mW1pnyxQseQ8b6jAJ9QMXgGZ
	 6VmVg+C2ilYoA==
From: Chuck Lever <cel@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	NeilBrown <neilb@ownmail.net>
Subject: Re: [PATCH v5 0/5] sunrpc: hardcode pool_mode to pernode, remove other modes
Date: Mon,  6 Jul 2026 16:50:47 -0400
Message-ID: <178337103119.1752692.17102361450604849930.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260706-sunrpc-pool-mode-v5-0-6c4ee7cd89aa@kernel.org>
References: <20260706-sunrpc-pool-mode-v5-0-6c4ee7cd89aa@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Mon, 06 Jul 2026 09:29:20 -0400, Jeff Layton wrote:
> This has a few small fixes and comment cleanups and also implements
> Neil's suggestion to remove serv.sv_nrpools:
> 
> Patches #1 and #3 address what is a shortcoming of the existing code --
> namely that the server can be configured to schedule RPCs to pools with
> no threads in them.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/5] sunrpc: route to a populated pool in svc_pool_for_cpu()
      commit: abf002b5412b282ce825cf0ada22f0278ae7f408
[2/5] sunrpc: hardcode pool_mode to pernode, remove other modes
      commit: cb4ab2c71e09f8c958ecc7bf07270ae78584f85a
[3/5] sunrpc: guarantee a thread per pool when auto-distributing
      commit: c972bef38717f27c282592bca22890f49233ec0a
[4/5] sunrpc: tear down pool counters before dropping the pool map reference
      commit: 9b6f69571d09627b8b4303be0f257c0e36d9d3fd
[5/5] sunrpc: derive the pool count instead of caching it in sv_nrpools
      commit: 9435623ac560654825a62ee4b628ae4bbaa87920

--
Chuck Lever

