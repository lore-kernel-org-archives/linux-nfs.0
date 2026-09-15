Received: from ewsoutbound.kpnmail.nl (ewsoutbound.kpnmail.nl [195.121.94.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 191003AE1BC
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 13:32:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=195.121.94.169
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789479159; cv=none; b=gJgJpyfTVOIa2KtCo+AdYzeGbavfPGG/r384k8vGWmPcO8vRy1kf7cXct0UWD9pFi7PHWxf5d6nAwQJl77C1ViqTO/cu0HHKSukgAU+XocRAKQfwZDHZqYTkJFVrWeX4z7Kbsn3B38sF+k378c6sSXO6Ryy3ly+VMOXzwqf4NVE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789479159; c=relaxed/simple;
	bh=4J5wkfStdXV+KViExCn/2C9++h/Wi77TXxBcwbAxXB8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=dh84c2tI7xN0j6fIn/Y+qVUtn6sFbiR72+xTaiqhvAggBS/Hm+c4Bw3fCGo5aoSBVhnBof5Hmy9nEpKURR7nLNayIvNgRZtzNTrA+g8Ja2GqlYKohSKWIeaSOWgeaPfziwZmP0jzKl2o+7YvJVhTN44PqmErcMU0nFZYv9ZIWpU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl; spf=pass smtp.mailfrom=xs4all.nl; dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b=F3FuaIoi; arc=none smtp.client-ip=195.121.94.169
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=xs4all.nl
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=xs4all.nl header.i=@xs4all.nl header.b="F3FuaIoi"
X-KPN-MessageId: e4911faa-b109-11f1-a059-005056abad63
Received: from smtp.kpnmail.nl (unknown [10.31.155.38])
	by ewsoutbound.so.kpn.org (Halon) with ESMTPS
	id e4911faa-b109-11f1-a059-005056abad63;
	Tue, 15 Sep 2026 15:32:27 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
	d=xs4all.nl; s=xs4all01;
	h=content-type:mime-version:message-id:subject:to:from:date;
	bh=kHFqP6thrIscA/hswfbaE/kvo1Fomak31Fy2MfLJwYk=;
	b=F3FuaIoiR85Bd7z+XZWRlNsvY59I64akgGVihLuhuN+HFKc4ax321SQ8ifLw7G459qq897CJKb/3T
	 jPuMuBPsLEwxa0xTg0OfCmWVwN6+UOFbCJly4yvlGY776gOeQyLMlJ3vOjkm/gNr5fcjzPhq+F/7sw
	 vCLANA+aHfKbWcsSai4t7lMmG1pcil7zR12nOy85X131jcqKSfKQi9d1sfO34JtU2jLJoo1uJK1c9s
	 KeaaiiXDMdLPQwCaVIFzRZeXHgtRvcwIdbNW8LsJc19jR7f54yMc26SCeyURzHsKoN/LXNMj20Wb+s
	 aT2E4c6M4fibMo67nFLVcYjCuREzi0A==
X-KPN-MID: 33|nvKB7ZlE7T6XXhsVJmGkqPJu9hFHZM4UCWhUp0oNYi11T3hokxytVpkoOysbIxZ
 i93PpoNxejHqA9q1pM9JvStsxCDS8dPX6afWS+LBx5LQ=
X-KPN-VerifiedSender: Yes
X-CMASSUN: 33|PzwCQoSoYjI7OsQM5YAOJT8Yx82kCS6w25NbZ7qp5qiqVHPb+gdkjLnN45u9K3i
 X4SOUY05s7ewUGCJbp2SHTQ==
Received: from localhost (unknown [178.226.150.234])
	by smtp.xs4all.nl (Halon) with ESMTPSA
	id e4323a4f-b109-11f1-bd2c-005056abf0db;
	Tue, 15 Sep 2026 15:32:27 +0200 (CEST)
Date: Tue, 15 Sep 2026 15:32:20 +0200
From: Jori Koolstra <jkoolstra@xs4all.nl>
To: NeilBrown <neil@brown.name>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, 
	Christian Brauner <brauner@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/7] vfs: vfs_lookup_open() should only return -EFTYPE
 for non-regular files
Message-ID: <aqlHJe2Vten3JLSg@lt-jori.localdomain>
References: <20260910002934.192979-1-neilb@ownmail.net>
 <20260910002934.192979-4-neilb@ownmail.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260910002934.192979-4-neilb@ownmail.net>

On Thu, Sep 10, 2026 at 10:20:49AM +1000, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
> 
> Decoding the non-regular type into over-loaded error codes doesn't
> really help nfsd much and it isn't particularly elegant.
> It also isn't reliable as some filesystems may return -EFTYPE
> from their atomic_open() for any non-regular file, given that
> __O_REGULAR was passed.
> 
> So change to only return -EFTYPE for non-regular files.
> Also use d_is_reg() to detect this case.
> 
> Caller can repeat the lookup in the dcache to determine what sort of
> object was there.  This might find a different dentry if there is a
> race, but that is not significant.

This is just because you need compliant error codes, yes? I understand
the race then is not significant, because you were always racing already
here.

> 
> Signed-off-by: NeilBrown <neil@brown.name>

Reviewed-by: Jori Koolstra <jkoolstra@xs4all.nl>
