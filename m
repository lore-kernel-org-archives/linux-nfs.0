Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6206645FFAC;
	Tue, 18 Aug 2026 13:56:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787061379; cv=none; b=pXnqfx0HwMTvpN/U9j1kkCl+cdWDuB23iAev9gBpsO0ytq3as3hzdZgn6JsPe2ohIeYKMTPuGdDxDeXxywbkSmH9foJMXbto/J8RQwPUKIL2x05PbcJRrhEr27BPi6evs6OAE7svkFS4u1cvFLHt6q9WLd8g98nIcSfXoIHbXTs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787061379; c=relaxed/simple;
	bh=aao7z+XRm5o6aqYkurUpBscTKB4yD4PhcGGM0UJGE+s=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=HLKjTE1MjM3qyqXlW/yGCe2EQgNNdDET37lx8TxF7tnVHhuXOVadacJPwT567DnceOcBsrzoXwZ5f9dEzDNPX0CtBgCrLzf5/XaA9gH3jFmusNeJ27qJg6MAtpQZq7zKUuOykN+Fd3r2WylP/uED7eHbEqchjO5sydz8d9oYXBo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Xi2Cqr30; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Xi2Cqr30"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6FBDC1F00A3A;
	Tue, 18 Aug 2026 13:56:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787061378;
	bh=hSrm4KTy+gUWwt0XGZi04OL8Twc1GSoMmGR6D9kQP5E=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Xi2Cqr30FEZEfK4lFGBiquxU1jhWKV2v3Kf/RYm9beLZMPrAiG0yQAd3LCkJXhl8V
	 WwQEniC48UZhN+gp5YOZm2UI4D5CXgdFZbz0Iocg2XGVbBwpPg1xVdg5e/O5UQaQri
	 0/WxqI3rfy3MJgf2qs69WFlMj/8R8gcHPwPVwwdeYEg6n1qzDf4nZ/ftEMF4dFEmQD
	 /8wfOq9y8dTzpAY5vXPsLWCmENeLwEt45z/wJhJ1IGxBbox/b7wrgDAALDn/UhhUWv
	 VT5ZdjBXV8hq93tddHtVv+rKDYmV92IGbhKjsxdpsBq5WzuxXP6PUgTWkZl6VfUvWw
	 lg8GIiHhKjpFQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 69933F4006C;
	Tue, 18 Aug 2026 09:56:16 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 18 Aug 2026 09:56:16 -0400
X-ME-Sender: <xms:gGSEakpMmOjXy2CfZQSiBcAdoOjzl87f4mmU1ChOPxi1IGSNsGpdIw>
    <xme:gGSEalfLKTmC8yQpUqFmFUg4OGeuL-OpjehEogfv2n6_6nsNeDmQQFFuX61no4ywg
    1CSuDiHmo8JJBkiasD-VDJh1ZMxQwKy68U2xUHCnvHZqVblIpOrDRSa>
X-ME-Proxy-Cause: dmFkZTFiIKXIYfS4NUJRZRC6rYIJOh28U3PNu4nlwOX7Oyejv+vlp4isUjvyHoafb2B/c9
    7y6eEDBLmy+PGUpuB4iddPyTnWcRkgQgKmwAR1ZfQL7Z0xC6aa2ZrJxwdX269N7LLAKskq
    qVSCB3llm40aG6L0xF3pvk5WxBFOb+4lfhVTok6a08hNaYebUPdHcywsQ3WNh1zu0IFX4V
    RsKYxFx26yVjHJ+B4yU0dSisqPHDUlHXWqrMSD0aKCrXpVMHUUCd4RxJHAQqqkuL+WgcvY
    e6spygztJuoxjESzeiLgi9cntjQKBOmJOCfYa2MuCCuKCXeEQGvOyAdj4Akua9R3tzqxjJ
    LjacWBwmtw/fZwyUXpeKXLVMJJ6kmsyl9aHB2/n+WRmwSi/p02gQGbyiXqNmCRMcQAEKCN
    wOH5UIFhU/XB4xyX5CLH95QILmY48iijvpWp9w6sGOBQo2YOAHslhIqjvZMPgrA3D1JSv2
    ZJnqYC8Dvy4vMSLclyPL7pJAGxNxKiTWa3obdEXxEm70BTJSWWdgsIGk0zbRKyj8onuhs1
    38EQXFkayxzSpkBsCMsoQVXmpO29T3fe+iBjG2jaDg2W2GLbKkbYPbWcTqk1t9zUuaiHGV
    Stog6mYLc8iWwpBhIdVULlQ+GJmSYnOrblj1IKeBjj6BtbmKYMgT+SBVYfvQ
X-ME-Proxy: <xmx:gGSEahhtNjMjh1js0NlD-funrIRz4VAJKMyNLE1IMqH-mGW975pwlg>
    <xmx:gGSEauLUTkHub5EGhMzMzCFaHf0l65FOPIgw62iDqQD-jI__mA38Kw>
    <xmx:gGSEagm-xKe-F-xNP0L15xZg28M8tdjKOFpwqFArdBAEDRqXFgswZw>
    <xmx:gGSEamN-N4LrfOP_XU9eY2l3jAFIXl3hZlsIOpboTsND3mffRBWTmg>
    <xmx:gGSEaq7jYSekh-LqyrY4t5SH0Xy0PxrPO1JLiv28pQ-_6fXTQMIJck5Q>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 43F2E7811F0; Tue, 18 Aug 2026 09:56:16 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AoVkO0MTrhO3
