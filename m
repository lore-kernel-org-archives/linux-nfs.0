Received: from mail-ot1-f54.google.com (mail-ot1-f54.google.com [209.85.210.54])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D6DF54C33F9
	for <linux-nfs@vger.kernel.org>; Thu,  8 Oct 2026 15:28:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.210.54
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791473314; cv=none; b=S1SwHVuQUBiVUbo1cF6KlYAHueegenVmZj1A+1BUNZv6b4zDGsfx9fHH1YjawJ8u7IItTuB49h5okBGRh7fsGiOBPANhQHXRjrBXXTeW34aNma0vTW5vJK9zlYmjj6vbt+gOdizcBlq+CrzOV87cIZDOjXAwxZ8WgpEjOzOdu5M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791473314; c=relaxed/simple;
	bh=xPIkTrWXwRX0CL0W0fiuITjlLJD76IEIwGpDkmWc6Eg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=b8Z6Js9v0sCjXdBUZj3CZxIcDvsZK135kqKYLsZmV0wneNLVyc/Ziibj5qWpx3AzPAAjoaUW8WtYWnt/bxyfUccbwER1M4dzQtjGzYK3AumA6UygRsaFDCb4v05v7W7Tz5+MNp+/0EWD7h4Wd1no3Chxt5S+7vl5J1nHoqkpKFQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=FvJ8yhmN; arc=none smtp.client-ip=209.85.210.54
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="FvJ8yhmN"
Received: by mail-ot1-f54.google.com with SMTP id 46e09a7af769-8266c388b67so2939394a34.0
        for <linux-nfs@vger.kernel.org>; Thu, 08 Oct 2026 08:28:30 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1791473309; x=1792078109; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=JOmVZUV8dWCecF0YjRXtl3pU/8WRFPW/xw293xIwNYM=;
        b=FvJ8yhmNscRIVTTGBcMxq4Ao90blQdAMv+RKihE2eERsYTgnuPHGDERwTL13F31Lzq
         BwLwyEUQ2/iNG9fudW9a5l2YeRAvtitMsxu2/RXcPUOfwg3SVC67XlceGH/qEJAR3b7a
         QNPteWXKm6f8EGnzc6NDO6IfL9f8w3qBgvQOonNpV/owN5gTSAERBVIJEf+0L8wsBvIq
         tL4hAMdb11a6fAxfQdyhgk3d8UH2S9P9MQbk/khMBjiHIS7jxE7qxcL+EiIbmKEAfM6y
         y8jETrx9LZevF+oRqmwfYB1vuPytgS8L/13n5g8fBJeyJfrKOXKnSWBe4uxSYRj9m8Gh
         jkig==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1791473309; x=1792078109;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=JOmVZUV8dWCecF0YjRXtl3pU/8WRFPW/xw293xIwNYM=;
        b=CcIlFCXaS0c4Kfjn2b3FuPFa/2faVPgKDLeufdjJFBxFT4RZnM4B/9L9EIrPjVClve
         20Ilp/dQ6dpC4Kki5VB1A2fm3iZ/ndQ97ZFuR6QOfSSBLtdntPvWLzyDt63RBOUIrWZO
         SA2suim4d/E+vUtdKT8r8CYVnfgrOxQuYbUwEN4yYcKq7fnkZhUy2h2HOzverzc72C2j
         ldogDR2ry+Epjr+diF+Hqs1JkmfXL3s8P9FrlSnJ2tJGA0ZopIyvX9P5CwcmAEH/g4ba
         GsyJtSM4zF8492VP1aXXxeeXEW1IJ8iJIqznLR2ZVqFXvJxG6ZDPNUwjFa4asAVpLk1y
         M2CQ==
