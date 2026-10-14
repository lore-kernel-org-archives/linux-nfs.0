Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6D6584F85C0;
	Wed, 14 Oct 2026 11:06:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791976008; cv=none; b=I+yZ8M4nbDkTOjGjCW01P2xmqqQ7g5nao1pHgtXsvDvs+exhPI0euf+jd06lowXvW7Ac6uZZMih76ukm0VsY+2OqjYWUzjOTS+vtV5XuqWZpBEJlH7bKrpB1DPyyVmhNcwMffHAnKYyHV+pos48Dvms1WvVolgZqqSo1+dV39mg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791976008; c=relaxed/simple;
	bh=cveKd6utIgrb+XTdlcv1LbUdWOZ8L+hkWeDCe9rFzSA=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=HhOhUYmNP8WmV1zHelPOyRa+KmpwHAOAzKg6UG3ijtOVV7KXZjUMq4pW6it9UpuY+RIOytvag8ccFz53xHMHIZlozhaW25chOxoi08QutvckSQ25NwFnyN3j2vmV9218yfp0EelwBBrcWOOZED1HzfwkpiMGg5cUmSJ/1/XKH0s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=fudU6f2G; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="fudU6f2G"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D37631F00893;
	Wed, 14 Oct 2026 11:06:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791976002;
	bh=SbnxO2zfcVMp/eis9EADsLfcP4WozFhv0XRLEaNlAs0=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=fudU6f2GY/0009ztfQ5XhPrFUVO25Tjr0lVVpxDMfUsORW4jjbXh6MttqQ1T2b9uF
	 94GRwbXhKFrVv69eppQmMcnetEtkHhnxNTcZz6bg+kd+Q6d7o2UxgH6lquZsHatKG+
	 mJN8QDfF8IjZrNx9PEo9nOplkcnKTlWC7G+DGm6Lyl49Lo6SjpUgIxdSb4i6H1RsgG
	 bj/Fjx5FbOBsX8wBC2V5hemGDEna44ZQ7IhYYWxGtmcfKiku3RUmCUr8I2szI7pZPz
	 UgMrRILsk1eK5U+MRvq+4f+jeV328/mr4i1tJQD+qmaKcDjEU1AxnKUbCayPGkOHDn
	 gAIyJTB/nLYNg==
Message-ID: <4616c5cefcad5ff4dd660f9db69a9962fddd28ef.camel@kernel.org>
Subject: Re: [PATCH v2 5/7] nfsd: keep polling a layout recall answered with
 NFS4ERR_OLD_STATEID
From: Jeff Layton <jlayton@kernel.org>
To: daejun7.park@samsung.com, Chuck Lever <cel@kernel.org>, NeilBrown
	 <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	 <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, Benjamin Coddington
 <bcodding@redhat.com>,  Trond Myklebust <trondmy@kernel.org>, Anna
 Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Date: Wed, 14 Oct 2026 07:06:40 -0400
In-Reply-To: <20261014-nfsd-layout-recall-v2-5-764462bddfd1@samsung.com>
References: <20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
	 <20261014-nfsd-layout-recall-v2-5-764462bddfd1@samsung.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-10-14 at 16:30 +0900, Daejun Park via B4 Relay wrote:
