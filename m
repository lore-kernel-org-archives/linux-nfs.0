Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.50
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297404;
	b=5Yp1jshfyY/tTcOykIpT/mWDTc/wICxMnuokhRvAYILx6bCIomdLfremhMgLqWaWpCtB
	 LzYLNXNLEkJmu/ul6ZEU2EQcr71QukbiqUXFjoCUQhZhEyxCLsZjeuG8ovy4nZvkhjTPq
	 +QteVU9IVWJzcqeDlwEBBi86SoHYE3QkZZBQEDMMlgogqLuExTlfB2zrT9POOHTvFoMMp
	 TFGagpLls7uEercFijXHsMBAzTeOW2+GFFnFkyjiaMiCMbNzqj9t8JJrTDN2+OU7rDxS4
	 eSxEp1Y7KiXlqy6/ddm1Z/arY7IaIKI/DZjvbe/I8inDoPCjrPsZZ63nNtT6T8GNJGg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297404;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=O11jiG57nemh67LvGOodj7boyGYJ53ph3c5MQLBtbwQ=;
	b=gmisquAWgm1ROiYKHZVgUf4tzl/rmxtPxSdr6m9Mt7jfGTNKbfkzxqVqx84RGENYC+gl
	 4PN1vqiHDuFgTH6yNW/EJheI4+hSmmiYG5nxGkohBs+nieRvzKxhR7PUlnplv0S75sp0E
	 3XMNXDamV3NMU8OBzBx+gzrwrZj4UziJKTWhvrqzuQe/0JREwslvXU48dlUxtNqwYP+Iu
	 /6xTl6Y4o10G0KKZqKPj7gi5PzJXaM6Upgt0BGuD22Ld2N50uIV/qrmb7jtA9itFWBluF
	 6PDwrucIeAAfhkhpzq1vCMjRO1V+hSMj7XxKhvtm+tb+NUmzKIvhKgNf4bAuTrBmHkQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Nny3L9pL;
	arc=none smtp.remote-ip=209.85.210.50
Received: from mail-ot1-f50.google.com (mail-ot1-f50.google.com [209.85.210.50])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5AD4C60A3839
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:10:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5AD4C60A3839
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Nny3L9pL
Received: by mail-ot1-f50.google.com with SMTP id 46e09a7af769-843b6f8e2c7so2732649a34.1
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:10:03 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793297402; x=1793902202; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=O11jiG57nemh67LvGOodj7boyGYJ53ph3c5MQLBtbwQ=;
        b=Nny3L9pL2u7eGhEMUwOOxsAKWvGmBqGCQw6aYjuubJRSDm4UNvFpJp335cLrXzbxRV
         uNSBqsSFJ+qgYzjCXZVD/p6gWJCSv0uX7mpUjxGvKiSnDGBGjWMQva2a3Fnnv+b+PMld
         JzKqDxJ3IV/hZRydfHFBOrnIAC8bT5pUziS2DzqupxlCilg30kQnYPJCVUomEc/I2/Hd
         UfTZngjdorjkqw15ve3SSoPBARhrVnSpB6nw9hTc1jg1dH9vIqjry/uAhF5+dykSsOl5
         q9rjRQd8jO9N1bDzjJfAsskgJA0Cuf9qnPQJ+YYND7Ivni0MYV9X0wXvzZ3jQIzpPmTS
         zZEA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793297402; x=1793902202;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=O11jiG57nemh67LvGOodj7boyGYJ53ph3c5MQLBtbwQ=;
        b=sFB07rjnwRdCQMcmTp07heBE5RcMIRGCKJ+aAQo7qEpx+XOCLb/+sOa2Sqvmg7Dft1
         s4rO2zRueOKyrYdtLJG1WMC9Dht9G+HtD8REQwjMIHpxA4BI8y0TK7c1tNQwEk1nnfwT
         dlAiWyd4+e5ytFg6LaWXPus0B321iH5NbAwmNaUf1QnemS2uh3pb+nXfw+OZSoZius+U
         CsQCRbjIP7XT+16zc5mXNBDWRcp39L6YopPd+4BychKBARrs9DtrskbdGGbYNWeI5DqU
         mNr/cBJSygOc7ZNTJOzcNf4StEP4Zz1l0DsPijTF28h4tFie02joxoI8Y3H4bWSI/7fr
         4e9g==
