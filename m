Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 008FE1940B0
	for <linux-nfs@vger.kernel.org>; Wed, 29 Jul 2026 03:18:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785295091; cv=none; b=MYWJwgMOwH/lkzazYHBEkdCYBxrBLhQvJQ5Jxz2teyas+aDVR8qg6JAwlVzjI4+t1P6lVA4MC47iX4WDXCRk0lmeFrc5HpaMvgJHDNN5EDprKl2C1sl4f4FgLA/Wq9+y3v5G3L3xCMbiG1z0XsDPgQw1NBToY8jz8/fwmcuxfxY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785295091; c=relaxed/simple;
	bh=iWO8uagfZiFOmjzR1znwWCLgJmMwl8vmRNioWQsB+Nk=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=C1Znd5RoJDfawVM1YVVFO1rG38ps9OdalopMBKrGjef28wtSSr6MYjbB/GhLxj6/HkGMbQK5oY9gt6LWQ0SpiaHZJ2P+ld3VkYoZu3Xg8MHFLsfX9yMgfqwhhQC0zz5/yEYB0EsDqJuu4R4RDfqcdI0d6o3q4B8fznO1aCefD8U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=E7u3FyIz; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="E7u3FyIz"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 45EF81F00A3A;
	Wed, 29 Jul 2026 03:18:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785295089;
	bh=iWO8uagfZiFOmjzR1znwWCLgJmMwl8vmRNioWQsB+Nk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=E7u3FyIz1PcOcFdSOvFfCiecA4sP7DwqpgpMkKBswbEimVLuH4RWHO2EJfmEzejnj
	 9U/kUQiXIIKlApeRM3GqV+0o5eX41pBZMzZTaQ/0lJw6SoBhLfxlzIDLeyDGlsEK0R
	 xOBYblnZnMg+z9sTwXScSpARMs0x8lOQyoXNj0N+PMuA19H8BPGoNCs/M75hiGV3pa
	 YToAK38nqTzUvC1gQRevnnGPIHxlcfYwTbcS1jH9iUQxbeSaVRVoGSNShu++IJqoN+
	 ArMYLXsbTnpH0G3N2mW0QZ3a/r2dLJ8JglJKWxOL6OsNvBbao89Sga/OA17hTSMVKQ
	 0tRTNx4pjfV2Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 52775F40071;
	Tue, 28 Jul 2026 23:18:08 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 28 Jul 2026 23:18:08 -0400
X-ME-Sender: <xms:8HBpauiYuSVao1nXz2_A-t9Cd_QHZPiNHL0L6GRDVCXwphPxiOfCjQ>
    <xme:8HBpap1e1dC04iK1T-82r6Eel7ydz8YYVmEJr_cIe7avR0PT7H8zTkKSi1JcWSf00
    QaaFtqAxloI6MxKZ7vJflYvDPGk5MZCIITid6AytUdijDsolt8R0MIz>
X-ME-Proxy-Cause: dmFkZTFlEvRLbxX/R7zrLd/d14ESObNiG04tZzmu3JcUwUgAbZyCOJr8+YmY5DERybfv6K
    W5yfYcHcBzmUsxNIAdSIB6pC756ZF0kuM5dnDeYA8X5sF3hdMdwHwtULFCh7cflMcQO+Rb
    ScxOXWKV90IS18VXlSM6uSDQgbUNzy50fIQV6kWuvarSxUw+bMt53ChE/tSgwFgHg79+Wu
    kVSN6vlAk0s339hLZhaGxl6l3V4LGiiZA+NrR8AnNK2bJ04gXA9AMHQVK72JRiDZEkqHNI
    Sy9cJ41LHDFGfSc0LSDeArTnITANULnb46kynrYqZatYqqTlF+yCd7H8S6gQDD1VanosAv
    yydkgk3pcWgdKMnyuLieMVfbe33Evmb4OkTmHmwBnLZejebiq41EZ2vh/Pd49OHMiy5lcQ
    CYvOzYaXnKotfE5nsxZT6etk0rgWoeu1vwGGA7XfMYelJYmPHOHoD2hrLCDnl9PRMv2uEG
    XTzutqU6lMVk0UlZQm/Q3ieelBVQc/t7aHSUMU27MiC3CSbHKdkk4EH2CfQ+cmjtw8Ed1m
    5ucat/a9A4OnvF7du7QTYBcc2LFvHhYW3MApu3t8znlslfqd2Pq4s7Tmdvze0ot1ofqFct
    eJEQCUrAX6oROh0zXtQgpR5Zf1ipVKoXH9yt+ym81yY/8l4ZzqUl9y3FHNkQ
