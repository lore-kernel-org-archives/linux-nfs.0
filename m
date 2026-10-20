Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792494876;
	b=K5dHa9Yq6j8k1kEUUFEmk50wtK0gHI0FuViSgfp3mXlkBRqegBdcjFY7Vl8mSkwqmUPD
	 kE32d471o+agOzZRmVO/Zo06AqABrxHcTEQeRwEgslo4AEto77/TB9IlYXgFpaZgSoiOF
	 Mi79GPmzgnTxenERuDvkbo3jVryPrrx0VItbnU1DGxsc4RqmOevnTxeZXspCK2xtzwPzv
	 +DuR62kJoyunBzm9QuBU6vlodhKUf/BC0QpSSQ7UW1Ma4zWK+cCQXemFrAhNnWMj7c87x
	 MZtDaTO6oCs1W1tqDGmgxaWFtNpiGfHpctG4tPEUROGWYiu4mIkTCVHZovV1Up2eFjQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792494876;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=JKsYdGt0o1em4/c1djWLrMEXHxXc+G/ZYaryfCKp7Ow=;
	b=OaNkXgHRPcrfFwSr93fidTmwKkRS3fpIG5B7fpkBbRd6me1ZW+qxz4AhKOpLq+j7VYv6
	 qln8/gjw6+s5KQlziBG8491mXiaJlnMOYDibxbedCTnGR7hbgKL9oWy0xwDBuu0dzNfMt
	 LUUY+wGX7i/hualWARitY9TR+7d+sIVXO+q5izOaaE55yJ72HNtsApftPxyMIjnMMyOa9
	 Zp83nOGbF/1a3Ku/nUt/G72CFDoX/4QLps63rTqMj5Kj40M0WXtUgdP2UqiakTL3T0kEd
	 9t9Q9f1jagmnUkmtgPE/3InI61I+0TEVd7qG1AKGD83apw4p1zDYlsbAbTpTCdWNESA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LWUwsRk5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AA33606A31A;
	Tue, 20 Oct 2026 11:14:36 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=LWUwsRk5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6FF641F000C4;
	Tue, 20 Oct 2026 11:14:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792494876;
	bh=JKsYdGt0o1em4/c1djWLrMEXHxXc+G/ZYaryfCKp7Ow=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=LWUwsRk5jH7j+A1I85ToWLvESZ3mSyz4ttokTJ5a56vA2jV/9BByJ7T0LUGPvac16
	 EsJQUu/wkrPHQB1PaQD4nnouIr7MTJwxPqsAEhypgNx4lspWuklzAgJnPkJwQNHDPD
	 zv34Q9A3+7EDQhC1k3I6mYxpbYEOkXD0eiBghJY0ECAUKjRl+lUxucgs4rQdJray4A
	 PDOi56SrNu7iMEv/Hm7XvQ7XNM5eaeQysRagoMdPs8bddVpL/yIlFil5jZ7UBybNYK
	 WRDoNqiQ12UvShXfK81+gHYDQcMLkIhKvMzM+nnRmc8fmaugyBLqKszFPcD0ZHwp35
	 5cRFFNoUY655g==
Message-ID: <ca48d9deba166723a52a9287941315c964700afe.camel@kernel.org>
Subject: Re: [PATCH] NFSv4.1: Return NFS4ERR_DELAY when a referring call
 wait times out
From: Jeff Layton <jlayton@kernel.org>
To: daejun7.park@samsung.com, Trond Myklebust <trondmy@kernel.org>, Anna
 Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, Olga Kornievskaia <okorniev@redhat.com>, 
 Benjamin Coddington <ben.coddington@hammerspace.com>,
 linux-nfs@vger.kernel.org, stable@vger.kernel.org
Date: Tue, 20 Oct 2026 07:14:34 -0400
In-Reply-To: <20261020-nfs-referring-call-delay-v1-1-0be8f0608f7c@samsung.com>
References: 
	<20261020-nfs-referring-call-delay-v1-1-0be8f0608f7c@samsung.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Tue, 2026-10-20 at 14:01 +0900, Daejun Park via B4 Relay wrote:
