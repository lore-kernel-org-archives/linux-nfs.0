Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.167.53
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793997630;
	b=gkCFrP1zfp1xVgLkQfYJsNVgusjSTfeQbTl5SYxg1kGdoR+V5yaXIUVg1hIym+1moTiW
	 /PUurvqCwOgoqxX/KhSyeeZtkkAQQTUldsOKMM87+eXXGk6RxYJHHNKcD4+iPsIXDxbgt
	 Xki4dat3J6y6t1mq7vcnt8pVC2E7fKBQ1OxRkQdMEl+13upRiD8Yxcgj06OgSZB0EoB5x
	 q3gKdrtHMk3crCK5+wDVNLkDhw8yT8hC8rGFa+CLU88Qgo47AVJsAUbD96SPRo6KCO5aO
	 5YVlj7/5O1xBS3zQ/UyQlZjW0qP0Topb/sXnl549acYv9vunsKBrKF7+pZGs8j3umyw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793997630;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=D/PxjqMUnoRNvdLWmtMbPlTvfojIHeVHPRoAErTV6bk=;
	b=MkLoFXoMHokPGI5BDUerdeZqR4pXpTL0LPPicMLM0Y86e8911Mv5CWciRpmo+6v1fDjW
	 YiNALEM0ILvIBsM7ATghwlA4lZatWb5O7tHOttyJylZsCfT9M3tp848yaS0qle3B+/1Ya
	 P7HrojMlBekH+XmtTk34OXvvdfuC3hJWcTvLhlBzV7DPdB3IC5EOS+0st7LkXh/NIAPSO
	 Ne6O6tMzh3yIdu81iQDpX5PI/fBYd/V0SbdnmIUuwLUKCVLEI64zcWaR7OOHjA2kewJE4
	 Q6Zh5tWvXZXlvfe5acWMW+PaUWxUBxsIp47wHGBw8ac/odx+R1RPTgtBVrRcxL/qxfQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=SIJeD92Q;
	arc=none smtp.remote-ip=209.85.167.53
Received: from mail-lf1-f53.google.com (mail-lf1-f53.google.com [209.85.167.53])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0371B606A32C
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 20:40:29 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 0371B606A32C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=SIJeD92Q
Received: by mail-lf1-f53.google.com with SMTP id 2adb3069b0e04-5be3ea5a7adso860519e87.2
        for <linux-nfs@vger.kernel.org>; Fri, 06 Nov 2026 12:40:29 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1793997628; x=1794602428; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=D/PxjqMUnoRNvdLWmtMbPlTvfojIHeVHPRoAErTV6bk=;
        b=SIJeD92Qu1ghLn6Diwyb6fKrNsRE4AsbWWViYIN/gXJsQyeupZTIwUP8vl58BvBs2t
         YI+JBoAXYqrypkee0TpRKbjDCNK7XjE+X8s+DbIKRMNyYguo2UimIdmlW9FHJFkxsj6F
         PRe74jak0M/nBlafEMyhrTfp5sy9m+5Y5AKj9tYqSQiZ8qhvXj75WvrXgfTpfb7Q8+QW
         27tEhwXkHqsMzu2hu7fLcBCVVP92uvzvKB+vrrQgbQ1Xrnke6CxmcQt+JKCUCDBBy4tG
         X4eElH8xoqVZzURtTRS97dAV9yMuUmrqd4xvPFm8WmomV7UhwzX7c9nlGhmbkKTPspy/
         Z6QQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793997628; x=1794602428;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=D/PxjqMUnoRNvdLWmtMbPlTvfojIHeVHPRoAErTV6bk=;
        b=XfRrnRXYF+bGwQTF3S4jCqxOSqaQy8S+CJ8AbfASLl10qJBUlA1/G8IRxJMPwN6EGC
         UwP1IrgiuvXF9Nh7zqmCn6Pt4xJFgmVVp8NqRt6TAIXfQPCeMJbrsDq5cGBVnfR42cJd
         lw69NCoOcVKCbcXFVfYz1CYYL20UAaBOuAVND/zELhSr19+j8OwYOUxDf2fsJkC0cNQT
         ydPe6xVDE3yJk6TnCEDojpkdu7bIe19eeBVNR2CF5Q/kIGpBNfI+v51l2HnTiwgAkXzX
         o1c1cNM4KTvMthuYmhnvBscJx4V4WYRD0SPX+QXMV9t8oSPivLBPunf/FOoLvffjmW21
         4/kA==
