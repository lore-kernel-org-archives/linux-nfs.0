Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.157
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793568553;
	b=fYVnYZ/hzukglammdSSwYmzb/aiZleKPV26rNQeAFulFV/3XPHA6TFPjUfTw35+Xg2SW
	 UO1ul6ppS2DGHDFPWnBjppzWYi0HgmdVipH/2Y0OeODmRKsA6kF0oZ4B81S+VwlCtItpe
	 4JnKs4GD+4sWldNjA2W4dXuyyL5lgyIcVRAaqlA0IR02SLJJajV6li/uyRbtLWkB9YNb6
	 o3uKic6O2utLVEPEbzVKurjMIq+3u3/nhY3eqU+HXxQZkm97B9WaG1Amr2hLKaeYWzEGs
	 qZDaoDTv0s0Fju9oiLfJ7IyXTQIVK51lyj27bYskcPMkFhWqTxzkliVIwzIp3GiBypw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793568553;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=4+Rkx3GQ7I6uDgxqLvKaPyUNc7ouJHNyu5UM0/cW7VE=;
	b=ZloQR+TegMpDE8BC2n6E4V25TAq6zwDYfQdOTsbAY3Zsj8vEAArXw9HJMf9ADPXZDhuH
	 XUUmqdDK4DE+n5RqXYmkqj5RAoBzq8hStYE9J2nPImaOJMG4cftni028e6FwwHAnt4W/+
	 2mvYejLxasZ6gmOTm33kGkSH0WYu3cGTKKBheojhx/y7mriAoXKhuBJef2zebMwiGfWxA
	 pcbBi2hp9bKs9c2W2YcXHNB/1wz7BCA+abkeWDriUtfPkWg40POUjtNg61WtciZnITSum
	 Y5pO3prX6PjIOIoSrO9WDBLc9QKy4CO6/J2Ac22hJC8B4Db/UAZEMLN37/KdmMimalw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=a1x2oBed;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=OTU05T+k;
	arc=none smtp.remote-ip=103.168.172.157
Received: from fhigh-a6-smtp.messagingengine.com (fhigh-a6-smtp.messagingengine.com [103.168.172.157])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 507D1606A324
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2026 21:29:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 507D1606A324
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=a1x2oBed;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=OTU05T+k
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 80C7C1400172
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2026 16:29:11 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Sun, 01 Nov 2026 16:29:11 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1793568551; x=1793654951; bh=4+Rkx3GQ7I6uDgxqLvKaPyUNc7ouJHNyu5U
	M0/cW7VE=; b=a1x2oBedTa5gOlHf9M2uHi9tX/JVIMqOeVHUGHv28j69tcVKB5g
	m+QdU9CDlK45s+GQB2NgSx4p9s2kI4/Aq7zmNU8p/P+7q9hLW9MyqymMpyjki4sx
	h/MbZf2mZ8XLk4s3EDJigI6DmJAig3uu8H3IGadm9dU2JVF9SckztKPSUQUiEVeE
	+3BvsCkKZipTxCxrtR4c7vpv2Qtz3GEb5FXIjK5xgvN4EshvUQY2VYInOTqaTcPm
	QO0qxTvnE3tkHcxnWAQGCzdRYpF94AZf5oN0oJnHQI/FpxY+lmADzW6rjwajY7FG
	FEFADvDRh5xvz/665sLeOG7CVMJ606drhuw==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1793568551; x=
	1793654951; bh=4+Rkx3GQ7I6uDgxqLvKaPyUNc7ouJHNyu5UM0/cW7VE=; b=O
	TU05T+kBNG0v8txz8MRNxmYt8TPjHs7zwavdSDzrN6kI24FfrB4eF8F5ZUrHGWz9
	/b/GwV2z5fV/d9L1RBwuiqz0soI62CgfPEKwNiDGKNPksAVKOZQzge9Di/ohWy++
	WBctQs0eKTeVxFs4+STLR0hBeS1C4eWW+olchshUjKdG6MNg58TFRc8bfPrqUprG
	S1EawR4/IJI06SvBpESsNFV6UgFrxvcfENk9nJ3CQvYcLVJw5ooP/xiH8JxgTPjb
	S3LvnmeabB8G5ivTAhAtC+Ni1M+BKWQFPjZLp3ZS0UjpjAQs7EhML5umX3h0ru4h
	w7dHFi2JmLrs0vFY60ztg==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793568551; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:ILr9QNCKyto1nbhqCXnFpJ56YwvoOMUaaxxUURXM/0GVhxI
	PR0YhQ0H1G9b2+pZpJDJySljSLhQ85abSAIX2QkwUNMKIrPNsCuu7sVVyicmjUp+
	vPXb8cqPWb4YSrM7ORWbZA9CWnT7DMXP2f1K38Xr0AU0szaquMT2DKZaU68djKjE
	bsTHCrwRF/y0W97kzTa5kQwr+Mbn9EKUOek0P+TxqHMViSO8dhYYP6d5UuMiNMZw
	u3ry17puUPsj63cnvAI1GJc6+/I9fIqlU0Y8/xQL6wIW1F25O/dBaBdbtmnaaFNy
	969yRXiqltGpB8ZDEhudP9b8vyiQCmQAWBKPXAg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:WUvppL31H65NuvEvp+bA+NhqjPmBDEZq6ABxS9qrTxA=:5AvZy7GVil8U9+BvclQES0J7RLBjeLccfzGxVbjLjyk=;
