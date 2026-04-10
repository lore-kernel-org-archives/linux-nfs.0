Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BD23A35E929
	for <linux-nfs@vger.kernel.org>; Fri, 10 Apr 2026 20:19:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1775852373; cv=none; b=UyYXJ+MuWrNGgqpFHLQvUCKt94a99IwwayJ7YUGofqmeAcE5vjL8cJeADuAIBwDOCOJf8/7KaVVgQAvjb0y5dxhXuzja66cIExiKfe7RQxRLGoLWmp7lCUSKBid4qV9HEV1ccDHWdiumNSi+16lZDnUBkq7yrfn1sNEhUMTx6RY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1775852373; c=relaxed/simple;
	bh=anx9oH8n+wxw5Afb9fuchdp7cu7WgGWLxkD13M/XXMU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=WxlhAovrqLfj3fTdNN8j/LXOo2Zmw5y4AQP1fZ88vB4bqNB4mIdFbAmUrQaEXw1sbuHKEeeVSPYN4vyNqRjpdJITnxOimCoLOjZEQi4S+xf2VROEvnkptxoQ0EIqyHEpxByGKlhhpJNLVyERXNIAq0tFFRTPZqiVujyuQohGfmM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=r8q0Agoc; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="r8q0Agoc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C0465C19421;
	Fri, 10 Apr 2026 20:19:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1775852373;
	bh=anx9oH8n+wxw5Afb9fuchdp7cu7WgGWLxkD13M/XXMU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=r8q0Agocg+88UOY0yKzvC4B7H0Z3cyvhwQysdBeO5imDqoRnJKo1tqdo60joMwAOl
	 dAvtKrDk9kVkM91QQg4tH5gBLwlAInTPJnPX1iM2QqFB4aQlF/JL3N3+32FoPZSEgG
	 wduSoEXvHM06bucnTQyrAy/lDzvZcjpmyYS9QXNBfGGeMIPiBZBaYn/xD9H7rZBb3j
	 Ysyl3SkQWAEi1LEcu6yhgDdH3D0vllQBgbsG7JUmX9lWZ3EB3xuik+31cznkkyvq+N
	 YP1HDXcBHI61g1ty/WBYBR3QruVRN1OFeAO2h8U92KTgB7rVY8gBa8DWx4itw9w1Wp
	 CqqVrDYsIcwoA==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	Olga Kornievskaia <okorniev@redhat.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	neilb@brown.name,
	Dai.Ngo@oracle.com,
	tom@talpey.com
Subject: Re: [PATCH v4 0/2] nfsd update mtime/ctime on CLONE/COPY with delegated attritutes
Date: Fri, 10 Apr 2026 16:19:29 -0400
Message-ID: <177585235184.1992986.5886959705627774468.b4-ty@b4>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260410160920.56855-1-okorniev@redhat.com>
References: <20260410160920.56855-1-okorniev@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Fri, 10 Apr 2026 12:09:18 -0400, Olga Kornievskaia wrote:
> generic/407 is failing in presence of delegated attributes and this patch series
> explores the solution where the CLONE compound returns updated mtime/ctime
> in the GETATTR op in the compound.
> 
> Both CLONE and COPY need to update destination file mtime/ctime
> (in presence of delegated timestamp) when file was modified.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/2] nfsd: update mtime/ctime on CLONE in presense of delegated attributes
      commit: a7f570141bae209189f05fdff295f67fe84dd183
[2/2] nfsd: update mtime/ctime on COPY in presence of delegated attributes
      commit: d0814470307048890b3cf6c8b373815f0b8cd64d

--
Chuck Lever

