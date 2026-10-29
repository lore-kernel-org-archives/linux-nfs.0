Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.45
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297412;
	b=1eCOscW6gN9liSdB9A30w74/AFeWEYPR6exFCJzUr1CkcG5yOg8LtlGT+f1NKgUYOKM2
	 wMiQsJkWgWnE+Pk6UR7SfbsPOFyoKH5xfc9JiSbkOLzwH8pi/ArkBIxRoG3TjQHG46Cj5
	 Y9InilzG9YHmKq0viCwAHiI2p+LzFXcxl4e610m/EHJYAdaWg20aXcPkAptrHR1KVn6N1
	 xBlO2VmSYopJIRSGRIXwZJb5teksb5c0uwv44lRHZDfhS+UIp1eslQx5TWiPa2grYweon
	 yWdvUoSqHySw7I0JRXnMW7HKFXuQsIDXzqwMjGA8e74Y5OzfnHDG4DdQ7BrGGvRifVw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297412;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=RWhJUFKF4TWvOC3SGf2JPVUTZX+qX1/DMK27i9WWrDA=;
	b=se3XAlBvHPhkxRwU46XqXOGzF5OrO2+ioHFtc339fNbBKdNR9zWgv22/rBeO9PcFqJVq
	 CWaia2mwXNOVLTiCBjnD7SUmegFClweJwGaWCVuN2G1f0M/8JsMKpjbbLYS2o0TnlWacq
	 IQsDoKRF0c8J40pVUssSh47KmabV5SHZnB40pXPcYV5ETpkHCgZ5ZfHGrjQa3jWPRNaZC
	 ne7DAS/gGYzm6jVXq5KcXV50MjL1zvVgueAJO9ITt4YZIoTgvFr5zsUYWkc7YoyYTjfw/
	 brSHtlkNzcURLFfCxNnDWtRNjdl4DwT6zRyzMFNXuLVj/5cENao7tbvVGe35HvGyhHQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=iUhJBgc1;
	arc=none smtp.remote-ip=209.85.161.45
Received: from mail-oo1-f45.google.com (mail-oo1-f45.google.com [209.85.161.45])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DF205606BD59
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:10:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org DF205606BD59
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=iUhJBgc1
Received: by mail-oo1-f45.google.com with SMTP id 006d021491bc7-6e560e00a86so1853614eaf.1
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:10:10 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793297410; x=1793902210; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=RWhJUFKF4TWvOC3SGf2JPVUTZX+qX1/DMK27i9WWrDA=;
        b=iUhJBgc1II657e2dR4MQ+AI/62WJbkERp4J2PgHRiqt0ATbFgXweQ8WA/56ouitxZE
         oF4Lm8Wj10KtvM07lGJMYWr17Y9uzkNsvN7Xxg9NDASbMFnxFTeIAF6RLmblQRWS6Q/u
         IFcMVCxWIaL8Yvr5uVQ1YxX7cuvjv0WTy0BWgiC4zoAUIawXvo5Jkh6VwuHG1yDwq0AQ
         9OMSSTiHskTM5QWoAN/Ml13YZp+7qu9U0cll1fMmBdrKeXGeS0x8TzYzzhmWiLvGBqu2
         qqY0jWrLFonoVtWQiOqrnVwh35cYChhl3CjfkEWokdKG6x7QXZtX+nJIWAkh+GY+YyeN
         O8ww==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793297410; x=1793902210;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=RWhJUFKF4TWvOC3SGf2JPVUTZX+qX1/DMK27i9WWrDA=;
        b=g1E4A9MU2vRp/s48p7dz4xH4K5+/tiUo+PoDnPNMLJvsWf4sCRAnoD5IDnShpvoDds
         /cxYUVJQ3nr32eU3NCHI3PpsPq2WJ7iV4hmMZtMJiKZGAj5MxuXV8CMujvqt8Sz3V+5v
         xxoL+aj14/c1FBer8xT94wDEj7UPB1AobYLWkkdTboxSlBKrdAGVcxBy82b6f3A9lySq
         2dYiE4H87ltDKwpfc87dHyh6g/zZp32QPMs3txoPXYrz3cqdaRzFsqR9t+IqT0RCmEaL
         G5AL6bpsTChvyKdxLSEW4VVWyx9k6IKoE9giZ1xPx3WR5XvZQN3ChOqSRbtWYikdsFBE
         SkpQ==
X-Forwarded-Encrypted: i=1; AKwUvBya1eiRK54VBOcyyuMXvwdJa8WDikKflYE6AX2esJKtKtlr+pd5tHLZAZxMHdx99YroYOXWfBzPO2o=@vger.kernel.org
X-Gm-Message-State: AFq9FYJ0aUSc1ktOC8M28C1KLzNhuSgpOAGOpE7H1WRF83ZNJDMc7CN0
	G104CEZpU2ocDs5aB5J5RKmO0IBLi0b/hNBIbUJbZZX/JNqGZyjbGKF0Cm0hljOmp9c=
X-Gm-Gg: AYBFou1gPcwafpTtLcdTPNbazHyHjd1lxxLNQYu5rLNihm+vw+3UmDXdasP2rWN8CAK
	B0IwbK1hwe0WESmrTWrVikoG/umACdzFJAsq8eCS18QFWrZNdUrP7t1/Nw6NioQ0IWiXNu0EdBC
	g37pqEbfeVWLhO47sT9r+cKe0Pdybo9LrZiTjwFUbumID+bpDF2fu58PaPXxl0KcnenftjR/Y7+
	W73gFhQ0K37suFerrxaja37AA24nne6PYGSbqVrgHOq1Zr0Fuz9sODdVYFxgdPIcE4NO6ZTT+fV
	v2X3hZ9QyqCArhnngIhjhra3VAafeLMELHDUJOZkZJ7h5zPPzSXMv2kS3p7VzWpBG0sxRyhXV8p
	iRVjysdVuLuSAw5s9CSOxnJlziLpyvWPJc5Oe/khmMqUbtrIzJmN7zIepWy5GQW332DjepltEA0
	st0fAIWxjXJq/9de4cEB1iQPxjd3v3QXwx6SgCM7qVev2eBy/NPBdskQH3yvu7+Hzf24V/nZ3Gs
	NDJGU6NmTTbn1cc36+H9b/A92Jp7sBfTZwpYzyq5mX0ZQB1sQJRO47ZbrxqfEA9gN0jKpHVu1sH
	AHlF+b4uvqA7rT+75pENttkRMXa372hyS8hjb6CIQ0V/Jd5qD6RHPOiO9j5NLxdL9n3w9nKt
