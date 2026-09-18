Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3AA394FDA68;
	Fri, 18 Sep 2026 15:15:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789744559; cv=none; b=PwC5L0m5NzcgEoXRd1cEygV59aHUMMbCU+NJLB55eu9k1GKOv6CxMK8anTvuC6tZk+VQkCiHL/wfi+CZ8mzJw4AtBiu2TQ92FGNExnGAsKLFvx0fLdCvbffLSaOzAJz9bQe/zz5xKDxGbhtBky6gve4VanPanObGrrU9gfpdRs8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789744559; c=relaxed/simple;
	bh=UfTLgGlcDO389mCAtzhYb8eUPKLIBO/8OmDx/Bf0eiw=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=AGM2REMR6uxQnRbduW8g2Svdmq46aC+KZzjvh3ekQGLTcsFVn5qfGqELWMB6uoQWNMruLU5DNlmwJIuGBAV5/jKpgnrfMBzTBJ16XwaCS30fCS/u7j2pTeOkJMKU1/9TI5XHMDxYe6Q+xAmmDvADjkqlMKXiizIyPmtyADPCT5o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=J18fAPvX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="J18fAPvX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 91D001F00898;
	Fri, 18 Sep 2026 15:15:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789744556;
	bh=o9OjELzOfnEXe/aV35HyOAn/5z/gkwl3afGuJPIOTAo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=J18fAPvXrmnVpkYAnRWamd5ziIU6ZpeBXScpnWdh/Dni6hxEDtUbD3Rwo5oIW8keY
	 0Kk7N6ina5Mt5mUBzc/ScwaZOWZdbWmFiVMQ6w7guALTy28CfGcqK+jvnrbzpHPLJn
	 ei4kM7CpG+KNhUso4dd7Cv75J8dYtLvv0tPOwvOOuK2Hoc5haHuMwJD8a1vQJ8AlxI
	 dK59oN2xjhE/F6mFaMleeMsrfYJvKUeikkl0TzATcZ13YTo84sXDtA9Kd003gRBOJO
	 3R0qiE2R1LUt5OIjVkSvaYJsET8oTDvgUg7rPCLyhVgg1fgTNqWtRTfJymhy4BuXY6
	 1FpBbPDY8uZVQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A7316F40066;
	Fri, 18 Sep 2026 11:15:54 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 18 Sep 2026 11:15:54 -0400
X-ME-Sender: <xms:qlWtaseO_erFY3v5ZN6Yni5ZizEiVPku9oQJ1MR5uH6i_HgwXQjlNw>
    <xme:qlWtapBoP-lWVaH5x8p2_zbbMMKEENgijDodfyqM5gELx4VHu4pI3e-60gkJh9Hij
    vFroCc-qj2wpSS4f79zYLmfpGQSzA1iKUQEThWv-02fFp4twsIxk4yQ>
X-ME-Proxy-Cause: dmFkZTFyeyeW4YTKL8BGfOlidQaMKIe0Y/lxcWtKiU1uxUhGtjbzNhVAnPES35mJw04iGI
    6Y5KV/Gbrs+krGKQLolsszzJlze9yuEotfINiUh15oh6n5J4HCRBfSJ/eKMxYdDZQgzYq5
    zXjdLUN1h+4glEqgEEmDWisv5k77BxsyoEe6cbiphpjxr1RnenF4T6BBYsQftoE4u2bLet
    MJtNSerLdkRbMz8cm0jpQ38G78EVitrZxMsAEYVp/e/LEMqnsr/7unSbHKoX+1Js1xEqwt
    t1/nR5P5Polw+qXMnF8qhaJBSD479TDjm89i6S3OB10jRlACPG/F7/vX2GM+wpWZ9x2zat
    vBzltsWkc9BATM86G0sCGC/Qa/3o6/4p0YP+6LMq69tVR2ByBZprj3ajYk/Q3aOLn2Xgwp
    Zv687ctvA7j5e7OqUzK+edRsrxUnLyA3Yg2y54QzcwKHBArjeVTrZQEtvsaSuixR8Hfvio
    Ab9lrk81DlXpwCmS1w8i0bcEKTLUKXrTNnEuVDn6cFHud2ExplQ2SyE6puSB/a7YqcpWCe
    O1dtQQ9a1JZBkwqY7/qTtoYD3FBC4FiJiQGm1Va0ITlLru/bID9biYllGoxNCxJNCs7nlQ
    3GM195d4PfAXBLLwXyNbfe/RU2U1zfSBOMMPhNc/fS15LmSDGmCzo0JQnwpQ
