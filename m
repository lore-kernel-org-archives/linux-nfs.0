Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 427AA3DB33C;
	Tue, 13 Oct 2026 11:47:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791892080; cv=none; b=TYhiM7EFe9kjOBojO9nzjnO7PtFhdYaCrRV5x6axdEOn38eW6NtFNM1AoGcS0v+cvTqr7vEltG9a4Mle7PPcONriFmCpc5YSLSQVJy3vS8X2mcPEKTtzamTcDFREEo/0R5oCwPWpugQ7WfozFizfzSEn2AROGu1PobDuC3WdEpQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791892080; c=relaxed/simple;
	bh=o6sARfxGQJNJVYqwHvvJQqvQOCgPoJokBZqHW2HTn8I=;
	h=Date:From:To:Cc:Subject:Message-ID:MIME-Version:Content-Type:
	 Content-Disposition; b=eNQWR6eTDtmsKtx8d31CgMPlruawsq+cdbHAvGyK3t2PWdYmVdODWTE8g7VusA6SoIZojfqpA1nt5dpdXi5vNYlfAIgyeer4o4Ak9lXnkopHnRPraYDKLbUkH57AKCiGcpIC3ooTm35BpEmMdu+pUEqEtYNdGGSkGDgOsRjzmsU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=T8dzxUKt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="T8dzxUKt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1572D1F00893;
	Tue, 13 Oct 2026 11:47:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791892078;
	bh=mJfBsSrl6RT1dyIbZP2nGyCTvVy4nbBrUrd1tAwn/3k=;
	h=Date:From:To:Cc:Subject;
	b=T8dzxUKtpodwdI5cwlxvBuMfd8FlweGY1jP0OGKXA25MgbEVqQeeioV0QzfDYNvlZ
	 pvABkOPArORfshxvywrB58dhRT4Ff7j8/GqHR7y1YTVBka8YOalM4U8vAJTT9QgIif
	 36FcaonTjddZCIBcNA+uRPq8AEBgjcPNsC18T38ZFTqoCQ/dB70tOTze6M0T6IFaSn
	 +HsCWPWndmUR6wawSdz7p+VxaxQVK+NwXnu9qAN7GdjIIkDHkz6ony3gPIeTUIvkx7
	 0E/uL4R5k5S1oRPCUuimnfLZOSkEIbegLHJeaEAhLbGUWpQPnjjqUK/Ok+Uk6YwLDU
	 4BfVG/hURjPQg==
Date: Tue, 13 Oct 2026 12:47:53 +0100
From: Mark Brown <broonie@kernel.org>
To: Anna Schumaker <anna@kernel.org>, Trond Myklebust <trondmy@gmail.com>,
	NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Anna Schumaker <anna.schumaker@hammerspace.com>,
	Chuck Lever <cel@kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Next Mailing List <linux-next@vger.kernel.org>,
	Tim Menninger <tmenninger@everpuredata.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Yongjian Mu <ymu@everpuredata.com>
Subject: linux-next: manual merge of the nfs-anna tree with the nfs tree
Message-ID: <as4aacUf2Q78FMvY@sirena.org.uk>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
	protocol="application/pgp-signature"; boundary="uVRrn9RlIwHa/1AR"
Content-Disposition: inline


--uVRrn9RlIwHa/1AR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the nfs-anna tree got a conflict in:

  net/sunrpc/xprtrdma/rpc_rdma.c