X-Forwarded-Encrypted: i=1; AKwUvBzrXqIm3jIoNnn7XI0bNYhCxK5B9bAGnHcvuD+nMNg6tAN53XqWmux4B72Tblb5+Jkhb8tnr7YcxGc=@vger.kernel.org
X-Gm-Message-State: AFq9FYLVqv5PgpahCWr7YUymkSLLiXwonX00iNb4Rxw8DCjfClY4DTpj
	MptoCfOtRdeEgBgtDsEd9C2NJyt5D0A9S6HJ2zRiTghPDThVDOupSmRnmh8IDQULCWg=
X-Gm-Gg: AYBFou0Td7fQWhKmT1nEqEpo3+XLavoemVJA5I4LzAfbQPct7YANdHU4OTLXegmMFvO
	hABVZADdzSIe1z5dmTmtj2t0/WP56KIfCiO3zCbiaPF12ThoIdq3ZCUYPnsGGJNqXvZGIpjwY5v
	QI2vj6Lc7hiTTUqUKxlaCX99JDzDD0z48ynQhOFF7W7GM3QmOU/lce5J20B7wakNeaNi2KMXvN1
	yjA2xhRVaZ1Wmtv0tJaCaIrXWdTKolX9wIZkeQQ7U4cQz/OHw/yiPb/x94hw/ufL2eCqCdbloVq
	Vs9gh8T+6EVwhJ7ws8U1TFxFr94+UAbFobkP+ffrjrdGM7G4MOjzOtLMLe4PCxfj8QCTk72nWuB
	QI2ZMZK+IbVm3/7DPB1/LWuNnRxRdaB4xp6W1/MRNoA0IqXCuXhVYusL5p7DWpx9Np5+QpGJbtv
	5/nA1T5EhGBB4gh66Av6Z4TvBwOn7ajQtXXZaMbZ6J2uNQNRnyeGNKiwH55SDoM70XaQr7AwSto
	X/UVxnvFWU2kAx8SNW9zs9tQ3dB4lXx3raVpuViaghhAK2TT5aqboHJS2XEDP1YgQAi3afPoMSB
	4m+GVwfWOeuS5whFjaygU/TytyBHKj3T4L1jn7emfgyVLp4rDA42ipYDJSmYKrqRVHlhxZzb
X-Received: by 2002:a05:6820:82b:b0:703:4abb:5628 with SMTP id 006d021491bc7-714f256d526mr50115eaf.64.1793297401863;
        Thu, 29 Oct 2026 11:10:01 -0700 (PDT)
Received: from localhost (75-163-200-235.clsp.qwest.net. [75.163.200.235])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-714f287d04fsm35324eaf.0.2026.10.29.11.10.00
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:10:01 -0700 (PDT)
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
Subject: [PATCH RFC 02/12] vfs: allow the parent lock to be shared for O_CREAT
Date: Thu, 29 Oct 2026 12:09:47 -0600
Message-ID: <20261029180957.387138-3-jonathan.flynn@hammerspace.com>
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

The VFS chooses the mode of the parent directory's lock for an open from
the open flags alone: O_CREAT takes it exclusive, everything else
shared.  That choice is made before any filesystem method is reachable,
so a filesystem has nowhere to say that it does not need the exclusive
lock for a create.  For a network filesystem the consequence is direct:
a create is a server round trip, and the exclusive parent lock
serializes those round trips, so creates in one directory proceed one
round trip at a time however many threads are creating.

Add an ->iop_flags field to struct inode_operations, mirroring
->fop_flags, with one flag, IOPF_ATOMIC_OPEN_CREATE_SHARED.  It is
transitional: it chooses how the parent is locked for a create, and goes
away once the VFS no longer takes the parent lock for one.  When a
directory's operations set it and provide ->atomic_open(), lookup_open()
takes the parent shared for an O_CREAT open as well, and then passes
->atomic_open() only an in-lookup dentry; dentry_create(), which nfsd
uses, is still called with the parent held exclusive.  A filesystem
that does not set the flag sees no change: the field is zero.  The
field is the last member of a cacheline-aligned structure, so it
occupies padding that was already there and no existing member moves.

