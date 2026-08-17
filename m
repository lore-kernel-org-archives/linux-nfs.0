Received: from mail-wm1-f41.google.com (mail-wm1-f41.google.com [209.85.128.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 77EDE3B8D4F
	for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 08:06:45 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786954006; cv=none; b=l16eFjPGVWNLlw0eGXBEK494hOp+qWShUcadiT/ivV1GIwYm8XdfoHDS2ihgFmh6WK2zhdlzBMhvRJHnt6kPX4EijkxTryHa3Iv5b8QDCSrMLUQ4qkHiIwYwbDfDaqOYafXvfZ/SzgEadQF6W2OuZk5nVfiOqcNmM1DYq61+uUQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786954006; c=relaxed/simple;
	bh=abKrljJPGtqWjp9jAoJrgahJFX0CG9RCRFUlDtLcCsQ=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=CFKXCT2gU2NMWW1CDwW6yWPOCwaDy8uMbTxKReGeVNKWB8uw9tUkLJz4V+GVy4AFLIth2AHRJ4Bj/6OIepxqwMJc2VeShswOqt99IjslCHiUm7yMgzKEe0COrO5DFSHf+HW7YvWfLE1O+NjqqtHlkKYYLzgzBPuCVEB0xhw/jxM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=WKwVGzpN; arc=none smtp.client-ip=209.85.128.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="WKwVGzpN"
Received: by mail-wm1-f41.google.com with SMTP id 5b1f17b1804b1-4998590d392so32935135e9.0
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2026 01:06:45 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1786954004; x=1787558804; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=6V+PnlGPEGd/JqnRb9cp/wDX0jZf3GBuIE7C3r4UIRk=;
        b=WKwVGzpNyAZcVcYwDzX20JjeBymkQaJFx9Xrgwe2ERRhQcSdc0CWmLsVt4eRC4ZgRD
         GfXjLi5uhJl7QD7dUZd7vL3CCy1cc3qsbumi1Th0RBKRYWHRK5fFkQrCIfiWPJRh389Y
         fLCO4zq9ST+adfZCyA+VO0foyYYmmnZhDgGanDj8qJc9Tt0ZFqvPKDv7OkDVYBbIdp8S
         Dnk8j8gJLHOvuGNBBbabrggWu+b+FMA6k+ndoJPQ25c8PTt1YJucGj7hiJAFINbdv69v
         KnWlIHVEjmiclVK3Y6I9SpQRUtCwfP+CU60FaFaCSj+KtaebfmxluvUG3KDSQr0CS/pz
         gmJQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786954004; x=1787558804;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=6V+PnlGPEGd/JqnRb9cp/wDX0jZf3GBuIE7C3r4UIRk=;
        b=rmkF7u/tBSy8AByM9yuPvzzpByw/jMCxE65GfbZKwgHPFsJ/QQUeEh4OzrT94mkWfv
         JqE0YYbSGloncP+Dgb+r+pMmM3M7KpiIxt4WQciIFBWNSXzK4As9a00ghsL6PZMNqoGS
         iE0S+YRY7jC616KhFcgVhoq6Xow5HNBs6XzcFsCYW3M8h9vC+620/LSD9DOoEQsCqKFB
         P2vO9tuc3R9FY6GwPmlThOVJ3cLs1Lb6LVOuAJ1z7o+Wxhtov01bBzjeLz4qbK6H93BN
         rkC/WZrnByVXOTD8dnAvgbIMX7NSr7fabg6/ylYO+J7+5FYleOs2nb+fZItwdauVE+Ti
         DT0A==
X-Forwarded-Encrypted: i=1; AHgh+RprjMPZwHjCaYCnh0mbPb6MVhjdAvH87f5t6VfgQWWm9nFnslQjPHluk0Xpg1PVsMc6A+dw5u297/I=@vger.kernel.org
X-Gm-Message-State: AOJu0Yxu4/kdQQchtrhBsftJtWihLgkN2Anzu2MPbrjQSgCDWl/bzZb0
	V1AbyCF8z2Lt3vfT/zCHeTCTd424sY5YPl7FSiamjxMCSJMNfizY15Fw
X-Gm-Gg: AR+sD11iq0N7qPvEc4a/y1GgsjtMDS0k4tuIf2gVkwyNJyai9XjPINFecTe4T6jRxZd
	rb8UfsrAfWyNiUj0daq1H5Me5MrxEk/4TfiN19At39hRvHcRlmIvJq/qJmWkseatoYJ/H3WkwfO
	8PYVtdtFr1aU+BjyTkhM6fL9PczjUNM1dEVC1lBYZYNHA2WdQvnDo5A/gpojaUidoxXW5clkbtr
	DQQbuygLB7HChW9K7caByFvseU0BA6Ogf69othIa6veP+3BNfuGtrRAvHyVJQBIeFsLS4DvpMRO
	rqtiL8++RKYO+RxI1X7H6+W6ncznR2RQ12PwMMYo6iqExDPj2s2hC7d//OscXYVXVJuS+DDEyYu
	/v6LLQHnmRtoBF0oP4sgw1WCuqNJzXvDG3IWWHVz64tkAdNkHKjK6a1jzfWHIu61fPrqXmiR5VC
	AVp65I8NnfZMSuKB3efmxR5qW+DkwOVLeExAVNHpb0E2vib1V1osttFU648jnkiqzNy23zIvYEl
	QzorygTnKlJXIrGqohhZEkBe5dN8p+LVQmr
X-Received: by 2002:a05:600c:3113:b0:499:83f1:398 with SMTP id 5b1f17b1804b1-49987977373mr315241675e9.9.1786954003281;
        Mon, 17 Aug 2026 01:06:43 -0700 (PDT)
Received: from pumpkin (82-69-66-36.dsl.in-addr.zen.co.uk. [82.69.66.36])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-4999610ed6dsm162407355e9.8.2026.08.17.01.06.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 17 Aug 2026 01:06:42 -0700 (PDT)
Date: Mon, 17 Aug 2026 09:06:41 +0100
From: David Laight <david.laight.linux@gmail.com>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Chuck Lever" <chuck.lever@oracle.com>, "Jeff Layton"
 <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, "Olga
 Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom
 Talpey" <tom@talpey.com>, "Andrew Morton" <akpm@osdl.org>, "Linus Torvalds"
 <torvalds@linux-foundation.org>
Subject: Re: [PATCH net-next] fs: nfsd: Fix buffer overflow in
 write_pool_threads()
Message-ID: <20260817090641.082489a5@pumpkin>
In-Reply-To: <9e99253f-99d9-4ecd-8911-2844621a6ae6@app.fastmail.com>
References: <20260812193349.13347-1-david.laight.linux@gmail.com>
	<35a12022-518b-4c66-b3d5-c850376bfca7@app.fastmail.com>
	<20260812220457.6dc4d5ec@pumpkin>
	<9e99253f-99d9-4ecd-8911-2844621a6ae6@app.fastmail.com>
X-Mailer: Claws Mail 4.1.1 (GTK 3.24.38; arm-unknown-linux-gnueabihf)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Sun, 16 Aug 2026 13:43:58 -0400
"Chuck Lever" <cel@kernel.org> wrote:

> On Wed, Aug 12, 2026, at 5:04 PM, David Laight wrote:
> > On Wed, 12 Aug 2026 16:19:22 -0400
> > "Chuck Lever" <cel@kernel.org> wrote:
> >  
> >> On Wed, Aug 12, 2026, at 3:33 PM, David Laight wrote:  
> >> > write_pool_threads() writes the number of threads in each pool into a
> >> > caller-supplied 'almost PAGE_SIZE' buffer.
> >> > If there are enough pools to overflow the buffer the code continues
> >> > writing beynd its end.
> >> >
> >> > Fix the overflow check so that it actually works.
> >> >
> >> > Fixes: eed2965af1bae "knfsd: allow admin to set nthreads per node"
> >> > Signed-off-by: David Laight <david.laight.linux@gmail.com>
> >> > ---
> >> >
> >> > I'm pretty sure this is 'root only' code.
> >> > So you'd have to try very hard to actually get the overflow.
> >> >
> >> >  fs/nfsd/nfsctl.c | 10 +++++-----
> >> >  1 file changed, 5 insertions(+), 5 deletions(-)
> >> >
> >> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> >> > index 39e7012a60d8..b74048aa2402 100644
> >> > --- a/fs/nfsd/nfsctl.c
> >> > +++ b/fs/nfsd/nfsctl.c
> >> > @@ -483,8 +483,7 @@ static ssize_t write_pool_threads(struct file 
> >> > *file, char *buf, size_t size)
> >> >  		 * file, sorry.  Report zero threads.
> >> >  		 */
> >> >  		mutex_unlock(&nfsd_mutex);
> >> > -		strcpy(buf, "0\n");
> >> > -		return strlen(buf);
> >> > +		return strscpy(buf, "0\n", SIMPLE_TRANSACTION_LIMIT);
> >> >  	}
> >> > 
> >> >  	nthreads = kzalloc_objs(int, npools);
> >> > @@ -523,13 +522,14 @@ static ssize_t write_pool_threads(struct file 
> >> > *file, char *buf, size_t size)
> >> > 
> >> >  	mesg = buf;
> >> >  	size = SIMPLE_TRANSACTION_LIMIT;
> >> > -	for (i = 0; i < npools && size > 0; i++) {
> >> > -		snprintf(mesg, size, "%d%c", nthreads[i], (i == npools-1 ? '\n' : ' '));
> >> > -		len = strlen(mesg);
> >> > +	for (i = 0; i < npools; i++) {
> >> > +		len = scnprintf(mesg, size, "%d ", nthreads[i]);
> >> >  		size -= len;
> >> >  		mesg += len;
> >> >  	}
> >> >  	rv = mesg - buf;
> >> > +	if (rv != SIMPLE_TRANSACTION_LIMIT - 1)
> >> > +		msg[-1] = '\n';    
> >> 
> >> Did you mean "mesg[-1] = '\n';" here?  
> >
> > Yes - and I thought I'd compiled it ...
> > I did decide not to worry about the missing '\n' when the output 'just fits'.
> > After all you need over 1300 pools with 10 threads to get to 4k.
> > I'd bet something else dies first.
> >
> > 	David
> >
> > (Oh I've replaced Linus's 20 year old email I copied from the commit with
> > his current one (he acked it) and deleted the broken one from the author.)  
> 
> I've convinced myself that the actual problem is the truncation. The
> buffer overflow cannot occur.

My analysis was:
size is size_t so unsigned.
So after snprintf() truncates the 'size -= len' is going to generate a
big number, so the 'size > 0' check doesn't terminate the loop.
Which would mean that the next iteration would write beyond the buffer.
But I think there is a check in snprintf() for 'silly' lengths that may
stop the overwrite.
That doesn't stop the length returned to the caller being longer that
the buffer.
I didn't look what happens as the call site, the buffer will be copied
back to user, if the user provided a long enough buffer that might read
beyond the end of the page.

Of course this is all likely impossible for other reasons.
(and root only).

	David

> I've posted a patch to address that.
> 
> 