X-ME-Sender: <xms:J6_naiCo76ZoJP0LWvUB4jzE-p4VjS3ZN7dV6jrJML1TKD5WA0x0sg>
    <xme:J6_nagOXCBpiQ4N8iKNrJarUCrDqKIcl5RzBW5Xv2OLjwHpJgA-YX1WDsXi-HPPjK
    3zZi3xdRwlzkM8czABtoR1JJljtkcC8y3Bj962jdqsxcem4kqA>
X-ME-Received: <xmr:J6_navZY3OYE3mfUOv-ibTpk1sLGbyaJHr_uTuD7D_Yw49AROCST_La7V9OWajP0r-LW1BM33mMUHhbdaXLqWjD-2IbDJSA>
X-ME-Proxy-Cause: dmFkZTEKrDxSHGgIzBmDpjjkIHPMxsCGK1CpNZ++cfdOy7KDq6R1lYMsRoD2uig6eGCoAn
    aEJPMyD+WGR9xsWveWH7U/Pdb5dVDtaZAlTcDWifkENAKFNAM5H1JMNRiKx0mKcyQv9zX4
    3z7Rj9CT3IseERoN0BIFtzIFIgm/M0X/MDC0zlANbAIGYYkP+Q2LF4nKDRg8LVId2AVsIN
    RLC2R95fOvuuvSqlfbNHw+hFLLzHZOs2L1lBycDPnqlGaGvz4aZNDHI3Kk4yWAvIWPlz5T
    WzDC1CZh2TD/klgUgN+CPfnKQBFccdMwfiRWwqsLoEIhLkcIBtXRfsrghpp//FlcFLrtnK
    duIefnNhjUyTrdvXQ4HsHch3mBXucqYnTOOBqZs3VuUPjY04vVhA5CvAM2qNbEXNqR6Jta
    dl/l4z/e7lVg0zTTzKnPIgVkm6mmJeo2KbL898L+nGuTpEZWRx/+YFjQGOtzsni0X3kVET
    ZkH8E7zEmVBth2Ic5EzWjQgWWUaVs1KRAzJwgJyetitZSqQlOkWTeNvZS+xAFnlLAvEHhS
    Z7pBfS35XHFo7cHxFWgWVcsKlTrahO8X0ulCjfI6wsQkumDM8daRpYo2yz5CbMYDZ6R+Bj
    C6uqPYvSXonTipa5vQBYQYI5I4M73aCRLHOM3bEw00lUcKWEIGuwo5M64jzQ
X-ME-Proxy: <xmx:J6_nantUdH57tA3pNrIvDQOjH9UmgiVTMg78qXtsTIe1MbfeA8C3fA>
    <xmx:J6_napNJSE10rbNER5WO2YyxT-tbsbB8vRTeq973l8J8DyK2lQeS-Q>
    <xmx:J6_nam6ElbaPQPRmhMGbDG2fgrogOQx8rkoWhpvjhqvGinkfwXhEIg>
    <xmx:J6_nanStFJr1jZM0823oEHduBDLfQSrgaXN_UikbS7XF1zGUc-1oUg>
    <xmx:J6_najjhTlMYQy3RLUIGfsqTXrwHu0NFPWJ80es98AxMl9d_DdQ9UPVY>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 1 Nov 2026 16:29:09 -0500 (EST)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Subject:
 Re: [PATCH v1] NFSD: Do not regrow a slot in the SEQUENCE that retired it
