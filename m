Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4B4CC3033F2
	for <linux-nfs@vger.kernel.org>; Tue, 10 Mar 2026 14:53:57 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1773154438; cv=none; b=X69/Rp1j5rXc+vtktJiu/4d54gZ8RHD44kDNmXTvkEYntnrj2x2IM2vg2VqZUw0xaJB2OCCAK61qXfrswCPpLTY8LpelrqJ+3rHsh0oW/35mQnd+XIMEDor1RmOhe9l/AZpxVV4FC+zNFIQv4gz6IKvQZmA++ETvsoyuXvkQ7UU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1773154438; c=relaxed/simple;
	bh=F02IUkidu0xypRH0tsk9l+p5Ofjor/zuj7ObzwI9id8=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=XM3wlucdeyqi3iNacfxP4g/QCBBNSi4Xt1Isy0NX3zCNJeWmvhSdQLPvHP4V+X3W8ttVl3b0NgdUAQfobCJN79bJ44ptO3xIvodSoPS9wpAWwr02tf57KklEgdpUZ+OOq7RdiAzwNjoqz1zu4jj2MngBx3XM6WYDP9OusPHSFZk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TqaF7Wa9; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TqaF7Wa9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2AC13C2BC9E;
	Tue, 10 Mar 2026 14:53:57 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1773154437;
	bh=F02IUkidu0xypRH0tsk9l+p5Ofjor/zuj7ObzwI9id8=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References:From;
	b=TqaF7Wa9S5PDqpLtmoiWzdgbtm32Ix7Huxh0ib8WiMXHqgd1GiB3wA1Dd3FKfx5E4
	 vAiMJWbUAdQt18AtEyM+NIw57ehkwIqiP6+yUKNDgdLy8PiGxpWxl5pEoHHdsAdN0D
	 qFSBtDbF2OA8JZgwoA/4rEIgxT2Qgo3rrQS3TzmAm/SjUMxeR1n3Pni+HZlJLZbi1D
	 u3hIJe59xzLn+0JXsUzt//CfppE19Qm64Az6z+74/a18x3TCZNzD9B8ueMh857cG95
	 ik9T+/VM6gGzZtu/FYHNGQLqPoJbJummVVM4hAwOCH2zydoLnsT3Pdy69sRynp5ECb
	 TnFH74V01RCWQ==
Message-ID: <1c630798e0c931310f86f636abe84a72b86f7aae.camel@kernel.org>
Subject: Re: [RFC PATCH v2 00/11] NFS/NFSD: nfs4_acl passthru for NFSv4
 reexport
From: Trond Myklebust <trondmy@kernel.org>
To: Christoph Hellwig <hch@infradead.org>, Mike Snitzer <snitzer@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>, 
 Anna Schumaker <anna.schumaker@oracle.com>, linux-nfs@vger.kernel.org
Date: Tue, 10 Mar 2026 10:53:56 -0400
In-Reply-To: <abAb8NYJECfXkRLg@infradead.org>
References: <20260224192438.25351-1-snitzer@kernel.org>
	 <abAb8NYJECfXkRLg@infradead.org>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.58.3 (3.58.3-1.fc43) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Tue, 2026-03-10 at 06:26 -0700, Christoph Hellwig wrote:
> NAK on this whole thing.=C2=A0 Linux does not support NFSv4 ACLs for
> pretty
> good reasons.=C2=A0 If you want to add it you'd have to do it properly
> (even
> if that is a bad idea in my opinion).=C2=A0 But adding a weird special
> case
> for passthrough is a no-go.=C2=A0 To be honest I really don't understand
> why
> your (as in Hammerspae, not you personally) want to abuse the kernel
> nfsd and nfs client for that.=C2=A0 If you want to pass in the protocol d=
o
> it in userspace without burdening the kernel with it.
>=20

Like it or not, Linux knfsd _does_ pretend to support NFSv4 ACLs. It
does so by using a (lossy!) mapping to try to convert the NFSv4 ACL
into a POSIX style ACL.
This is a problem when you're re-exporting NFSv4, as we need to do,
because at best it mangles your ACL. At worst, it throws random error
codes back at the client.

So Hammerspace does need that passthrough ACL in order to have re-
exports work as expected.

If the upstream community is unwilling to take patches to address the
issue, then we're quite happy to maintain the code separately. It will
still be available to those who need it through our github site.

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
