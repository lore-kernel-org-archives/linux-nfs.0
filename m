Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6323436402D;
	Fri, 18 Sep 2026 01:57:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789696648; cv=none; b=KOEnpHx66PBYMS+CnfUSvdpefePkY5aYxdwFki6jGYhE22INmTfLx9r47WOvGpo3Z90SImaIgVx/GeeOWgmc6V+LWkuGSKxf3hlZMzt4zBIbcspd87q/350ELk6vkBXgW8hw4Qz6nlPdabilkT2hprvS7IWjXAOedtniQUdwJRo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789696648; c=relaxed/simple;
	bh=hbQc0GaY6lOPoJ91KlEigJvV9nbhljbIUsgd1JVtgaA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=hrEtljq6s7RUAcwTRqA2ixuX6d8qNv3NJRdY2fKKvuRYapwI3oLqhp8oWV5iJNNLFEM1i8BOckLHHMmR+t/izNLSgsbEqgXyru3ZPg3imQ+AYQ2mlASNlE+epPLQKC85SjBhBtN8TlmJK+tHt9Txu3y9qtEay7UQfovDWbuVpR0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=IGJH0ybt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="IGJH0ybt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D43D51F000FF;
	Fri, 18 Sep 2026 01:57:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789696641;
	bh=Evdfruu4+Uyxd/vYv+YN9PpOxA3Bi31Qe6k7V+XBhZ4=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=IGJH0ybtJH355WJzEkGMYOPZ4Gvz3oNSI0qLXQWgpFDaaXWF35TvJXs96CnSMEk01
	 +SEfmF7fvKT2MkUuF7nUXM+xi5LWmi7mADDaSbKhHRsFtnpIV4ZrcJR6x8kOhhrhlj
	 zv1TY2fcmLliuCSgzruuViy6XH12nrBId1krrmydJc8RzfLetxh9ak7Eoa5K6PYlrV
	 SUuD324m2rTg9WiE984ycoAs70XhY3aCW4vEpsFtMVLPUNzMeJp1XHrFKTkJaoHFBp
	 IM9EcXkoqkq38G14kvsueQaImo2SFX1o+WjDYRosB1d6lNdbamLRjHRQOAo2RCl45V
	 M3/v/lDRamYdw==
From: Chuck Lever <cel@kernel.org>
To: Dai.Ngo@oracle.com,
	Wentao Liang <vulab@iscas.ac.cn>
Cc: akpm@osdl.org,
	jlayton@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	tom@talpey.com,
	stable@vger.kernel.org
Subject: Re: [PATCH] nfsd: Fix id-to-name cache entry leak in idtoname_parse()
Date: Thu, 17 Sep 2026 21:57:16 -0400
Message-ID: <178969662930.2341231.14504404156570226246.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260917163154.2162438-1-vulab@iscas.ac.cn>
References: <20260917163154.2162438-1-vulab@iscas.ac.cn>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Thu, 17 Sep 2026 16:31:54 +0000, Wentao Liang wrote:
> idtoname_lookup() returns the id-to-name cache entry with a new
> reference. The name is parsed between the lookup and the update call,
> and when the parsed name is malformed (negative length or longer than
> IDMAP_NAMESZ), idtoname_parse() jumps to the error label without
> dropping the reference returned by idtoname_lookup(), leaking the cache
> entry.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: Fix id-to-name cache entry leak in idtoname_parse()
      commit: 775ce3d60e25d646447e7ca6c0864b3abf658817

--
Chuck Lever

