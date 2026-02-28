Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2BA532E4274;
	Sat, 28 Feb 2026 17:03:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772298196; cv=none; b=f9qvmZ9zyC168fvBpDiEyGi9no0iLEzHsSKeq8o1HwGRBpTSlgBik5VnqZ1obPQITO4gZD1pD9AzkD+HzF1bsT/T1b1WbTDr7iJgF/UqvNblRHFDEUm6IlHoojWWr7IS/dJJr5LaObHk8BcL2tCeMKyfrMLpwGl93csh/6uyLx4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772298196; c=relaxed/simple;
	bh=opqLZKqNnI++/upx0AwCYnXibnHRb6eb9IWHAB5RD3Y=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=C9Qi0khLH2lfTMRUaUxkZfM3nILtWXqqOzvdOqCaYB7y+1m+5dNrX/2j6q42HzSyzzLEI44p0dvkxdZcX5uqYHz2cXCfEVC9yBgzP6ecNjHKZPSPgSM7jVN9fyuG0u+2mnfmcU4WdDVwf05l7ucBAeUQLbuBUr18LD/VcE9AFi4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dRVlWni6; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dRVlWni6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4A068C19424;
	Sat, 28 Feb 2026 17:03:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772298196;
	bh=opqLZKqNnI++/upx0AwCYnXibnHRb6eb9IWHAB5RD3Y=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=dRVlWni6d4fshi8cYcudxMAt0rLYg2Mx5AqC6YYC/fyww+QnjJp6Tk0u3eipyHDh0
	 KFkSrRiii8NiyzDxsGyFhfQukMXoULQiWeABmSozdo544JBOqe95lfBjnsj5h6T2nA
	 WVSTH7j3vwxFtvWqsb/aPcj0ZYPPLisgD/sqRq2Uas2exal0MmNDGqvIqdtZdowWwc
	 gTzZQj8kg2VXQUAbslGTvmv0WJ87skdzleGOf2fvbQ18PVMI2YoOzZVdl+MIePle1q
	 gVkyXcmBdqDsNYK450JZpCKM9ijvqFvUmjegLja14GBdvV62LKV4x15zvQs9YQKRV0
	 qO6BkDxYmQWNQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 513BEF4006C;
	Sat, 28 Feb 2026 12:03:14 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 28 Feb 2026 12:03:14 -0500
X-ME-Sender: <xms:0h-jaZ1_HN1_FOUSWNrGxoNabG06nKoI21d6I0L0J9pPiMCM95kIIA>
    <xme:0h-jaa43FGZDZq10aUgVOwJbsBvXRF_4AP9tj4gKzFnq6P1H5HUkde6miQjn5KDd-
    PKfQLMxsiO3FhNhL1jYqOM9pBhyZ2JznGSKbJ_-Lwgo4KJ9ZHnBtRw>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddvhedvgeefucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedfvehhuhgt
    khcunfgvvhgvrhdfuceotggvlheskhgvrhhnvghlrdhorhhgqeenucggtffrrghtthgvrh
    hnpefhffekffeftdfgheeiveekudeuhfdvjedvfedvueduvdegleekgeetgfduhfefleen
    ucevlhhushhtvghrufhiiigvpedtnecurfgrrhgrmhepmhgrihhlfhhrohhmpegthhhutg
    hklhgvvhgvrhdomhgvshhmthhprghuthhhphgvrhhsohhnrghlihhthidqudeifeegleel
    leehledqfedvleekgeegvdefqdgtvghlpeepkhgvrhhnvghlrdhorhhgsehfrghsthhmrg
    hilhdrtghomhdpnhgspghrtghpthhtohepvdefpdhmohguvgepshhmthhpohhuthdprhgt
    phhtthhopehnvghilhessghrohifnhdrnhgrmhgvpdhrtghpthhtohepuggrvhgvmhesug
    grvhgvmhhlohhfthdrnhgvthdprhgtphhtthhopehnihgtkhdruggvshgruhhlnhhivghr
    shdolhhkmhhlsehgmhgrihhlrdgtohhmpdhrtghpthhtohepvgguuhhmrgiivghtsehgoh
    hoghhlvgdrtghomhdprhgtphhtthhopehjuhhsthhinhhsthhithhtsehgohhoghhlvgdr
    tghomhdprhgtphhtthhopehmohhrsghosehgohhoghhlvgdrtghomhdprhgtphhtthhope
    htrhhonhgurdhmhihklhgvsghushhtsehhrghmmhgvrhhsphgrtggvrdgtohhmpdhrtghp
    thhtoheprghnnhgrsehkvghrnhgvlhdrohhrghdprhgtphhtthhopehhohhrmhhssehkvg
    hrnhgvlhdrohhrgh