X-Forwarded-Encrypted: i=1; AL+hErGaJah1ARMtrxmvrA58Z3rUoUBXprddVZOlYikMq7Py9BL09mxaFGZi0GNq6lV5EAXCR24/92m9cdY=@vger.kernel.org
X-Gm-Message-State: APuU4Z+M/3ARPTznrIYka9cXIx2g8la5McbC3Xs0mBHofZL2UHM3/mAg
	xmh+UShqHhCykCNMEWhPTy9xc1XFCOMNWiLGVdg48wOJmPTHJ64iT4AV
X-Gm-Gg: AYBFou3GGPfE28RAy9FbizBz84YUgult9M2ms/vHaHmBov2SgQdlcuFRWesMlOz7soo
	0GUyoc7P7ScEm7P/FG2QOVylNYYw6ADBnGBAZ5osK/LqL4lC5MF2Bwxl3KKI+g0AUTLVdQZet9Y
	oYVtOetX1DO5ulXfLBcHwp3zMWmsKzzv0VXOsoWt1yKE46nbDnlbtpnNLBOXVn7LS1XWpb14fNz
	mHERArHEW7ycCnW/IRGwAd75Cr/hG4RBDdnyoAN5gAiL1nSWIX36E1bI3taiKYlFId7bxXRwa5D
	uR5CvF41eGD4WN2VhNXp4PPzFIxVIuHQB5/eLb5Ortw7bB2hEyFMLTjLpCvRgqXNmPRZrJIFfVN
	Lqnkfyt4WwKkhAFQA97dqC97L+x9782fFTdz6BR7i9Rvxo157tbFyQDYmWf4J8Tm001YPl8oT+7
	AynLAGgWyFCtKhj1gDkHQLS2KB3K6RMjinXXQkkmtlHihopm/QOnrTmjUYKKxtndLEnDvjK3gRv
	cBgLZuvlGj4hxEKegdWFHje2LNBkHV6hM0po/qqGfX5lvgBo2gt3mOswuWR6h2uyLdJg0/QcPnq
	xhrsQvc8vWjoN8a8qE2W8RMx223bhf2zk0+BBRqVU4WpSfiD9P7SsJfhY/BOQjF+1hS0w95Z4p8
	3uFyw7/mxtebl1olpTcWnPL6fa4AHvT1na3Uvo9NF2xqLHck0G+dyyjcXLov3
X-Received: by 2002:a05:6512:1104:b0:5bf:e341:b175 with SMTP id 2adb3069b0e04-5c003ab5418mr1155367e87.39.1793997627853;
        Fri, 06 Nov 2026 12:40:27 -0800 (PST)
Received: from Lauri-G-Pro-14-M4.intra.lakuz.com (n2vuxegy3pwmc89dqti-1.v6.elisa-laajakaista.fi. [2001:99a:2ab:bb00:c40d:a019:da27:d206])
        by smtp.gmail.com with ESMTPSA id 2adb3069b0e04-5c00306f939sm494383e87.52.2026.11.06.12.40.27
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Fri, 06 Nov 2026 12:40:27 -0800 (PST)
From: Lauri Gates <lauri.gates@gmail.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Dave Chinner <dgc@kernel.org>,
	linux-xfs@vger.kernel.org,
	Carlos Maiolino <cem@kernel.org>,
	Christian Brauner <christian@brauner.io>,
	"Darrick J. Wong" <djwong@kernel.org>,
	linux-api@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-btrfs@vger.kernel.org,
	ocfs2-devel@lists.linux.dev,
	linux-nfs@vger.kernel.org,
	linux-cifs@vger.kernel.org
