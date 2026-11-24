Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795530989;
	b=suHbb7Af1Utchx45t4yUA8cal9L6MC3tX3P/VMrp7hDC1z5JyECmtK98xRymAP4wy26u
	 Fx2E4E+EoCR/e5z6Rp5U5u741JzNJ0ljPi1Zmpgejp446lnNgXClv6e188+1hj58wou7m
	 oB0Btlih0T9NLKmJ2h8Q+KVb5AWOIeyMd4MxqrjyCR6z5P0lV28SWtsp9IH2Ek2nizICj
	 Fc51PttN9L1Fj4Pwb0+WPXchDQv2UTk8wqiyvTPO3j3n802tkBotHZNtb9VnHvrSlubSw
	 9BWcQUcoU9zTuBRLVR8UFqZJ+M/r35hop4kjKaOK+jFqPKuQ7IlyAgzC+5/7Jt040jA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795530989;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=Jk3Z5typ32yZTZJzY1EkClsxvv6xevcLP/OBucW90vM=;
	b=y6T7oPPSyusnjKGRPipDU73u6NFabvgtvrE2S+wtxQyj18sstNNg7jE9suz0BSKXJzXY
	 bSXWagB9aG4P8rduve5Hq/3ITyhsg5qngzTDUQZ5GPQFkfUR/w4v8YQDXAdRjHAcgSJgL
	 F5f7xMLT05XaDrDqDHsAYpnITlZT5hJRe/Mz5viigmIRiaQ6scxh83Z6vYDBeiKNoYq6h
	 iHnIx8wsfZSlDpWlQBegonc3jrjnCaRmvaZ5xVq+LsNudvXpi/yr1qsyUrK4+jqEZbtAD
	 +s3Z1knGx/a3yVMXSvNzgGphefiBuko6U3tw6fdxIuDwXPXPGiqUlIV3KmdYbhmvtRA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EyG51qPw;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id F1DF3606A31E
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 14:36:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EyG51qPw
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F02651F000D0
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 14:36:27 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795530988;
	bh=Jk3Z5typ32yZTZJzY1EkClsxvv6xevcLP/OBucW90vM=;
	h=Date:From:To:In-Reply-To:References:Subject;
	b=EyG51qPwrnmGrpk76pPVh65/BrqYPaP2dZTeBhMUDiVt4ZGx9SkgW4uudv9X7ITqI
	 cima4006YuqFpauGtuPTMyow6NW/tUOghqgbg3RMFLImBrUJkoQRaukFrAp+Nm0CWJ
	 2AoKp/HY84XiQ0Q+sen28clfUsVFttBoHGHGRnnF/9fh4uxNSx395bHO8MZBqHArcy
	 OmASfKnxk1LVWB39F3/L/ZsKUAvfT+NlOY8uOIruYe7UI+hmJk99aQq/kWphWVDD+k
	 ehzJufWjfQKHUNINtaAFo0hdoirN8Fe4QrbJ12JqXgY/g7dG2C7RSYBSlEQ4+/T/Yj
	 QZ2+e66tiJ2ug==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 043A8F40066
	for <linux-nfs@vger.kernel.org>; Tue, 24 Nov 2026 09:36:27 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 24 Nov 2026 09:36:27 -0500
X-ME-Sender: <xms:6qAFa4yMnsjZfHSeSzMrKkBk_vSIzFKD4GrQXSyUpli8t41kvJi5Fg>
    <xme:6qAFa3FzZrKVl41oiUIPIiqS0A6TcWTSnq0RB2FLGBDIh76p1aABDEuDCdouuhVIT
    9X5EKeJVw3o_y-luzX504plRU6E5E0mKhlxdHiNac42RyN-6y2Kkt45>