X-ME-Proxy: <xmx:8HBpaqba7bbukgISIBNvp-xGSrQlPFrND9bERp5qm4Ul21ZdSxD03Q>
    <xmx:8HBpak8MUXFXgqcIIvJ06BfvOiocOmXQIfk_iLRe6UB--jmuBc5xlA>
    <xmx:8HBpaklCEAangC8UjY6YlTAG_tmK5lscrxP2cs4MSO3DVBlyoagTdA>
    <xmx:8HBpapYueU33O7xT10rSKE741geeL2gH8Ko9qi_LoQzESLvjXAFddA>
    <xmx:8HBpasMhDfdGuqeDyKEE2Hsw6ybAluEXbZeYdtSWPPn0Lgj2NujAy_Xe>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 305A9780070; Tue, 28 Jul 2026 23:18:08 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Tue, 28 Jul 2026 23:17:48 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Jakub Kicinski" <kuba@kernel.org>
Cc: "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "John Fastabend" <john.fastabend@gmail.com>,
 "Sabrina Dubroca" <sd@queasysnail.net>, "Shuah Khan" <shuah@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Message-Id: <fdd3e54d-2eb6-468c-9877-adc0809d64b2@app.fastmail.com>
In-Reply-To: <20260728184712.09cc50f4@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
 <20260720-tcp-read-sock-v2-1-29545d034f3c@kernel.org>
 <20260728184712.09cc50f4@kernel.org>
Subject: Re: [PATCH net-next v2 1/6] net/tls: Bound consecutive no-data records in
 tls_sw_read_sock()
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Tue, Jul 28, 2026, at 9:47 PM, Jakub Kicinski wrote:
> On Mon, 20 Jul 2026 10:27:55 -0400 Chuck Lever wrote:
>> A record that delivers no payload -- an empty TLS 1.3 data record
>> today, a control record once read_sock_rectype() lands -- leaves
>> tls_sw_read_sock() in its loop without advancing the caller's read
>> descriptor. A peer that streams such records keeps the receive loop
>> running, and the socket lock held, for as long as the records
>> arrive.
>>=20
>> Cap the number of consecutive no-data records consumed per call. The
>> count resets on any record that delivers bytes, so a normal stream
>> is unaffected; a peer supplying only empty records is bounded to
>> TLS_RX_NODATA_LIMIT iterations before the call returns 0. read_sock
>> consumers treat that as "no progress, re-poll" rather than EOF, so
>> the connection stays up and makes progress once real data arrives.
>>=20
>> Only tls_sw_read_sock() needs this cap. Its consumers drive the recei=
ve
>> loop from kernel context -- a work item or service thread holding the
>> socket lock across the whole call with no return to userspace -- so an
>> unbounded empty-record stream keeps that context and the lock pinned
>> for as long as the flood lasts. The cap supplies the return boundary
>> that a system call would otherwise provide. tls_sw_splice_read()
>> and tls_sw_recvmsg() already have one: they run in the calling task's
>> context, reschedule while draining the socket backlog (cond_resched()
>> in __release_sock()), and drop the socket lock when the call returns.=
 A
>> flood there costs the caller only its own scheduler time, so the cap
>> would add nothing.
>
> Is this alluding to PREEMPT_NONE (which for practical purposes is=20
> no longer a thing AFAIU)?

No. The cond_resched() reference was a bad way to make the point.

What the bound protects is the calling NFSD thread. A client can
open multiple connections that all send a continuous stream of empty
TLS records, as a denial of service attack. The mechanism added
here is an escape hatch for consumers.

This patch has already moved to a prerequisite series, intended for
=E2=80=9Cnet=E2=80=9D instead of =E2=80=9Cnet-next=E2=80=9D at Sabrina=E2=
=80=99s request.

https://lore.kernel.org/r/20260726-tls-follow-on-v1-0-99bf4cc1c729@kerne=
l.org

--=20
Chuck Lever
