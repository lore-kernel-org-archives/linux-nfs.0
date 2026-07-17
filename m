Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA58B3FE362;
	Fri, 17 Jul 2026 13:30:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784295040; cv=none; b=qWygHJbB/dzfWAOxQ5iyAcHu1uySZBK4ExNRYAtQ1/rOM57NrCo5Hasroq1up0SqqvXJE7LB44XcDooIcUPo0LU3YwkQ0WyGCSwkGsPOTrz+7LmxxDWZ2ky3q480yXTofWGRf9CAIPffTdmsyecbGiUiBS5/un0bD9b2UKZQV88=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784295040; c=relaxed/simple;
	bh=29pKVQceg99MEoof+gZBMKmC+qG5XFxgt67qyXzkKQs=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=GSJhlx7z97h+/VCQiF6OAdVunO+aJ3xzrGVK0+6pOBPIdHueYrZ7wb4N7VDBcaMi4uU6R+erosU6vnmeaJDMLGiyK9WkbTVtvwdGiY+8BHPqq9yOHR7m0IIQrWMs6/aOyAjiVFvmbXvw3ItPKYr+lbmNui8VACRLzSJV1Fw/aUE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gkIPXkFX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gkIPXkFX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 37BEB1F00A3A;
	Fri, 17 Jul 2026 13:30:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784295035;
	bh=Y3GeW2sIXn/OVMUQoat2kJR+EyxYE5jZKL/Rh4m3FFQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gkIPXkFXQV47Cp54a0Ef/8VLiSX7InqSAXd+m7fKHgLL4p7kulfXZHzANrC0iKbFC
	 cb8cmylIKkKH/yKCEonJSoNhSXEKaHQkve6yhzJYnO1M3Ol9VdphIgYdJ7DcR8tQna
	 oPuIiX/ZJxDFxZPKRA9NgVv1O96qPG+Gmmlq9vQDp3xHbU6bec3WTyACXk6Vwwog6M
	 LVNR32b/eSdyPw76rHUaH6F+YIutDckjPBUGpilYXlI2wB+MYCVxk9OYX4IUh+IM+f
	 7Kj7zrLghNQ/d+0EItkyPhaHVQ9IskTXEEPBxV96XnYCEaqmnyNAO5rmGTl9lRy8xj
	 rBkM3Qek6aMkg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jeff Layton <jlayton@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Steve Dickson <steved@redhat.com>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH v7 0/6] nfsd/sunrpc: convert nfsstat server-side interfaces to use netlink
Date: Fri, 17 Jul 2026 09:30:30 -0400
Message-ID: <178429502166.2709028.16160860800198876103.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
References: <20260717-exportd-netlink-v7-0-b7ce17b83b60@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Fri, 17 Jul 2026 07:08:52 -0400, Jeff Layton wrote:
> I last sent this series about a month ago, and dropped the ball on
> sending out a newer version afterward. This version fixes some minor
> issues that Chuck and Sashiko pointed out in review.
> 
> The nfsstat tool currently scrapes /proc/net/rpc/nfsd for server
> statistics. This procfs interface has several limitations: the
> counters are global (not network-namespace-aware), the format is
> fragile to parse, and it cannot be extended without breaking
> existing parsers.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/6] sunrpc: add per-netns per-procedure call counts to svc_stat
      commit: 99d92415bd4a11218abe303fc9e6c12fef392d87
[2/6] sunrpc: use per-net counts in svc_seq_show()
      commit: 07d348fc22493ddf7f195903b929ddae1dd0f533
[3/6] nfsd: implement server-stats-get netlink handler
      commit: 58656de1ad40362db64f5ac6debd2646b956fe1a
[4/6] sunrpc: remove unused svc_version vs_count field
      commit: 09048531826cc3a5b0baca029ce3e3af432029aa
[5/6] nfsd: count NFSv4 callback operations per netns
      commit: 5ce4d8f4b06b8f987b1cc88f13e8c1a1cf29db37
[6/6] nfsd: export NFSv4 callback op stats via netlink
      commit: 134cf2c7e0bc44e69d52d955bac1c2348a86832f

--
Chuck Lever

