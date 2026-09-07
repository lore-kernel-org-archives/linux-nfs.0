Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 199EB3A7198
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 19:15:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788808546; cv=none; b=hN1okJif6llSuXqKB1XJ4ps4wGySpaNd4YLDQQZTtB/ujygkTJ2m1wtq+twslQc8tO4ZnbU9YmlWpTxGUZjwKt7jZfZ9lI8uXM8+fGhBvDdecgsVAT0+yVGMP+7AUN08xh+HZ6v+cfyGd25fFEa7AC1zo5J1K14ZFfEl7jtDkOY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788808546; c=relaxed/simple;
	bh=XQXhzDCg2dhhu1WnZjNPmpaah8H+eGUxRVpDiA9aivE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=YGhhKNqOQZCneZAZxjNbWx1p2Ojl8nv8BQ50L7nTDX8fSu3N42i2D7Ph6MuEsRxgFkezivOOmBP5O+B2TNnEg+BvZkokq8Gm6Nw+6d1TiP348rDLGRdKE4YeF5HAyGMGepocbJKlvStehg2nl6hPD0Es3TZIFMAljnblhjM6LRw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=g0cSj6gQ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="g0cSj6gQ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A31F41F00A3A
	for <linux-nfs@vger.kernel.org>; Mon,  7 Sep 2026 19:15:44 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788808544;
	bh=tiXZzvH6IH4UX6JC04NiKtmHUrGl1MNxToT35sq2QiQ=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=g0cSj6gQKa4854Tbs8A/nuK08z6ueEgBcypPe2TwH7Pp+7XezeFSk0v9b2PylfX1N
	 qA2XYtaXaENWsL+MUBCUOwhuOAb1rwDcctCbyOk/V5lf3Cs8DyV43+s8izbRPhHCGA
	 wvj89PqNljsWxUK0NXjAcZyDjjaazUOnDKET1k8DB3SFT6iZ/1U1Rh/UNF//DcUTaC
	 4UnHufSBMBiIn6KeBdHqH2RQhAcT9lNtOMeDOzvuktBqxrrIMqccXZH3OtuTt+1TV2
	 vrTJrDj1tYzXICXpVo4GFiq4Rtf0p2yobo1QVth7lzPXEGsotujHKFYGEPAMeV6UH2
	 mHYjobaVPCdyw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id B0AA4F40066;
	Mon,  7 Sep 2026 15:15:43 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 07 Sep 2026 15:15:43 -0400
X-ME-Sender: <xms:Xw2fakR5KFhVaI_OeCrdv_MVw1BFQTsCKj-SR4ohyRdQ_YVLMMjJkg>
    <xme:Xw2fasmNbYQW6TQ_iccyb3_kPzA3DEHRnjNB2tbXIADDNg-rFKF3xdMNc3JyYZ1Hr
    kWfzUBSxl_6GlgY_6CkMcrJ4EUOTs-MQ7GGuJg-MEXYWkfoz7lI94od>
X-ME-Proxy-Cause: dmFkZTE31xTmpyx5/rgzD8Yn08Xp4dnoKBm2ae8X5WOcf4Nj45ZwRG470q1Aox5KXGeh2t
    TpsnHVsFD9kjkEUj23D6SUarxwbsP724jABoOSS7UY7pOOSC1/xhrO4PYgof1WiFCNzoEO
    YC1TkKYWR2ITL9s0/4H/qHdmiEyBPEj913Xs4vPyibFri5o823i0tDIUGLhAXEiy2YHE2a
    tsG8h2sxphjOCFk/THMegNieNjeNq5/m6dcMeEL62dKB12/bb62uOpwgk+Imjp11GMOWGv
    W+XPF3l5A8zuc4n011G4Aj30S/jpsEHsenFcS/7SeGknsYjPS+PyAlK5t9mzuRGRbG8di7
    36oVOC0Sh0DwvT9KNs7RBOWA9S367K/s+xIRQ3KKfPRa8mLHTTWyKXau45EXIuO8uwtWVw
    ckea5qv9mioeT7GoFpwXDr5bODsdJSh0lR3YCcnDYD9HZ6J/iQVuG/KHYEYA8AIE9k3WIE
    qRwe0mQhCYLRxw0nebiKp7uM21PuWuBzC8Do06rl+E5Z3hHSRx2dqFJ9c+D7nd1yIobZ6n
    4Po1Wg+/hlZTgJlQzOwPkOm7+lSppg9QFKefQB75DEOj9ZqeLqu7gpi5AhE14w2+kxZEOS
    w4VeUuS0AqtISQbAj6oLq1LIgMgwFvXvMvgnd2oDtx4lDqB2UIJ449LGBdrw
X-ME-Proxy: <xmx:Xw2fan-0rlntAvegWvXUU4z1huJmpBB1_ev7Ti9D9ETFIrFTQHwFFg>
    <xmx:Xw2fatBjjpA8Py1MmdmiWCqFEOdpeNNcaXasdzVAwkt_K8O9hezVUQ>
    <xmx:Xw2fasQug0R97reVNhSK-iDNbVhpGOc6BX50C-wvGfKIUG_e4cL-yA>
    <xmx:Xw2faksgv6uw04VL1nwNIogOy8mE6yT7XTet71q2_2cPhGBRliLOmg>
    <xmx:Xw2fao2YkLTqQcWqqsORg8zmuIfuMgmktjhCL4eJLJU3xLOvd8qD6lYQ>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 8E4C37811F3; Mon,  7 Sep 2026 15:15:43 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AGBspSFnGaaV
Date: Mon, 07 Sep 2026 15:15:20 -0400
From: "Chuck Lever" <cel@kernel.org>
To: syzbot <syzbot+d5c77cabf7a3492aa650@syzkaller.appspotmail.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
 netdev@vger.kernel.org, syzkaller-bugs@googlegroups.com
Message-Id: <4c018446-e4c0-457a-b2d1-a5bf856d0e2e@slotpi15m67>
In-Reply-To: <6a9ef807.2bb5a69c.24b23c.0007.GAE@google.com>
References: <6a9ef807.2bb5a69c.24b23c.0007.GAE@google.com>
Subject: Re: [syzbot] [nfs?] [net?] KASAN: vmalloc-out-of-bounds Read in
 rpc_queue_upcall
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 9/7/26 1:44 PM, syzbot wrote:
> Hello,
> 
> syzbot found the following issue on:
> 
> HEAD commit:    df2908090cda Linux 7.3-rc2
> git tree:       git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
> console output: https://syzkaller.appspot.com/x/log.txt?x=1416cc8e580000
> kernel config:  https://syzkaller.appspot.com/x/.config?x=8c5c3949d762a91f
> dashboard link: https://syzkaller.appspot.com/bug?extid=d5c77cabf7a3492aa650
> compiler:       gcc (Debian 14.2.0-19) 14.2.0, GNU ld (GNU Binutils for Debian) 2.44
> C reproducer:   https://syzkaller.appspot.com/x/repro.c?x=14daa071580000

The fix is already queued in nfsd-testing:

  https://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git/commit/?id=8e5890ef0296

#syz test: git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git nfsd-testing

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
