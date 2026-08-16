Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9B1F44B04B6
	for <linux-nfs@vger.kernel.org>; Sun, 16 Aug 2026 17:44:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786902261; cv=none; b=DRu0RKQLpNx9x+z6/jPZGg5uuyiMx6sYip7CpfCsNdVulpTaIpuwg3rL0cf1zpcB717z+vWwnT7YQNkMAmAoUakgjVv1/dZym/vqfQTF9huuWuhK/nr2v1rQsD1MtrkJvIOjFedli+0kspQkGynGYGlDYD//AjacZX5kIuehXp8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786902261; c=relaxed/simple;
	bh=ikCHD4uz8Sv5Zp+ogOVi+wL4lrTx/7z9bY8tOlH4dko=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=dHNvrzw56K64f8AtSa4X0t95b68B0Cb4Z1nvuvSQKKkmcb6B+GPONXhAypKKoMM8OOC/F0wEk8cF7zTJ2tSqwkkBwrVB7wkU1hMsX5CHIduuIe55TnHu6ftufjy2/+JBQViPnc8nJg7m9gsEmCTGpKITFEvCvk4U3oAJVuSNCgk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Up9/VeiL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Up9/VeiL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0503D1F00A3D;
	Sun, 16 Aug 2026 17:44:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786902260;
	bh=3koC8qQeXJT1PcHy8iw2Wca65JqUYiFncphUA8glpMc=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Up9/VeiLMNjSUc+Z3O6ffnctgN+myYtg6XRjbnRcK+5ibfb8s4qKeECQC28rfRMgq
	 5qJAOzqj8php2pUSu+g6tNk35/dpH1VKb+XufCMKMI3HeBuNhjDikzoBqqdG/BmfqO
	 zRlLmJM+LyukeLaWSWvzXePq1EGo2vqdPTrmyU4en+FREXkE8QYKit2xPsJbUL+Yh6
	 wwpwYtNp3bAOVuoMPDkBfbe3QkIKdSiufZT+vouhNvaTvnqgTbQ2Sc0BC51em51+DM
	 NK2zTeb3W+sdQpEPrDDM+khBTWeR1C+qOivBZuP0mQo47s1KtTWTwSTPl1RfOV6Ltw
	 hIUUdkpyWdisA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 20083F40066;
	Sun, 16 Aug 2026 13:44:19 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 16 Aug 2026 13:44:19 -0400
X-ME-Sender: <xms:8_aBapoC0xnRxhXrLdCYUWWMe3AlhFUN8WhHnMIS9bLWoGCff_bDPA>
    <xme:8_aBamdLtWCgBYNTEHdjmDYLj4Vf1gqlpgQvhnwRB-1LRrGjCyO9t3tvAELml5hl8
    JOGm18ZOHrGjdjWBk7RU8EFHJt5RsChN4OLffZgEVG4q-IU4ry6c0w>
X-ME-Proxy-Cause: dmFkZTFYDtM91glfzLd46r91F0+xfaR6kW3HyR5E07wiz6J94gDRwXikdW0vGDhp7BGxPg
    i8+BbxvWJo15WI2SewmJ23WVl/H/QYX+7NcyVcLwBXYt4MUxsr6gvjZehFM9aQWR9GUes0
    Q3aCz96HIE9OcwKV2rYptV6u7/6LImgR/P+7Pvrao9R5mKEmhS07JSCXHaD8ehSuxH4rry
    kR3aizXPiZWS2JkC7UYxm5JIXASe5vfUnp9JEfArqJeq6hBYApIn/TY35M+lDq7dYBtJLh
    8GxoXmhCXT+B4TY5g+7naKYC6aBUMIs0bDOQLZujC959PHUm7m2u7iOetb55MFSxrUkMm0
    QYzrgFhkKSbBAg848asSjIGD91P/Uuve5lUIhGd5UjOh6gUqC+3v+hi9YAefqevjOCxSzx
    LpsMXpEzQmeyKg5ZayVpQmntfvD1ITEqvJdf/968ujTqdMne7e4iLZwKLqHTGxkFeh7zfn
    +/cp92KfQE6uXrWLGGwt07QcKVBZNoMphS1UmNmrePhhNUhAjN2bqkJDQvAsdKE8OCWmnk
    9KzTpoPLNM7S/xh1cehb82KDey9xDtTYyD4v9BUQFczofSl/HNgMZY0deaygx+f1Jtw8pT
    FpQUJ4xDhV5Ay3BSpFu01foyd2JIG/BjVbxfgy9Kj+oQrnJGTHYoP9AwzUcQ
