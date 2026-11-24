Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795548593;
	b=h8duGJXG8aLFeeyt0br0yMq8Rgg0WWWC+gtug0A3U0Wk23lhXltg6LvYr1L1QmPD4Xlx
	 c7Lei8gzH8qZIoO09Ec/g0itSlAYMyvxv8pMz6U00SX8gOIXTk41ELdyI+2EDroZ6LmGC
	 E6UpZ2RQXQRjmy5C/aeaF5uftH8NMefJVJHxpamyHFBdfG1Xof+d+eKZt8eWBxJwXzw8T
	 QB11YruLhKsDpt076MwKQV3UN+Gojr3E4Palbc3uEsX1mnMAwDy0zGh+3ueybR0Lw2cq2
	 xdh4Yp1NsAEvAecZ+1THQMU6Lo0OsogtUQS6L4iMJqN1G1kSnRaNSEvJGTiK3YWA9bQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795548593;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=JKCRNsREQLXm5F17UquQcc6OSOFSGuVeEBdwvHauNUE=;
	b=Uy4RjC9JU1xVB8FT4Lja/bBNJO5kN0uhYMGuTyJIotYIgcKp6p7BX5huvvEwEfCLadaM
	 scwZcCiId3a/F40kZMkHTfgulPjBR1V2pDAIRkdETEaGfFrFRk20kFsq1oJrgQ+AOGzE1
	 1E+q4xD9yfT5lHUelOQWxwfh8piYUCZxBjf87k/+6gdiBOuwQtHRajpXwR95BeBiFtTuF
	 i0P0dIFX3KoJZfLohRlbFMSW8OpVxDZvevOKDe9RdtPQVLXb2v6Y37lzrDEprPjISrDKw
	 HfHkxNAbxqmnVJDXnTsj2/6q2E9lKFlKpON+HCA0UTE2ZbobjLgl6cs0HH11uciFN6g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nCDBFvzC;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BF65B606A321
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 19:29:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=nCDBFvzC
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1256D1F000C0;
	Tue, 24 Nov 2026 19:29:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795548592;
	bh=JKCRNsREQLXm5F17UquQcc6OSOFSGuVeEBdwvHauNUE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=nCDBFvzC8FExYqdoKy3jLjMJqTvOU1hLZOWvoOC039xjpLo1dZNHc23IulIhMwAjJ
	 psYdUivCu3IrmhLfqGD7DWTGW74HRS78nE8y9Tvb6rDUm7FU0712Wm3XVdnYjHxYmh
	 c4Jd6+9IzfQHFXcvo85OWMoJHOMq1X971/B3qXYM5yu9FAXr+m0JDx5x0TVj2aAIZw
	 x+Khb9y48qNKi/2Muc1NG7D9JwGBLzPOKXDto6ShRdWSGGE0OGo5h2gf7bYT9dqXZS
	 xhoTKUNAe6UHQb+lMWusevyu0+Ba6Rwf+iSwcu3RynaPgALnbNfw4JgiNvXk89tqhm
	 0WTL+O+21KEfQ==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Marcin Krystianc <marcin.krystianc@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Accept an empty access ACL in NFS_ACL SETACL
Date: Tue, 24 Nov 2026 14:29:48 -0500
Message-ID: <179554858409.1415929.8449350335335047400.b4-ty@b4>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261124132421.3698977-1-marcin.krystianc@gmail.com>
References: <20261124132421.3698977-1-marcin.krystianc@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Tue, 24 Nov 2026 13:24:21 +0000, Marcin Krystianc wrote:
> The xdrgen SETACL decoders reject a request that sets NA_ACL with an
> access ACL of zero entries, and the SETACL procedures return
> ACL3ERR_INVAL or ACL2ERR_INVAL.
> 
> The Linux NFSv3 client sends such a request when it creates a directory
> under a default ACL and the inherited access ACL is equivalent to the
> mode. posix_acl_create() then returns a NULL access ACL and a non-NULL
> default ACL, and __nfs3_proc_setacls() sends both, the access ACL with
> zero entries. mkdir(2) fails with EINVAL, although the server has
> created the directory. xfstests generic/319 and generic/697 fail over
> NFSv3.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] NFSD: Accept an empty access ACL in NFS_ACL SETACL
      commit: fdee166138c2eaaca10824ef28cd50c657295147

--
Chuck Lever

