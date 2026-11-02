Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793654102;
	b=Vl0jbq1YddNvBA8YmyzyA2STUSMZ4etYWnNi7jt1lpUo7xCEFcYuJjmDrQZuARKh/2tb
	 Bgb3q01PgDlIKi2a11DWy4HSgXq222cHQTcgZSPQDzvxV2q5CZ8+VricdF3am1uwHQcwv
	 H4Oc2AVCGsV/TjGKtRfW5WM654xKLKyc4rKw6C6TkA9JqHTCBC4J5v+LbGz3ZbjfZF3Ru
	 uJ+1TwPV6/OrKDvv2uYKrfE4ZhSuKbnVIuB+FpQ/fE25Cg1hd6qzm5r0eecIbGkudbCer
	 DZQnE3kFQ+aJXeXlCTdkGhXBvnSCqB7jNJVF2FiwkFGDpYlhMjwUwOB2Iuu0M+f739Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793654102;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=IboT5prE1F2zgLUjN3M8JJkwTsSKYt9w9Q1ZY5Lm5jE=;
	b=hLYDz3PA19h9Y9dZiVnP5KwgeXd7vQh2nzZMMsKtGA4/+GXfXVeGyjgmnJBnNTyKGs7J
	 CHvEMMxiBaFEd6reHxQ0goHYWX4Kz5PPYb7te+xj5lQLdKORtElHXzr6T3uCZXsLK8P8C
	 b8praB0HyoY1n34SYZZcwGOSC+x7lsTk2gBBo5m3IZLJfwUQmMl81Q87wbeXNlba92r3/
	 7oVKzyXOCAt/nuDAXFsp3JHi60/Jxt71HS33yRdxmND3M3hbuMLJD4OglFZZE+Nsl6xD+
	 m4CbrgSgL+Au+9CGoMp4d3X/ZuUC5+OYZm/nOBkbkHjF3GPqz7Dczif4TUKQT7iZRAA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="i4XS/+Qp";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DC7B8606D834;
	Mon,  2 Nov 2026 21:15:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=i4XS/+Qp
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 405B91F00A1C;
	Mon,  2 Nov 2026 21:14:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793654101;
	bh=IboT5prE1F2zgLUjN3M8JJkwTsSKYt9w9Q1ZY5Lm5jE=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=i4XS/+Qp/XJpkpHyhLatkkxrTnb76H0AyrbluP9UrYsSjjvFvYed65zWeP+n5bDMR
	 T4jrppxwRxmsiUoLJtpEDBZOQUgSEb2I7JAqNJICoUtmRZqGDSr+AkbMY5KraB9hcp
	 LJSetra0CCoguNvIXys8kMbF38qG79C7rZIljzi9OxsucTBr2qJtAKy2hNxphivV7X
	 SqR7z4TvF6OS2jxQo3eWdNU0GD2TA876qUhcb25obxs7Qa0hq+gMR1c2AKZ0TYfXxl
	 /PRnwvUkfYbroZLwoik/xUkslivJlp+q60cSPVqp80BDXlYt0jmnPbIlU0+2JbsucT
	 rjIixFbj3/TrQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3FB84F4006B;
	Mon,  2 Nov 2026 16:14:59 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 02 Nov 2026 16:14:59 -0500
X-ME-Sender: <xms:U_3oagUAPKL0KahIhejOYJwKEPfYb6twqYG_HHugM7_eLn8Er-TgPg>
    <xme:U_3oavZTuzGHMfK0qXbinG0nc7CYskrIhJQ5eHOz_Ha7XvQtwnXU_T7hJPsGo9qg4
    BhXiwA3Pdzj3QiIOE4JzHYJnc55BkwZtZcinLkFBcrDsA6sylLxQvo7>
X-ME-Proxy-Cause: dmFkZTGSCWblgfsMhzNjEIN00ph1bmXztXGhYrK6FQCSJysx8m5mqsCTJHkCuZD0tpZuBG
    pYnx6qST1krVMCyjpYhoMBo2TltjSYVP2LKGOkZnOBb4t//k/nGoJ/SIXKKJyIATQl84il
    BuXRlRV3aPeB88TAd/llIDq/9PMZ1EzorVjUV4ox06mXS/IOKUqdbOTFcr2gFtJFq3Gx7F
    Zq0nEujwlkDiPcDOX28riG6oQW7iLTgD6BaMnfnV9H0ADvTknFe8adm4EFa+o6I1mSuG3K
    LJ3epAVfTBg3DuzNRu88aZuYWYeuI7KoVJah/eioVIkx6sAoHZjqyTVRvcNhYqHYgvNdOh
    F7RoapMXPpPy7fnRDGp1EnOzRafp7mYLbQvUWevKonPpL0zVugnrni/xwOB0ZUdq15K6LL
    U4eIWAyGEDjfaCYO/Dppo1HoBBuP1Ugp4Zki+kXZHcTkA1gjEQVaV70KrwrPcut26vPd/h
    q5yJSVyn3x/Ch0xklWbVCXPbWoaIS17brwWPL/guaVzJxizQ0P/jgX0plm53NXTsLd+70V
    110yVl467ZsRMKGBWdC4JnWQHbcxAMHjeZkhkyAsfOuCVSLebxwzvInrQKLcoImyb5UwHY
    pO0Oc+d4/j2oJCRnrCOkOe51eLIclfMVgyBLq7y/6qqZiV8XA97NvuTzr1lg
X-ME-Proxy: <xmx:U_3oatxqYhX0hWpcSGJgdTO64UmbQLn1zkSvkgmn2QN3P9YNu5WJ0w>
    <xmx:U_3oav5HgW2k6KeJbHXAdQUNPTjXcBKAkESvLUwa5JME7gNZc5c0tQ>
    <xmx:U_3oasSgNqIt2BaGeBZ12VcERyFoy0lpk1cdl0eiT57vWKlvWpphXg>
    <xmx:U_3oaifZ0cTDaYHT72Jch7KjTqrgvVpyqwgckwFzCeMt7Uwl9HyKaw>
    <xmx:U_3oapwU7EvPML2sBaImLYgTk9SsDSGibfYemkcHEOBIYG1GVrkdWT-b>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 181AE78273B; Mon,  2 Nov 2026 16:14:59 -0500 (EST)
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
X-ThreadId: AlKaHQIBeldV
Date: Mon, 02 Nov 2026 16:14:38 -0500
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
Message-Id: <961e7e3d-2117-48ee-8a7e-a7a851ec8ef8@app.fastmail.com>
In-Reply-To: <20261102-work-procfs-fs-v1-6-d09a996317b3@kernel.org>
References: <20261102-work-procfs-fs-v1-0-d09a996317b3@kernel.org>
 <20261102-work-procfs-fs-v1-6-d09a996317b3@kernel.org>
Subject: Re: [PATCH RFC 06/27] nfsd: let procfs own the seq_file of
 /proc/fs/nfs/exports
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Nov 2, 2026, at 10:07 AM, Christian Brauner wrote:
> Declare the seq_operations and let procfs open and free the seq_file.
> ->proc_open() and ->proc_release() only set up ->private and take and
> drop the reference to the network namespace now. Reading the file then
> no longer holds up its removal.
>
> Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>

Acked-by: Chuck Lever <cel@kernel.org>


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
