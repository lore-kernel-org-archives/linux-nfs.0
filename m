Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.161.54
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793297395;
	b=ldoVuniGN9cGjU/HcAfc+bPBlxfeZUodE5IAqfODzPrGVLi+OFbodOcM8pfyMAlxk6GE
	 /2Z11JySO113+awLTZUNTYO8kZlkDgfJT1IqCoTy1gBWFefa9kOs8I3y8uL3CTpeDbgv4
	 3kkHJ7KZt1jpMri+FEfGH/n6RP/mHehkki/UPprHp/lTL/2fUE/LJY3MzEnL13swKcrwj
	 WrXM5QZmaLlmljxmitdqaMR/0zhwC29NKCOmokvPtxGacUU8HwiK1MmuYH+qMYNfr+UUD
	 K25iTBNcxbYewJGuQhRp5SR0peBD1Miv0WZrIKXxF+kN3QwkprYBAp1wH0R45VKwRvQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793297395;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=W/EAKP+3XkXqAm0vqhsCDYAT7jfMEV3PZN/8IdWi65g=;
	b=OnZHIInFHhazbaHekEsAYdExtRTFLObOmJCb/D6L3Gf32R/99deQloqyN4TSd3UrINpb
	 m+hI27TGu9o4YEz43HGaaoB5V4Cl4FY8I603pPNJdRNe7ShGIIhQhs7DGravwYXla7yTH
	 8DE3/xRW0HKnbve1EhiQoYpC3A9YJx93xTkhIAP6QGm1gAmjimafKRoQ0xk1BjrCROyaj
	 4wSkigBA+gGCz6y6GsN0wVB/2y8R/OW8FgdiL2xacfT+NNLWULxHwAOflKUOxcuxZNI8+
	 UV/dkTlaitgaSQG7h8SDN5IUKjejTfiG3TRAFHtedPBb+wEBmD/levhxq1j/V5e99ZQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=hammerspace.com;
	spf=pass smtp.mailfrom=hammerspace.com;
	dkim=pass header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=WHUCIw3D;
	arc=none smtp.remote-ip=209.85.161.54
Received: from mail-oo1-f54.google.com (mail-oo1-f54.google.com [209.85.161.54])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 198C6606A32C
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:09:54 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 198C6606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=hammerspace.com header.i=@hammerspace.com header.a=rsa-sha256 header.s=google header.b=WHUCIw3D
Received: by mail-oo1-f54.google.com with SMTP id 006d021491bc7-6aa9606ddadso1951956eaf.0
        for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 11:09:54 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1793297394; x=1793902194; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=W/EAKP+3XkXqAm0vqhsCDYAT7jfMEV3PZN/8IdWi65g=;
        b=WHUCIw3DTHv0YSgCSziJSIq2gMfnbCVkeyXE0Nqvbg4dxTy0IkIRgO9QnyIvYNNbhy
         p0AYgxLp1JRlHRw1gQy6Eeu7FWjODrVtqlsUN2CaAzQLU49QpUK8AdWdHmLLvyEzETK7
         ywz1szFDByUrRePx/ht+DSlDwVF4f4eXSSJjXbH5+dgFTrZ/qdv29dc8VPp1LKVOVJ+4
         uKIaEoBsB+GVRCe5NUgfgy6nB7lZQXHxr84MtrGNq+pZt8qrNcdoaHQ0Tsyqj33wKSr/
         CZl29Q941vt7NTjjU5TtXOVc4MlNInsff1/WyivXzZxjWMSJTEFcdA60yluaPKY63rGh
         KQgg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793297394; x=1793902194;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=W/EAKP+3XkXqAm0vqhsCDYAT7jfMEV3PZN/8IdWi65g=;
        b=oeD11F0dxNdkx/RDwI9hdpReHJ91LVLMkQza/ChvxcmUey9K4trU/haqquiHVd8cRR
         rjVckwdHKk5G+lzB4wzmsoImx74/zBpTlIDy3ZrvOX3upE9jcGMUb91eDMKyDaAM11p0
         hQZrKCe8n1OpE2jHqep8MLjg2rGbX32V1c/IJooRPnN2E1CnPT2diPUQkie2nYh5yZU2
         10hnOMxsx+oVmmIRj+NFuFOIz+nTiaOftdYr/rRH5siaCuO+GpirbdSgzHKbNPBgmCk4
         bU3jljfoXRjDzzENWunXL+UJD1XWSKqLWkxm3f9mhbZJbfsbjpY5akg/lOd4iK6JLqhg
         D69Q==
