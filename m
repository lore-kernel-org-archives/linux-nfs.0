Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793115690;
	b=vAGgbfwNv2gTvHfkAvvEzsPNaoD54uV2EgJ6IrGSqS131K3mR1uJl90z5s3PqS74HiZa
	 Q8raIhj/01CYI7Dc3HiLz0FNYUHdyAG5QeBs5ng6IbbtWGl/fCAtb2AmYmN62W7AZF9tH
	 4ClG4Ljc2dzydJa3qTwm2A3n88D+M1P6gmQEdVLfRJW6YdECg+3GlcjtVLLiw3pmfrfo7
	 6PKmeGO/qDZqxkMy3PoBTpR8UPvroG22Nkw1UOdzbLemBq6V5ObTrZfYLG+nEp/iZiZYo
	 oG+tltlWYF8Ih0CZPNVDIObaqI70ihxrqWaAPscBgsf8jGzsMw4WmP5S4EgzL+V5N/A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793115690;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=Ag0ghHEewxIOhXRku5slk0/T3YltAZ8n4kNBd3rHwoM=;
	b=jELk7xtqixiSgcb/CF8aKvu/Pq14Tp7v7Y/NhJ8UnLSr3DaEpsn+SzT5y8uZfIoVWE0X
	 ubY9FvWfj8EL1EE8vShQ9xQfkNC8Lng2n3y800fpTQo1vG0VX61ahubN9xy396ZxLrVC0
	 EpRdJM+D4VwROFgIOXpukYxcXyZZlyss/A/jvvpliExUk7X41MBoW7HEpLpPQ0Dcq2ym9
	 Z28KOMYqIR7humGVD3bOre8jn2Rt7eUDWu9/DpPKaf4PRDZonn6t5I2hNnzZVk/ih6cTb
	 dD1l1112FgX5I5uTpBR0tR18RIKEjxEeaVemyel4GzkSaVFVD1Fue8OKwYamLx3YYfQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ldzm1JZd;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 505E9606A31D
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 15:41:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ldzm1JZd
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D469D1F01828;
	Tue, 27 Oct 2026 15:41:29 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793115690;
	bh=Ag0ghHEewxIOhXRku5slk0/T3YltAZ8n4kNBd3rHwoM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=ldzm1JZdI5v6KexczdTPQlKgksYySr5d60AomYkxIlrhFy6QCQuUQKHXS8W+61zSW
	 97fm0WI8+M51A85SJeE+GFkPbigjDUO61RpYpk3gwUTmHb6Bag7OSs212tMAPUYVci
	 gCs/BuQ0wuSgvKBbrE0KeOJb1K3csNpEaVxB4kiXs/yITV5Vl8Jj1UUMLuLZZPkhSM
	 dZHCWtb/18fQ6h/pCD11BskaM6QiIDWYRPkOKCMaK7rIb8J2GSoKAAGjgthm6i/jur
	 CnrYEIoEwSFQZlBxTvol/J5uPz9I+KwXySQv4SdZcVqRLNYdhnugx5pGlboratKj06
	 vkFO9aw9GX6dg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 40B03F4006A;
	Tue, 27 Oct 2026 11:41:29 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 27 Oct 2026 11:41:29 -0400
X-ME-Sender: <xms:KcbgagZrYrC9TlPrLkNe9mSMeYf3gMFO8e-ROicFaa_Kemsynb-WZQ>
    <xme:KcbgamPJJT-esQBQgKSAzFUzADOQC01wBIMMDtYwJTB-30qLYpY-I2dmUI4ysWF-8
    opwKvYEKNKdupHC4BCiMJDehjLnXFAFy40O2eGyyuoybAnCZ44h-Amp>
X-ME-Proxy-Cause: dmFkZTEcEhOPJJZepPGARJ6mYcQm6nzIyqxydvSUFgkyUtXHeD0iolO9k11Yl+CnM0yr7W
    l5fX9unwUztnvV9rJ62ZXKLQnfv1ZwWL3nBxo/zvahBNW/sJag3Qk2Mi3FpxzSb9c6zYC9
    ipXwNeim8dn5+DzwhEVXJpZi9cvkLK/qOQV3hxfTTCjLjfPJvw/Wg4VQLLeZDY1FISBIvo
    NZ74B1ihgQL2SZIflIWRlSohcIK7LSaNdRmpBnjqDp3LUiw8uklGOJ1gFXkUEUUPsEx08Y
    hcvJ4F7ORIaQNKiCC/bZT1RY91Nfc9oP7qGVZsSh5BNJ/SYg02bZ1k5QmczXOyeMubEAlR
    MyoHfNyfaoL6fEk59N9IJGIKMwpt22wlpopvldogKtja8h3oYAHzxSMiQje2GzcQJf7uqI
    T5+XaI5O0md9O7oJ2s066HsuVpTAmRsKXRbmEHplzReLIiokVVXLLsYADUFzE5IoRenQZS
    XbIDt4VHbJXBXdr4qmk2WSR+h0+Aa52Ub58jVk0amCGu8U6Vp2IDLy2OAI2eZ5vweP0gIJ
    ikKW0WoDOAvSVZtW0ruZDdlYQGUoXQtL2sHt25QNkMMv8mN+U9g3jrtObH7E2cYW7VZwg+
    XwezNkfAuIGfDX6UqL3tyAi946plK5ePq3R+80+cyjJHBAOFXZceH2KCFqiQ
