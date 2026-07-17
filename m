Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6E4203FFF8E
	for <linux-nfs@vger.kernel.org>; Fri, 17 Jul 2026 13:30:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784295051; cv=none; b=dij1Lro9WVtObVoecyVDZxDOTMGpAVT32abv04ZNRtLXhww7ZF1LvkZz7xcpK0zTasY+Nt9HahyacGYiBz7WCWVy31aJrFWngl1jS6FZh0DrGGD0PlXKb5+vJcC/d2j7w00d7k78lPl55pxbvWO4cIIJjDIgBuUlYSHB6tCywn8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784295051; c=relaxed/simple;
	bh=v0i26vEgOT/0+Pe7G7LgMQPo1C9fdFYL4UvMENdRoDE=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=MezWobzqJE86ZOIMx8g8j2kNC+mzJQX5kal76ARZIjphQUulRNeZkhQLIRS/dmxoM19iDDAw5Q2gQOGJKpiK9xyg72Rdj/ys1AvhYoBhTR/lLsUjrIJWDlHZmSRtKTDV87dSuDibI3m/VL1LpB2uk0WV3DXcFnIbc3+dNWc/0sg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=NiZbjn6/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="NiZbjn6/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7D4391F000E9;
	Fri, 17 Jul 2026 13:30:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784295050;
	bh=nkdBIGecpJClDSBpruXj9/zAlDn9j9OVFyjjLw/EPp0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NiZbjn6/Dg1mY4W5eIC7vFrnf77inFasW/lmNz8pvfxKuvgfNMxIZD5uLYZDqY6z0
	 vNF8QBSidr/eWqlSh+ZZpjsEmwB5dvVJifExWL/FpksvGysYnrRA9EH/CycVx8Nnw3
	 VApQb5NoqUIKlF3lk+Ofa5KMkt/GxXUYvG9vysXDFxtNhEvz2qRlWkpAlMhu89SFQD
	 Sslo8nuQpgjLwO2NUWyIQa0eDTGRy/SSw8nwF1WXk9PR7kV5QPm71kbACw+ffZOPXf
	 4ArPl2GjPnp+TRnJ9n9g0ANt8loSSj5F6Tcm3ONo+UhNLE/h11VtI2CZqzSyFIMaDQ
	 P6tOIwY7JzNrw==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	NeilBrown <neilb@ownmail.net>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v5 00/18] nfsd: refactor nfs4_create_file()
Date: Fri, 17 Jul 2026 09:30:46 -0400
Message-ID: <178429502167.2709028.6167445375170866097.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260717093001.1972119-1-neilb@ownmail.net>
References: <20260717093001.1972119-1-neilb@ownmail.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Fri, 17 Jul 2026 19:27:48 +1000, NeilBrown wrote:
> For for another version so soon - I hadn't noticed Jeff's LLM results.
> Most of the issue raised there were already addressed I think, but the
> using  nfserr_noent instead of NFSERR_NOENT, and adding a condition on
> the call to mnt_want_write() in the final patch were still needed.
> 
> Thanks,
> NeilBrown
> 
> [...]

Applied to nfsd-testing, thanks!

[01/18] nfsd: honour client-provided attributes for NFS4_CREATE_EXCLUSIVE4_1
        commit: 0ac10ed2eadf239b8322acdcf9e6b1560c28789c
[02/18] nfsd: move check_nfsd_access() call into nfsd_cross_mnt()
        commit: c4fcf4eb1c1c96519959585f5fbec5ef38dfab4d
[03/18] nfsd: correctly handle CREATE of mounted-on files
        commit: d50cf4faa7098f1e86e9300e71f81ec543daae3f
[04/18] nfsd: replace fh_fill_both_attrs() with fh_fill_post_noop()
        commit: f2f9c31c20a94f7d99da2629667bfb85ad0876a8
[05/18] nfsd: move fh_want_write() after preamble in nfsd4_create_file()
        commit: 130835c9487dfaff092761d6df1129b7a962c111
[06/18] nfsd: move more nfs-specific code into preamble of nfsd4_create_file()
        commit: d2d28891fbfad5c68a3de28fad87ed7ab3eaa915
[07/18] nfsd: remove subtlety from nfsd4_create_file()
        commit: 5c40d90d8bd3bd552b4ac2a11a81418d209fc2ef
[08/18] nfsd: in nfsd4_create_file() let VFS report if file was created.
        commit: b47e34213946cb6210010648fd9e598291b649bb
[09/18] nfsd: nfsd4_create_file(): Move NFSD_MAY_CREATE check earlier
        commit: 0dff1ebde230f9bcc7abc6cbf6b7539e3ea3f616
[10/18] nfsd: fh_want_write) failure need not be immediately fatal for nfsd4_create_file()
        commit: f7f56f21ff446625dbcccefaeab95d2fda4a3ada
[11/18] nfsd: (almost) always open file in nfsd4_create_file()
        commit: a2b9f05a9aa76978ce4cc0131ff2691baa872b01
[12/18] nfsd: reduce range of directory lock in nfsd4_create_file()
        commit: afe7358ca88eeb3292a8933a139acf1c9e7040b1
[13/18] nfsd: open-code nfsd4_vfs_create() into nfsd4_create_file()
        commit: 1233ae38bcc77a4107b0121004de2e3c6340f2b6
[14/18] nfsd: move some code out of the d_really_is_negative() branch in nfsd4_create_file()
        commit: e6bd2126f078bd0fe3dbe7b804d5c3d3a6fdc23f
[15/18] nfsd: reduce want-write range in nfsd4_create_file()
        commit: dfe0dd04a90fd1c6a2d1db2b605d7da8068a7934
[16/18] nfsd: move v0 checking out of nfsd_check_obj_isreg()
        commit: acf95a02c3d3d32364b91f6e5f938638addc7a68
[17/18] nfsd: separate out VFS-specific code from nfsd4_create_file()
        commit: 385074f4868b4ada9c5cd72a53e24e445b97a5e3
[18/18] nfsd: use do_lookup_open() for non-creating open requests too.
        commit: 71349ee933edf67b4dae8a2b68398da2471284c2

--
Chuck Lever

