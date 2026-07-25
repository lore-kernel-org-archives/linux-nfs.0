Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A368540E8FA;
	Sat, 25 Jul 2026 20:14:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785010501; cv=none; b=tkInkUNAYU/6xoxfYvqloOuNugJTcc1mlYg4aGS2RS416TCGvdcdyTMUIV2t3NY8nYQ1ZoR0E7O+AQGhkwSFIS+rtWZ3BvprG/JnbhWuEFR6Y118feEvqGLvwhp0YazHw2cZmD2Kpk16t49uUQMY2JTckwW4IjaBVNKTAD79KwI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785010501; c=relaxed/simple;
	bh=Db3f9Hkbr1czRMuS6sEqyNruq5sN9vgK788hDrtE69w=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=pfmjZ/qT8C+vTXpGa+qwQceAN5G3cLoQmu17WGH7rizOb4UWk85oX2KVsHN9krkqPTsfkqG9i7j6IPOPfqzlDcmfeycNI32LHILL/GAO5+9tDsBNZNg0YDZt2w5yxOQj1ANK93+covYMB0OSRQCh8udqYdA8vYLMHwK0n/nLDSc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=LOb7WuPP; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="LOb7WuPP"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 231BC1F000E9;
	Sat, 25 Jul 2026 20:14:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785010492;
	bh=RTyMHzE0NoKBxtjm0Pr5tmlD2a81LRHCxcfNNyoc3PI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=LOb7WuPPFMZoBJ8pvZS2vIzbus1m/mggu4XTTwJkwxY0aFDfcnPL3Och1dcPKQTYR
	 Pr5ZHzRwGWAiUw/MALqbJn2JqH3x9+HFbWPaYYvx4kALhmDdQmGf3kWQ5GfzGppFVR
	 sBjVV1aJOF7BH+MhXizPMZm5aKBTZVXKMOXNS4zJTJdJQOFwinOY8/htG0C0+XqIr9
	 z9RgvU2NhvEIaX6nPRDHtIPVZRGJYwQ4wVG7NHyUHjcF2t/dsCywjdNEZEiNke+rKP
	 5/Z0ZVQ9QeyJzy5ekdC6LWhm8QoYcWvh0xyAp/ps1DfjVQDePQ1sie8Fi5FaSH8eiV
	 8QNvxS2LPANAA==
From: Chuck Lever <cel@kernel.org>
To: Stephen Smalley <stephen.smalley.work@gmail.com>,
	Paul Moore <paul@paul-moore.com>,
	Anna Schumaker <anna@kernel.org>
Cc: Achilles Gaikwad <achillesgaikwad@gmail.com>,
	Trond Myklebust <trondmy@kernel.org>,
	Casey Schaufler <casey@schaufler-ca.com>,
	Christian Brauner <brauner@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-security-module@vger.kernel.org,
	selinux@vger.kernel.org
Subject: Re: [PATCH v2] security,fs,nfs,net: update security_inode_listsecurity() interface
Date: Sat, 25 Jul 2026 16:14:48 -0400
Message-ID: <20260725200958.4471-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20250428195022.24587-2-stephen.smalley.work@gmail.com>
References: <20250428195022.24587-2-stephen.smalley.work@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

On Mon, Apr 28, 2025 at 03:50:19PM -0400, Stephen Smalley wrote:
> Update the security_inode_listsecurity() interface to allow
> use of the xattr_list_one() helper and update the hook
> implementations.

This commit wedges an NFSv4.2 client running fstests.

A kdevops fstests run against nfsd-next hangs at generic/086.  The
client stops making progress and never recovers:

  watchdog: BUG: soft lockup - CPU#3 stuck for 250s! [086:60396]
  Comm: 086 Tainted: G  D  L  7.2.0-rc4
    __pv_queued_spin_lock_slowpath
    _raw_spin_lock
    nfs4_xattr_set_listcache [nfsv4]
    nfs4_xattr_discard_cache [nfsv4]
    nfs4_xattr_cache_scan [nfsv4]
    do_shrink_slab
    drop_caches_sysctl_handler

The D taint says something died earlier.  It did: by the time the
lockup fires, the client has already taken two dozen NULL pointer
dereferences, all of them in the same place:

  BUG: kernel NULL pointer dereference, address: 0000000000000000
  RIP: _copy_from_pages+0x44/0xd0 [sunrpc]
    nfs4_xattr_cache_list [nfsv4]
    nfs4_listxattr [nfsv4]
    vfs_listxattr
    __x64_sys_listxattr

The two stages are connected.  nfs4_listxattr() declares its
remaining-size accumulator as an unsigned size_t.  On a size query,
where listxattr(2) passes a NULL buffer and a length of zero,
xattr_list_one() decrements that accumulator for the SELinux label
without regard to the NULL buffer, so it wraps to a very large
value.  nfs4_xattr_cache_list() then sees a NULL buffer paired with
a buffer length large enough to pass its own bounds check, and
copies into it.  The fault happens while the xattr listcache
spinlock is held.  Task exit does not release spinlocks, so the
lock is orphaned, and the next shrinker pass spins on it until the
watchdog fires.

The reproducer is a plain getfattr on a file on an NFSv4.2 mount
with SELinux enforcing, which is what fstests generic/086 arrives
at by way of a drop_caches write.  No fstests machinery is needed
to see the oops.

An audit of the listxattr path pointed here, so I built nfsd-next
with this commit reverted and reran the full fstests nfs_v42
section on the same pair of guests.  745 tests, no soft lockup, no
oops, and generic/086 passes.  The two failures that remain,
generic/033 and generic/258, are unrelated to xattrs.

I am not proposing the revert as the fix.  Achilles Gaikwad has
already posted a targeted patch for the accounting itself:

  https://lore.kernel.org/linux-nfs/20260707152305.15324-1-achillesgaikwad@gmail.com/

Whether the right answer is that patch, a change to
xattr_list_one() so it leaves the remaining size alone when the
buffer is NULL, or hardening nfs4_xattr_cache_list() against a NULL
buffer, is for the three of you to settle.  I am reporting the
severity, because the accounting bug is not confined to a short
size query: on a filesystem that caches xattrs behind a lock, it
takes the whole machine down.

I can test whatever you settle on against the same setup.

--
Chuck Lever
