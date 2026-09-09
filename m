Received: from fout-b3-smtp.messagingengine.com (fout-b3-smtp.messagingengine.com [202.12.124.146])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3106C49AA55
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 23:32:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.146
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788996728; cv=none; b=ee8Kr9krZU3TJk5JO6Dx7hhr8MsgXpO4JgZJMJxjCeoceVE+0tUoBsn7mvfOOZo3I0HHLwt891RS/HME+Am4y9/n5TZte1sGAF0kVue2piGmnnc2vCdrX+PD4jraNqQkhODkrRYWS8vBhWAPiMJuobYIcp2Ku8Ig0M9sj4Y9emc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788996728; c=relaxed/simple;
	bh=7PS6WNkGqdOtEQCVi45Z157xMJUipDyFoL7TmLSVOqk=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=sUyJhGGBhvLkGkKW/0QPDasMDxs+T5VbBZODYofKtEW8xugQuSnWqY5oXtftq6hOHcHye++dYwDkLhDiNOF2i9yQv8Ea7HCVHqrz6Eku/VtG4ApX9MZLghTMDnlw+WB1h6oo5/8rLfPBXgPQk3oBzR+tq//tA720LZObOkIC6l0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=j9kZQ+ju; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=fAzR7feh; arc=none smtp.client-ip=202.12.124.146
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="j9kZQ+ju";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="fAzR7feh"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.stl.internal (Postfix) with ESMTP id 3CCF11D000F1;
	Wed,  9 Sep 2026 19:32:05 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Wed, 09 Sep 2026 19:32:05 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1788996725; x=1789083125; bh=y7KoC6RC9BVdYOUuZgM0dPpsQafBY6QbFDJ
	bIo7HcNE=; b=j9kZQ+jufsvHsu9FQ4ERWE+90HZNQsKOxONjKpIl0R8M11me4R/
	31dOLw+ufjByML7cpg5qfVsIT3B4bTsfcDoKIu5d0bU3LQFqvrEIvPGgBe0SVX+C
	yGXMJwpQSkq0iw+Gjn6UlsQLCifaVwFJAQWwCjoQIZgkcxNWfWBi9B9qvIZXvWYU
	ZUOyvmQwiod7OTUQa/uX0+qg9TceokE6TCjc5ltdCFDDTAUwZlWlHJxez/JjWWsW
	zgL1XBai9eM6VIjp5lL6VP6euKaH2j7BeKNLMALHwIjboQzxzyIuTcZlczUkD+0w
	zg/OxZJjj8/P8DC8zHP9yfWACRNH17jdfNQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1788996725; x=
	1789083125; bh=y7KoC6RC9BVdYOUuZgM0dPpsQafBY6QbFDJbIo7HcNE=; b=f
	AzR7fehHRP0BNgFOoUPyyjiIhd3LmhTl8mk8w95BsZBsvBOg+uNujVTw8GO8ijlv
	P9LGlamF8kK/XCy6qgwE8UWDOUJRg7k64lu8R6rBJtp9LsyWVGZX52xl4004ne/n
	4yTzOOCpCsExVDlDuDenAlIISrETfAvFY9iAWRJEwm18enapKdTqMXP44LsNjR0q
	cWngL3qdjiLILcuzX5+Bo8eDf1clnlDp82kA+ZQ2mHGLdFWTw3L8pT/CdzoR/k0p
	/x1ROu0CeYAxBiR3q6bk+tQ6C6eXIlebsuq1vLWRM8cnzSRAE7/zZQZ5L4FOjg7P
	esnlftmoNewb0FiVAoZdQ==
X-ME-Sender: <xms:dOyhapO9WO9qT68dvumrQGcuh_2HGRnE5DJKC7bkqAkQz336QDbodg>
    <xme:dOyhavoKENgmmmjJtD2c9yb64mzUzT_ezw9FwqbL9xYxzqGlbPwzBtK2DAe4BVT1b
    j1lYPSVFUh4g_r_W7i3nKkX8amI-650dN_CwW2EAtUrUPhEV0li>
