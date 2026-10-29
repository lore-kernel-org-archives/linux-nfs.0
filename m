Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.210.52
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297407;
	b=5KowYdNsJJ7+SyaUiVejv+TEF04B834T9tHcPsm/6e2PEZmlwBAXsYh5JT8f8WeNq0x2
	 oJRK1W10zJ45ppon8hsPvdgliVDGmKv/+xf8fce6TqMYKl+VrlhHPlWqv5Rh/N6fiF/Z6
	 1mCEPbe7E7FfO9FQCSkCNN+TjmXWDSOMmCiwUjXW2Ke+uYWcIWFb3Qw0SE9+RVxDx0ata
	 16SeilAX71SpHNgchkx5ck6i91Djm1FMDGbvxqOUe2kXEWRPyWLo+CBg8tNkgKxjVkBCR
	 lcWJKWzgaiUQzYQlev3r2V0NB8+gqu8UfN81YRY9tnKsnFP4NzZVqUtLmLpIwczBzbg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297407;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=lY/j4BJTPHacq4th+geW3uU/xT9CmxLqWYLCqLTZczE=;
	b=RyCTaIUaudbff7QbZ1f+XDjjqSvOwXp4aF4YU+ccMi3AEbBWzSVFYyH9ePQD++zbmqY4
	 Xs7RXKCtKtMwciLXV9AgJiX4h4RMGM02gMw1H3kdY81iPv2e3CQjNL8+MvWg1HKkvT+h7
	 ZEjQj6APQtcrIRjWQCAgSHoN6NloheGBJOkHVIk2/p1K4Jj+Al5UtX7n+BVOZwlaM3XNz
	 F2sutFkTyktJtA1wKdEfKOF/4ZBFIvUceuGk0WebqjreCS1Cb+hT7am80ytahES6PoJ52
	 BkEl5WEu1JLHR6XN9Qf/VTJVrS55H609y4A4ppi3XvuxFWFFcbThhaqozokfjyNi4sg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Ry1TF5jp;
	arc=none smtp.remote-ip=209.85.210.52
Received: from mail-ot1-f52.google.com (mail-ot1-f52.google.com [209.85.210.52])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0623660A6F53
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:10:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0623660A6F53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=Ry1TF5jp
Received: by mail-ot1-f52.google.com with SMTP id 46e09a7af769-843a4ca671eso1211706a34.2
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:10:06 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793297406; x=1793902206; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=lY/j4BJTPHacq4th+geW3uU/xT9CmxLqWYLCqLTZczE=;
        b=Ry1TF5jpHfEtNb/wLvErDSS8ox5RnKxXAurma5fBS90BM/ds83g3mFR2ATwEzR8DL7
         LVwlSKaZJySUADCRte4WXCkQq/GC1izQCx2MmN+Ca29mhrg/P1ThlGcHsKFoDCcGG6nR
         7x5vE5eVuyZJ3utrbUtEf6i12A5SBsj8j2eHN1Nlet+iT4vloY3EUrZ2st31Cw8vozMy
         Je+wyMqJp6Q0i3NADjc4eD9NiSRCeFvQKGH2wH3IhKOPEQSyE1+nb7RdhTwmVI1x4HWi
         mK7WpuT2eNnX+6Z9h4obk2oaLUvW//10MbXgsxrtBNqePP791KDaZsFj2KztFPd42ge9
         CigA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793297406; x=1793902206;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=lY/j4BJTPHacq4th+geW3uU/xT9CmxLqWYLCqLTZczE=;
        b=B/r+TC1j+w685isgX6UrzGhAw3T0And/Wb1bglgTPFvq2UeQRJyaII3JBOVjtzfxtQ
         aVY+EGKqQDDsGL2y8wt8UDuQOxKciw28iwu4qzR0IaJLLgWTzmslj90mk+cQ6Ton5JeX
         Ovk3UxxT+eyrzDLF90saCAmOmcWQwMhQwyXCiWI1isF0FmOcll7alRIDSrvFpWCqap9q
         9vRwLV3nb6zDet2Etz7skgTUSx7hbMQeCQ5mhnVzZ0wCqoJw5UwYQ17yOJ3yDOmUwxVe
         x9Z25BHb5rFzB2yRffzGQnJgKP/vmgR7pNjsXa2LE6sbH7xZyqsQHgodVRRC/tbXLd5U
         ehlg==