With the parent held shared, exclusion for the name being created
comes from the in-lookup protocol that lookup already relies on under a
shared lock: the first thread to resolve a name publishes an in-lookup
dentry that a second finds and waits on, and the name enters the main
hash once.  Every other directory-modifying operation -- create without
an open, link, unlink, symlink, mkdir, rmdir, mknod and rename -- still
takes the parent exclusive, so a shared create runs concurrently only
with other creates and with what already holds the parent shared:
lookup, readdir and opens without O_CREAT.  Unlink joins them only
where a filesystem also provides ->unlink_shared(), added later in
this series.

One case keeps the exclusive lock even where the flag is set: a
superblock on which two names the dcache tells apart can be one
directory entry, as on a case-insensitive server whose client does not
fold case.  The in-lookup protocol would exclude a second create of
"foo" but not a create of "FOO", so such a filesystem sets
SB_I_NAMES_COLLIDE in ->s_iflags, and may set or clear it while
mounted; creates in its directories then take the parent exclusive.

The VFS has one gap of its own to close.  A cached negative dentry that
revalidates reaches the atomic-open method already hashed, outside the
in-lookup protocol: safe under the exclusive lock, but under a shared
one two threads could each hash a dentry for the name, leaving two
hashed dentries for one name with nothing to detect it.  So, for a
create with the parent held shared, reject such a dentry and go round
the existing loop, so that ->atomic_open() is then only ever handed an
in-lookup dentry.  On the filesystem that opts in later in this series
this happens on every such create over a cached negative dentry, not
only in a race, at the cost of a dentry allocation and an unhash but no
extra round trip.  The rest of what the exclusive lock provided, for
the filesystem's own per-directory state and for a plain open of the
same name, becomes the filesystem's responsibility, as
Documentation/filesystems/locking.rst now states.

Since NeilBrown's "VFS: move mnt_want_write() and locking into
lookup_open()", lookup_open() takes and drops the parent lock itself,
so the flag is read there, once per pass, and decides both the lock
mode and the rejection, with nothing threaded through a signature.
With CONFIG_DEBUG_VFS, lookup_open() also warns if a create made with
the parent held shared is about to hand ->atomic_open() a dentry that
is not in-lookup; lockdep cannot see a missing exclusion, so nothing
else would catch one.

This relies on in-lookup dentries being allocated with the parent's
->i_rwsem held, as d_alloc_parallel() is here.  NeilBrown's
"multiple-filesystems: prepare for changes to VFS locking" plans to
invert that order; if it does, the lookup of the name being created
moves ahead of the shared parent lock, and the exclusion, which is the
dentry's in-lookup state and not the parent lock, is unchanged.

Measured with "nfs: concurrent O_CREAT in one NFSv4 directory" on a
7.1.13-based kernel carrying an earlier revision of both patches, using
a test-only switch, not part of this series, to choose the lock mode at
run time: with 60 processes on one client creating files (open with
O_CREAT, a small write, close) in one directory, creates went from
about 2,700 a second with the parent held exclusive to about 29,700
with it held shared.  The shared rate stayed about flat from one to
four clients, because one client already reached the server's limit.

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
---

Notes:
    For reviewers and review tools; not part of the changelog.
    
    An automated review of this patch (Claude Code running Sashiko's
    review prompts) reported that locking.rst misdescribes a d_rehash()
    of the in-lookup dentry, because a concurrent d_alloc_parallel()
    would find that dentry on the in-lookup chain and wait on it.  It
    was checked and dropped: atomic_open() calls d_lookup_done() as soon
    as ->atomic_open() returns, and that takes the dentry off the
    in-lookup chain without the ->i_dir_seq window.  A
    d_alloc_parallel() that sampled ->i_dir_seq and missed the hash
    before the d_rehash(), and scans the chain after the
    d_lookup_done(), neither retries nor waits, and hashes a second
    dentry for the name: the outcome the text describes.

 .../filesystems/directory-locking.rst         | 19 ++++
 Documentation/filesystems/locking.rst         | 81 ++++++++++++++++-
 fs/namei.c                                    | 86 +++++++++++++++++--
 include/linux/fs.h                            | 35 ++++++++
 include/linux/fs/super_types.h                |  1 +
 5 files changed, 214 insertions(+), 8 deletions(-)

