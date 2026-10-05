Received: from mail-oi1-f175.google.com (mail-oi1-f175.google.com [209.85.167.175])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D3E1F4AD4B8
	for <linux-nfs@vger.kernel.org>; Mon,  5 Oct 2026 14:39:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.175
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791211163; cv=none; b=nFSi/GI3SlRvcau+uZU/XwLZVqscrUOM2jF/Q+lEyN3VAJnGaxl6gt5xJlMBK19NtmhVfkSBJyIaxMmue1S3WFGGfTsA9fcNrw5SQbMzI1bdv4QV5NChGBUoXA+cATitabJYdnEaqoTWorUbtODkem/lz+MxmiSC/k2+EgQo36E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791211163; c=relaxed/simple;
	bh=ynBIq+6WKuQjkK9m9g9FwjEcqZZMXFI9J3UGeE8k7bM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=uSW4VSL9c3BiMQ0LtdVOHfZLZN65IcllwMbYCrLxxkbiUsR0OzztH8aHrCZNp1O7a7PNukQ98ETz0GQAUns9ZFkri+s8nBPVUh+b2IvfjZHCsIExwNH+4IYV5jbWJz0uXbLfrqRMquSCdFusP2n8cNLbTH5ywAm8KqXdJS0naHw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=CmbXO5rf; arc=none smtp.client-ip=209.85.167.175
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="CmbXO5rf"
Received: by mail-oi1-f175.google.com with SMTP id 5614622812f47-4af173320f9so984615b6e.2
        for <linux-nfs@vger.kernel.org>; Mon, 05 Oct 2026 07:39:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791211155; x=1791815955; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=dTy8Wly+8kllS4uOidrj8YeCjxSqk21LH4O5zXhsADg=;
        b=CmbXO5rfEojXBZFd+NIjfheme3sFtzacprfQgAhN6IMEo1fFOA8JvRBGSyuvpwfasO
         JmEl5WzpSKL96J4Q9gyqm9WBLvNFYw8XTOfsIECxxnjtzLC+XkgNu8guJBTPWj3h0W+c
         W8Ph/H5k7g3ccuWR2dEdUm6y/QboaCektkENbVpdyiHXYp008O8+qStf/uA1mbOSDDXF
         edURv1I3851puq2nXnMLjXpVz6jH7FT5TUXBsz9/u6WaLJ/8yBZB1bPfwbonrRxHD5nO
         uQ6AxQniw/RkkfEuPbkuS+HVJj88fB0n4SQEHuuoLpXafo7W/EnttkCg96jkz/H3HdWM
         jquQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791211155; x=1791815955;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=dTy8Wly+8kllS4uOidrj8YeCjxSqk21LH4O5zXhsADg=;
        b=lUNkp0QTq0igoty6QB/S53NsJ/Xrnvo2tgkD/sti8jVU1Fbda/lyUjRTLQtknsdtUL
         UBHaVOxsLUgD7LhzLq0ybeZa1iNKHT5SZV99exON50dwaJKrYR9539hHEJPMycsRsw7z
         CBJ6Md/MYddM7SaiyD9BLliTDJ3bdMUYhsgQoDySHUfh/5fEBQjsuejo5Q0NLFcAyW6p
         sSAa/1xRs8SMIMNNBcQ16niEqlSttzguBQ44ewHDMkfoNoBLsn/FHKIuRJ/WCHcvKNys
         roUF9vLRI4Jb2yZTkRl7Wqunv0375iTsyGFfkd03zLXhFx9KIabrqvRYBduiqojAoKpz
         +pvw==
X-Forwarded-Encrypted: i=1; AKwUvBx7asOq3GBnkqBa3kBSQxf1YJElHHrCBKOTIaZr2FAFmyz580cx8XXxODe0QtrRRIsoffsgd6IJOWg=@vger.kernel.org
X-Gm-Message-State: AFuF++l70tUaiucAKkCXI5KdeB93AIhxdPHqZfHjiQBcISlwjLEcaHpM
	cV3CYi/WGCQRPzpPwNk0ExJVeyfr1+C9AMLpMqIQzOQhyoC4zLbm9al4rOSKt0wjx8c=
