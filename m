Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8767E552922
	for <linux-nfs@vger.kernel.org>; Thu, 17 Sep 2026 13:50:29 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789653034; cv=none; b=hHwWCGJ/3Shbn7Vqm30GIMw8sTNiKsSLw7olAI9TlvcWApQHuneFipHDyKajEl5VK0sd+1Tj5KlOucdjYhMthr5aWcMNoRJMltuQoUTmaDJI/5yA8hqPOMiByHH0uVM08mmnKwofcrDZd09YZxtf1EIyofsSb7g3sLv6PUMudq0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789653034; c=relaxed/simple;
	bh=rHPlkZq8QcUlcXZ95UpE62wzPJOMFcq9wd+pUL1ocmQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=c/zI71zoAAQpl4Y8ssiDdeqhN13HOuXN21NSkg/Qc+utVL5rTwOmyj2oODEX8eYYZ1XNynW8yLrMBJOKq1sTvgqP5RMiUw6zgilRKgiilIXeVc+eoYDd7dwT+K8WCTmw3HCFnoxPcUZH+QdBvPCu6kOqCcia7mAbJZ4wleugCXk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JODIuAeR; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JODIuAeR"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4AD0D1F00893;
	Thu, 17 Sep 2026 13:50:28 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789653028;
	bh=7VGadqoDro2Vuq8v7rDZVtvL7j39zo1OAHVttGXcDZw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=JODIuAeROk7LvipUYjMLS3zBtlaO5JUCAP362f6d/berratThR0fannh5iT0kVyEo
	 3wvwxYcmvSKFI/Ltpb0GC8hldei2dkPjTAVEKrx3OCoDv+DcqO9PGD0d6/TNEQuP5M
	 6BAlaka6oIdn1vhRzI+LRUnAnml5sFhZ//qu8ol9++tVVutE8Tufh6MqLiwCOW3lAB
	 HlJrD/r6dKEtVfan9j0zSj+07gMLFd+WhrfCZYdCwWn4vfndKX6GY4SUn/mJUprNTF
	 OGbBKRINToU3wSq9KC0RUvC8TA5OVswTp4hr/1F591hd0/vOPHRKS26jIC+RPlEXQ1
	 +50Z+sAXVxNTA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 64538F40066;
	Thu, 17 Sep 2026 09:50:27 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 17 Sep 2026 09:50:27 -0400
X-ME-Sender: <xms:I_Crarhk6toSpcoKOzeqUnjmUOJjvebhP1tUzhSHZaX8I-EcApesDw>
    <xme:I_Crai0GeRGKI55x1Fj3YGXnIniQWs5cFSPZrpCDABu85ojBwIst2GyLdcyCuMBwK
    WPnHT04CUHce8wCQYSw05z7eLMgJMwrZEn_zPJMaVswsqUf-gd-p0Yw>
X-ME-Proxy-Cause: dmFkZTGbv4BjqDEZH4LmsvRoCU7w++Gb6N4eKYd0gPPlrLJd2U7e1W6Sm+hPFrTp/Drr34
    k7NWipfOQ2MK6YZQ9hcdzGjPejZ2TqsovaUyO2h0/tgaWOFuRZowuP3cGkmykJ2pkN+z+i
    HM+GGKzagpw7dZtL4aQAZX4I6uI68nRT1NGexdHQU6m/Im7rGxWaVrvctc0giIQs2YKan1
    Xc23GDZewGSYfl+BMyW5vJdqWwoEm0JpFIXVz+El69A5HduXQjMULfPOmxdTOx7L1EcVX/
    CVlj9+P37du8/Ju6TMa4GJasAsh16WQenLX0FfeHZ2Cd3YQPeWBe4oeeoym3b1kwpOrGLC
    WhgXAK5de30l/Y0VpYD4plOkEcTIJKgosyeJ+l7OkhoEVmkzen+ytkc/F7swAuDu0/lK/v
    IJM5rikuTil5B5NBRqfhpQ9iHDiX8mjIy+ARH5I812mrrEU6YsswQRapnRFDkF1b/HwUop
    6ZmwOYqvkwNAj7Fxdf+xLWikrE4nN7Y32zwJQkduaGZ/4hH0/G/pLKsRY22Tzt4SukTWTT
    8A+OafK6A8q6JAFuhBwsyHd58WP8Stef1XQYBZig7hGSbnYCFeVLjvGsxdgvQxrGXCBOt1
    e3UfJ6F/8scqKcT1ElDUJZdLYqFu9Ak1TqZGoGxzS3LY0xsFn510599RlT1g
X-ME-Proxy: <xmx:I_CratihTnFC6uus25JkY4R98QVXcysGdSrWGUcvoPa-L760s5hgLA>
    <xmx:I_Cras8XM_ZRePCm8ol2eNnxruVjBtMnyKn0BBltDXt0NHB47-if1A>
    <xmx:I_CrasGTAT4gYyUPfnJ-k1rkvj9B6Y3D3vJ0WcgH5ZAEWNV63Vdc6A>
    <xmx:I_CranlTJWSn5MQYi5P62Ps6YH0iyTfi8UkQC4In8YdShAheIramZg>
    <xmx:I_CraoYcs_niGvx_g9aycVrz1onVx8tJuF5Pyp2ZLxpJMR_XU2mJk9Qo>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 3FF38780075; Thu, 17 Sep 2026 09:50:27 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Az0uTlCllO7k
