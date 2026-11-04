Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793818355;
	b=KIQSdW2GpKXCMxqPx1PXoZ26nHHpB2T51ShV5Z3dbz3rW+SysvhP4TJ+ZqfspvF54zlz
	 cECj7EH6CiU/8gGkPeg+gDJCRqmVpI1HGTIos9IOdyoyuDHTjJ3B9vs4/6/OBoIYhb1ku
	 5u9mHoExaY2K1CnoeC2NNALPXTRyUzzrGpxXTdbTPtafiQrBfR2x3mV3/yZ3tMET9d26Q
	 zC4U3dQyL5IYAPHCb0nlMO2mwd+dqYVZkQuJ1/GhoWdFSrFgCM5G+VfchrhYEh/94IxUu
	 Qg1uYSoxT1KtqSKrrs8Kb+JrtcvvG9iwz3rBbWRAGjnhDbH7mC/+d9bBVr+F3pz3/jw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793818355;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=4zBJElmewVqQvxer0r7NFF4wXHeb1cAhIrId66oRiqI=;
	b=WearPFIDqnNuF0CtAZQhjPsIM1tf3ZbLFFW4LDik/2J+gO3xRqY4lfL7fcBlM1J5C9bE
	 Wcci8UQlgkJgl/tGfjyOyi8cbK8gNzM80Ox9qhgYk0uyC8MVScJod0+nyOoelcroxgy3b
	 GSQI3EWQN9UHAJTBKzHinPajj5Nl/5Fyppsr5+4EQOTUqzCUtfUhqe/CvG7milNM8LpEU
	 +n9VVqqp3sNP4/6gos8rxhhgdSNrDFF6GegFaDVAdrrAnUgP+CiFIMohL3aOqDrXKTb8s
	 nh/UpjIbU/3z6GPmOl9SWuJrcPMGAQBd98TMChno1kYPwtqb5ctEQSnPIBczp662uZQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jfWPZzXM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 35919606A32C;
	Wed,  4 Nov 2026 18:52:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=jfWPZzXM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5A54E1F000C1;
	Wed,  4 Nov 2026 18:52:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793818354;
	bh=4zBJElmewVqQvxer0r7NFF4wXHeb1cAhIrId66oRiqI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=jfWPZzXMYPWmUQmoX5fKi8CD5Zt6a5iMFLZl3CPrcvu3LPWfX+XB09ABlY5meibUG
	 vnZ4JE2x60l/kaWoV9JxmJoFEMsoEy1BtimeHUXXWnDuLyXKhyTTyz2C/2QjDHgc9f
	 i3C2eut5K0aBQJI0pM9/awDQ4l9CqboW5NGuEIEwG1BndHe4vlkRR7JfCIpi/1Rq0S
	 uCSTPm8wEydfGc0E4t1b7CdP5VD84IOtSzmct6Zceh5F9RTzEnmga+zStlD2S3sDu+
	 1iTpS/5xf5omijP9sn8RROBVIeugCx956GQgtW+LGUmciF/WaJeV2gNpZBcsx1bitl
	 MH7qPEEckI6JQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 89EC9F40068;
	Wed,  4 Nov 2026 13:52:33 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 04 Nov 2026 13:52:33 -0500
X-ME-Sender: <xms:8X7ramMZtHGJ3A3lf5yc5WubAR37S401ccOs6C6dKZQquORJ03BMyQ>
    <xme:8X7ravyUUFWXQCRGf6y4UZ7QmIF8aNFyDBoilQAqHS0MaSfGWRVTLGTNV1oOp4zh3
    yUcIv0HSXncXqpbM_45Gka3RcptO5m6SNie8JekGTLCP6X2-fpAkKPH>
X-ME-Proxy-Cause: dmFkZTGXN/Mt/6+UKYWeIUhVeRjK8N1s9Xsqjx+ISwdggEXtg39O6sodkPEtjFnM2V5axO
    iM8JADVFiYM8EnDIBG1H2GuyVD7vZdG+CuHNQCWH9R05F/i/IPtxhgIKKfJOQy+81jO35Q
    fnzywM4X7aJ0i0QmGS4FJO0/7JLnr/cwihqwO3KOUSWacNTfog8FN9R0bukZ1yhxCWsPe0
    KaWBjErV+4pMHyfAmQN55zoQu08ElWvLKODfKciFEyPkmDFcKQQeUa9HSG24X/HviKqQ7N
    64bqweaK7FPm03fSZ0ZXBQIqqYVLkz5oSXDgFqv6Z8FiIDO/Pt98rvj77DXumuf8djqJI7
    WIEW0Yc76oy9JsaE90iWUukudmppmVdXoFs2GdNLE4C8wvhujntqIvi+iWbR2evIpkH2Q1
    B/1QqhnfpK8UgGHlyP6P/2+WcRNATaZogzxW0Us0eutiB4mxj7zJ44qpgmopED85Km5Hm4
    SrKyYXFNeg0ssF3YimQy7iNur3V8w/iSUy8knpuv9dF6fikRnlKZDd2OOFh28AJkDG7BtE
    6MjVO+Abb9GuCM0NtIOMp1fu+mthBq2a0/y4nn60e6sajqF8ggP2CAe+K69HUXkquSB257
    M7zT+2VKCfhwTBPGhTHMGWKMxgEOAOiMwPZe9ulv4fxX6e28wgLUWFBkLoEw
