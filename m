Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.69
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795116195;
	b=v35pZGNSHVUlsLYY/Q/msh7Ytg9Ou8YPpfVgJDy8DH3hWtuozPYEStpUPBnaJ3m7NcbK
	 TDrAYXbv0G81xYjhSX60JGSGhgc0I8HJFSIK6urX1qrWWik11WORVpPQhgqA5xpML8L3a
	 mYeXSQUfl1eoKZiN2CqJGyvtxe2kzpeKHRmoXt0L2NgtMglFLdJv7LC48B45X2jGTnkNn
	 8xCCrsl0Vgwpv3A10RwAN9+em4EYi4AtR1NFrfCW2ISieAJeQXuAmgTNOzeCi+PPF7Ar5
	 gZ3THyYHpW0fz7f3o20+OjLcBQmFrbwDEbmQdjWnGc3x6z4HgOA3W8kEQ64yBheKK0Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795116195;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Received:Date:Mime-Version:
	 X-Mailer:Message-ID:Subject:From:To:Cc:Content-Type;
	bh=sfFGrUaw7Fqr5/HV4cxJvsPhjYosSvwq1pdNIkXnzLs=;
	b=u4PqwBGVXPzaGjJ4H+vPxUwSstMLsaQQ/6Yto4NDAO9D4MO1r5cNnd7EBsRHt8Meqrek
	 RBWOvNI7K0XbCGOrCny2zh+9KAUuSEV7HAJpxWwI6MZgguCtYv0k9RSo9JX2OI8QhSwuu
	 lh/bzT6T7J6qN8aKAxzJQMxwKRpP/VdGfrr/wnVrnif1PCcOcmB5I7+/1COny9I2nBZcB
	 nMZsAs22bjwa33srsDFbFg9pI6/t0LsbFU+VGD4o+fdNgiV0anoC0afYBHstQGNPu2mW/
	 DIgkAJRvvaFAUHb9vSwzhjzfvezpok6j+dQYEBm3Is0TvqwIrdLTjI0mzW74TiDARfA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=google.com;
	spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com;
	dkim=pass header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=RoDD9snv;
	arc=none smtp.remote-ip=209.85.221.69
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 04798606A332
	for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 19:23:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 04798606A332
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=google.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=flex--dmnk.bounces.google.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.a=rsa-sha256 header.s=20260707 header.b=RoDD9snv
Received: by mail-wr1-f69.google.com with SMTP id ffacd0b85a97d-492b5408dedso15888f8f.3
        for <linux-nfs@vger.kernel.org>; Thu, 19 Nov 2026 11:23:14 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20260707; t=1795116193; x=1795720993; darn=vger.kernel.org;
        h=content-type:cc:to:from:subject:message-id:mime-version:date:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=sfFGrUaw7Fqr5/HV4cxJvsPhjYosSvwq1pdNIkXnzLs=;
        b=RoDD9snvR81IV2Ac91gE8vBF6shjd0+G/GstOxhrAM3SU+vnUWav7pdLTYj2zpW1ae
         n0Bw5QMqboFfQibqVW5DVvHhfnDNMM1bLnZJhgAckNtr3yUmAixu7c/zjC2QiGwUCYAR
         xAzcJanpU9j1ZN4wZa04592Gm1gNrIyH7AvAVZYBFC3diNVX9v937HdIIdlsXjsNUPyj
         orOAinpXq3RWqJtvSWFbFK3EiGctAOxAgEwoS46l5q2rHBqFPTZKnqkGdZOStIyZM8uw
         peeEGD6cYufG62reehGHYWkMo8EF3PqyLkLROupBtdKbawNz6OqI6yTugB8Lh9PX0ixk
         jLmg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1795116193; x=1795720993;
        h=content-type:cc:to:from:subject:message-id:mime-version:date
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=sfFGrUaw7Fqr5/HV4cxJvsPhjYosSvwq1pdNIkXnzLs=;
        b=tosK+qx76PQtbBR8CkNrwbb28i/JLllysM9rL5NVifPh4QBdyMpKRsFhJ0yzRkDIvu
         3MWXRnr0hL4HudxFGa8ULOLSk0gl7X6rvcVo1TQ8YTTTcr9dcjcBjtp9pS26bdfRMcNY
         mt75xpT5/108M/HI6kr9i45Pm/gWkwwGHyQNaZTZaGxooQ3Rt8MRrswhPu5HhZRgd9XY
         Ibsx++V8I5uVig5efjhShrgn9bPp96iOE1t7WcH4n1uaJ4BEmNaEGjYz7RMyVee92ZvO
         oDRjg5ERH74WhaJVyMuAIKzFlZYPmDrXGAMzDf4rjbwAWos+bB9YzdNXDZG8UkdqUIyZ
         smlA==