Subject: Re: Concurrent FIEMAP on reflinked files serialises on the AGF buffer lock
Date: Fri,  6 Nov 2026 22:40:26 +0200
Message-ID: <20261106204026.14530-1-lauri.gates@gmail.com>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <au3wJNbRPXQZG5Op@infradead.org>
References: <au3wJNbRPXQZG5Op@infradead.org>
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

On Fri, Nov 06, 2026 at 07:20:04AM -0800, Christoph Hellwig wrote:
> Please do.  The main question are:
>
>  - do we want it in fileattr_get or as a STATX_ATTR_ in statx.
>  - how do we make the query reliable, and do we even need to?

Thanks. For the newly Cc'd lists: the thread [1] started from du-like
tools that call FIEMAP on every file to count shared extents, which on
XFS serialises on the AGF buffer lock. Dave suggested a per-file "may
have shared extents" flag so such tools can skip FIEMAP on files that
cannot share, and Christoph asked for a patch. Before writing one I'd
like to settle the two questions above and the "two bits" question
below.

To see what the flag would buy, I emulated it: a walker that calls
statx() on every file and runs open + FIEMAP + close only on files
whose XFS_DIFLAG2_REFLINK was set, read beforehand with xfs_db -r. In
all 80 configurations (trees 0-100% reflinked, 1-24 threads, two
machines) it found the same shared files and extents as FIEMAP on
every file.

On placement, a STATX_ATTR_ bit (say STATX_ATTR_MAY_SHARE) looks like
the better fit to me, for two reasons, though I may well be missing
history here.

A du walk needs statx() for stx_blocks anyway, so a bit in
stx_attributes would cost it no extra syscall, while the path-based
file_getattr(2) adds a second call and lookup per file. Median of 5
runs, 100,000 files, warm cache, Ryzen 9 3900X on 6.17:

                               1 thread   24 threads
    statx()                      195 ms      11.4 ms
    statx() + file_getattr()     352 ms      19.9 ms

(An arm64 VM on 7.2 shows a smaller gap: statx() alone vs with
file_getattr() is 79 vs 97 ms on 1 thread, 8.9 vs 11.0 ms on 13.)

The other is that for a "may share" bit, clear is the unsafe answer,
so a filesystem that cannot answer should not look like one that
answers "not shared". As I understand it, stx_attributes_mask makes
that distinction, while struct file_attr has no validity mask today
(it is size-versioned, so one could be added), so through
file_getattr() btrfs would currently read as never shared. A spare
bit in stx_attributes adds no field to struct statx, which I hope
meets the concern Christian raised about spending statx space on the
case-folding RFC [2]. If fileattr is preferred, the bit could instead
mean "no shared extents", so that clear is the safe default, as it is
for FS_XFLAG_CASEFOLD.

> Besides xfs, btrfs and ocfs2 also support reflinks, and nfs (and maybe
> cifs?) can export the semanics remotely.  So we really need a way
> to indicate if the file system could support reflinks to start with,
> and then one that the file could, so we probably need two bits

For du, I think the mask could stand in for the "could support
reflinks" bit if it means "this filesystem can answer for this file":

  mask clear            not reported, fall back to FIEMAP
  mask set, bit clear   no shared extents
  mask set, bit set     may have shared extents