X-Received: by 2002:a05:6820:810:b0:6e0:fb60:d5c1 with SMTP id 006d021491bc7-714f1f8ac39mr93646eaf.11.1793297409166;
        Thu, 29 Oct 2026 11:10:09 -0700 (PDT)
Received: from localhost (75-163-200-235.clsp.qwest.net. [75.163.200.235])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-85d3549a245sm161891a34.12.2026.10.29.11.10.08
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:10:08 -0700 (PDT)
From: Jonathan Flynn <jonathan.flynn@hammerspace.com>
To: NeilBrown <neil@brown.name>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jan Kara <jack@suse.cz>,
	Jonathan Corbet <corbet@lwn.net>,
	linux-doc@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH RFC 06/12] vfs: let a filesystem remove files with the parent directory locked shared
Date: Thu, 29 Oct 2026 12:09:51 -0600
Message-ID: <20261029180957.387138-7-jonathan.flynn@hammerspace.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
References: <20261028041023.3738553-1-neilb@ownmail.net>
 <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
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

Let removals of different files in one directory run concurrently on a
filesystem that orders them itself.  Today they are serialized by the
directory's lock even when a server does the ordering, so tasks removing
their own files from one shared directory wait for one another.

A filesystem opts in by providing two new inode operations alongside
->unlink(): ->unlink_shared() is called to unlink a file with the
directory locked shared, and ->unlink_shared_done() after any delete
event for that removal and before the lock is dropped, to end the
exclusion for the name that ->unlink_shared() set up.  The existing
->unlink() is still called only with the lock held exclusive, by every
caller it has today, so neither removal method has to ask how the lock
is held.  ->unlink_shared() can hand a removal back by returning
UNLINK_NEED_EXCL, having done nothing; the VFS then retries it with the
lock held exclusive, through ->unlink().  A directory found by the
shared lookup is retried the same way without the method being called,
unless the name ends in a slash, which is answered -EISDIR from the
type alone, as before.  On a superblock marked SB_I_NAMES_COLLIDE,
where two names the dcache tells apart can be one entry, removals take
the lock exclusive from the start, as O_CREAT opens do there.

Because the exclusion lasts until the delete event for the removal has
been emitted, an O_CREAT open of the same name made with the directory
locked shared, as IOPF_ATOMIC_OPEN_CREATE_SHARED allows, emits its
create event after that one.  A create that arrives only once the
removal has unhashed the dentry is not ordered against it while that
event is being emitted.

The locking documentation sets out what the shared lock still
guarantees, what the filesystem takes on in its place, and the costs.
A handed-back removal goes through its permission, security and
delegation checks, and its audit record, twice.  Removals made with the
lock shared bypass vfs_unlink(), so a probe on it no longer sees them;
the security hooks and notifications still run.  The victim is looked
up through d_alloc_parallel() under the shared lock, and the argument
that this adds no deadlock assumes, as today, that nothing holding an
in-lookup dentry waits for the directory's lock.

No filesystem provides the methods yet, so nothing changes.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
---
 .../filesystems/directory-locking.rst         |  41 +++
 Documentation/filesystems/locking.rst         | 180 +++++++++++-
 Documentation/filesystems/porting.rst         |  35 +++
 Documentation/filesystems/vfs.rst             |  25 ++
 fs/namei.c                                    | 260 +++++++++++++++++-
 include/linux/fs.h                            |  39 ++-
 6 files changed, 563 insertions(+), 17 deletions(-)

diff --git a/Documentation/filesystems/directory-locking.rst b/Documentation/filesystems/directory-locking.rst
index 316f10cb3d..2d9533f824 100644
--- a/Documentation/filesystems/directory-locking.rst
+++ b/Documentation/filesystems/directory-locking.rst
@@ -50,6 +50,47 @@ For our purposes all operations fall in 6 classes:
 	* find the victim
 	* lock the victim (exclusive)
 
+	unlink(2) of a non-directory is the one exception: if the
+	filesystem provides ->unlink_shared() together with ->unlink() and
+	->unlink_shared_done(), and its superblock has not set
+	SB_I_NAMES_COLLIDE, the parent is locked shared for it, the victim
+	is found through d_alloc_parallel() and locked exclusive as before,
+	and exclusion for the name comes from the filesystem instead - see
+	Documentation/filesystems/locking.rst.  That takes an existing lock
+	in shared mode and in the existing order, parent before victim; it
+	adds no lock and no new ordering.  That holds while
+	d_alloc_parallel() is called with the parent's ->i_rwsem held, as it
+	is here; once in-lookup dentries are taken before ->i_rwsem, the
+	lookup of the victim has to move ahead of the shared parent lock with
+	them.  If the filesystem declines, or the victim turns out to be a
+	directory, everything is dropped and the removal is done again under
+	the rules above; a name ending in a slash is instead answered -EISDIR
+	or -ENOTDIR from the victim's type alone, as before.
+
+	The victim's parent and name are stable under the shared lock
+	because it is not a directory.  Splicing (see below) moves only
+	directory aliases, and can do so holding the old parent no more
+	than shared, which is why a directory found by the shared lookup is
+	let go with nothing but its type examined.  Any other change of a
+	dentry's parent or name is made by __d_move() for a rename, and
+	every rename holds the parents involved exclusive.  That includes a
+	filesystem renaming the victim to carry out a removal, which
+	->unlink_shared() must therefore hand back.  With the victim's
+	parent and name stable, the ordering analysis below is unaffected.
+
+	Such a removal can make a lookup of its name wait in
+	->d_revalidate() while that lookup holds the parent shared.  The
+	wake comes after the VFS has emitted the delete event, which the
+	removal reaches having let the victim go: by then it needs ->d_lock
+	and the victim's ->i_lock for the unhash, and the notification
+	subsystem's own locks and an allocation for the event.  A waiter in
+	->d_revalidate() holds the parent shared and a reference on the
+	dentry and takes no lock of its own, so it still cannot be blocking
+	the thread that must wake it; the wait is as long as the removal and
+	its delete event together.  An O_CREAT open made under the exception
+	in class 2 can wait there in the same way, and for the same reason
+	cannot be blocking the remover either.
+
 4. link creation.  Locking rules:
 
 	* lock the parent (exclusive)
