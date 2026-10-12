Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1B3EE48F827
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 15:07:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791817639; cv=none; b=LGPWBrkaN2Tcz2gWcXEVxKkumA9hmFEj8AesjDWnIC1E/+HWxq6Hk4Flyo7GRTBrvKwPPstwG2vTK22WdRx953QCpGdiwceOYm3JaUI1V3dghs5VaGBF5Qmu4ekaFXzEGxQKO4ZVUqux+0tghFt1p+zqdYlfcj04YeWXOpsFlww=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791817639; c=relaxed/simple;
	bh=3dUp/9viTlfCRNVAQDogk9DfecYetrUlFc3EopDXyXg=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=u9YJucXmqshnB1e/FVWEWJy36fPH6Z33BHXOBBsi5BWKc9K9UYWCfUOP4WJepRW793iKKtquugjikA4T7VmjA2im8sUPko67UgBBuyQA8487mXZlqc2oXr4zo8AJoilixuNbV8qYmT+mk7wsvoWXtwK8AAoY+U8VYwA12+1mjAE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lCyYy81p; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lCyYy81p"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D07491F0089E
	for <linux-nfs@vger.kernel.org>; Mon, 12 Oct 2026 15:07:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791817637;
	bh=Ne4lWASnAdyPxkb/cP0InkWkICW7G975/szCfFpIVlo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=lCyYy81pfgjkF9K7Z/1YNf8yHJwCsdMeSc00fvVZwJ55MEcUlhsJ4T0rZOU4Zk2D/
	 T7C3EoZxu+N2SQ92zrLpIlb/8xPR6qQdBryEkTs/qOcztBckzu/kwyjicq+XM5QRIM
	 MS3uTjo+Rxj87y0+Xm5dt0Qx7zjZwT+bQWiEQIfcB9mORF7we9k+83/c5aJP5qL9zF
	 pKvppXdd4E91OKdS/1PjNFDTaZpGEFwiD586+gXsE7AbOqydnNXJLnQ0H0attRVWCj
	 ChLiYgfW5dSOrqII8kqD8fta53ECREegrIOGakx9L+MkiyumH0lpgfSYVDORUnHecg
	 na5Yx+upff2rw==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 3B6DDF4006A;
	Mon, 12 Oct 2026 11:07:17 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Mon, 12 Oct 2026 11:07:17 -0400
X-ME-Sender: <xms:pffMaldb4JrmIiRmiQrHJNO9t397VDKH03bz1Z55JaipxxEh9ioo7w>
    <xme:pffMauDhWQUgoYCx0IYZ4SSLapFgY_H-dr_wp3D3XLFxtnYVZEWiuUC9vn5sud-tu
    f6RMuRza9dds_-RYrOBYmwW0ectvX3FO9V4SebX_RelTXBZLNUa3_GF>
X-ME-Proxy-Cause: dmFkZTG2n8o+6MecnIjypGxSFqBGuUpTGbSkdhzISCx/3PhMSf5+TuX7YdQS6q005BNC8f
    VtHobaUQRKxUMI95HMDD4DgBmN2IuCj3a5pdGwbfjC3QKuQ0Q+ryLuk1y2EaP5Xb6SaZE1
    wqpExuomkh3iqbFwqhsfg03ZqvOSx/jn8629p7pXFf8di/aQqskgTcwXWm3QuxsJHwPilU
    PXSeYnNo9vR31RpmlpVqqFxVcYdZJUHgL4KhWs1A88/RUknXnJjuqRFYzBN3B6lguZYVyL
    gtdAP2U0V1trj8XRqL/WKvbHUklkwteW5cfdDa8hnACPHv6pQXrmq2dlFC6SRF6Ka2eHk1
    KiU+0zfEwxpYP7sRFEh7UnDG4q3dKe+KcQdiGdrsy5aP4FESgDTpPTrdI+bo8pVB0BUr0v
    6jT8uUxaF/pAQ2B/UK/qHGvGzmbzL2h8D1FFeRdpgb3QBu/D2rVT+E5JQGdevXjLQ2lDvV
    IViaiyEnOo8hK9Byu7n7Uc7LjRpaKRezjq9hAkW5DvTYeW4q9EC7hUqM3dQXb/tlPf9pdH
    pH+8ztC7PnEi2iGewM2cFQG+ocLwG6Ke90CJhlmIGUFZF5BAB9GPGE5npkxePEWazmoqkZ
    yjf3G9wKWU7418wJFr8z++FJYsBxcOdGpHCvNC4hxGmTx2VgI9t6qpg13ykg
