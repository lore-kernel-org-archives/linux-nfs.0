Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com [209.85.210.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9F3C440DFD7
	for <linux-nfs@vger.kernel.org>; Sun, 19 Apr 2026 13:52:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776606755; cv=none; b=UmFkqaYb0lvHFN2Vgpjsbfh9b1FSxySxBS0SGLatQYbz0lDXXYMyv+HFWu1HwEzUUdtdc5yssu55DTVQPeB3CXNV/jPt5bYdBw3uDxR5zq5Z7k1Oo0yFiifdpLTUnktL5hLtCsdA5SHcGEiSHnvjj/6uoSUuHmNWbqR41kz7sA0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776606755; c=relaxed/simple;
	bh=0xlwD2XzlI2c2/k+84ch+FaunohJYR+PG4UzIsdfF00=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=LXvgjOKhOZrHcraVw3+wjrW6eHhCyKr2hC2B2Ct6glv6G9HKUAxNho8NsurQJbrbQhYHWFc4DhJUy7hRCcOxaC4gzA3Xickf1P9Y8prNqNSz2VvAs3cBM5EoyNhVu5odR4TwYM43sso/X5tWquCra5OhV96pdDCNgYQ+JWEmtug=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=m6CVMS/e; arc=none smtp.client-ip=209.85.210.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="m6CVMS/e"
Received: by mail-ot1-f50.google.com with SMTP id 46e09a7af769-7dca00c1591so455288a34.3
        for <linux-nfs@vger.kernel.org>; Sun, 19 Apr 2026 06:52:32 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1776606751; x=1777211551; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to;
        bh=TEJPeMszFc5csM0tO7Hd3vRrNvsKDXBRzHM/pdoOd6Q=;
        b=m6CVMS/eR0pB2DZ3JQyHn42vmZ+8LGUt2+DsAXTzjCul8Fic6+ccrcTT9a3UEu39PK
         9yWlwUryvQy5GJmOEvScT07IR3DpJW1PAA29zPzN/2phPLj7Dq0TrnmjJfrBtZdrvdod
         OBTcr3Sxi2do0+FqgwDbpn6IYR0NY8vhd1Z7NSZfYIa2Fxr1HIiEkxK9HphqKB0U6/MS
         YCDOu35CkAli0BgK+lei9GyqokkaLxNYm0uNoako4Io4LBbaUezbj+OUbzy0ZDNBbJ04
         aPsXKxSalhP5KF1Gj5X1gAFkMHZIQSez17DZxptX9xDePRE7PAnvmFEvYI5HypI9vDLV
         f0+g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1776606751; x=1777211551;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=TEJPeMszFc5csM0tO7Hd3vRrNvsKDXBRzHM/pdoOd6Q=;
        b=AYdVI5fk17oa+lZSuWj8+jDqqko+fk4CB85cxJadBfb2NQtf442FWi9chTHK/1DCB2
         skTBSHGnuI2oyxrXi1dYXqGCLimLCjyL3m1t0KieyVPhUr8OuLlAvEFkFA27tMqOe1OE
         EC73gSVR9LNhXbqCINYKAuHROyhCPg+7jqpZgvgnIzY4MyFgQnmoB5eDfUxsD17EL/cL
         SW8ejb+JR5De8i7T5FREMRiq0O6Vdo9EFP5Kb7MOuNSDUyyfLmPIeOU302Bx/x3jgsA1
         sgBPdn7IavfB1x1Tf1EILaPyf/R+394ycwW9hF18DyzgH9JKBOoUgj6YrhAE/sZBtNNB
         D4Rg==
X-Forwarded-Encrypted: i=1; AFNElJ9dT1oLrgxIg6wj3UrYdEiHS+7MfEpntW9EPSw/06EUwOYOZ0ke0n2rP5G6+Isxbsme9kYwmhODDmw=@vger.kernel.org
X-Gm-Message-State: AOJu0Yx3K3ZpTyTFjs9kZ+j8adxXe8TliJ56lDYT+g8GSYxZgSQu4VI0
	3E+11/nt2hAHwzEqorNEh/mKFP3fAktdlQgmR5QiLsdFOvVqMLUI2e7t4nGtvRBtwvY=
X-Gm-Gg: AeBDieur6vjF9jkn32PEw/VSzy81c4k5VrYaaGfRbLSafx7j0xbrHfsnj9ZK0FZjcsC
	NDoMo5uwdj3AIucdSSX/6giTUlhdGOVCZSG3IN2Y9mzBVfl/ZudfUXv6WZE3qvBuLv0/oRZBhnw
	nQl+jRIKYVFhuBL8MNZjT9YAKxv75NV45hHyz4/VWYdBbDrAIRP/wgX9NIeokhXTlNDAdni0wT5
	2EItPkdGtlsC0OJjJHbD4VOfaooaLFqV5Ve41yc9WkS4yGFAbvipuE+W31xPm+gadpOylRcs93G
	Zi/Ex7pxAqg7oQnGc6iwB5YNWvPetj34zaI0EmfTEHyGe25mAojZLICbLk5edPfOBw2bproItgX
	k0gS0YV+u3DN19Owl+4lqjqQjAaOFQoqUKn3eVv+fvAvoZYYFNeDGBGavOmjCHGmZykKJKNqzkP
	zfYDPR05QHjsxMquCm1uQboNbUiLTYpdd/RQ5ua53HbiOenZSHRxs=
X-Received: by 2002:a05:6830:82eb:b0:7d7:d4ee:c02d with SMTP id 46e09a7af769-7dc951f20c7mr6000125a34.21.1776606751427;
        Sun, 19 Apr 2026 06:52:31 -0700 (PDT)
Received: from [192.168.37.1] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-7dc9751920asm6217239a34.9.2026.04.19.06.52.30
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 19 Apr 2026 06:52:30 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Sean Chang <seanwascoding@gmail.com>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Jeff Layton <jlayton@kernel.org>, trondmy@kernel.org, anna@kernel.org,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 2/2] NFS: Fix RCU dereference of cl_xprt in
 nfs_compare_super_address
