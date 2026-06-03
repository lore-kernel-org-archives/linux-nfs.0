Received: from zeniv.linux.org.uk (zeniv.linux.org.uk [62.89.141.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E52D3D75C4;
	Wed,  3 Jun 2026 18:15:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=62.89.141.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1780510531; cv=none; b=MD4mnIDWeIsoClFrOgcgSUnaYUEJcTxsXUkl7P4+skDNO5ml3chubRKbtYa/QQjlq/qy3D2GZC3d8MK/V0Ncjm7zQ2VJ0HdPozLJfoeUza5hUGKY3y5jPUosvFBosubwfrTNuETGmyu4IOPVqe2ntANx1BnuJM7nq8auM18cAF0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1780510531; c=relaxed/simple;
	bh=jhwknV79Cned0+Im2nigFykt91JXEmDFlghbUVrys3A=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=MQYfxrt9/PpqP+fV2ikTOd0eWR01TRD9EqfsUx/v1szJuBfnSTJSpd6LpGa/m4QH8zblG5QldAzAG3NIRTxwdaPE+/u+iy/A8S8iJq5HvCvb1wmknBiYUsrvNrKOqCddXFAAXH+wLoj0TcsUdidWJ16pS5gYUeYMN9usDysiVbI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk; spf=none smtp.mailfrom=ftp.linux.org.uk; dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b=FnSafiUE; arc=none smtp.client-ip=62.89.141.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=ftp.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b="FnSafiUE"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=linux.org.uk; s=zeniv-20220401; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=v4fFxWZunMwECwBvp6piWj1PSNGn3csGHHdhyDGVvN0=; b=FnSafiUEE2DnYLY62RfG9sJSo4
	Ru2eaGJiv5tj9zOHmcH9bwFXEjGrW+umxS0KvEb0MAVxDNjX5P61vHpy956XZqjIKgZBghbQt/PO6
	tDGoCEukfj9WUfRGA4U8nnEUf8XJR5P/Jyu6ay6s6D3vzMg//1m3zIUH36zCIRRgvMAZ3mhjGAfxL
	AqokxkGD72zvW3P6noFew3+d1uPIwrgm5ZSyK4BOYDuaA8inPE+cprK5p6mVYbnVPso876OTp3NZ0
	XojbatUiQW0QEtYOrD/hvkNoApJRq6nMeNaOgV0VRVnAVdd5MhiBERfhFDVeXEYk+7WWJ1cFAg4bt
	2fm+lCtQ==;
Received: from viro by zeniv.linux.org.uk with local (Exim 4.99.2 #2 (Red Hat Linux))
	id 1wUq7f-0000000F3YC-2Ti3;
	Wed, 03 Jun 2026 18:15:23 +0000
Date: Wed, 3 Jun 2026 19:15:23 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: Jann Horn <jannh@google.com>
Cc: Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Amir Goldstein <amir73il@gmail.com>, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH] fhandle: fix UAF due to unlocked ->mnt_ns read in
 may_decode_fh()
Message-ID: <20260603181523.GW2636677@ZenIV>
References: <20260603-vfs-fhandle-uaf-fix-v1-1-ff64ee367e4d@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20260603-vfs-fhandle-uaf-fix-v1-1-ff64ee367e4d@google.com>
Sender: Al Viro <viro@ftp.linux.org.uk>

On Wed, Jun 03, 2026 at 07:38:06PM +0200, Jann Horn wrote:

> Fix it by taking rcu_read_lock() around the mount::mnt_ns access, like
> in __prepend_path().

> +	/*
> +	 * Containing namespace.
> +	 * Normally protected by namespace_sem, but there are also lockless
> +	 * readers (which must use RCU to guard against the namespace being
> +	 * freed).
> +	 */
> +	struct mnt_namespace *mnt_ns;

Umm...  It's somewhat subtle - at the very least you need to explain why
there will be an RCU delay between umount_tree() clearing that and
having the sucker freed.