between commit:

  a0db57fee35ec ("xprtrdma: Fix Write chunk payload corruption on a short r=
eply header")

=66rom the nfs tree and commit:

  9ee534a759123 ("xprtrdma: trim head iovec when the payload arrives via a =
Write chunk")

=66rom the nfs-anna tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

This one definitely needs double checking.

diff --combined net/sunrpc/xprtrdma/rpc_rdma.c
index ba8bdca8a49fb,7e5713367291e..0000000000000
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@@ -984,12 -984,16 +984,16 @@@ void rpcrdma_reset_cwnd(struct rpcrdma_
   * @rqst: controlling RPC request
   * @srcp: points to RPC message payload in receive buffer
   * @copy_len: remaining length of receive buffer content
-  * @pad: Write chunk pad bytes needed (zero for pure inline)
+  * @writelist: bytes conveyed by the Write chunk (zero for pure inline)
   *
   * The upper layer has set the maximum number of bytes it can
   * receive in each component of rq_rcv_buf. These values are set in
   * the head.iov_len, page_len, tail.iov_len, and buflen fields.
   *
+  * For READ replies with a Write chunk, the payload is already in
+  * the page list. An overestimated head length and buflen can be
+  * reduced without moving reply data.
+  *
   * Unlike the TCP equivalent (xdr_partial_copy_from_skb), in
   * many cases this function simply updates iov_base pointers in
   * rq_rcv_buf to point directly to the received reply data, to
@@@ -998,13 -1002,16 +1002,16 @@@
   * Returns the count of bytes which had to be memcopied.
   */
  static unsigned long
- rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int=
 pad)
+ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len,
+ 		     u32 writelist)
  {
  	unsigned long fixup_copy_count;
  	int i, npages, curlen;
  	char *destp;
  	struct page **ppages;
  	int page_base;
+ 	int pad =3D writelist & 3;
+ 	unsigned int delta;
 =20
  	/* The head iovec is redirected to the RPC reply message
  	 * in the receive buffer, to avoid a memcopy.
@@@ -1016,8 -1023,20 +1023,20 @@@
  	 * head.iov_len bytes are copied into the page list.
  	 */
  	curlen =3D rqst->rq_rcv_buf.head[0].iov_len;
- 	if (curlen > copy_len)
+ 	if (curlen > copy_len) {
+ 		/* These READ replies have no inline fields after the payload.
+ 		 * Trim the head without moving the directly-placed data.
+ 		 */
+ 		if (writelist) {
+ 			delta =3D curlen - copy_len;
+=20
+ 			rqst->rq_rcv_buf.head[0].iov_len =3D copy_len;
+ 			rqst->rq_private_buf.head[0].iov_len =3D copy_len;
+ 			rqst->rq_rcv_buf.buflen -=3D delta;
+ 			rqst->rq_private_buf.buflen -=3D delta;
+ 		}
  		curlen =3D copy_len;
+ 	}
  	srcp +=3D curlen;
  	copy_len -=3D curlen;
 =20
@@@ -1243,19 -1262,9 +1262,19 @@@ rpcrdma_decode_msg(struct rpcrdma_xprt=20
 =20
  	/* Build the RPC reply's Payload stream in rqst->rq_rcv_buf */
  	base =3D (char *)xdr_inline_decode(xdr, 0);
 -	rpclen =3D xdr_stream_remaining(xdr);
 +	rpclen =3D rep->rr_hdrbuf.len - xdr_stream_pos(xdr);
 +	if (writelist)
 +		rpclen &=3D ~3;
 +	if (unlikely(!rpclen))
 +		return -EIO;
 +	if (writelist && rpclen < rqst->rq_rcv_buf.head[0].iov_len) {
 +		rqst->rq_rcv_buf.head[0].iov_len =3D rpclen;
 +		rqst->rq_private_buf.head[0].iov_len =3D rpclen;
 +	}
 +
  	r_xprt->rx_stats.fixup_copy_count +=3D
 -		rpcrdma_inline_fixup(rqst, base, rpclen, writelist);
 +		rpcrdma_inline_fixup(rqst, base, rpclen,
 +				     xdr_pad_size(writelist));
 =20
  	r_xprt->rx_stats.total_rdma_reply +=3D writelist;
  	return rpclen + xdr_align_size(writelist);

--uVRrn9RlIwHa/1AR
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQEzBAABCgAdFiEEreZoqmdXGLWf4p/qJNaLcl1Uh9AFAmrOGmgACgkQJNaLcl1U
h9B4hgf/XZT4PY5+VTnMuDjQozfJIhFb3bwjKmTUBYJSaWxHqTLKjKwC2kCq5uS3
D+98UnIj7LhWZ3xdcvrvo/x9NyN/UBLaVB+ZALKCL80ZTLbGS5koocC4tP19aPOu
gaLWbbq/Vx4hZEAESSNy0YSsOFvdSZuTyB8WMRIhbIRJ8Myo/kVPEXpyRwArWpnU
EnmIo3w1OJ7LbW9E8zRvrC1+3ohGyTYQNA1fCyYsTA4k2F4Kcms/FIUzg3GcVZzn
aZGvKYTPZSXcO5SRTNS5zCH1ce8IBR2nGlS06KV3DJlqh5LZwCowbf9ZUJE09JdJ
G4jANezHfD22Lc1CX55djO2ZB8d2Wg==
=8vv0
-----END PGP SIGNATURE-----

--uVRrn9RlIwHa/1AR--