diff --git a/Documentation/filesystems/directory-locking.rst b/Documentation/filesystems/directory-locking.rst
index 6fdf0b02df..316f10cb3d 100644
--- a/Documentation/filesystems/directory-locking.rst
+++ b/Documentation/filesystems/directory-locking.rst
@@ -25,6 +25,25 @@ For our purposes all operations fall in 6 classes:
 
 	* lock the directory we are accessing (exclusive)
 
+	An O_CREAT open is the one exception: if the filesystem has set
+	IOPF_ATOMIC_OPEN_CREATE_SHARED in ->iop_flags and its superblock has
+	not set SB_I_NAMES_COLLIDE, its ->atomic_open() for such an open is
+	called with the directory locked shared, and exclusion for the name
+	being created comes from the in-lookup state of the dentry instead -
+	see Documentation/filesystems/locking.rst.
+	That takes an existing lock in shared mode; it adds no lock and no
+	new ordering, so the ordering analysis below is unaffected.  That
+	holds while d_alloc_parallel() is called with the parent's ->i_rwsem
+	held, as it is here; once in-lookup dentries are taken before
+	->i_rwsem, the create's lookup has to move ahead of the shared parent
+	lock with them.
+
+	Such a create can sleep waiting for an in-lookup dentry while
+	holding the parent shared.  That is not a new wait: a shared-mode
+	lookup already does it, and no thread that has published an
+	in-lookup dentry needs the parent's ->i_rwsem to finish with it, so
+	the waiter cannot be blocking the thread that must wake it.
+
 3. object removal.  Locking rules:
 
 	* lock the parent (exclusive)
diff --git a/Documentation/filesystems/locking.rst b/Documentation/filesystems/locking.rst
index f7363ad770..c04df4c746 100644
--- a/Documentation/filesystems/locking.rst
+++ b/Documentation/filesystems/locking.rst
@@ -120,7 +120,7 @@ listxattr:	no
 fiemap:		no
 update_time:	no
 sync_lazytime:	no
-atomic_open:	shared (exclusive if O_CREAT is set in open flags)
+atomic_open:	shared (exclusive if O_CREAT unless the fs opts in)
 tmpfile:	no
 fileattr_get:	no or exclusive
 fileattr_set:	exclusive
@@ -135,6 +135,85 @@ get_offset_ctx  no
 	involved.
 	->rename() has ->i_rwsem exclusive on any subdirectory that changes parent.
 
