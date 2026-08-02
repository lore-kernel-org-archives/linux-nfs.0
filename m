Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 76B7183A14
	for <linux-nfs@vger.kernel.org>; Sun,  2 Aug 2026 01:50:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785635435; cv=none; b=T/vPQlxxeYP86QmbWLFP6xBK7w4xXNFaSNvCNwdFvDP/e86lbWExNY+uxkil+fjI34R1IZsFh+D4QfNtnOchFzmF/M+CfrtSXR0D0V0SUR529uPm2/HMZG4fKw7E7nLHvx9Et5GMWy+cwG9K0qQY+GN6RfZua2YPYF0K1gLZFa8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785635435; c=relaxed/simple;
	bh=F429MZEqske5y7LhhXLzz6tcgRvhuf2UlyTcyRfVACc=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=mTyO7KYh3nNSwg4KuUcw3PUShmFGY0/nNhA0vAknDXL2O1sfr/fuUksCiyyWCbm8IYHMrbQqhNeYD4MK04d92nRuQJKxsW+zlJF7GiGPmD2o6FHwWkFKAXcrZ66294KKA2o+9srze6d2tJwDRSbVBFQBeYgEFjPAqWbzrkoAaQQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TCHMdN3f; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TCHMdN3f"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 207B21F00AC4
	for <linux-nfs@vger.kernel.org>; Sun,  2 Aug 2026 01:50:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785635434;
	bh=zGWvYk2SiE5J1pZ5G5PfJsN0bbe1brbynbXV4hXJXyc=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=TCHMdN3fYz/TEwQ4CjX0Hye5wtE1jd5bwmiq8VOcwKCqSgu4816vdfMTUIH2gbt/h
	 fy7eMjieEb6x3M4x9yeo8TXAHNJd3o9bGVzA/rmcmQ8sVPA9KwPNMi35yNAS7M0+L0
	 MBo3a62HrhXaixAKvt3Wx5sitKJZkXX5iMM9WpZz95KqT4pX+KWSeoPPl+5q9tyysN
	 IaNkdXO1jdeygfHbdArz87uw5zlPjT3aCubtCkh9YsYnM4cCEdL1KCPDuv+UiqMD5t
	 UNLkDs8t9tm+ffcLs9fMyabz1DKTvYqhZtQGDAIXOqUWjyS7ZsGXI1A4aBz7O+/Rdy
	 PTqgNfVP7D2ng==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id F3BA1F4007A;
	Sat,  1 Aug 2026 21:50:32 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 01 Aug 2026 21:50:32 -0400
X-ME-Sender: <xms:aKJuaskksP-74myyIPER2VSPJyMSdCn0HHYRGMHRTPdYCt5E0JvyRQ>
    <xme:aKJuamoT5zFX0mNGGjJdm_zzy9ed5HVhPAoWdPQtGY1WeICGtGeNKxisemb4KKxWr
    rWWtX5_pg-JgwQBYGfkN6DWIew2QrYLZn9i6psg7mFKQZBgvKtUVKQ>
X-ME-Proxy-Cause: dmFkZTFrtLORwI7j3QVS2sSLb7ipREVrb8rFLK8zJ5h7lP/3Hw0Q5ZaETTO9tpuuSNrHZd
    fy8akBZEB1es2wz5jZ+ik0w0+l9MuD7IR65p0GboSUjOz1MIjhyY1l9zQYxIB9oG9/bdIS
    rrHtNpX7F3rkehj65xcKSaudnRPQQuUHpdEDK4qmBLa00Pjx2vrnBbTXwYLIl6+O+875mF
    IwAWIbvZQrWU+uoiESmmo0GRAGIxQIAMt4uvO9LJf4IhdzKnezhiE2SJQzJWtpLB34NVtr
    re/gGjU5L8xtpCIs85alUKVAGGhKKU1HhzDQKObkyee1o1kC9AxRh8S0yaDpMp3tfBDjbT
    Gdj15H98yl3ZE7ViiCb57Z4Mo74pxqCXAhle7BIdztm798DQKmGohDMLKK84VJ+ezJCjZC
    KsBfhelBUiPb8x0wulocRXCdUY2sxIaR2njWmfkwIkh7wR8PpKmQhvaId/GHCK8aY990zz
    Gv8lAquDlELbLUr6K/u6/D1mvJ2tPR+vTF8XMT6s0wWd6uBvJ1DaAhpgzCjS9rwRgKWv1k
    XxKnAWFdCGs5uYBCzbWRiae2D2UBJ2CVTtYPudf4auwcjPQOW0Iwj3e82+lUVd/fsjtngm
    BiQpmrhIP54tHj12XrDwgr7jj1TnkOv+0m2qjQF7RtkRcY7fBBfbDSGIXgwA
X-ME-Proxy: <xmx:aKJuahj2QhPXHRHsR0KoKWXlT0UJSZkJhBgZl8scS9MBa0zDzdaYPQ>
    <xmx:aKJuatzbhvOXf8MIxdGpqwaSzILB9HVbgQVN3yWzvYHhA6sU2ZRpyg>
    <xmx:aKJuakLAJLuF5DkBW5HzWCQgXE7VGGoOx1CWWlJroVJPZgWFVER8hw>
    <xmx:aKJuakSpyjYk0oTMCl9UU6AQ7OaXUxupAj-4aD5D1NCWWdoQogEIKw>
    <xmx:aKJuasoz4NgxFx9aV7Mgtvln35IwgUeKMdXZ90qwvUaY0Lmvrg9VxMj1>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C60C9780075; Sat,  1 Aug 2026 21:50:32 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Date: Sat, 01 Aug 2026 21:50:12 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "George Chapman" <gchapmancontact@gmail.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org
Message-Id: <e359f4e2-b27e-4e5a-bf38-1c46331e4e5d@app.fastmail.com>
In-Reply-To: 
 <CADjmrE=0LVQxWaodOXFyRpCSoJAShifsjJQ_VcqQXyAC-edJDw@mail.gmail.com>
References: 
 <CADjmrE=0LVQxWaodOXFyRpCSoJAShifsjJQ_VcqQXyAC-edJDw@mail.gmail.com>
Subject: Re: [BUG] NFSD: write_unlock_fs() has the same pre-shutdown-check UAF that
 92ea163c773c just fixed for the netlink command
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hello George -

On Sat, Aug 1, 2026, at 3:32 PM, George Chapman wrote:
> Hi all,
>
> Bit of context, my name is George Chapman and I'm a cyber security
> researcher from the UK.
> I'm sure you get a lot of these but recently I've been exploring
> AI-assisted tooling as part of my own security research, using it alongside
> manual code review to look for bugs on local Linux builds.
>
> I've recently found something and want to raise it with you please,
> essentially this report is a product of that process, an LLM helped me
> trace through the code under my direction, with everything checked by hand
> before sending.

Commit 208b023eef24 ("NFSD: Prevent post-shutdown use-after-free in
unlock_filesystem") is already queued in the nfsd-next branch.

You can search the linux-nfs@ list archive on lore.kernel.org as part
of your research to determine whether an issue like this has been
previously reported or fixed.


-- 
Chuck Lever