X-Forwarded-Encrypted: i=1; AKwUvByRojV4N1KX858k1l4NYBDtmvCqarviFsg8M/GTMgoQbHcVj4TYS+k6EuHw0guzJnUUxNySpOp29ZU=@vger.kernel.org
X-Gm-Message-State: AFuF++k+XntMPsGCfbHQgPIY2l1qYE7Pwi+xiZ9OlRwPhEZBNpjLgmSq
	sgADBOCOtwxZtUStrSbj3n8BKeGj2/SWJgnYh5KOGUaOOeFwb5hJeRiZrpRN13TV4sA=
X-Gm-Gg: AYBFou1bnDQpG2uVB2yHhqFPHHcVTJ3h+3KDBZ5r+5KAyBJtpwwxlSQU07OjWgo1PJf
	PBmMl8kU6SrRIPOYAIpGLVuF7H/HvYtjtyQ315XxEExg+/+z6Wf88yrSP2RYcjcxCqB4OCaGi43
	b/QpbUb7mcuuM+vl22mVNsaIe8medSYhGWmUflN4nulTN8xg9OxxCd5hb6sWPT2ABmkycNbHWz+
	hcAOBlJWmc38uWYRvRYwLMbPatMoV1CJN6Z+GR79FuucLwodB1xSgos73WL/M0vSGeP8r3StPdS
	VjfL34fSzLFWE7NV4uWtCP7kVsTsC4WU3KOAvXKonJnsloorQRjdYqbcDrre3n4zCRvd/RDaU12
	wz1c25X77nXzI/2kLNA4uZ4ac8QaKAe5tU+d51iUwDMy1m58oK+PqqaAK5oP2sFC2AE6+5O7xPA
	hNAvbotGchXP776/0mcUNgADuYI+8INnNM0WZdIrbIddP0TtrNuqZU4sCD4YajX1q6kW7A+kiH1
	xqV0lHXOiFthOQL4w==
X-Received: by 2002:a05:6830:6d24:b0:822:b35a:a2d3 with SMTP id 46e09a7af769-82acfbb2f63mr6766567a34.9.1791473309431;
        Thu, 08 Oct 2026 08:28:29 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-82ad9eeb5eesm5901841a34.2.2026.10.08.08.28.28
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 08 Oct 2026 08:28:28 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Chuck Lever <cel@kernel.org>
Cc: Benjamin Coddington <ben.coddington@hammerspace.com>,
 Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 linux-nfs@vger.kernel.org, Daire Byrne <daire@dneg.com>, bpf@vger.kernel.org,
 Martin KaFai Lau <martin.lau@linux.dev>
Subject: Re: [PATCH RFC v2 0/9] SUNRPC: dispatch ready transports round-robin
 across clients, classes from BPF
Date: Thu, 08 Oct 2026 11:28:26 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <D87A521D-E15E-4E87-A467-C73DED8ADD05@hammerspace.com>
In-Reply-To: <5f226738-0062-4e78-af4c-c68c1433e1b2@app.fastmail.com>
References: <cover.1791402701.git.bcodding@hammerspace.com>
 <5f226738-0062-4e78-af4c-c68c1433e1b2@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 8 Oct 2026, at 11:19, Chuck Lever wrote:

> On Wed, Oct 7, 2026, at 3:59 PM, Benjamin Coddington wrote:
>> This is v2 of [3], with the change I floated in that thread: the kernel
>> no longer decides which transports belong together.  By default nothing
>> changes.  An administrator who wants peers grouped loads a small BPF
>> program that returns a class for each accepted connection, and the pool
>> takes turns across classes.
>
> As a quick response to this posting: I'd like to hear opinions from others
> on this approach rather than just fetching it straight into nfsd-testing.
>
> Having patches to mull over is great. Thanks Ben!

No problem, thanks for all the feedback and discussion so far.  One point of
trouble on the bpf-list side is their CI bot can't apply these patches
because there are conflicts from the nfsd-testing base.  It might be that
the bpf folks won't even bother to review if their CI can't build it..

If this goes further, I'll rebase a next version onto something the bpf-list
tooling can handle, then back to nfsd-testing if it looks like its mergeable.

Ben
