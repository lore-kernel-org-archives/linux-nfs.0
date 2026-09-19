Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B037B33A014;
	Sat, 19 Sep 2026 15:47:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789832849; cv=none; b=cUkti3NfbqidkduTLzLqKKOEvO1Ko2uf2lEh/yOg4oq51sKbvcTCSBHXKCksdDMo1OoTh9DHxMirJ3nRX1y9P+xb7xzzpuc3sSMPKZjBBrkdYzwZOWNSEyeRqQGZt6IsCjOPpDNVV902Ks2aHLmaN92c7EqSYJdEYPPMhONlIQQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789832849; c=relaxed/simple;
	bh=aQwBW/J4ZINdvadr0XdeF7bmZtIw6fMwqTv8ouYq5ns=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=teLyOUNyxTU5HBXljRjL4l+SaVbB3x60etIyijZyFWaQVosGvJaXq68k+vVAgN+bKPef+t3Veb2UoIaXriq1mDsFN9iKfcd3Gp9onx9gh8xEUd5DFySLQg8v5sEqFCcza1RGWDsIYTYGqjzxN6uCoLqmF0rgh2FpHqspIc/krUc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=AiVVo1Zy; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="AiVVo1Zy"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 08BFE1F00898;
	Sat, 19 Sep 2026 15:47:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789832847;
	bh=mODAfFhrA/MwRkrgaakjZKRIyNrtunWJQx8N1zGq8SE=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=AiVVo1Zyfo3O7oZ9prZcnoQpuCM4Fq5bSXnUEbchPY5TelE+fucj8a2sb9FMfKTw0
	 PeJmC6f2Y3oXhwmiuOu8RRJ6qiJYhI3CpbuuOa4oYSjnanbuMZ/0WHiuBhLlxMQjzE
	 gjs3V1QsFFzpBvAW6CKhI1TAj9ZZDAMLY4l7pG2eNOlcN8CfE6F5UkIFEGuhCVMVJu
	 lDP6kQFNW7QWT7EVfEvaCo6agVNgRb4fJTWHTyqnxzB2YVyGrrvhpm1PtSVmB6hmVy
	 EqdaMHSqMTbroC6atNWqXWrTO1ehmDMPmH2/K/R51yv+sa3ptrg3WXcIiChpqwrNZ1
	 gsAmjyQTrdBQw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 1626FF40066;
	Sat, 19 Sep 2026 11:47:26 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 19 Sep 2026 11:47:26 -0400
X-ME-Sender: <xms:ja6uahvGbAPIicBSV5zgxL03tCk3pzMJeZgSto4sdetuBsrClWyCdw>
    <xme:ja6ualRvvxXHzDIdaEiI52K5S7M41AhSeOEMI3UU6KS5zKX7pXHXWm4887bNr9XBX
    h2bRK-9eHcUUzN38-B7v4uxl49987E1eUJev1wbUrnc9u80hta547Cc>
X-ME-Proxy-Cause: dmFkZTGoh0mOmlRrlZ5GwR88ixO4iXB664+VWrJRNYFNenTomUqh+UiXgCxhBQgewE69EB
    u+/YkKFO1As/lBVEJQ451JM1sJvyf1ZvBzhi6FFto0bGxVVjmt8302FLdCZoxuRgPq95L2
    4Lz4W/F+AOfdw82DwB29GbOWs2pBeMqjccVYEfOkScn6BBf+d2HCztV5Fx5tqN4XdKRvef
    DZ5VuZ4jgE23hRhCEh5SBuUpl9JDPZ/SXptnYbKRqVsIVHcxQ7oKIL3veMptizQ3NqJ4/h
    WVxDebWTiRtsueNzSp0U5+Zc+T/OrkOHqdOUbbSkERiRLpnJgQCF5AaqAnYwexW/3eYJF2
    +JTnHJvoGIUoRQaJ0nzCX02A1fA8p7b2gnbVnuep0NII67zSuLvx77btmtQgCyAVTZvCku
    jAnWjaYolVyzXVBnikdhzMUNpy8S+SrMftnN3N1Iu3LMIl/5y0quD+Pv2xTEmgbnZuDPRV
    sKx66SVYI8wNgck06AxkyYofiYBDYjWCMmZ4Ia0SESHmvChl21HrDltylwJq6cYtx7WQSK
    /ya1VEKKWwoLcArdP2CpmzJyNEJRYp3DMygppBhXzfcCCf/p7vX8YnwPR7iCctvNLYCbB1
    dreR9yw6xq0jO3w7Tv+6cnFfRhmEnTmGKwvN8TQtPy/qG1P2zOs3veZD8U3A