diff --git a/Documentation/filesystems/locking.rst b/Documentation/filesystems/locking.rst
index c04df4c746..1783f24052 100644
--- a/Documentation/filesystems/locking.rst
+++ b/Documentation/filesystems/locking.rst
@@ -65,6 +65,8 @@ prototypes::
 	struct dentry * (*lookup) (struct inode *,struct dentry *, unsigned int);
 	int (*link) (struct dentry *,struct inode *,struct dentry *);
 	int (*unlink) (struct inode *,struct dentry *);
+	int (*unlink_shared) (struct inode *,struct dentry *);
+	void (*unlink_shared_done) (struct inode *,struct dentry *);
 	int (*symlink) (const struct mnt_idmap *, struct inode *,struct dentry *,const char *);
 	struct dentry *(*mkdir) (const struct mnt_idmap *, struct inode *,struct dentry *,umode_t);
 	int (*rmdir) (struct inode *,struct dentry *);
@@ -107,6 +109,7 @@ mknod:		exclusive
 symlink:	exclusive
 mkdir:		exclusive
 unlink:		exclusive (both)
+unlink_shared:	shared on parent, exclusive on victim (see below)
 rmdir:		exclusive (both)(see below)
 rename:		exclusive (both parents, some children)	(see below)
 readlink:	no
@@ -128,12 +131,16 @@ get_offset_ctx  no
 ==============	==================================================
 
 
-	Additionally, ->rmdir(), ->unlink() and ->rename() have ->i_rwsem
-	exclusive on victim.
+	Additionally, ->rmdir(), ->unlink(), ->unlink_shared() and ->rename()
+	have ->i_rwsem exclusive on victim.
 	cross-directory ->rename() has (per-superblock) ->s_vfs_rename_sem.
-	->unlink() and ->rename() have ->i_rwsem exclusive on all non-directories
-	involved.
+	->unlink(), ->unlink_shared() and ->rename() have ->i_rwsem exclusive
+	on all non-directories involved.
 	->rename() has ->i_rwsem exclusive on any subdirectory that changes parent.
+	->unlink_shared_done() has ->i_rwsem shared on the parent and nothing
+	on the victim.  It is not an operation on the directory but the end of
+	one, and is described with ->unlink_shared() below rather than listed
+	above.
 
 	->atomic_open() with O_CREAT set is called with ->i_rwsem on the
 	parent held exclusive, unless the filesystem has set
@@ -168,7 +175,8 @@ get_offset_ctx  no
 	Nothing else changes: ->create(), ->link(), ->unlink(), ->mkdir(),
 	->rmdir(), ->mknod(), ->symlink() and ->rename() still take
 	->i_rwsem exclusive on the parent, so a create holding it shared
-	still excludes them.
+	still excludes them.  It does not exclude ->unlink_shared(), if the
+	filesystem provides that as well; see below.
 
 	The flag is also ignored, and the parent taken exclusive, on a
 	superblock that has set SB_I_NAMES_COLLIDE in ->s_iflags.  A
@@ -214,6 +222,168 @@ get_offset_ctx  no
 	dentries being allocated under ->i_rwsem, which is planned to
 	change.
 
