Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 978E6202C40;
	Wed,  8 Jan 2025 18:52:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1736362328; cv=none; b=rIkn/bsegwrXo6I0KZ6Vl3cyuMc741otNpuVl3VTTSnJHfsTA/rEf9toRz7KQXaIbDb6vA7UOmY1aF7OUzzAxZxDWVYYgzr7TYrewcdybo96cVzuGzcawMPMt7y/2TxkKmWkj98E5GJaOXwS0w3KqJXOWFxUvuOHY5YBMlGpaug=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1736362328; c=relaxed/simple;
	bh=Dxq0AijgOWXwYeOA4ZjtM2pXlTORWOVqU6/zj3zzazs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=O9uSR6X8jMJHYMpdVbW7fsWZExt5mUC/5CyqilvEGHe2DUz1Zc2Cn2/Z3Pr7Jq04MuD4S2ay668DRhjx0S+Y5CXHHVbmphTEeoi9kKflUwPTiemkqsYJD8NaDgItBSMKJu4FJth0Cuo9Q+3dewC4equ9W17HVl/DwIMzggCWPXE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=B8Sh/8Qk; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="B8Sh/8Qk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EB897C4CEE2;
	Wed,  8 Jan 2025 18:52:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1736362328;
	bh=Dxq0AijgOWXwYeOA4ZjtM2pXlTORWOVqU6/zj3zzazs=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=B8Sh/8Qk7sXB2AFH8Fsdh+EK0lSgG72xkaprxR1pdyKVWoARn1fxOOI4nQye3GhWx
	 fc3SJDJ5C3uV0AJoVoQnIwNryEgpbyw71e7pACU7edJj1iS74tudr80ZbvX9A2Elz6
	 PJzBWEj7eBhyhwIsY6+F2FoJewFYbv0KSnB02nHPaGjcACfMh6Ff7eAA0ABK4YmIgY
	 OErKc2SfvW1SCPCUzBdLQTL39d4ZCKE4RVK6c9Jbh1b+0bIaaKEXW9XQE4L+ngBdAE
	 VHjhRCIy8YYyi2iXAcBzSQ9fjSG+BmUMxoQ6GNrWfYExFz5riLh+jTEjpuvmafAdnL
	 RtggGFWQ/RFGQ==
From: cel@kernel.org
To: trondmy@kernel.org,
	anna@kernel.org,
	jlayton@kernel.org,
	neilb@suse.de,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	linux@treblig.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs@vger.kernel.org,
	davem@davemloft.net,
	edumazet@google.com,
	kuba@kernel.org,
	pabeni@redhat.com,
	horms@kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/3] sunrpc: Deadcoding
Date: Wed,  8 Jan 2025 13:51:59 -0500
Message-ID: <173636224522.14442.16141044595756555843.b4-ty@oracle.com>
X-Mailer: git-send-email 2.47.0
In-Reply-To: <20241210010225.343017-1-linux@treblig.org>
References: <20241210010225.343017-1-linux@treblig.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Tue, 10 Dec 2024 01:02:22 +0000, linux@treblig.org wrote:
>   This is a bunch of deadcoding around the sunrpc code.
> This all removes whole functions/definitions/files
> rather than changing any actual codepaths.
> 
> Dave
> 
> Signed-off-by: Dr. David Alan Gilbert <linux@treblig.org>
> 
> [...]

Applied to nfsd-testing, thanks!

[1/3] sunrpc: Remove unused xprt_iter_get_xprt
      commit: 8adbba46957fb64315205ec7f2cacc5a1a37e878
[2/3] sunrpc: Remove gss_generic_token deadcode
      commit: 678651b2327102b4e45ad5e830f232c7da177762
[3/3] sunrpc: Remove gss_{de,en}crypt_xdr_buf deadcode
      commit: 515f416ca1c064c77100f2944a8c61add0e8dd7b

--
Chuck Lever

