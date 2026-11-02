Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793653907;
	b=W8o09YfhRAt7/Uf/W60wgP94TwHiB5PyJIfFJggQXwCkp+bmUuE5uc7TgAP2C9jl4wzm
	 hh5GUo6DV18sUU44PTTIklDvhzNMb5NhEv+XoDaQtMOUJOq4HHnz1oYdY/xFvpmWmOXP+
	 4UH4i6hqfbLiGNJ8pz63rXasqFQu/o7ighYrwSJXyzduyz3R+VA0dQnXX5ZAHt9wLU7qH
	 5dZsZlsFIO9AVPgpNw9WFsiRUwGejlpKJYlADq1K+b/n5zgQRLRyM58mqdxUf6VquoQsW
	 X0TBpEivMQ70kvuqtZQJLHYQJEpGjY7W0GpA0bt/kwSHdSODTTOVacvieWD7bcuKTjg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793653907;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=xxWoHxsw4VPFqHPAqACZbusTmTkHUnFSnkXXJwnJ4WA=;
	b=mJdlIVJJriiy4tGT6xC+gAAmFRR2mON8MjBfuiZHV8Hmo6hfDicZC2gk4QtJxDglGM5K
	 MBShJBwXHzYjlAM5qRXOotA4vCvbBNku9acs02zBP+9+38A6kSkwt02NyUorpBuVexLJp
	 W3vmOzj1vYepJUMsjG2KrpSmOIBveiivt0MQ7BAbz8dLzP289bE8CgnKH7eanliDwGX1l
	 AkkObsQU6TrBmk1rjEl324SqKkVii/U074zY6b03OGW+gxlS5DNoKhQ4pD4F0wFQ/8PHr
	 pi2vFgJ5LhjJCpxChY6mmu7bxcg91Jidsv38VJxA5MRU+lyezkI0PndHyb6EzdfMO9w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dNDBoidi;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6A250606D810;
	Mon,  2 Nov 2026 21:11:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=dNDBoidi
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5EBC91F00A1A;
	Mon,  2 Nov 2026 21:11:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793653907;
	bh=xxWoHxsw4VPFqHPAqACZbusTmTkHUnFSnkXXJwnJ4WA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=dNDBoidiMHuL2wzZuLuAcR2y81xpCDgwkS0jPMiuOz1hDmQcHPBHVLpe/eurDeIc6
	 0QP40mIGdVms2YJGGkVjr72DZQ3Qy6LGB3WJi9fpQCsfISujOiuLPDEsN3HhDVyYJA
	 NP0R0vcCve7pFHXNfT6Jbv6dCtnUUfz6t94JpXfv1SOy2mrpqjHCbhlHo2EL0lzabm
	 VaCmh0/DUDyv4apj0JsUnQZAAcYnhzhZND7bT++OdNcHv2Pb1I7aSrCaWuC3IHDIaI
	 92lPqtkbxGUwGCbUiY4ifB/boq31hhx+blzjeDbp2RPYCw9C+nXRNYRT0XdHWa+zUI
	 ljjUNimhb6KYQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A6FA8F4006B;
	Mon,  2 Nov 2026 16:11:44 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 02 Nov 2026 16:11:44 -0500
X-ME-Sender: <xms:kPzoaoxuxxTdjPhQc-3C1zahFZ9aLPvFlowSXGC4R9C8GitGRfcHEQ>
    <xme:kPzoanGt2jIbLsy47fOpg3WSZ6PY5cBPEClcODOsbon89QNyNk_IgDaAKQadQr2gv
    uVji238fOMsmLse7Ab600gs9JzJ4DZGzIXqA8TonRFGYfmnT8t3fbcj>
X-ME-Proxy-Cause: dmFkZTE7nCOuYmDhbapfq9wnjcJo8I33hiQgEa8gG2mpUd6SiuGVjxefYxNF6ts7apvhL2
    O5TBTvvYo35j+hcPabsgTVdffpGt9MvK5vyw0ZMRJyC2vP2RybIncEIE31yiniEOHW+BGf
    KJmARPQ+h8rxdMmbqHuWCrc+Rw3W1Pf0ttMp3mPjsGk8H3PuZMLxakWBNCayAXhn4arSzS
    SZT0vmmbKnAjrINdR7jALY8t/GQLDesfw1v5pO7HM0aidEkcoMk/IX3mKuG96bBGSC44od
    6j/8Jj2EeiKpBxuZiOuoARjnD/H7MmHLm4946WLbdldIeKehhGb+AjzJw7psiDGcN84+AT
    fxd1ztnRd84WKFx7SmijybVrXSJKl1AR6Etu7r8JTz1E2IGG2rbVvLkvpR2IBVnXEcQUHC
    r3GDkPNpHJrO1FrRX5A6DIGX8s2wqnE6WbRRhP/2UYux7WzU3qFcGt1leEKU+a12CXazx+
    obllJ0NCoPjY5PVFTCgHM6NA+K8OAWAC3Y3QpVQ0GtrFfYBqHxRpcYNa889BVVJkMXM0Xx
    NfAqx7SCTsESPLk/r6Zjs10FtyBDV2ONG987Ot6HPmAwX9PryQz/c+/GTZobKPftcCgNbF
    dMjgQuUNaOpeJy2SLb+WxTNiYQx6H//DcXk9Eak51jjRY6pefZcEU0xUdZXw
