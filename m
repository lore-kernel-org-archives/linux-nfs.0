Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5545D4CDDF8
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 21:45:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790804734; cv=none; b=sjyf10iX6E4UyNEUdb2e7meGv+Co1ipRU0aGDyGw3AnPYlz7olkhZycFnx0uRYq5dv9ha2V1pqXLcwSdmgXz473haW4TqvxGkNaVz/L1TCFqrkPzlzr2mb1HprPLB+j32hOdHUjQuiPFKmV0OglVZ2Cqpz5EAt2/7SG7oioGinE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790804734; c=relaxed/simple;
	bh=geikOljM+kIU6XZq5aAl20laJSFQr4ug/PbHf2BECp0=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=HoHLnvIt0Jug5OO+QuLKIqYMq6AnnIdp5WeG0bm8FlcVkXpbwJSdtgs8KAdHb/B/hHziQLv2pRYScm40sBqtYbd292o0PZAAxzSroR4SvL11GDSEpkrpUst83PNFNJ2NYJaS2ioVRIdmhA14/dm4w2zOiNGseXDfZKLud+9KqLA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fJHRP3ai; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fJHRP3ai"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E8E411F00899
	for <linux-nfs@vger.kernel.org>; Wed, 30 Sep 2026 21:45:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790804733;
	bh=CtaMcGNdk30uLxH6xMsSI9tSOyodavZEWPuc1F6yBfY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=fJHRP3ailoi2WXMcwWflPOEKtad/+zZmve+1ldbG4uC8Sy9axs0j9A8oaP0uE0P5y
	 42iXYuVpQfo3mErTaOOl3B+xgBeYJABZ5fQQnpwzLf27TXQFygGcgvZePFSRvfiBxv
	 TV/crI5+RoB+4/2ra1E8Jfc0PZO+heLXbZ0/sr1r41NpW6O5EkMWp0J0dtUarNTDr3
	 c6z4i8eDg+x5ITDIu3HclddWWbx0LWH6QzyN4Ao+vuUBcgiM2F6KBQMd3IL5+p0Hdg
	 cckCudMYHMLRZ/rEs0Pk1nRPxRgaIt1OCPUoI8xZ2JePAfHPaqvAv/ONwl7QnRK45M
	 Aw6UOZzkYI0QA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 1CF77F40066;
	Wed, 30 Sep 2026 17:45:32 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 30 Sep 2026 17:45:32 -0400
X-ME-Sender: <xms:_IK9atwRE5RDnL3nvgiWiPxZJax9ghM35RAwcJTNEI9FTy-FwAN4PA>
    <xme:_IK9aoEWiUjc-lzrGHWJzxmdBAE6XCYgs8nrAp-y4uB3OLCIfQxh_OAx29WAtvIJO
    7ZEnOHM3mHqFutDVIMQdmurkoIOox9Fz8HBbwjeH_IgTosUOKzjpDWG>
X-ME-Proxy-Cause: dmFkZTFs6EsHtvcxDoNPRmnMrcSYgQEpDV5tFUM5Fiw0km0jshs9pcIo3IyHNTXWYMH23c
    nFyBPo1/EewyREUreh5GkAcyf9sK1qqtjLvNPGejzkiIqBQ/gmN4xwvOSfBfZAHPKx8xPM
    9JIYYaX8nuenCK55rvJGjMjzLGAQ4Dkhlm/Zy1xEnPFp0Uu176UWPf+JZVOrvz7aW4t2Z6
    elMa5TU4JBjEmOcIOfJu7SsxKJf362bdPt1GAQA4CP38/faxyZur4JIaX8MOdlJ1Hzzfmm
    pTI+PV4hNO/QTYitYNCyxQHm2n0HdPV8AWv4nBV7orGh/r+NnoJP+552dZ4eJ1U9oQh2WV
    7vl1fpHlR5hWoqYn2f49ZAh39K0r1qKLeFatfTTFVm87GMQVoTWldQx1PU4EWTTSl0Z2b/
    eSh2URlaeoukyIRqxyyAhGIFwOgKp8YcYPCufz/cQMtuEN2+QNM47+P02O4DByFto+2OYl
    6+EXGiPRH2yZacCRJ+b+zNfTFYwtiQCxZzZGwnMp61A+ok7wVRHKA/aeH8tLnn4eN9rtlE
    oSI+L+Ap+mrbkkRzo5MpTHnURKjphhpZ12rAOC/QbLXqkvw0N9Q342Yc/KXHTgFlgUPGIm
    wyMTm8Zo25i7REhOWQXKaiOOL4+KsrObomroLzhuwJxATwaGRFr56LgC3ktQ
X-ME-Proxy: <xmx:_IK9alMHAtCxlguHtbmW4J9dURSKEfa_LLdcUDiso25KzPL_v6Z5EQ>
    <xmx:_IK9avszwAYPUYY5m-oOB8ZPydJJ59lsoPd0LXYiI1tb2sNmixGlGg>
    <xmx:_IK9anUfT44iVXr_MlvTDZi9Wb3icR9zeUTJbvC3bI3D4ObRW7qp_A>
    <xmx:_IK9avsDYS4u7b9ZqOrPVlVjkhtmBBEDRMZ40r_XxRVpcdETC1y4TQ>
    <xmx:_IK9arU9GaysRVR9g1TyCz0gPps1kpgahxJXbas_ZhC-vvxaOl22--YT>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 02A3B780070; Wed, 30 Sep 2026 17:45:32 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ARSqHijOgxAJ