Date: Thu, 17 Sep 2026 09:50:00 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Roland Mainz" <roland.mainz@nrubsig.org>,
 "ms-nfs41-client-devel@lists.sourceforge.net" <ms-nfs41-client-devel@lists.sourceforge.net>,
 "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Cc: "Rick Macklem" <rick.macklem@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>
Message-Id: <ea3ec60c-18a1-4643-ade0-c4a004cb2ac3@app.fastmail.com>
In-Reply-To: 
 <CAKAoaQnTria60yM=zYQAe+dZti0ZvCfja0V+Y0F=Qu1h+hXGAA@mail.gmail.com>
References: 
 <CAKAoaQnTria60yM=zYQAe+dZti0ZvCfja0V+Y0F=Qu1h+hXGAA@mail.gmail.com>
Subject: Re: Need NFSv4.1 "WANT_DELEGATION" op ...
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Sep 16, 2026, at 7:57 PM, Roland Mainz wrote:
> Hi!
>
> ----
>
> We're experimenting with a delegation-driven client-side
> consitency+caching model for the ms-nfs41-client Windows NFSV4.2
> client a while now.
>
> The original idea was to have two modes:
> - Mode 1: Get delegations (read delegations for accessing data
> read-only, write delegations for accessing data [a]) at OPEN time, and
> return the delegation when the file handle gets closed ([b]). The
> client only does buffering+caching if it has a delegation.
> - Model 2:  Do not request a delegation at file open/creation, instead
> translate Win32 oplocks into WANT_DELEGATION+DELEGRETURN. The client
> only does buffering+caching if it has a delegation. Server-side
> revocation of the delegation triggers an oplock break, releasing the
> oplock from the Win32 side just returns the delegation. This is
> basically how Win32 oplocks work on the SMB level.
>
> But in real life there are problems:
> - "Mode 1" only worked for small testcases. Real Windows applications
> typically change filehandle attributes or change ACLs after creating a
> file, which results in server-side delegation recall triggered by a
> NFS SETATTR, and after that we do not have a delegation. And there is
> no WANT_DELEGATION op support in Linux+FreeBSD nfsd to get a
> delegation back. Which typically means write delegations not being
> enabled and therefore no client-side buffering/caching.
> - "Mode 2" does not work because Linux+FreeBSD nfsd does not implement
> WANT_DELEGATION to implement this "on-demand delegation" model.
>
> Or short: For "mode 1" or "mode 2" to work we need the NFSV4.1
> operation "WANT_DELEGATION" to work, at least in syncronous mode (e.g.
> no CB_PUSH_DELEG support needed for now [c]).
>
> @Chuck Lever What do you think ?

Roland, thanks for raising the question here.

Playing devil's advocate for a moment. Since 2010, when RFC 5661
was published, no other client implementer has requested a server
implementation of the WANT_DELEGATION operation. That suggests:

- POSIX clients might have a hard time making use of it
- There are one or more flaws with its specification
- It might not add any benefit for real world workloads
- It might be possible to work around the lack of a
  WANT_DELEGATION operation using OPEN

I don't have any evidence of the challenges or benefits, but
these are admittedly open questions. And note:

- There is no testing infrastructure, currently
- As you found out, Wireshark does not yet implement a decoder
- Notably the Solaris NFS server also does not implement it

Even in the simpler synchronous-only mode, it's a heap of work.

I'd like to hear from POSIX client implementers. Have you
considered implementing WANT_DELEGATION, but found the
specification wanting, or is there some challenge to
introducing the plumbing in your client? I'd like to understand,
practically speaking, if WANT_DELEGATION itself is conceptually
flawed, before diving in. We'd be the first to attempt an
implementation of it.


> Why is WANT_DELEGATION an "optional" operation in NFSv4.1?

I didn't perform a deep search of pre-2010 items in the archive
of nfsv4@ietf.org, but RFC 8881 does give indications about why
WANT_DELEGATION is OPTIONAL.

- Minor-versioning rule 12: a minor version must not introduce
  REQUIRED new features except infrastructural ones.
  WANT_DELEGATION is new in 4.1 and is not infrastructural, so
  it cannot be REQUIRED.

- Feature-to-operation mapping: "For the NFSv4.1 features that
  are OPTIONAL, the operations that support those features are
  OPTIONAL, and the server would return NFS4ERR_NOTSUPP."

Underneath that is the older NFSv4 principle that delegations
are always at the server's discretion. Section 10.4 says "Making
a delegation is up to the server, and clients should not assume
that any particular OPEN either will or will not result in an
OPEN delegation". Section 10.4.7 restates it for this operation:
"servers MAY provide delegations separate from open, via the
OPTIONAL WANT_DELEGATION operation". A server that never grants
delegations has nothing to implement here, so mandating the
operation would be pointless.

The RFC treats the absence of WANT_DELEGATION as a normal case
with a fallback. Section 10.2.1 notes that "since the server is
not required to support this operation," a client reclaiming a
delegation with no associated open can instead use a dummy OPEN
with CLAIM_PREVIOUS and then CLOSE it (rfc8881.txt:9596).

So the protocol was deliberately designed so that everything
WANT_DELEGATION does can be approximated with OPEN, which is
why it sits on the OPTIONAL side of the line rather than being
treated as infrastructure like sessions and RECLAIM_COMPLETE.

It doesn't look like an oversight to me.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
