Received: from mail-ej1-f47.google.com (mail-ej1-f47.google.com [209.85.218.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC9633B27C7
	for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2026 13:20:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.47
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777036856; cv=pass; b=XniezZDIoAoUb7RO2AYOEOcZex/IUDq23cGn2aRU3HlRQ3hALJsc5F/6U7C4CHpLcWr2633q5hrmzxcE25Wupvanky1MuvL/374m/2wAuqfMIegirhNlJowNZ/au/IgFS8SxEYkczao8nfD15SJL2yGbBlWc2ZRRSHwWVpvJaik=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777036856; c=relaxed/simple;
	bh=ASS3cGIUH/I1kiBf/Dy1WJ4mFG1Z1t92cIyj895Uf5Y=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=FwnvsuHsGMM8L/dbyMwk4QFqAOiTBqM7N1VQ4wDbJ626gzW/LAUnVZADyLi7Y3nvGgGCUh/VD5v+tefdDdpO3VtXhSHvfuwhEIWn1kld207toLZNvE36uF6G2FDEUp5fxeVblsqBHfNXuTgDPrKCAtJx9ZX7kSde0nXtrDR/2YM=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=G3G0GFTL; arc=pass smtp.client-ip=209.85.218.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="G3G0GFTL"
Received: by mail-ej1-f47.google.com with SMTP id a640c23a62f3a-b886fc047d5so1404504366b.3
        for <linux-nfs@vger.kernel.org>; Fri, 24 Apr 2026 06:20:54 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1777036853; cv=none;
        d=google.com; s=arc-20240605;
        b=hCtPeUld5/Lh1O0TcCq2NBKDR4RzJ4s8L7OKrkPHYQKDeuSm5xC5f0A+uLZ7eU5YAq
         akSVei+4PDfDZYBKzsA0qgmnsyC1YXQ88l+7K3ke5myYyqkzzg1Pe/Z4jQ/sBnpHUznu
         6UnKR6Ug0rqLlGJsRLiJ/4meiyHLdI9oF4KUSGudbedQxWW3VCHjXh7BJRXA38zyXUkE
         sZl0vlWMteqsIIVIFI9bqXFAV/wVPtaIgT1h/En9luziOJF2J+0i8c21P9tLr1OrRbd+
         7C7U+2DYab11/ftq6ubwMAHN1dY9IGoSoNJU94SbHVBVELb4O31nuABG0c1LxkYwGf9P
         bPsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20240605;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:dkim-signature;
        bh=ASS3cGIUH/I1kiBf/Dy1WJ4mFG1Z1t92cIyj895Uf5Y=;
        fh=8oTTDw1v0ZMa59D29VzttmRjRe1/QYVXBEGMr4L18uc=;
        b=Me1a4jd8Bxc4Rhy4I6L4xwA370XguqTaJINey5wIOAfB314l6Mb+Fhmo//1iUcHh+Q
         Nqw7Pr4d6k036XTroLqOkF0qXhD520ugV8UIgOQhUziak/tyMUBop2f1IcYC+IT9uRfq
         outExBqFyDhr+787wuPG7s3xYdi+AJSsTdFvvfBi6CSfSwnVdc0bAw00NZkHD2FlONf5
         8RET20Wi0ZvHSTJgeLOAe3FwsQtDlgttGGVt5plXUhq+nihJ7Gh17r3L+npnqg46re8y
         r9b9p5Ye8Ee6c9FZNpId5L7RlRUuKFejFfVOjzY//xJFM9pa9QjTZvZNK8QGPyzBnwL7
         472A==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1777036853; x=1777641653; darn=vger.kernel.org;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:from:to:cc:subject:date
         :message-id:reply-to;
        bh=ASS3cGIUH/I1kiBf/Dy1WJ4mFG1Z1t92cIyj895Uf5Y=;
        b=G3G0GFTL8u6BieWBwXnTVyAyWJiob4JW74lnONgl+e4w4W4lKn/RmQsIK+x/VI4jf6
         NflDdA9V7x2/E2VOhTJCyxMY2IlDLxXYpn5tWoNRP4mCQgmI76SyDsvGSy2aIe4oGum9
         CyvKTJ8cfXbhRVNWtmQYkBX8SCACLg1Q6FzvCAFmHimbNIJPGNmFExiWQRhmRelE9p/d
         zvMFrunzBsepClEnkPIlDR0+FrxO+PcLHFhiIpLaC4blZZErZmfQyFQy0K/Wk1Zop/87
         Bkj52UvHHwffn+oHTSkNfRracpkSIuzoS80cM+VHPK47b3nW7MCCHWIJacyaVmgo3u9f
         6qCg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1777036853; x=1777641653;
        h=content-transfer-encoding:cc:to:subject:message-id:date:from
         :in-reply-to:references:mime-version:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to;
        bh=ASS3cGIUH/I1kiBf/Dy1WJ4mFG1Z1t92cIyj895Uf5Y=;
        b=CKoZH6tiaUULNYG9bfODVoP8m8eQMfFoPi1zk8A5VNo9cdX4URXChXCNuy8cLHO0IL
         ohjsXR7uDdjkFEMFF1pgeauCB+o1XEh0jAAsXjzhroZfN3bxyqief/JHbRXOxTAjasrj
         UVboDtIAogW0XUS9Y/mF4f3i1KRzswV2KSF1ZvK756uqXJuigK+LJge0RVW3lt04Pc2w
         HPnmh5vmpdQJjgisRE5QJa9yb0sCvjNQT+RkyBkQHBZDbUmQJF/cxSsfNmnsiHEN1W5I
         PBijc/VPcwgdDKENQzEl/9CnXiElD19oHKQMkKOhx/dW+PUNjOsVOyivu80TDDBbe7KW
         iKuw==
X-Forwarded-Encrypted: i=1; AFNElJ/ksf/fZQO1McdkKCLdOqUJjmqHDykOcOinJjSKsYvEX1dVQxIt24+wPLsTsp6jIVUF/UoxsRK5haY=@vger.kernel.org
X-Gm-Message-State: AOJu0YwkmKxzqKbMkr2nc4es1r6C4bT88Jt+ZtC6ktjOsNffdPL2g76Q
	10SD8LujHsFon7PZTMzV3R9aSt1TdMIlQ8wBxOvNAjEA7v1d97KBwSvv36VEaOF1//ev3zDwbpj
	hM/4gRL+lqvSaD0tJAo5vxzZVl09zgaE=
X-Gm-Gg: AeBDieuBZPwyNnTqBmx+vnqOP4JVC/4/wGcuuLmKCSIboCzkGu/ov0yFjdBUuD+oiFK
	4WnMheVIQN/J06COwgFRkvv5pT8YIb3hr1VtlPXQv2gojGHLbYEdut8CUJXpIPLw60E7Y/yATk3
	Ud/VhCFO7niVrdtphVwdEUPN0QOMDKr8zP4NIMeODWvhKrQpWwOh1tgk3MzcAawAL2U9fEvZKPT
	0yiily2yBBa+Py1TNrd3SGLUylgkAh/t7o9m2x9j/W9myzAytl0gesk4YzV1XC+YywJJ5En+27b
	fCcCLB7c+gRUT/ca
X-Received: by 2002:a17:907:c1e:b0:bad:d21f:904d with SMTP id
 a640c23a62f3a-badd21f9640mr134660466b.31.1777036851676; Fri, 24 Apr 2026
 06:20:51 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CANT5p=oV8kcE6hXPoUVQAYGaiz+2OERoSRLAS6X+q9KJ_8w8YQ@mail.gmail.com>
 <438478a7-c965-4a2a-9c4a-84b5f77d6dbe@samba.org>
In-Reply-To: <438478a7-c965-4a2a-9c4a-84b5f77d6dbe@samba.org>
From: Shyam Prasad N <nspmangalore@gmail.com>
Date: Fri, 24 Apr 2026 18:50:40 +0530
X-Gm-Features: AQROBzAWgiHMPutXPKosmS70CLbZfFyKsRjxdv-KyVf-hd6DFXM_DKprRPT5BlM
Message-ID: <CANT5p=ortwT7ensa+kKoCa=wMnGETpqaQuBnhDWMSNu82KsqFg@mail.gmail.com>
Subject: Re: "Intent" of VFS lookups
To: Ralph Boehme <slow@samba.org>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>, CIFS <linux-cifs@vger.kernel.org>, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, Apr 23, 2026 at 11:13=E2=80=AFPM Ralph Boehme <slow@samba.org> wrot=
e:
>
> On 4/23/26 7:01 PM, Shyam Prasad N wrote:
> > Wanted to understand if this is a problem for other filesystems or if
> > it is specific to SMB protocol?
> > SMB2+ protocol mandate that open call specifies if the file being
> > opened is a directory or not (regular file).
> sure? From memory (though the logic has always kind of escaped me) if
> you neither specify FILE_DIRECTORY_FILE nor FILE_NON_DIRECTORY_FILE the
> server is supposed to open the object regardless of the type.

Hi Ralph,

That's interesting. The spec does not seem to define this. Perhaps purposel=
y?
Will try and prototype a change to verify.

--=20
Regards,
Shyam
