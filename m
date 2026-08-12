Received: from mail-wm1-f44.google.com (mail-wm1-f44.google.com [209.85.128.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61DCC3559F2
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 21:05:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.44
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786568704; cv=none; b=JophzC9tSJyAS9lmgHnrmjj9y313X71gedhdc55CUXg3Znl0+rxs/IF59GPsOKNe/9i+OhLEFEHX8jpxO2fkgXq7yszWpmicGe46BsgLX/HO/T728rhh0WwACuCKK4ZFUpS30TJv98vdPZqyA0ejuQe5GifStN0mVfG7jyXj2x0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786568704; c=relaxed/simple;
	bh=3AndPJsMoZUpkGoPAyT/4CJpi5zdzfk5krEWZF9SMoA=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=KFltd4v69yVA1IFUIZdkdHrF01A/Y5LXGSxDYUtSvir7uqXhSHaA+BwV0e5D362UbXdDNxRsRnf+PDTUm6rbx/oCmYbadwccqiB/8mRlhu5InKtKp1IJN7mgQ/9/q5PIQP68Gim1tnRm7fH0dJbDujwKthyq5ehKcheNIrayM2Y=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=omhS+htb; arc=none smtp.client-ip=209.85.128.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="omhS+htb"
Received: by mail-wm1-f44.google.com with SMTP id 5b1f17b1804b1-4954dff6536so10563585e9.0
        for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 14:05:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1786568700; x=1787173500; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=6v0UE5voQLegbVDpIZwHxcQU9AlIKwvDrpwbfg/A56I=;
        b=omhS+htb5t8ThBlGLzGWBHsYsAzfFsHKjjzXU5VSn/itvwMqYEwngmb8/jrqhO+T1x
         NQW5gHRgYK4k9qayzSEvERLgZH5RLvHPJYmR085pl/TdtQJCWGNl+ZO7P2wkcpgax+RL
         B0aqCeTqk2bbshQzH0SHHk/P6jk/L/8PqA5Ssr7gWCU0VoZKwzmDW34wH19wYM67zvn5
         8b232kVMyQX1WD/95xlVMg5grgnkEkAmJ/lz3Qhw3XFpH11FJkRylBSbQ3WU45FCTEry
         W5+nmAqptmseACnUUo2ok2zh9OxFF4Wnuo+83SNh4DOrc2G+esKSa393oy5Vq0MjzNim
         KyVw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786568700; x=1787173500;
        h=content-transfer-encoding:content-type:mime-version:references
         :in-reply-to:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=6v0UE5voQLegbVDpIZwHxcQU9AlIKwvDrpwbfg/A56I=;
        b=NDePQWPMOR10m8wgTw0LLzzAm9l6rOluvosH6F+3+sOwah1YsRyUPhY8UX+XE/wI69
         7VCrfrddopxEgGukG0/RSDFsA5xeeKoGavWG4wPM2teMuVMiKrGJ13tsrhbP05RBukTA
         rS2FbgH62Tt2rfUEsdCLFQsPklNJ+pM3Dky17dxEy6HMJpVkmW810G/mEeAE3bNrrr1w
         /5bVD9JtSmPI7HRMYkc70pTgfr3XhKWO3BJVzTmaSTrBaesWEaxpk/djLrzpru1TtxRi
         A6aMG+gXvzp8WQIu12/5RSzwr8cc1qF9vRZFH9LogTv6Bwv6XsS2SFbsAKvfgrdOFO4y
         qH5Q==
X-Forwarded-Encrypted: i=1; AHgh+RoduZeHU3GZ1AsXqpg+GJKDvJ/sIMs5q8GUF2oGScYbONq3BwlDuiO/fxK8Ts0eaz81M8OY8u/kRKw=@vger.kernel.org
X-Gm-Message-State: AOJu0Ywmtwa/hQfjCnRp6vVLxnFCOQD7YK+/mtJriGIcW1XvCZDo+3If
	Tzl3DuGsA+QX7UEyeksAQn4H8uEEqvlcajzUp0noaR+7VJ2SjFsCDecX
X-Gm-Gg: AR+sD12xMCccmj+/lgEnjv5HmKo02Hx9i6521RjusKnFsqJ1/Ifp/21dJdn+gRniojK
	MlliFN/jRFf1aoARmfNyVBpVNL7hou8GJJu4r1kh3EdTk3NB+CxHfbcAcyEJpHE6nDhmepokVAS
	ma+osF/0P8ZiKCHHMcH3c02jFPxfr5kxQDoUYCuY1OyG2CKKb5RE8NhvkBZWPOhd5yFB1tOMEnL
	iPILy47it2BoH1/udGnY8ZrItF0rfkTua6HxmrJQW+zqBmp3s5RE67kpSzNHuNPL5MFqemcKp/W
	hKd1LZmTatQu8JDqo+7wz3+VVEkNYU7CvVziurmnzBx2VzXuHzcZOOsEp7r0d+zLDiqoeAEe04d
	pK96xhL0PG9h2nc0fyDjk5L875YUXIVsfvB62Y+gxSkdFq8qvNOzKM8Ko2HM4iHcOyLX1x8B/LC
	FVXlNuGVbXm4Qx3mwWxyWYGfhjmeLmPLNQAt+mWjOtZuq8qlyrXThTw5Yryy3oZ5Ud/HkGGOy8c
	So/NPtbCmy35Wox1zbb8cWsKw==
X-Received: by 2002:a05:6000:420d:b0:478:19e7:22a2 with SMTP id ffacd0b85a97d-48159fedeebmr1204191f8f.25.1786568700438;
        Wed, 12 Aug 2026 14:05:00 -0700 (PDT)
Received: from pumpkin (82-69-66-36.dsl.in-addr.zen.co.uk. [82.69.66.36])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4815a5b6e3asm430516f8f.28.2026.08.12.14.04.58
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 12 Aug 2026 14:04:59 -0700 (PDT)
Date: Wed, 12 Aug 2026 22:04:57 +0100
From: David Laight <david.laight.linux@gmail.com>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Chuck Lever" <chuck.lever@oracle.com>, "Jeff Layton"
 <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, "Olga
 Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom
 Talpey" <tom@talpey.com>, "Andrew Morton" <akpm@osdl.org>, Linus Torvalds
 <torvalds@linux-foundation.org>
Subject: Re: [PATCH net-next] fs: nfsd: Fix buffer overflow in
 write_pool_threads()
Message-ID: <20260812220457.6dc4d5ec@pumpkin>
In-Reply-To: <35a12022-518b-4c66-b3d5-c850376bfca7@app.fastmail.com>
References: <20260812193349.13347-1-david.laight.linux@gmail.com>
	<35a12022-518b-4c66-b3d5-c850376bfca7@app.fastmail.com>
X-Mailer: Claws Mail 4.1.1 (GTK 3.24.38; arm-unknown-linux-gnueabihf)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Wed, 12 Aug 2026 16:19:22 -0400
"Chuck Lever" <cel@kernel.org> wrote:

> On Wed, Aug 12, 2026, at 3:33 PM, David Laight wrote:
> > write_pool_threads() writes the number of threads in each pool into a
> > caller-supplied 'almost PAGE_SIZE' buffer.
> > If there are enough pools to overflow the buffer the code continues
> > writing beynd its end.
> >
> > Fix the overflow check so that it actually works.
> >
> > Fixes: eed2965af1bae "knfsd: allow admin to set nthreads per node"
> > Signed-off-by: David Laight <david.laight.linux@gmail.com>
> > ---
> >
> > I'm pretty sure this is 'root only' code.
> > So you'd have to try very hard to actually get the overflow.
> >
> >  fs/nfsd/nfsctl.c | 10 +++++-----
> >  1 file changed, 5 insertions(+), 5 deletions(-)
> >
> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > index 39e7012a60d8..b74048aa2402 100644
> > --- a/fs/nfsd/nfsctl.c
> > +++ b/fs/nfsd/nfsctl.c
> > @@ -483,8 +483,7 @@ static ssize_t write_pool_threads(struct file 
> > *file, char *buf, size_t size)
> >  		 * file, sorry.  Report zero threads.
> >  		 */
> >  		mutex_unlock(&nfsd_mutex);
> > -		strcpy(buf, "0\n");
> > -		return strlen(buf);
> > +		return strscpy(buf, "0\n", SIMPLE_TRANSACTION_LIMIT);
> >  	}
> > 
> >  	nthreads = kzalloc_objs(int, npools);
> > @@ -523,13 +522,14 @@ static ssize_t write_pool_threads(struct file 
> > *file, char *buf, size_t size)
> > 
> >  	mesg = buf;
> >  	size = SIMPLE_TRANSACTION_LIMIT;
> > -	for (i = 0; i < npools && size > 0; i++) {
> > -		snprintf(mesg, size, "%d%c", nthreads[i], (i == npools-1 ? '\n' : ' '));
> > -		len = strlen(mesg);
> > +	for (i = 0; i < npools; i++) {
> > +		len = scnprintf(mesg, size, "%d ", nthreads[i]);
> >  		size -= len;
> >  		mesg += len;
> >  	}
> >  	rv = mesg - buf;
> > +	if (rv != SIMPLE_TRANSACTION_LIMIT - 1)
> > +		msg[-1] = '\n';  
> 
> Did you mean "mesg[-1] = '\n';" here?

Yes - and I thought I'd compiled it ...
I did decide not to worry about the missing '\n' when the output 'just fits'.
After all you need over 1300 pools with 10 threads to get to 4k.
I'd bet something else dies first.

	David

(Oh I've replaced Linus's 20 year old email I copied from the commit with
his current one (he acked it) and deleted the broken one from the author.)


> 
> 
> >  out_free:
> >  	kfree(nthreads);
> >  	mutex_unlock(&nfsd_mutex);
> > -- 
> > 2.39.5  
> 