> From: Daejun Park <daejun7.park@samsung.com>
>=20
> Commit 045d2a6d076a ("NFSv4.1: Delay callback processing when there
> are referring triples") made nfs4_callback_sequence() wait up to half
> a second for each request named in the referring call lists and answer
> NFS4ERR_DELAY if one is still outstanding, so that the server sends
> the callback again later (RFC 8881 section 2.10.6.3).
>=20
> Commit 8618289c4655 ("NFSv4: Fix a sleep in atomic context in
> nfs4_callback_sequence()") turned referring_call_exists() from bool
> into int and made the caller test for a negative value, but kept
>=20
> 	status =3D nfs4_slot_wait_on_seqid(...) < 0;
>=20
> A timeout stores 1, referring_call_exists() never returns a negative
> value, and the callback is processed as if the request had completed.
>=20
> nfsd has named the COPY in CB_OFFLOAD since commit b53a42970fa4
> ("NFSD: Record each NFSv4 call's session slot index"). "NFSD: Send
> referring calls with CB_RECALL" [1], queued for v7.4, also names the
> OPEN that granted a delegation in a recall of it, and expects
> NFS4ERR_DELAY until the client has recorded the delegation. A client
> that has not recorded it within half a second answers
> NFS4ERR_BADHANDLE instead. nfsd sends the recall once more two seconds
> later, and if that is answered the same way, it gives up: a
> conflicting open then waits until the delegation is revoked when the
> lease time has passed.
>=20
> Keep the error from nfs4_slot_wait_on_seqid(). A server that names a
> request the client has not finished with now gets NFS4ERR_DELAY until
> the client has, however long that takes, where the callback used to
> be processed after half a second. Each resend answered this way holds
> a callback thread for half a second; by default there is one callback
> thread per minor version, shared by all servers.
>=20
> With [1] on the server and a test-only sleep of five seconds before
> the client records a delegation, opening for write, on the server, a
> file that the client had just opened read-only took 90 to 92 seconds
> in five runs (lease time 90 seconds): both recalls were answered with
> NFS4ERR_BADHANDLE and the delegation was not returned. With this patch
> the client answered NFS4ERR_DELAY twice and then returned the
> delegation, and the open took 5.1 seconds in each of five runs.
>=20
> Fixes: 8618289c4655 ("NFSv4: Fix a sleep in atomic context in nfs4_callba=
ck_sequence()")
> Cc: stable@vger.kernel.org
> Link: https://lore.kernel.org/r/20260802-nfsd-deleg-destroy-badhandle-v1-=
9-323aa7196055@kernel.org # [1]
> Signed-off-by: Daejun Park <daejun7.park@samsung.com>
> ---
> The patch applies unchanged to v7.3, next-20261019 and the stable
> branches back to linux-5.10.y. Before v6.8 referring_call_exists()
> returns status itself and the caller already tests it for a negative
> value, so the change has the same effect there. [1] is queued for
> v7.4, so this would be good to have in v7.4 too.
>=20
> Tested in QEMU guests with Chuck's nfsd-testing b4e06bef3884 (based on
> v7.3-rc6, contains [1]) as client and server kernel; its NFS client
> callback, session and OPEN code is the same as in v7.3. KASAN and
> lockdep on, NFSv4.2, the export on XFS, nfsv4leasetime 90. The
> test-only sleep is a module parameter that makes
> nfs4_process_delegation() sleep before it records the delegation,
> while the OPEN still holds its slot. It is not part of this patch.
> Without the sleep the recall was answered at once with and without
> this patch (five runs each), and three async COPYs of 64 MiB completed
> with CB_OFFLOAD answered NFS4_OK in both.
> ---
>  fs/nfs/callback_proc.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
> index 3fb10c8e42..f4ccfa50a0 100644
> --- a/fs/nfs/callback_proc.c
> +++ b/fs/nfs/callback_proc.c
> @@ -489,7 +489,7 @@ static int referring_call_exists(struct nfs_client *c=
lp,
>  			ref =3D &rclist->rcl_refcalls[j];
>  			spin_unlock(lock);
>  			status =3D nfs4_slot_wait_on_seqid(tbl, ref->rc_slotid,
> -					ref->rc_sequenceid, HZ >> 1) < 0;
> +					ref->rc_sequenceid, HZ >> 1);
>  			spin_lock(lock);
>  			if (status)
>  				goto out;
>=20
> ---
> base-commit: c03c1a14507dfaf8b856c2608f9ac216021fc222
> change-id: 20261020-nfs-referring-call-delay-6376146da036
>=20
> Best regards,

Nice catch.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
