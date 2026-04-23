Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 250F132142B
	for <linux-nfs@vger.kernel.org>; Thu, 23 Apr 2026 16:45:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1776962748; cv=none; b=gIfUNfBU8JPU2QnxUvThFA5QW0IpI8RmoixX7b9dKC98K7hfoeCcVuP1nzjyhbYVfl4dwp386Folj/pz6Bdy9twqkAulJP7G3CqNkU8AXMp+3DrKILJZNG1K6P6lJPjWkfrDX1VkwVMfnET92Dr20NsOB+5OBbbVREMm81mZx54=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1776962748; c=relaxed/simple;
	bh=AImhaNnASHIbsJLo8jWuk/8cvVa6CWPu4Dee3FbALcQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=Kw6kihe8Rn/kpX5yR5eBVyeWmW4hkObR1SMfGksYTk6+Zkps8niPo8ZHRjhmwRS7ols0LBlBEbogvPZtqwwWi12Pcsma3cwVMsXhNpzxrHiAcIFcDxdRx4OXEEHrO4n/UjnzotwDP2bDisBd5lhupd1XicOnEzSolpUPK9N5kbw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DHPekRmn; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DHPekRmn"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7FDE2C2BCB4;
	Thu, 23 Apr 2026 16:45:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1776962747;
	bh=AImhaNnASHIbsJLo8jWuk/8cvVa6CWPu4Dee3FbALcQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=DHPekRmnPscpDaNCQvh0Vi7mW2BdOHZrmW5h34Sx0vYZ5v1dPF+rDLglhNNgGwULb
	 9pvwIWBiOMaoq1FeEd7jzOFqmoIBsh+dZr51DO/V7I2X1Tpfmg5VTKYBAWEGHbV32m
	 w4zVm/1c+CX4zw0bxMRCST+sxCZF1NlHqWMyXjR1QFguoWKIe6DNtXWuyJizqAh1+J
	 xtYkpxNJgrqjEH8cNpWEpqfnKMGjqVDowUq1Dd+YDusihtBmX0UvCKF9L34I1Kch2C
	 khx2AHRjKN5DmLVdRSkYN1quv6G/LiLnchMUUjUZ6C/5z7drqSQrwvvDbFgvhwJa5y
	 xizZel6vTTj7Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 70140F4006B;
	Thu, 23 Apr 2026 12:45:46 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 23 Apr 2026 12:45:46 -0400
X-ME-Sender: <xms:ukzqablX9jAY63Ej8yPi6oTQiBVrxrQpi-hx-9Iya3OiKwql2xW5OQ>
    <xme:ukzqaZpjzlMpb1VZJ3ZcsYoepqNuysDpdAZNRZGOewyYuur_y6yLtoIzAdC-SYujS
    S1CnejFSzO2ns-YxmYCEe_Kzyn6x6o5P70vNFLt_UBgqyqil1tS4dg>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefhedrtddtgdeijeeiiecutefuodetggdotefrod
    ftvfcurfhrohhfihhlvgemucfhrghsthforghilhdpuffrtefokffrpgfnqfghnecuuegr
    ihhlohhuthemuceftddtnecusecvtfgvtghiphhivghnthhsucdlqddutddtmdenucfjug
    hrpefoggffhffvvefkjghfufgtgfesthejredtredttdenucfhrhhomhepfdevhhhutghk
    ucfnvghvvghrfdcuoegtvghlsehkvghrnhgvlhdrohhrgheqnecuggftrfgrthhtvghrnh
    epjeevhfduheeltedvjefhjeevgffhleegjeevvdfgudeuffefgedtjeeuhfeiudeknecu
    ffhomhgrihhnpehkvghrnhgvlhdrohhrghenucevlhhushhtvghrufhiiigvpedtnecurf
    grrhgrmhepmhgrihhlfhhrohhmpegthhhutghklhgvvhgvrhdomhgvshhmthhprghuthhh
    phgvrhhsohhnrghlihhthidqudeifeegleelleehledqfedvleekgeegvdefqdgtvghlpe
    epkhgvrhhnvghlrdhorhhgsehfrghsthhmrghilhdrtghomhdpnhgspghrtghpthhtohep
    uddtpdhmohguvgepshhmthhpohhuthdprhgtphhtthhopehnvghilhessghrohifnhdrnh
    grmhgvpdhrtghpthhtoheprghnnhgrsehkvghrnhgvlhdrohhrghdprhgtphhtthhopehj
    lhgrhihtohhnsehkvghrnhgvlhdrohhrghdprhgtphhtthhopehtrhhonhgumhihsehkvg
    hrnhgvlhdrohhrghdprhgtphhtthhopegurghirdhnghhosehorhgrtghlvgdrtghomhdp
    rhgtphhtthhopegthhhutghkrdhlvghvvghrsehorhgrtghlvgdrtghomhdprhgtphhtth
    hopehokhhorhhnihgvvhesrhgvughhrghtrdgtohhmpdhrtghpthhtohepthhomhesthgr
    lhhpvgihrdgtohhmpdhrtghpthhtoheplhhinhhugidqkhgvrhhnvghlsehvghgvrhdrkh
    gvrhhnvghlrdhorhhg
