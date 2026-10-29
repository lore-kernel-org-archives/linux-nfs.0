Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.160.48
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297394;
	b=vHP2+O7p9gf5OhpPzwqjRXFeuJiqbqGJ/Z4+meEEo3xcIwhQnCJCc0x6R/tS5C8ahkVw
	 rqLZCBcuUIHYYSus+cZXNLMPaf53BWXw5yOy9LlK5SYg1V4wNua9Wk8o6uBIKWB5cmvMJ
	 pxFPCbDjJDY2XDAjnkJwc9acETW1YLMEUdSvXwN1pFHbqmVZ6OPoNFhvit7Wzt6FbeqRt
	 MWY4oQMAOmhymqZAZyOgkfm8UWrJmdOpmshJKS3QrbHgs8WkfLDN4kO3on3dBg/MNyZdi
	 cdmOFqqQDnjnQj2lFAbkCUMXkVZOs24Vvif6pLwswamTYIT195D61MYfWNZ9hWWt25g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297394;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=BL+32AV/+8oEq45HeDcTTOkYS9ivJyJauIHumIl+ifc=;
	b=iljiGlPkEC3X90LOHbeiNV+iHPvk9tP5wTsctI9tt2IxCBDNbIowVdkBBnL/3SA1URS7
	 5q3A5PUAVuCreIUI5SKuCmCht9gQiDPsb3VdtdWAqzYGYL+J0tNiZ0hiGNbm6Yh+pCb1g
	 wSCgP8Dqj38qWdhvNrvY2aAAOyAhr8XImCNEe7uuxO5n5jW+ohmOp5YhDW3kkRvsV5IvT
	 wpjZztPImRxnuAO4RcthhRQoodETPaL7BcfKVGIid//aIpUDzvoV+XHCXnWkd2aBC1ECK
	 0JqirKGs8D2lbW4bO/if1dBf/5+kieBFlLbtkFcRP8Yr+OLA7SQUpAa8CHW99FIxC9Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ZAnA6cXW;
	arc=none smtp.remote-ip=209.85.160.48