+	->unlink_shared() is an optional second removal method.  For a
+	directory whose ->i_op provides it together with ->unlink() and
+	->unlink_shared_done(), filename_unlinkat() - the path of unlink(2),
+	and of unlinkat(2) without AT_REMOVEDIR - takes ->i_rwsem on the
+	parent shared and calls ->unlink_shared() where it used to call
+	->unlink().  ->unlink() itself is still called only with the parent
+	held exclusive: by the retry described below, and by every other
+	caller of vfs_unlink(), none of which changes.  So each of the two
+	methods knows the mode of the parent lock from having been called,
+	and neither needs to ask the lock.  On a superblock that has set
+	SB_I_NAMES_COLLIDE, ->unlink_shared() is not called, for the reason
+	given for O_CREAT above: the exclusion it installs is per name as
+	the dcache compares names.  The VFS reads the bit before it takes
+	the parent lock, so a removal that read it clear may still call
+	->unlink_shared() after it is set; a filesystem that sets the bit
+	while mounted must hand such a removal back.
+
+	->unlink_shared_done() is the other half of the method and is
+	mandatory with it: a directory whose ->i_op has one without the
+	other has not opted in, and its removals go to ->unlink() with the
+	parent held exclusive as before.  The VFS calls it for every call of
+	->unlink_shared() that did not return a positive value, and for no
+	other, with ->i_rwsem on the parent still held shared and nothing
+	held on the victim, after any delete event for the removal and
+	before the parent lock is dropped.  It is where the exclusion
+	->unlink_shared() installed for the name ends; see the order of
+	notifications below.
+
+	With the parent held shared the VFS still provides this much.  The
+	dentry was resolved under this hold of the lock through
+	d_alloc_parallel(); it is positive, is not a directory, and is
+	referenced until after the method returns.  ->i_rwsem on the victim
+	is held exclusive across the call, as it is for ->unlink(), so two
+	removals of one inode are serialized.  ->create(), ->link(),
+	->symlink(), ->mkdir(), ->mknod(), ->rmdir() and ->rename() still
+	take the parent exclusive and so are still excluded.  And while the
+	dentry stays hashed, no second dentry for its name can be hashed:
+	d_alloc_parallel() returns a hashed dentry rather than creating
+	in-lookup state for the name, so a lookup or an open that resolves
+	the name calls ->d_revalidate() on that dentry, and a hashed
+	positive dentry is never passed to ->atomic_open().
+
+	What the VFS no longer provides is exclusion of ->lookup(), of any
+	->atomic_open() called with the parent held shared (with O_CREAT
+	too, if the filesystem has set IOPF_ATOMIC_OPEN_CREATE_SHARED), of
+	->iterate_shared() or of a second ->unlink_shared() for the same
+	name.  Nor does it keep the dentry hashed: a lookup whose
+	->d_revalidate() fails d_invalidate()s it, and d_delete() on behalf
+	of another remover of the name unhashes it while it is still
+	positive.  Nor is anything except a lookup of the name routed
+	through ->d_revalidate(): the filesystem's own users of d_lookup()
+	and d_alloc_parallel(), readdir priming among them, reach the
+	dentry directly.
+
+	The filesystem therefore orders the removal itself against every
+	lookup, open and create of the same name that the parent lock no
+	longer excludes, and against its own directory listings: a listing
+	that the backing store may have produced before a removal took
+	effect - one begun before the removal, or while it was in flight -
+	must not instantiate the removed name, and must not refresh the
+	inode being removed, once that removal may have completed.
+	Whatever it anchors that ordering on is found through the dcache,
+	which compares names as the filesystem's dentry operations do, byte
+	for byte without them.  If the backing store treats two names as
+	one object where those do not compare equal, through case folding
+	or Unicode normalization, the removal of one name is not ordered
+	against a lookup or open of the other that the parent lock no
+	longer excludes.  Such removals must be handed back, and where the
+	filesystem cannot tell that they can happen, that is a limitation
+	it documents.
+
+	One arrangement that provides the ordering is a per-dentry marker
+	that ->d_revalidate() waits on, kept by these rules:
+
+	- the marker is installed under ->d_lock, and only on a dentry that
+	  in that same ->d_lock section is still hashed, is still positive
+	  and has no reference but the caller's.  A resolver that can fail
+	  ->d_revalidate(), and so have the dentry unhashed, takes its
+	  reference before it consults ->d_revalidate(), so with a count of
+	  one every resolver that consults ->d_revalidate() after the marker
+	  is installed finds it and waits.  In that same ->d_lock section,
+	  after installing the marker and not before, invalidate ->d_seq
+	  (write_seqcount_invalidate(), whose barrier orders only earlier
+	  stores): an RCU-walk that consulted ->d_revalidate() before the
+	  marker was installed then fails its ->d_seq recheck when it takes
+	  its reference, and retries in ref-walk, where it finds the marker
+	  and waits.  The one resolver this does not reach is an open by
+	  file handle, whose reference comes from d_obtain_alias() without a
+	  ->d_revalidate(); the exclusive parent lock never excluded it
+	  either;
+	- RCU-walk consults ->d_revalidate() without a reference and cannot
+	  wait, so for the rule above to hold ->d_revalidate() must answer
+	  -ECHILD under LOOKUP_RCU while the marker is set, and must never
+	  answer 0 under LOOKUP_RCU.  -ECHILD sends the walk to ref-walk,
+	  where the consult is repeated with a reference held;
+	- none of the filesystem's own paths but the remover's unhashes the
+	  dentry while the marker is set, and the remover does so only once
+	  the backing store has answered its removal; none hands the dentry
+	  to a caller as the result of a lookup without waiting for the
+	  marker.  Erring toward leaving the dentry hashed is safe: a later
+	  resolver of the name waits for the removal, after which the
+	  remover's own d_delete() normally unhashes it, and an open by path
+	  that fails on it with -EOPENSTALE is retried by the VFS, first in
+	  ref-walk if it was begun in RCU-walk and, if it fails again, with
+	  LOOKUP_REVAL, which tells ->d_revalidate() not to trust its cache;
+	- the marker is cleared in ->unlink_shared_done() and not before
+	  ->unlink_shared() returns, so that it outlasts the delete event the
+	  VFS emits for the removal;
+	- anything else - a second reference, a dentry that is no longer
+	  hashed, a removal the filesystem would carry out by renaming - is
+	  answered with UNLINK_NEED_EXCL.
+
+	UNLINK_NEED_EXCL is a positive value that only ->unlink_shared() may
+	return.  It says that this removal cannot be made with the parent
+	held shared and that nothing was done.  The VFS then drops the lock,
+	takes it exclusive, looks the name up again and calls ->unlink(),
+	which cannot ask again.  A directory found by the shared lookup is
+	sent the same way without the method being called, unless the name
+	ends in a slash, which is answered -EISDIR from its type alone; so
+	->unlink_shared() is never passed a directory.  A removal that the
+	method hands back runs the permission check, the audit record, both
+	security hooks and both delegation checks once in each pass, and its
+	name is looked up twice.
+
+	A lookup that holds the parent shared can now wait in
+	->d_revalidate() for such a removal, for as long as the removal
+	takes; before, it would have waited for the parent lock instead.  If
+	the filesystem's wait there is uninterruptible, so is this one.
+
+	The order of notifications for one name is what
+	->unlink_shared_done() keeps.  ->unlink_shared() returns with its
+	exclusion for the name still installed; the VFS emits the delete
+	event for the removal, then calls ->unlink_shared_done() to end it,
+	then drops the parent lock.  A creator of the name that the call
+	releases emits its create event after that delete event whichever
+	mode it holds the parent in: one that takes the parent exclusive is
+	waiting for a lock that is held until after the call, and one that
+	holds it shared - an O_CREAT ->atomic_open(), once the filesystem
+	has set IOPF_ATOMIC_OPEN_CREATE_SHARED - is waiting for the
+	exclusion itself.  A filesystem that ends its exclusion inside
+	->unlink_shared() instead loses that order against a creator of the
+	second kind: the create event can come before the delete event of
+	the removal it waited for, and a watcher then concludes that the
+	name is gone while it exists.  That is why ->unlink_shared_done() is
+	not optional.
+
+	What this does not order is a creator that never met the exclusion.
+	When d_delete_notify() unhashes the name before it emits the event -
+	when another reference is held at the delete, or the
+	fs.dentry-negative sysctl is set - a resolver that arrives after the
+	unhash finds no dentry for the name, makes its own, and is ordered
+	against the removal by nothing; the window is the span of the event
+	itself.  Nor does any of this decide what a creator released by
+	->unlink_shared_done() goes on to resolve: the dentry it was waiting
+	on may still be positive, and whether ->d_revalidate() then sends it
+	to the backing store is the filesystem's answer and not the VFS's.
+
+	->unlink_shared() is meant as a transitional interface.  It lets one
+	filesystem at a time stop relying on the exclusive parent lock for
+	removal, and ->unlink() and ->unlink_shared() can become one again
+	once removal locks the target dentry and not the parent.
+
 See Documentation/filesystems/directory-locking.rst for more detailed discussion
 of the locking scheme for directory operations.
 
