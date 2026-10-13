Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 67B32521890
	for <linux-nfs@vger.kernel.org>; Tue, 13 Oct 2026 19:10:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791918614; cv=none; b=o3NcdE+XhS3TVF2eKDuBwR/S1vgSUoyz56m3EOPRAxFY4Sh3mxuxRTF6mz2jUJv+XHaf9SnS/RkEBzXvUr9Sj172TEgeSmyzTcxA0BbJj+wiH883+yJ9Cg3IPLAKYk1C4GZyAoTF96M2ikA9zU9jjhbdXeSsF7iScG+qIrJ9fUo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791918614; c=relaxed/simple;
	bh=kgDt0QtjD4rWqE26JI0a9S1+vEnqhAt5PUTkanFcZfU=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=YWN5rmZa9diGaY5mjkjNsY67ndmXB+50CZYnnPqFulaXRoSsMjymKsqZyxJcjjeIPy/9j97BWBArR0XXqOI6GdAMgVGCv07vsvE9zUzKKYXxu/b4DGruhGOl/zTpbDaM8HdqWr9zv78LR9hLmwghDBWWoXSuZ6Y2qToQQea+R68=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ojerFzHZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ojerFzHZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D0E851F00893;
	Tue, 13 Oct 2026 19:10:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791918613;
	bh=kgDt0QtjD4rWqE26JI0a9S1+vEnqhAt5PUTkanFcZfU=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=ojerFzHZ3Jv0HbWBtEvWogBd3/IjAJvSjKjmwWaJljCGEAtNjitfw+fz7sNCsu8HI
	 EQz2UD62CGs53pf7oUX6RFgilpPbeXzHYsnNYl6I0dIpRUKqzEBwzqn7xZB9RvDr4n
	 MzFDrCSgI6cdKwc6NK/LdB5hni0jfmYQtGEWOfBS/eLpuPqpK7vndmSUO7SYBlcDGq
	 Zf8KMlF4kCCvW8BaV8sjnHmiGEZIQwXMYq+vF+SmIXI5zVE+uOjZW2axd/iO300i9h
	 7KDy2Q1wxFg+hws2x7/MtXAP7pe4lTKm2NQXbaVMd7+DoJDfBaQ9Fa4Y0GBixhZeqt
	 5QrP6+Tq4Mvdw==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0B698F4006E;
	Tue, 13 Oct 2026 15:10:12 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 13 Oct 2026 15:10:12 -0400
X-ME-Sender: <xms:E4LOai7NwwzcOj5yPSHhAcrG0DFsxalVL1g2QCFRExdeqfBDZyNOcw>
    <xme:E4LOamuErD-5mlaxYBv3ZdHISliI-m8WGLImH_6EwyG0S9AZTAH_imJEMJnzOdd7T
    8UZyT7N_V6h4AIBFZNI46aLpATCeGBcTSqcv0kV1urFG2y_zp1xTWg>
X-ME-Proxy-Cause: dmFkZTEd2rtBwbkaWrWZrgOaUkT88gktJFrEb1+xB9o1IS+tF4mNpE+JoW1KBvYanzbv8H
    8AzTLM0sfXqxsSG43v2DDjP4caaBbtwOoyBCWgwm3F2vpqKZ4cD+zawhdI4WQzoshFmMnz
    Ky18dABWABv5alNWKLXmiRSkBIj86NXxwyEjFf0QhIGQxPLnQ49TScqRAOAT84yCMaQpo/
    gmAWziumX9+Ne3+8BSKagAy1p9GffjLtBAL23Glv9SNJVjeCjzhwLQOUcxQI1HhoIR0dee
    hsisNXNb68zWdc1tE8JS2Xr9/O3IOOBzD9LsNQEkLhZYsin+IVdY40SQrGiLLHbvXMExt2
    EHz45EJIdCPELCbDDlAyuv/8mIT9OyjKAPo0E+Y6okaAw905BU3eDeeVpTL5OUIStM0Exm
    v7VFX7ErUFpswDUYWxPYiPr2r/ESURCo1x77Fr+kxB7F03P39cXDbbJqoERGspF56RJnHv
    jCjwJhp/qk20ufp6fD/mO3p4Y+game6GjvBT1VYI+6aRDsRQwTa3hneI3ge4LZPnSH/wQi
    o+XbTIFkJewx33XrkBHVyNsFj0wo5afK8ScxKKcOjQIriHYcbKMJxFmAMbOIHZ8Pt0f8Mq
    BlHd8VTp53Sjwhx+38+e6zV2xGGBUgUiI3eHFKJbV6Uxn1F0gFlRzahJic0Q
X-ME-Proxy: <xmx:FILOan-jRc7qYnm5STOz9B6hlKAmAwBeCmo7VS0rat5K9PtMJkTfrg>
    <xmx:FILOaiyyB869pxSlApWtFY_2F1HhN9_dzpzsarsPm71H_83hY_Db_A>
    <xmx:FILOarMid582NGA4UWxH5T6bdpgRmyQ3uFTdf-V9dMUdo3qPTvX8NA>
    <xmx:FILOav-105pApJ_bNKqdTIbaXh16jc7r_NeqidZ9ovJwqfkDvPqRPg>
    <xmx:FILOag4m-jJ1-dmPmNOXvFGOtbAkFEwRRUYcIfw2XRpegKNisvinqzgZ>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DF2A8B6006E; Tue, 13 Oct 2026 15:10:11 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A1CqOqGV3QlV
Date: Tue, 13 Oct 2026 15:09:50 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Tim Menninger" <tmenninger@everpuredata.com>,
 "Trond Myklebust" <trondmy@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 stable@vger.kernel.org, "Eric Badger" <ebadger@everpuredata.com>,
 "Jon Curley" <jcurley@everpuredata.com>
Message-Id: <04579cd9-a4bf-435e-86a1-4d5e55005e76@app.fastmail.com>
In-Reply-To: <20261013135327.1695983-1-tmenninger@everpuredata.com>
References: <20260921235520.502987-1-tmenninger@everpuredata.com>
 <20261013135327.1695983-1-tmenninger@everpuredata.com>
Subject: Re: [PATCH] NFSv4/pNFS: Preserve layoutreturn seqid while lsegs drain
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hi Tim,

On Tue, Oct 13, 2026, at 9:53 AM, Tim Menninger wrote:
> Hi Trond, Anna,
>
> Please hold off on applying this patch for now.

Will do!

>
> Further testing has revealed incomplete recovery under sustained
> pNFS/RDMA I/O. Some workload ranks remain slow after DS recovery, even
> with the reconnect loop gone.
>
> I have not yet established whether this patch is incorrect or exposes
> another layout-recovery issue.

Makes sense. I'll keep my eyes out for an updated patch
once you track down what's happening.

Anna

>
> Apologies for the noise.
>
> Thanks,
> Tim
