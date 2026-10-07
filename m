Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4045737647B
	for <linux-nfs@vger.kernel.org>; Wed,  7 Oct 2026 21:43:39 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791409420; cv=none; b=nbIvuBhoHvJ0AFqj8l9BA9sHko8Bst13cLD6I2mqrY5Ru3LMZzOodOuCL4umzPPM9vL/vx2NPMVGCLbb5N3vA3jBKf9NqfjAjaFhQKZyekPkWhGBlfLI6ysUCq6kpgPX6vtb3tgHsboHXGxqEiEPikRfBS7TlBHarX9w9p+AOKA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791409420; c=relaxed/simple;
	bh=2xQzAL255w/ZHCkdrsklkDmtBaIFS+RKJEOhTRiefzA=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=mwWzRk71ffRM8OXzwclLPmT+tp+RvsSXGOqgsD1dmhWxIqiWiio4rY3AltdQFU7PzGcnnVG3QJpgoM1LcoHx3aR7RRKApR6Ck+Svp9yevrVmU1Kn2Rpis+J6UDav6QYx7VHevdeS1uQMQGx0siKDwMLSO8C1KpbxxFlNmMd2cFM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=oV7DIXTM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="oV7DIXTM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B29611F00898;
	Wed,  7 Oct 2026 21:43:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791409418;
	bh=fNb9NskaPfm1GX3t8y4i3xRDgEMW4LSqpQQp5e7UC4c=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=oV7DIXTM4zN+yNvcKKF/Q2VBAphvhRElZ63cjrzTJvqkm5L18502TIOeT01L79NrU
	 gv1Oevl/NBXMIXTWZQS2y/o9fjQagOw815cwgvSg3a0RuXKLn5stZyPYUInl2F05fG
	 bQYG79j6DzmvE0/dvsunrq7LbmGYQOvCyTk8mpaQXyvxQ6MAZm/7gUJ2o3OogLeG5c
	 izyzDRTJFVAigrMXlvUbEcoW+klMOjoWG52o+IapjGsbx3c1pLO3CGjoUzBaOu4vpx
	 ek7WRTfN4AwwOcA81eXj9saLQj4KtZYtn7jNwsS6GeU9MtGhLI1XxDM128J+BGLSB9
	 kj29r42iY1KLg==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0A507F40069;
	Wed,  7 Oct 2026 17:43:38 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Wed, 07 Oct 2026 17:43:38 -0400
X-ME-Sender: <xms:Cb3GarmiqXcd4j5mdMNm6SaSERLQGrjsm7r8GhrBt9ILu-ntKquVxA>
    <xme:Cb3GappSh6fY-4klazUcWnpOgyi1JiSsfXu0gGL6L8xkCFP-mjDcgexNxVVzEeE_8
    0Pv5pLJu_KtvzPsYY9qdx6dx1fDM4s1a6XyCdw-r6xP6CTEWOiJqBQM>
X-ME-Proxy-Cause: dmFkZTEBFNvMZzCpSRYWq1DI/E1RgLshA0I47xmHEIIf6UErzRFl+nnM14yvTNGeXlx0t5
    mHaJKFg3dfRWBWYncWR0lQfkMZuroMbok53kIJdwWCRsiSmbj+EoZK/LDn1NK3lbkK3kaw
    kJC4sKJt2flHV+yMB8BVk1A6r/9enjeFPxFqIll2xICKgnnkh+AFuoDMTG1YdS2jjxkHuO
    En6MsJDqtY+vxhOz83nQH3mDNVtp5OOaif6HTHRqiANqBSpJz8Rwbo2U18sECk3bU77Pfn
    zY60+ZxGreYrqrxXf9jZZ/kdFVSPAkIcIsocIoIctitZcmIJ8v5A2j4jYdEdIQckJVDpoR
    +UuXYBzO74E55083XVybE3KKdE0+OOjPRkXsbU2f/6poXVFeOB5D7WCi+0bujcq0U0trzd
    Ki9byKrXoOwMQQOhZNhvd8VImpZXAi/rpW0yzYjDRkCaewyYooeAqDH0AZs6M9wmXvwDdA
    OOPU5EU1LcxROzZAxJgLOjxAcG9n4njHGYZwn6ivIyK9KMON7k0HwGu/uja+eoDqYOw1FN
    qEmv3gspNkhfNoP5LYJd4Wx9fVkeUaVDxWw8phAmq9J5ACnPxLGCfgR9vJaygnbF35+vXY
    tQZtOqDjM1z068BTj5DDHstCIIkEKnLH9fhIDjotxU92X0rPMN9GpL2kMzIg