X-ME-Proxy-Cause: dmFkZTEYy0s9Yj6p0xZ0drFBYKg8ISTN79T5NxUX9wp+4BouGIhGAGed+oPS4ddk6Nlbtv
    G7UDYgxPiX9NRjYyJZ8fiPwVq6XhXkPqcQo57c73YN/GWKVM+9qShuIZdNkC2Y0Y9SxUsk
    TJSfx1sxVtJEFO/N4KZfy2Tbb51y69Jhaye3vpOLcWl0PT3K+nXc/Mi6vd8L3fbiG9GjeC
    NdRoS2rzf6KFjw1FClhQTEeqcTyQ5M9wEp8zu6+AoEnCOXhEILzWWSg3zaZS8ipKPlkH3W
    7/XHKoeMkhV4QAtyIjGyRWOupNIa7+uzOKQO1yb9RiIgMCAV19U8QcX8naojQT1vf3DsaE
    lpGPkxIY6mHfj6/AH9IdwIZmINWHICtwrKl0/5xNyijvA1Y5hBvV/Iudz5Tw0owLh8pLRG
    FaCIJKcpHATBDSR9evAVyMhH3MzEjLpdgFo0yZyvSAEDfdOdF1YcGEdSVtiVM0qmPCnMM5
    PgP0/FEXN3m/uvf87P+4Z9j7OEWhfy3GsiqOHeAd13uW1gA1y99l/tgqq0MzHhmZBAWAYh
    i8z0+pdUHYX0SNf19LH1llSfg3umLTz4ZRlbaByJnR1rW8q27rJn3GDawJHklrr9pDMxLw
    pLuKtA8DNomDWTFnM7rorZJiSlxktfQLTtHJfBZMpjPtYiLch3H11IkHWztA
X-ME-Proxy: <xmx:6qAFa8D_UIm4YLyUwyLr4ws6EX6vL9n6Lfo7UMlk-kLVlNLGAFtrOg>
    <xmx:6qAFa-fluOrQDqffdABi7GZB1xaR1l3XR_lYKhjY8m4cWyQUTh1gqQ>
    <xmx:6qAFa8diYPNFAD8VWlFPnZxcKxUrvgBKkg8euHCcYo0qIbXQHT0vUg>
    <xmx:6qAFa6jF55s_R5_jrcECTNyAao0Q_ClYKXj_Vihn90nFA-rRQ47elA>
    <xmx:6qAFawQiI5MwrFukZgyN9VBIMBTKx2cz9FecHa3TzfGPAtsUqxJmDxJo>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E090A780070; Tue, 24 Nov 2026 09:36:26 -0500 (EST)
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
X-ThreadId: AKzItFI1RcM3
Date: Tue, 24 Nov 2026 09:36:06 -0500
From: "Chuck Lever" <cel@kernel.org>
To: linux-nfs@vger.kernel.org
Message-Id: <7c0d12cb-4483-4a67-a8a5-5ae75c9f1e32@app.fastmail.com>
In-Reply-To: 
 <CA+1jF5roNowGUBSAS-v7uC2GzZTgrLzXD_h_HLVuKOsb1qMu_A@mail.gmail.com>
References: 
 <CA+1jF5pNXvipBz8Hh3LWn=H07JJGEJPVH_hWZYCE8GhB96kvgg@mail.gmail.com>
 <6bf939ae-c29e-475c-9261-0cddfc31805a@app.fastmail.com>
 <CA+1jF5roNowGUBSAS-v7uC2GzZTgrLzXD_h_HLVuKOsb1qMu_A@mail.gmail.com>
Subject: Re: Which Debian version has working krb5p support in NFS server?
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


On Tue, Nov 24, 2026, at 3:04 AM, Aur=C3=A9lien Couderc wrote:
> On Mon, Nov 23, 2026 at 3:28=E2=80=AFPM Chuck Lever <cel@kernel.org> w=
rote:
>> On Mon, Nov 23, 2026, at 5:03 AM, Aur=C3=A9lien Couderc wrote:
>> > Which Debian version has working krb5p support in NFS server? We tr=
ied
>> > to start a test campaign with krb5p, but that project stalled in
>> > September because neither Debian 12 or Debian 13 seem to have worki=
ng
>> > krb5p support.
>>
>> Have you reported this to Debian?
>
> Funny thing is, the Debian people suggested asking in
> linux-nfs@vger.kernel.org, to get a list of known "safe" kernel
> versions and "known" broken kernel versions.

Nothing you've said so far indicates whether the problem is in the
kernel or in user space (nfs-utils, libkrb5, or a configuration
issue).

krb5p is working on my Fedora systems just fine. Please pursue
this more aggressively with Debian to rule out a distribution-
specific problem. You can tell them that we aren't aware of
open kernel issues with krb5p.


--=20
Chuck Lever
