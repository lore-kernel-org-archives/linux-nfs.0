Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795196297;
	b=wT6krakd4izCEnzbSlrYbywDkDEvxOyC6tyqSqAaH/WZj119TmNUHMhtC6K8UeecjwU5
	 ywR2MXr0pjBO+57q/ei2WIZd1dOVJm4KD+Ua4qJbT/lLSJmsZP8Wb3lYOfkpVA4pb0XMv
	 /nTyeEkkBnZhujV5mg/Rk2wMfHjfKz7vcssIcBSgmfGS0dvPRgPKrBxozaFo6uiJi3Eap
	 za4027jbdBTrp2QCWJtTVbtZPRge8KfsCgjUTSulalDOAdJaEU/4Abmh+H5m/LH0I9mFT
	 C0KGUVMXCXM5zHNiJsE1sMyrzdXDuErWmBC8g1T8a4jROx0HIPVbRiKfiKZd/Gwwvxw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795196297;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=WpG8GZ0+ijh10faBuNP9llDtNA5OgcqJtGZ+Z8sydsw=;
	b=ZBqxIwknJq2+noeYCtHnLsl88M2VprwZ0je+vhU4ApT3gLibmJ1IbsXFsNfjacYVDDMe
	 SWimjvyFljtWkDhtA4KR7WFZNqdn2Vgxt7XWfFnAEXLumC/EeQZjZrX9n3AJKT068L3Jl
	 7sJkDP+McYjt70VhrhIb93itHD8mgcO5D8a8XDRNRS5m7tqlPw0okZkq4zDw/XiOIMTjV
	 e5BuVsmcjWoESSXOwvMmAbaYDxfASyZEhkW6+U9wrSGRRFf2n7Af5hDmMuAGF0JECjlpn
	 oImt4WjdkiFI44XDwphB4XvEfzVb/xnX0ZXMaU5GfaMp7U44HX+GEtXnK2xJ5kmaEsA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Tx0CH96u;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5C28606A325
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 17:38:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Tx0CH96u
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 26E351F000C4;
	Fri, 20 Nov 2026 17:38:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795196297;
	bh=WpG8GZ0+ijh10faBuNP9llDtNA5OgcqJtGZ+Z8sydsw=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Tx0CH96ulmLnXjQM/52qjEDThiWpOmNDZ9qCMzzeO9Y0+67xHY2jHG7vhEi9iK6el
	 WWIOqaxmftap2ljBmNCxo0elzsJvGwSUSC39rfWD+juWYDABeRelOx8oh4lzLUgE2K
	 kr70wopSFJRZm9k49hFZPT/IxZlEzwhyFa7iIhW/fPkFXrHewYj7lm8YtmkQthKhHX
	 u2w6sH+RY8Hsj/+DZR8E2wsl5bDWur0CV6fqdlWN29oIaQHa/GCqVveErKfPJDEH4L
	 3XGOhC2XjcKylpEEnL68Kd1YRZCMAFC0kbZQQWWx8r9iO1+q/TZmUlOTW99V2ifAHK
	 +s3USHmm5wDrg==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Dominik Maier <dmnk@google.com>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	dmnk+artist@google.com
Subject: Re: [PATCH] nfsd: only set RD_STATE in nfsd4_setattr() for sole TIME_DELEG_ACCESS
Date: Fri, 20 Nov 2026 12:38:14 -0500
Message-ID: <179519628521.17621.9761018337750842549.b4-ty@b4>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261119192327.2693868-1-dmnk@google.com>
References: <20261119192327.2693868-1-dmnk@google.com>
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

On Thu, 19 Nov 2026 20:23:27 +0100, Dominik Maier wrote:
> In nfsd4_setattr(), whenever FATTR4_WORD2_TIME_DELEG_ACCESS is set in
> sa_bmval[2], RD_STATE is unconditionally ORed into flags alongside
> WR_STATE before calling nfs4_preprocess_stateid_op(), even when other
> attributes are also requested in the same SETATTR operation.
> 
> Because nfs4_check_delegmode() accepts a read delegation whenever
> RD_STATE is present in flags, an NFSv4.2 client holding only an
> OPEN_DELEGATE_READ_ATTRS_DELEG delegation (and ordinary UNIX write
> permission on the file) can combine FATTR4_WORD2_TIME_DELEG_ACCESS with:
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: only set RD_STATE in nfsd4_setattr() for sole TIME_DELEG_ACCESS
      commit: f6100c1e9950cf6e18e142e75b5f96051ae0d5ba

--
Chuck Lever <cel@kernel.org>
