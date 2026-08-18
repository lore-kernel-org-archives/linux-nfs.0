Received: from mail-wm1-f43.google.com (mail-wm1-f43.google.com [209.85.128.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E1AFD3438AD
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 23:22:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.43
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787095335; cv=none; b=UI5Yq23wPFA8vOrrLSYMLDNdTrthrDs+pd7P8RCcNtVN2vshGwX4ARk8uEUeF59jnB03PucXkMWZm8s68I4pLA3wXaZ3sr2sOOnJR4Z8Tn5qDPwwoFQzx0+2mMKeAoTSGig+YgKwuNE0K9wnENP0YKHJec+8vJ9sWCLKpR67xzE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787095335; c=relaxed/simple;
	bh=e1WByzyJHjoTRjqdDZ5trr2DzkSWuSNiweUaCCjB3J0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Nw4+6lpHCMDaJP/hJIapTaXY+eUxOLo7XMsPh9p06nMQEmSw7g993mGbMciYNhHtXiwWSKHhZFEtgAooLS2fSAi8r56u6ehJlWc3Zm038vIO3V5JRxnnWoN9za6ixJtUzRLmKyqnaXmL28Il3d+rvD6XxwqXJimY5QxtYVhtop0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com; spf=pass smtp.mailfrom=truenas.com; dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b=lVFBQk8r; arc=none smtp.client-ip=209.85.128.43
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=truenas.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=truenas.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=truenas.com header.i=@truenas.com header.b="lVFBQk8r"
Received: by mail-wm1-f43.google.com with SMTP id 5b1f17b1804b1-496bb7cdf51so4603175e9.2
        for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 16:22:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=truenas.com; s=google; t=1787095332; x=1787700132; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=3s+ro1L4dqcmEMXAFkp78d4td1TXtxW4mVR0/hBAGO4=;
        b=lVFBQk8rQ7fYAYZhYMAJvHazOeOjIEOrYJ8Jee6SYZUyz1kbZ4gYxXjc33NcUaQzPQ
         24+2eypZF9uC0SoQu7ISK9nYBtITZ7nCitW8CczEnKXHnrR7Evoxg816AA8xIlQAtren
         ODXCrzwTjJMlP7jDFSQJne4fKBbmkrYDq211dgAI4JcHELOi7dKs+YWAi+pDjqNfqsyv
         udHLngbVrB7i5sPOtutQ0CTWlPGxjX+HG+GDy2sX7DOd8n5xyJEY9/OWyNrxqjvzIW0J
         e0HwbUaLgtUP06DarkAbsfLv1srHLR8M+JuVuvEXzyGbvLW54zgDzdvmtsRxPEGP0oRS
         yAsg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787095332; x=1787700132;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=3s+ro1L4dqcmEMXAFkp78d4td1TXtxW4mVR0/hBAGO4=;
        b=LBuZss3u66mCUiSoEDZuzb4mLzNRzsaYoxm4LwK0TOAcviawjdYMyr0i93k1o3lI3j
         55iFTzW+5arBtQyBZaz0hh+SopweRCKLVHHO7xdrnDBSlIunU7FvbkqezlAtI9NVcER1
         ukTEeyh75inaOlAvCiEI449SfdBrFoC/y+BId1o9B++iEAPXFHwiIn1VZNHAFL42733s
         8cAg3zcsBQtDtmA3I2ME16+4hvpnUKcttrS7kVJQMLvMG4O0VNr2l1xCtqJh8bt7XW6z
         Bs4B15MQyQHhBFa788P5JXiZa0c3kMx03v5l8cTPcsV0i4opJFBfBUOML3gyprmdPzXL
         c1zw==
X-Forwarded-Encrypted: i=1; AHgh+Rrn86ugLdQBH9iJdAXnOMSR9ZGzeVrZnx/gfnsphQUTcp5bw36X9a3Co8S3RySIWTo23IDHuaw4UA8=@vger.kernel.org
X-Gm-Message-State: AOJu0YwG8oFsO+FayNggzx7zDuAo3fp8UkeoFYLSwEQZr8PH9cHDNjuz
	pQeaioEvwi3nWUNuGPYWJ//TsoGp9CQA7/dEFV1PqCgCZ7JkKDZZ+Zxu8ScJlVR1mQ==
X-Gm-Gg: AR+sD10hDjzUikVF0kdYGvLHdDyDldKJbr5n79UnB8QWf5qxuLRewKma6D3LCXGDR8K
	jjKLJP5q/0rmsJvpUq1OTIY0VDhVDJuf26xOi3c4SXYUBsqb2yjU/gCH0JvJeuxAzfp5QGmIjZt
	5HSXG7hbaP46v1oWjpmR3mGHGUTKkK0zWtHGwhetWImuADoi3prUbJYDq3L8XLmWelNZblDFTNe
	n2bRPKrfN3uLcyosTO8ojQJGmgTRntO5NREivc3+RMkxmPNApnDoQd2CAYyTvGB/cX7I0UUCbBD
	cpYO59Ywa9lqxHR0zWSyc17WtZyrzZZEUFKaD6xw+QF+jhQpGn0OHC66YEj8HIIkBTbShUHFFtm
	O46MvNSDc/MY0gNmYU+e7+RdmXX2EzO6FH0P1Vf9tj0I+hX9Yqfqvc6T81J9JUQD/rLL6uzyRoz
	adinM+XkQBkWNDxlqCVTeh5hjm0AtcdBtuHDn6sFdb
X-Received: by 2002:a05:600c:4f52:b0:499:7a15:fcec with SMTP id 5b1f17b1804b1-499aa1fdfb3mr6449865e9.13.1787095331739;
        Tue, 18 Aug 2026 16:22:11 -0700 (PDT)
Received: from hamza-PC ([2400:adc1:158:c700::1])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-482b144173csm722684f8f.6.2026.08.18.16.22.09
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 18 Aug 2026 16:22:11 -0700 (PDT)
Date: Wed, 19 Aug 2026 04:22:06 +0500
From: Ameer Hamza <ameer.hamza@truenas.com>
To: NeilBrown <neil@brown.name>
Cc: cel@kernel.org, jlayton@kernel.org, okorniev@redhat.com, 
	Dai.Ngo@oracle.com, tom@talpey.com, trondmy@kernel.org, anna@kernel.org, 
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, alexander.motin@truenas.com, 
	caleb.stjohn@truenas.com
Subject: Re: [PATCH 1/2] NFSD: Use nfsd_iter_read() when ->splice_read is not
 zero-copy
Message-ID: <aoToQWzqZNqB4sIJ@hamza-PC>
References: <20260817210811.3984663-1-ameer.hamza@truenas.com>
 <20260817210811.3984663-2-ameer.hamza@truenas.com>
 <178709365192.2852630.5607658976022815566@noble.neil.brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <178709365192.2852630.5607658976022815566@noble.neil.brown.name>

On Wed, Aug 19, 2026 at 08:54:11AM +1000, NeilBrown wrote:
> On Tue, 18 Aug 2026, Ameer Hamza wrote:
> > For some files splicing a READ cannot avoid a copy: gfs2, kernfs
> > and the cifs direct-I/O modes use copy_splice_read() as their
> > ->splice_read, and the VFS substitutes it for DAX files.
> > copy_splice_read() allocates a fresh page for every page of
> > payload and reads into it; nfsd_splice_actor() then installs
> > those pages in rq_respages, displacing Reply pages the thread
> > already owns. Both sets of pages are then freed.
> > 
> > Route these READs through nfsd_iter_read() instead. It performs
> > the same single copy, but into the thread's own Reply pages, so
> > the per-READ allocation and the displacement both disappear. On
> > its own this is not expected to raise throughput; it changes
> > which pages a Reply is built from so that the next patch can
> > recycle them.
> > 
> > 9p and ceph fall back to copy_splice_read() only inside their
> > own ->splice_read methods, which nfsd_splice_read_is_zero_copy()
> > cannot detect,
> 
> I think that if we are going to do this then we should do it properly
> and make it easy to detect these cases.
> 
> Could we add an FMODE flags FMODE_DONT_COPY_FOR_SPLICE which causes
> copy_splice_read() to return -ENOTSUP or similar.
> Then nfsd can call splice_read if it appear to exist, but set that flag.
> If it fails with -ENOTSUP, fall back to iter_read.
> 
> I really don't like the approach of explicitly testing whether
> f_op->splice_read is a particular value.

Thanks, this indeed works better. I believe it also covers 9p and
ceph falling back to copy_splice_read() internally, which the
helper could not see. I will work it out this way for v2.
