Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794952926;
	b=nKNbcQWJTe8NiK1VshY8wlA+bomV3akczGQzorHOlgAZoyPbFIMMkPBnIBDmYx+gkoL1
	 WX0m+56pOC+1/f+zQdDnQgp/17ku4dg9TjWteMrpTBqdgtxfX6X9404F60+SiWSPB7hie
	 yGLqNhb4CU3E+MwOSVWvgo/hTVVUtocKyYMUTBkLFCLrT5YHU6Qn+A/WRcQdMKWxY0bxw
	 H8X9EdxbAPH1RUMFgBOq7S5KOA/Rw2p1kacA3TMKXnGxh7uLEgaNxKDgflGW0g2PFj69V
	 R37HyCPmZ9GpVqKtMNiglQj53sLjpJta9COcCza4i8hlnzZFIZeGVorl2J5SjxUjeJw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794952926;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=EsQiVnWdklcglRbIqoscQFF5X7p4jGIU+Y0OOx+78ps=;
	b=1qU5iDcdl4gxYAH9LaV2n9SYqMZYd3YcHobTqL7dbzbcGItri8cjcyCPbVsgA8b3L5uG
	 +vVekYYykNlaJF5f9u5KoRztmwaY89mXaqBjcFzobTybuzsaJn7PZnFyWHKKBbwoarUUk
	 XUcxbqE1tyjiTN87ANXu5nceJqDfwfG73hwNA2TIP7Lz7446In21VwUlwf2FjwkmEPDo3
	 xDsIVpbpe/dA8XrilOgK7n2sMeYzjDahvmkgAldepaw8/2IvX6m+nzR7eVC0wtr+Rs85H
	 NYULjuRzswMJAqCDPVQ4PoB/X2hvkuA/IzBOPoLiuLXVQBbf7kW5XJ6BpdJw4CjDYjg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eRKKuDOC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 74368606A32A;
	Tue, 17 Nov 2026 22:02:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eRKKuDOC
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1BB3B1F000CC;
	Tue, 17 Nov 2026 22:02:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794952926;
	bh=EsQiVnWdklcglRbIqoscQFF5X7p4jGIU+Y0OOx+78ps=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=eRKKuDOCG4lZI0ZtmAAIpexh5saMlRjXYGgquqnGJHw5xx0hKiSTtEpRMTU0UnEZx
	 IcVAie3qbTbLtwat8lgNDCP6zhB7QCTVdVvmIBlqP9fuJUX+csyhPtr5Pct2KMF+dr
	 sKEIWoHciSIaSRbPXtRwsvShsS664//k6GK3BjshzeV1onoC5SB/aS7wLmCyLKJ9K8
	 m5LAARW1i0RM6erGJTXwnJLIbMj19kpQzxaJV5KdnARcC1GmD4YHak/fh/wBY2ukPa
	 yhfRyDN1zjqulKDzMqoKKSTFXathlkGd8lIzu3DnyeBMJBeCEbjKT0GFxDySnJK8UV
	 YAtD4XE3Ry5Ag==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 50504F40066;
	Tue, 17 Nov 2026 17:02:04 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 17 Nov 2026 17:02:04 -0500
X-ME-Sender: <xms:3M78aq1jfwU6kkpHJYfkamLb7k26diePkGr8HYaND-ZrMBjnohMrzQ>
    <xme:3M78an6y1Y_GR0u1TwtOXDhTJSDOYemr1m9Hmyh5XEDGdsDAx71bEoAOEShnFinjM
    69EF-AeO1bjSPJvAvqEXXhgqHUGSfFOCO013H2g38lm6F7OfmUkmU4v>
X-ME-Proxy-Cause: dmFkZTEFWk4jFRq2Ypvh/OGGpN3RYf9yAIcrjwoio2l5SxvidVJI3djILaxgpL7LyuOL7E
    lli1okH5QEaMWzCUMyMt49RTjdtkb7p5j8SnJ7vko/DXCHPESNoXMFqc8eAYVU7BGtrfNE
    O8Wkt/X+eQscT/cb/kG8LbWg6SuLpK+A11UAMB+QAdy5UWJZaV2trmsj/oQjP/6lPcVVP0
    p+nLQemqrSyF8f9utiFf/d15PjZvnAYnKe5plmCnfbGuYaAIvR4RuHbeaDv3ZwgaqwEoTc
    O56V45wyKdQUyvAqx58jhwnrJqlfVvWKvX0EJKReKmJux7PwleYyLgjD7P44v937Li49Qw
    3PfPZt4Tz5Ch4ICbtemCoWAFkhd9LpRHHoQMM6xH+uQv2Cf4FlSCV6BNrPskaFpbE2Gt1a
    ss+P7AhsTRHraYWbE5wed0xL9iCm70tSnIKB//n/ZBAuWR+D7Nfc9NMkA+fe4C2g5UFBLM
    HmApoPfgE08+h48RscbkJ1zXPfd8wMImQd71BRZR8wJOu7FYt+A09ttWsoXwQ9M7voSEdh
    iRB9mHPKZYTCf5j5tYY9XJfVHu4mQQzGd7r79LEO7RpJ1QmejEfUCnIUQqmekcp8PP/D1n
    CB+FZEcYdo/YsJxNiNswgtVIPlyCf6Ab0g19TFApN5j+o5xqL9Y5EgaGlC7g
