Received: from mail-ej1-f44.google.com (mail-ej1-f44.google.com [209.85.218.44])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C9BDC3630AC
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 22:47:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=pass smtp.client-ip=209.85.218.44
ARC-Seal:i=2; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789426048; cv=pass; b=n4NfFJT95rGcJk+MzwOjGurMRFFpZIhGSOtUBHws/+eNpvnl82q2d7E9bAeMGlSx1hWHgsHxLb7mQRLmobipizdQdDzdGGvLAwn3fVWqYyk0D0iKhWjgtWybFMBcl/PfVOFV8G5gAOP3lscTmT2DkY5N5CB4s1jgbNWTxLuBdyM=
ARC-Message-Signature:i=2; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789426048; c=relaxed/simple;
	bh=smjPe3RajYQPH5VvyxqOK7x6E6M4GeW/od7bmiPh1SY=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=Klt9qgchZH/hXtoR2A1Qu8rbSPgKbFFuYjb6YTvpljg9p4UsciOAcnCl50BboQ6hZT5/zyiMa6/k0tkNBYDgo0fSu6G9By/8mB/tCk+jMpGlbIHotESfMbxLyLIBjSr7gz+qMXVsze5AKIc6/SEySmT0DW99fQMt8EKMl88DZn8=
ARC-Authentication-Results:i=2; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=brahma.io; spf=pass smtp.mailfrom=dneg.com; dkim=pass (2048-bit key) header.d=dneg-com.20251104.gappssmtp.com header.i=@dneg-com.20251104.gappssmtp.com header.b=Lhiw9YXp; arc=pass smtp.client-ip=209.85.218.44
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=brahma.io
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=dneg.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=dneg-com.20251104.gappssmtp.com header.i=@dneg-com.20251104.gappssmtp.com header.b="Lhiw9YXp"
Received: by mail-ej1-f44.google.com with SMTP id a640c23a62f3a-c20ce3c118aso47412366b.0
        for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 15:47:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1789426045; cv=none;
        d=google.com; s=arc-20260327;
        b=OpySxcrW2H2vFmG+BK4KhdEjrMAAZkMNylL4bB98sn4o/2LynGsr5MfXaLAbGh5pJ6
         mgsc+Box8X38eUXKoN8enoaQYrw0kQ0z32TV//yx/F2TL3wumqPLjILwsK+HVBpGUUvY
         vgWe/I0ghINsvXJZI9QJyXZXceVZ5793sfps7p//xHhhPXyM7ItncN0SV4CfVHE9bRhr
         MnQ6BW1JYebrqwwjlgUhriiWFaAVWK+8tiaDbIxXbV2ISR8SyHFKSy5dgLrk9VstY1F2
         /0sm7ccXDLzeQajgnyA5DnRKkdOd8IFUb6PJIvxRyW8x3rXiYgoq0HTjPtPE/QOzj6O4
         2boA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20260327;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=9Ri+vR4mGUVhZPO5xpqE+Ep8OB3oPRVY/6sA8yCIDjM=;
        fh=JtCcliMZLxE1I7hL92of/xH2uZCs72AXByoBzkAxhm0=;
        b=UB7SnyPlnKYqskuj++FopWBExax3e916I/YTdNtpvq6+UPfS96WBHhCsTQSD2t7Kxk
         KOPGy1sYKZLpXplXr/2i8iHYX9kqzrE6Z+gXTjGmJmZVF1Q7Yxh33YuEUJ5SNpRJQaRW
         P6EFRobtdLDo0q0SDKsah2fcwZXryewa657YQQno2+V2KN9VjJNpJ5SymFuRccs4q5bt
         th7hE0I0bXKMAOyyzAls6420imO+41FtyHDNabMdi4GrGrxNRePYUydVD0FfRfM8JupM
         FuY+/4rEZaC4LKSq+SZ75LPgtuVuzpj2u1+c962sCHllBV8FIleI2TT24/lhp9ogH4CU
         LvBw==;
        darn=vger.kernel.org
ARC-Authentication-Results: i=1; mx.google.com; arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=dneg-com.20251104.gappssmtp.com; s=20251104; t=1789426045; x=1790030845; darn=vger.kernel.org;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=9Ri+vR4mGUVhZPO5xpqE+Ep8OB3oPRVY/6sA8yCIDjM=;
        b=Lhiw9YXploXEQvhqwCNH9pw4rXKo12aawGb8s5sPgIkTE61qEo25DeFXG2trvNSakj
         F3jiXABQLzWSawFcNdYubvkJPTYXbZ5m/2CYkOduOC1o8I/NCRGn0+WsXvqZysyLae79
         oVSzenR4cMrjFh9BNIhVXNGJCEvJGJty/dRZGXo+cUjCWojY24CZjyH/yJpB0DXqtRDo
         NlZwjmOCM7ADZrcx0+wdMsO2qZxlCwweUJlaSdqgXZxPxVMJplCwxIUoNfySbSK7x6dX
         Cme5eo4VXvMpSshDqgTSWM5pvHMTXt0DhzfIREeu38W8nujtWDIkGwkz5i0J3czzmd2p
         D8Xw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789426045; x=1790030845;
        h=content-type:cc:to:subject:message-id:date:from:in-reply-to
         :references:mime-version:x-gm-gg:x-gm-message-state:from:to:cc
         :subject:date:message-id:reply-to:content-type;
        bh=9Ri+vR4mGUVhZPO5xpqE+Ep8OB3oPRVY/6sA8yCIDjM=;
        b=ZI37RLYZ+rs6PcJSd3DLVzkDBjO8jSiYqif03c1PVMxi/QC4dhLHasXWGEQ9kB110Z
         wgEJSYmPfpMZjQSnQYQDYQqSZ+6gpPKrMI/LYlwaNdXEeMQsTAiXaBW+HXC8P0qf3TtL
         KhhQzRgjOWD2xgoSiDuB/aCMPRi/cS9F8YiKG6qEZIkk3RkwRBvZIYf2LHTZlWhSHaIU
         +Xepo+urP51y16ZeS1RbTvLiRUPXaVyyDA3j3f6YOQgcGkMa2GTbpIJHnA2epwfeeUvO
         DEJWblyztB8KsZeIbs1qLuEfYoqm8XNjVlqqWYeI/iRFfQVqqlVSMOWIQ9wUonLY3Qpa
         ObQA==