X-ME-Proxy: <xmx:0h-jaee-oEB2ztOzVUzjcgdOkForXm6paqwzcPvPrnv1qf3UkrgS8Q>
    <xmx:0h-jaT6ii0tYw9sybwPjmqPiImEjRyz8KbtVtL1R8ClYptYzO17D8g>
    <xmx:0h-jaaMhqI8Kun0DZgA5Fz3mMTD5w0NUH7LmjMDiy7zRdOB4bUe2sg>
    <xmx:0h-jac4LPWOOsAPHJ8bGC6NaPqvTd8Bewfc_A6hnLm9_FUVF74o-Cg>
    <xmx:0h-jaZxaPugMGPmtL1yly6vRQ0j4Pkozppa-bcc1OVnSKHpsUvNwUQuz>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 252B6780075; Sat, 28 Feb 2026 12:03:14 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AwZUiapUpQnw
Date: Sat, 28 Feb 2026 12:02:53 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Andy Shevchenko" <andriy.shevchenko@linux.intel.com>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Trond Myklebust" <trond.myklebust@hammerspace.com>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 netdev@vger.kernel.org, llvm@lists.linux.dev,
 "Chuck Lever" <chuck.lever@oracle.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "David S. Miller" <davem@davemloft.net>,
 "Eric Dumazet" <edumazet@google.com>, "Jakub Kicinski" <kuba@kernel.org>,
 "Paolo Abeni" <pabeni@redhat.com>, "Simon Horman" <horms@kernel.org>,
 "Nathan Chancellor" <nathan@kernel.org>,
 "Nick Desaulniers" <nick.desaulniers+lkml@gmail.com>,
 "Bill Wendling" <morbo@google.com>, "Justin Stitt" <justinstitt@google.com>
Message-Id: <bf983b54-6a1d-4520-b07b-29cba47d5665@app.fastmail.com>
In-Reply-To: <aaLNTpODbiNCwmps@ashevche-desk.local>
References: <20260204202437.2762161-1-andriy.shevchenko@linux.intel.com>
 <177024270291.126397.9981743455921781902.b4-ty@oracle.com>
 <aYXDpqqM0qrEVzvy@smile.fi.intel.com> <aaLNTpODbiNCwmps@ashevche-desk.local>
Subject: Re: [PATCH v3 0/3] sunrpc: Fix `make W=1` build issues
Content-Type: text/plain
Content-Transfer-Encoding: 7bit


On Sat, Feb 28, 2026, at 6:11 AM, Andy Shevchenko wrote:
> On Fri, Feb 06, 2026 at 12:34:21PM +0200, Andy Shevchenko wrote:
>> On Wed, Feb 04, 2026 at 05:05:35PM -0500, Chuck Lever wrote:
>> > On Wed, 04 Feb 2026 21:21:48 +0100, Andy Shevchenko wrote:
>
> [...]
>
>> > Applied to nfsd-testing, thanks!
>> 
>> Thanks!
>> 
>> FWIW, I have got a success report from LKP.
>
> Any estimations when this appears in Linux Next (or even vanilla)?

Applied to nfsd-next just now. Should appear in linux-next the next
time nfsd-next is pulled (Sunday night US/Eastern, maybe?)


-- 
Chuck Lever
