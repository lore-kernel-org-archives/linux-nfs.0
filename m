Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 584DF2BE639
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 21:03:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791320605; cv=none; b=hdlp11hnx97/wwACrFBQmdHPkq12qS/JQ5+/DaKko1rzNVCDtQko6zOcusg4msiaPGXpXMM1bjpKaBgV44qy1KQSIVW7ymSdtbHA7B6s3sWdiSMvafJpnUGXDf03T0Gk4YkXOt4PjkxWoDm162mf5gW5WCjB+F/eEsKFoTylhz0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791320605; c=relaxed/simple;
	bh=3qarz5B9iHtqTX4uWzSown/yyrD/532F02sGNrkdNgQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=l1L1blEUoJ30r20xJoB44VUd/oS4uQRm/ETmBUbhQPKL077oAJe1TjxUTdCJi5hCw3KTe3HEgCG1hNxakza+scQKrQ9AWIQKrtY2J/EyG2i2Yrsei+6bKlpx2uvSjZuRODqiuK0n+QM/nCK1ae9lOupOmhGid7H8mW3WlplyRSA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aUVaqcBW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aUVaqcBW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A87941F0089C;
	Tue,  6 Oct 2026 21:03:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791320604;
	bh=uf/ILQj8JaAPaF5rkcSuibv4CHVXczOZkrMm321klDg=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=aUVaqcBWNA4JC5ARlKUhZcrsGGSquRx3R/APW3PoAIWK/UwW1WEEGS+0NCvZpbFDC
	 FrG2ZNCnwtBhX9f67Imfrvc2C2TV0vsbUZ/6tg00EBcw10TYeAcATPFTw0SSaPL/aL
	 HPRrx7uspQL0wXDkL4gugkLR0FNn+8trVIX0R8ge6Nd62FJgCs/Kr+9XyB7LhvLOg6
	 qJOZO4jLSdzT/0vOhRuGkUNWTdTCqDM1WuVcfRzDDOvZu6+FwQhW5iMHt1UHtkZKQj
	 N97UDLvs8rskAXCY0zN2ko0GtN2JjREFBe8DXeFASxBpwfX4bXbOi2SnTCenpZY/sP
	 T6rx54yy3CCKw==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id DEAF6F40066;
	Tue,  6 Oct 2026 17:03:22 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 06 Oct 2026 17:03:22 -0400
X-ME-Sender: <xms:GmLFamB7B24ybDCoMf-6dXUpr2TdEaXyWTHU8vN2moZ8EyXJHQa5ow>
    <xme:GmLFarWbFmoueNMcFrGMH9C7m9PeGU3drcKjmfdREWoKotBRRoPOhRjzJDz7ttiiY
    JWhKcgMeBee9qH2C29rlsCy0tT9YNubw2ny5oMPi48wz-1HIHzNJJV7>
X-ME-Proxy-Cause: dmFkZTEbskDY6lb/CTt4fHE+hUvfXQpsCI4gl7D/LnkhRiuThFkBLCyLjMdimqlOXu252E
    pjMNxXSu0N3n/2b1qB+IuAb9Y7GTgBox7v0MH0ANUWDHYyCbg48Pv47BxckzaKLm2sU4X/
    Txi1Ry9vtgeJo+dP3pd3qfp7Qftniu1wJGyeKW85/o99rJUUyQlSKJqjtIS0sQOuvTEW7y
    c+abT4yUG1yzlHtMxIdf0toyPzXloaneK/AuKSG3GUGxPd78I8VmqRj4HibyqPCSZk+HaV
    ANtrcbXsc4y0LRQUhZAcPsH0iJTncOP+SKwrfKyjRvp4GNxjvBr9kVkln3UcIoBsL6BVSo
    Qu40z5onKboGgeeHGKEyg12GFo5Lp/wVgYtJP2e1j9FdXu/Nr9i4UZOJzufkQOyth14cyU
    W4IMYu/waoWcri4ANooZB/voQh2dKXxUcDHGG4dzsgj3yhb7F0SlyyxsgcIubiwM66ZHr1
    5NQ31lf6RZWjtfmL8EDHjUs7DW49SKk6lnKVqOi850/S2kZPq4ckpWAXzHm98fHL/psEyp
    Mb5rOdGtZr8wI/y+I16OjPiypXqD+SusuE7lwFhkDnFdYYVa/Y0XjByVaosEbkobWEvgdA
    1h52kzP/LNjTJWLxgttFSMlcssuq/EGPwsLb/fdnrQ1c3nKdCXaVpdkwdcLQ
