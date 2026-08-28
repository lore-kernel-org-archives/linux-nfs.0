Received: from mail-yw1-f172.google.com (mail-yw1-f172.google.com [209.85.128.172])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 00391449B2F
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 12:33:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.172
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787920401; cv=none; b=kg5kZZIrYu46n8nMaqW7pIlCZ6O1M3qM7ArWxEpkHuz3lFU7jWKvWDY/5dGyis377MxC+gj10QAAvbrZDOavWmRJpN5ehw2ITLMDmk9jYgKWFm2d59/HFudfA5jPSW0ufNBrghoJrvUOCQ+/brLunHC8e8tp9oWk5FUM/cpF068=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787920401; c=relaxed/simple;
	bh=bqfJK6AvjcrjKxv8vWiaGOdrwD/fsLSuibq+C9S1YR8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Yv+JmBZHLcxaSgNaPUxz3rb7cEUKmaMdgCMgXuNIIOk9Xmhht1++IvmD4Xrogtse9aHFmyCM1pdL8HrXpoXB7RrbWMixdKUOggxqBzqympV0YUIPYlDBnT1+eLHtlio8WPCOJcwepdWmseaeD1HRVWkqPofGKUokbUWmLj5iD20=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=BfVCfqsl; arc=none smtp.client-ip=209.85.128.172
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BfVCfqsl"
Received: by mail-yw1-f172.google.com with SMTP id 00721157ae682-836cbcd0a48so12431777b3.1
        for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 05:33:16 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1787920394; x=1788525194; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=bqfJK6AvjcrjKxv8vWiaGOdrwD/fsLSuibq+C9S1YR8=;
        b=BfVCfqslo3GL69I4crMY3JvAWuL1m8zKifTWvhLHX9ZJ0lvcRnd5tgmPS8Iawn1TAC
         AyJoMvWzkWa9omMRR+MBal0KqwgbkTGs8QVDnqjjQwwlwgQgw0KFdKTrzDTFz7eKDCwm
         9/mRXG0nRs59A5rIQjS+D4dCD9dXwbo2m5v9UhjHUCaZLZOIWbmr4fqc9Ol5E4/CrktN
         TPb1hnJ0EoD494j4suTvjbCFRcAEPUAflFQ1YHVSVNUVoVt428h9r2eiLhrEREumUo6c
         RCvdaGqCOaULFd5+EgTVuP2WqtyY2Xi9Pba3susZ034rQMDHhvlvldqKoBAUtBlkUGEP
         HZMA==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787920394; x=1788525194;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=bqfJK6AvjcrjKxv8vWiaGOdrwD/fsLSuibq+C9S1YR8=;
        b=q4P5z5jPKaPpZaWhYRoKF0mXoJFJs3hyewXQu41xg6q9ovg+RlFwaYQdclEI61C27l
         ojIgDAjD1O7+NSMRMDenOoMyXNorwU5WEJz7KOX2r+K5x353Doa6WXck+b5eCqkc1wDJ
         qvF5OVaCuAl3JLwd1Ao2qARqxY3datT5/14+QzMZRGqdBKNVT5pO3N8Z0TbsCSFgSfYw
         g+BGmZyyk3WJuYvE6c81m/cVf7fWf4FwmAC4YwjwnTzN9kCBbvSH6HDmnzURwoSPls0E
         nVbT3DYjLBfgh1rHhe/BDUghQJBVBiMP3l0OKSDZVYBCeYSuahY3Al1aO31XOwJB8ygj
         JchA==
X-Forwarded-Encrypted: i=1; AKwUvByagF+bp2fjlf8bxq24TWwqFvRVkfTKCg5RoVa8DHxbhJq8eKbyCzVH0ucHvRYkqDX9twj3QCcgngY=@vger.kernel.org
X-Gm-Message-State: AFuF++mZ/HsGLE8ItJcQxlJV+SBrvbE8mG0BRjWsOR+cLlrLuEWuyMrw
	PIHY/Qdb7cbPlJPANILP0yoGRZ9SGY4fSKAMZU8ETPFQewHM3cxKt3ON
X-Gm-Gg: AYBFou1N0CV+pFI+W1Du8886P9rncWtqnED0Mr2cOGmF1ClMISE94Wh9uWYwtPhyGEn
	V6a+Me02fknWjDfOBVBMeKn0fIcXfl43S86oyZQvN6ekV5I48GFKUy0bxm1d4taFp/fgy7bnAdB
	cUZcgFWeMsBMmHj6E/RDhVvYrZ8V5BpiYFKGPPrtPFbe+4YnsIm0aNcBfgtW2whMOeszcN+w1oo
	3u4hI8zf2+X7dQbSSYc+hmIzfCywt+3pXgN+xMDSMIGyj9YtmF9VFNAc+5XHF9rClRAHlpSQP+Q
	M/oxChN36CGAhOG05776BIvQzqeFfqa2i1/O8o7mLVfC7VrcCRXtkBVFytXYZ+35j1IPbQdWFZq
	tzHijCifjlc4C53EQ1tFzTSGjTJSUwbmYUUGgEgYE5wj1lju6d+RbFU0/K0ZBi9kQWZ0ckHNKA2
	Ek8yvDd7uWhiXPx3ycGEVxIT5Q4P9BNbOBW/6XnpxJeVaUT/ZBNOkaYUWAm/TYO6ksRfs=
X-Received: by 2002:a05:690c:6ac6:b0:854:4fdc:cab9 with SMTP id 00721157ae682-85d65ee9995mr32089877b3.6.1787920394110;
        Fri, 28 Aug 2026 05:33:14 -0700 (PDT)
Received: from mac.lan ([136.55.173.105])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-85e5f4f3b6csm5435987b3.20.2026.08.28.05.33.13
        (version=TLS1_3 cipher=TLS_CHACHA20_POLY1305_SHA256 bits=256/256);
        Fri, 28 Aug 2026 05:33:13 -0700 (PDT)
From: "Cen Zhang (Microsoft)" <blbllhy@gmail.com>
To: gregkh@linuxfoundation.org
Cc: AutonomousCodeSecurity@microsoft.com,
	Dai.Ngo@oracle.com,
	bfields@fieldses.org,
	blbllhy@gmail.com,
	cel@kernel.org,
	jlayton@kernel.org,
	kys@microsoft.com,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	neil@brown.name,
	okorniev@redhat.com,
	stable@vger.kernel.org,
	tgopinath@linux.microsoft.com,
	tom@talpey.com,
	xmei5@asu.edu
Subject: Re: [PATCH] nfsd: hold cl_lock in client_has_state()
Date: Fri, 28 Aug 2026 08:33:12 -0400
Message-ID: <20260828123312.26927-1-blbllhy@gmail.com>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <2026082828-palpable-dingo-241b@gregkh>
References: <2026082828-palpable-dingo-241b@gregkh>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> Please use your microsoft.com email address, and not a random gmail.com
> address.

Sorry for making you raise this again. I will hold off on new patch
submissions until my approved Microsoft email address is available,
which should be soon.

Thanks,
Cen