X-ME-Proxy: <xmx:jq6uaskhqz_lp97X450jwcAa9l9PKee_kK4-Y4HHNAYyiEss6I40tg>
    <xmx:jq6uagvQVcyGjyIw_uQFixL_fUW3vr3CybcQsk3u7HQgZ2yN5QETTw>
    <xmx:jq6uajO_46CUtCEOlBI-hb32rBETMT0SzAPeZ-CgGYhPoAoJdQdz8g>
    <xmx:jq6uap2Jx3fKJ8fy77h2DqyusiNqzMSnIK460QGA2Lm82RQtVvcoAA>
    <xmx:jq6uatyMaFF4JCAcizmCeCGW7zUFcBLEn4dOyEZ1yWeUA0Vu8ZcHjXom>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DD94D780070; Sat, 19 Sep 2026 11:47:25 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Atqj05nf2p3o
Date: Sat, 19 Sep 2026 11:46:57 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "Jonathan Corbet" <corbet@lwn.net>, "Shuah Khan" <skhan@linuxfoundation.org>,
 "Randy Dunlap" <rdunlap@infradead.org>,
 "Christian Brauner" <brauner@kernel.org>,
 "David Howells" <dhowells@redhat.com>, "Sagi Grimberg" <sagi@grimberg.me>,
 linux-nfs@vger.kernel.org, keyrings@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, netdev@vger.kernel.org,
 linux-doc@vger.kernel.org
Message-Id: <5a2b6bac-bcdc-479d-a8ae-8b670f78d80b@app.fastmail.com>
In-Reply-To: <2FBF57B6-FBB6-498F-A1F4-695D52EB89E9@hammerspace.com>
References: <20260918-nfs-mtls-identity-v1-0-197e568d78a7@kernel.org>
 <2FBF57B6-FBB6-498F-A1F4-695D52EB89E9@hammerspace.com>
Subject: Re: [PATCH RFC 0/5] NFS: isolate mTLS client credentials by network namespace
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Sep 18, 2026, at 1:21 PM, Benjamin Coddington wrote:
> On 18 Sep 2026, at 10:05, Chuck Lever wrote:
>
>> An xprtsec=mtls mount names its client certificate and private key
>> by keyring serial, and tlshd reads those keys with its own
>> credentials. Each key therefore has to grant user read permission,
>> and any tlshd on the host that learns a serial can read it. Nothing
>> separates one network namespace's credentials from another's.
>>
>> This series makes the network namespace the isolation domain. The
>> RFC thread asked whether the user or mount namespace is the better
>> binding. tlshd services the handshake socket of one network
>> namespace, so that is the namespace it already lives in.
>>
>>   https://lore.kernel.org/linux-nfs/20260602154740.49861-1-cel@kernel.org/
>>
>> The keyring is held in struct nfs_net rather than found by name,
>> because /proc/keys is not namespace scoped. Its serial travels with
>> each handshake instead (patches 3-4), and tlshd's possession of that
>> keyring is what lets a provisioned key grant no user read permission
>> at all. Both ends of the link exist today, in tls_handshake_accept()
>> and in tlshd. The handshake genetlink ABI and the cert_serial= and
>> privkey_serial= mount options do not change.
>>
>> Still open is how userspace names the kernel-held keyring. Patch 5
>> prototypes a request_key type handled in the kernel and tagged
>> KEY_TYPE_NET_DOMAIN. A keyctl modeled on KEYCTL_GET_PERSISTENT, or a
>> read-only attribute on the netns-tagged nfs_client sysfs kobject,
>> would do the same job if the keyrings maintainers prefer one. Keys
>> that userspace adds are quota-charged by user namespace while the
>> keyring lives in nfs_net. Confirmation that this is sane when the
>> two boundaries differ would be welcome.
>>
>> nfstlskey, the provisioning tool that consumes the key type, is
>> merged in https://github.com/oracle/ktls-utils/ .
>>
>> Tested on one Fedora VM acting as both NFS client and NFSD, with
>> tlshd from ktls-utils 1.4.0: NFSv4.2 mounts with xprtsec=tls, with
>> xprtsec=mtls using the identity in tlshd.conf, and with xprtsec=mtls
>> using serials that nfstlskey provisioned.
>
> I think this is the old upcall/namespace problem that's never been generally
> solved (as far as I know).  Here's a shameless plug to potentially revive
> the original "key agent" concept which solves this in a general way.
>
> The idea is - user space processes (tlshd) register themselves as key-agents
> that can satisfy request-key.  A key agent represents itself as a key-type,
> and the appropriate key agent is consulted for request-key if the calling
> process has that agent's key in its keyrings.
>
> Otherwise, this solution looks good - but without a general solution to this
> problem, other folks building on keyrings will keep trying to solve this
> problem.

Thanks for having a look! Your idea sounds a lot like how tlshd uses
netlink.

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
