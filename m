Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EF503385D64
	for <linux-nfs@vger.kernel.org>; Mon,  6 Jul 2026 14:36:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783348613; cv=none; b=WNPb0nxC7sa0UK4oSTvffJXRuUUrB10IcbSvwvClhpFzc7HbMFnKeRG9jqxDAV6eUaMWMzErU7OKtbiJbUEwuAc1MK9FbZhDU3+50aiSCGypPHtuswhjZm1jySHwxw9+jcWVIEgtVWLZLkjnvj9t0SxQyKbmK8dgcpUy8vDedQo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783348613; c=relaxed/simple;
	bh=WXQLjYLfxwnHgrL2RyI2A6t6Od6DVnBjwolJYYd0+3k=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=H9+SWy/9SMZJtsYdEoBxJCO9Df+wY6dphofvKwLrfLjxlsqipUTFJXmCkjmKv1RFtfTtvaSCnhjAr0BOGVJqSsiawutYueHRMvT/uOlDu6hQdyNr9IZglJlbMJ4f8l/lWZrILaRefnmTDfJFOEH4uHEN4xZ/veDsVDcjya9x80c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Lencrpbl; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Lencrpbl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 215941F000E9;
	Mon,  6 Jul 2026 14:36:51 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783348611;
	bh=5DZsMcIN2lcn8rovSx/BdVqousCwJtfpSze8K0FogBE=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LencrpblymzzJu4LlaPYv5lAfnZsVUE5fn7EpxE/gvX0QwbT1Qrayty9FnqKRZ8YL
	 kI/OePYCnXLZfiuLT415sOpFq5UpvB5raSkgDa0Zrk1wpyCf3S6BWWlk+TOFagTh6v
	 Cd9YMgJeN9yQJGeADFD1ype75uRAeTRBawxJhRQsXeuDyL5rHJQA+uvCWShMMIDfpN
	 f89D91k8QTGVOStHoQms4tGYDDP6H1imOPn9rI6yDCPSU2fei79wGGXOeUAObYZHzh
	 xbAdFZXuJ/vz+4h5DePKvQiI+9gjohBJGdlS9/R8/MbEt41d33ZAvcWtNLKqK/xwYA
	 WOITE1fuS+3RQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>
Cc: Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 14/14] nfsd: use do_lookup_open() for non-creating open requests too.
Date: Mon,  6 Jul 2026 10:36:46 -0400
Message-ID: <20260706143647.1243020-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260705222032.1240057-15-neilb@ownmail.net>
References: <20260705222032.1240057-15-neilb@ownmail.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Neil,

Thanks for jumping on the Sashiko findings. Codex review identified
three correctness concerns which I've confirmed with Claude are not
false positives:

1. do_lookup_open() takes write access unconditionally.

	error = mnt_want_write(parent->mnt);
	if (error)
		return ERR_PTR(error);

   Fine for a create. But a read-only OPEN with no create now returns
   -EROFS on anything mounted read-only at the VFS layer: squashfs,
   iso9660, a read-only bind mount, a snapshot. The old path didn't ask
   for write until nfsd_open() actually opened the file, and for
   O_RDONLY it never asked at all, so these opens worked.

   Worth stressing that this isn't the "ro" export option. That keeps
   the underlying mount writable and is enforced in nfsd, so it's fine.
   Only genuinely read-only mounts break, which is probably why it
   slipped past testing. Can we make the mnt_want_write() conditional on
   O_CREAT? The read-only-open setattr path already re-takes write for
   itself, so it shouldn't need the blanket grab.

2. We open the target before checking it's a regular file.

   do_lookup_open() runs dentry_open() on any positive dentry, and
   nfsd_check_obj_isreg() doesn't run until nfsd4_open_file() returns.
   There's no O_NONBLOCK on that open, so an OPEN of an existing FIFO
   sits in fifo_open() waiting for a peer, and it waits with the parent
   directory's i_rwsem still held from start_creating(). One client can
   pin an nfsd thread and the parent directory that way; a handful of
   them and the pool is spent. A device node does the same thing through
   its ->open. We used to know the type before we opened anything, so
   could we check d_is_reg() ahead of the dentry_open()?

   In fairness this isn't new to 14/14. "always open file in
   nfsd4_create_file()" already opened existing files for the UNCHECKED
   case; this patch just extends it to plain reads.

3. Mount crossing and the target export check are gone.

   nfsd_lookup_dentry() went through nfsd_mountpoint() and
   nfsd_cross_mnt() and revalidated the export it crossed into.
   start_creating() is a plain one-component lookup, and we fh_compose()
   against the parent export. Bind-mount one regular file over another
   inside an export and the new path hands back the covered file instead
   of the mounted one, with no check_nfsd_access() on the real target.
   Narrow, since only file-over-file mounts reach it (a directory trips
   the isreg check), but the behavior did change.

Actually some of the suspect logic is added in earlier patches, only to
be exposed by this final switchover patch, so I'll wait for a re-roll.


--
Chuck Lever
