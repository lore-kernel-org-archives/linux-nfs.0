Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793130201;
	b=0pGGTTIMrxfkW71yHZBryAnPkRBegmPPKVtn7OA865bab9Q8x+cGV6HiaUeohRA60te9
	 ghJm2YeEcXU+yH9Bi26/TmL48E2r/IYZKTs8ATZO+jig0M7EDIiz+8RNuWLJCSwkZDP6S
	 6v9Ze2v9fGmmaZsMSC9DL4nitX50ohkFzwU+6QG/eEFbzOJoQDHxu8tL3v9IpfgoDMgxV
	 4piyv+Bz3J6rb0kkQGQsGeU+Xk9RF2/NSO0FZzy2bRXM+TkmBEIuHqHtY9koG8nAPB+9b
	 YFlzIFF9ZfnxmCJVA9K2W/gxWy1xz+EAP+hLldpJ9/N54HAxjA87l6QG/Z6rFe/xJ3w==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793130201;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=YUdXRkUnmyKckbiCSZwqIfvpA2XsvLBQukrw69VFn8k=;
	b=UFueBm+kI3X7fKRpCPtWyrutt9jYjI+pZbR2DhKY+pBYzZpzQ9Vfcnf3Vtypke/Se0sK
	 R/BozEK5JEK18vPtgI/PykYNThM8dVI8N4oCirR7keRfYNlN61WyKFen5uMTGVqJrFVwA
	 6iDoArhN0T12CjKS9eiye9zwPNqDPqcPsc/TDv1G+swioPfiVCB1uhPVivndtlq9aOgxt
	 XI6Ki42bHJvC9FeJs9hVCNeAcpEHhQN1cTOEyltK6HTI5mwYD+RTNHBIRCk3/ICRKXU8s
	 IDDKkrPReWEnGnfj28XNNmazDxhVZijDFpXommUscdTJo4Wiwi7F2ATYHNf8tX/f4xA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aSVUPSSp;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FDC3606A321;
	Tue, 27 Oct 2026 19:43:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=aSVUPSSp
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 160F41F01825;
	Tue, 27 Oct 2026 19:43:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793130201;
	bh=YUdXRkUnmyKckbiCSZwqIfvpA2XsvLBQukrw69VFn8k=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=aSVUPSSpD8YYKL3w5fYEwwh2CHkbnG9Ad9EKbZm2agZYdtTzE8PoK6jJb8QQi88Bc
	 FgFSEyQ0xLIRap3kZXGJb++B4PbBVt0hSRiWOydgpyuEdUHrE1ihniqaWRMbsPSqhj
	 Nkn4QGJoUKu5YfwM+1Sudw4rWzMrCAiXsyWaC5LgeOnpif91cS8SH+OpMUSYFZCa6v
	 ohGu994aEAIVr8+5shMbTdyyP0KGMhwHmFzO6S1gN9JrmMVYDGzF1uxx52X0wV3h8u
	 MDMfvPiR2O/C0PKNtQPHfAP6YEkyODUUwUL/V5/scGKuC3Lwc5znyZMQac4+yh9+G4
	 lxN5KAPaAbCFw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 63F10F40066;
	Tue, 27 Oct 2026 15:43:19 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 27 Oct 2026 15:43:19 -0400
X-ME-Sender: <xms:1_7garR6_ii-3JqWAxkLfgp5COynTZHd7NgkE9vlTTdZ0Xw9BgszwA>
    <xme:1_7gannKFijXN3WLc-ZZqIXqDfnNxdHxcistzuczVINnBEJedfTn3iADgs0lJmz_3
    -dQF97cbBUnS911gI06Z55C9P0TsM4SqCpfzVsJg7jeLCqydIOEHAUN>
X-ME-Proxy-Cause: dmFkZTFHp4xcxxMGOXbqjTEmsIzphxytrdzKnRuUsJ4q1xJ6tc++wD0Px1pkG595opi4L2
    in5nosoMgjjhZ9i/1O7VORgeIhchpg2tC8i1KNVutWlZAR6WfIXTZJP7TWh+OoRRnYAqRg
    PikNACcGZ79jBKMoYKn3ZESzcV7SDOfCGSffPtkcgLyuWbLsLlzS5neArTXHUypsRrC5kh
    cdCFNjvb0qjKpalrMDPrB7zVZYeAksYVn0oIQoTbs/UqYnTkJPtJeyjmbi5hLHiQVlTTne
    c/KZFYQF1LJ5ibZkZNEEK1eZ/BMW9E5f8+RoorcD2LjRzUuIIBWyh+wC+qbuA47WXBJljc
    d12wCgK73jQWU/CEUMI+dRWFIYn8JL5eFMDQjTEUl9ue62crxyyrq3LV5sA7NMmm8HXF4s
    78Ka2Rqsy7c7lOYOW6xRJepzD5g9U25ATjvKr1u7r+c4uEY7Z/4wHTOON+yrz4CgVzqDQD
    vRRzhEdVGoq5UiHXNCkzOfsW0axVPB3VncqtOlJ5dn2v6MWR2bIgnLUQC3qDfwQmskZKrx
    th7hExcwzQ6CC3IPLK153hQY/8fLQw5fx/lsq4HQi+oVaM93LPp34msqG8ykY1jhKADIrx
    GJ3DJFT5UB9zWwJgvXumdaeMtAfSIJzVC+Ga08JmhsQt2QvmFxppVYS4mgwQ