Received: from mail-oa1-f48.google.com (mail-oa1-f48.google.com [209.85.160.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B0A3C606A31D
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:09:53 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org B0A3C606A31D
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=ZAnA6cXW
Received: by mail-oa1-f48.google.com with SMTP id 586e51a60fabf-483c607ccb4so1344466fac.0
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:09:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793297392; x=1793902192; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=BL+32AV/+8oEq45HeDcTTOkYS9ivJyJauIHumIl+ifc=;
        b=ZAnA6cXW3uEmAGJSMsCqqkc8J3UbkUBlKaxca14efBcSWi2MrC9WIoBPRYlP2sUq7G
         c6fTdjKD/Ngq6mCgmvZyqWmFmViVrQPApXROvqkYPquXtzFCJVbMzvBADBkQu3nGWIFR
         yroapqOYhybxmt8z64swJpRIBb01ljqJe5BToW3lSJGxWJe+0WWrakdFywUoqV0RZxR5
         iM/XrZQacFWMrLMpYWOIutjPyF4igIppHunMP06iQhkO+42hI5qisZaYUNPa1NnzXQLW
         Qdl+dXaOaGLg0kspMP6iMg6BFDaZktQisrd5jiabXXVXEqx5vB5NzWN69qrjr7Fw5BC4
         eWiw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793297392; x=1793902192;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=BL+32AV/+8oEq45HeDcTTOkYS9ivJyJauIHumIl+ifc=;
        b=a49o4EoWOfDR63tqOqOl0lhEY/3cd7pJFUFOJuq7rpq5PlpWWClcRaxstXw+3PFdXM
         hI/GmFzkfDKx+LxwgxslfkqvX9ZSOM1Ic0p0/D/Y44doapVYA8zk1ozddLwbar07jDLt
         pxbkHmYOWyxv6tMaSQIchJefe/M97iFOgmRb8z7NugTvO2Dgn84Xttn2TPJQN8kq4hTY
         knC0uj0kwd6bDfBkrxu3S5Xz/V+kGUVm9Y/ptzUKpevMV1CKcXkv3JdOjTwyuylVQXHM
         zmerGfekgc8q/BKcoBMTtBc1sk15s5gA64PI0t3nqNAPd7DQkLKHglifQphocIhxGAnp
         gx3w==
X-Forwarded-Encrypted: i=1; AKwUvBw1ZD6NI8udmo72ak7w3rHZJquybj95y4/5uuBOtoj04sas6DUxKfs6BDwOT9cK+JTZ9E/NCOTwzVM=@vger.kernel.org
X-Gm-Message-State: AFq9FYKQADa34I2qhhliSSBeJTPV+ShsI2ptFRdfHILPxmy2JMLPIiMh
	OMZ3Kj6+q65HH5K1Dvdf2h0LamVLA7h1FGZ8uyqb9n/xRdIiO8ndL+4xLFvtMMu0K+c=
X-Gm-Gg: AYBFou13kklvCDZ2yk8hkDicyscEaY1p34+7ned08r5RPaVZNVULWe6G+nZVFiDMbZM
	gWGtX+MfVsT1NSECsQRg7QKvf2rPYWYcfptmFWgu06p7LXRdJ/33l1tbVdHjXtt2sBR3UFwQAS0
	oLFaSHm0FgepOLeC1WjqpRYx/CB7uWWK4xF+7JAlnRKTOgPp//YN3SNKtxTOK5UtHehhp+RFG/M
	x7DLW5kzyhVEqc58KaRnh2sKWbS4n8hfdWL4uBen1SbdYvHkq0wVG5ffOvUFi/k7Uw58l7AjVBx
	pDxKkNrVPU6iIm5GwByjR95a+924IbncBc9cUiZE+GghZjLkD+0Q8EmFWhLlb3XtKtVzUGPZTqM
	AaktKJkmt+nKO8HZ6fJAIOdOATFDCZ61hijFaWHDSihCQG5myCmt0gHfUTWa/Nu7EgvjurKPbHI
	OfngLPA7XhZNVOHNoUAR4W4tgGZCsBhw0bTI8sQXeesglRedjEImUtQF6eGomfYi20CmfDNFwGY
	OYcfol/+wfUa9k3zfY8yYcKiIRrZZvvzMmWDyFEAQNr13wn2J0rvgzwKCqSxSSiMdsdt6FZj7PT
	IMjZxCZsTVFm3llfd7z1rCEtLZgUOqs6LZuDbb9QeoUousEL0Gh2bRBhOy4OlSs+GYVCNrY7
X-Received: by 2002:a05:6871:3287:b0:4a7:5eb7:ab97 with SMTP id 586e51a60fabf-4a8bb62169emr4560053fac.32.1793297392261;
        Thu, 29 Oct 2026 11:09:52 -0700 (PDT)
Received: from localhost (75-163-200-235.clsp.qwest.net. [75.163.200.235])
        by smtp.gmail.com with ESMTPSA id 586e51a60fabf-4a9048e6ab1sm119378fac.8.2026.10.29.11.09.50
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:09:51 -0700 (PDT)
From: Jonathan Flynn <jonathan.flynn@hammerspace.com>
To: NeilBrown <neil@brown.name>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 0/3] nfs: fix the silly-delete hand-off that 2/9 makes reachable
Date: Thu, 29 Oct 2026 12:09:47 -0600
Message-ID: <20261029180950.387072-1-jonathan.flynn@hammerspace.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261028041023.3738553-3-neilb@ownmail.net>
References: <20261028041023.3738553-3-neilb@ownmail.net>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Hi Neil,

Your "nfs: fix nfs_call_unlink()" computes the silly name's hash before
d_alloc_parallel(), so nfs_call_unlink() can now find another cached
entry for that name and hand it the pending silly-delete.  With it
applied, that happens: an entry made by a fresh lookup of the silly
name, after the original entry was invalidated, receives the delete
when the file is closed.  Three problems in the hand-off become
reachable with it, and these patches fix them:

  1/3  the hand-off can overwrite NFS_FSDATA_BLOCKED on an entry whose
       REMOVE or RENAME is in flight (Sashiko's review of 2/9 reports
       this too);
  2/3  the other order: nfs_rename() tests its target before it takes
       ->d_lock, so a hand-off landing in between is kfree()d by
       block_revalidate(), leaving DCACHE_NFSFS_RENAMED set with no
       data and a NULL dereference at the final dput(); a hand-off
       that the VFS's unlocked test missed also trips the WARN_ON()s
       in nfs_unlink() and nfs_rename().  nfs_rename() now tests under
       ->d_lock, and both return -EBUSY, as may_delete_dentry() does;
  3/3  nfs_call_unlink() holds rmdir_sem for read across its lookup and
       across the dput() of the alias, and either can kill a dentry
       carrying a silly-delete, which re-enters nfs_call_unlink() with
       rmdir_sem still held: that deadlocks against a waiting rmdir()
       (Sashiko's review of 2/9 reports the alias case).  It now takes
       rmdir_sem only for the REMOVE it sends, which also closes an
       older route to the same re-entry that does not need 2/9:
       NFSv4's delegation return in ->unlink_setup().

They have to go wherever 2/9 goes, and its Fixes: tag will take it to
stable.  Fold them into 2/9 if you prefer, as you did with the d_seq fix
in 1/9.

One window is not covered, and you may prefer to close it another way.
After nfs_unlink() or nfs_rename() clears the mark, and before the
VFS's d_delete() or nfs_rename()'s d_move(), a hand-off can still land
on the entry.  For an unlink, that costs only a second REMOVE, which
finds nothing.  For a rename onto the silly name, the target is left
owing a REMOVE of a name that now belongs to the renamed file.  That
REMOVE is normally dropped, because nfs_call_unlink() then finds the
renamed file's own entry and its file handle differs; but if that entry
has left the dcache by the time the target's last reference goes, the
REMOVE is sent and deletes the renamed file.  Closing the rename case
would take the hand-off refusing an alias that is no longer hashed, and
nfs_rename() dropping, under ->d_lock and after d_move(), a
silly-delete that landed after its mark cleared.  I have a draft of
that, and can test and send it if you want it.

Tested with your v4 and these patches on a 7.3-based kernel, over
NFSv4.2 to a pNFS metadata server that is not knfsd.  The hand-off
happens as described above.  With 3/3, the nested nfs_call_unlink()
that follows it starts with rmdir_sem not held, where without 3/3 it
ran with rmdir_sem held for read, and the REMOVE is sent once.  The
removal race tests of my RFC, posted in reply to your 0/9, passed on
this kernel, as did a PROVE_LOCKING and KASAN build running them,
though lockdep does not see rmdir_sem's read hold, which is taken with
down_read_non_owner().  No test here hits the races that 1/3 and 2/3
close, or the deadlock itself, so for those the fixes rest on the code.

The series applies to 83f32c773255 in Linus's tree with your v4, and
fs/ compiles without warnings at each patch.

Tools: these patches, their changelogs and this letter were written
with Claude Code, using Anthropic's Claude Opus 5 and Claude Opus 5.5
models, at my direction.  It found the problems fixed by 1/3 and 2/3,
and two of the three routes in 3/3, reading the code with and without
Sashiko's review prompts; Sashiko's own review of 2/9 reported the
problem in 1/3 as well, and the route through the alias in 3/3.

Thanks,
Jonathan

Jonathan Flynn (3):
  nfs: do not transfer a sillydelete onto a blocked dentry
  nfs: answer a handed-off silly-delete on a removal target with -EBUSY
  nfs: take rmdir_sem for a silly-delete only when its REMOVE is sent

 fs/nfs/dir.c    | 32 ++++++++++++++++++++++++++------
 fs/nfs/unlink.c | 39 ++++++++++++++++++++++++++++++++-------
 2 files changed, 58 insertions(+), 13 deletions(-)


base-commit: 83f32c773255720a661aa45d83e36278135f23f5
prerequisite-patch-id: 3405b4d6ab8b0bf24ba63a898083d617deec4f24
prerequisite-patch-id: 096657d6d80d7ca533ccb574d2af65611ede4af2
prerequisite-patch-id: 1a2319c14739918aef86116647fea28ae85ad4df
prerequisite-patch-id: 725cb18c3936d50141ef27dafc159bf50b64a5bd
prerequisite-patch-id: b39cdd352b97e2cd247311fd5db620dbff227bd7
prerequisite-patch-id: f9f3f0e945cadf96113d4ac9ab8f7b0c207af4e5
prerequisite-patch-id: 4c09a15390bb556d79bea1ee733f52a58bec80ef
prerequisite-patch-id: 7c026717a97b2c86a169539822f5d14650f68f8a
prerequisite-patch-id: a702d54495d0f3d7f88b82411d884dcf5aacf9a0
-- 
2.43.0

