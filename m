Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792785693;
	b=hyHHrBu74MhwKroJndZazUyHI08Q+PFGe1np0Xqzs/do9DOO51emkeSvr5T8ck3g47sh
	 S+yLFtfv7mzClCg6T4bPJty1/qd+M9s6MbO36M0lfY6WjpRAdaFGWf+iudGJCSnh9xXAE
	 /qQE4zocQGZRSfvUJtIS2M1MsIkoPLzFmkta8s5wa5ElwOXV0W7ugsQEg562xSmyxOwyJ
	 MqyBt6k0H08pFn0MkyP9HsqZrisgNgAU+MKk43PoF4j+qVlKzvwfH5Nv+N9mg8Iu5A9Qk
	 t7DTmgEf2bsMCRUe9GX1Yj7NUbwykBYZldU8YnBzuSibMP8V0zY8J6WJo0kivHq0xDA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792785693;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=83dTVyz0p3AkNgmbCP0B/0Rsb2Y7EcIdwhNXZ0ef3CU=;
	b=lP5MRtK2uAy8iRgW50cfpvj/ucOYO4eBerBMPi9Uuc+N6TKScghcWyfJFZ7CbTyBPL2K
	 TSYMJlPudO3mOHTU9dEIsRqNtIXA+Gkxle35kql2FqWwiX3Uh4d2JyM0cUxI51D15Zc39
	 219esJFvDIbKPff0KjKSihKmnPNt9syjvxYpXhRAtfmWJJshoH/79t1/cc9EANp7Cx+cV
	 Z8wBSfoyreqTd2YSTnLu2b9bm6+T55T11hYIbGiJk3XnRfkNx7Gx1/LBCiuCa0ZvatD1v
	 yiLYhb30T0ApLCBqLFPpAiUq44f/mqN4eILN9MpghNhHX2auHNEayE6L8XcJNglV8IQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IGua9sbi;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE37460A262D;
	Fri, 23 Oct 2026 20:01:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=IGua9sbi
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2F1871F01825;
	Fri, 23 Oct 2026 20:01:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792785692;
	bh=83dTVyz0p3AkNgmbCP0B/0Rsb2Y7EcIdwhNXZ0ef3CU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=IGua9sbiZvxXE9t5mnd9LaHC1TIZfDMAaoXaEO3+IzeRAzJW74uBbIpURdPA5E2F7
	 OR1KmqBWnTfAQTWkQkp8S4+9uE3jFoC/D8PFl24WwwwCcoH8NeIc3uZEDNS5l4YoYK
	 FxmWgnP/yVZRb72cDWfPJaf6+GGRfV1A4CzF1MCE0DsqSwkewSWYIXpc5c07sfdnW8
	 ThdAOh7/nakAzPmSXazynTO6Erz+EhSn/zjMNj+6WMMxdKQf04QOSG7NUSY3i7Gzsy
	 n0+UTvxUZl7CQXBUWzT7ErJ0IBRAPWXvEEZCKj6JsgcN4TLAbsr/QR0B2DLNF01OSt
	 oH3cWINARbIOw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 57222F40069;
	Fri, 23 Oct 2026 16:01:31 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 23 Oct 2026 16:01:31 -0400
X-ME-Sender: <xms:G73barP9AXVm5jOgncs3VboEjrQujvNFP4z8w-jxW8zt1J096JBDzQ>
    <xme:G73bagyrWpJuBwpX2tlUc2b1tAQf2kbq3xZ37wX_zub_uKv3iSs3OQcRXdvMIvnkb
    00e8_XrTrjT626866BNM_VpURgDCA1L7Jjvcj-w7puokwcto3lismw>