+	->atomic_open() with O_CREAT set is called with ->i_rwsem on the
+	parent held exclusive, unless the filesystem has set
+	IOPF_ATOMIC_OPEN_CREATE_SHARED in the ->iop_flags of that
+	directory's ->i_op; then lookup_open() calls it with ->i_rwsem held
+	shared, as ->atomic_open() without O_CREAT already is;
+	dentry_create(), which nfsd uses, is still called with it held
+	exclusive.  The flag is a property of the ->i_op instance, so it
+	applies to every directory using it.  It is ignored unless the
+	filesystem also provides ->atomic_open(): without that method the
+	parent is still taken exclusive, so ->create() is never called with
+	->i_rwsem held shared.
+
+	IOPF_ATOMIC_OPEN_CREATE_SHARED is transitional: it chooses how the
+	parent is locked for a create, and goes away once the VFS no longer
+	takes the parent lock for one.
+
+	Setting IOPF_ATOMIC_OPEN_CREATE_SHARED is a statement that the
+	filesystem does not rely on the exclusive parent lock to exclude
+	other creates in the same directory, or to serialize its own
+	per-directory state.  Creates in one directory may then run
+	concurrently with each other, with an ->atomic_open() for the same
+	or another name without O_CREAT, and with ->lookup() and
+	->iterate_shared().  What excludes two creates of the same name is
+	the in-lookup protocol: whenever ->atomic_open() is called with
+	O_CREAT set and ->i_rwsem held shared, the VFS guarantees that the
+	dentry passed is in-lookup (d_in_lookup() is true), so a concurrent
+	lookup or create of that name finds it in the in-lookup hash and
+	waits for it.  With ->i_rwsem held exclusive - on a superblock that
+	has set SB_I_NAMES_COLLIDE, or through dentry_create() - the dentry
+	need not be in-lookup and may be a hashed negative one, as before.
+	Nothing else changes: ->create(), ->link(), ->unlink(), ->mkdir(),
+	->rmdir(), ->mknod(), ->symlink() and ->rename() still take
+	->i_rwsem exclusive on the parent, so a create holding it shared
+	still excludes them.
+
+	The flag is also ignored, and the parent taken exclusive, on a
+	superblock that has set SB_I_NAMES_COLLIDE in ->s_iflags.  A
+	filesystem sets that bit when two names the dcache compares as
+	different - byte for byte, or through ->d_hash() and ->d_compare()
+	where it has them - can be one directory entry, as they are on a
+	case-insensitive server whose client does not fold case in the
+	dcache.  The in-lookup protocol is per name as the dcache compares
+	names, so there it would exclude a second create of "foo" and not a
+	create of "FOO".  A filesystem whose ->d_compare() already makes such
+	names equal, as a casefolded directory's does, has no reason to set
+	it.  The bit may change while the filesystem is mounted.  The VFS
+	reads it for each open before it takes the parent lock, so an open
+	that read it clear may still be running shared when it is set.
+
+	A filesystem that sets the flag must publish its result on the
+	dentry passed to ->atomic_open() with d_splice_alias() or d_add(),
+	which hash it and end the in-lookup state together, inside the
+	parent's ->i_dir_seq window, or with d_add_ci(), which leaves it
+	unhashed and publishes a dentry of the case-exact name that way.
+	It must not hash it with d_rehash().  d_rehash() takes ->d_lock and
+	adds the name to the dentry hash, nothing more: the in-lookup state
+	does not end, no ->i_dir_seq window is taken, and the waiters are
+	not woken.  A concurrent d_alloc_parallel() for the name then
+	neither finds a reason to retry nor has anything to wait for, and
+	hashes a second dentry for it.  The result is two hashed dentries
+	for one name with independent inode state, lookups getting either,
+	and nothing in the VFS detecting the condition.
+
+	The guarantee is for the O_CREAT opener only.  Under the shared lock
+	an O_CREAT open can run concurrently with a plain open of the same
+	name, and only the O_CREAT one is handed an in-lookup dentry; the
+	other may be holding a dentry it found hashed and revalidated.  That
+	pairing is not new - two plain opens of one name can already reach
+	->atomic_open() that way under the same shared lock - and the VFS
+	does not close it.  A filesystem setting this flag is responsible
+	for it, as it is today.  One way, which NFS uses, is for
+	->d_revalidate() to report a cached negative dentry invalid when
+	LOOKUP_OPEN is set without LOOKUP_CREATE: lookup_open() then drops
+	it and calls d_alloc_parallel() itself, so the plain open is also
+	handed an in-lookup dentry, or waits on the creator's.  Calling
+	d_alloc_parallel() from ->atomic_open() instead relies on in-lookup
+	dentries being allocated under ->i_rwsem, which is planned to
+	change.
+
 See Documentation/filesystems/directory-locking.rst for more detailed discussion
 of the locking scheme for directory operations.
 
diff --git a/fs/namei.c b/fs/namei.c
index 96c6594039..ce10a408d3 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -4414,12 +4414,49 @@ static struct dentry *atomic_open(const struct path *path, struct dentry *dentry
 	return dentry;
 }
 