X-Gm-Gg: AYBFou3QFU08Y52e21c92wDJlBB0T3PwhF/JJaU9jNpgNyK1g2SD6mGye0f9v+FWjBH
	OBpkTG/7FiPcGGraWWRv78CYLrCg1x4ddnfBplpoZx+tSu1MNFDHGe5UCKyDguLtok3SmTqio7j
	xiO1pFGJTyaJkhqM+EVfp2wgaIP+1Srqv8ka7v4zjvFYpDYQ4SGbMHlq536PUgF3asON7POppNy
	W0RTG7+ZMyGLO1dRkBFcKM2L3TVJgwuQefGQlrp6Z/6IhO75ueKsSsCxtpLdVEpQZtdJvUj0XVg
	N3bz3+ae01ZeEU+SrxIjxGn1i3UME1e44hC29oix4DYqnCAmIGBrgICH2qzSUKcqrphrdxix4ai
	7Yek+5PSTOIf/TRRQoWkbDc17Loa4WiO1GEABo9zQ1r1cEXmLT3hy3Pv8U/RaOHThuoZ1U2z99R
	74ZoGNke2/n5HgMdaAWddOA2YIKNcmlMAmwwNR/GB0BY3sDzTIoUm2g4G9Ezt5q+Rrb9SlhCYVk
	bZSnxWJ2beCgavXnP4=
X-Received: by 2002:a05:6808:1395:b0:4c6:7ce9:1bf0 with SMTP id 5614622812f47-4f679ee36b2mr7036940b6e.20.1791211154818;
        Mon, 05 Oct 2026 07:39:14 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4f5249dc2e3sm9923990b6e.11.2026.10.05.07.39.13
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 05 Oct 2026 07:39:14 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Daire Byrne <daire@dneg.com>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC 0/2] SUNRPC: dispatch ready transports round-robin
 across clients
Date: Mon, 05 Oct 2026 10:39:12 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <447769D8-07C4-48D7-82E3-5C373C3428DC@hammerspace.com>
In-Reply-To: <CAPt2mGPTskN+JoEBQftKvW=LZnRQLRcGm+1o2iO1RqPQpQC4rw@mail.gmail.com>
References: <cover.1790953694.git.bcodding@hammerspace.com>
 <CAPt2mGPTskN+JoEBQftKvW=LZnRQLRcGm+1o2iO1RqPQpQC4rw@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 5 Oct 2026, at 8:18, Daire Byrne wrote:
> We use nconnect, set tcp_slot_table_entries=256 and use
> svc_rpc_per_connection_limit=4 in an attempt to allow for more
> requests in flight (NFSv3) and limit greedy clients.

Hey Daire - that limit is per connection, so a client's nconnect multiplies
it.  I suspect what you really want is the limit per client.  That isn't in
these patches, but with the svc_client added here there's an object to hang
it on.

> Now I understand that these patches don't affect the re-export
> server's connection to the upstream servers, but I am interested to
> see what effect they have on the re-export server's clients. If we can
> give a more equal share of requests to the clients does that in turn
> reduce the re-export server bottleneck? Do those greedy readers reduce
> their rops/s such that the re-export server doesn't flood the
> connection to the backend server with bulky read requests?

I don't think it will, or not by much.  All this changes is which client
gets the next free nfsd thread.  It never leaves a thread idle to hold a
client back, so if the readers are the only ones with requests queued they
still get every thread.  And a READ that's waiting on the source server
keeps its thread the whole time.  The readers only give something up when
another client has a request waiting for a thread.

So it depends where your GETATTRs and LOOKUPs are stuck.  If they're
waiting for an nfsd thread on the re-export server, this should help.  If
they already have a thread and are waiting in the NFS client behind the
READs going to the source server, it won't, and that sounds more like what
you're describing.

You can tell which if you can catch it happening.  On the re-export server
the sunrpc:svc_xprt_dequeue tracepoint prints qtime-us, which is how long
the connection waited for a thread.  And mountstats on the mount of the
source server splits GETATTR and LOOKUP into backlog wait and RTT.  If
qtime is small while the clients are suffering then these patches aren't
going to help.

> I was going to test the patches but I got as far as they don't apply
> cleanly to v7.2 and then got caught up in other things.

Sorry, the posted ones are on Chuck's nfsd-testing.  Here they are on v7.2:

  https://github.com/bcodding/linux.git nfsd-clientq-7.2

It's three commits on top of v7.2: the svc_clean_up_xprts() wake fix and
the two from this RFC.  That's the tree the numbers in the cover letter
came from.

Ben