A filesystem that cannot share extents at all would set the mask and
leave the bit clear. If I read v7.4-rc1 right, only xfs, btrfs and
ocfs2 report shared extents, and all three implement
->remap_file_range, so the VFS might set the mask itself for files
whose filesystem lacks ->remap_file_range. What I could find per
filesystem:

 - xfs: XFS_DIFLAG2_REFLINK is set on both inodes in
   xfs_reflink_remap_prep() before any extent is remapped, so clear
   means no shared extents.
 - ocfs2: OCFS2_HAS_REFCOUNT_FL is set on both inodes before the
   remap and cleared only at zero clusters, which looks like the same
   meaning.
 - btrfs: I could not find a persisted per-inode reflink record
   (last_reflink_trans is in memory only and reset to last_trans when
   the inode is loaded), so btrfs would leave the bit out of the mask
   for now. btrfs folks, please correct me if I missed something.
 - nfs, cifs: I could not find a per-file attribute in NFSv4.2 or
   MS-FSCC that could carry it (space_freed comes closest, and nfsd
   does not implement it), so no mask bit there.

A filesystem-level "could reflink" bit might be a separate need:
nfsd encodes clone_blksize for every export and ksmbd advertises
FILE_SUPPORTS_BLOCK_REFCOUNTING unconditionally, I assume because
neither can ask the exported filesystem. Did you have nfsd and ksmbd
in mind for that bit?

On reliability, my tentative answer is that the bit does not need to
be exact for this use. A clear bit must never be wrong, and it never
was in my tests, including a survey of my desktop's XFS root (2.0M
files, flags read with xfs_db -r and matched by inode number). A
stale set bit costs one FIEMAP, so I would document it as "may have
shared extents"; since the contract is only "may", clearing it more
eagerly later would not change the uapi.

Stale bits do limit what it saves, though. The flag stays set when
the other copy is deleted or the file is overwritten; only truncation
to zero and FALLOC_FL_UNSHARE_RANGE (see the caveat below) clear it.
Ordinary copies set it: coreutils 9.4 cp and install, cat (which
copies with copy_file_range), Rust's std::fs::copy, and overlayfs
copy-up all reflink on XFS. On my desktop, leaving out benchmark
trees, 18% of inodes have the flag and 41% of those share nothing.
That leaves out ~/.rustup too: an earlier test reflink-copied it, so
all of its 132k inodes are flagged and none share; counting it, the
figures are 25% and 62%.

On real trees (24 threads, median of 5), statx() on every file, then
open + FIEMAP + close on every file, on flagged files, or on files
with shared extents only, the lower bound for a flag cleared when
sharing ends (/usr has no shared files):

                       statx only  every file  flagged  shared only
  /usr      224k files      28 ms      264 ms    29 ms       -
  ~/.local  372k files      63 ms      506 ms   487 ms    322 ms
  ~/.rustup 132k files      20 ms      319 ms   318 ms     21 ms

Would there be a reasonable point for XFS to clear the flag once
sharing ends? I don't know the code well enough to tell what that
would cost.

The caveat, which may be unintended or may be my misreading:
FALLOC_FL_UNSHARE_RANGE over a whole shared file does not clear the
flag on the first call. bpftrace on 7.2 shows
xfs_reflink_clear_inode_flag() entered and
xfs_reflink_inode_has_shared_extents() not, so it looks like
xfs_can_free_cowblocks() returned false, perhaps on I_DIRTY_PAGES
left by the unshare. A second call after sync clears the flag.

On Darrick's XFS_IOC_GETFSREFCOUNTS patch from your other mail:
thanks for the pointer. It gives a device-wide total without
privileges, which a du tool could show for the whole filesystem,
though not per directory.

If the statx direction sounds reasonable, I would be glad to put
together an RFC with the uapi bit, xfs and ocfs2 support, a man-pages
patch and an xfstest. This would be my first kernel patch, so
corrections on any of the above are very welcome.

[1] https://lore.kernel.org/linux-xfs/20261102193533.93690-1-lauri.gates@gmail.com/
[2] https://lore.kernel.org/all/20251006-zypressen-paarmal-4167375db973@brauner/

Thanks,
Lauri
