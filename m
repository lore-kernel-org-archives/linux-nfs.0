Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BDEFD33B6F9;
	Wed, 12 Aug 2026 18:58:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786561087; cv=none; b=vFmbwjFy5Ht7TcGU05WdXjLfrKxc2h4ox5RpScZBFUlfFpdxPMk7193/NKsMwd4aLTkmSrMRsGuJJNGd6dJMZlVKuATEOg7WTbc1XZDpSQ4KcaMPpAC9v0aPEyOUCuAv0/pgtgp8ItbiYK+YceKRMgAGQ2IP8jOqSZbb0+dzMmw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786561087; c=relaxed/simple;
	bh=Vpc7UAbxApmKTkyFsou65P250aL9mVZg+o68rKTqwCs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=LaCoy+lupijDK8O0aIgXmfE+zt1Wp58/ogb3d65kBhJiFRM+fdE0RpJVfn4a/oj+MFuoY9QceY1dRu6FEW+GJVYGfA85chtsJbAA9q2tdgKD3KHfGgE51/4RBD1DbRDRRRrxrdPu35j2uoI/7yeCmtiRy2wlkUq+2zkIqJafgzc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LLLdUUGo; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LLLdUUGo"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A289F1F000E9;
	Wed, 12 Aug 2026 18:58:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786561086;
	bh=qozpR+PbQVbpMEhtpJrjTbXtzSyCFUOUuMymOoszJes=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LLLdUUGooJKik25jGrn16610ADb5GyiPp9Jr6h5ZzkQbl8/7l2+whqB1Z+xi2r4cs
	 6dnSLxUhx9+DRJZevL5IP8ixK9ESt8OEIBehdEqQwn1aL0smBIOLzuj9iYTz+bZp/I
	 w+9lYygnNbN8zs7iBw4a/aMstTa5idzaCai4BTiEnbVBum+OTcjB0ZYVsp7Cz4pnKy
	 i1Xs7hXAC6ziVxxMbb6EzHHFzKwjd1o/DutDUYB2aOVS4zudZyALfYy40Xy3Kxks+g
	 4jGCT2bUCozOi3MHXoySm0gYZUtyxFiqkmy5pVbFm7yYgzR8cwn5KixsXx9W3jYyQU
	 ItRdeWdIrncFA==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH 0/2] nfsd: don't use the xdr buf for temporary storage in CB_NOTIFY
Date: Wed, 12 Aug 2026 14:58:00 -0400
Message-ID: <178656102757.3199185.15214037321613191070.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260812-dir-deleg-v1-0-411faa713068@kernel.org>
References: <20260812-dir-deleg-v1-0-411faa713068@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Wed, 12 Aug 2026 14:08:13 -0400, Jeff Layton wrote:
> I posted a patch to fix up a sparse warning with a cast a few days ago
> [1], but Chuck objected and wanted to fix this by moving these
> (host-endian) allocations out of the xdr stream entirely.
> 
> This patchset should do that. Some of them are able to be moved to
> temporary stack allocations, but the mask fields need a separate
> kmalloc'ed field tracked in struct nfsd4_cb_notify.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/2] nfsd: pass caller-provided attrmask storage into nfsd4_setup_notify_entry4()
      commit: fced96df83e491cc182e9ec3ac6cf9234e705410
[2/2] nfsd: back CB_NOTIFY notify_mask words with per-delegation storage
      commit: de7051270554f99559f9b6bcf3c4fb695c7c223d

--
Chuck Lever

