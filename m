Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 840DB298CAB
	for <linux-nfs@vger.kernel.org>; Sat,  4 Jul 2026 17:42:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783186927; cv=none; b=j4aXEdM2kyGTJ41/ia3HHeIaI81bnlYueH4cCZpIizpAWXMlHwaTAVOMuoNhdB7YHmUtTEtYksKbSWUU8f7+dxg5Sk+cTFeFULmZNzcUAgl9ljx7V7qHIxhCRiD1Ln3F9jWFR17D1jpJloWDZpbRRANKZdqXDQY1wGBe6N+XtJg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783186927; c=relaxed/simple;
	bh=nh6kFZpzJN7n+RZRkhx1IJJ/gVtRkueABnba7qgkGQY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=iUrHBU3d0YqiR3XtBUtxBVQFqB3+1pl5pjb4tj9oOqt0BLsD3UstohzA/DQHTpuRtdDmpc3ZWNNOHn2uCWrB0VLgUzZlXa80MDY/nCakhIviZP2H3b36TfY2VJbcdWQUAykFfPo0XEHbMDtLPOZXHRNe4+vlRkez0WjV631qHw0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MKQLsSEf; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MKQLsSEf"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C72711F000E9;
	Sat,  4 Jul 2026 17:42:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783186926;
	bh=d54CLJIu9+biFhkOSXVv1yEdICOaDbVRDk85s7zWt10=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=MKQLsSEf9gUm+jKYJ1qFYRkmSfZqRAmkGkKo/ITkx686oXvu76z82+5xnuMqLbdjv
	 2fL/RmWXasyZOEQO46Fv6Cpst0M44tYYJQbvr1rth9SA1yYyzib4IV5O3I4iRuv0Eo
	 ubrlain21ebGPmwMKiqhRroBMgdajiNA0BgKHpXuzppliTYKVsCpbI3Mjg0dj3ZhIC
	 Mu8Mn1moIrVOwh1OeaY3JF+kDapbkIooXHnslLcsKLFKgkUevRJr/TIuoARKFDEyvh
	 QvA5mKL1qkytiEr5ch+cKii2bZ5fBnphioJbOd/oAJ3qngMpbLUTorxMLP4+D1izIk
	 l6lQfD5zG9lmg==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	Oscar Ou <oscarou@synology.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3] lockd: preserve multiple NLM_SHARE grants from the same owner
Date: Sat,  4 Jul 2026 13:42:03 -0400
Message-ID: <178318668544.3488896.1908137356659270173.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260703063856.2423734-1-oscarou@synology.com>
References: <20260703063856.2423734-1-oscarou@synology.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Fri, 03 Jul 2026 14:38:56 +0800, Oscar Ou wrote:
> When an NFSv3/NLM client issues multiple NLM_SHARE calls from a single
> host for the same (file, owner) tuple, the current implementation
> overwrites the recorded access and deny modes with the latest pair.
> A subsequent NLM_UNSHARE then drops the entire entry, even if other
> grants were implicitly subsumed by the most recent SHARE.  This is
> particularly visible to Windows-style clients that map each open of
> a file to a distinct NLM_SHARE, all carrying the same NLM owner
> handle.  For example:
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] lockd: preserve multiple NLM_SHARE grants from the same owner
      commit: c8c45fb61a5ff3eb786e4aa434b534b605ab657e

--
Chuck Lever

