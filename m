Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A1FA2556BA9
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 18:37:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792175832; cv=none; b=DZL+MUTSuM4cYRvgzZ+moR21EvLHLNLS+CTdJwjI+JFoVzzLuYTlJPRVNwSbIqk8SrFRuiVv3M72YT/B4Z6Conz9iAGnck6QF2lQeyqumV3jcpeEgYfpbwxJUYlkqqSRwxBDcdsta3l4jsLT8/7u3r9HyDEyOPjvyXF8LY0BsjE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792175832; c=relaxed/simple;
	bh=Y72N7Q+UJL0WvMo4SOXiRa3TJYDyg4fwxoiQMGHDLsQ=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=oM3vgI71RxaDQJpCawSQ0z/HpjDFZFBlt1D5G8Y8ck07hi1fMsXSOWCXg3/7TlwjJ0fcS9KVqRpK05OiPhz1pl7M81odLu2IvDUUoUSQwG1Zt9WtV+2RphegpNbJo7bdmnb287O0CJdGKfpoX+fBL56jqS8zz8zf2/6lvWbR8Ko=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=K4rb1Qcc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="K4rb1Qcc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1FA501F000C5;
	Fri, 16 Oct 2026 18:37:11 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792175831;
	bh=CIiUJXN9ppwsapWTQHD1yCndjogup7HHozzrqh+lUJA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=K4rb1QcciePA0NhVeWR80NY6v+cQDfeYB9BMzDebuCYK3wKjHx4xDACV5pWycffSj
	 xIVF5zaei4pXM0kNKsy6quoglaJtjozJrILZHhB38ba/HLrBnX9Mrg5KMU1Wjr+BOR
	 dA+LthgUSRooPT+7XKHpmDv/fZlIEyRLMtpLbvz1ch0sNHyDn8JIRRZQEw+eVk0IFF
	 qxHQBF4iEhBKT8oxNWl4yHVUj6RljHuqmixs0TPQS6MQBRfg1vHw8hL/tOYnOX46As
	 zAkEUAUwsJp3c/fYuicAtBpW6tsfDEpVBbo3W8w7X8njbByxvY5WPI/qTNofjskllh
	 pag67LOGAPXJw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 387F4F40066;
	Fri, 16 Oct 2026 14:37:09 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 16 Oct 2026 14:37:09 -0400
X-ME-Sender: <xms:1W7SajU3o0eeHnbLq_R-nZ3cwzYqDZgcK8Op0l-SWP1tPw9ymPn04Q>
    <xme:1W7SambzgtoQhowgpzo3R2EQjdSowPnyqY62iTk6C1VrJrs9_wCGf15s_hJnkZCcG
    ZOOFpHecisWfxBhEXrdDWNUm1Wi4HN80oysMi1zokTNMbcXa7fb4XaV>
X-ME-Proxy-Cause: dmFkZTF0/FGLHdPDrCIUsBYvGPyL3FJjefzp3oaq/lWe9hAuun7mjGxM9pgPdoc8pE8lKs
    AXwkYsD6zXi40RkJdxsRBjkQSHEuVEbviXM69lVg9OmntIgwdXMryYauBV8uivqQF+1lhx
    V0NeHxDAMi4bV23cmHo/P+ahu05RioRyPAO701+/iDH9rzgVznl1f4nruiU8V+1umOcIv+
    IamWE/l2HMLsiXucjg0Y9Bc7AoM5Rs/3RAQx8XRmMTFZhMVCz8AHb5La0ss0/ccMBccyh5
    grUWWENMnHpdWjqlySg7DwLKpNOCBYEOnfINZe7ygHbqPiuIuveHti6zgeFHXq2ym6OYjM
    bKdz0bzhIdp4+W9geta6mzvblf2GZD8LKidzG/VyQ34hO2PAIN8nDGHt/lA9y1OAHULpyH
    m9ezCkmpZTJppZFncyf9nj6a49lpteS/TMlpOtMJjmnou5K+GoQ+6TnI+IxPNNnLsCluXF
    jHnnVRuoJaklbsJ7DdR0UfzCKsCQTb71QvD6yDHuMlGR+27lQVFEsGLBAhsVrw7Ih8paNf
    vVPIL4CChVX48e0RGumBXUxRC2Rbl/7cc6haSHKWxzIFvX64D7/Zow3ALo2Ii2Xj+GmUX2
    Gg6+E1zZhU80vbYSqVtFHsE8TlQbiwZeCVwTrnAC0HXD0HEYTHToX4hjPR4Q
X-ME-Proxy: <xmx:1W7SauCorEqsMwLc6E-mC7T_Pp7WOvdts2w_5cQFv6OyWuA5gmJTlA>
    <xmx:1W7SamytNTzEQshhTLrW-ExKd96-5qBuhVYhZpqzwQCu8VotUn9VWg>
    <xmx:1W7Saq4iiFtZ2ECW2a5yIdZNgjZSjyUqEbfq0JQFH6qsOYHsGcM9MA>
    <xmx:1W7SavzqaxuA3_h3yBrOsb4bv_h4tRpAy5JkDEzn0tD6hguVU5ovuQ>
    <xmx:1W7SameQLJqUrOl1YaweY4BF8aK73IS0MEztY-O-N6viTihaAz8MH_4r>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 13A4D782738; Fri, 16 Oct 2026 14:37:09 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A1bjWCdmgco7
Date: Fri, 16 Oct 2026 14:36:48 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Matthew Wilcox (Oracle)" <willy@infradead.org>,
 "Jeff Layton" <jlayton@kernel.org>
Cc: "Mike Snitzer" <snitzer@kernel.org>, linux-nfs@vger.kernel.org,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Christoph Hellwig" <hch@lst.de>, "Jens Axboe" <axboe@kernel.dk>,
 linux-mm@kvack.org
Message-Id: <ca089229-de04-445a-a40a-d4559ad4908b@app.fastmail.com>
In-Reply-To: <atIQkYA0AZg_z53_@casper.infradead.org>
References: <20261015233309.42999-1-snitzer@kernel.org>
 <20261015233309.42999-8-snitzer@kernel.org>
 <1299ad92163f2eb8fecc06165b3b52f7904f09e9.camel@kernel.org>
 <atIQkYA0AZg_z53_@casper.infradead.org>
Subject: Re: [PATCH v4 07/10] mm: add folio_mark_dropbehind() to mark a folio
 dropbehind and account it
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Oct 16, 2026, at 7:54 AM, Matthew Wilcox wrote:
> On Fri, Oct 16, 2026 at 07:08:41AM -0400, Jeff Layton wrote:
>> This patch and #8 need to be split out and merged via the mm tree.
>> They're related but the rest of the series doesn't specifically depend
>> on them, and I doubt Chuck wants to carry them.
>
> Patch 9 calls folio_mark_dropbehind()

Seems like the best plan would be for me to take 1-6 and let the
MM folks take 7-9 with an ACK from Jeff and me when we are happy
with 9.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