X-ME-Proxy: <xmx:3M78anU0MJ35zJ3NF5t0f4ScxkcsT3P7nBy3grYqehD-Bs0aT3fDkg>
    <xmx:3M78ai64XGO4B10f_mx5toxFs_hI5crqdE1ZqJkyW4lQCVpizqa6Sw>
    <xmx:3M78avOt7UDMa5ZXcad-yrMZ1xx7rDvSS6ajIf1O1pvu-h3fvDtK-Q>
    <xmx:3M78algMt1NSKEj31TOL76bmFCAw6QHR4dwEMMeuS0i8PnqzpbVH4Q>
    <xmx:3M78alib9v_mERwNSmE9KLKWOVL58rpYH24tW96EQor0v_frdN4CGY3f>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 219C2780077; Tue, 17 Nov 2026 17:02:04 -0500 (EST)
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
X-ThreadId: AgKvhXN-CN1w
Date: Tue, 17 Nov 2026 17:01:43 -0500
From: "Chuck Lever" <cel@kernel.org>
To: koraynilay <koray.fra@gmail.com>, "David Sterba" <dsterba@suse.com>,
 "Namjae Jeon" <linkinjeon@kernel.org>,
 "Sungjong Seo" <sj1557.seo@samsung.com>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>,
 "Konstantin Komarov" <almaz.alexandrovich@paragon-software.com>,
 "Paulo Alcantara" <pc@manguebit.org>
Cc: "Chris Mason" <mason@kernel.org>, "Yuezhang Mo" <yuezhang.mo@sony.com>,
 "Jan Kara" <jack@suse.cz>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Ronnie Sahlberg" <ronniesahlberg@gmail.com>,
 "Shyam Prasad N" <sprasad@microsoft.com>,
 "Bharath SM" <bharathsm@microsoft.com>,
 "Sergey Senozhatsky" <senozhatsky@chromium.org>,
 ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
 "Darrick J. Wong" <djwong@kernel.org>,
 "Sean Smith" <defendthedisabled@gmail.com>,
 "Andrey Albershteyn" <aalbersh@kernel.org>,
 "Pedro Falcato" <pfalcato@suse.de>, "Amir Goldstein" <amir73il@gmail.com>,
 =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali@kernel.org>, linux-btrfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 exfat@lists.linux.dev, ntfs3@lists.linux.dev, linux-cifs@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-api@vger.kernel.org
Message-Id: <f297d9ea-ebd7-47f4-ab7b-de5c45980000@app.fastmail.com>
In-Reply-To: <20261115180343.576773-8-koray.fra@gmail.com>
References: <20261115180343.576773-1-koray.fra@gmail.com>
 <20261115180343.576773-8-koray.fra@gmail.com>
Subject: Re: [RFC PATCH v4 07/10] nfsd: add provenance time (ptime) via
 FATTR4_TIME_CREATE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sun, Nov 15, 2026, at 1:03 PM, koraynilay wrote:
> Implement provenance time (ptime) in NFSD, as introduced in a
> previous commit ("vfs: add provenance time (ptime)").
>
> Map ptime to FATTR4_TIME_CREATE, allowing clients to set it across
> CREATE, OPEN and SETATTR compounds.
>
> If the underlying filesystem supports it, use __vfs_fileattr_set_locked()
> to set it, returning -EOPNOTSUPP in case it's not supported (i.e. when
> __vfs_fileattr_set_locked() returns -ENOIOCTLCMD).
>
> When querying FATTR4_TIME_CREATE, request both STATX_PTIME and
> STATX_BTIME, preferring ptime over btime if available, and advertise
> FATTR4_TIME_CREATE support if either ptime or btime is available.
>
> Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
> Signed-off-by: koraynilay <koray.fra@gmail.com>

> @@ -3646,7 +3649,14 @@ static __be32 
> nfsd4_encode_fattr4_time_access(struct xdr_stream *xdr,
>  static __be32 nfsd4_encode_fattr4_time_create(struct xdr_stream *xdr,
>  					      const struct nfsd4_fattr_args *args)
>  {
> -	return nfsd4_encode_nfstime4(xdr, &args->stat.btime);
> +	const struct timespec64 *ts;
> +
> +	if (args->stat.result_mask & STATX_PTIME)
> +		ts = &args->stat.ptime;
> +	else
> +		ts = &args->stat.btime;
> +
> +	return nfsd4_encode_nfstime4(xdr, ts);
>  }

I have trouble with this approach.

We've already established that, for the Linux in-kernel NFS server
implementation, FATTR4_TIME_CREATE reports a file's birth time and
does not permit NFS clients to modify that.

After this patch is applied, the server reports the ptime instead
of the btime on some filesystems but not others.

Essentially this changes the semantics of existing files that have
a btime set -- technically that's a regression.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