X-Forwarded-Encrypted: i=1; AKwUvByl5k3DZiBVDFDifwy+bv6+8l5q10pgoTeco9OUHQLRmOMCZCFEOTkYAP8umgcwmKOKPdAny98JSK0=@vger.kernel.org
X-Gm-Message-State: AFq9FYJQM2gT6VO3F62Jgf5hGhaUshlu7YIC969jOIOCbn8fSYGG/n9e
	T3xCtnZm/iPRbcwVPKyL7DZFZu59Z/WCbJ6otOUy81aRV833nKuRayMsdo9AOgO2AMk=
X-Gm-Gg: AYBFou18KQ5TSaaJyr4Zq24aibq/S2AhRXt9OaPKM4G+XZHw2Vx/nVdvIj5f+ahcuON
	gO5m8nO8dhJqi6Ux2yrQOua8xglv8/mn06DDq9y8HrTBYHkaoWCiw2XNdt+9ZupACbErArXdDPy
	45F5X4CWssD7j2sYSkdz4YOD1lgGhwFs91+Aw5sQaEr9SRkqzooDW87J1cfU1U5mZbTAZ7PQXtX
	PMbL69WDqgmKKSBnO3PDu/H35zGPZDMZkP2Yg5+ZuRJ7RDYanQwbY1BiCHljf3LTdUa/18mxCXh
	rN2NFM1e8mqfL+mTbmKyzvxvbjUNl6Dfdz7bQDrwdQjrkHy28oCTbTON9nUVn9VRKyN5Mb0zedh
	YsHgwlYhmKBoKPYZDs2iTKMvg89SeYhGuonPSZnXZaZ53pTroK9pmb3MX8Upx0qREB1AUAQyAUd
	+Rktta+MkKtSY9t92Jayg130AENv4iK5GuIc57XzODGoA2ERzON6lqsEzkGIVh7C2/1lIYJt0xp
	SOu/DnmfnTtsqEhMFDXGnQkWBML2CNmFckvCMq++44nTQvUE86ts8PGCnOeTRjs+RhY8ASiUYUA
	tSqqENjbsYiDnIdkY4D5usDyRAikh9f4x8kN5ch8NjEfKlqaq667vNYElBxaX+II7RhdW5nR
X-Received: by 2002:a05:6830:34a1:b0:804:ec69:3979 with SMTP id 46e09a7af769-85ac090193bmr5308756a34.21.1793297405639;
        Thu, 29 Oct 2026 11:10:05 -0700 (PDT)
Received: from localhost (75-163-200-235.clsp.qwest.net. [75.163.200.235])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-85d3501abc9sm213289a34.0.2026.10.29.11.10.04
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:10:05 -0700 (PDT)
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
Subject: [PATCH RFC 04/12] nfs: concurrent O_CREAT in one NFSv4 directory
Date: Thu, 29 Oct 2026 12:09:49 -0600
Message-ID: <20261029180957.387138-5-jonathan.flynn@hammerspace.com>
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

Set IOPF_ATOMIC_OPEN_CREATE_SHARED in nfs4_dir_inode_operations, so
that the VFS takes the parent shared rather than exclusive for an
O_CREAT open in an NFSv4 directory.  Creates of different names in one
directory then stop serializing on the parent inode, except on a server
that reports itself case-insensitive or not case-preserving, where
"nfs: tell the VFS when two names can be one entry on the server" has
set SB_I_NAMES_COLLIDE and creates keep the exclusive lock.

