Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 863F22EEE76
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 23:18:12 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790723893; cv=none; b=arwxgnY+a0U5VReXC3iUL6c+NOt51YLG31MamJlRPhiAq7SezQP2TLWQ5Jq+8X5K+H51bsZggxdRC70G60ah8s8lwzsvMBZ8dTc2niOpzOdkuegRGCBVDj7fbjRlsev1e45BG6c5Rfc6fJ3NnAcKIzo5qdiCEybBD+AP2bDDLLM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790723893; c=relaxed/simple;
	bh=3aYOFj61jL5y6ONyS+nrY5uDOHrujCLI0FE+2DIhUKc=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=gWhilqjCvSq3zfKjrlHjo+L2QpwhtKi6+ua6BMV1dRb7sEaTV8IAW0G1BL0RA0uhTEA+aU4oJx51gB7thdnguKMig+hFMD5kPlfFPGU4hgv/zkwN5j5H1x3NykXl0mTGJXnOVGeTAm+GTFCuyQGD3aGRWFD58iJsvze4jruHl4Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nb0dc4w+; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nb0dc4w+"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0123D1F00893
	for <linux-nfs@vger.kernel.org>; Tue, 29 Sep 2026 23:18:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790723892;
	bh=owF2LDCue+mmtARKbnVjObSYP8riay5OsFD1WmgvVCw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=nb0dc4w+Wghyizext0cy1FFOEV8xxtfbdmDIAGEWwXlbyqdBtj14ADNq3doaLAHzF
	 nuH9yhUSdSd0egbXytdCFom0Kp7uoBh7NnAsitVEHTLTqY+pqd974EbnfrHTm4Pc8c
	 6LvGw+INhnmTspNnB7TRhqi/3F/Y/0Fyr+/DB5Hv3wQaHZEdlkXoL8FiLeqDdXx67O
	 Wz+2ask1lUNTwXLDs5jDdpJaBaHZdX0HZAbcwisl1ns4ZYUX7r+FGF9e8forjEQqsx
	 e0rJwjaTOoTpeg9jY5i468umN6yZGk9TqyR1mfbDaOJOFtiOWdOJ53mwl7QvoAB6AS
	 fAPPbmqa4f7UA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 1483DF40066;
	Tue, 29 Sep 2026 19:18:11 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 29 Sep 2026 19:18:11 -0400
X-ME-Sender: <xms:Mke8aiAqTOTgLpSApL6_s9igWh-kD3iFauDBGNQBfRWTgRBsJceI_g>
    <xme:Mke8anWDVRNYrQzAU-rATRyZVZJVcYHcciqwNUrLyVwlaEp0eTI9M9VMD5HgCGma2
    bFvDF8zAWF1Wfq0rtbXe6Y0VfVC0_CLDsl8URo-GlWDP3nf5S8qGNs>
X-ME-Proxy-Cause: dmFkZTGHEgLFH0UzEvHZ6BE1bA23rv7Q4vUusdzWF/kePvVj9Qnb5zjXM8d94S6+cY0yU6
    QZbRahQACsK9emsZkGOgVnBVyMjCmVal6ZlPnrrUDLEzKLPo/l2HoxZitVEysIDI7gsYz8
    6NxnUEi0w0ez2h57Ss4IQJz3BQ1Al4dKBuyavGle3Vz/vyv0EJRfgNYjnPFqbVt7d/KhD6
    lVQbV1K7Jr5/fQiym6Lx6/atSw4D0dJ8QgsDm8LgIRk61/ao5STabmyldMAXiif3h6Yo0b
    UkMSmyvoSgNkdYUYgbNtOLxai9H0gqP8ohll021PCO74CPSfIDhP+Qrk1S/AFJfmhjk5KF
    ynh05ilaGhyovaxtQi06YOqn+rNoIkwE3zt2iV0qebvF0Hsbueq5U6lIFEQRzenTBVoe8c
    9jypmZ+Sig8gyui1kqi1sEiaajWGD4wFYUoAsKnu6O1weGO3F1Zdf2g/wrxw+2IE3+XRGn
    XDT5HQACbZWeJXCVQGSRl8vjCrwszhG1uJdw+c1TtUszBYoMpTHto22BPD2OFLHfNgNCqa
    KC9C57DV9UZa3ZBaKqhwq47pa4lbeoaSUkl+NR1qO8fL84V7cbL7uTymcch+G4Rz+p7XWK
    zqOby2EcJuXMjqeRwahY62aVv0DQ6bJdsTVNXASa5YQeJ3xz1/yhxD+5gSkg
X-ME-Proxy: <xmx:Mke8anfOPJgV8dWjP8kkAhR5cP-E6uCYK862Aqfs2v47ad7WS5FwDg>
    <xmx:M0e8ak9W4eOJhVjJxFwF4q6VpcIhrKZ7i-lsNrKLZuDecpyrlSzRmg>
    <xmx:M0e8ajk1svf0Kpi3xZZ0QM8SpA6hCV3HRNsxD_SNOAtMiqLpHL9fQg>
    <xmx:M0e8am9gzxu9B_WvGhNN59L_gfnWWaMA-SqhcDaGAqDxELUwsSTMZQ>
    <xmx:M0e8ahnTFr6Ruus4sKrDMiAiSgpn4q7GAgTt3YrQriIaKizkFVuhnVHZ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E16B2780076; Tue, 29 Sep 2026 19:18:10 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A77Ixbv5qpj3