X-ME-Received: <xmr:dOyhaiGj7JscxD5fsP8qf9j_Nxpe99saZ3KlZz3URT368u7YfGnqARJhMXM1ViEuCd5jSAljLpixfNOy0Sy91dAU02Dry4s>
X-ME-Proxy-Cause: dmFkZTF7PHGi5aYZAdrbzn/TtEDcIx27eRlwAGFpkf9sdZLSF7u9bD92iQqmHOC3KTCxbG
    IQSRrG/8IrFGh7V2B5LPsBdPio6OJ+GI72mQbqd0C2gximondBtF++s2oZcQGsT9QgzKez
    f7syc1LqYwPq/jVaAuerfUkUtomT6TSHvDsnQq9rVDqWFhV4H5jQ59y7bfdMXQmaiQTfXu
    /AVeBmxZDFEy1SrVHKFtzalBAO8GrwrcdHmVk+2e0NLyIa8YOW9LlMRWff3P5jjtGhQkFC
    GDQ3BCaVxvLXg85TYWz/WLQiIYe1zlY8nfU72eXzTIH08hsy88aIb0plB9G9jS1RCe6ZQJ
    YE8h3QT7mverW8qvtOY1nn/05zBmNQNPsSO5632yRuZze+3UeFheexkSoC5Sbudbr+MBIR
    hI3Xp2BXzRsXI4T4XMHpMeR2vJ9LrMikYelba3yHiXJrz267LpOdg0eSTsbMBc6MRaKQJE
    Dp9OZpe4NmWvQF5rDjNMXO06mwD8B9jIqNPbDgvGv5DUkfAEqsV/oNzRohxBM1qbwfkZAl
    M9s+i4pjOCyPbzwgDLIMP7tQgQ+CR+jUuYxLFzVdwRd4gNXA17ES0G3YiPmaukTvaC3/HC
    g+CwvTdGH7FETmzO/e1leVkqtvBqyde4ikWtYJ0SGemYV6HJa9Hyr9Pchi4A
X-ME-Proxy: <xmx:dOyhasqKquKrWE5MrFBNiCPPZPFkNDNMlo0hpxoTjplrq53KfF5jzg>
    <xmx:dOyhajZj_D_VsvW4B1pI9aV_A3CWdgzJExv3FLSFv950BVFgRAGlpA>
    <xmx:dOyhatXgkNjY9gpskfgtq55YhH1gtnxt9uXlvz00wUbCDKnuXoOoXw>
    <xmx:dOyhak-PE2gQPzR7-XjUB93nOCi1SjF91SEqia3W-J1Hi1y3EpSTdA>
    <xmx:deyhamski04HWODH7awzRyPOK7MYbDvD-KcPUgeeO3cU3sMSlIe0ILV1>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 9 Sep 2026 19:32:02 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 01/10] SUNRPC: Carry a generated-codec context pointer
 in struct xdr_stream
In-reply-to: <20260908134234.512312-2-cel@kernel.org>
References: <20260908134234.512312-1-cel@kernel.org>
  <20260908134234.512312-2-cel@kernel.org>
Date: Thu, 10 Sep 2026 09:31:59 +1000
Message-id: <178899671901.207413.7637003261420249464@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 08 Sep 2026, Chuck Lever wrote:
> A generated XDR codec function receives only an xdr_stream, yet
> some codecs need state that the stream does not carry. Passing
> that state as an additional argument changes the signature of
> every function on the path from the program entry point down to
> the one that consumes it, and for generated code it makes each
> function's argument list depend on an analysis of the entire
> specification.
>=20
> Add xdrgen_ctx to struct xdr_stream, a pointer that the layer
> initializing the stream sets aside for generated codecs to find,
> following the precedent of seq_file->private and
> netlink_callback->data. Every xdr_stream initializer clears it, so
> a codec never reads a residual value left in a stream that was
> allocated on the stack or taken from a transport's free pool.