diff --git a/Documentation/filesystems/porting.rst b/Documentation/filesystems/porting.rst
index c38f5df755..029c178e2f 100644
--- a/Documentation/filesystems/porting.rst
+++ b/Documentation/filesystems/porting.rst
@@ -1422,3 +1422,38 @@ helpers take a const struct mnt_idmap *. mnt_idmap() and file_mnt_idmap()
 return one. The idmapping is immutable so nothing should have modified it
 anyway. References are taken and dropped via mnt_idmap_get() and
 mnt_idmap_put() as before, both accept a const pointer.
+
+---
+
+**informational**
+
+->unlink_shared() is added, as an optional inode operation.  A filesystem
+that does not provide it sees no change: ->unlink() is still called with the
+parent's ->i_rwsem held exclusive.  One that provides it has unlink(2) call
+it with the parent held shared instead, and takes on ordering a removal
+against the lookups and opens of the same name that the lock no longer
+excludes, and against its own directory listings.  It may return
+UNLINK_NEED_EXCL, having done nothing, to have ->unlink() called for that
+removal with the parent held exclusive after all; ->unlink() has to stay
+correct for that case and for every other caller of vfs_unlink().
+
+->unlink_shared() is paired with ->unlink_shared_done() and needs it: a
+filesystem that provides one without the other has not opted in.  Whatever
+->unlink_shared() installed to order the removal against the resolvers of the
+name is still installed when it returns, and ->unlink_shared_done() ends it,
+after any delete event the VFS emits for the removal.  The VFS calls it for
+every call of ->unlink_shared() that did not return a positive value, and for
+no other.
+
+For such a filesystem the ->iterate_shared() entry above no longer holds in
+full.  ->iterate_shared() is not excluded from that removal, and for dcache
+pre-seeding d_alloc_parallel() alone is not enough: a listing that may have
+been produced before a removal took effect, including one begun while the
+removal was in flight, must not instantiate the removed name, or refresh the
+inode being removed, once that removal may have completed.  See
+Documentation/filesystems/locking.rst.
+
+If the filesystem has also set IOPF_ATOMIC_OPEN_CREATE_SHARED, the opens
+that the lock no longer excludes include O_CREAT ones.  That flag already
+makes the ->iterate_shared() entry untrue for those opens, which hold the
+parent shared alongside ->iterate_shared().
diff --git a/Documentation/filesystems/vfs.rst b/Documentation/filesystems/vfs.rst
index 1824462a43..a6eeac44e1 100644
--- a/Documentation/filesystems/vfs.rst
+++ b/Documentation/filesystems/vfs.rst
@@ -419,6 +419,8 @@ As of kernel 2.6.22, the following members are defined:
 		struct dentry * (*lookup) (struct inode *,struct dentry *, unsigned int);
 		int (*link) (struct dentry *,struct inode *,struct dentry *);
 		int (*unlink) (struct inode *,struct dentry *);
+		int (*unlink_shared) (struct inode *,struct dentry *);
+		void (*unlink_shared_done) (struct inode *,struct dentry *);
 		int (*symlink) (const struct mnt_idmap *, struct inode *,struct dentry *,const char *);
 		struct dentry *(*mkdir) (const struct mnt_idmap *, struct inode *,struct dentry *,umode_t);
 		int (*rmdir) (struct inode *,struct dentry *);
@@ -481,6 +483,29 @@ otherwise noted.
 	called by the unlink(2) system call.  Only required if you want
 	to support deleting inodes
 
+``unlink_shared``
+	optional.  As ``unlink``, but called by the unlink(2) system
+	call with the parent directory's i_rwsem held shared, not
+	exclusive, and never for a directory.  Providing it, together
+	with ``unlink`` and ``unlink_shared_done``, is how a filesystem
+	opts in to concurrent removals in one directory; the filesystem
+	then itself orders a removal against the lookups and opens of the
+	same name that the lock no longer excludes, and against its own
+	directory listings.  It may return UNLINK_NEED_EXCL, having done
+	nothing, and the VFS then calls ``unlink`` for that removal with
+	the lock held exclusive.  ``unlink`` is still what every other
+	caller uses.  ``unlink_shared`` is not called on a superblock that
+	has set SB_I_NAMES_COLLIDE, except by a removal that read the bit
+	before it was set.  See Documentation/filesystems/locking.rst.
+
+``unlink_shared_done``
+	required with ``unlink_shared``.  Called after every call of
+	``unlink_shared`` that did not return a positive value, whether
+	the removal succeeded or not, after any delete event for it and
+	before the parent directory's i_rwsem is dropped, to end the
+	exclusion for the name that ``unlink_shared`` set up.  See
+	Documentation/filesystems/locking.rst.
+
 ``symlink``
 	called by the symlink(2) system call.  Only required if you want
 	to support symlinks.  You will probably need to call
diff --git a/fs/namei.c b/fs/namei.c
index 1b3a605ded..0028a18fb1 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2958,6 +2958,116 @@ void end_dirop(struct dentry *de)
 }
 EXPORT_SYMBOL(end_dirop);
 
