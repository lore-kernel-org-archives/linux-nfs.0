Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792671762;
	b=k7KICwHIrYyT2eqZZ/UC+bOg3U7uG5vH6LMBj/z+kVJmcbATdvBxpG3R+JrSMzaSAL4v
	 uUIixNzRQExBkKPloo0UtL1gnahfhz7RzjCMYf5baz2z+PFymkMyOB2+F3slJeWvwP9DK
	 NLyqMDTTEpy5gdPrW3IDiMehkz4kaH5kUehbm+MvgUFz0xDvJz9xtcJDzH1Et8QbrE2ZG
	 PmUtWQcXLGeNKQNM4HXuHE2xQ9W3Y8wGgjWcOsxoRyo0qc21SReJ4PbTWy/fOuAkpZEjE
	 +gQJFFte/gWcsnRgkgj4eq9mv8YOJPZ5vlRcey6zR29koGE57x8JBMR9RKLqDwHy7vw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792671762;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=lL31NV31uswmFcMG4uuUkHmQjZyahNmfA5NSd7S2PCE=;
	b=yGEVtYziSsYQIfppUSx/M2ZrGcNPInDFFXgAFWa8EnxvdS/Co12pn9pzuXN8/saJwimb
	 AYyE3ECpmQZbsP5LY2ZYLdDWnZG9gBi5+eFts3i8HVVg5nGIW6vwiJcyJLeG6NeXqddmy
	 v8AvLwd2ttOhey1JFnJnzPXoznLX2/eNDLXOnfVSq9j4PvQzY9eK8My8jORF9jqtOMHVH
	 TItacNiqtTFTS5fsvK8tV/E2c6Q+0QQ5MKnnl7F3tOTtcmNqDrWRBeOyvnYQiqh7jq3aQ
	 oidIi9RL8Vz/A9Vz5H2g/Lz3wL26c38cRPcdqEAjNqF77An1Q8WHx/0RkRtY9acaE+g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Bt0jWbiz;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B4B25606A330;
	Thu, 22 Oct 2026 12:22:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Bt0jWbiz
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 69F3D1F000C8;
	Thu, 22 Oct 2026 12:22:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792671761;
	bh=lL31NV31uswmFcMG4uuUkHmQjZyahNmfA5NSd7S2PCE=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Bt0jWbizqx66731kLA6kosw5my+SlsB/HO8xOpeR3vZEp39NxsXpl8DESXCe7H9Hn
	 JTaeZkqkkt69uyt7SwCyzy88aEo/W2K8nbpsC8cCd/j662Xsn48Xric4mMspRIqBJz
	 63Tb6hkvaNNKQEXghIMoPUHVmTTQ3G1Gfk60jwr6H88obzgjk2UL+cXGzCihJqGjZo
	 TKKgLOCqwUUBLJTnEyYvidFFqrUQ6FuIkolNyumv96enHU+5CiIGxiI5u+V7ZH0N+3
	 oA4/nN5M77GBybn6yacx8sHvnIyBsv3ijZwV4B3PabBCu5pzrgzs/lCvNFFy2c7Spo
	 MBVV4I01ymxEw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A6318F40066;
	Thu, 22 Oct 2026 08:22:40 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 22 Oct 2026 08:22:40 -0400
X-ME-Sender: <xms:EADaaqo4P5HBSsoNBgXPIudVHkM40F8o3QPUBTZrV9j6H6BwiCvnmA>
    <xme:EADaajewGikZPo64jHwVqJ-bfg96T1gskx5ifsdUTaHBtkpiXCh6IIRhOlpjkw2VA
    kmx0_u5a0RqL_HumYw1QTN5uTk8rZk7g2ZY8daAqiGyai4lCFOb0dSg>
X-ME-Proxy-Cause: dmFkZTE3Fpze23TlqyVGyIy3s5PLt5OWXDy2UHCpyIE5k6lPzEIPomiBsHPATLF2K1H1Hd
    18SnlC+P96utND4XNW8QhOm18ZzRAcjg8CyAXuQhZLsHbQ5l3RS7x9D+rBYGBsBZRdsWH8
    /+InIJuZqt1on3Keyt0g6cFzrK977OTPXZycnLgTK373M5uaM1IcDeEWvQwuwlH1tPyN1o
    rNlw4u5yzp6BQEF7SSFFvkzqOPB3mfCLS/E1MqC5N0eYaYfKctZl0HDbpSP77OyLKNIEob
    c7X/iKNQ6EJqB6zwrNTuXHpe3mgFLrmI6sZ5tGQWW13WZBnieG1IiBHwaNoHR6t+pcRMb2
    8hVOp2+EAczRf/hbBvVV1LPK2dJW0NWDpkU9oqE7do8UQWYqU0LHH0mMGP51K+J5IjF5Fv
    MuTQh5CIOJ7HWWu8Bia5oY5cwyc6zWJV2lCDA348r12KL90wh+ja+INtnB90hkZSNZ0Hco
    TOk5hvFohtP/ulks6Af13LFag2HMpfCQNUWHv4jG4tXXAnXeRnVQEseRUxzdBd28KB2KEg
    axArrD03vbz7QQhRxusooSQ55fCt78F8sqSV5tODL24PEhsGxxsUXyDxTFw9LKuayY+veM
    kCb6QdJsMtsttBYRbNmUbxFAc+8h2qXeJ/Gq6sb88eUlajTO+FUOQJzedK4A
