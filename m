Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1CA1634CFD0
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 14:42:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789137754; cv=none; b=HlpKoNPe1JCmzvj3RnRnH9MF+aodP9snLuni+bvX/X+uBaWKY+5MhRJDCui2QM22B9KIvikzcmMxornDKqVRnqARgkV3polYA/LTJKcziOlX37GHOGwwMMXR1kYedWwSC7gcPsJ0lmctF61wbHDOQy1fO9ITSYnSTw5EpJzdXjw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789137754; c=relaxed/simple;
	bh=EGgCsshfuDCrKeThEeIJoX/moOH6gxfaQRsjf0igk1w=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=dZj1S61pZByvHqGZwaS0YH36pYMJAWjiRH4hpF9aApfdt3790zJcKXf3vGuEJQUMPPgOryxnclyxnFvjOnCyodeYAXJblkckCm33OD5gah3uIo0GiX11JFgFhnnQs5oIxQf+VJb0nPlHEPoslPxtcP3ZjvNHokgXokPLo2cASUI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=di9gXzN4; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="di9gXzN4"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7FECA1F000FF;
	Fri, 11 Sep 2026 14:42:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789137752;
	bh=Am565XyNmbKWUvjW+npkDTEqJi/oWfkJ01amBFPdArA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=di9gXzN4f5RzqLCOLT9NvO24hJnH+m/Cp4JUx8RpaKmbWE7A5IKKx1CDZkC76dVdj
	 WwMK1FqqmsmjZ14V7EHqD+S1+6dk3R2f/sK1F8IbeMuNd5utZyybuIbYhTuTqmIkbZ
	 KwgADnCuJ8PPUJfiCG+6aPs50UJe1hoQPXSpF9yo8DuayV3ZbXN/Taves134ssMcdA
	 FgBwXj4wnxsyEHmOWmsD7v6uD1FERJC3uGLVk+wX34azzDWEElzBJgmxD9NIHl+YaG
	 mqB8VBxXcmRur0FmTrM2xEoorEFHBvI3BWr1b2synugdwaYguji2uSl/PA3BjnmqQv
	 /JzR/WDtLrd4w==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id BB529F40066;
	Fri, 11 Sep 2026 10:42:31 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 11 Sep 2026 10:42:31 -0400
X-ME-Sender: <xms:VxOkakvD9R4wFSP8b1z7pu9tMiRPhpDWA2esZEP2qXevzX-KhQDgCA>
    <xme:VxOkasRczOqW5a2ltUXvPY5YY4HRPd-IW91vVEoGVm7ZzV2Sl7d4qY7BTL4UwCPjj
    3f3Y97_sHBxBo7Ao_Gzg61bRHCmnqnkUWHihmtUUBsfaWrRxtVBfF0>
X-ME-Proxy-Cause: dmFkZTE2cjtoV0DIqNNgXUWyCncbg4bZLSovApzDGeDdpUylWfRUXxmS8VCQVLNa5RNHQk
    I1lUC01n32RvCtyyd7wL+bUTq1W3dDqA8cTVW7QIAgryISvcjMlKRh8S32cmGfEhrNZ67c
    AfODzapILalhmaCmiSkDw9XLdXJJcJ2dAu6X67/+gvfYKg2jlqSetwZJCaWh/SDJ4WSmF2
    dfjIMRV0YkDJB0/5wRL3pmMQr8S5fVjZDQSdsU3Vvzm4gBq+MGiq7grmmxhXZf5Qbx/RC2
    2THugWFRN51iMkDB5dg+ROMnbaT80Rb+xiPyPobbQngM0BawQgnrvfj/tJC6wlF1+UZJUp
    uJ6ByM5HIaZJae7X3JXneEgRiVhAOXP/UjXZd3wH27oqUUFAAP07viH/rTzTZAaL9oy2nX
    VD3anJBKYfTDimedXbyUgZq05FPlq1DSxJ53nVSvEXNcVmdlcPkbL/N1VLDSHyKJcvZeaO
    GqS9XSUE9gfqCCDr7fzh+jzcs4s+aU7Y0nFco7cJz6nPk4oQoTeMOq9hgykg8770S58iCx
    EIZublXdfdFUM5i5fXpzWF7SW1a2u1skSNsidpDvWtl3/0J8um6B75QMw4Dm3TJGoUZzS7
    Zu69IFnw++RElc0L3iyfU+7xuVdl+ABsFOrd7L4TKWKHF4mkxYR6W1mKjpRw
