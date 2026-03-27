Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 26B003A1D2
	for <linux-nfs@vger.kernel.org>; Fri, 27 Mar 2026 15:20:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1774624808; cv=none; b=obT+iowZOVvMdyAuu2H5QYaYquYzFkCeN4D21QRtEVvjN7U1wJN5UvpnTNFR3ifqHQBjeStzFwUd1JoEK06ntJaBM+uPnT+nle2PmPA5Au2LZ1/FbpQ9ySAKpfl9PmRd3CmqUp4iT8PxkXyDF1NXN818qHCOAK/SsDtcAcWwNBM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1774624808; c=relaxed/simple;
	bh=cQzWs4ZA/OPWlZYmfOQeqfTDkmkz29sDHAC95nSTYBQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=FSWqW8kHlfwHdzStJZ6KZazKLuHVHb3qDgHytRjfO6fbHdmooatrAJnthkpIh/moHASLXWoGyms6MefDTWCButWzoIvF53yPnyioZTv1UL/ApooF/PBAZfI1+UUKKpFKFsRTGd8tRnZSkts8nAvUOklew3mcEMo9CjSy4yqT0zg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ZMbgLA03; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ZMbgLA03"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 955E1C4AF0B;
	Fri, 27 Mar 2026 15:20:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1774624807;
	bh=cQzWs4ZA/OPWlZYmfOQeqfTDkmkz29sDHAC95nSTYBQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=ZMbgLA038ZRA0AZyE97XGN5bWpSmMYk9FGuXQn+l8sjaakvWRrZ1LIOi8x9Y7fHEc
	 EuYsFZ23HSBTGMIWjbJZ9UsLSnb6dgbysnKNhRoKSz1N+C2vjHhsLKTDmFFM8WvTUw
	 3lJMRI8Hs08H6plbVRr3I70Jo4RhiJpNF+w/Pi7UZMRyorgaENg1Hi89qZvg3AiyiZ
	 brh3wOt2i0xR4ehSWP/Bj9MI5PK5nsji5/qlQ9qt/e7zvm1e4Xf7XIworGs1hiPRmu
	 nA/hqt8u+HdbueuAN6m1v2gjJdJc0+vyDVCHm/hW9886eWdMJFu3IphHuUvqFTbczw
	 BaV3v0bxjuMJQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 73F2CF40084;
	Fri, 27 Mar 2026 11:20:06 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 27 Mar 2026 11:20:06 -0400
X-ME-Sender: <xms:JqDGaTQWjCX6cLBrjSi3sEzhX3CSuWxysL61VY9O-ThnXJoacP_cFA>
    <xme:JqDGafn_FkTofQWbRBK9qzgooJmLwSkKGfcsio6TmdyazvVv8oyB7Bewn5zLOPPRF
    Tinfog1-IxdxrhmhziYy8GDy3JHOPOMeDR8n1I_YRMCTu6tnern-A>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgdeffedtiedvucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpefhffekffeftdfgheeiveekudeuhfdvjedvfedvueduvdegleekgeetgfduhfefleen
    ucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpegthhhutg
    hklhgvvhgvrhdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeifeegleel
    leehledqfedvleekgeegvdefqdgtvghlpeepkhgvrhhnvghlrdhorhhgsehfrghsthhmrg
    hilhdrtghomhdpnhgspghrtghpthhtohepkedpmhhouggvpehsmhhtphhouhhtpdhrtghp
    thhtohepnhgvihhlsegsrhhofihnrdhnrghmvgdprhgtphhtthhopehjlhgrhihtohhnse
    hkvghrnhgvlhdrohhrghdprhgtphhtthhopegurghirdhnghhosehorhgrtghlvgdrtgho
    mhdprhgtphhtthhopegthhhutghkrdhlvghvvghrsehorhgrtghlvgdrtghomhdprhgtph
    htthhopehokhhorhhnihgvvhesrhgvughhrghtrdgtohhmpdhrtghpthhtohepthhomhes
    thgrlhhpvgihrdgtohhmpdhrtghpthhtoheplhhinhhugidqfhhsuggvvhgvlhesvhhgvg
    hrrdhkvghrnhgvlhdrohhrghdprhgtphhtthhopehlihhnuhigqdhnfhhssehvghgvrhdr
    khgvrhhnvghlrdhorhhg
