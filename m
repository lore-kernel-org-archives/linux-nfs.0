Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 52836400E05;
	Thu,  4 Jun 2026 16:01:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780588894; cv=none; b=fwu5RhUBjVgotWSF3S7E3ssVjvUjPTshcnNkFq4PK2n68nII4syA8rBJzqDLlQumXBz/uv0Jz9DLYsMrjc1ueCwpQOkYXT0xp0IMu245EwrdqjotrYdkRdvNM5R/F1wbdEtHrcLNjX6TqRUH3f4p0CeGRlihYWE1g1ETVlW3asc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780588894; c=relaxed/simple;
	bh=sAguuISAhwj9wdW9qGOP8BaeZe/NDYghe39SPByZ3Mw=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=AFyLyb8IjeHCwSpV6IMnGarqHIAnUbGDd8Kwv+R5oFidF9JkbRmczOW9ElVx7F8eGP4FDGTH5FwvbIUgJwsI1noH2rr7LgDR/bbI/Z0H/VkbystLgwdjFy+Y1hwOxc6VRqwS8ZO1DynN+T6iC6qgPregS9mndbJLrRiYn9QQLxE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hKO5OdSt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hKO5OdSt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D1961F00893;
	Thu,  4 Jun 2026 16:01:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780588893;
	bh=Kv+/HslF58Fy27OdcBKmKh0bgHxCLMuK/hEHV8hue7A=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hKO5OdStWeM816WvgZQljY5qfqln5eA8jVYpX0NVkd9th3OUnfyiDdhuEHS/6iALb
	 x2oGgV8/9vdBrpu/vA/L2HZjNr6F6xTpQBp0QxJ/ptZan436ru55WoKru1R2HHF5ct
	 3XaH+yd/kzpf04+6/7SIooOa0s0cmchY6HgrGpDhGZUCJ4y26Fj3yh9lPOmvSuJ18d
	 Bkxofnn+hHqjYCskYCIU+cQeBTflZQDJNMKAvk4kYCZx1x9xt++/8jUedWJcqR5Qn1
	 N6VgK8vVKlc03D3c8jqAyG/ODD5U2lsOHmw468/hica6TgYrjxOMyeoAjwXSPZock2
	 /+mko2vEJ31Kg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Lorenzo Bianconi <lorenzo@kernel.org>,
	Anna Schumaker <anna.schumaker@oracle.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Al Viro <viro@zeniv.linux.org.uk>,
	Chris Mason <clm@meta.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Trond Myklebust <trond.myklebust@hammerspace.com>
Subject: Re: [PATCH v4] nfsd: close shrinker/GC/fsnotify vs per-net shutdown race in filecache
Date: Thu,  4 Jun 2026 12:01:29 -0400
Message-ID: <178058888122.189287.12247547978661030653.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260604-nfsd-testing-v4-1-3aeb1479c5bb@kernel.org>
References: <20260604-nfsd-testing-v4-1-3aeb1479c5bb@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Thu, 04 Jun 2026 10:31:09 -0400, Jeff Layton wrote:
> The shrinker, GC worker, and fsnotify/lease callbacks can unhash an
> nfsd_file from the rhashtable and then call
> nfsd_file_dispose_list_delayed() to move it to the per-net dispose list.
> If nfsd_file_cache_shutdown_net() runs concurrently, its rhashtable walk
> misses the already-unhashed file, and its drain of the per-net dispose
> list can run before the file has been queued.  The file then sits on
> the per-net list with no thread to drain it, leaking both the file and
> its associated state.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: close shrinker/GC/fsnotify vs per-net shutdown race in filecache
      commit: 2f8b2f5b13f99fdd76a434ab284e09dbc7afb212

--
Chuck Lever <chuck.lever@oracle.com>