X-Gm-Message-State: AFuF++l1mmDXX9JhVX+n7oQHwrrfXe314pPGe5deHV7qQKBqDVqpDbhE
	WBj+Eli5uOzyoOnG1QJP+CqKcYQkMf59Gih2y0RQNBnA8wvPcbM6497DlWTADactcHxGrzAd5y+
	bAORr4Vuz6nU/Jcp34nYejXyyqZXetfJhylrIgL6uXz08QjyenfZZ
X-Gm-Gg: AYBFou0JK8eIy86vEH0nhdk18oRFqz3OmNWk+JsaKWg51gNi1a6k4UkzrkugrsiS+m3
	fHES7pEFJazj2oH8D5c7trJRMEL4ZOci2uVnSMWeS+ixD0Fr0w91ame8ODuHOwFA92lMXjN8Llr
	qU2ZaFBRG7KesSR+vjc28UvFKXO2RhDkVnSLwTRk5GZDm6otJDroNPxdEaDRm4iwtyo6aTcVt0t
	bnY63PefrdmR061ObN8tmaR4i/ccFuSNIPp/JYJUYbqHs6K2u6cURPlNdV2XfZSHNPu5junJkUK
	v/ARcyv9jk9DviZBfYiOs0IOnno7zQqyVC7f1ktPkCVw/aRYtF0OswugrOVLpFkUdvpXjpVkdOi
	yF2UkDIleqS8=
X-Received: by 2002:a17:906:4792:b0:c26:1cfd:4244 with SMTP id
 a640c23a62f3a-c29c89688d6mr94916266b.11.1789426044921; Mon, 14 Sep 2026
 15:47:24 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <CAPt2mGO-08X5h-v2Nm9m8E4y5X9V3BpCcoSZiqW6rd-siBBAmg@mail.gmail.com>
 <420a86d7-d911-4d20-8150-703a94f36314@gmail.com>
In-Reply-To: <420a86d7-d911-4d20-8150-703a94f36314@gmail.com>
From: Daire Byrne <daire@brahma.io>
Date: Mon, 14 Sep 2026 23:46:47 +0100
X-Gm-Features: AcwNN1XttWliKFp0e9C_i1ou_SjamVsu5tiT3y_lXPIOgaxoiGc9K-x8KaRWhgw
Message-ID: <CAPt2mGPfwmFAARgKGQ35WpiBPK4=EFSqyS9+16KE9MOEgnAGgg@mail.gmail.com>
Subject: Re: FS-Cache/cachefiles not writing data in v7.2
To: "Owen, Mike" <mjnowen@gmail.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>, dhowells@redhat.com
Content-Type: text/plain; charset="UTF-8"

Yes, that was exactly the issue and that patch does indeed fix the
problem on v7.2.

Thanks for the pointer and I'll try to search better next time!

Back to testing v7.2 and v7.3 then...

Cheers,

Daire

On Mon, 14 Sept 2026 at 16:29, Owen, Mike <mjnowen@gmail.com> wrote:
>
> Hi Daire,
>
> Does O_DIRECT work but Buffered does not?
>
> This thread with David Howells:
>
> https://lore.kernel.org/linux-fsdevel/2319644.1789132399@warthog.procyon.org.uk/
>
> cites this fix:
>
> https://lore.kernel.org/linux-block/1667275.1788941191@warthog.procyon.org.uk/
>
> If so, the above patch has not yet been included as of 7.2.6 (today/14th Sept)
>
> -Mike
>
>
> On 14/09/2026 13:44, Daire Byrne wrote:
>
> Hi,
>
> I was keen to start testing the various scalability improvements since
> v6.18 and so jumped straight to v7.2.
>
> But there seems to be an issue with fscache/cachefiles (mount -o
> vers=3,fsc) whereby it is creating the sparse files on disk, but is
> not actually populating them with data.
>
> I checked v7.1 but that seems to be working fine. The only related
> merge in v7.2 I could see was the removal of fscache as a backend for
> EROFS.
>
> Maybe that took with it something that is affecting the NFS case too?
>
> Daire



-- 
Daire Byrne
www.brahma.io
Follow us on: LinkedIn | Twitter | Facebook | Instagram

This email (including attachments) may contain material that is
confidential and/or privileged for the sole use of the intended
recipient. Any review, disclosure, reliance or distribution by others
or forwarding without express permission is strictly prohibited. If
you are not the intended recipient, please contact the sender and
delete all copies including any attachments. Thank you.