Date: Wed, 30 Sep 2026 14:42:59 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Message-Id: <6115b92b-46fa-4837-a088-c8d601dceb61@slotpi15m67>
In-Reply-To: <20260929231329.22018-5-snitzer@kernel.org>
References: <20260929231329.22018-1-snitzer@kernel.org>
 <20260929231329.22018-5-snitzer@kernel.org>
Subject: Re: [PATCH v2 4/9] NFSD: Enable return of an updated stable_how to NFS clients
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Tue, Sep 29, 2026 at 07:13:24PM -0400, Mike Snitzer wrote:
> From: Chuck Lever <chuck.lever@oracle.com>
>

One note before the review: this patch, as posted, did not apply to
the current cel/nfsd-testing branch without a conflict. The
fs/nfsd/nfsproc.c hunk is against the older nfsd_proc_write(); on
nfsd-testing that function is now the xdrgen-generated variant with
argp->xdrgen.data and a separate count variable. The resolution was
mechanical, but the series needs a rebase before it can be applied.

[ ... ]

> This patch prepares for that change by making the @iocb_flags
> argument of nfsd_write() and nfsd_vfs_write() bi-directional. A
> caller passes in the IOCB_* flags that express the stability its
> client asked for; on return the argument holds the flags that were
> actually satisfied. Each protocol version maps that result back to
> its own on-the-wire value when it encodes the WRITE reply, using the
> new nfsd3_stable_how() and nfsd4_stable_how() helpers, so that NFS
> stable_how values stay out of NFSD's generic VFS API. No behavior
> change is expected.

Is "No behavior change is expected" accurate for exports with the
async option? See the question on the vfs.c hunk below.

Also, "Each protocol version maps that result back to its own
on-the-wire value when it encodes the WRITE reply" does not quite
match the code. NFSv2 passes &iocb_flags and discards the result,
and the NFSv3 and NFSv4 mapping happens in nfsd3_proc_write() and
nfsd4_write() right after the write call, not in the XDR encoders.
Something like:

  NFSv3 and NFSv4 convert the result back to their on-the-wire
  stable_how with the new nfsd3_stable_how() and nfsd4_stable_how()
  helpers. This keeps NFS stable_how values out of NFSD's VFS API.

[ ... ]

> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 1d2b03cb42963..82eba97656c4e 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1444,7 +1444,9 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
>   * @offset: Byte offset of start
>   * @payload: xdr_buf containing the write payload
>   * @cnt: IN: number of bytes to write, OUT: number of bytes actually written
> - * @iocb_flags: VFS IOCB_* flags expressing the requested write stability
> + * @iocb_flags: IN: VFS IOCB_* flags expressing the requested write
> + *             stability; OUT: the flags actually satisfied, which may be
> + *             higher than requested

Nothing in this patch raises the flags, and the only change to the
OUT value below lowers them. It might be clearer for this comment to
describe what the function does now, and let the patch that adds
promotion add "or raised". The same text appears on nfsd_write().

[ ... ]

> @@ -1493,11 +1495,11 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  	exp = fhp->fh_export;
>
>  	if (!EX_ISSYNC(exp))
> -		iocb_flags = 0;
> +		*iocb_flags = 0;

Before this patch, the zeroing here hit a local copy, and the reply
echoed the requested stability:

nfsd3_proc_write()
	resp->committed = argp->stable;

nfsd4_write()
	write->wr_how_written = write->wr_stable_how;

With this change the zero flows back to the caller, so a FILE_SYNC or
DATA_SYNC WRITE to an export with the async option is now answered
UNSTABLE:

nfsd3_proc_write()
	resp->committed = nfsd3_stable_how(iocb_flags);

nfsd4_write()
	write->wr_how_written = nfsd4_stable_how(iocb_flags);

RFC 1813 section 3.3.7 says that if stable was FILE_SYNC, committed
must also be FILE_SYNC, and anything else is a protocol violation.
Table 20 in RFC 8881 section 18.32.3 allows only FILE_SYNC4 for a
FILE_SYNC4 request. The Linux client takes its "faulty NFS server"
path in nfs_writeback_done() when committed is lower than what it
asked for, and sends a COMMIT it did not send before, which
nfsd_commit() turns into a no-op on an async export.

This is the same problem that stopped the May 2026 posting of this
patch. Jeff withdrew it then because it was not clear that clients
are prepared to send a COMMIT after asking for a stable WRITE:

  https://lore.kernel.org/linux-nfs/e13b7b601f0cefda78cf96458e6af6e466cfb5f2.camel@kernel.org/

Nothing in this revision addresses that, so I can't apply the patch
as posted. It changes the reply to every stable WRITE on an async
export, and this series needs it only so that a later patch can
raise the reported stability, never lower it.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
