Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DBC23955CB;
	Sun, 18 Oct 2026 09:48:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792316926; cv=none; b=BgYXJFSArPqfI/Rfsyq0/wtm7BHXsrXJ505E22KFFeFV5/CBFEUHdKT7i0paau6eaPQ/2udYVGduJEJYG10DXEmB1x5kqn0I79Xfh7jKynBYWtk+aFIaDbqEFrDlH5DqOWV/iu5UFA2EHgG04Emo84FGlbxYIRV6jYoUbeUNktY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792316926; c=relaxed/simple;
	bh=qJwB7t76AjRWxoKh9qhPkLMwN8Ed3hiT4W6+ha8iVOM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=H/gGR72inD6/UBAX0woDs/IEN6UVto9ak91WfoPaLoZbAsMHX+MGEMBNh3unLsNTFyeBnZR6zRRoRAqcYX/jp9tMFozgMUB1b6NyGVIwZSIXpqWg32376k2FHvCqyeMkwwAkx5+SuvsbhUe3H1Tl+IPuaE+/rEg2vmqiTRSzs08=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=No0JYd+e; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="No0JYd+e"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1AD9E1F000C5;
	Sun, 18 Oct 2026 09:48:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792316924;
	bh=bo3zANLBm5Q1EtGR6aS+nMbP2EIcBSvsA1K6ycT/s58=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=No0JYd+eZ9MMu4X4uOIlI2UC//AQquVnjxUzHVsqGba8ZPnWUT0tYblZXQ7K3JRWM
	 MzJ4gkOPZIvYMuia3c7M4drz4AiT8aU6HHw8sah28aRLPH1mZN3DkRWoTETUoM85Tk
	 srz/PFvmUFj3NzLtZxjbpsl0gGz7l5CnZHh9R5GJzNFPT6dJH3okwI87t3NEpXVL7w
	 8WeVaaT+GEhrLemeiYcFPkKV3zPtdikzEqS1CWpovOcAptcrgG9UkfNPqktgjVGYgA
	 AO4VZ9tVKlw1C525myfiRWdXlheNQD4w1DiHCCa5/19mKAc0zq0ZHE0Gf6wbWNNAWx
	 41KYygGWE67Zw==
From: Miguel Ojeda <ojeda@kernel.org>
To: gregkh@linuxfoundation.org
Cc: achill@achill.org,
	akpm@linux-foundation.org,
	broonie@kernel.org,
	conor@kernel.org,
	f.fainelli@gmail.com,
	hargar@microsoft.com,
	jonathanh@nvidia.com,
	linux-kernel@vger.kernel.org,
	linux@roeck-us.net,
	lkft-triage@lists.linaro.org,
	patches@kernelci.org,
	patches@lists.linux.dev,
	pavel@nabladev.com,
	rwarsow@gmx.de,
	shuah@kernel.org,
	sr@sladewatkins.com,
	stable@vger.kernel.org,
	sudipm.mukherjee@gmail.com,
	torvalds@linux-foundation.org,
	Miguel Ojeda <ojeda@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH 6.6 0000/1674] 6.6.160-rc1 review
Date: Sun, 18 Oct 2026 11:48:33 +0200
Message-ID: <20261018094833.47517-1-ojeda@kernel.org>
In-Reply-To: <20261017160431.119607952@linuxfoundation.org>
References: <20261017160431.119607952@linuxfoundation.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Sat, 17 Oct 2026 17:37:52 +0200 Greg Kroah-Hartman <gregkh@linuxfoundation.org> wrote:
>
> This is the start of the stable review cycle for the 6.6.160 release.
> There are 1674 patches in this series, all will be posted as a response
> to this one.  If anyone has any issues with these being applied, please
> let me know.
>
> Responses should be made by Mon, 19 Oct 2026 16:02:05 +0000.
> Anything received after that time might be too late.

Boot-tested under QEMU for Rust x86_64:

Tested-by: Miguel Ojeda <ojeda@kernel.org>

I am seeing the following warning:

    net/sunrpc/svc_xprt.c:874:1: warning: label at end of compound statement is a C23 extension [-Wc23-extensions]
      874 | }
          | ^

It looks like mainline cleans that up in the next commit which was not
backported, so we get to see the intermediate warning here:

  7b31f4daebad ("SUNRPC: rename and refactor svc_get_next_xprt()")

Cc: Chuck Lever <cel@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>
Cc: Olga Kornievskaia <okorniev@redhat.com>
Cc: Dai Ngo <Dai.Ngo@oracle.com>
Cc: Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org

Thanks!

Cheers,
Miguel