X-ME-Proxy: <xmx:pffMarZrpfDhcs21fHRxypArVBYPxy1kWYOLCvvsbLT6gXiA-tlwmw>
    <xmx:pffMaiLkxh3JUUM67F6FTFNWWIJ-wD7FKmmi1tO-yPoajLu6x0pVOQ>
    <xmx:pffMahAqX5Q1MuFbaJWZF67daWCHnHvpHDScWRl0VDxPXBQ6fi4rGw>
    <xmx:pffMavrJoF14RwFCpj5c5U02kIFhvBt-aQS60C1jsDBnmxtk7cTA1w>
    <xmx:pffMakilN7-9RIV9669BO7VroCUwx53dr95M9MToFf4eoAsOKKjdbuiX>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 0D556B6006E; Mon, 12 Oct 2026 11:07:17 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A3fh4j6Kirz-
Date: Mon, 12 Oct 2026 11:06:56 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: "Benjamin Coddington" <ben.coddington@hammerspace.com>
Cc: linux-nfs@vger.kernel.org,
 "Trond Myklebust" <trond.myklebust@hammerspace.com>
Message-Id: <c07e2fb6-8ec9-41c3-883d-1159d26dfc8d@app.fastmail.com>
In-Reply-To: <9CCF4553-C2AB-48FB-A3A0-6ED96D50798A@hammerspace.com>
References: <20261012123346.123126-1-anna@kernel.org>
 <20261012123346.123126-3-anna@kernel.org>
 <9CCF4553-C2AB-48FB-A3A0-6ED96D50798A@hammerspace.com>
Subject: Re: [PATCH 2/3] NFS: Modernize the callback decode_bitmap() function
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Mon, Oct 12, 2026, at 9:13 AM, Benjamin Coddington wrote:
> On 12 Oct 2026, at 8:33, Anna Schumaker wrote:
>
>> From: Anna Schumaker <anna.schumaker@hammerspace.com>
>>
>> The sunrpc function xdr_stream_decode_uint32_array() is already designed
>> to decode arrays of integers with all necessary bounds checking. Update
>> the decode_bitmap() function to call this and map the return value into
>> something the callback handler expects.
>>
>> Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
>> ---
>>  fs/nfs/callback_xdr.c | 24 +++++++-----------------
>>  1 file changed, 7 insertions(+), 17 deletions(-)
>>
>> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
>> index 5a1f05469268..b6ecfb73d850 100644
>> --- a/fs/nfs/callback_xdr.c
>> +++ b/fs/nfs/callback_xdr.c
>> @@ -100,24 +100,14 @@ static __be32 decode_fh(struct xdr_stream *xdr, struct nfs_fh *fh)
>>  	return 0;
>>  }
>>
>> -static __be32 decode_bitmap(struct xdr_stream *xdr, uint32_t *bitmap)
>> +static __be32 decode_bitmap(struct xdr_stream *xdr, __u32 *bitmap,
>> +			    size_t bitmap_size)
>>  {
>> -	__be32 *p;
>> -	unsigned int attrlen;
>> +	ssize_t status;
>>
>> -	p = xdr_inline_decode(xdr, 4);
>> -	if (unlikely(p == NULL))
>> +	status = xdr_stream_decode_uint32_array(xdr, bitmap, bitmap_size);
>> +	if (unlikely(status < 0))
>>  		return htonl(NFS4ERR_RESOURCE);
>
> There's a slight behavior change here..
>
> xdr_stream_decode_uint32_array() returns -EMSGSIZE when the wire count
> is larger than bitmap_size. That makes a well-formed bitmap4 of four or
> more words fail CB_GETATTR and CB_RECALL_ANY with NFS4ERR_RESOURCE. The
> old code accepted such a bitmap and ignored the words past bitmap[2].
> knfsd never sends more than three words, but bitmap4 is variable length
> and trailing zero words are legal. The client side already treats
> -EMSGSIZE as success in nfs4xdr.c's decode_bitmap4()..
>
> Minor.. any concern about that?

I should probably try to preserve the old behavior as much as I can. I'll
fix that in a v2.

Thanks for the review!
Anna

>
> Ben