+/*
+ * Can this directory's ->atomic_open() be given an O_CREAT open with
+ * i_rwsem held shared?  The method must be present: without it
+ * lookup_open() goes on to break the directory lease and call ->create(),
+ * and the in-lookup protocol covers neither, so a filesystem that sets the
+ * flag and supplies no ->atomic_open keeps the exclusive lock rather than
+ * silently losing exclusion.
+ *
+ * Nor on a superblock that has set SB_I_NAMES_COLLIDE.  The in-lookup state
+ * that stands in for the exclusive lock is per name as the dcache compares
+ * names, so where the filesystem makes one entry of two names the dcache
+ * holds apart, it excludes a second create of "foo" but not a create of
+ * "FOO", while the exclusive lock excluded both.  The filesystem may learn
+ * that about a superblock only after a directory has taken its ->i_op, and
+ * may learn it again, so it is a superblock bit and not an ops-table flag.
+ * It is tested last, so only an O_CREAT open in a directory that has opted
+ * in reads it.
+ *
+ * The bit is read once per pass of lookup_open(), before the parent lock is
+ * taken.  An open that read it clear may still run shared after the
+ * filesystem has set it, until that open completes; every open that reads
+ * it set takes the parent exclusive and so excludes the shared ones.
+ */
+static inline bool atomic_open_create_shared(struct inode *dir)
+{
+	const struct inode_operations *iop = dir->i_op;
+
+	return iop->atomic_open &&
+	       (iop->iop_flags & IOPF_ATOMIC_OPEN_CREATE_SHARED) &&
+	       !(READ_ONCE(dir->i_sb->s_iflags) & SB_I_NAMES_COLLIDE);
+}
+
 /*
  * Look up and maybe create and open the last component.
  *
- * Takes the parent inode lock itself, exclusive if O_CREAT was requested and
- * shared otherwise, and drops it again before returning.  The caller must not
- * hold it.
+ * Takes the parent inode lock itself, and drops it again before returning;
+ * the caller must not hold it.  O_CREAT normally takes it exclusive, every
+ * other open shared.  A directory whose ->atomic_open() has declared
+ * IOPF_ATOMIC_OPEN_CREATE_SHARED takes it shared for O_CREAT as well,
+ * unless its superblock has set SB_I_NAMES_COLLIDE, and
+ * the dentry handed to ->atomic_open() is then guaranteed to be in-lookup:
+ * that in-lookup state, not the parent lock, is what excludes another opener
+ * of the same name.
  *
  * On success returns the dentry of the last component.  If FMODE_OPENED is set
  * on file->f_mode the file was also opened and attached to @file; otherwise
@@ -4440,6 +4477,7 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
 	int error, create_error;
 	umode_t mode;
 	bool got_write;
+	bool create_shared;
 	unsigned int shared_flag;
 
 retry:
@@ -4447,7 +4485,22 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
 	got_write = false;
 	mode = op->mode;
 	create_error = 0;
-	shared_flag = (open_flag & O_CREAT) ? 0 : LOOKUP_SHARED;
+	/*
+	 * One evaluation of atomic_open_create_shared(), which reads ->i_op
+	 * and the superblock's SB_I_NAMES_COLLIDE, decides the lock mode, the
+	 * unlock at out: and the in-lookup guarantee this function then owes
+	 * ->atomic_open(), so the three cannot disagree.  It is after retry:,
+	 * so a delegation retry re-reads it for the lock it is about to take.
+	 *
+	 * LOOKUP_SHARED states how the parent is locked, so it follows the
+	 * lock and not O_CREAT.  create_shared is the narrower question --
+	 * O_CREAT holding the parent shared -- and only that case may reject
+	 * a hashed negative dentry below.
+	 */
+	create_shared = (open_flag & O_CREAT) &&
+			atomic_open_create_shared(dir_inode);
+	shared_flag = (!(open_flag & O_CREAT) || create_shared) ?
+		      LOOKUP_SHARED : 0;
 
 	if (open_flag & (O_CREAT | O_TRUNC | O_WRONLY | O_RDWR)) {
 		got_write = !mnt_want_write(nd->path.mnt);
@@ -4478,10 +4531,23 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
 			break;
 
 		error = d_revalidate(dir_inode, &nd->last, dentry, nd->flags);
-		if (likely(error > 0))
-			break;
-		if (error)
+		if (unlikely(error < 0))
 			goto out_dput;
+		/*
+		 * A valid dentry would normally end the loop here.  With the
+		 * parent held shared a negative one cannot: hashed and not
+		 * in-lookup, it leaves ->atomic_open() no exclusion for this
+		 * name, because __d_add() takes the i_dir_seq window only for
+		 * an in-lookup dentry but rehashes any dentry it finds
+		 * unhashed, so once this one has been dropped a second opener
+		 * can hash the same name independently.
+		 * Reject it and go round; d_alloc_parallel() then returns an
+		 * in-lookup dentry.  On a negative, d_invalidate() is an
+		 * unhash and nothing more.  A positive is kept: it is returned
+		 * just below and never reaches ->atomic_open().
+		 */
+		if (likely(error > 0) && (!create_shared || dentry->d_inode))
+			break;
 		d_invalidate(dentry);
 		dput(dentry);
 		dentry = NULL;
@@ -4519,6 +4585,12 @@ static struct dentry *lookup_open(struct nameidata *nd, struct file *file,
 	if (create_error)
 		open_flag &= ~O_CREAT;
 	if (dir_inode->i_op->atomic_open) {
+		/*
+		 * With the parent held shared, this dentry being in-lookup is
+		 * what excludes another opener of the same name.  The loop
+		 * above established it and nothing since can have cleared it.
+		 */
+		VFS_WARN_ON_ONCE(create_shared && !d_in_lookup(dentry));
 		if (nd->flags & LOOKUP_DIRECTORY)
 			open_flag |= O_DIRECTORY;
 		dentry = atomic_open(&nd->path, dentry, file, open_flag, mode,
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 3e240579e2..f14520194b 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1995,6 +1995,8 @@ enum fs_update_time {
 	FS_UPD_CMTIME,
 };
 
+typedef unsigned int __bitwise iop_flags_t;
+
 struct inode_operations {
 	struct dentry * (*lookup) (struct inode *,struct dentry *, unsigned int);
 	const char * (*get_link) (struct dentry *, struct inode *, struct delayed_call *);
@@ -2038,8 +2040,41 @@ struct inode_operations {
 			    struct dentry *dentry, struct file_kattr *fa);
 	int (*fileattr_get)(struct dentry *dentry, struct file_kattr *fa);
 	struct offset_ctx *(*get_offset_ctx)(struct inode *inode);
+	iop_flags_t iop_flags;
 } ____cacheline_aligned;
 
+/*
+ * ->atomic_open() may be called with the parent directory's i_rwsem held
+ * shared even when O_CREAT is set.  A filesystem setting this accepts that,
+ * for such an open, the only exclusion against another opener of the same
+ * name is the in-lookup state of the dentry it is given:
+ *
+ *  - that dentry is always in-lookup (DCACHE_PAR_LOOKUP), so a concurrent
+ *    d_alloc_parallel() for the name finds it and waits on it;
+ *  - it must be hashed only through d_add() or d_splice_alias(), which end
+ *    the in-lookup state under the parent's i_dir_seq (d_add_ci() leaves it
+ *    unhashed and publishes the case-exact name instead).  Hashing it
+ *    with d_rehash() instead loses the exclusion: the name becomes findable
+ *    without the in-lookup state ending, so a concurrent d_alloc_parallel()
+ *    neither waits nor retries and a second dentry for the name can be
+ *    hashed;
+ *  - d_drop() on it does not break that: it unhashes from the main hash
+ *    only, leaving the in-lookup hash entry and the waiters in place;
+ *  - no other directory-modifying operation becomes concurrent.  ->create,
+ *    ->link, ->unlink, ->symlink, ->mkdir, ->rmdir, ->mknod and ->rename
+ *    still run with i_rwsem held exclusive, so an O_CREAT open is
+ *    serialized against all of them.  It runs concurrently with other
+ *    O_CREAT opens, with an ->atomic_open() for the same or another name
+ *    without O_CREAT, and with ->lookup() and ->iterate_shared(), which
+ *    already run with i_rwsem held shared.
+ *
+ * Ignored unless the filesystem also provides ->atomic_open, and ignored on
+ * a superblock with SB_I_NAMES_COLLIDE set in ->s_iflags: there the in-lookup
+ * state of "foo" does not exclude a create of "FOO", which the filesystem
+ * may make the same entry, so the parent is taken exclusive.
+ */
+#define IOPF_ATOMIC_OPEN_CREATE_SHARED	((__force iop_flags_t)(1 << 0))
+
 /* Did the driver provide valid mmap hook configuration? */
 static inline bool can_mmap_file(struct file *file)
 {
diff --git a/include/linux/fs/super_types.h b/include/linux/fs/super_types.h
index ecd96aeb1c..91f1522a0d 100644
--- a/include/linux/fs/super_types.h
+++ b/include/linux/fs/super_types.h
@@ -352,5 +352,6 @@ struct super_block {
 #define SB_I_NOIDMAP	0x00002000	/* No idmapped mounts on this superblock */
 #define SB_I_ALLOW_HSM	0x00004000	/* Allow HSM events on this superblock */
 #define SB_I_NO_DATA_INTEGRITY	0x00008000 /* fs cannot guarantee data persistence on sync */
+#define SB_I_NAMES_COLLIDE	0x00010000 /* names the dcache tells apart can be one entry */
 
 #endif /* _LINUX_FS_SUPER_TYPES_H */
-- 
2.43.0