Date: Sun, 19 Apr 2026 06:52:28 -0700
X-Mailer: MailMate (2.0r6272)
Message-ID: <35E1BD18-1B61-4F71-B50A-D1C830760562@hammerspace.com>
In-Reply-To: <20260419100128.20546-3-seanwascoding@gmail.com>
References: <20260419100128.20546-1-seanwascoding@gmail.com>
 <20260419100128.20546-3-seanwascoding@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On 19 Apr 2026, at 3:01, Sean Chang wrote:

> The cl_xprt pointer in struct rpc_clnt is marked as __rcu. Accessing
> it directly in nfs_compare_super_address() is unsafe and triggers
> Sparse warnings.
>
> Fix this by wrapping the access with rcu_read_lock() and using
> rcu_dereference() to safely retrieve the transport pointer. This
> ensures the xprt structure remains memory-safe during the comparison
> of network namespaces and addresses.
>
> Additionally, add a check for the XPRT_CONNECTED state bit. While RCU
> guarantees the memory remains valid, checking XPRT_CONNECTED ensures
> the transport is still logically active, preventing operations on a
> transport that is already undergoing teardown.
>
> Fixes: 7e3fcf61abde ("nfs: don't share mounts between network namespace=
s")
> Signed-off-by: Sean Chang <seanwascoding@gmail.com>
> ---
>  fs/nfs/super.c | 21 ++++++++++++++++++---
>  1 file changed, 18 insertions(+), 3 deletions(-)
>
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 7a318581f85b..c9044d9d64cc 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1166,12 +1166,23 @@ static int nfs_set_super(struct super_block *s,=
 struct fs_context *fc)
>  static int nfs_compare_super_address(struct nfs_server *server1,
>  				     struct nfs_server *server2)
>  {
> +	struct rpc_xprt *xprt1, *xprt2;
>  	struct sockaddr *sap1, *sap2;
> -	struct rpc_xprt *xprt1 =3D server1->client->cl_xprt;
> -	struct rpc_xprt *xprt2 =3D server2->client->cl_xprt;
> +
> +	rcu_read_lock();
> +
> +	xprt1 =3D rcu_dereference(server1->client->cl_xprt);
> +	xprt2 =3D rcu_dereference(server2->client->cl_xprt);

This is a good fix for the sparse warning, but..

> +
> +	if (!xprt1 || !xprt2 ||
> +	    !test_bit(XPRT_CONNECTED, &xprt1->state) ||
> +	    !test_bit(XPRT_CONNECTED, &xprt2->state))
> +		goto out_unlock;

^^ I really don't think this check is necessary.  Aren't we only ever
comparing with one freshly created, and the other looked up holding sb_lo=
ck?

I'm doubtful this hunk is fixing a real problem.

Ben