Date: Tue, 18 Aug 2026 09:55:56 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Ameer Hamza" <ameer.hamza@truenas.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, alexander.motin@truenas.com,
 caleb.stjohn@truenas.com
Message-Id: <2ed0ee16-c20e-44bd-9e7a-f5b71764f14f@app.fastmail.com>
In-Reply-To: <20260817210811.3984663-2-ameer.hamza@truenas.com>
References: <20260817210811.3984663-1-ameer.hamza@truenas.com>
 <20260817210811.3984663-2-ameer.hamza@truenas.com>
Subject: Re: [PATCH 1/2] NFSD: Use nfsd_iter_read() when ->splice_read is not zero-copy
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Ameer -

First off, thanks for posting the full series to provide good
context for your problem statement. Contention in the page
allocator is vexing, and is a problem we've been chasing for
years.

There is a lot to unpack. I'm going to focus on patch 1/2 and
set 2/2 aside for the moment. I promise we will come back to it.


On Mon, Aug 17, 2026, at 5:08 PM, Ameer Hamza wrote:
> diff --git a/fs/nfsd/vfs.h b/fs/nfsd/vfs.h
> index f0cb184643f2..70bd3c6fc188 100644
> --- a/fs/nfsd/vfs.h
> +++ b/fs/nfsd/vfs.h
> @@ -149,6 +149,35 @@ __be32		nfsd_iter_read(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  				unsigned long *count, unsigned int base,
>  				u32 *eof);
>  bool		nfsd_read_splice_ok(struct svc_rqst *rqstp);
> +
> +/**
> + * nfsd_splice_read_is_zero_copy - check whether splice can avoid a data copy
> + * @file: file to be read from
> + *
> + * copy_splice_read() reads via ->read_iter into freshly allocated
> + * pages, exactly as nfsd_iter_read() does into pages nfsd already
> + * holds. Filesystems that implement ->splice_read with it gain
> + * nothing from the splice path, and neither do DAX files, for
> + * which the VFS substitutes copy_splice_read() no matter what
> + * the filesystem registered. The VFS substitutes it for O_DIRECT
> + * files as well, but nfsd never opens files O_DIRECT.
> + *
> + * The test is one-sided: a filesystem's own ->splice_read method
> + * may fall back to copy_splice_read() internally, as ceph and 9p
> + * do, and that cannot be detected here.
> + *
> + * Return values:
> + *   %true: splicing from @file is not known to copy
> + *   %false: splicing from @file would copy, or is not supported
> + *           at all; use nfsd_iter_read()
> + */
> +static inline bool nfsd_splice_read_is_zero_copy(const struct file *file)
> +{
> +	return file->f_op->splice_read &&
> +	       file->f_op->splice_read != copy_splice_read &&
> +	       !IS_DAX(file_inode(file));
> +}

[ ... ]

The iter_read path appears to have two pre-existing problems
that will be exposed to even more file systems when 1/2 is
applied.

1. fsnotify double-counting, which you mention
2. atime is not updated, which shows up in LLM review

LLM explains it this way:

--- cut here ---

nfsd_splice_read() picks one up from the VFS on the way through:

fs/splice.c:splice_direct_to_actor() {
	...
done:
	pipe->tail = pipe->head = 0;
	file_accessed(in);
	return bytes;
	...
}

nfsd_iter_read() has no equivalent, so it leaves atime to ->read_iter.
That works out for most of what moves here -- gfs2 reaches
generic_file_read_iter(), cifs direct I/O reaches
netfs_unbuffered_read_iter(), and ext4_dax_read_iter() and
xfs_file_dax_read() both finish with file_accessed() -- but
fuse_dax_read_iter() leaves it undone:

fs/fuse/dax.c:fuse_dax_read_iter() {
	...
	ret = dax_iomap_rw(iocb, to, &fuse_iomap_ops);
	inode_unlock_shared(inode);

	/* TODO file_accessed(iocb->f_filp) */
	return ret;
}

The second runs the other way.  vfs_iocb_iter_read() emits an fsnotify
access event of its own, and nfsd_finish_read() emits a second one:

fs/nfsd/vfs.c:nfsd_finish_read() {
	...
		*count = host_err;
		fsnotify_access(file);
	...
}

splice_direct_to_actor() emits none, so the event in nfsd_finish_read()
is the only one the splice path gets, and one too many for the iter
path.

Both are reachable today without this patch.  sec=krb5i, sec=krb5p and
nfsd_disable_splice_read all reach nfsd_iter_read(), and NFSD_IO_DIRECT
reaches nfsd_direct_read(), which calls vfs_iocb_iter_read() and
nfsd_finish_read() the same way.

--- cut here ---

So what I'd like you to do is provide a backportable fix that applies
before your series to address the fsnotify and atime accounting issues.
I'm not convinced that stable will want the bulk of the 1/2 changes as
you have them here.

I don't expect this work will be a heavy lift, but let me know if it
turns into one.

-- 
Chuck Lever