X-ME-Proxy: <xmx:1_7gagC4oYKjkSOGsyJVZW5Q3JBuTBQ3mtz-QETsvBmpDpF9UZJM5w>
    <xmx:1_7gavuuY6CkskkVRsxgCjcw3GC9CJ3VrkGuZxso-h80drx3_7lSJA>
    <xmx:1_7gaoF7wsqnDxxUAt9IodNUzHOsDdJ-g9nzHbv9ISzWU-uB2xUrnQ>
    <xmx:1_7gai-Ded41_BKqj3Hnyc6REhnBGx_DiyNLZpjvcUO1765dt8xmng>
    <xmx:1_7gamP6rv05RdNy_6yx8Edf4Go4Pqngd0zqvKqukN4lCQQe1gR5FSxa>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 2DCB578273B; Tue, 27 Oct 2026 15:43:19 -0400 (EDT)
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
X-ThreadId: AGB9D7c4hmNR
Date: Tue, 27 Oct 2026 15:42:59 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Jonathan Corbet" <corbet@lwn.net>, "Shuah Khan" <skhan@linuxfoundation.org>,
 "Randy Dunlap" <rdunlap@infradead.org>, "Mike Snitzer" <snitzer@kernel.org>,
 "Donald Hunter" <donald.hunter@gmail.com>,
 "Jakub Kicinski" <kuba@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@kernel.org>, "Paolo Abeni" <pabeni@redhat.com>,
 "Simon Horman" <horms@kernel.org>, "Steve Dickson" <steved@redhat.com>,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-doc@vger.kernel.org
Message-Id: <7b76322b-9d67-4479-a389-f982a6f4a17a@app.fastmail.com>
In-Reply-To: <31238159b7a4753e0a10c9f8b9fdecc4b92fb2f5.camel@kernel.org>
References: <20261027-export-iomode-v1-0-262ed932a036@kernel.org>
 <20261027-export-iomode-v1-2-262ed932a036@kernel.org>
 <ad5ac019-34ac-4c7f-8b90-cde8a0dc0546@slotpi15m67>
 <31238159b7a4753e0a10c9f8b9fdecc4b92fb2f5.camel@kernel.org>
Subject: Re: [PATCH 2/6] NFSD: Apply per-export I/O modes to READ and WRITE
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Oct 27, 2026, at 1:59 PM, Jeff Layton wrote:
> On Tue, 2026-10-27 at 13:54 -0400, Chuck Lever wrote:
>> On 10/27/26 12:45 PM, Jeff Layton wrote:
>> > Resolve each export's effective I/O mode (explicit setting, else the
>> > global io_cache_read/write knob) in nfsd_iter_read and nfsd_vfs_write,
>> > and skip splice for reads on exports whose effective read mode is not
>> > buffered. Update the debugfs knob comments to match.
>> 
>> [ ... ]
>> 
>> > -	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp))
>> > +	if (file->f_op->splice_read && nfsd_read_splice_ok(rqstp) &&
>> > +	    nfsd_read_iomode(fhp->fh_export) == NFSD_IO_BUFFERED)
>> >  		err = nfsd_splice_read(rqstp, fhp, file, offset, count, eof);
>> 
>> nfsd_io_cache_read_set() still sets nfsd_disable_splice_read whenever
>> the global knob is switched to dontcache or direct, so
>> nfsd_read_splice_ok() returns false before this per-export test is
>> reached. An export pinned to riomode=buffered on such a server never
>> gets splice; it falls through to nfsd_iter_read() and does vector
>> buffered reads. The same applies to the splice_ok decisions in
>> nfsd4_encode_read() and nfsd4_encode_read_plus_data().
>> 
>> Patch 3/6 says an explicit per-export setting pins that export's
>> IO mode "regardless of the global knob", and that isn't quite true
>> now for the buffered case.
>> 
>> I need to think carefully about the interaction between the "disable
>> splice" setting, which is global, and the per-export I/O setting.
>> 
>
> Maybe disable_splice should be an export option of its own? It seems
> like that should be doable.

That would be easy to implement, but I wonder if it's something we want
to carry as a permanent extension of the export options API.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