X-ME-Proxy-Cause: dmFkZTFLSgFQCdwjP+L2UOGlp4WBYK1w9l8llu21sPp5qrLcIM9wEhZ5L3lCE5gVar5uoV
    0yXU70fnczRS7CeKNq4kG2axPkKPLlf2zruTC6G6wf8jtkvf1PQnkbfb7OU5eKXgAggKW7
    1dnMDtSM6msg+UOTpcS1Jx1AeIcfXNMOl0ycYI08D0bOPYt/3mD8s9PBmBAcN9MDeBJZNP
    r9ivTRHOAr7NtHBxO2bODLqiKzdD4s+CGS2tZwcLgBTwgkMuQAFpyvQff0KoIk6VpgrlBr
    bb3RLpjL51WkCBGwLUpQwIRW4YyB8BYzld7nU7mxmPzJJNCeWrBjkJDdICnEQmUA2g6qU+
    Zi/Y/Vbg1Ct38fmWOLUkk1Gt6+o8ScL2Espptc8SIWzJ4b1pCeCGCPXyRzgmxeDLk9ym6p
    BUsrl5aFv667VTJ+YSld4x19p8BVONFBk6SbEjw+ZUP7PTdNenbGeOYpRDRUEt0J4zhc50
    6K0pSiSXm9gIFEo2mciW+qT9HEY5y//Q2q7eUW6OiRXR17j+5WDmhAQA7Vh/RfHF6g2wwq
    0TErGVKVS30EUdJoHvI6ttUDNATMdUmBdszS7lCC0q33x5QAROoReJlGSyNcs4Md65CY70
    pPQ0Z+nsltAraVnJ6BARJRVclWQm0vKiPcRlWKOkXyPob6Hskm4xowKmWHFw
X-ME-Proxy: <xmx:G73batZUw0A_D0YznD8DjEUAuBJq751BFaSStcFGkjFEf-FMv1oqdg>
    <xmx:G73batW8p94nPpt75Hl6C_le6M7DRkAimv45xGoRJvYGrT212l_IPg>
    <xmx:G73bargMqKEBLRL6Cs90K7fmSwyUyygeAngWzG9bHhlLgnaxtcUTTQ>
    <xmx:G73barv7CxGzL1kdYWCnxnMLGdqorpe_MnmnuR6V-v0NrGEPrqL07w>
    <xmx:G73bak6La4kGGtadX1viPaWU-wkIH6kiVrN4wVxtcZKtnQnUZYqVUx0H>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 2257E78273D; Fri, 23 Oct 2026 16:01:26 -0400 (EDT)
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
X-ThreadId: ALXHXgarDijJ
Date: Fri, 23 Oct 2026 16:01:06 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Avi Weiss" <thnkslprpt@gmail.com>
Cc: trondmy@kernel.org, anna@kernel.org, linux-nfs@vger.kernel.org,
 stable@vger.kernel.org
Message-Id: <f5a152d2-2f76-409a-823a-b2a7bc5abef2@slotpi15m67>
In-Reply-To: <20261023084819.609293-1-thnkslprpt@gmail.com>
References: <20261023084819.609293-1-thnkslprpt@gmail.com>
Subject: Re: [PATCH] SUNRPC: Fix TCP-with-TLS transport class identification
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/23/26 4:48 AM, Avi Weiss wrote:
> xs_setup_tcp_tls() assigns the ordinary TCP transport class to
> a TCP-with-TLS transport. When rpc_clnt_add_xprt() is called
> with an unspecified transport type, it inherits the class
> identifier and can create an unencrypted TCP transport.

Confirmed: rpc_clnt_add_xprt() copies cl_xprtsec into the create
args, but when the caller leaves the ident at zero it fills the
ident from xprt_class->ident of the existing transport. With the
wrong class pointer that ident names plain TCP, so
xprt_create_transport() dispatches to xs_setup_tcp(), which never
looks at args->xprtsec. The TLS policy is dropped and no error is
returned.

The effect is a silent policy downgrade on a mount that asked for
xprtsec=tls or xprtsec=mtls. The primary transport still completes
its handshake, but every transport added with an unspecified ident
is a cleartext TCP connection that the xprt switch then uses for
ordinary application RPCs. NFSv4 trunk discovery is the main
caller; the xprt_switch add_xprt sysfs attribute reaches the same
code and is also fixed here.

Against a server that requires TLS, the added trunks fail to
connect and the mount loses the multipath it was supposed to gain.
Against a server that accepts both policies, the client sends
application data unencrypted on those trunks, with nothing in the
logs or mount options to show it, even though TLS would have worked
for that session. Nice catch!

As a potential follow-up patch, xs_setup_tcp() still accepts args
with a TLS xprtsec policy and silently builds a plaintext transport.
Nothing passes it that combination after this fix, but a check that
returns -EACCES when args->xprtsec.policy is not RPC_XPRTSEC_NONE,
mirroring the switch in xs_setup_tcp_tls(), would turn any
recurrence of this class of bug into a connection failure instead of
silently using cleartext.

Reviewed-by: Chuck Lever <cel@kernel.org>


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