X-ME-Proxy: <xmx:qlWtapVv6-rR43qj2JRhOY-TPtmy1xQHWFTLscjBKPqCpuNss0G3cQ>
    <xmx:qlWtauc3rBzJcBZdYmy5HlFY7kBBm3P1rTimhjxeuLm4nEh54JhSdQ>
    <xmx:qlWtat-fzf1BY5UhIoLAh2zBUp6bzD4HGHiTvOk37STAPB7jtyDNYg>
    <xmx:qlWtatm6xm0-W98UfAOBnblUNOxezBk-26X4NAIvRYcY23UtBLy89Q>
    <xmx:qlWtamhrnMCLq7AMwh9RVIUDLPuAECF177t45MDfk1LFdvqifpG4WrnQ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 7D640780075; Fri, 18 Sep 2026 11:15:54 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Ak1fuKNIJ_kR
Date: Fri, 18 Sep 2026 11:15:27 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Hannes Reinecke" <hare@suse.de>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "Jonathan Corbet" <corbet@lwn.net>, "Shuah Khan" <skhan@linuxfoundation.org>,
 "Randy Dunlap" <rdunlap@infradead.org>,
 "Christian Brauner" <brauner@kernel.org>,
 "David Howells" <dhowells@redhat.com>, "Sagi Grimberg" <sagi@grimberg.me>
Cc: linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-doc@vger.kernel.org
Message-Id: <81bade19-10d6-4fc7-9a57-eef85afe76cf@app.fastmail.com>
In-Reply-To: <bbc4ff6f-aa38-4862-96fe-518c3b4df4d6@suse.de>
References: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
 <20260918-nfs-mtls-identity-v1-2-197e568d78a7@kernel.org>
 <bbc4ff6f-aa38-4862-96fe-518c3b4df4d6@suse.de>
Subject: Re: [PATCH RFC 2/5] NFS: allocate the .nfs keyring per network namespace
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Sep 18, 2026, at 10:44 AM, Hannes Reinecke wrote:
> On 9/18/26 4:05 PM, Chuck Lever wrote:
>> Commit 87268f7a4f1f ("nfs: create a kernel keyring") allocates one
>> .nfs keyring at module load, and nothing in the NFS client reads it.
>> One module-wide keyring also cannot isolate x.509 credentials
>> between network namespaces. Each tlshd instance services the
>> handshake socket of one network namespace, so a credential
>> provisioned for that namespace's mounts has to be reachable by that
>> tlshd and by no other.
>> 
>> Allocate one .nfs keyring per network namespace in nfs_net_init()
>> and release it in nfs_net_exit(). tlshd finds a keyring by name
>> through /proc/keys, which is not namespace scoped, so each handshake
>> request has to carry the keyring serial instead. Allocate the
>> keyring under a kernel credential rather than that of the task
>> creating the namespace, so an LSM labels every namespace's keyring
>> the same way.

> Curiously enough, I had been pondering a similar issue.
> Thing is, when running within a container (eg a docker one) access
> access to /proc/keys might be restricted, and from what I've
> gathered each container gets its own, _empty_ keyring.
> (certainly an empty session keyring ...).
> So I wonder what'll happen with the predefined keyrings (like the
> .nvme keyring); one possibility is surely to make them network
> namespace aware.
> But the alternative approach I'm exploring is to allow each container
> to create its own (.nvme) keyring; that would have the advantage of
> being more flexible and we wouldn't need to rely on 'magic' names.

IMO we need to hear from the folks who have deep keyring expertise
to understand what is most flexible and most idiomatic. I'm certainly
not expert enough to make those calls.

It would be great if tlshd's NVMe and NFS/NFSD keyring support
behaved consistently with each other, but perhaps that's just my
compulsion for symmetry talking.

I'm willing to take a look at patches, if you have any.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
