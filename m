Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66EB229BDB5
	for <linux-nfs@vger.kernel.org>; Sun, 23 Aug 2026 16:18:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787501893; cv=none; b=LNJtTYfUueKmm5mea85IhbSX0bdl5KJr0ioF3IYEEGz6AR5n+UicuWnqlPgWU+XDcKErJq0DYJU4wqbDfXmwhgLzXXsjzWUpKOZ8L9p8QjImuEoHnyCpoEZ0e5Vi+VAnz8yJ6P900a1OT/pXvfNlLn805HcRs4UDFvKBEks6w9Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787501893; c=relaxed/simple;
	bh=63/ChlT20yS/LPviYlBW19bappE7aXURzHNf9uySaAc=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=lTZvSufNK7/+/7FIJ0Q3wMkul8bIWJtswpORX/EGA01yTpTwDtDwJMm01VDp0PtW9c132hG6rPqmTbAW/HTnR9raapG4vkyuJAzr2/Wz3/pnJreRgD32MYTyedJdEZumGUOTvVMLeM5SwCMdCFDxj5UzhtvQi7xOaEo944JlR6Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Y+sc/cyG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Y+sc/cyG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 25E231F00A3D;
	Sun, 23 Aug 2026 16:18:10 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787501890;
	bh=z8Jg42LIBWbstVDAWk39jiVDx6Dr2dwk4I9Gs2bWH5E=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Y+sc/cyGiK/zCGBEcFAch0oCD69knMLSzrKLWHH0r4/G3txyUstqDnMbFBB+la7O6
	 6u8ttqe62qA1W7tdkFmQiFpkd0q8icTC0uhRwzA+E77d20viMi+IlewZQVcTMQkCGF
	 gD3yR/oKDN2r9o9Y9VipeOAmW6owNw+aI3RfJ5TQo/adUdpEsRonuu7NL3TfkPtAoG
	 J7HEburG6k0CiIPhJPctKuyb3C882bJrBZkor9zuRof8FKFtuOvnep0chQRJgfVizn
	 dwoANaGeJJX6bLixchZYDWNhKSYa5NXzmfjWgSEKQMZ+3W0QrX32POsKUUo9J/Ltoo
	 cVQpl9xUhjr8w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3965FF40068;
	Sun, 23 Aug 2026 12:18:09 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 23 Aug 2026 12:18:09 -0400
X-ME-Sender: <xms:QR2LagEFGzBg2RH1xsdT71NLwveSC7LIdkK1vm_3ytCc7L0x__WDhw>
    <xme:QR2LakLbehi41QcTQIPfddJ1Y1RRvJrisPdHkzBPgihbT5mHxojgUz_sHMlF7faJD
    Ku9_bqhofU2VmKI6QUptWbiUbmSptbquZUiF70Wrc5k4sfKXLQ0BpNP>
X-ME-Proxy-Cause: dmFkZTGQYiar4/wH1ZX+ko5p5V8Jb47gXoBT4LrZ/33NQC8+2di23n4yKsjb85tRwa9hX/
    vcGCG1meDdZMzBIEW1cULJBgLbaRt7rvXgUnjrzX+nE3ufqmtxw/h3zSgf3ppmHw/aFOBO
    RnkPq0xdbDuIc4NEdN7a6ahqJIG8iTXpYm7W4SNy/FRs7+IW33536gPLeAfYGZMKk22R7R
    AsSGswH336lfLPVZ3YJu58Kwf0jkSuk8wKKal5SXP79+HJ7/gJZ4l7lZYE/Hv1zmwIv7O4
    KKhNOf9h58l7qe3FtRkFjWW3Mx1zRuawf4VCTd1YzKNPR2B/se5P02yxr0NCjDYzpKu8CG
    khblCAeT8ebwf2KXTE0J8aQdNSF7mJ1E9QjAcZZc8t+ZMX/FPz8T1qAQh+NkIiYugCSwAv
    qzhUtmf7ZNG20KZrqsw3Napw9MjPHn6/A5Yewmd1rX5gcGQ0GB++4jKyrexxWu0QHV7Bnx
    ZGn8yH7Y1FNMditTYL5CIa8N9sPqCQU5hfkC5E8GljzycRMbJo595WMBmUEFN+D9SFr6In
    hOP0kTZBH7sQtbQrZoZO5A7yjmLt6rJ+0VEA04mlsQXphcMlBiTSRAoXot+Lpv/RZl3sce
    NZz5RNg6wDFB7XOFZih+q+UNRyumbJyWdqeiyObXBLx3eoFeLhafke8HXhQQ