In-reply-to: <20261101154742.1950822-1-cel@kernel.org>
References: <20261101154742.1950822-1-cel@kernel.org>
Date: Mon, 02 Nov 2026 08:29:04 +1100
Message-id: <179356854478.547122.8943689348477321562@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 02 Nov 2026, Chuck Lever wrote:
> When a SEQUENCE acknowledges a smaller slot table, free_session_slots()
> retires the slots above the target. If that SEQUENCE is on the new top
> slot, the growth test later in the same nfsd4_sequence() call finds the
> table at its target and allocates back the slot the call just freed.
>=20
> The slot is retired and rebuilt inside one request, so a client with a
> request outstanding on it never sees NFS4ERR_BADSLOT. A copy of the

How would a client have a slot outstanding if it has acknowledged the
smaller slot table?

I accept that shrinking and the growing the slot table in one op could
easily have edge cases and is best avoided, but I'd like to understand
the motivation of the patch.


> slot's first request passes the seqid 1 rule for a rebuilt slot and
> executes a second time. A CREATE replayed this way returns
> NFS4ERR_EXIST, reproduced with pynfs against a two-slot session and one
> write to drop_caches. A retransmit of a request whose reply was lost
> matches the retained seqid on the uninitialized rebuilt slot and gets
> NFS4ERR_SEQ_MISORDERED, which the Linux client retries every 15 seconds
> without limit.
>=20
> Skip the growth block in a call that retired slots. A retransmit that
> arrives while the slot is retired now gets NFS4ERR_BADSLOT, which the
> Linux client handles as a session reset. The next request on the top
> live slot still grows the table on demand, so a copy delayed past that
> request meets a rebuilt slot as before.
>=20
> Fixes: fc8738c68d0b ("nfsd: add support for freeing unused session-DRC slot=
s")
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  fs/nfsd/nfs4state.c | 13 +++++++++++--
>  1 file changed, 11 insertions(+), 2 deletions(-)
>=20
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index cafdf80f32de..1b8fe62cc756 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -5230,6 +5230,7 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_c=
ompound_state *cstate,
>  	struct nfs4_client *clp;
>  	struct nfsd4_slot *slot;
>  	struct nfsd4_conn *conn;
> +	bool retired =3D false;
>  	__be32 status;
>  	int buflen;
>  	u32 maxlen, respsize;
> @@ -5301,9 +5302,11 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_=
compound_state *cstate,
>  	    slot->sl_generation =3D=3D session->se_slot_gen &&
>  	    seq->maxslots <=3D session->se_target_maxslots &&
>  	    seq->slotid < session->se_target_maxslots &&
> -	    !nfsd4_slots_inuse(session, session->se_target_maxslots))
> +	    !nfsd4_slots_inuse(session, session->se_target_maxslots)) {
>  		/* Client acknowledged our reduce maxreqs */
>  		free_session_slots(session, session->se_target_maxslots);
> +		retired =3D true;
> +	}
> =20
>  	buflen =3D (seq->cachethis) ?
>  			session->se_fchannel.maxresp_cached :
> @@ -5360,8 +5363,14 @@ nfsd4_sequence(struct svc_rqst *rqstp, struct nfsd4_=
compound_state *cstate,
>  	 * configured maximum, not the running thread count, so a
>  	 * client resuming from idle can grow back before the pool
>  	 * scales up.
> +	 *
> +	 * A slot rebuilt in the call that retired it carries
> +	 * no cached reply for its outstanding request, so a
> +	 * retransmit of that request is executed again or fails
> +	 * with SEQ_MISORDERED instead of BADSLOT.

This comment could probably be improved.  As we don't (now) rebuild a
slot in the call that retires it, "A slot rebuilt in the call that
retires it" does not exist, so is not of interest...
Maybe:

   Don't grow the slot table in the same call that retired some slots.
   Doing that would mean the client never sees a confirmation
   that the server dropped all the slots, so ...... something that I
   don't understand yet.

I don't object to any of the code here - I'm just not clear on
motivation.

Thanks,
NeilBrown


>  	 */
> -	if (seq->slotid =3D=3D session->se_fchannel.maxreqs - 1 &&
> +	if (!retired &&
> +	    seq->slotid =3D=3D session->se_fchannel.maxreqs - 1 &&
>  	    session->se_target_maxslots >=3D session->se_fchannel.maxreqs) {
>  		int s =3D session->se_fchannel.maxreqs;
>  		int ceiling =3D min_t(int, NFSD_MAX_SLOTS_PER_SESSION,
> --=20
> 2.54.0
>=20
>=20

