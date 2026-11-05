Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793905112;
	b=sWNHbIfKa/jYyf3KYmY6q6Huyp/UbqeBXjY/r8bn9RHcmOVntfBGFK9qVORz+UC1uqma
	 52JvaG4MO1eeSoZucjBJlw/aT6tKyr2GzlaAZMaesdi+g+YKWnhcLW92IcRA6vwdck7+a
	 UmtiTFSgkBq4msuf8rBvXESKbQ6pl/PnPVCLpHJQyIFzQacmm0Mv/1IQsN5/y/kHTBqTo
	 52ZG+Nsq224DU075IvJfTHhJw6TPgybAoiZSicMT9d9Ian9Gor/851Occ5H92PLz41Vz3
	 5jzW0vlTIa7yFmcRbSGskkqCf+0dwEWQMlkzPNG84qGy+DGm9bnZlMIGhcQAggyyoVw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793905112;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Content-Type:Content-Transfer-Encoding:
	 User-Agent:MIME-Version;
	bh=eefzh4c+QotAov3+ZMLXnKDHBtjZnvz0FDSJ0ZfRNgM=;
	b=x/A+g1aL0xlkfGTz8PwUdLWrimt2LgY4WzTKVHurbuXZzyAEsL0NgBFNdyeOoKzQx6aQ
	 qXD7peDFUsjnxLPzEhnWuj51Sb2bR33mIph64Pr9D+kF3oohRCVJ858iA/R1ZWKj00jbw
	 q7KLsx2vzqgL0o3+3kX9uNHUaZNL9YWnNNoykXjDpEGAjcrystvcG+II0hZ5CPiJ/KIq/
	 Ho4ghnqj4voochzRNW7FcGCxcY9gDkmQn+MkN5JQsHYHhtc0APEEKMrizH8pBwPxju89s
	 WdYnWUCyInm52a42BjuR+pqRbZgJmTTduXUb9AiCRT8dAB+VoWycopqMBBc1llpwFdA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nyDuoA5t;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A755E606A31B;
	Thu,  5 Nov 2026 18:58:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nyDuoA5t
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9553B1F000C1;
	Thu,  5 Nov 2026 18:58:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793905112;
	bh=eefzh4c+QotAov3+ZMLXnKDHBtjZnvz0FDSJ0ZfRNgM=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=nyDuoA5tjxCe3/W/5qOSUA7umGVBDf1b8h0z7WT1W98/E10bsTvTGCjLrdjCJT9ZC
	 neZuvYuqhXtTtAV+n2O4Sa7zj5wjDCBUyAZ1pyCFs24CsfcFxQ/IqzprE/mdtRZC8R
	 VNT7eBXgAtukSWa+kD44bOfBgNc2SlNn/UdmBrqdXZMXheStMXAvHmloSGVTaHNgAu
	 /sB4Uri7hR5NEPp82ZoJdj8YIMmeT2IK9uCClmK74LsV00P5xTazPp+W9+J8/PBjBR
	 IW3gWz8QIXkQ4II8PTc/u5zsGVtMYFGFKjLPFq1UYR46oqGcmgFb90P/s+DQMfSEZY
	 ZtvDDtfGquQaQ==
Message-ID: <457aa50d7c217019552b103912a1309f7330c617.camel@kernel.org>
Subject: Re: [PATCH] NFS: idmap: fix race between key revocation and payload
 access
From: Trond Myklebust <trondmy@kernel.org>
To: mdshahid03@gmail.com, anna@kernel.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Date: Thu, 05 Nov 2026 13:58:30 -0500
In-Reply-To: <20261105173251.30389-1-mdshahid03@gmail.com>
References: <20261105173251.30389-1-mdshahid03@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.62.1 (3.62.1-1.fc45) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Thu, 2026-11-05 at 23:02 +0530, mdshahid03@gmail.com wrote:
> From: Mohammad Shahid <mdshahid03@gmail.com>
>=20
> NFS idmapping retrieves the user key payload after validating the
> key, but does not hold key semaphore while accessing the
> payload.
>=20
> The key revocation path acquires the key semaphore for writing
> and clears the payload pointer through user_revoke().
>=20
> Without holding the semaphore ,revocation can race with payload
> access.In this case,user_key_payload_rcu can return NULL.
>=20
> The existing IS_ERR_OR_NULL() check passes this NULL pointer to
> PTR_ERR(),which returns zero and incoorectly reports scuccess.
>=20

Let's just fix the real problem, which is that the callers expect
nfs_idmap_get_key() to return either a non-zero length or an error
value.
Right now, it can return a zero length, which is interpreted correctly
by nfs_idmap_lookup_id(), but incorrectly by nfs_idmap_lookup_name().

The semaphore is unnecessary.

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