X-ME-Proxy: <xmx:GmLFahj_R97iopHr0WCMpk7sB_p64bCNvkUJCXm_BDA7Qgr1D0uSxw>
    <xmx:GmLFapEubH4Fv_IJpC3922H6ZNhdFLdTp9Drk9pfwlA5oTNUjX5fCw>
    <xmx:GmLFarvxrw0vvM6TIePZT-V0BHbMm1P4AfgX3ekR9ScJv4INoGLzdg>
    <xmx:GmLFaidmfsLdE7uf_wErdV_3dWhusbvuaTQU2xPvAYLNDj2gAgdBzA>
    <xmx:GmLFapnxTPHFHvbZHk890wgwiUOe7Wv8JyLgbLLA10yRFIrGrdIAOKJf>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id BCEC4B6006F; Tue,  6 Oct 2026 17:03:22 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A4F22hcLF66F
Date: Tue, 06 Oct 2026 17:03:02 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Mora, Jorge" <Jorge.Mora@netapp.com>,
 "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>,
 "Scott Mayhew" <smayhew@redhat.com>,
 "Benjamin Coddington" <ben.coddington@hammerspace.com>
Cc: "rushil.patel@gsacapital.com" <rushil.patel@gsacapital.com>,
 "tim.saunders@gsacapital.com" <tim.saunders@gsacapital.com>,
 "mark.brading@gsacapital.com" <mark.brading@gsacapital.com>,
 "ben.roberts@gsacapital.com" <ben.roberts@gsacapital.com>
Message-Id: <d39afd89-0543-410c-8c3a-c8869ba643bb@app.fastmail.com>
In-Reply-To: 
 <SA1PR06MB113533BFC97DA85AE6D37D99DE1962@SA1PR06MB11353.namprd06.prod.outlook.com>
References: 
 <SA1PR06MB113533BFC97DA85AE6D37D99DE1962@SA1PR06MB11353.namprd06.prod.outlook.com>
Subject: Re: Close-to-open consistency on SIGKILL
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Jorge,