X-ME-Proxy: <xmx:8_aBah1rUXEqO9Z0sF9ExmKxURDxlXUVpFXpG3G0raXUHTnJc0eCIg>
    <xmx:8_aBanTEbRriVHJVxUpsMVObApVwbyPjs9jyVsDhnjhF8TebqGZ9JA>
    <xmx:8_aBaklIXk9gEde6rqJuCx9_b2NoSDEOVld1gok4dy5x59iXtCbE-w>
    <xmx:8_aBaoOWszks8ji03MAao01_kf-lBXydk4jw3sKS0tld1BXth8M-uw>
    <xmx:8_aBaggFI3g1EhvMTSYE1XPhSDEmWrxyY54KTokuVtpHGR775LVW_wzR>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id E84347811F0; Sun, 16 Aug 2026 13:44:18 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: ANRTDGv-SKPo
Date: Sun, 16 Aug 2026 13:43:58 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "David Laight" <david.laight.linux@gmail.com>
Cc: "Chuck Lever" <chuck.lever@oracle.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Andrew Morton" <akpm@osdl.org>,
 "Linus Torvalds" <torvalds@linux-foundation.org>
Message-Id: <9e99253f-99d9-4ecd-8911-2844621a6ae6@app.fastmail.com>
In-Reply-To: <20260812220457.6dc4d5ec@pumpkin>
References: <20260812193349.13347-1-david.laight.linux@gmail.com>
 <35a12022-518b-4c66-b3d5-c850376bfca7@app.fastmail.com>
 <20260812220457.6dc4d5ec@pumpkin>
Subject: Re: [PATCH net-next] fs: nfsd: Fix buffer overflow in write_pool_threads()
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Wed, Aug 12, 2026, at 5:04 PM, David Laight wrote:
> On Wed, 12 Aug 2026 16:19:22 -0400
> "Chuck Lever" <cel@kernel.org> wrote:
>
>> On Wed, Aug 12, 2026, at 3:33 PM, David Laight wrote:
>> > write_pool_threads() writes the number of threads in each pool into a
>> > caller-supplied 'almost PAGE_SIZE' buffer.
>> > If there are enough pools to overflow the buffer the code continues
>> > writing beynd its end.
>> >
>> > Fix the overflow check so that it actually works.
>> >
>> > Fixes: eed2965af1bae "knfsd: allow admin to set nthreads per node"
>> > Signed-off-by: David Laight <david.laight.linux@gmail.com>
>> > ---
>> >
>> > I'm pretty sure this is 'root only' code.
>> > So you'd have to try very hard to actually get the overflow.
>> >
>> >  fs/nfsd/nfsctl.c | 10 +++++-----
>> >  1 file changed, 5 insertions(+), 5 deletions(-)
>> >
>> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
>> > index 39e7012a60d8..b74048aa2402 100644
>> > --- a/fs/nfsd/nfsctl.c
>> > +++ b/fs/nfsd/nfsctl.c
>> > @@ -483,8 +483,7 @@ static ssize_t write_pool_threads(struct file 
>> > *file, char *buf, size_t size)
>> >  		 * file, sorry.  Report zero threads.
>> >  		 */
>> >  		mutex_unlock(&nfsd_mutex);
>> > -		strcpy(buf, "0\n");
>> > -		return strlen(buf);
>> > +		return strscpy(buf, "0\n", SIMPLE_TRANSACTION_LIMIT);
>> >  	}
>> > 
>> >  	nthreads = kzalloc_objs(int, npools);
>> > @@ -523,13 +522,14 @@ static ssize_t write_pool_threads(struct file 
>> > *file, char *buf, size_t size)
>> > 
>> >  	mesg = buf;
>> >  	size = SIMPLE_TRANSACTION_LIMIT;
>> > -	for (i = 0; i < npools && size > 0; i++) {
>> > -		snprintf(mesg, size, "%d%c", nthreads[i], (i == npools-1 ? '\n' : ' '));
>> > -		len = strlen(mesg);
>> > +	for (i = 0; i < npools; i++) {
>> > +		len = scnprintf(mesg, size, "%d ", nthreads[i]);
>> >  		size -= len;
>> >  		mesg += len;
>> >  	}
>> >  	rv = mesg - buf;
>> > +	if (rv != SIMPLE_TRANSACTION_LIMIT - 1)
>> > +		msg[-1] = '\n';  
>> 
>> Did you mean "mesg[-1] = '\n';" here?
>
> Yes - and I thought I'd compiled it ...
> I did decide not to worry about the missing '\n' when the output 'just fits'.
> After all you need over 1300 pools with 10 threads to get to 4k.
> I'd bet something else dies first.
>
> 	David
>
> (Oh I've replaced Linus's 20 year old email I copied from the commit with
> his current one (he acked it) and deleted the broken one from the author.)

I've convinced myself that the actual problem is the truncation. The
buffer overflow cannot occur. I've posted a patch to address that.


-- 
Chuck Lever