X-Forwarded-Encrypted: i=1; AL+hErFc2wqWNXSxAU79YR4cThdgzdaMS/RjD4YDWNmW8u7ro2X9jSPF2WdquvnyRNq4SaJ5MTbJfHIcJEU=@vger.kernel.org
X-Gm-Message-State: APuU4Z+8/xIwMWEztY36gpTNyoBWuPQuCGNwhTsDLW53Ma0Jl0XVkTyI
	yR2XQ4FiEbzDrT4w/5kOO4/p8SFTKcREv8eXfV05+2Dy+urn8yCj1lWBker6IU0VjoCD3fnDhQ=
	=
X-Received: from wrpz6.prod.google.com ([2002:adf:f746:0:b0:4a6:7c3d:a12f])
 (user=dmnk job=prod-delivery.src-stubby-dispatcher) by 2002:a05:600c:848d:b0:4a5:1cf1:b7bd
 with SMTP id 5b1f17b1804b1-4bb88810b2dmr11129215e9.16.1795116193152; Thu, 19
 Nov 2026 11:23:13 -0800 (PST)
Date: Thu, 19 Nov 2026 20:23:10 +0100
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
Mime-Version: 1.0
X-Mailer: git-send-email 2.56.1.809.ga0b61035b5-goog
Message-ID: <20261119192311.2684978-1-dmnk@google.com>
Subject: [PATCH 1/2] fs: export may_linkat() for nfsd
From: Dominik Maier <dmnk@google.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	Christian Brauner <brauner@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	dmnk+artist@google.com, Dominik Maier <dmnk@google.com>
Content-Type: text/plain; charset="UTF-8"

vfs_link() expects its callers to enforce protected hardlink policy via
may_linkat() prior to creating a hardlink. Move the declaration of
may_linkat() from fs/internal.h to include/linux/fs.h and export it with
EXPORT_SYMBOL_GPL() so modular in-kernel file servers such as NFSD can
invoke it before calling vfs_link().

This prepares for fixing missing hardlink restrictions in nfsd_link(),
which was discovered by an AI-assisted code review tool (ARTIST),
validated in QEMU without kernel modifications or error injection, and
verified with kernel builds and checkpatch.pl.

Fixes: 800179c9b8a1 ("fs: add link restrictions")
Cc: stable@vger.kernel.org
Signed-off-by: Dominik Maier <dmnk@google.com>
---
 fs/internal.h      | 1 -
 fs/namei.c         | 1 +
 include/linux/fs.h | 1 +
 3 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/internal.h b/fs/internal.h
index 3f2fbac..7c30669 100644
--- a/fs/internal.h
+++ b/fs/internal.h
@@ -54,7 +54,6 @@ extern int filename_lookup(int dfd, struct filename *name, unsigned flags,
 			   struct path *path, const struct path *root);
 int filename_rmdir(int dfd, struct filename *name);
 int filename_unlinkat(int dfd, struct filename *name);
-int may_linkat(const struct mnt_idmap *idmap, const struct path *link);
 int filename_renameat2(int olddfd, struct filename *oldname, int newdfd,
 		 struct filename *newname, unsigned int flags);
 int filename_mkdirat(int dfd, struct filename *name, umode_t mode);
diff --git a/fs/namei.c b/fs/namei.c
index 925aeb6..8f7c2dc 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -1385,6 +1385,7 @@ int may_linkat(const struct mnt_idmap *idmap, const struct path *link)
 	audit_log_path_denied(AUDIT_ANOM_LINK, "linkat");
 	return -EPERM;
 }
+EXPORT_SYMBOL_GPL(may_linkat);
 
 /**
  * may_create_in_sticky - Check whether an O_CREAT open in a sticky directory
diff --git a/include/linux/fs.h b/include/linux/fs.h
index 5b3a100..c165f27 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2740,6 +2740,7 @@ int may_delete_dentry(const struct mnt_idmap *idmap, struct inode *dir,
 		      struct dentry *victim, bool isdir);
 int may_create_dentry(const struct mnt_idmap *idmap,
 		      struct inode *dir, struct dentry *child);
+int may_linkat(const struct mnt_idmap *idmap, const struct path *link);
 
 static inline bool execute_ok(struct inode *inode)
 {
-- 
2.56.1.750.gf70dc682cf-goog