On Mon, Oct 5, 2026, at 7:38 PM, Mora, Jorge wrote:
> Hello,
>
> I'd like to get the NFS client's view on a patch that showed up on
> linux-mm, and in particular on how the proposed behaviour interacts
> with NFS close-to-open (CTO) consistency.
>
> Background
> ----------
> Rushil Patel reported that on NFSv4.1 (Slurm jobs, NetApp filer),
> cancelling a job can leave processes stuck in D-state in
> folio_wait_bit_common() while __filemap_fdatawait_range() waits
> uninterruptibly for writeback. If the server is slow or unreachable,
> the only practical recovery is rebooting the client.
>
> The linux-mm patch:
>  =20
> https://lore.kernel.org/linux-mm/20260325113616.785496-1-rushil.patel@=
gsacapital.com/
>
> The patch makes the wait killable, and also skips the wait entirely wh=
en
> PF_EXITING is set. The PF_EXITING part is needed because after SIGKILL
> wakes the first wait, do_exit() -> exit_files() -> nfs4_file_flush()
> -> nfs_wb_all() re-enters filemap_write_and_wait(), and at that point
> wants_signal() will not deliver SIGKILL to a PF_EXITING task, so a
> second killable wait can hang forever.
>
> Matthew Wilcox's reply (CC'd linux-nfs):
>   https://lore.kernel.org/linux-mm/acQ0YRLM_SxYfjfI@casper.infradead.o=
rg/
>
> suggests that the PF_EXITING special case may belong in NFS rather
> than in __filemap_fdatawait_range(), e.g. in nfs_wb_all():
>
>     if (current->flags & PF_EXITING)
>         ret =3D filemap_fdatawrite(inode->i_mapping);
>     else
>         ret =3D filemap_write_and_wait(inode->i_mapping);
>
> He also flagged the subsequent:
>     ret =3D nfs_commit_inode(inode, FLUSH_SYNC);
>
> as another possible synchronous wait that could trap an exiting task
> even if the filemap wait is skipped.
>
> Matthew's take on CTO was that other filesystems do not flush-on-close
> the way NFS does, and that it is probably acceptable to weaken the
> guarantee for an involuntary termination (SIGKILL / exit) rather than
> an orderly close. I'd like confirmation (or pushback) from the NFS
> side before we settle on an approach.
>
> Questions for the NFS client community
> --------------------------------------
> 1. CTO on involuntary close
>    NFS flush-on-close exists largely to uphold close-to-open: after
>    close, a subsequent open on another client should see the writer's
>    data.
>    If we skip waiting for writeback (and possibly COMMIT) because the
>    process is exiting after SIGKILL:
>    - Is it acceptable that CTO may not hold for that file until
>      writeback/COMMIT later complete (or fail) asynchronously?

I think that if the user is explicitly killing the application, then they
are already aware of the risk of losing any unwritten data. This does
sound like you want 'softerr' semantics for killed tasks, however.=20

>    - Are there known applications or protocols that assume even a
>      killed writer has pushed data to stable storage by the time the
>      file descriptor is gone?

Not that I'm aware of off the top of my head (but of course, that doesn't
mean they don't exist!).

>    - Should we still initiate writeback (filemap_fdatawrite) and an
>      async COMMIT, and only avoid the wait =E2=80=94 or is skipping mo=
re of
>      the flush path preferred when PF_EXITING?

I would prefer still making a best-effort attempt to writing back stale
data since a slow server will eventually process it.

>
> 2. Where should the special case live?
>    - Generic: PF_EXITING / killable wait in __filemap_fdatawait_range()
>      (as in the linux-mm patch), affecting all callers.
>    - NFS-specific: change nfs_wb_all() / nfs4_file_flush() (and any
>      other flush-on-close paths) as Matthew sketched, leaving the mm
>      helper alone except perhaps for making the wait killable.
>    Preference? Any other NFS entry points that need the same treatment?

We should probably handle this in the NFS client since it sounds like ot=
her
filesystems don't have the same issue.

I hope this helps!
Anna

>
> 3. nfs_commit_inode(..., FLUSH_SYNC) during exit
>    If we only replace filemap_write_and_wait() with filemap_fdatawrite=
()
>    on PF_EXITING, does FLUSH_SYNC COMMIT still block uninterruptibly
>    on a wedged server? If so, should exit-time flush use a non-waiting
>    commit mode, and what are the CTO / stability implications of that?
>
> 4. Error reporting / other openers
>    If the dying task stops waiting, writeback may still fail later.
>    Mapping wb_err / errseq_t should still surface errors to other
>    users of the inode =E2=80=94 is that sufficient for NFS, or do we n=
eed
>    explicit handling so that a later open/revalidate does not
>    incorrectly assume a successful close flush?
>
> Ask
> ---
> Could people familiar with the client's CTO and flush-on-close paths
> weigh in on:
>   (a) whether weakening wait-for-stable-storage on SIGKILL/exit is OK
>       for CTO,
>   (b) NFS-side vs mm-side placement of the PF_EXITING bypass, and
>   (c) what to do about FLUSH_SYNC commit in that same exit path?
>
> Thanks,
>
> --Jorge