X-ME-Proxy: <xmx:ukzqaRSKM4T9G79yRr9Onid7Td1j4tlXYx8qt9FTYXcqpVpEVLQMdA>
    <xmx:ukzqaYIrMM6Pb67MV_KXRuIn_nMYnVm1pKguF2aj1GeDM43uNLRUEQ>
    <xmx:ukzqaQVj46v7o3Ho6qkKeJu2opjqtEUYVSrl_Ys9T0U8r_H_ocxOVw>
    <xmx:ukzqaURp3qJIr90yDicgYN4OUCb0RreOy38ncoMN7y1Y4FjbiVaFmQ>
    <xmx:ukzqaQBwbpDoJEsC3-Arj1V1P-hDRfdu9-3MJjhdCpJKrKo8J0KKQbLT>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 4A21D780070; Thu, 23 Apr 2026 12:45:46 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AYSbrDMut7As
Date: Thu, 23 Apr 2026 12:45:26 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Chuck Lever" <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Message-Id: <f61f49b8-c9c7-4a19-ba03-7f5967fcced8@app.fastmail.com>
In-Reply-To: <20260423-sunrpc-pool-mode-v1-1-b7f20e35749b@kernel.org>
References: <20260423-sunrpc-pool-mode-v1-1-b7f20e35749b@kernel.org>
Subject: Re: [PATCH RFC] sunrpc: hardcode pool_mode to pernode, remove other modes
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Thu, Apr 23, 2026, at 10:39 AM, Jeff Layton wrote:
> The SVC_POOL_AUTO/GLOBAL/PERCPU/PERNODE pool mode selection machinery
> was added when NUMA was new and the right default was unclear.  Today,
> pernode is the right choice everywhere:
>
> - On multi-NUMA hosts, it gives one pool per node with proper thread
>   affinity and NUMA-local memory allocation.
> - On single-node hosts, pernode degenerates to exactly one pool,
>   identical to the old "global" mode -- svc_pool_for_cpu() short-
>   circuits when sv_nrpools <= 1, no CPU affinity is set, and memory
>   is allocated from the single node.
>
> The percpu mode (one pool per CPU) created excessive pools relative to
> the number of threads most deployments run, and was only auto-selected
> in a narrow case (single node, >2 CPUs).
>
> Remove the SVC_POOL_* enum, mode selection heuristic,
> svc_pool_map_init_percpu(), and all mode-based switch statements.
> Simplify pool map functions to always use the pernode path.
>
> The module parameter and netlink interfaces are preserved for backward
> compatibility:
> - Writing "pernode" succeeds; any other value returns -EINVAL
> - Reading always returns "pernode"
> - Writing to the module parameter emits a deprecation notice
>
> Assisted-by: Claude:claude-opus-4-6
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
> In hindsight, I wish I had proposed this before adding the pool-mode
> settings to the new nfsd netlink interfaces.
>
> If this is too radical as a single step, we just could switch the
> default to "pernode", add a warning and leave the interfaces alone for
> now. Or maybe do that and go ahead and remove the percpu setting?
>
> Thoughts?

Generally, I think the end goal of making "per-node" the default
and only setting is correct. My comments below are about how we
get there.

The main concern is not perturbing any configuration that today
happens to set the module parameter.

The proposed patch correctly preserves the shape of the user/kernel
interfaces (same module parameter name and perms, same netlink command
and attribute, same exported symbol names and signatures). The concern
is that the accepted input set has narrowed from four strings to one
and the setters reject the legacy three with -EINVAL. For the module
parameter that path runs at module load, so existing modprobe.d configs
written any time in the last ~19 years will cause load-time parameter
errors. Some might categorize that as a regression.
                                      
The commit message documents that non-"pernode" writes now return
-EINVAL. The historically correct approach for this kind of obsoleted
tuning knob is to accept-and-ignore the old values (plus the pr_notice)
rather than hard-fail.

Or, put another way, the proposed patch implements something slightly
different than true backwards compatibility. Userspace that previously
set pool_mode=global/percpu/auto now gets -EINVAL, which technically
speaking is a behavioral narrowing, not "backward compatibility."

I might go even further and suggest that perhaps for v7.2:

- Change the behavior of "auto" to be per-node
- Add a deprecation warning that is emitted when setting other modes,
  but don't warn when the value is specifically the only accepted one.

Then wait a few more cycles before removal of percpu and global.

Other notes:

o The existing pernode path assumes every online node has both CPUs and
  some memory. nr_online_nodes on some platforms (e.g., certain ARM64,
  CXL) counts memoryless or CPU-less nodes; for_each_node_with_cpus()
  vs. for_each_online_node() matters here. See
  svc_pool_map_init_pernode().

o Recommend review of some history on this topic:
  https://lore.kernel.org/linux-nfs/f027319a-378d-4b91-a418-c45218fb7a21@oracle.com/


-- 
Chuck Lever