X-ME-Proxy: <xmx:JqDGaWTb7fU75h-EfMKjtNz-ChIrC6eMZSLT8txQYWhQUxIi-xPkYw>
    <xmx:JqDGaXw_SkIGYoKML8KdIaZpIVe3mHiWR11332ey8VyVZWIyBJ1zig>
    <xmx:JqDGaWDAuX89ZEaxNvOM1KZZuYTb_Jjz3_OgJ-rEfsxgKhR9VGA9-A>
    <xmx:JqDGaTEJIRBse9fu-Pfau8_r9XE9EgkM4fpXrNsoF_f_RD9wDmV9EQ>
    <xmx:JqDGadPEnAr54oZcLZTU4vTyx_caGUdhXPPmlxRK_MWB0WzzMGOG6pcW>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8BD4E780076; Fri, 27 Mar 2026 11:20:04 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Aql3KRXDeodw
Date: Fri, 27 Mar 2026 11:19:43 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
 "Chuck Lever" <chuck.lever@oracle.com>
Message-Id: <d22d6a1b-13c7-4b02-bf82-d1d701e912c2@app.fastmail.com>
In-Reply-To: <b7cbff660e5222d3c2b9c48d6040f73132f5f312.camel@kernel.org>
References: <20260326-umount-kills-nfsv4-state-v5-0-d2ce071b3570@oracle.com>
 <20260326-umount-kills-nfsv4-state-v5-2-d2ce071b3570@oracle.com>
 <b7cbff660e5222d3c2b9c48d6040f73132f5f312.camel@kernel.org>
Subject: Re: [PATCH v5 2/7] NFSD: Add NFSD_CMD_UNLOCK_IP netlink command
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Mar 27, 2026, at 8:06 AM, Jeff Layton wrote:
> On Thu, 2026-03-26 at 13:55 -0400, Chuck Lever wrote:

>> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>> index 988a79ec4a79..e1e89d52e6de 100644
>> --- a/fs/nfsd/nfsctl.c
>> +++ b/fs/nfsd/nfsctl.c

>> @@ -2200,6 +2200,44 @@ int nfsd_nl_pool_mode_get_doit(struct sk_buff *skb, struct genl_info *info)
>>  	return err;
>>  }
>>  
>> +/**
>> + * nfsd_nl_unlock_ip_doit - release NLM locks held by an IP address
>> + * @skb: reply buffer
>> + * @info: netlink metadata and command arguments
>> + *
>> + * Return: 0 on success or a negative errno.
>> + */
>> +int nfsd_nl_unlock_ip_doit(struct sk_buff *skb, struct genl_info *info)
>> +{
>> +	struct sockaddr *sap;
>> +
>> +	if (GENL_REQ_ATTR_CHECK(info, NFSD_A_UNLOCK_IP_ADDRESS))
>> +		return -EINVAL;
>> +	sap = nla_data(info->attrs[NFSD_A_UNLOCK_IP_ADDRESS]);
>> +	switch (sap->sa_family) {
>> +	case AF_INET:
>> +		if (nla_len(info->attrs[NFSD_A_UNLOCK_IP_ADDRESS]) <
>> +		    sizeof(struct sockaddr_in))
>> +			return -EINVAL;
>> +		break;
>> +	case AF_INET6:
>> +		if (nla_len(info->attrs[NFSD_A_UNLOCK_IP_ADDRESS]) <
>> +		    sizeof(struct sockaddr_in6))
>> +			return -EINVAL;
>> +		break;
>> +	default:
>> +		return -EAFNOSUPPORT;
>> +	}
>> +	/*
>> +	 * nlmsvc_unlock_all_by_ip() releases matching locks
>> +	 * across all network namespaces because lockd operates
>> +	 * a single global instance.
>> +	 */
>> +	trace_nfsd_ctl_unlock_ip(genl_info_net(info), sap,
>> +				 svc_addr_len(sap));
>
> All of the tracepoints get passed svc_addr_len(sap) for the length. Any
> reason not to just determine the length inside the tracepoint, so you
> don't need to calc the length unless it's enabled?

Unless I'm mistaken, the trace_nfsd_ctl_unlock_ip() call site
expands to a static branch that skips everything, including
argument evaluation, when the tracepoint is disabled. The
svc_addr_len() call, being part of the argument list, is
already behind that branch.


>> +	return nlmsvc_unlock_all_by_ip(sap);
>> +}
>> +
>>  /**
>>   * nfsd_net_init - Prepare the nfsd_net portion of a new net namespace
>>   * @net: a freshly-created network namespace


-- 
Chuck Lever