+/*
+ * Resolve @name in @base for a removal, with the parent's i_rwsem held and
+ * possibly only shared.  Unlike lookup_one_qstr_excl() this uses the
+ * in-lookup protocol -- d_alloc_parallel() rather than d_alloc() plus
+ * ->lookup() -- because only that excludes a second resolver of the same
+ * name when the parent lock does not.  A negative result is -ENOENT;
+ * LOOKUP_CREATE and LOOKUP_EXCL have no meaning here.
+ *
+ * A directory is returned like anything else, and the caller must let go
+ * of it having looked at no more than its type: __d_unalias() can move or
+ * rename a directory alias holding its parent's i_rwsem no more than
+ * shared, which a shared hold does not exclude.  A non-directory's parent
+ * and name change only in __d_move() for a rename or a silly-rename, both
+ * of which hold the parent exclusive.
+ */
+static struct dentry *lookup_one_qstr_shared(const struct qstr *name,
+					     struct dentry *base,
+					     unsigned int flags)
+{
+	/* LOOKUP_SHARED: the parent is held shared, as for lookup_slow() */
+	struct dentry *dentry = __lookup_slow(name, base, flags | LOOKUP_SHARED);
+
+	if (IS_ERR(dentry))
+		return dentry;
+	if (d_is_negative(dentry)) {
+		dput(dentry);
+		return ERR_PTR(-ENOENT);
+	}
+	return dentry;
+}
+
+/**
+ * start_dirop_shared - begin a removal with the parent held shared
+ * @parent:       the dentry of the parent in which the operation will occur
+ * @name:         a qstr holding the name within that parent
+ * @lookup_flags: intent and other lookup flags
+ *
+ * As start_dirop(), except that the parent's i_rwsem is taken shared, so
+ * what excludes a concurrent operation on this name is not the lock.  It is
+ * the returned dentry -- positive, referenced for as long as the caller
+ * holds it, and resolved under this hold through d_alloc_parallel() -- and
+ * whatever the filesystem builds on that, because the VFS does not keep the
+ * dentry hashed.  Only for a directory whose filesystem provides
+ * ->unlink_shared().
+ *
+ * end_dirop_shared() must be used to finish, not end_dirop().
+ *
+ * Returns: a positive dentry, which may be a directory, or an error.
+ */
+static struct dentry *start_dirop_shared(struct dentry *parent,
+					 struct qstr *name,
+					 unsigned int lookup_flags)
+{
+	struct inode *dir = d_inode(parent);
+	struct dentry *dentry;
+
+	/* I_MUTEX_PARENT, as __start_dirop(): __vfs_unlink() nests
+	 * inode_lock() on the victim inside this one.
+	 */
+	inode_lock_shared_nested(dir, I_MUTEX_PARENT);
+	dentry = lookup_one_qstr_shared(name, parent, lookup_flags);
+	if (IS_ERR(dentry))
+		inode_unlock_shared(dir);
+	return dentry;
+}
+
+/**
+ * end_dirop_shared - signal completion of a dirop started shared
+ * @parent: the parent that was passed to start_dirop_shared()
+ * @de: the dentry which was returned by start_dirop_shared()
+ *
+ * As end_dirop(), for the shared lock.  If @de is an error, nothing
+ * happens.  The lock dropped is the one start_dirop_shared() took, not
+ * re-derived from @de->d_parent as end_dirop() does: it is the exclusive
+ * parent lock that makes a child's d_parent stable, and this is not it.
+ */
+static void end_dirop_shared(struct dentry *parent, struct dentry *de)
+{
+	if (!IS_ERR(de)) {
+		inode_unlock_shared(d_inode(parent));
+		dput(de);
+	}
+}
+
+/*
+ * The pair filename_unlinkat() begins and ends a removal with: the shared
+ * pair above when @unlink_shared is the method it read, start_dirop() and
+ * end_dirop() when it is NULL.  The caller passes the same pointer to both.
+ */
+static struct dentry *start_unlink_dirop(struct dentry *parent,
+					 struct qstr *name,
+					 unsigned int lookup_flags,
+					 int (*unlink_shared)(struct inode *,
+							      struct dentry *))
+{
+	if (unlink_shared)
+		return start_dirop_shared(parent, name, lookup_flags);
+	return start_dirop(parent, name, lookup_flags);
+}
+
+static void end_unlink_dirop(struct dentry *parent, struct dentry *de,
+			     int (*unlink_shared)(struct inode *,
+						  struct dentry *))
+{
+	if (unlink_shared)
+		end_dirop_shared(parent, de);
+	else
+		end_dirop(de);
+}
+
 /* does lookup, returns the object with parent locked */
 struct dentry *start_removing_path(const char *name, struct path *path)
 {
@@ -5683,7 +5793,9 @@ static int __vfs_unlink(const struct mnt_idmap *idmap, struct inode *dir,
 			struct dentry *dentry,
 			struct delegated_inode *delegated_inode,
 			int (*method)(struct inode *dir,
-				      struct dentry *dentry));
+				      struct dentry *dentry),
+			void (*done)(struct inode *dir,
+				     struct dentry *dentry));
 
 /**
  * vfs_unlink - unlink a filesystem object
@@ -5713,21 +5825,40 @@ static int __vfs_unlink(const struct mnt_idmap *idmap, struct inode *dir,
 int vfs_unlink(const struct mnt_idmap *idmap, struct inode *dir,
 	       struct dentry *dentry, struct delegated_inode *delegated_inode)
 {
-	return __vfs_unlink(idmap, dir, dentry, delegated_inode, NULL);
+	return __vfs_unlink(idmap, dir, dentry, delegated_inode, NULL, NULL);
 }
 EXPORT_SYMBOL(vfs_unlink);
 
 /*
  * The body of vfs_unlink().  @method, if not NULL, is called in place of
- * dir->i_op->unlink(); vfs_unlink() passes NULL.
+ * dir->i_op->unlink(); vfs_unlink() passes NULL, so ->unlink() is still
+ * called only with dir->i_rwsem held exclusive.  vfs_unlink_shared() passes
+ * the directory's ->unlink_shared(), which its caller read before taking
+ * the lock, to choose the shared mode it then took.  It is passed in, not
+ * read here, so that the lock mode and the method come from one read of
+ * ->i_op.  A positive return from it means that nothing was removed:
+ * everything that follows a removal is skipped, and the value is handed
+ * back.
+ *
+ * @done is the directory's ->unlink_shared_done(), from that same read of
+ * ->i_op: both or neither.  It is called when @method has been called and
+ * has not handed the removal back, after any event for the removal is out
+ * and before the caller drops the parent's lock, to end the exclusion for
+ * the name that @method returned still holding.  A creator of the name that
+ * the call releases therefore cannot have its create event out first.  The
+ * paths that do not reach @method installed no exclusion and so make no
+ * call: this is the one function that knows which of the two happened.
  */
 static int __vfs_unlink(const struct mnt_idmap *idmap, struct inode *dir,
 			struct dentry *dentry,
 			struct delegated_inode *delegated_inode,
 			int (*method)(struct inode *dir,
-				      struct dentry *dentry))
+				      struct dentry *dentry),
+			void (*done)(struct inode *dir,
+				     struct dentry *dentry))
 {
 	struct inode *target = dentry->d_inode;
+	bool call_done = false;
 	int error = may_delete_dentry(idmap, dir, dentry, false);
 
 	if (error)
@@ -5750,10 +5881,13 @@ static int __vfs_unlink(const struct mnt_idmap *idmap, struct inode *dir,
 			error = try_break_deleg(target, 0, delegated_inode);
 			if (error)
 				goto out;
-			if (method)
+			if (method) {
 				error = method(dir, dentry);
-			else
+				/* A positive return left nothing to end. */
+				call_done = error <= 0;
+			} else {
 				error = dir->i_op->unlink(dir, dentry);
+			}
 			if (!error) {
 				dont_mount(dentry);
 				detach_mounts(dentry);
@@ -5771,9 +5905,43 @@ static int __vfs_unlink(const struct mnt_idmap *idmap, struct inode *dir,
 		d_delete_notify(dir, dentry);
 	}
 
+	/*
+	 * After the event, so that the exclusion the method kept for the name
+	 * outlasts it: a creator of the name waiting for that exclusion is
+	 * still waiting while the event is delivered, and one waiting for the
+	 * parent's lock is waiting for a lock the caller still holds.
+	 */
+	if (call_done)
+		done(dir, dentry);
+
 	return error;
 }
 
+/*
+ * As vfs_unlink(), for a caller that read @unlink_shared, the directory's
+ * ->unlink_shared(), to choose the lock mode, and then took dir->i_rwsem
+ * shared.  @dentry must be a non-directory that start_dirop_shared()
+ * resolved under that hold.  Returns a positive value, UNLINK_NEED_EXCL,
+ * with nothing removed, if the filesystem could not do it with the lock
+ * shared; the caller then does it again through vfs_unlink() with the lock
+ * held exclusive.  @unlink_shared_done is the directory's
+ * ->unlink_shared_done(), from the same read of ->i_op, and goes with it.
+ * Not exported: filename_unlinkat() is the only caller.
+ */
+static int vfs_unlink_shared(const struct mnt_idmap *idmap, struct inode *dir,
+			     struct dentry *dentry,
+			     struct delegated_inode *delegated_inode,
+			     int (*unlink_shared)(struct inode *dir,
+						  struct dentry *dentry),
+			     void (*unlink_shared_done)(struct inode *dir,
+							struct dentry *dentry))
+{
+	/* A directory is never kept under the shared lock. */
+	VFS_WARN_ON_ONCE(d_is_dir(dentry));
+	return __vfs_unlink(idmap, dir, dentry, delegated_inode,
+			    unlink_shared, unlink_shared_done);
+}
+
 /*
  * Make sure that the actual truncation of the file will occur outside its
  * directory's i_rwsem.  Truncate can take a long time if there is a lot of
@@ -5790,7 +5958,16 @@ int filename_unlinkat(int dfd, struct filename *name)
 	struct inode *inode;
 	struct delegated_inode delegated_inode = { };
 	unsigned int lookup_flags = 0;
+	const struct inode_operations *iop;
+	int (*unlink_shared)(struct inode *dir, struct dentry *dentry);
+	void (*unlink_shared_done)(struct inode *dir, struct dentry *dentry);
+	bool force_excl = false;
 retry:
+	/*
+	 * An -ESTALE re-resolution starts over: an escalation a previous pass
+	 * asked for applied to the dentry that pass found, not to this one.
+	 */
+	force_excl = false;
 	error = filename_parentat(dfd, name, lookup_flags, &path, &last, &type);
 	if (error)
 		return error;
@@ -5803,7 +5980,33 @@ int filename_unlinkat(int dfd, struct filename *name)
 	if (error)
 		goto exit_path_put;
 retry_deleg:
-	dentry = start_dirop(path.dentry, &last, lookup_flags);
+	/*
+	 * One read of ->i_op decides the lock mode, the lookup protocol, the
+	 * method that is called and the unlock.  What is read is the method
+	 * itself, and that is what is passed down, so the method that chose
+	 * the lock mode is the method that is called, and nothing below goes
+	 * back to ->i_op for it.  It is read after retry_deleg: so that each
+	 * acquisition of the lock reads it afresh.  The exclusive retry needs
+	 * ->unlink(), so a filesystem that provides only ->unlink_shared() has
+	 * not opted in.  Nor has one that provides it without
+	 * ->unlink_shared_done(): the exclusion the first installs for the name
+	 * is ended by the second, and there is nowhere else to end it, so the
+	 * three are taken together or not at all.  Nor on a superblock that
+	 * has set SB_I_NAMES_COLLIDE: the exclusion the method installs is per
+	 * name as the dcache compares names, as an O_CREAT open's is, and it
+	 * is tested last for the same reason; see atomic_open_create_shared().
+	 * An O_CREAT open follows the same rule in lookup_open().
+	 */
+	iop = path.dentry->d_inode->i_op;
+	unlink_shared = force_excl ? NULL : iop->unlink_shared;
+	unlink_shared_done = iop->unlink_shared_done;
+	if (!iop->unlink || !unlink_shared || !unlink_shared_done ||
+	    (READ_ONCE(path.dentry->d_sb->s_iflags) & SB_I_NAMES_COLLIDE)) {
+		unlink_shared = NULL;
+		unlink_shared_done = NULL;
+	}
+	dentry = start_unlink_dirop(path.dentry, &last, lookup_flags,
+				    unlink_shared);
 	error = PTR_ERR(dentry);
 	if (IS_ERR(dentry))
 		goto exit_drop_write;
@@ -5814,24 +6017,59 @@ int filename_unlinkat(int dfd, struct filename *name)
 			error = -EISDIR;
 		else
 			error = -ENOTDIR;
-		end_dirop(dentry);
+		end_unlink_dirop(path.dentry, dentry, unlink_shared);
 		goto exit_drop_write;
 	}
+	/*
+	 * A directory is not kept under the shared lock.  __d_unalias() can
+	 * move or rename a directory alias while holding its parent no more
+	 * than shared, and may_delete_dentry() looks at ->d_parent in a
+	 * BUG_ON() before it answers -EISDIR.  Nothing above looked at more
+	 * than the type, and end_dirop_shared() unlocks the parent it is
+	 * given.  Do it again with the lock held exclusive, where the answer
+	 * is the one it has always been.
+	 */
+	if (unlink_shared && d_is_dir(dentry)) {
+		end_dirop_shared(path.dentry, dentry);
+		force_excl = true;
+		goto retry_deleg;
+	}
 	inode = dentry->d_inode;
 	ihold(inode);
 	error = security_path_unlink(&path, dentry);
 	if (error)
 		goto exit_end_dirop;
-	error = vfs_unlink(mnt_idmap(path.mnt), path.dentry->d_inode,
-			   dentry, &delegated_inode);
+	if (unlink_shared)
+		error = vfs_unlink_shared(mnt_idmap(path.mnt),
+					  path.dentry->d_inode, dentry,
+					  &delegated_inode, unlink_shared,
+					  unlink_shared_done);
+	else
+		error = vfs_unlink(mnt_idmap(path.mnt), path.dentry->d_inode,
+				   dentry, &delegated_inode);
 exit_end_dirop:
-	end_dirop(dentry);
+	end_unlink_dirop(path.dentry, dentry, unlink_shared);
 	iput(inode);	/* truncate the inode here */
 	if (is_delegated(&delegated_inode)) {
 		error = break_deleg_wait(&delegated_inode);
 		if (!error)
 			goto retry_deleg;
 	}
+	/*
+	 * UNLINK_NEED_EXCL: ->unlink_shared() cannot do this one with the
+	 * parent held shared, and did nothing.  Do it again with the lock
+	 * held exclusive, through ->unlink(), which cannot ask again; that
+	 * bounds this.  Every positive value is treated alike, so none
+	 * reaches user space from the shared pass.  Being positive, it is
+	 * neither an errno nor the delegation return handled above, which is
+	 * made before the method is called.
+	 */
+	if (unlink_shared && unlikely(error > 0)) {
+		force_excl = true;
+		goto retry_deleg;
+	}
+	/* Only ->unlink_shared() may return a positive value. */
+	VFS_WARN_ON_ONCE(error > 0);
 exit_drop_write:
 	mnt_drop_write(path.mnt);
 exit_path_put:
diff --git a/include/linux/fs.h b/include/linux/fs.h
index f14520194b..c3dea996c0 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2041,8 +2041,41 @@ struct inode_operations {
 	int (*fileattr_get)(struct dentry *dentry, struct file_kattr *fa);
 	struct offset_ctx *(*get_offset_ctx)(struct inode *inode);
 	iop_flags_t iop_flags;
+	/* Last, not beside ->unlink, so that no other member moves */
+	int (*unlink_shared)(struct inode *dir, struct dentry *dentry);
+	void (*unlink_shared_done)(struct inode *dir, struct dentry *dentry);
 } ____cacheline_aligned;
 
+/**
+ * enum unlink_shared_returns - positive returns of ->unlink_shared()
+ *
+ * @UNLINK_NEED_EXCL: this removal cannot be made with the parent's i_rwsem
+ *	held shared, and nothing was done.  The VFS drops the lock, takes it
+ *	exclusive, looks the name up again and calls ->unlink() for it, which
+ *	cannot ask again.
+ *
+ * ->unlink_shared() is ->unlink() for a filesystem that can remove a
+ * non-directory with the parent's i_rwsem held shared; providing it, along
+ * with ->unlink() and ->unlink_shared_done(), is the opt-in.  The VFS calls
+ * it only with the lock held shared and goes on calling ->unlink() only with
+ * the lock held exclusive, so neither method has to ask which mode it was
+ * given.  It returns 0, a negative errno, or a value from this enum, which
+ * no other inode operation may return.  What the VFS still provides under
+ * the shared lock, and what the filesystem owes for the exclusion the lock
+ * no longer gives, is set out in Documentation/filesystems/locking.rst.
+ *
+ * ->unlink_shared() returns with whatever it installed to order the removal
+ * against the resolvers of the name still installed, and
+ * ->unlink_shared_done() ends it.  The VFS calls that after any delete
+ * event for the removal and before it drops the parent's i_rwsem, for every
+ * call of ->unlink_shared() that did not return a positive value and for no
+ * other, so a filesystem providing one without the other has not opted in
+ * and its removals keep the exclusive lock.
+ */
+enum unlink_shared_returns {
+	UNLINK_NEED_EXCL	= 1,
+};
+
 /*
  * ->atomic_open() may be called with the parent directory's i_rwsem held
  * shared even when O_CREAT is set.  A filesystem setting this accepts that,
@@ -2066,7 +2099,11 @@ struct inode_operations {
  *    serialized against all of them.  It runs concurrently with other
  *    O_CREAT opens, with an ->atomic_open() for the same or another name
  *    without O_CREAT, and with ->lookup() and ->iterate_shared(), which
- *    already run with i_rwsem held shared.
+ *    already run with i_rwsem held shared.  A filesystem that also
+ *    provides ->unlink_shared() adds the removal of a non-directory to
+ *    that list, the same name included: it orders the two itself, and
+ *    ->unlink_shared_done() is what keeps the order of their
+ *    notifications for one name.  See enum unlink_shared_returns above.
  *
  * Ignored unless the filesystem also provides ->atomic_open, and ignored on
  * a superblock with SB_I_NAMES_COLLIDE set in ->s_iflags: there the in-lookup
-- 
2.43.0