X-ME-Proxy: <xmx:8X7raluAejDJL5VN8yCyZmkKrs4hdLGAMIYFcmSfo6mchVIhOvUcLQ>
    <xmx:8X7raqdmFtIjvOJL5Be87mZTEA8jYpyWqGK-74UC-DY0RuzLLreRFQ>
    <xmx:8X7raq8Pe4r-aW9zIdU8fzfJ_dnv0P9OYsQlbElEhbcS5XltGHKUuw>
    <xmx:8X7ratTHhPASOWdOnC7O_SjoaAvl9ZNyRsEJrxLNqiPshl64h1jqzg>
    <xmx:8X7rajpin0o3EXvq32GNu0mwBDcv4VSIC2h3lT5UVmqJlfgid5oNiCFI>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 6239B78273B; Wed,  4 Nov 2026 13:52:33 -0500 (EST)
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
X-ThreadId: Av7Xq62OMXVV
Date: Wed, 04 Nov 2026 13:52:13 -0500
From: "Chuck Lever" <cel@kernel.org>
To: sariorkunemin@gmail.com, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <d2539122-2d86-4306-af54-43598f4aded7@app.fastmail.com>
In-Reply-To: <20261104-nfsd-cross-mnt-v1-2-5ec5fca0a553@gmail.com>
References: <20261104-nfsd-cross-mnt-v1-0-5ec5fca0a553@gmail.com>
 <20261104-nfsd-cross-mnt-v1-2-5ec5fca0a553@gmail.com>
Subject: Re: [PATCH 2/2] nfsd: check access to the export being entered when crossing
 mounts
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Nov 4, 2026, at 6:56 AM, orkunsari via B4 Relay wrote:
> From: orkunsari <sariorkunemin@gmail.com>
>
> Commit f0d6ad5a2f67 ("nfsd: move check_nfsd_access() call into
> nfsd_cross_mnt()") moved the check_nfsd_access() calls from
> nfsd_lookup() and the NFSv4 READDIR encoder into nfsd_cross_mnt().  The
> moved call checks @exp, the export being left, which the caller has
> already verified, rather than @exp2, the export being entered.  The
> sec= and xprtsec= settings of a crossmnt/nohide child export are
> therefore no longer applied when LOOKUP or READDIR returns its root
> filehandle and attributes.  Later operations on that filehandle are
> still checked by fh_verify().
>
> The same commit also removed the check that nfsd_lookup() applied after
> a ".." lookup steps up into a parent export via nfsd_lookup_parent().
>
> Simply checking @exp2 instead is not enough: nfsd_lookup_dentry() also
> serves SECINFO, which must not fail with NFS4ERR_WRONGSEC (RFC 8881,
> section 2.6.3.1.1.5) and did not check the target export before.
>
> Split the crossing into __nfsd_cross_mnt(), which checks @exp2 before
> switching to it only when asked to.  nfsd_cross_mnt() keeps checking,
> for READDIR and the CREATE paths, while nfsd_lookup_dentry() does not.
> nfsd_lookup() checks the resulting export whenever it differs from the
> directory's, which covers both mount crossings and "..", as it did
> before.
>
> This was found by AI-assisted code review (Claude Code).  The fix has
> been build-tested with W=1 only; no reproducer was run.
>
> Fixes: f0d6ad5a2f67 ("nfsd: move check_nfsd_access() call into 
> nfsd_cross_mnt()")
> Signed-off-by: orkunsari <sariorkunemin@gmail.com>

This issue is very likely addressed by patches I posted earlier this
week in response to a similar vulnerability report.

  - "NFSD: Check the entered export on a mount crossing" checks the
    entered export inside nfsd_cross_mnt and in nfsd_lookup_parent,
    which covers the ".." case that 2/2 also raises.
  - "NFSD: Let SECINFO query an export that excludes the request's
    flavor" handles the SECINFO concern the patch solves with its
    __nfsd_cross_mnt split.
  - Two follow-ups (secure-port policy, applying the entered export's
    credentials after LOOKUP and RESTOREFH) rework the same region
    further.

Let's set 2/2 aside for now, because the series I posted seems more
thorough.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
