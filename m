Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793396581;
	b=sgDveRBaF334PSdA1Gkze0oLb6jGebbKSz5TDLBQEF2/sIBplKhWkjSdksqmqWvDdAsp
	 VujDQ95yZdUz+Mdk+DbFUq+HfjSjhKUzpE0dHX+2gAwdwaslFigs10IGTf0czzyczr8ol
	 cIi/MPfKGsHKWS97coiOTOkSlES21TSvy8OzsJGOTkefHc5dwb66M3fwIJt0An9LLD8gx
	 IjeH0SGSqNoYW0t9gUR00kBLkrM5Wbixo2hU7Pbj2BJsL4op/x20uXMrgHIIs1gSMVd30
	 xX9PO9h6quMHJ7CGCvY006GDm5vl5M/KSEFg8s4rTIFc6i4I4gIbMId+iSk7yYQnjTA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793396581;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=Plypqu2Uu/AYvjD/t72oYOPZBCVo6UDUsF7g4kcekpA=;
	b=pzTtMrWwU9SpX+mgPjD5yNP6ugAj8L7YMe0OTeCcUok3Nf2Ixwho3Qprqk2yjzzfPiVJ
	 9F+Ro5eZKDa2OGdxrZ6IyGK1otElpdnFpD8aIDuA+a/+iNjB6cdgM6TnFiwO6pRUsUCyb
	 z3O0ZFdpUIizaZANRqjsdLBzd7dWIlpZiXIk8pxxvM+WXrDFGDIrnXdEX7PuwIrZlvG4l
	 h9S9dU91KXVB9xoQpZuBRXqDjQJcTSA82DDFdaeqxtw37i34BxRRA5Mzs+GJWFWMSRGT5
	 38aAUXLOsDHgtp9wLmQqj8uHeQgFJ2ZCg3bylMnnlPibH65q2XAnQk4P7bdBVytV5tA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Z7RM7JSD;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9557B606A31C;
	Fri, 30 Oct 2026 21:43:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Z7RM7JSD
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5CAB01F0093A;
	Fri, 30 Oct 2026 21:43:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793396581;
	bh=Plypqu2Uu/AYvjD/t72oYOPZBCVo6UDUsF7g4kcekpA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=Z7RM7JSDQvidV8bzbUum/xvlsIUoS7VV3XJI/4+FxKr/1KUmpmYoCa1xsd+RRPSuO
	 29QWAEJK9oQWfIqznhodaJ5QH+Eaz6EUkD6RszlRdnxDfoJ+/HHo5f41qf+M38cumJ
	 mXrkpAbMLoLYpBE958MiW4KGcy50U0Z+/nK7X9MzDH9JNZ2WYr+MCAT+hswa5VyBmR
	 XQeLNIvQGWCJSY9dwIi8hRGhItBtwhdpndu4ngzICWBmcJbbBEN2HMD5sBeDA6jvaL
	 5HUZBvCqf3pozESakSbvyb1dZRlzvAWAqN+Hb2iouKNGhLIEM93R5ODYgtQxxFYzC9
	 hchEKP07Z7UKg==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Shuangpeng Bai <shuangpeng.kernel@gmail.com>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Lorenzo Bianconi <lorenzo@kernel.org>,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Subject: Re: [PATCH v2] nfsd: pin the module while a server exists
Date: Fri, 30 Oct 2026 17:42:57 -0400
Message-ID: <179339657125.1233826.8770399038318929234.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261029181006.1305530-1-shuangpeng.kernel@gmail.com>
References: <20261029181006.1305530-1-shuangpeng.kernel@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Thu, 29 Oct 2026 14:10:05 -0400, Shuangpeng Bai wrote:
> Since commit 924f4fb003ba ("NFSD: convert write_threads to netlink
> command") the server can be started over netlink without mounting the
> nfsd filesystem. But that mount was the only thing pinning the module
> while a server exists (commit f49169c97fce ("NFSD: Remove
> svc_serv_ops::svo_module") removed the per-thread reference).
> 
> So when the server has been started via netlink, a plain "rmmod nfsd"
> succeeds while the threads are still running. exit_nfsd() then frees
> struct nfsd_net in unregister_pernet_subsys(), destroys the DRC slab
> and finally unmaps the module text underneath the running threads:
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: pin the module while a server exists
      commit: d9130c9f6535392d423351ffb5521e7689cae6b6

--
Chuck Lever