X-Forwarded-Encrypted: i=1; AKwUvBy/CCWfWIS7kBm2MvTMa3smubYGUE965qJFWexLeJB4ii/qZNnUSgAwLEsYuswds5C6ZdjYdvtnjNk=@vger.kernel.org
X-Gm-Message-State: AFq9FYJQveVrfxMp1lLDTg7lUBAGjhJpyCmDYb/hGEU9HPT5jV1Bqszb
	FFKMg/kDjk+nYCdIj/HXeL84LWNdYg2SDYS9bwLHXmI+hdy4ido5m3bDy4suCGmNOzM=
X-Gm-Gg: AYBFou3qtxMmR0DeN7xQl9vJgYliiUMEHHw83nB+NR0yGD48SZJcHvnvz01ayThJTgL
	WdFV+AcPjFbO1zsBAnlj8ad0fGBMJc9gjkLAYyN7rnBxnOn23euQfZRGta+7VhwriQKi0diYxHF
	7aS57UmT4+nZKmMKYYJ9hWFpfHElaL/HB9tdbwEOPcivlwsWjMVenX5e/wB/DM0X1CFY1XsUGRK
	7jtsvdqX4HyOn4C5jm71nzE0cNMWunlXeQTfQm19HGLLuj0tl/JMC2cyNdopp2FQ1uD7Yu+KG8K
	V7ZCiCgg7oF23afNlNT1KhGOIyWzRPexZ+xPaOUqakgbDnhvB7v1ZeNaw1IuDxp47b7/97LlyCl
	tvQLklI1tVA9hz1QhZ/jGncJ6Etr0NlrtC2EzKajXw0IVJ/M4vZk55R0nhBrXc0ZiKRl7drBqvY
	0UAIN0cm+9nbcvrQ0rW3IOnj1w+3A5LqcCSjCsZ3WeZVu2Z1uADnPqzXbHYHuhK+AfMUlTxvk1d
	aILLlg18LeRkLgiXaiwgccc4Ie85PDcGxZtJzLSZ7ENUUbJ3X59Qtw1d26+aeBW3F4OyVVItnK3
	lmIJ5kRhSpIRCW+q39SlD1L0a7Ut7ZMTzlKZBscCXN/s7Lbk27MDVzLAhF3I7Voe8fT2W19r
X-Received: by 2002:a05:6820:c30c:b0:6fc:373a:176a with SMTP id 006d021491bc7-714f2ab9b84mr17297eaf.77.1793297393747;
        Thu, 29 Oct 2026 11:09:53 -0700 (PDT)
Received: from localhost (75-163-200-235.clsp.qwest.net. [75.163.200.235])
        by smtp.gmail.com with ESMTPSA id 006d021491bc7-714f24899ebsm51267eaf.13.2026.10.29.11.09.53
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 29 Oct 2026 11:09:53 -0700 (PDT)
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
Subject: [PATCH 1/3] nfs: do not transfer a sillydelete onto a blocked dentry
Date: Thu, 29 Oct 2026 12:09:48 -0600
Message-ID: <20261029180950.387072-2-jonathan.flynn@hammerspace.com>
X-Mailer: git-send-email 2.43.0
In-Reply-To: <20261029180950.387072-1-jonathan.flynn@hammerspace.com>
References: <20261028041023.3738553-3-neilb@ownmail.net>
 <20261029180950.387072-1-jonathan.flynn@hammerspace.com>
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

