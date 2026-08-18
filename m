Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3261445FFAC;
	Tue, 18 Aug 2026 17:57:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787075827; cv=none; b=TSk0Q3gtWwtSESkGrv6gXp2+JsgqOv50zw48zOfV26VN0brw5f/UJQasp9F0poxHHCmIYFdNUHAHcS7znwL2RovBBF7TQM8A05L/z2filMMcGiyK9hbm63YGIpv+RXy2MWRjDRv7zC4fYf93rgbTMNxcPjzELI3onMdk0G0nxDI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787075827; c=relaxed/simple;
	bh=RY3cxw/KA5bkPabXW9t+2Jd97WDLjpfqotR2fUOtZBQ=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=tuXl/3RIYuZY02NWnk7qMZd/kkfzrxVOjztd6xGKq1LT12Y6q2bFswjiw7RNQ/VTaqZXmJk3kCcWAgL2OqicRZpdXUVT97csQ8pBsTJWZTFAsyV/NDNF5a3KEr/uCHeQSQeHLZaMuCbOc092jZDgH/Z9s8zIpStBOJd5El+7gww=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XtCDDDJ0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XtCDDDJ0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CDAF91F000E9;
	Tue, 18 Aug 2026 17:57:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787075826;
	bh=RY3cxw/KA5bkPabXW9t+2Jd97WDLjpfqotR2fUOtZBQ=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=XtCDDDJ0yCcKEwMm8YxaUju9Z8Okun0RVZOinHt9cgs2pgvhoATL+l0dBn000bn4M
	 +Gh5exndVBlsSOtN+OExVHvdqerLG8Yppw2DRPenNzPKStn7QAnYTFA+867OXXoBIe
	 BqWEDSUxlIqsiVWeqtFYhgHo1m5dRAo3SM/0sAqU0cgoWOPgfQg8yodUzMfwrdvp4v
	 Cg+7poP9KDESJeGRW8tWjWPbUV/Y3qKkVC9EIoIQUh+4sOKY9rwdg62cn2USKONSi3
	 rGvSwgo/ylchAWGHKh44kvQaquNDqcA55QP3FVUPenavyZRI2JLJ8pNUb3eAWd7Anl
	 wZPON0ZZZZSoQ==
Message-ID: <ee96bac85fec2cf59adfb3d4ff54182c8260f6cb.camel@kernel.org>
Subject: Re: [PATCH] pNFS: Check lseg validity before marking a layout for
 return
From: Trond Myklebust <trondmy@kernel.org>
To: tmenninger@purestorage.com, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	stable@vger.kernel.org
Date: Tue, 18 Aug 2026 10:57:05 -0700
In-Reply-To: <20260813135834.22278-1-tmenninger@purestorage.com>
References: <20260813135834.22278-1-tmenninger@purestorage.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Thu, 2026-08-13 at 13:58 +0000, tmenninger@purestorage.com wrote:
> From: Tim Menninger <tmenninger@purestorage.com>
>=20
> pnfs_error_mark_layout_for_return() receives the lseg associated with
> the failed I/O but previously used only its I/O mode, operating on
> the
> inode's current layout header regardless of whether the lseg itself
> was
> still valid.
>=20
> A layout stateid can be invalidated while RPCs still hold references
> to
> its lsegs. pnfs_mark_layout_stateid_invalid() clears NFS_LSEG_VALID
> on
> those lsegs through pnfs_clear_lseg_state(). A subsequent LAYOUTGET
> can
> install a replacement stateid in the same pnfs_layout_hdr. If an RPC
> using one of the old lsegs later reports an error, the current code
> can
> therefore mark the replacement layout for return.
>=20
> Once NFS_LSEG_VALID has been cleared, the lseg is no longer eligible
> for
> selection for new I/O and must not initiate another error-driven
> return
> of the inode's current layout. Fold pnfs_mark_layout_for_return()

I strongly disagree with the above premise that NFS_LSEG_VALID should
be used to gate layout returns. If the client tries to do I/O and
fails, then it is required to report the error, the type of I/O, and
the byte range to which it applies.
We attempt to redrive that layoutreturn as the outstanding I/O requests
fail. The EBUSY is there to ensure that we don't fire off the
layoutreturn until all the errors have been collected.


So NACK to this patch.
--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