X-ME-Proxy: <xmx:QR2LavZImFoEewH_S1WaEIAmVvfTPWAAq-n-Zx_8GhuHJK7jE3yD9A>
    <xmx:QR2LaoYyFXBVEE21YlupvqTulKpR5xWdUnNLKCedGnXnJMbTBJRYbQ>
    <xmx:QR2Laol1MbR6t8-3yO4U1CZaMhDGdk9ZAuiq-kUYxHxUVinjg12r1A>
    <xmx:QR2Laj0frDFIypibvCyqe5lzbBc1h_hQs-ngSem_GNeCncnT5fjaVg>
    <xmx:QR2Lao1rWf-szB2gTpqsrMdegR2o0Fbjurd90V5WJZdr5_6nv2cUZpSr>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0C7407811F0; Sun, 23 Aug 2026 12:18:09 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A9rAnHCH3z6s
Date: Sun, 23 Aug 2026 12:17:50 -0400
From: "Chuck Lever" <cel@kernel.org>
To: prabhakar.pujeri@dell.com, "Jeff Layton" <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Rick Macklem" <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org
Message-Id: <2805508b-99b1-4bfd-bdd5-cd07ba0789f5@app.fastmail.com>
In-Reply-To: <20260823113255.3417-1-prabhakar.pujeri@dell.com>
References: <20260823113255.3417-1-prabhakar.pujeri@dell.com>
Subject: Re: [PATCH] nfsd: release POSIX ACLs of unexecuted compound ops
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Sun, Aug 23, 2026, at 7:32 AM, prabhakar.pujeri@dell.com wrote:
> From: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
>
> nfsd4_decode_fattr4() allocates POSIX ACLs while decoding OP_OPEN,
> OP_CREATE, and OP_SETATTR. Normally a processed OPEN releases them from
> its op_release callback, while CREATE and SETATTR transfer ownership to
> struct nfsd_attrs and clear their pointers.
>
> If compound processing stops before a decoded ACL-bearing operation,
> nfsd4_release_compoundargs() frees the operation array without dropping
> those ACL references. A client can repeat an aborting compound to leak
> server memory.
>
> Release ACLs that remain attached to decoded operations when the
> compound arguments are destroyed. Clear the OPEN pointers in its release
> callback so the final sweep remains idempotent for processed operations;
> CREATE and SETATTR already clear theirs when transferring ownership.
>
> The procedure release callback also runs after a hard XDR decode failure.
> Keep opcnt limited to fully initialized entries on a truncated operation
> number, and clear it when the dynamic operation array cannot be
> allocated, so cleanup never walks stale inline entries or beyond the
> inline array.
>
> An A/B kmemleak test with 512 crafted NFSv4.2 compounds found 347--349
> leaked 64-byte ACL objects without this change and none with it. On the
> rebased kernel, 512 runtime-abort and 512 hard-decode compounds completed
> without a kmemleak or KASAN report.
>
> Fixes: 5fc51dfc2eb1 ("NFSD: Add support for XDR decoding POSIX draft ACLs")
> Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>

Hi Prabhakar,

Thanks for the report. I agree with the diagnosis and its status as
triggerable by a remote. After careful review, I have decided to
split the work into two patches.

Your two opcnt assignments fix something separate from the ACL leak,
and that fix needs to be backported to stable kernels.

For the ACL half, the underlying issue is that ->set_acl() borrows
the caller's reference rather than consuming it. That makes pointer
ownership the true root cause, which IMHO needs a different approach
than your proposed fix. And, since POSIX ACLs in NFSv4 are
experimental and disabled by default, it's something that can be
treated as mainline-only; no backport.

I'll post these as a two-patch series soon for you to review and try
out.

Can you share the test that generated the 512 crafted compounds?


-- 
Chuck Lever
