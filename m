Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793581202;
	b=JNIVF5wjKo6THgetTSCFv8xU2FW5WNlfnkTIIDHNXtupYaaX4LrrIcl0eAtl/oN4rdwe
	 AEapuLIBkM/jwt7Gq3YGEE0s3Trvl38N+K2/tPbmh05DU2lfuVLfuft5NEQObQ9VhztX1
	 ule9rM/+wne6SBl6e12dYvLxwIaE09wPDeuhuFxOHd34hwQDS1hHhMnol8ipg6XXy1zi7
	 sSe88I1xTqLOs+QqP2Li1HcCfVhq7I/WOkzyPcgJRHNCdKp7W1sf3+r6d41Sb4cmYGN8j
	 e+R3Km2LK5UvfvSnscfPn2V6LoBrW6nD009FWpFZrT+vccHOV7T21ypZLfiU4TBlwmQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793581202;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type:Content-Transfer-Encoding;
	bh=Hjkc+obzyLKi6m990tloWP/wzVdvqnjoeAb9+EaVM5k=;
	b=bdwu9j5ei4nzhRcMYnIuYpEqf44Kx3fvEeW5fy9fzjaK8sELkyxlTZ+B0YthgHbkbCJD
	 CSR7phTJZGtC45FrM6jyU//LP4HtSRAE+g45Sogyr5+c9653FcnYiG0LmBC/tOfaWOCJg
	 c/z4Cq/fKdiESJHFXZE6BkhAencS3/Ij3pKgT+4DXS8Wgk+7SPbSUnCZCBgVCNAhvKr5c
	 cUO16cRav53YHa20b/7FNHfBU9vbyVUxaH+6SK9DY67yt46tchQuTf07hRYIt20YeyJ7P
	 8Cd0NdQfrs62cZcVJl54vpC65TsGW2BedET7fKB3NjHdETX6fm/9icYuwGOlxVglDcw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZApzT3Ox;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A74FA606A324
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 01:00:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ZApzT3Ox
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1DAF61F0093A
	for <linux-nfs@vger.kernel.org>; Mon,  2 Nov 2026 01:00:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793581201;
	bh=Hjkc+obzyLKi6m990tloWP/wzVdvqnjoeAb9+EaVM5k=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=ZApzT3OxTGdumT2RTS7fm6mdApRvqmj6qubqLev8GrvVuwJrhstCtZU7InQypB2cZ
	 wcUf7twgKdy7eldenN0bTUnUmAN4/Uu+gcJaKK0iQu5JcmTFSDUT/q6CsaUbjokW0n
	 AYNwpe/4ua7zOr4yklpnq5vjLoZE1wg9uav4iI4IB07nHyVYRXfK2c35M1SjAPDrQd
	 pPlv6yQihZkDWwhSQrtXWeKV2UNHoo8VLfexC98f48II6B3ypFhmwmn71kYHanIBaw
	 XyFHlqi5w535a+EPfBg/P0oq960BhCAMx2bYflKm1jqQUSSGY6MGi2AeAtoKkdbntZ
	 UcR9emxB+gE1w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A7D0BF40067;
	Sun,  1 Nov 2026 19:59:59 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 01 Nov 2026 19:59:59 -0500
X-ME-Sender: <xms:j-DnamLepvFB3JtYUbIjxnZi5QjKd2OHj0mmZ1ChcM6E_OJLV7dcKg>
    <xme:j-Dnao-Pv6kyQF6Yx9N9T7T7_cbsfrJTmKdozotxPQaaaM7sQcgwV8MsbW1x7HjGq
    swEYmDbgZ6DwtiHtGk5a1Zhj3XrgZv02q15WI1n7-OAyJP3cUYApPU>
X-ME-Proxy-Cause: dmFkZTEY6fq6S0qREoNd7bK0BgPQaUEbGlgAmUAaJj9OqOXgaDelLGjsHbNQEFztKwV94o
    D6h5tHNahy8j5qWRGfZwjG9yVrb1VO+Y++ZouLTeKxtUMXren/UciUQWQI4DtMfLeLIRGg
    nDd25uggMKOoaxzScrSkDBRWatDYwONh8xIqVEZuDnVWDoGGpQ3RQGio/i/aILTn1Q5qnn
    kpqg9tGcTn6MGwfnA2uyvDbPC3FVbOJnhNTOr3kt9k/JsHe3/GvI3gaeiPE3TF0cd+ETBp
    ApR+Gfax/P25jkw4lQJt2Xar+nddXeNcv6lOSa90p1TWCkoPVMMpy34gq7p4XHcmBDQvNV
    uALNffogNNsYsHOCsWoy3u2fTw66Rnxzss5MrCFYBvfaUHgoeLfc1oWCQCXkZprZpMZz2I
    HOn5odoV0M7RXWM+8txWfYwZro66QTmB+mlGCIMwLtKRhpOLtEo3XK6wJo7nAaIptX9V8F
    Kol9PHKEqQ4lPXbqSqWOkmzfsmBwji2cKK0/tgxH2GAN7LGDsh2RqFT+wZsmpdICShIWob
    nx6Pf1Qgxs5wpPK9MsfM4uAiqK/Qu7/pHsZVo0EIcPFCY75dwErirSsfvR9YNC1px7sk5T
    Hq7gIssdXbr2ODwtU0bZttncCsodm48sNWvlIbUwt4DLPzULTBjnzoeFxr3Q