Harden the hand-off of a pending silly-delete.  When the last user of a
silly-renamed file goes away, the client can move the delete it still
owes onto another cached entry for the same name.  Leave that entry alone
if a removal of the name, or a rename onto it, is already in flight on
it.  Moving the delete there would overwrite the mark that makes lookups
of the name wait for that removal: the wait would end early, the removal
could report success without removing anything, the pending delete would
be leaked, and a later release of the entry would dereference a NULL
pointer.  If that removal succeeds, the silly-delete was redundant; if
it fails, the silly-renamed file stays on the server, which is the cost
of skipping rather than waiting.

The mark and the hand-off have shared ->d_fsdata since the commit named
below, which reasoned that no silly-delete is pending on an entry being
removed or renamed over, but not that a hand-off could arrive while that
removal is in flight.  The hand-off has stayed unreachable since then
only because nfs_call_unlink() passed d_alloc_parallel() a name whose
hash it had not computed, so the lookup for the other entry never found
it.  NeilBrown's "nfs: fix nfs_call_unlink()" computes that hash, which
makes the hand-off reachable even though every removal holds the parent
directory exclusive: the hand-off does not take that lock.  That fix
adds no test of the mark; this is the test, and a tree that takes that
fix needs this one too.  It does not depend on any other patch.

This was found by an AI coding assistant (Claude Code) reading the
code; Sashiko's review of NeilBrown's patch reports it too.  The
hand-off itself has been reproduced with that patch applied; its race
with a removal or rename has not.

Fixes: 3c59366c207e ("NFS: don't unhash dentry during unlink/rename")
Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
---

Notes:
    For reviewers and review tools; not part of the changelog.
    
    Known and not fixed by this series: a hand-off that lands after
    nfs_unlink() or nfs_rename() clears the mark, and before the VFS's
    d_delete() or nfs_rename()'s d_move().  The cover letter describes
    it, with what it costs and a fix offered.

 fs/nfs/unlink.c | 19 ++++++++++++++++++-
 1 file changed, 18 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/unlink.c b/fs/nfs/unlink.c
index 0eddc7ee11..491ebd8582 100644
--- a/fs/nfs/unlink.c
+++ b/fs/nfs/unlink.c
@@ -142,9 +142,26 @@ static int nfs_call_unlink(struct dentry *dentry, struct inode *inode, struct nf
 		 * the sillyrename information to the aliased dentry.
 		 */
 		spin_lock(&alias->d_lock);
+		/*
+		 * Not if a removal of this name already owns the alias:
+		 * ->d_fsdata == NFS_FSDATA_BLOCKED means nfs_unlink() has a
+		 * REMOVE of exactly this name, or nfs_rename() a RENAME onto
+		 * it, in flight and ->d_revalidate() is waiting on that field,
+		 * so storing over it would lift the block early and the later
+		 * unblock_revalidate() would store NULL over @data.  Tested
+		 * under the same ->d_lock block_revalidate() stores under.
+		 * Skip rather than wait: that removal makes this sillydelete
+		 * redundant if it succeeds, and a wait here would sleep in a
+		 * dput() path -- the nfsiod callback that releases a
+		 * silly-rename among its callers -- for the length of another
+		 * task's RPC, with ->d_lock dropped and these tests redone.
+		 * If that removal then fails, the silly-renamed file stays on
+		 * the server: the price of skipping.
+		 */
 		if (d_really_is_positive(alias) &&
 		    !nfs_compare_fh(NFS_FH(inode), NFS_FH(d_inode(alias))) &&
-		    !(alias->d_flags & DCACHE_NFSFS_RENAMED)) {
+		    !(alias->d_flags & DCACHE_NFSFS_RENAMED) &&
+		    alias->d_fsdata != NFS_FSDATA_BLOCKED) {
 			devname_garbage = alias->d_fsdata;
 			alias->d_fsdata = data;
 			alias->d_flags |= DCACHE_NFSFS_RENAMED;
-- 
2.43.0