Date: Tue, 29 Sep 2026 16:17:50 -0700
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@hammerspace.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Message-Id: <d5d7635a-fe7a-4664-8797-b581c23cdf9c@app.fastmail.com>
In-Reply-To: <arwYBaemyvLoG2sT@hammerspace.com>
References: <20260929173423.16149-1-snitzer@kernel.org>
 <20260929173423.16149-2-snitzer@kernel.org>
 <37625d4e-9d86-4651-bbc8-73c1c589942d@app.fastmail.com>
 <arwYBaemyvLoG2sT@hammerspace.com>
Subject: Re: [PATCH 01/10] NFSD: interlock the use of NFSD_IO_DIRECT for NFS READ and
 WRITE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Sep 29, 2026, at 12:56 PM, Mike Snitzer wrote:
> On Tue, Sep 29, 2026 at 11:27:05AM -0700, Chuck Lever wrote:
>> 
>> On Tue, Sep 29, 2026, at 10:34 AM, Mike Snitzer wrote:
>> > Now that NFSD supports NFSD_IO_DIRECT for both READ and WRITE it is
>> > much safer to avoid needless buffered vs direct contention if/when
>> > only one of them has been configured to use NFSD_IO_DIRECT.
>> >
>> > Mixing direct and buffered I/O to the same file causes needless page
>> > cache invalidation and writeback, so although io_cache_read and
>> > io_cache_write remain separate interfaces, writing either one adjusts
>> > the other so that READ and WRITE are never left on opposite sides of
>> > the buffered/direct divide:
>> 
>> Jeff and I have been discussing making DIRECT the default for WRITEs and
>> BUFFERED the default for READs. This patch takes us in the opposite
>> direction.
>> 
>> Nothing here convinces me that mixing the modes is a bad thing to do.
>> "Needless page cache invalidation" needs some demonstration, and it
>> needs to show why the right thing to do is make it impossible to mix
>> modes rather than explore the issue as one or more bugs that can be
>> fixed. Or... why not let admins explore this for themselves? Where is
>> the hazard and why does it need to be forbidden by the admin UI?
>
> The basis for the interlock is that O_DIRECT mode is intended to avoid
> bloating memory with page cache and the excess CPU burn of managing
> the page cache.  Using read caching in conjunction with O_DIRECT
> writes knee-caps the wins of O_DIRECT.

Jeff and I have never seen that, and it's a counterintuitive result.
Buffered READ with DIRECT WRITE seems to work very well and the server
is easily capable of managing the page cache in this case, since
reclaiming a clean page doesn't mean having to flush dirty data.
Evicting clean pages is not slow.

So I'd like to see a quantification of the penalties in this mixed
mode before adjudicating it as a hazard. That is, you might be right,
but so far I've seen no direct evidence that having a substantial page
cache presence is a general deficit for WRITEs. If there are certain
cases where even caching READs is a problem, then by all means, set the
READ IO mode to DIRECT too in those cases.

I don't see this as an argument for forcing the server's mode setting
in every case.


> But sure, you can do it.. and
> I suppose the freedom of choice (and enough rope to hang) is perfectly
> fine.

"Enough rope to hang" is the usual approach for Linux tunables. I
should also point out that both of these settings are still debugfs,
not the final shape of the administrative UI. It doesn't seem sensible
to me to restrict them at this point, but I'll keep this idea in mind
as we continue to develop our thinking about what the eventual non-
debug admin UI will look like.


> I can drop the interlock and send v2 after more time for review
> of the other patches (but there were some real bugs fixed in the
> interlock patch so will require some care to adjust).

The usual policy for "real bugs" is that those need to be fixed in
separate, backport-able patches before making behavioral changes.
Stable wants the fixes, and does not want the behavior changes, so
these need to be separable.

You can send the bug fixes any time without waiting for a v2.


>> As I recall, even a direct WRITE needs a subsequent COMMIT. Have you
>> demonstrated that the client COMMIT is a latency problem or that
>> the memory that is pinned on the client has a noticeable impact?
>> 
>> We suspect that it might, but every time I've measured, avoiding
>> COMMIT with NFSD has shown no impact on throughput, which is why
>> NFSD doesn't already do this optimization.
>
> Yes, in the header for "NFSD: let a direct-mode WRITE raise stable_how
> and elide the client's COMMIT":
>
>     What this removes is the COMMIT traffic, and it is worth most where a
>     client's writes are carved into several WRITE RPCs, because each piece
>     is then committed separately.  Measured on a pNFS flexfiles share where
>     every write straddles two data servers, so every write becomes two WRITE
>     RPCs and, under NFSD_IO_DIRECT, two COMMITs: the two modes do identical
>     durability work, one fsync per COMMIT against one fsync per WRITE on
>     identical WRITE counts, and the COMMIT RPCs alone cost NFSD_IO_DIRECT
>     31% more server CPU and 42% more client CPU for the same bytes, about
>     20 us of server CPU per COMMIT plus a client cost that grows with the
>     range committed.  Where only one write in 22 is split the same effect
>     is a couple of cores on each side and no resolvable throughput
>     difference, and writes that fit a single RPC send no COMMIT in either
>     mode.

I asked about latency, above. This paragraph is about CPU utilization.

Based on this description, it seems to me the client has full visibility
of the data to be pushed back and how it's sharded, it has information
about the network RTT (that's where the real throughput impact is for
COMMIT), and it has control over the selection of UNSTABLE vs. FILE_SYNC.

The problem here might be that when a large WRITE payload is sharded
across multiple servers, the client still thinks it is sending them via
UNSTABLE WRITES to one server, and plans for only one COMMIT after the
server completes the WRITEs.

But for the pNFS scenario, the client sends one UNSTABLE WRITE followed
by a COMMIT to each server. If the sharded WRITES are all single RPCs
to distinct servers, then they should each be FILE_SYNC.

The client can be smarter about how it writes data back to multiple
servers, can't it?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