X-ME-Proxy: <xmx:KcbgaiSlgBlt3oyTLBz9f6cmNOCEFRaqeSQiMwGJVFklBq0ikefPBQ>
    <xmx:KcbgaocWBHQIXNV7chN5aFnnBGgHXqanwCzX5uR-4m8wAYbv_h4Qfw>
    <xmx:KcbgauC1IzCDf4h8B3E-eexS-OYGerTCu0BKrnmKdCZZrW7lFyEGjw>
    <xmx:KcbgaikQadEOKMQRe13TeaLBiCW4BxLMtbdhq73RME_VBfsT_Lqz5g>
    <xmx:KcbgahcT53VfZVhX8FFDgpyLBhv1hrqvuz0OVKJRHxOiIzskDwQ7V4T1>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 1E60C782738; Tue, 27 Oct 2026 11:41:29 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AqDuBGFLn2G-
Date: Tue, 27 Oct 2026 11:41:08 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Adolph Zeng" <coderzeng@gmail.com>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <11396b5a-249c-4710-9a1f-c078fc50e9ab@app.fastmail.com>
In-Reply-To: 
 <IA1PR12MB662781C8C09627A5CDEBF39DF4602@IA1PR12MB6627.namprd12.prod.outlook.com>
References: 
 <SY9P300MB153090355AAD017CD7216634A6602@SY9P300MB1530.AUSP300.PROD.OUTLOOK.COM>
 <IA1PR12MB662781C8C09627A5CDEBF39DF4602@IA1PR12MB6627.namprd12.prod.outlook.com>