It seems it could almost be worth having and common xdr_init()
which call xdr_reset_scratch_buffer() and clears xdrgen_ctrx and
possibly a few other pointers.

Reviewed-by: NeilBrown <neil@brown.name>

NeilBrown

>=20
> Signed-off-by: Chuck Lever <cel@kernel.org>
> Acked-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/nfs4xdr.c          | 1 +
>  include/linux/sunrpc/svc.h | 1 +
>  include/linux/sunrpc/xdr.h | 1 +
>  net/sunrpc/xdr.c           | 3 +++
>  4 files changed, 6 insertions(+)
>=20
> diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
> index 00ddaac499c6..6ea6cb0632f8 100644
> --- a/fs/nfsd/nfs4xdr.c
> +++ b/fs/nfsd/nfs4xdr.c
> @@ -4609,6 +4609,7 @@ static void svcxdr_init_encode_from_buffer(struct xdr=
_stream *xdr,
>  	xdr->p =3D p;
>  	xdr->end =3D (void *)p + bytes;
>  	buf->buflen =3D bytes;
> +	xdr->xdrgen_ctx =3D NULL;
>  }
> =20
>  __be32 nfsd4_encode_fattr_to_buf(__be32 **p, int words,
> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> index 5fa9417e034d..b80161b849ce 100644
> --- a/include/linux/sunrpc/svc.h
> +++ b/include/linux/sunrpc/svc.h
> @@ -567,6 +567,7 @@ static inline void svcxdr_init_encode(struct svc_rqst *=
rqstp)
>  	xdr->page_ptr =3D buf->pages - 1;
>  	buf->buflen =3D PAGE_SIZE * (rqstp->rq_page_end - buf->pages);
>  	xdr->rqst =3D NULL;
> +	xdr->xdrgen_ctx =3D NULL;
>  }
> =20
>  /**
> diff --git a/include/linux/sunrpc/xdr.h b/include/linux/sunrpc/xdr.h
> index b102b4f21e6b..2b33fc64be17 100644
> --- a/include/linux/sunrpc/xdr.h
> +++ b/include/linux/sunrpc/xdr.h
> @@ -244,6 +244,7 @@ struct xdr_stream {
>  	unsigned int nwords;	/* Remaining decode buffer length */
> =20
>  	struct rpc_rqst *rqst;	/* For debugging */
> +	void *xdrgen_ctx;	/* Context for generated codecs */
>  };
> =20
>  /*
> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index cb2ef428651f..d95e80d85a89 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -1162,6 +1162,7 @@ void xdr_init_encode(struct xdr_stream *xdr, struct x=
dr_buf *buf, __be32 *p,
>  		iov->iov_len +=3D len;
>  	}
>  	xdr->rqst =3D rqst;
> +	xdr->xdrgen_ctx =3D NULL;
>  }
>  EXPORT_SYMBOL_GPL(xdr_init_encode);
> =20
> @@ -1181,6 +1182,7 @@ void xdr_init_encode_pages(struct xdr_stream *xdr, st=
ruct xdr_buf *buf)
>  	xdr->p =3D page_address(*xdr->page_ptr);
>  	xdr->end =3D (void *)xdr->p + min_t(u32, buf->buflen, PAGE_SIZE);
>  	xdr->rqst =3D NULL;
> +	xdr->xdrgen_ctx =3D NULL;
>  }
>  EXPORT_SYMBOL_GPL(xdr_init_encode_pages);
> =20
> @@ -1619,6 +1621,7 @@ void xdr_init_decode(struct xdr_stream *xdr, struct x=
dr_buf *buf, __be32 *p,
>  		xdr->p =3D p;
>  	}
>  	xdr->rqst =3D rqst;
> +	xdr->xdrgen_ctx =3D NULL;
>  }
>  EXPORT_SYMBOL_GPL(xdr_init_decode);
> =20
> --=20
> 2.55.0
>=20
>=20