X-ME-Proxy: <xmx:j-Dnal0mUpsvX6ldnVgdDCmPrG6IjVSCcwk_w7PPm6zYn0thburITg>
    <xmx:j-DnalZTG9ic4k0S-96LChiG3WnI36BOV4Tck8P5Xv94sSSSoSQt7w>
    <xmx:j-DnatKOP159NFTgkYLqhBgNd7XZXHAsysRz8qIWqiAmg6srks4u9g>
    <xmx:j-DnakGaKJCfNvcTi7afSzTwsca2-ypWxotBn6KWUT1-RB_6pxlJIw>
    <xmx:j-DnakuK1HsHJ0cjraSPX4rJZOxvIE84VP_7ks41RvU22we-ST7TridZ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 7D8C8782738; Sun,  1 Nov 2026 19:59:59 -0500 (EST)
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
Date: Sun, 01 Nov 2026 19:59:39 -0500
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Message-Id: <d80b6f2b-22c8-4848-99dc-787ef8bbd88a@slotpi15m67>
In-Reply-To: <179356854478.547122.8943689348477321562@noble.neil.brown.name>
References: <20261101154742.1950822-1-cel@kernel.org>
 <179356854478.547122.8943689348477321562@noble.neil.brown.name>
Subject: Re: [PATCH v1] NFSD: Do not regrow a slot in the SEQUENCE that retired it
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Mon, 02 Nov 2026, NeilBrown wrote:
> How would a client have a slot outstanding if it has acknowledged the
> smaller slot table?

It had none when it encoded the acknowledgement. The client fills in
sa_highest_slotid when it builds the request, from the slots in use
at that moment. The request on the higher slot is sent afterward, and
the two are in flight together. RFC 8881 Section 2.10.6.1 warns about
exactly this ordering: "the request may have been sent from the
requester before the update was received".

The trace I have is from a TLA+ model of the slot table, and pynfs
then reproduced it against a live NFSD. The target has been lowered
to 1 and an earlier request on slot 0 has stamped the new generation.
The client builds a request on slot 0 while slot 0 is its only slot
in use, so sa_highest_slotid is 0, then sends a request on slot 1
with the slot's current seqid. The nfsd threads handle the slot 1
request first and cache its reply. The connection drops and that
reply is lost. The slot 0 request then arrives. Slot 1 is no longer
INUSE, the generation matches, sa_highest_slotid is 0, so NFSD frees
slot 1. Slot 0 is now the top slot, so the same call allocates slot 1
again, with the retained seqid and NFSD4_SLOT_REUSED but without
NFSD4_SLOT_INITIALIZED or the cached reply.

The client reconnects and retransmits the slot 1 request with the
same seqid. check_slot_seqid() reports a replay, the slot is not
initialized, and NFSD returns SEQ_MISORDERED. The Linux client takes
the out_retry path in nfs41_sequence_process() and resends the same
seqid after NFS4_POLL_RETRY_MAX, with no limit. If the lost request
was the first on the slot, its seqid 1 passes the REUSED rule instead
and NFSD executes the compound a second time. pynfs shows both
outcomes with a two-slot session: a CREATE on slot 1 whose reply the
script discards, the table shrink, two requests on slot 0 with
sa_highest_slotid 0, then the CREATE sent again on slot 1. At seqid 1
the second CREATE returns NFS4ERR_EXIST. At seqid 2 every retransmit
gets SEQ_MISORDERED.

"Outstanding" in the description was my word for a request whose
reply the client has not seen. I'll fix that in v2.

With the growth block skipped, slot 1 stays retired until a later
request on the top live slot grows the table. The retransmit that
arrives before then gets BADSLOT, which the Linux client handles as a
session reset. That is not free, but it ends.

A copy delayed past that later request still meets a rebuilt slot, as
the last paragraph of the description admits. Closing that window
takes more than this patch, though.


> This comment could probably be improved.  As we don't (now) rebuild a
> slot in the call that retires it, "A slot rebuilt in the call that
> retires it" does not exist, so is not of interest...

Agreed. I=E2=80=99ll clean this up for v2.


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
