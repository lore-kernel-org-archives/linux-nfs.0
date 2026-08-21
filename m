Received: from mail-wr1-f53.google.com (mail-wr1-f53.google.com [209.85.221.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5ADB535F8C9
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 15:36:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.221.53
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787326588; cv=pass; b=Kq4scedlVCx6rYxm+GNz59JHe48HnFwtRYJF+HZw7lErAeNVJMz0Acnyeii740e7Co7S9ho2W21NBHC/RpEpMgCNt5lsOR2sTzn6PlXgIz6OPrzc0tQz8I4DljFBTkLcyjxwBMJ6okJFNKW3Eypk0H0wthGp8Wn1ok44UmEub6E=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787326588; c=relaxed/simple;
	bh=xyPMZlPfjW9T2//cbQa4rUL28GBJdEd/uDiDROLzzQ0=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=XisxeKZUIt6767dYgU/y9fuDA/n0PQiZzOSxyNQCnz5f65Jyhv+mmUcZjuQzdjlf3A4fofaeloso6soddw8YcyTpunu5cqBiHKOj7CahPtMusY0KnaGp5bsCB61nmPcMP/kAeaoNrPGTgIGabTp/6WqyMDUcS6kcAKziWP/YhB0=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=bynar.io; spf=pass smtp.mailfrom=bynar.io; dkim=pass (2048-bit key) header.d=bynar.io header.i=@bynar.io header.b=FILEliRB; arc=pass smtp.client-ip=209.85.221.53
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=bynar.io
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=bynar.io
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=bynar.io header.i=@bynar.io header.b="FILEliRB"
Received: by mail-wr1-f53.google.com with SMTP id ffacd0b85a97d-47f96c5b722so571173f8f.0
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 08:36:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1787326585; cv=none;
        d=google.com; s=arc-20260327;
        b=If7wn4bNrWYKJkSq8uc6lTg6GMttxkiVBHh2NYcDbYz5ALcmT0XyqZmx8q8Cr+zxIF
         VTUMAofQ7EMpT7qdQAq+zfd9XBRIo1BshIolbWsisLz70rri5DisVXoUbk5NaZ7tqd5v
         KvgylCJK4c0x7vXKHJZyrERw2WQx9W0Z2C3sFxpsJABw7Lue06jnOhbRnAzbqcWPzoLh
         K2l7ZFpbr39J9Jaa/2s5j+4uLoa2BCg80GMAIwUkaPDZhRsJPcJiRriprqfrX2aP4mxq
         jmiye67Cj3a/+IQMh+FLegz1DFqUp+jdI6C9AwHBAyWsrLLzbhwu1egNmaxY9RkGUv5b
         FO1g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=xTFagY5lhfq4phRZNbHmMF0fyCdUlkT9RSwivJQEo90=;
        fh=woarG7HuPafLixkr1GVKQQyEUcax4sba8pTDfhki6LU=;
        b=dtmGM2UeMdyvvwffBGgHfGS3/U3hGoB7uRaSLUhVGANBypnBCp4pludfe5VlnVgDJB
         VFVdoViuJWflZlY++P7yXww6/91l/jqaeDxORQ07FgfA3W3mc0dFYAQZ0gDTX3/Rkqpi
         Xv1ctsx29Iz0isBbTWhIkEg87yAl+noSYxpAVWRKptdN4xzyjg77vyAw2C7YPHCXXI5P
         sr+PlJU2cmLQgBoLWMW2M4z5oBbz5y+EYN9xc+0nJqNCRz7bLzjgboEp3GRhMITqTFIt
         EaU+OpwiMRj0+O0bTcLmNyenQ175Itni/cZHr8QsZJQHxki6liUeJLganFw7UIUI2nAB
         oTjw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=bynar.io; s=google; t=1787326585; x=1787931385; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=xTFagY5lhfq4phRZNbHmMF0fyCdUlkT9RSwivJQEo90=;
        b=FILEliRBTkJw/VVnKDPja2bXefyxMY+tfYy8sEomda7n4UEMuKIo3b3BJptA8osGdV
         vE41HT+h4Wd6phv/VGj/6CcV3hE31uMSpaNlpn7HR/ZvZgWSunOkwJXP4QyrHrFmYcaK
         GqWC7MLflhzG8bRBqhQyMtDsWYNRkSSO2OQ6dNwIWMDDQXjZSRG2jvTn9Hv+tJP5ZpF6
         FLpU8lecguTq0ezu0VaHoQ/VRrXh0kh5FKFHbI3JquRwhgDxaewP2ckNL7JrAstpwwe/
         fMDLFI/nxj6+T5WBdB51AcBVaWsy4HnnnGHSIp1XKKO4n6nr5rhf1XkecC9r+rMEWXqU
         C+Zg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787326585; x=1787931385;
        h=content-transfer-encoding:content-type:cc:to:subject:message-id
         :date:from:in-reply-to:references:mime-version:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=xTFagY5lhfq4phRZNbHmMF0fyCdUlkT9RSwivJQEo90=;
        b=IhvRrlOkTdNqwTkJ+8cfzxSuA5XkqfBQbzVSZWPtmOCzpnccHoA+vacGu+vSvX+/xs
         2eHHaXRu2dKuv10gIy3D/vqJX1aHY4x86VyXzWpz0peyV2fWMPCEQu1nUbJhKuVTRbFY
         iHgwaW5n37eSpWu4PHJ1mJcqlZUXcZJMQnnyQlNAtmRTWTKRkdkY9ZWYeXDYLBLWR180
         vnY+T5r5shvcndyUgrLch61BcZNeXr+0hvUeYEUYgnfNB14BM1i1haA6UeYdXegweXqR
         WF2h36tczZXzy0BsrNhiv1YXpkx3J5+1tjgS//1DYtFa5TY5zqYpeLbDQWb2P9x9wyOK
         0ieQ==
X-Forwarded-Encrypted: i=1; AHgh+Rrlg8MaFY+YpgeWV+RmEHWb5YcvSRZs3sVWm7+dw/jQJD9sOMkGmo9QxIeOJSeqnN1zZF10guZaVtY=@vger.kernel.org
X-Gm-Message-State: AFuF++lOTwopMv0nTyUAEcIjTdxZ09kn3FfxIJj92GHvb9J/qsLMcYWc
	alVWZrBY0qWaTjqcEZ+YHb/zJeB/LXrRPAOAxzMSwbKGMQD3ARLSeQvb2LTLAowWzusXIT+zHvq
	KoVisZz+Vkin1DhLHT9/XEuBC9O2fAoMbdcfgq1QoG5w=
X-Gm-Gg: AR+sD12JE9hEwRVbgTZQhVugPjNx49F6QL8NWEla7Lk0hYfhoKj3qDbsiVnd2Slokwe
	rbtQwszrdeEM+7R1fXyaK7kla4vG8byPaEDTL0iU8Ea9qimxW6bu0YkNVAU51VlAoaYSVgHyNh6
	/m3z8CwM32pLhGhqUiv0i9tj2E7uPvuORhxMS7dPeiOtGaGoMZcmgqU4LXOOR/tzifbqvSd8i/+
	7oWI+8i7/lXjVBUVSUmQx1yytxycVZybTvxSf3p6whcQElOJnvpD/VRCDF6ksrCD/eY+2Q4KDEj
	eJIKuiPkxkW8IILfK1A44uVoB+aB9uYkLNYNjwyY
X-Received: by 2002:a05:6000:2301:b0:481:f33d:6445 with SMTP id
 ffacd0b85a97d-482c0b587d1mr11038908f8f.7.1787326584418; Fri, 21 Aug 2026
 08:36:24 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260820143049.25712-1-paula@bynar.io> <b8744803-5b58-4c64-82da-73a802dd4b0f@app.fastmail.com>
 <CANegxYFKBfCKjEEn73n1-C1Ev9MY9RE-zQ4LW2C-BCoRpjAqhw@mail.gmail.com>
In-Reply-To: <CANegxYFKBfCKjEEn73n1-C1Ev9MY9RE-zQ4LW2C-BCoRpjAqhw@mail.gmail.com>
From: Paula Moutafian <paula@bynar.io>
Date: Fri, 21 Aug 2026 16:36:13 +0100
X-Gm-Features: AcwNN1UXPa-Wn9OfMIeYFhPMp2-pGl0vvhY4Qzk3l03UVVJZIvHlmXWLsAS30L0
Message-ID: <CANegxYHr3=tB+OhemrJdLh2ciM4ZUjCPq9SXbJmh38NdRVtVGg@mail.gmail.com>
Subject: Re: [PATCH] SUNRPC: fix out-of-bounds write in xdr_inline_pages()
To: Anna Schumaker <anna@kernel.org>
Cc: Trond Myklebust <trondmy@kernel.org>, Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
	NeilBrown <neil@brown.name>, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

Hello Anna,

The note was a mistake, I confirm that it compiles fine and the patch works=
. :)

Kind regards,
Paula


On Fri, Aug 21, 2026 at 4:32=E2=80=AFPM Paula Moutafian <paula@bynar.io> wr=
ote:
>
> Hello Anna,
>
> The note was a mistake, I confirm that it compiles fine and the patch wor=
ks. :)
>
> Kind regards,
> Paula
>
> On Fri, Aug 21, 2026 at 1:56=E2=80=AFPM Anna Schumaker <anna@kernel.org> =
wrote:
>>
>> Hi Paula,
>>
>> On Thu, Aug 20, 2026, at 10:30 AM, Paula Moutafian wrote:
>> > xdr_inline_pages() re-carves an existing receive buffer into a head, a
>> > page list and a tail at a caller-supplied offset, computing the tail
>> > length as buflen - offset.  It does not check that the offset lies
>> > within the buffer being carved, and iov_len is unsigned, so an offset
>> > past the end wraps the tail length instead of failing.
>> >
>> > The offset reaches it from wire data.  rpc_prepare_reply_pages() deriv=
es
>> > it from the authentication flavour's au_ralign, which is read on every
>> > encode, while the receive buffer's size is fixed once in call_allocate=
()
>> > from au_rslack.  unx_validate() raises au_verfsize, au_rslack and
>> > au_ralign from the reply verifier's length, and runs before
>> > rpc_decode_header() reads the accept_stat, so a GARBAGE_ARGS reply
>> > poisons the alignment and only then selects call_encode().
>> > call_allocate() short-circuits on the existing buffer, so rq_rcvsize i=
s
>> > not recomputed and the retry carves a new offset against the old size.
>> > auth_unix keeps these fields in a file-scope static rpc_auth shared by
>> > every AUTH_SYS client.
>> >
>> > For an NFSv3 READ the design slack is exactly one XDR word, so the
>> > underflow needs only au_ralign at encode to exceed au_rslack at
>> > allocation by two -- a five-byte verifier body.  Observed with eight:
>> > rq_rcvsize is 132 with a 128-byte head and a 4-byte tail, the verifier
>> > raises au_ralign from 2 to 4, and the retry carves at (26 + 4 + 4) << =
2
>> > =3D 136 against an unchanged 132-byte buffer.  The in-tree
>> > sunrpc:rpc_xdr_reply_pages tracepoint shows the transition on one task=
:
>> >
>> >   rpc_xdr_reply_pages: head=3D[..a18,128] tail=3D[..a98,4]
>> >   rpc_xdr_reply_pages: head=3D[..a18,136] tail=3D[..aa0,4294967292]
>> >
>> > (one task, before and after the re-encode; addresses abbreviated)
>> >
>> > xs_read_xdr_buf() then fills the tail against that length, and the TCP
>> > record length is not capped against rq_rcvsize, so the reply to the
>> > retried call writes peer-controlled bytes past the object:
>> >
>> >   BUG: KASAN: slab-out-of-bounds in _copy_to_iter+0x7c8/0x1538
>> >   Write of size 1664 at addr ffff0000c7640aa0 by task kworker/u8:0/12
>> >   Workqueue: xprtiod xs_stream_data_receive_workfn
>> >    _copy_to_iter+0x7c8/0x1538
>> >    __skb_datagram_iter+0x33c/0x560
>> >    skb_copy_datagram_iter+0x3c/0x454
>> >    tcp_recvmsg_locked+0x110c/0x2308
>> >    xs_sock_recvmsg.constprop.0+0x34/0xe4
>> >    xs_read_stream_request.constprop.0+0x410/0x1140
>> >    xs_read_stream.constprop.0+0x680/0xe9c
>> >    xs_stream_data_receive_workfn+0xcc/0x420
>> >   Allocated by task 12:
>> >    rpc_malloc+0x174/0x2d0
>> >    call_allocate+0x25c/0x944
>> >   The buggy address belongs to the object at ffff0000c7640880
>> >    which belongs to the cache rpc_buffers of size 2048
>> >   The buggy address is located 544 bytes inside of
>> >    allocated 2048-byte region [ffff0000c7640880, ffff0000c7641080)
>> >
>> > That is 160 bytes past the object, with both the length and every byte
>> > chosen by the peer.  Under KASAN the interposed __asan_memcpy() return=
s
>> > without calling __memcpy once the range check fails, so the report
>> > establishes that the write is reachable and out of bounds; it does not
>> > establish that the copy executed.  The enlarged head stays inside the
>> > same slab object and is not itself a violation.
>> >
>> > Reproduced twice on an unmodified v7.2-rc7 arm64 KASAN kernel with
>> > CONFIG_NFS_V3=3Dy and no other configuration change; the geometry abov=
e
>> > came from tracepoints that already ship in the kernel, not from added
>> > instrumentation.  The trigger is an ordinary read(2) on an already
>> > mounted NFSv3 AUTH_SYS share over TCP and needs no client privilege;
>> > every byte the attacker supplies is a legal server reply.  Under
>> > RPCSEC_GSS the verifier is authenticated and cannot be forged.  UDP is
>> > bounded by the datagram length in xs_udp_data_read_skb() and is not
>> > affected.  NFSv4 does not take the retry path, since
>> > RPC_TASK_NO_RETRANS_TIMEOUT suppresses the re-encode.
>> >
>> > Commit 53bc19f17f21 ("SUNRPC: receive buffer size estimation values
>> > almost never change") placed the equivalent slack update behind
>> > RPCAUTH_AUTH_UPDATE_SLACK in gss_update_rslack(), but auth_unix was
>> > never converted and still assigns unconditionally.  Gating it the same
>> > way narrows the window without closing it, because the first update ca=
n
>> > still land between the allocation and the re-encode of an in-flight
>> > request, and it would leave the other caller of xdr_inline_pages()
>> > unguarded.
>> >
>> > Clamp the offset to the length of the buffer being carved so the tail
>> > length cannot underflow.
>> >
>> > Assisted-by: Bynario AI
>> > Signed-off-by: Paula Moutafian <paula@bynar.io>
>> > ---
>> > Note: the defect is reproduced 2/2 on an unmodified v7.2-rc7 arm64 KAS=
AN
>> > kernel; the patched kernel has not been built or booted.  A reproducer
>> > exists and can be shared privately on request.
>>
>> Question: Am I understanding you correctly that you have a reproducer, b=
ut
>> haven't tested or even compiled the code to verify that it works?
>>
>> Thanks,
>> Anna
>>
>> >
>> > No Fixes: tag: the unbounded carve is original to xdr_inline_pages()
>> > (unchanged since the initial git import) and unx_validate() has writte=
n
>> > the shared rpc_auth's slack from the reply verifier since at least
>> > v2.6.32, so there is no commit that introduced this.
>> >
>> >  net/sunrpc/xdr.c | 3 +++
>> >  1 file changed, 3 insertions(+)
>> >
>> > diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
>> > index fa6a30b..f77dbdb 100644
>> > --- a/net/sunrpc/xdr.c
>> > +++ b/net/sunrpc/xdr.c
>> > @@ -409,6 +409,9 @@ xdr_inline_pages(struct xdr_buf *xdr, unsigned int=
 offset,
>> >       char *buf =3D (char *)head->iov_base;
>> >       unsigned int buflen =3D head->iov_len;
>> >
>> > +     if (offset > buflen)
>> > +             offset =3D buflen;
>> > +
>> >       head->iov_len  =3D offset;
>> >
>> >       xdr->pages =3D pages;
>> >
>> > base-commit: a4ff2be345d0abc943da8dd8da98151843b750dc
>> > --
>> > 2.50.1 (Apple Git-155)
