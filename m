Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0B9F24AB1CA
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 14:15:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791382540; cv=none; b=W4gn+qQKPSKla9Tet2JauNJuxTd3DPjvp6I3PrJzalJjBgky8G0sidRTqGqVMzdrXTZkh/6k9nAa/zB6DufYnojujpYX2QX7i5vV1/tfnSFQbFmfZEGCLBJjEBWrtaeBHE1u7/vixyJwfudyabaYPtwqzGNMPKsnjA4Jb4H7yTg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791382540; c=relaxed/simple;
	bh=6DZ9S8a+OVGA8K4XhnYCLmwvZZSJ0P1X64+aeKr4tB8=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=QVhvkcdp7KwF1wg3ILDGqiGl3616cjur+R9sktzev5vPNsrj9F2DmGtOtAo9gOVIIIOE0nkfeKlVubc2PNEWTSFMiNTaGgBD0W3vYfmZQeeEbfIHvF413o9zzF196A9/UM/uwDqDk1XJGJS26jRQOVzqFf2xVUFs+7H5SzBJSoc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=d7tRRz6l; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="d7tRRz6l"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3CF211F0089B;
	Wed,  7 Oct 2026 14:15:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791382532;
	bh=wJR4AdIx3NyAK1iOeQa50RByB9CaN7iPvuuPToNKzyk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=d7tRRz6lr6uJKOnI/mYncpVCeiw7Bz29P4OmnqQZHQBtJc/P249QLM807kWe5i1J5
	 ojYsSwMsKAQ7MRkSxyEjw8ISlmhxz01+KrSadgikxCixGLnBM+cIma/ZRSNxPgKaWt
	 DW2verdtwzYI4N1n+dRk0YG2d2lszkIlua9NKK8CtO/oA8HLqxYgNFnRxlRPmzzRLA
	 K+lnc2WZf4lR5bREAtDSnhuxQ2HRwrCpS4e8mn/ZfmwAwPOqb/Y5AVlhYgwUwFk7+5
	 8zw7tmOQA/wz8UQSy5HAq68FqtiW1xkYLOeUoexP+ub1Al2iEmuSYatDTtUAGzJQeM
	 Gvyk00Zbz4HzA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 7BD72F40066;
	Wed,  7 Oct 2026 10:15:31 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 07 Oct 2026 10:15:31 -0400
X-ME-Sender: <xms:A1TGarOg3p7hxynoXF0WcHdaSHSwhUDeODlE8IN4qc3Lv6LyrvGCJw>
    <xme:A1TGagwSvuOmf77SDDqzAZCxRdDS-8qxDryaaYciaQ3qziN2nQysayuxmYzJ5-gI3
    fHha63Sm8FgQpHZ3ygR7nJxT9sOtAhXwrg0_nA8CgSzhXSgt6MgCtA>
X-ME-Proxy-Cause: dmFkZTF9Mg2h1jYac/CQtQHYJKoF5LSDa2YgHUJ3hbogN5jGBl+8m1gffAlC2qN9eyXAky
    /gg9BRjyTATBSSGbLiVwmeISfi3ViW+aW8w+tU3qGVBP2/8X99j8Pj0VmMkBYlnILTASvY
    MF1EYoh4df8wVCVO0FXF/3qeCDzt0VHKRTAB1xY3zXeuYNOoVNghCIEdhxQERPWYRBYYeO
    Gtn2+N+NItjcIoI6W1cGIQ7BcjTAQNOWCZT487nGXpqEC3pvRHec/JE+sDAl9UoGew1XPb
    0OmnCifZ7tJFC34lK7TzOC5BNrz6qfmOrFVO+rRrq3BT9mL7ZRcKqiVbxi+naSTizNSScF
    qpsof5TwhANQnpVAB8LZevOWWFaBKG1PlDQW/vcJNHI8L10pWehdnoZnXZ2Bh4ugDouMrZ
    a8NF9vO1H2FaKVHt6a9CR6CWoRcWc9GssuRJNhwMxmKcpHiK0qUvPnInlUENUtBjCU4Z8j
    y/yWyAHj39KA9Ny6uii7Rg3RA5RqZugkEtpmjhQCL8AF6D6YqCCQb8MLZGPqJXTQiC4yBT
    w2FtF3aNsaW1yQbNKGzFHS0DZo2gGyNHIMBMnOzBGmlf1J011WMGbeanYJKnD2JuAxTMmZ
    idNmvvZKEIzt7IgcM8F1KerTC0EB3jOgPY8vIkpqCSv454rTIIOlttqGGD8w
X-ME-Proxy: <xmx:A1TGajx1rvp_WLWL2lEVCELmMMEtw5N1uX6Alp7b8CFzS19Ks5F2FQ>
    <xmx:A1TGasz8jBo5VdxghY2ij29QBSNjD5e2c2gO9kIb9Xn-LtUPjdDh7A>
    <xmx:A1TGatanTCIqpM58euTI99Pbk2zdbtPzpA4dyG-6EAnyzMAL7wFk4A>
    <xmx:A1TGatUTssqjUr2sqnTFVje5Kiw-i8bmjli4Oe3SVZhfQ3BYuDf8RQ>
    <xmx:A1TGargXOaA32bCjAIuAOZ1DRbjXCbb5tpSWAXE6xqwWOKos3iRPZU5e>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 5B04F780070; Wed,  7 Oct 2026 10:15:31 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AB0QkRkUO1Do
Date: Wed, 07 Oct 2026 10:15:11 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org, "Daire Byrne" <daire@dneg.com>
Message-Id: <0d2ca4ec-d7b5-419e-8284-2ed134302f91@app.fastmail.com>
In-Reply-To: <7840A427-7BD2-4C87-95FC-2E5325130CAB@hammerspace.com>
References: <cover.1790953694.git.bcodding@hammerspace.com>
 <cb5d00b3-008f-4876-b284-c8cbabfea3ad@slotpi15m67>
 <7840A427-7BD2-4C87-95FC-2E5325130CAB@hammerspace.com>
Subject: Re: [PATCH RFC 0/2] SUNRPC: dispatch ready transports round-robin across
 clients
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

The extra good numbers redacted for brevity ...

Also, thanks Daire for your user stories, those details are interesting.


On Tue, Oct 6, 2026, at 2:07 PM, Benjamin Coddington wrote:
> On the question in your second mail, an admin setting one table for
> more than one fairness behavior: the posted kernel keys on source
> address, so I can emulate "all movers are one class" today by giving
> the movers one address.

OK, that helps me understand the motivation for your earlier question
regarding whether I would accept such an approach. You were referring,
in particular, to the proposal to introduce a new netlink API for
creating tables that configure server fairness, after Neil, Jeff, and
I all rejected tuneables in June.

The design requirements have evolved to need some kind of configuration,
because a single NFS server is frequently deployed in environments
where several different workloads are active at once. The requirement
to protect fairness between NFSv3, NFSv4, and presumably LOCALIO
client workloads makes this challenging.

I'm not terribly excited at adding this configuration to exports.
Today, netgroups are defined separately, for instance, and exportfs
is just a consumer of those groups. Making it more like iptables,
controlled via nfsdctl, resonates with me more.

We also have the problem of using raw IP addresses, which is a)
not user interface-friendly (hostnames might be nicer); and b)
not entirely secure.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