> From: Daejun Park <daejun7.park@samsung.com>
>=20
> When a client answers CB_LAYOUTRECALL with NFS4_OK and still holds
> layouts, nfsd4_cb_layout_done() sends the callback again after 10 ms to
> see if the client is done. The repeat carries the stateid of the first
> callback, although RFC 8881 section 12.5.3 has the server increment the
> seqid in each CB_LAYOUTRECALL request.
>=20
> The same section makes the seqid of a processed CB_LAYOUTRECALL the
> current seqid of the client. Since commit dce72920c81b ("NFSv4.1: if
> referring calls are complete, trust the stateid argument"), which is in
> v6.8, the Linux client answers a recall whose seqid is not newer than
> its own with NFS4ERR_OLD_STATEID, unless a LAYOUTRETURN is on the wire
> (NFS4ERR_DELAY) or the layouts are gone (NFS4ERR_NOMATCHING_LAYOUT).
> Before that commit it answered a repeat of the recall it was working
> on with NFS4_OK until its LAYOUTRETURN was prepared, and with
> NFS4ERR_OLD_STATEID from then until nfsd had processed the LAYOUTRETURN
> (read from the code, not run). So a client from v6.8 on that needs
> more than 10 ms to finish its I/O and to send LAYOUTRETURN answers the
> second callback with NFS4ERR_OLD_STATEID, and an older client can
> answer a later one that way.
>=20

What eventually breaks this cycle? The client has a newer layout, so it
returns NFS4ERR_OLD_STATEID to the CB_LAYOUTRECALL, and now the server
is going to continually retransmit that request. What makes the server
eventually give up?

Or am I misunderstanding what causes this?

> nfsd4_cb_layout_done() takes that as a failed recall. With the block
> layout it logs "client ... failed to respond to layout recall.
> Fencing.." and runs /sbin/nfsd-recall-failed, with the SCSI layout it
> fences the client with a persistent reservation preempt, and in both
> cases nfsd4_cb_layout_release() drops the layouts. Section 12.5.5
> requires the server to wait one lease period after a recall before it
> takes further action. Here the client is still using the layout: its
> I/O can be in flight when the conflicting operation goes on, and what
> it has written to newly allocated blocks stays unwritten on the server,
> because the layout is gone when the client wants to commit it.
>=20
> Clients doing O_DIRECT I/O in 1 MiB requests on one file for 30 seconds,
> block layout on XFS. "after" is this patch with "nfsd: make the time
> limit of a layout recall work", on nfsd-testing 32eb1a60b456.
>=20
> Recalls that ended in the failure path, out of the recalls sent:
>=20
>                                                    before      after
>   2 clients read (different halves of the file)    7 / 9       0 / 9
>   2 clients write                                  8 / 9       0 / 9
>   3 clients write                                  19 / 20     0 / 20
>   2 clients write, the server writes 4 KiB to
>   the file every 50 ms                             216 / 229   0 / 250
>=20
> Blocks that read back as zeroes on the server, out of the 1 MiB blocks
> that the clients wrote to a new file with O_DIRECT, followed by one
> successful fsync():
>=20
>                                                    before      after
>   2 clients write                                  6 / 564     0 / 481
>   3 clients write                                  11 / 527    0 / 569
>   1 client writes, the server sets the file size
>   every second                                     21 / 469    0 / 504
>   2 clients write, file preallocated               8 / 601     0 / 602
>   1 client writes, 1 client reads                  4 / 493     0 / 508
>=20
> One client writing through a block layout whose path to the device is
> cut for 15 seconds while it can still talk to the server, and a 4 KiB
> write to the file on the server:
>=20
>                                                    before      after
>   the write on the server takes                    0.05 s      15.6 s
>   the recall                                       fails       completes
>   /sbin/nfsd-recall-failed is run                  yes         no
>=20
> Before, the write of the client that was in flight when the layout was
> recalled was stuck for 18.5 seconds and no WRITE was sent to the
> server, so it reached the device about 15 seconds after the write on
> the server had returned. After, the write on the server waits for it.
>=20
> Two clients writing one file with the SCSI layout on an nvmet-tcp
> namespace: before, both recalls sent ended in nfsd4_scsi_fence_client(),
> the number of registrants on the namespace went from 4 to 2, and both
> clients logged reservation conflicts and did the rest of the run
> through the server. The same with a new file, after a fresh boot: both
> clients were fenced, and one of the 630 blocks they had written read
> back as zeroes. After, no client is fenced and no block is lost.
>=20
> Handle NFS4ERR_OLD_STATEID like NFS4ERR_DELAY: the client has seen the
> recall, so keep polling until the layouts are returned or the time limit
> is reached. Apply this only together with three earlier patches in this
> series: the limit only works with "nfsd: make the time limit of a
> layout recall work", with "nfsd: run the fence script when a block
> layout lease break times out" a block layout client is fenced when the
> lease break gives up, and "nfsd: answer NFS4ERR_DELAY instead of
> waiting for a layout recall" keeps nfsd threads out of the longer wait.
> Kernels before v7.1 do not have the lease break timeout that the second
> of them fixes. There, an operation on the server that does not come
> from nfsd, and an nfsd thread that still ends up in the filesystem's
> break, waits until the recall ends, for at most two lease periods. Such
> a kernel already waits that way, without a limit, for a client that
> keeps answering NFS4ERR_DELAY, and RFC 8881 section 12.5.5 asks the
> server to wait at least one lease period before it fences.
>=20
> The poll sends the callback every 10 ms for as long as the client
> holds the layout, as it already does for a client that answers
> NFS4ERR_DELAY. With a client that needs long to return the layout
> that is about 100 callbacks a second, for up to two lease periods.
>=20
> A client can also answer this way without having processed the recall,
> when a LAYOUTRETURN that left layouts behind has moved its seqid past
> the seqid of the recall. With this patch alone it is then polled until
> the time limit and fenced, where it used to be fenced at once, and
> LAYOUTGETs for the file fail with NFS4ERR_RECALLCONFLICT meanwhile;
> "nfsd: poll a layout recall with a new seqid when the client is past
> it", later in this series, gives such a client a new seqid.
>=20
> This keeps the poll as it is for a client that has answered NFS4_OK.
> Sending each repeat with a new seqid, or ending the callback on NFS4_OK
> and letting the LAYOUTRETURN finish the recall, would follow the RFC;
> both are larger changes than a fix for stable kernels should be.
>=20
> Fixes: 6b9b21073d3b ("nfsd: give up on CB_LAYOUTRECALLs after two lease p=
eriods")
> Signed-off-by: Daejun Park <daejun7.park@samsung.com>
> ---
>  fs/nfsd/nfs4layouts.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
>=20
> diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
> index 8bcf4d5380..5692d0aee7 100644
> --- a/fs/nfsd/nfs4layouts.c
> +++ b/fs/nfsd/nfs4layouts.c
> @@ -863,7 +863,15 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, stru=
ct rpc_task *task)
>  	switch (task->tk_status) {
>  	case 0:
>  	case -NFS4ERR_DELAY:
> +	case -NFS4ERR_OLD_STATEID:
>  		/*
> +		 * RFC 8881 section 12.5.3 wants a new seqid in each
> +		 * CB_LAYOUTRECALL request. The poll below sends the request
> +		 * again with the seqid of the first one. A client that has
> +		 * processed that one is at its seqid or past it, and the
> +		 * Linux client answers the repeat with NFS4ERR_OLD_STATEID
> +		 * while it is returning the layouts.
> +		 *
>  		 * Anything left? If not, then call it done. Note that we don't
>  		 * take the spinlock since this is an optimization and nothing
>  		 * should get added until the cb counter goes to zero.

--=20
Jeff Layton <jlayton@kernel.org>
