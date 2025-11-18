Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C7F9D1F151C
	for <linux-nfs@vger.kernel.org>; Tue, 18 Nov 2025 14:43:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1763477025; cv=none; b=Mqh0UL0J70VLN96+wmginkQSIFTa9nEz2euK1SZpCWTvA3wVLEhakDJf6hhOhnx/phgZCnRs/dD2sOYf0Ml7OvOI0IjQIIBi5yPsivJ1Bo1Vd5lnwf84mmvWzj/QOuafcpqnLdQF0EwmbEw04gypS+Hz0+Dvc7+JhwPKuNjmthY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1763477025; c=relaxed/simple;
	bh=ShGFoxpiq/IGQ+GElofJqqcHbfh2f/EmaZlunjP3yJo=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=Ze2Kls5sLwAafZ1FspRAaUz9BI5PQJY8LwQt2TqT2mcKJu+GKgxF80Eyw3hoyQ30O9DOrazXqjZj2M8mtQmIXMVt57RE+ZAbB36BlZWsQCWqP3ZYDBWfMb1D8c4OTD8zWBvaMETJtSdAa02dkG6U5uTI7hy5qXokHvUFdyTvtOQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=q2TXL3dR; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="q2TXL3dR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DCA59C2BCAF;
	Tue, 18 Nov 2025 14:43:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1763477025;
	bh=ShGFoxpiq/IGQ+GElofJqqcHbfh2f/EmaZlunjP3yJo=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=q2TXL3dRFfdJPWp2T5S8XqBS9J59TbG38yuElt6n+xuI6h02nxLLeDf9cjtHhaSbA
	 GfJX30eSsGqwecGIesgW8V+0oEvfnrlc0Zf4rMUWMUdrMOIfQMwqk9M9HzoBk/mFSt
	 t/Rdy6bdwsxltQdfZsdGe+6fpB8jVr9PqWFEoq3qYp6BHOT2i12hMQLhKyDfvnWKcz
	 wr8mPRw5tzTIMpDkcwqshm7GgfO+pYjqF1HVzXrgq+hPteqCmrV5BGeHIMHtIB/svv
	 uJNQmMFZaRfsLB844mS+Xx4kxMzCOMu/2UUQwThV4uniyOTInhLBg1wZST068GuuiM
	 F1Pog+DkwBLlw==
Message-ID: <fe6b3cb2fde809977394c5f605b844de043189ed.camel@kernel.org>
Subject: Re: [PATCH] nfs: Implement delayed data server destruction with
 hold cache
From: Trond Myklebust <trondmy@kernel.org>
To: Gaurav Gangalwar <gaurav.gangalwar@gmail.com>, anna@kernel.org, 
	tom@talpey.com, chuck.lever@oracle.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 18 Nov 2025 09:43:43 -0500
In-Reply-To: <20251118105752.52098-1-gaurav.gangalwar@gmail.com>
References: <20251118105752.52098-1-gaurav.gangalwar@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.58.1 (3.58.1-1.fc43) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Tue, 2025-11-18 at 05:57 -0500, Gaurav Gangalwar wrote:
> Introduce a hold cache mechanism for NFS pNFS data servers to avoid
> unnecessary connection churn when data servers are temporarily idle.
>=20
> Key changes:
>=20
> 1. Hold Cache Implementation:
> =C2=A0=C2=A0 - Add nfs4_data_server_hold_cache to namespace structure
> =C2=A0=C2=A0 - Move data servers to hold cache when refcount reaches zero
> =C2=A0=C2=A0 - Always update ds_last_access timestamp on every reference
>=20
> 2. Configurable Module Parameters:
> =C2=A0=C2=A0 - nfs4_pnfs_ds_grace_period: Grace period before destroying =
idle
> =C2=A0=C2=A0=C2=A0=C2=A0 data servers (default: 300 seconds)
> =C2=A0=C2=A0 - nfs4_pnfs_ds_cleanup_interval: Interval for periodic clean=
up
> =C2=A0=C2=A0=C2=A0=C2=A0 work (default: 300 seconds)
>=20
> 3. Periodic Cleanup Work:
> =C2=A0=C2=A0 - Schedule delayed work on first DS usage (lazy initializati=
on)
> =C2=A0=C2=A0 - Check hold cache and destroy data servers that exceed grac=
e
> period
> =C2=A0=C2=A0 - Reschedule work automatically for continuous monitoring
>=20
> 4. Callback Mechanism:
> =C2=A0=C2=A0 - Use function pointer callback to avoid circular module
> dependencies
> =C2=A0=C2=A0 - nfsv4.ko registers cleanup callback during initialization
> =C2=A0=C2=A0 - nfs.ko calls callback during namespace cleanup (if registe=
red)
>=20
> 5. Timestamp Tracking:
> =C2=A0=C2=A0 - Add ds_last_access field to nfs4_pnfs_ds structure
> =C2=A0=C2=A0 - Update timestamp on DS allocation, lookup, and reference
>=20
> Benefits:
> - Reduces connection setup/teardown overhead for intermittently used
> DSs
> - Allows DS reuse if accessed again within grace period
> - Configurable behavior via module parameters
>=20

Please read RFC8881 Section 12.2.10
(https://datatracker.ietf.org/doc/html/rfc8881#device_ids)

Specifically, the following paragraph, which disallows what you are
proposing:

Device ID to device address mappings are not leased, and can be changed
at any time. (Note that while device ID to device address mappings are
likely to change after the metadata server restarts, the server is not
required to change the mappings.) A server has two choices for changing
mappings. It can recall all layouts referring to the device ID or it
can use a notification mechanism.


--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