Subject: Re: [PATCH] nfsd: prevent SAVEFH from bypassing export security
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Tue, Oct 27, 2026, at 8:44 AM, Adolph Zeng wrote:
> An AUTH_SYS NFSv4 client can read or write a file on a sec=3Dkrb5p
> export using another client's valid OPEN stateid by inserting
> SAVEFH between PUTFH and READ or WRITE.
>
> PUTFH resolves the handle with NFSD_MAY_BYPASS_GSS, expecting
> a later security check. SAVEFH carries OP_HANDLES_WRONGSEC even though
> it only saves the handle, so PUTFH skips NFS4ERR_WRONGSEC. Stateid I/O
> can then reuse a cached nfsd_file.
>
> The original report exported /srv/nfs-sec to * with these options:
>
>   rw,sync,no_subtree_check,fsid=3D0,sec=3Dkrb5p,secure,root_squash
>
> The 0600, nobody:nogroup file /srv/nfs-sec/secret.txt held 32 random
> bytes. A Kerberos privacy NFSv4.0 client ran SETCLIENTID, OPEN and
> OPEN_CONFIRM, then kept its read/write stateid live. A separate
> AUTH_SYS client used UID/GID 65534 and a reserved source port.
>
> The AUTH_SYS client enumerated a bounded range of nearby clientid
> counters, stateid numbers and seqids to find the live OPEN stateid.
> With it, PUTFH, READ returned NFS4ERR_WRONGSEC, while PUTFH, SAVEFH,
> READ returned the file data and PUTFH, SAVEFH, WRITE changed it. The
> Kerberos client subsequently read the changed contents.
>
> SAVEFH leaves CURRENT_FH in place. When deciding whether PUTFH must
> report NFS4ERR_WRONGSEC, look past SAVEFH to the first operation that
> uses or replaces CURRENT_FH. If another PUTFH replaces it, leave the
> earlier PUTFH unchecked, as required by RFC 8881 Section 2.6.3.1.1.
>
> Local COPY and CLONE consume SAVED_FH as the source. Check the
> saved export with check_nfsd_access() before using its stateid:
> a cached open stateid can otherwise bypass the sec=3D policy. Map
> NFS4ERR_WRONGSEC to NFS4ERR_ACCESS at COPY or CLONE, since neither
> operation permits NFS4ERR_WRONGSEC. The check also applies when
> SECINFO_NO_NAME or RESTOREFH intervenes. LINK and RENAME already
> check their saved handle in their own paths.
>
> An inter-server COPY carries a foreign SAVED_FH. The source server
> validates it; the destination must not apply its own export policy
> to that handle. The destination PUTFH still checks its local export.
>
> KASAN guests reproduced the NFSv4.0 and local NFSv4.2 bypasses on
> d135ab453a74. With this patch, direct READ and SAVEFH READ/WRITE
> returned NFS4ERR_WRONGSEC. Local COPY/CLONE with a protected saved
> source returned NFS4ERR_ACCESS; foreign-handle inter-server COPY
> completed.
>
> Fixes: 68d93184352f ("nfsd4: fix wrongsec handling for PUTFH + op case=
s")
> Assisted-by: LLM
> Signed-off-by: Zeng Adolph <coderzeng@hotmail.com>
> ---
> Testing: two x86_64 guests covered the original NFSv4.0 report,
> six SAVEFH security boundaries, NFSv4.2 local COPY/CLONE, and a
> foreign-handle inter-server COPY. W=3D1 nfs4proc.o built with
> CONFIG_NFSD_V4_2_INTER_SSC enabled and disabled. The ASan/UBSan
> decision harness passed 262 cases. The KASAN guest reported no
> KASAN, Oops, or NFSD warnings.
>
>  fs/nfsd/nfs4proc.c | 36 +++++++++++++++++++-----------------
>  1 file changed, 19 insertions(+), 17 deletions(-)
>
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index a50f9dcb3..25fb7fb61 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1491,6 +1491,11 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struc=
t=20
> nfsd4_compound_state *cstate,
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (!cstate->save_fh.fh_=
dentry)
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82return nfserr_nofilehandle;
>
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82/* A cached open stateid=
 does not authorize the saved source export. */
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82status =3D check_nfsd_ac=
cess(cstate->save_fh.fh_export, rqstp);
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (status)
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82return nfserr_acces;
> +
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82status =3D nfs4_preproce=
ss_stateid_op(rqstp, cstate, &cstate->save_fh,
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82    src_stateid, RD_STAT=
E, src, NULL);
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (status)
> @@ -3237,32 +3242,29 @@ static bool need_wrongsec_check(struct svc_rqs=
t *rqstp)
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82struct nfsd4_compoundres=
 *resp =3D rqstp->rq_resp;
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82struct nfsd4_compoundarg=
s *argp =3D rqstp->rq_argp;
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82struct nfsd4_op *this =3D=
 &argp->ops[resp->opcnt - 1];
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82struct nfsd4_op *next =3D=
 &argp->ops[resp->opcnt];
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82struct nfsd4_op *next;
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82const struct nfsd4_opera=
tion *thisd =3D OPDESC(this);
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82const struct nfsd4_opera=
tion *nextd;
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82unsigned int i;
>
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82/*
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * Most ops check wronse=
c on our own; only the putfh-like ops
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * have special rules.
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 */
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (!(thisd->op_flags & =
OP_IS_PUTFH_LIKE))
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82return false;
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82/*
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * rfc 5661 2.6.3.1.1.6:=
 don't bother erroring out a
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * put-filehandle operat=
ion if we're not going to use the
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * result:
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 */
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (argp->opcnt =3D=3D r=
esp->opcnt)
> +
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82/* SAVEFH does not consu=
me the current filehandle. */
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82for (i =3D resp->opcnt; =
i < argp->opcnt; i++) {
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82next =3D &argp->ops[i];
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82if (next->opnum !=3D OP_SAVEFH)
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82break;
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82}
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (i =3D=3D argp->opcnt)
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82return false;
> +
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82next =3D &argp->ops[i];
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (next->opnum =3D=3D O=
P_ILLEGAL)
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82return false;
>  =E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82nextd =3D OPDESC(next);
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82/*
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * Rest of 2.6.3.1.1: ce=
rtain operations will return WRONGSEC
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * errors themselves as =
necessary; others should check for them
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * now:
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 */
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82return !(nextd->op_flags=
 & OP_HANDLES_WRONGSEC);
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82return !(nextd->op_flags=
 &
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82  (OP_HANDLES_WRONGSEC | OP_IS_PUTFH_LIKE)=
);
>  }
>
>  #ifdef CONFIG_NFSD_V4_2_INTER_SSC
> --
> 2.43.0

My concern with this fix is that it addresses the issue for READ
and WRITE, but not for COPY/CLONE, which can involve a foreign
filehandle which fails the server's local security policy checks.

I'm interested to hear especially from Neil, who was working in
this area a while ago.


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