X-ME-Proxy: <xmx:EADaapN_PmoHOmf9UNR0fY0WRns62xO1e8mq0kzAPS7PqX21sUoT8A>
    <xmx:EADaatigbKtdPJSrw-bQE739vn6sABgaIyoB5B4dAYWu8niEvwWnhg>
    <xmx:EADaangibXOc70IRgrN3AyhJopla7ssf5dpdRd09ASTFNgUwAdn5wg>
    <xmx:EADaasJODjQ5vnn1TtRk15rwv2WTpd3IVpEYK0Xr2ELx20UxP6UE-w>
    <xmx:EADaamniSqU9BHobPa5tOa0mgiLLjABXDk3vl6Wh6mYR6ORTlUf3tHEq>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 84B50782738; Thu, 22 Oct 2026 08:22:40 -0400 (EDT)
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
X-ThreadId: Ag9yIq03xO8V
Date: Thu, 22 Oct 2026 08:22:20 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Giorgi Kobakhia" <gkobakhi@asu.edu>, "Jeff Layton" <jlayton@kernel.org>
Cc: NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Xiang Mei" <xmei5@asu.edu>, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org
Message-Id: <d8952be8-7ee8-4c57-aea3-9f19011b377f@app.fastmail.com>
In-Reply-To: <20261021203817.3898293-1-gkobakhi@asu.edu>
References: <20261021203817.3898293-1-gkobakhi@asu.edu>
Subject: Re: [PATCH] svcrdma: bound check rc_curpage in svc_rdma_build_read_segment
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Oct 21, 2026, at 4:38 PM, Giorgi Kobakhia wrote:
> The existing guard in the end of loop is not enough for bounding
> rc_curpage, because it only checks if some part of the chunk goes beyond
> the rq_maxpages.
>
>     if (len && ((head->rc_curpage + 1) > rqstp->rq_maxpages))
> 	goto out_put;
>
> If the chunk exactly fills up the pages, then len is 0, guard is skipped
> and the next chunk makes head->rc_curpage go over rq_maxpages.
>
> Commit 81381d1a90de ("svcrdma: Adjust the number of entries in
> svc_rdma_recv_ctxt::rc_pages") made OOB accessible, since it
> shrunk the rc_pages array size to rc_maxpages.
>
> Commit d1bea0ce35b6 ("svcrdma: bound check rq_pages index in inline
> path") added a loop-top "rc_curpage >= rq_maxpages" guard in nearby
> function svc_rdma_copy_inline_range(). The same check would guard it in
> svc_rdma_build_read_segment().
>
> OOB write is triggered in svc_rdma_process_read_list():
>
>  BUG: KASAN: slab-out-of-bounds in svc_rdma_process_read_list
>         (svc_rdma_rw.c:1148 svc_rdma_rw.c:1197)
>  Write of size 8
>
>  Call Trace:
>   svc_rdma_process_read_list (svc_rdma_rw.c:1148 svc_rdma_rw.c:1197)
>   svc_rdma_recvfrom (net/sunrpc/xprtrdma/svc_rdma_recvfrom.c:1022)
>   svc_recv (net/sunrpc/svc_xprt.c:870 net/sunrpc/svc_xprt.c:968)
>   nfsd (fs/nfsd/nfssvc.c:919)
>
> Add bound check for rc_curpage in the beginning of the loop.
>
> Fixes: 81381d1a90de ("svcrdma: Adjust the number of entries in 
> svc_rdma_recv_ctxt::rc_pages")
> Cc: stable@vger.kernel.org
> Assisted-by: LLM
> Tested-by: Xiang Mei <xmei5@asu.edu>
> Signed-off-by: Giorgi Kobakhia <gkobakhi@asu.edu>

Commit 4e84914d70a0 "svcrdma: account for inline bytes in Read chunk page
budget" in the nfsd-testing branch already carries this guard and addresses
the same KASAN report. Thanks for the independent confirmation.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
