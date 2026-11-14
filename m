Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794648934;
	b=Sb8GaDVRLGADWdOskuQ/5kwg2o/rMGxTe7oCYa+bKRHKv3dlEe8Rc4YEq+/DAZYRs6iy
	 WwTK4oSzUVUwxXoGlmClXXiO0m2REmcJ1O6NqH2NE3dZHYfYZRSVTivIsBuNEd1Yk7VyY
	 Omkl6QyuvKOg8s6azc2MJOy2coGurjUusIvnyZLfRxZA1CtQj0WAm9yGyQB6evn7MWEyG
	 q/p/Ie8WP7YgAq1pH9bthUqgbkDvBsF5jE0jKbt5+LeLJIdIWo0g124gwFLE5RHF1WXWX
	 9BqACx/uPNN8oxDvvkfUtYQgUtI+WiVnaZ6CiYq63GmeKaymlGLFoMZ1STxeW/DH8sA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794648934;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 MIME-Version:Content-Type:Content-Disposition;
	bh=R3SHNzEG8PZRl+89SIxHaUlLOou0v8iJQFJkz7hZ9JM=;
	b=NL4nA2Lx29u7RL1KlJgH8kFBIYoBV3eWQfdM1BExlHlyC1x78m/zXRGbb7GxZ0FKn2wx
	 ENAssVcD8s5NFJY7anQo2ybMG66A21mM0ca0GQOnuvB1wj7Uqqy/fuJrb3bHX75J/5q7R
	 zffl+Q7e69xV/k9oBzapfvS3iaDCNl8FGv+oZKEsbq5vMpU8Dxwj5S3xBeSTXL+fC/Pjd
	 2RNiPf/npBTITgBZLQPLEkokEFUo2pROiEjaIlKtu/3z/AUWeLBY4v47E/HAADDk6r6SL
	 7ypOQO6NOm31fjQAF8i92IfLXrwPxbsVVHKDHBt+rdql0zgL2jOxrTf7tnwa8DNYeuA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Uvfc/e8b";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EAB94606A327;
	Sat, 14 Nov 2026 09:35:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Uvfc/e8b
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 277FF1F000C4;
	Sat, 14 Nov 2026 09:35:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794648933;
	bh=R3SHNzEG8PZRl+89SIxHaUlLOou0v8iJQFJkz7hZ9JM=;
	h=Date:From:To:Cc:Subject;
	b=Uvfc/e8bUSIWz+2yFggtoHWkEr+ffxhKYH6vkR49oM2nss5jWUMeF1/NEMgjSSapo
	 N98CYT8jcSDaccm0KVoS+/8rABjn1vJGlxDYqjFqUah1708/hi9wyg507fFdNSlI8l
	 fWPu1yEraCJcMuqC1vutS+3c6CU+0wZ0yndqYgIUb+vjkSFMC0iuKauIcmcZMeKGqC
	 92nDpl56ckvD3vC4kB8Q9XQC3h5bzYHtHpeikz7LQ12cPzFzWGD2s7jbd9MX7B5fJV
	 Ii5TnCdI4vEnlC39oLEUTCOR/7LcG0rxncpgCv+QUCRGKlb8YoTct7pEoCQnbMkcEC
	 G89OzKr4fHBGg==
Date: Sat, 14 Nov 2026 10:35:28 +0100
From: Christian Brauner <brauner@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
	Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Jan Kara <jack@suse.cz>, 
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: nfsd: delegated timestamps get written to frozen filesystems
Message-ID: <20261114-abdrehen-mahnwache-farbpalette-9c31774145cc@brauner>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hey,

I'm working on a freeze protection series. This fell out of it and I
can't just fix it myself.

Can I leave you with fixing this?

cb_getattr_update_times() and nfsd_update_cmtime_attr() call
notify_change() under inode_lock() but nothing takes freeze protection
for the export. So they modify filesystems that are frozen. On ext4 that
trips the WARN_ON() in ext4_journal_check_start().

Reproduced on v7.4-rc1 with two NFSv4.2 clients, the second one in its
own network namespace:

- client A opens a file O_RDWR and gets a write delegation
- the export gets frozen
- client A writes 64k into the file and keeps it open, so the data
  stays in its page cache
- client B runs stat on the file

nfsd sends CB_GETATTR to client A, sees the file was modified and
updates the timestamps on the frozen filesystem:

  WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0, CPU#0: nfsd/444
  Call Trace:
   __ext4_journal_start_sb+0x7a/0x470
   ext4_dirty_inode+0xa1/0x120
   __mark_inode_dirty+0x154/0x1110
   ext4_setattr+0x2bd/0x24e0
   notify_change+0x81c/0xee0
   nfsd4_deleg_getattr_conflict+0x7f0/0x1370
   nfsd4_encode_fattr4+0x3c3/0x1290
   nfsd4_encode_getattr+0xd1/0x1d0
   nfsd4_encode_operation+0x285/0xf80
   nfsd4_proc_compound+0x5e2/0x23c0
   nfsd_dispatch+0x26d/0x870
   svc_process_common+0xfed/0x19a0
   svc_process+0x600/0xb90
   svc_recv+0x1969/0x2650
   nfsd+0x2f8/0xcd0

The inode's mtime and ctime on the server change while it is frozen.
That was with delegated timestamps turned off, the
cb_getattr_update_times() path with them on is the same.

I think nfsd_update_cmtime_attr() has the same problem
but I haven't reproduced that variant. It runs from:

- nfsd4_copy(), nfsd4_do_async_copy(), nfsd4_clone()
- nfsd4_finalize_deleg_timestamps() <- nfs4_unlock_deleg_lease() <-
  destroy_unhashed_deleg(), which is reached from DELEGRETURN,
  nfs4_open_delegation(), the laundromat via revoke_delegation(), admin
  revocation, client teardown and nfs4_state_shutdown_net()

mnt_want_write_file() on the delegation's file before inode_lock() would
do for GETATTR, COPY, CLONE and DELEGRETURN.

But the laundromat and nfs4_state_shutdown_net() shouldn't block on a
frozen export, I think? Lease expiry for the whole net would stall and
nfsd shutdown would hang until the thaw. Those probably want
sb_start_write_trylock() and skip the timestamp update while frozen.

The OPEN with truncate path in nfsd4_truncate() had the same problem.
I've got a fix for that one in my series.

This goes back to 7e8ae8486e44 ("fs/nfsd: fix update of inode attrs in
CB_GETATTR") and e5e9b24ab8fa ("nfsd: freeze c/mtime updates with
outstanding WRITE_ATTRS delegation").
