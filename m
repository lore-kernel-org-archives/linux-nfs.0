Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D14003B4EA9;
	Thu,  2 Jul 2026 07:44:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1782978266; cv=none; b=D5wroQqQ9FsbzheIIymscXgtzHLR4vBZBMJu1IiSkVJYaaUYJ7H0q2dLC/bZC1w9WOA1gU2irGb1VD+6Rk4fghqCImpgU9QgpyoOEV4rbi7dO/lP75Px0j8AnGyZapTPv/DuVet2Fr48YfxEtDsybl90pzyuV2b/cgc+4Ejze7s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1782978266; c=relaxed/simple;
	bh=86OvD4fbRP1MhaFrjiWmHql7uPFq7+n64G79hRC1syE=;
	h=MIME-Version:Content-Type:Subject:From:To:Cc:In-Reply-To:
	 References:Date:Message-Id; b=ZmF4hiPQFHslRGBF4qJfSGLATfVcgzXm7/qFG0/vNZLvFAoRTAOIkmwi7jB2k1rUmIWpvnfoc2RHJaGGHhcEWGHhADt3ligbVFz4FbG/CuWr8vKfk8b3bU2Jx2Ho4/WhToqTv91Gv3Pf7YW7EvGzUYk/TutRfIeA/kH//NTV+gc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZdKpHwc2; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZdKpHwc2"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 13F841F000E9;
	Thu,  2 Jul 2026 07:44:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1782978262;
	bh=pw7UB+las03Zd+n0XXxB46auuLv6eyuJTUsh0sXoIck=;
	h=Subject:From:To:Cc:In-Reply-To:References:Date;
	b=ZdKpHwc2j42OHNqT6vySAGjYzBtQ7zSona1+PlfNEsIOXJYT2WxO89xvARtVfCenO
	 90FAp5/2D0wzbkCDmUPenZRdJhzKu3UqFdPQR1xTkxbIeIoVrp4NoGSPvV/LAWAY/+
	 13LDx8rtoqw/x7NdwEXxIS7KOLLOHt9SBUYjc7OSF/kMxtazINW6JhtXf0Bd7Zfz3l
	 r3N5CBpGUTT5oZgqEfAqxjKD/BAz5Qd2ETtUm2GAZUmipaaZKnc0/rpnKUifjRqAJB
	 w0DeFz5B4+ov2oczSldWfH4T/IC6OVdOuIOR4mQksiq/t8mzN/EJLaHVKnLZvcuoXg
	 5AawwGEY4Kkog==
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH/RFC 00/18] VFS/nfsd: replace dentry_create()
From: Christian Brauner <brauner@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: Christian Brauner <brauner@kernel.org>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, Jan Kara <jack@suse.cz>, 
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jori Koolstra <jkoolstra@xs4all.nl>, 
 Benjamin Coddington <ben.coddington@hammerspace.com>, 
 Mateusz Guzik <mjguzik@gmail.com>
In-Reply-To: <20260601070042.249432-1-neilb@ownmail.net>
References: <20260601070042.249432-1-neilb@ownmail.net>
Date: Thu, 02 Jul 2026 09:44:17 +0200
Message-Id: <20260702-kurswechsel-grundlos-erdteil-27c448aef1ec@brauner>
X-Mailer: b4 0.16-dev-4217c
X-Developer-Signature: v=1; a=openpgp-sha256; l=1395; i=brauner@kernel.org;
 h=from:subject:message-id; bh=86OvD4fbRP1MhaFrjiWmHql7uPFq7+n64G79hRC1syE=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWS5iV1+tWCqwHXtvdvOGOrfK3RIcHy7IuFwJ3tQ/MFUz
 wUcamyTOkpZGMS4GGTFFFkc2k3C5ZbzVGw2ytSAmcPKBDKEgYtTACYS6s/IsPPxiVP+Zv9n/b3x
 bHXZ+1MNRwOz2rjlS0Qfz/DqDON9vIvhf/i3kFt68w8EJHrsnMLx/uyZG1mrqjS6dCynL44xCe/
 QZAMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

On 2026-06-01 16:37 +1000, NeilBrown wrote:
> My recent proposal for inverting the order between inode_lock() on a
> parent dir and d_alloc_parallel()[1] missed that fact that atomic_open()
> has two callers, and would have resulted in easy deadlocks from nfsd
> when re-exporting and NFS filesystem.
> 
> I think the best way to fix this is to provide a richer interface for
> nfsd to use, which includes all the locking as well as inode_operations
> calls.  This allows the nfsd behaviour to share more code with the
> system-call behaviour.
> 
> This series refactors code between lookup_open() and
> open_last_lookups(), and uses the new lookup_open() to provide
> vfs_lookup_open().  It then rearranges the code in nfsd so that it can
> easily use vfs_lookup_open() instead of dentry_create().  Finally
> dentry_create() is removed.
> 
> This series is based on a merge of nfsd-testing, vfs-next/work.dcache,
> and vfs/vfs.fixes (though I can't see my "Fix possible failure to
> unlock.."[2] patch in there yet).  So I probably will need to resubmit
> after a bunch of that has hit mainline - though a few of the patches

Yes, please resubmit. 

> This will conflict with the O_CREAT|O_DIRECTORY work so obviously we'll need to
> work out how to order them once we both have enough positive review.

I have that on my todo but somehow said todo keeps growing...

