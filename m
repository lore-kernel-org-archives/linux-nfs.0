Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F268B2E65D;
	Thu,  4 Jun 2026 07:56:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780559788; cv=none; b=gjVxuKP6wCFUuLDveCxDTZZrVkAD7xe/RzWu6yIH4sI3Ndzk74/yGvUT2tbVaRCjs3tQ0PsPIqvcYGY3g0EG9wzV5VDtjJVra5s0Y+OztPPuTyqM+1Zi5EinwnWrirEtGFOb8y1JvK54+da9UBRrKRZ95Zih0U/hAjmb8pvzQt4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780559788; c=relaxed/simple;
	bh=5okoBXguTQpUNwRV89WZmaRvx9VW9Kn9J48WudylOf0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=FdeOXMznEcJun7pmD7xF6HRZVzdY/sM+NwKy5fkDOY/nSy6TlvbkyBo5z+dxoJd+WALetqtiAJoe/YWlRbudUOxgSFBl72EkqmpOvCc0LTuW39mVBzHjtL+r4LUL9OFDzkVSen2WAimyr0h8Cej1/8LBPlUvcEODVCC8+Gb+Jhs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dO6xrlsV; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dO6xrlsV"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F40051F00893;
	Thu,  4 Jun 2026 07:56:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1780559787;
	bh=gssK3Igts23GBW8l1/QhOpdL8Nb7U9OZ+p2rM8MYVDM=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=dO6xrlsVhSr/kXZNxLK6vc5xKYszLTR4kKXPt3qdBZdX/7Ix52OkT2TxT9d87uAMz
	 67UfSnVMuqha2Fz3fmZYqc2OzAdM9yMlBMhYq5txTxC2ziFEGiBuCGU0iCT84iJhlv
	 L2pQjJEZclQ6yKhpgEU4YRSPxZvKg3b1qBlIjQ2Ugh2ZWM/xseFjadiDjjqdyUszeI
	 ER5wwKBSLwdIZXPEm7WJRA6DRZicEsLIJ0ScpDPmhOcZaWOjXFbWE8XChkvqi3jTCb
	 IPFmdeHt9bcmfOCfrWPHCly5UyuIP0kybTriegilbA6Dog8wuZEXkXhmP/KTxuvvN9
	 HbbuelrXNSFGg==
Date: Thu, 4 Jun 2026 09:56:22 +0200
From: Christian Brauner <brauner@kernel.org>
To: Jann Horn <jannh@google.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, 
	Chuck Lever <chuck.lever@oracle.com>, Jeff Layton <jlayton@kernel.org>, 
	Amir Goldstein <amir73il@gmail.com>, linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
Subject: Re: [PATCH] fhandle: fix UAF due to unlocked ->mnt_ns read in
 may_decode_fh()
Message-ID: <20260604-vorboten-gebilde-entbunden-1c6652465d69@brauner>
References: <20260603-vfs-fhandle-uaf-fix-v1-1-ff64ee367e4d@google.com>
 <20260603181523.GW2636677@ZenIV>
 <20260603182454.GX2636677@ZenIV>
 <CAG48ez0Jte3UE8wn9Ljs3o2uVDFB24Zbp9zBdaj+D5c4R0+TSQ@mail.gmail.com>
 <20260603185324.GA2636677@ZenIV>
 <20260603190225.GB2636677@ZenIV>
 <CAG48ez34NaE5DCdC=VQWFRPds6JHwGq2YJDF5e6XUtGPNfQq+g@mail.gmail.com>
 <CAG48ez2kK2dB4Tva0aNdWphV6BS021A4bf6a_cu_yOEJ8Uy=PQ@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAG48ez2kK2dB4Tva0aNdWphV6BS021A4bf6a_cu_yOEJ8Uy=PQ@mail.gmail.com>

On Wed, Jun 03, 2026 at 09:14:25PM +0200, Jann Horn wrote:
> On Wed, Jun 3, 2026 at 9:08 PM Jann Horn <jannh@google.com> wrote:
> > (And there's also that weird detail of how, for anonymous namespaces,
> > the active refcount isn't used and AFAICS never actually drops to
> > zero...)
> 
> (Er, nevermind, I missed that anonymous namespaces just have their
> active refcount set to 0 from the start already.)

Let's distinguish a few things:

(1) generic reference count of namespaces in general: __ns_ref
    - for mntns: keeps the mount namespace and the mounts attached to it alive
(2) active reference count of namespaces in general: __ns_ref_active.
    - always a subset of (1)
    - only regulates userspace visibility of the namespace and has no
      lifetime implications per se. "active" just means "reachable from
      userspace". It's nothing that the mount layer itself should care
      about at all.
(3) passive reference count of struct mnt_namespace
    - keeps the mount namespace alive but not the mounts attached to it

With (3) you can grab a reference to the mount namespaces without
pinning the mounts in it. Then do other stuff that you want and then you
can grab namespace_sem which allows you to see whether the namespace is
still alive via mnt_ns_empty(). At no point does the caller need to
artificially prolong the lifetime of a mount namespaces by grabbing a
__ns_ref reference count. This is especially useful if the caller needs
to do a bunch of sleeping operations before they can actually do the
meat of the work they need.