X-ME-Proxy: <xmx:kPzoakX1575s1xPK_eRnHKHwfrJs0dh41R1DNgFe6QjSA1GNvloQig>
    <xmx:kPzoaucrAaHqLBPd5fXUJKW90uwtgM36P2rOCnTrC3gEediQhDxGvg>
    <xmx:kPzoaq1brQHn036GXHRWgb2TJPEUtB4n80avLnuqxkDWgbKvmiH79A>
    <xmx:kPzoakc8_jk9jC4iv-WEqTZu5jnNeZJxZR4JSbSaITEBNtWbgxkbuQ>
    <xmx:kPzoau7BSrFGgoTyo_PA1CYGAey1sR943z5_XGLHZHfJ_ObFFdVmJ7Se>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 7098678273B; Mon,  2 Nov 2026 16:11:44 -0500 (EST)
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
X-ThreadId: AFgPYeWZplpR
Date: Mon, 02 Nov 2026 16:11:23 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Christian Brauner" <brauner@kernel.org>, linux-fsdevel@vger.kernel.org
Cc: "Linus Torvalds" <torvalds@linux-foundation.org>,
 "Jann Horn" <jannh@google.com>, "Josef Bacik" <josef@toxicpanda.com>,
 "Chris Mason" <mason@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Eric Dumazet" <edumazet@kernel.org>,
 "Thomas Gleixner" <tglx@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Jonathan Corbet" <corbet@lwn.net>, "Christoph Hellwig" <hch@lst.de>,
 "Greg Kroah-Hartman" <gregkh@suse.de>,
 "Joel Granados" <joel.granados@kernel.org>, "Kees Cook" <kees@kernel.org>,
 "Jan Kara" <jack@suse.cz>, "Jan Kara" <jack@suse.com>,
 linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-acpi@vger.kernel.org, linux-kselftest@vger.kernel.org,
 linux-s390@vger.kernel.org,
 "linux-scsi@vger.kernel.org" <linux-scsi@vger.kernel.org>,
 linux-um@lists.infradead.org, linux-wireless@vger.kernel.org,
 "Linuxppc Dev" <linuxppc-dev@lists.ozlabs.org>, netdev@vger.kernel.org,
 ntfs3@lists.linux.dev, platform-driver-x86@vger.kernel.org,
 coreteam@netfilter.org, kexec@lists.infradead.org, linux-pci@vger.kernel.org,
 linux-sound@vger.kernel.org, netfilter-devel@vger.kernel.org,
 dri-devel@lists.freedesktop.org, ibm-acpi-devel@lists.sourceforge.net,
 jfs-discussion@lists.sourceforge.net, linux-alpha@vger.kernel.org,
 linux-arm-kernel@lists.infradead.org, linux-cifs@vger.kernel.org,
 linux-fbdev@vger.kernel.org, linux-hwmon@vger.kernel.org, linux-mm@kvack.org,
 linux-sh@vger.kernel.org, linux-usb@vger.kernel.org,
 samba-technical@lists.samba.org, sparclinux@vger.kernel.org,
 linux-m68k@lists.linux-m68k.org, linux-doc@vger.kernel.org,
 linux-serial@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
 "Takashi Iwai" <tiwai@suse.de>, linux-input@vger.kernel.org,
 linux-raid@vger.kernel.org, linux-ext4@vger.kernel.org,
 linux-modules@vger.kernel.org, linux-debuggers@vger.kernel.org
Message-Id: <7ee779f9-db3d-4829-bdd8-1d09e3f74c43@app.fastmail.com>
In-Reply-To: <20261102-work-procfs-net-v1-6-982104a4f592@kernel.org>
References: <20261102-work-procfs-net-v1-0-982104a4f592@kernel.org>
 <20261102-work-procfs-net-v1-6-982104a4f592@kernel.org>
Subject: Re: [PATCH RFC 06/11] SUNRPC: let procfs own the seq_file of the cache content
 file
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Nov 2, 2026, at 10:07 AM, Christian Brauner wrote:
> Declare the seq_operations and let procfs open and free the seq_file of
> /proc/net/rpc/<cache>/content. ->proc_open() and ->proc_release() only
> take and drop the module reference and set up ->private now. The
> rpc_pipefs file is unchanged. Reading the procfs file then no longer
> holds up its removal when the network namespace goes away.
>
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Acked-by: Chuck Lever <cel@kernel.org>


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
