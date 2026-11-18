Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795011977;
	b=bwxFM1x1CuAfPTWzWFT1C5cLVgner/CdNAezvlOpx2yH/wAvtOuRhXmkLuo3eAhGtoaJ
	 wiXDSHpizXUEqAO97rDQKeP4CWFpxpTw3uvjg4ztUX9YN1sSrhc7n1mfeJ55ISEVC/D+q
	 g9bCDULQ1LXk+F40sx7ZTbnSTFesrh10TWMLzSo5MJWhnt1VOrHhe4eRF96pencDAeNNy
	 Dly5XjEzL4p93pM73G6GuJtclr3lxHsK8oAJhfzpKSvO0lC4iA4FJOXc9xj3rOhbr5lnJ
	 fcZ/avfq7He73A8In/5alSv+OOPQ0ZoWoEFzK2uIKzSmis2AuwLnQoVFpkU5QpNUkRA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795011977;
	h=Received:DKIM-Signature:Received:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To:
	 User-Agent;
	bh=+HQPOu2vVrOracN1upWEQlhyegdam6XoIVCNFPCqT8g=;
	b=yrKDgQasZW6X7lQofEIF1SqM7XBqCrWPBXiGVh98+7ah484k2n+jN6L/VLbmlc7v+2PQ
	 W1dsltsSEhExXmOmYirI5rc7916At1aCZNJ1XEKyCfh7CCaBR4wxvcnlNHOJNwn+/Gc2t
	 prYYxU+BtJQEIdpSoyw6iFv1cDjjPbZBrSAwT4SlcUfYeHCAtmFPOLVsGupZceZ1ihE//
	 x1Dcr8fgOzWCmrnMqV0Cui7FUzq6aIWdenLwQZu5BUVSdIo3c0iTcfU7Wme4Ebcw8/jEQ
	 Ixv9Fl5+J9GriIrIsyFs8P+b4VJ7cksoOjKLxhJGrbNQp+sNvCsFiYEDaKQhSikLoSA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=b1YAsdmC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D990460A2617;
	Wed, 18 Nov 2026 14:26:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=b1YAsdmC
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3FDA81F000C5;
	Wed, 18 Nov 2026 14:26:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795011977;
	bh=+HQPOu2vVrOracN1upWEQlhyegdam6XoIVCNFPCqT8g=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=b1YAsdmC7his1/Eu4Z6hbYoA6zyoZmPZFr5zP19iQ+Qklq+pmJ+V3geLGfrvYWBND
	 92J5R9k1/53CBIk2/n3w0gSEu1PXrQeYlTE2b8x43kkQt6x5BdeGlTBHwCQg4qdelJ
	 rqwF53kW9bkQqbOLeQQ+KThU2o3F5NPIIJvp2GA5vYYUn/wn9X6YRyy9SusGvu+MxJ
	 ggNx2X/Z2afeJZZ7rPbJ1ulx8lIy8gOS0oKXOwXS+v7ekcnxA6kl2OKIPVtbs1YmxU
	 nUbJWhCUQkC833PQr2/g8xv+xfdUNSfcNuguKGgUs+FNnvHaHAsNvHkuLELWIOspR+
	 V41lNv7tgef/A==
Received: by pali.im (Postfix)
	id DB216846; Wed, 18 Nov 2026 15:26:13 +0100 (CET)
Date: Wed, 18 Nov 2026 15:26:13 +0100
From: Pali =?utf-8?B?Um9ow6Fy?= <pali@kernel.org>
To: koraynilay <koray.fra@gmail.com>
Cc: David Sterba <dsterba@suse.com>, Namjae Jeon <linkinjeon@kernel.org>,
	Sungjong Seo <sj1557.seo@samsung.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>, Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>,
	Paulo Alcantara <pc@manguebit.org>, Chris Mason <mason@kernel.org>,
	Yuezhang Mo <yuezhang.mo@sony.com>, Jan Kara <jack@suse.cz>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Bharath SM <bharathsm@microsoft.com>,
	Sergey Senozhatsky <senozhatsky@chromium.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
	"Darrick J . Wong" <djwong@kernel.org>,
	Sean Smith <defendthedisabled@gmail.com>,
	Andrey Albershteyn <aalbersh@kernel.org>,
	Pedro Falcato <pfalcato@suse.de>,
	Amir Goldstein <amir73il@gmail.com>, linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	exfat@lists.linux.dev, ntfs3@lists.linux.dev,
	linux-cifs@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-api@vger.kernel.org
Subject: Re: [RFC PATCH v4 00/10] add provenance time (ptime)
Message-ID: <20261118142613.be3r3s6kobkkxnz4@pali>
References: <20261115180343.576773-1-koray.fra@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261115180343.576773-1-koray.fra@gmail.com>
User-Agent: NeoMutt/20180716

Hello,

I have just one issue with the userspace API. It does not allow me to
figure out what is the source of statx btime field. If it is fs ptime or
fs btime because this RFC implementation is mixing both fs ptime and
fs btime into the statx btime field.

I have feeling that this is quite a mess in API and I would like to see
a clear distinguish between btime and ptime in the API, like there is a
difference in the fs storage.

If the btime is used for forensic analysis then somehow I would expect
that the statx would not report / not fill changeable ptime value into
the statx btime.

It would be really helpful if the statx API on inode can differ between:

1. btime is present and its value is ..., ptime is not supported
2. btime is not supported, ptime is set to value ...
3. btime is present and its value is ..., ptime is set to value ...
4. both btime and ptime are not supported

This should cover all cases of different filesystems and also allows
userspace to do proper backup of both ptime and btime fields (if it want
to do forensic analysis or anything else).

Pali