X-ME-Proxy: <xmx:Cr3Gah95mLG-vvoqTtyhMIptE8cbrxNhhDKPeKiTR3ebOmtaHrcinQ>
    <xmx:Cr3GambaALSHSnckkhPA4EEvYDiPD6ifTVORWehJQLvkLvswAiubwg>
    <xmx:Cr3GatN1UXrBbwCGVw5dW0bqB2NrDEUTUvR6shX-eI7Zw8oCL8c31A>
    <xmx:Cr3GaqAcXC99cRzBnz0aij2ywd77VwYXESleyOcu1CEojFja5qqDyA>
    <xmx:Cr3GasJLSoOosCwS_vSobgLihU-N80XGZ-_2EZR2eIU0lgbUtQmdBiFv>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E0A38780075; Wed,  7 Oct 2026 17:43:37 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AamgRIaDwhGw
Date: Wed, 07 Oct 2026 17:43:17 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Daniel Pidutti" <Danny@lightningiq.io>
Cc: "Christian Brauner" <brauner@kernel.org>,
 "Al Viro" <viro@zeniv.linux.org.uk>, "Amir Goldstein" <amir73il@gmail.com>,
 "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
 "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Message-Id: <95f498e9-02fe-4a3a-af15-0ea1f7ec2531@slotpi15m67>
In-Reply-To: 
 <DS4PR04MB984629798B7EB97DBB56117C8D942@DS4PR04MB9846.namprd04.prod.outlook.com>
References: <20261007164648.50493-1-cel@kernel.org>
 <LV2PR15MB538107FDEB65AB1A4CEA8D5EC6942@LV2PR15MB5381.namprd15.prod.outlook.com>
 <DS4PR04MB984629798B7EB97DBB56117C8D942@DS4PR04MB9846.namprd04.prod.outlook.com>
Subject: Re: [PATCH] exportfs: Release the get_name() directory file synchronously
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 10/7/26 3:03 PM, Danny Pidutti wrote:
> Thanks for the quick patch. The description matches what I saw on
> our server.
>
> I tested it on the kernel where I found the problem: Ubuntu
> 7.0.0-38 (7.0.14) built with this patch only, 64 nfsd threads,
> vfs_cache_pressure at the default of 100, and the same parallel tree
> walk over about 43 million files and 5.5 million directories.
>
> Before the patch, unreclaimable slab grew by about 90 MB per second
> and reached the 8 GB limit of my test script. With the patch it
> peaked at 1.5 GB in the first two minutes, came down to 0.6 GB while
> all 64 threads were still busy, and stayed flat until the walk ended.
> Open files went back to the idle count once the walk finished.

Thank you for testing. May I add your Tested-by: to the patch?


> One question about the stable backport. The Fixes: tag goes back to
> 3.10, so stable may pick this up for 5.15 and 6.1. As far as I
> remember, __fput_sync() on those kernels had a BUG_ON for callers
> that are not kernel threads, and that was removed around 6.6.
> get_name() can also be reached from open_by_handle_at() in process
> context. Could you check whether the older stable kernels need a
> different fix, or a guard on current->flags & PF_KTHREAD?

Confirmed: the tip of linux-5.15.y and linux-6.1.y still have
BUG_ON(!(task->flags & PF_KTHREAD)) in __fput_sync(); it was
removed by commit 021a160abf62 ("fs: use __fput_sync in close(2)"),
which went into v6.6.

The Fixes: tag has to remain unchanged, since it names the commit
that introduced the behavior. Since this fix will go through one of
Christian's VFS trees, I can post a v2 with a recommended Cc: stable
tag, such as:

  Cc: <stable@vger.kernel.org> # see patch description, needs adjustments for <= 6.1

and note in the patch description that kernels before v6.6 need the
__fput_sync() call guarded by current->flags & PF_KTHREAD, with a
plain fput() otherwise. Among the choices sanctioned in Documentation/
this one comes closest.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