This is the only user of "vfs: allow the parent lock to be shared for
O_CREAT", and what it needs from it is the guarantee that the dentry
reaching the atomic-open method for a create is in-lookup.  NFSv4 keeps
the dentry the VFS gives it when O_CREAT is set, and publishes the new
inode on that dentry; because it is in-lookup, the dentry is not in the
main hash, so dropping it is a no-op and publishing it is permitted.
The name enters the hash exactly once, and until it does, a concurrent
lookup or create of the same name finds the in-lookup dentry and waits.

NFS does not use the exclusive parent lock to serialize its own
per-directory state, which is what that patch asks an opting-in
filesystem to promise.  Both pieces of state a create touches are
already under finer locks: the directory's change attribute and the
cache-validity bookkeeping that moves with it are updated under the
directory's own spinlock, and a dentry's directory verifier is stored
under that dentry's lock.  Neither needs the parent lock held
exclusive, or held at all.  The verifier is also ordered so that losing
a race can only cost work: a verifier offered against a directory state
it no longer reflects is declined rather than stored, so the failure
direction is an extra revalidation, never a dentry claiming stale
validity.

Lookup and readdir already run with the parent held shared, and
readdir already instantiates dentries there under that lock:
nfs_prime_dcache() takes an in-lookup dentry with d_alloc_trylock(),
skipping a name another thread holds in-lookup, and invalidates and
retries a hashed dentry that no longer matches the listing.  A create
joins concurrency NFS already handles.

NeilBrown's "nfs: remove d_drop()/d_alloc_parallel() from
nfs_atomic_open()" states that the method has exclusive access to the
dentry in one of two ways: O_CREAT, where the parent is held exclusive,
or a dentry carrying DCACHE_PAR_LOOKUP.  Setting the flag removes the
first of those for open(2), which reaches the method through
lookup_open(); nfsd reaches it through dentry_create(), which still
holds the parent exclusive.  "vfs: allow the parent lock to be shared
for O_CREAT" supplies the second in its place: with the parent held
shared for a create, a hashed negative dentry is rejected and the
lookup retried, so an in-lookup dentry is what reaches the method.
NFS's invalidation of a cached negative for LOOKUP_OPEN and that
rejection do not overlap: nfs_neg_need_reval() returns 0 for
LOOKUP_CREATE before it can reach the LOOKUP_OPEN case that invalidates
a cached negative, so the invalidation that covers a plain open never
fires for a create, and the rejection in "vfs: allow the parent lock to
be shared for O_CREAT" never fires for anything else.  The opener newly
in company with a shared create is one opening the same name without
O_CREAT, and that is the opener the invalidation covers.

The flag goes on the NFSv4 directory operations only.  NFSv2 and NFSv3
reach a different atomic-open path, which has not been analysed or
exercised under a shared parent lock, so it does not get the flag;
adding it later is one line.  Referral and automount directories are
unaffected, since they are given different operations vectors.

Every other directory-modifying operation still takes the parent
exclusive; for unlink that changes when "nfs: remove files with the
parent directory locked shared on NFSv4", later in this series, gives
NFSv4 ->unlink_shared().

The measured effect, from a 7.1.13-based kernel carrying an earlier
revision of both patches, is in "vfs: allow the parent lock to be
shared for O_CREAT".

Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
---
 fs/nfs/nfs4proc.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index fac8450b65..808bb8f1c1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -10869,6 +10869,7 @@ static const struct inode_operations nfs4_dir_inode_operations = {
 	.setattr	= nfs_setattr,
 	.listxattr	= nfs4_listxattr,
 	.fileattr_get	= nfs_fileattr_get,
+	.iop_flags	= IOPF_ATOMIC_OPEN_CREATE_SHARED,
 };
 
 static const struct inode_operations nfs4_file_inode_operations = {
-- 
2.43.0

