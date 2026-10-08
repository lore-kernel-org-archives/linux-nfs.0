Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id ADE783ACA65
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 15:20:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791472819; cv=none; b=gJBy+18tl+oQSRwkIPV5SWokkrUX0/QLiWnsKENYQREVXZ6O4eJDjzEodVVa34w3136eZYq+4eMiGHl80Oe3nm3lgTFyVdgrAZhS1xQRJmFMVBkMBgNAtDJgnBIcCl8T3i1r3ERR0cZ5glcQR5vr4KlLbxqvnD8vyrwXMqtwatE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791472819; c=relaxed/simple;
	bh=EDlyX+P7UDLvAVZf4IZS7UhEVVQW7cpzMX2ZcyCY4sY=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=TwOqefc7M2EbX8HA84+QUbPNeRD5yuSq0EC3YIX5kUozoOp1DwOsGMRCgw5aXgLb+lDGOrmZdS/hPeglB3hrDgNHngVub817Nb0afqUhrlOPDveG38O+2lBLyAQcBacYfW8Yx2JrtWpUW9wKjzvC0xXoqUqwU+sUxyaolbLZgf0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=bSuf01MU; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="bSuf01MU"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E9F621F000FF;
	Thu,  8 Oct 2026 15:20:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791472815;
	bh=YfVEq24R0dKF+JPPJNtnXrH1r50ARzIe2/ClQZyANG4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=bSuf01MUTlvbwc6mBq2PP3uxu1XY8qItTcpCYQmMNOCFtIOl271y675kYnw4CATPD
	 8PtTWNRYJ1+wcF45YiP+maSXlXS5Zf7vETrbz30re+k8V+kJ5L0Kqv4kiWpDdw8NZI
	 6GUH4o4Crq0iJgRAxGqV6ol1UdrqsJtYcFCrk3o+hmlG1s8msVrErJTxRMYHNz+lsj
	 7s4dxhNee/hdSNt0wAVpjrwxuTyrYZ26LmoftWG4t5LeUoMhzHzdMkza5E7g5Bon7P
	 e7yHCdf0tdlCUEHngGoWSo/RktRJEKf9CN1nRdYF59tCSOm9GokV//it6IW8ZforKv
	 1ijT/FMhrsE6A==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 184FFF4006C;
	Thu,  8 Oct 2026 11:20:14 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 08 Oct 2026 11:20:14 -0400
X-ME-Sender: <xms:rrTHaudqFiUfbfjcN7Dm6m5hgU_LwKK2Susx7MvkdHTULK6xmUr_Ag>
    <xme:rrTHajDiGan7wz8HUZ0raZwYgMrwRbQsK4Mc4-duoZzD3BKuG5wU-GguoIw-31aK5
    2XuBb-4eMIrwVvhYNT_YADIpNY4fph6i9Sof3g_ljUQ8CB6NtV8WRHf>
X-ME-Proxy-Cause: dmFkZTEZZpqbNESrY/bX7q5KSF/dhOrD+kqPOY+su76KTd1OUZOYNejP66UOFdMnJbj71Q
    wFWPiiB59RMENey5f04Cd9Xh/dg1o1l5IxzTolGsiUztQsLJVGOUaIkYf7b/0R5JBQ09Iz
    PqTL9wwgXx0f6y5xpsONVzo4Xk4SSfFPiO/rg+fmtTaej5ecQ/Fc/0eroWiWc3kX/ZZMvb
    DqIpvh2scfhc4xLcFMQVSFpOi0tdgsMt8SOWovoHhE6BpPrF1foqnTyyNq8AOCuRk3hpap
    5ihTq4irTCqnNMelrFcKFfKDlASaIu2OFfjbvT16ji27LOw+F4uzSgnI42+KHXiehPvhXj
    B2ActXvwYkGAF8YPiNd+2aeaXWny0a0nt6QlTkLfqvP1fjkfXtW0rvH7cfKeIkiwkiketh
    +gTCRJe4RDOU8WLu7CWIYwAlLPj3dntCdwJMz+7Z42UMy6bWrI5SRi8w81DZQYaAwCXFyi
    a11wp9j3grodgqCj3ZlLzl/Yso/GwBqqX3Vm/p7mPoB6izqAx7Zm/tnvHCokVYL7F9+qfz
    RA+9NCrbRPqgGZkLd3NnADiLRQD8sNZu7fkmDGoMaie1UA5lOS23pyXpYv2I+3GheR3nVy
    LWBlYIes/nXKq6mvUDVcC30HkAsPwHWte4PP1gRaz839TquRjsJYXtbtC6pQ
X-ME-Proxy: <xmx:rrTHaoEUwNTXq9QFMVZ7SRd2L3wJXmX9o4t9cg90HFwwLnGsHR9K-Q>
    <xmx:rrTHarYAbj8WHZgYEvZUoiw-aP1PNcZEbaUvjjVb8nai1iCF-4m3uQ>
    <xmx:rrTHaiAtHMZiYKR0-1f4pSOTHhDXmE8RT5MRRSaDDYx0gUF0vsfAOA>
    <xmx:rrTHarnxcpIBzMjlEchEhr_8Fji3erOL7MfHitFeGqjS-LPugwpg4A>
    <xmx:rrTHarzfNXiXv07cU4NoOrpM5CjxCIEpKt2gDTKRjzj0a7VmFF4_iDyE>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E8FDB780070; Thu,  8 Oct 2026 11:20:13 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AlSxgl7w3Myo
Date: Thu, 08 Oct 2026 11:19:53 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>
Cc: linux-nfs@vger.kernel.org, "Daire Byrne" <daire@dneg.com>,
 bpf@vger.kernel.org, "Martin KaFai Lau" <martin.lau@linux.dev>
Message-Id: <5f226738-0062-4e78-af4c-c68c1433e1b2@app.fastmail.com>
In-Reply-To: <cover.1791402701.git.bcodding@hammerspace.com>
References: <cover.1791402701.git.bcodding@hammerspace.com>
Subject: Re: [PATCH RFC v2 0/9] SUNRPC: dispatch ready transports round-robin across
 clients, classes from BPF
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Wed, Oct 7, 2026, at 3:59 PM, Benjamin Coddington wrote:
> This is v2 of [3], with the change I floated in that thread: the kernel
> no longer decides which transports belong together.  By default nothing
> changes.  An administrator who wants peers grouped loads a small BPF
> program that returns a class for each accepted connection, and the pool
> takes turns across classes.

As a quick response to this posting: I'd like to hear opinions from others
on this approach rather than just fetching it straight into nfsd-testing.

Having patches to mull over is great. Thanks Ben!


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