X-ME-Proxy: <xmx:VxOkamFsPqPK7E-lf5vEL9OTUUjmVKUNNhyvz_jOWimatXS96W3Z3w>
    <xmx:VxOkaoC5Di0ykZ12k-j3uqjC2nhB30LZb-Vwpo98F9J7eQTZqfTXIQ>
    <xmx:VxOkauXPorMc8Y-dmlMxJeK8mYZQMDcKnDdJqOehceNdFFGkZwA7rQ>
    <xmx:VxOkakqig1LeW6vngMV8vGS3s9UgwcT4Jd-6_SCNN9tMfyI3G5MlHg>
    <xmx:VxOkaiTx7KHnEjVcfva51wsZD-SnxfRJSiorpoIWDftwDbcR5BS04iId>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 944237811F0; Fri, 11 Sep 2026 10:42:31 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AJxlnPHrJ3iN
Date: Fri, 11 Sep 2026 10:42:08 -0400
From: "Chuck Lever" <cel@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org
Message-Id: <f5e4a7ef-43fb-4209-a2ef-34135c1333cb@slotpi15m67>
In-Reply-To: <178908135551.207413.11072935643340240963@noble.neil.brown.name>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
 <178908135551.207413.11072935643340240963@noble.neil.brown.name>
Subject: Re: [PATCH v3 00/12] Improve the scalability of NFSD's classic DRC
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 11 Sep 2026, NeilBrown wrote:
> On Thu, 10 Sep 2026, Chuck Lever wrote:
> > 1. The transport reports delivery outright where it can. TCP now
> >    reports when snd_una passes the reply's sequence number, and RDMA
> >    reports on each Send completion.
>
> As you note in the relevant patch, the TCP ack can arrive before the NFS
> client has seen the reply.  But I don't think you drop the cached reply
> immediately, so that probably don't matter.

Right. The ACK marks the entry, and the next prune of that bucket
evicts it.


> > 2. Where no report will come, a later request on the same connection
> >    stands in as an implied ACK, since a client on a live TCP or RDMA
> >    connection does not retransmit within it (RFC 1813 Section 4.5).
>
> I don't follow this.  Why would no report come?  TCP will always send
> and ACK.

The cover letter was unclear. TCP always ACKs, but svc_tcp_sendto()
does not always track the reply. The per-socket ring is fixed-size,
so a burst overflows it. A kTLS send that leaves part of the record
unsent is not recorded, and neither is a failed send. Each of those
is reported as untracked right away, so the DRC entry has no report
to wait for.

Implied ACK was meant to retire those entries early. Without it, an
untracked entry is handled the way every entry is handled today. The
untracked entries just sit in their buckets for the full two minutes,
lengthening each lookup that hashes there, which is the cost this
series set out to remove.


> And I don't read RFC 1813 4.5 as saying a client does NOT retransmit on
> a live connection, only that it DOES on a re-opened connection.
> I believe that when an NFS client gets a timeout (6 minutes on TCP?) it
> will resend without re-opening the TCP connection.

Section 4.5 says that a connection break with automatic reestablishment
requires duplicate request processing. I misread that as naming the only
way a duplicate reaches a server over a connection-oriented transport,
and then reasoned that a request arriving on a live connection could not
be one. Re-reading, I see that text supports no such exclusion. It only
gives one case that a DRC must handle, and says nothing about what a
client does while the connection remains healthy.


> And as you say it is possible (I would say "likely") that a client will
> have multiple requests outstanding.  Even multiple non-idempotent
> requests.  So I cannot see that a later request tells us anything about
> receiving an earlier reply.

Agreed.


> So I'm perplexed as to why point 2 is needed, or how it is justified.

With the explicit reports in place I expect implied ACK to fire
rarely: svcrdma reports every reply, and on TCP only a ring overflow
leaves a reply untracked. Shall I drop implied ACK from v4 of the
series, measure the untracked rate under load, and size the ring from
that instead?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
