Received: from mail-pj2-f43.google.com (mail-pj2-f43.google.com [74.125.227.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0C1BD3845A7
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 18:27:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.227.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790620065; cv=none; b=XzW4Z2UBHNOJTT4PwCV4xvjTwVwPVxToaipR/jQeB3jyQoTNMsk9Zof++42iW7PSz0iLp9iQbJ6uyNVIebYoFi5zgouBh0SQzCIvBOvQbCdY2chIWlXPmWM6EJQ7J2xZt97y8EHPurp44+agDh8ytolffLV91FOyibZhmpI1XF8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790620065; c=relaxed/simple;
	bh=t+Wl467fbPC5kkDsovZkI/r9q+G/kPOqYLWWS7/qWJ0=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=SA5jNec5IDKvLPzs7b3a+G7fh/Q9deFuAbiJo7nUc+rRLCMky9m3baeMdC4Y6H9tdIqENBbRGEUDsCKd5dXGO32O6QibKV0HXcr+uhaV+jwO0sKDDHd2IsTrIvwfyf4CaoV/Nhd59ZkD7iyKdVmnmRj6l7S2IdIZBatHOvX23hI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=SfJcxZrq; arc=none smtp.client-ip=74.125.227.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="SfJcxZrq"
Received: by mail-pj2-f43.google.com with SMTP id 98e67ed59e1d1-39b910bdf2eso1688869a91.2
        for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 11:27:43 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790620063; x=1791224863; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=t+Wl467fbPC5kkDsovZkI/r9q+G/kPOqYLWWS7/qWJ0=;
        b=SfJcxZrqat9OyxZDgv9X3pmcpLTNzDLF95p3LTYhADLaLj89GLijLIYo/ngqKrKm9F
         en9GqUFXVY7rUuBfUvFpk/A5p4/QMQUM0c8RGDZfmcfRABXUQ9H9V/SpOUGnu/RQjS/o
         qtukL2xX3PoWfZ1p1j1U9Ff/fv4DCspdUcUORGYEqdBqIK8vQIHr70l+ska90O04sC9L
         Col4wphBgZ8fYj1bCpcDPGQY9b1vqy9n0saRa+pIvI/3PMsVGJfS8NiyMutwi+Z+3kU7
         b8HmsM4Djw25gqcYNdLivHuXu/tvXvB2j/mxAJ6JNEQxxfk7xElcw39SuUoNYroKbkkq
         jxkg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790620063; x=1791224863;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=t+Wl467fbPC5kkDsovZkI/r9q+G/kPOqYLWWS7/qWJ0=;
        b=au3mCiexWGuNV8aaLDVRxfcuM5UmllFLryPim/R+tua8PDM7FcvYjMnZJdtAP5Oltw
         Cyr+/ItNRa8XNbqwCgNA+62BZy1v60Kw2FCm0/bk+Oo006lVJ0faP505Ert8HdKpsyTu
         SpIeMe4/wOq5PuQRReqD0cOur3rCFnmy9t+jMMqoPtPm/REMMj7TVxWJJKnOCpPTYigF
         Au50JL1jXq3D0N6PBB/4dnHEXaNLSFHhFrWFjz7xLcneHvwrum3u+pH4io7AI7PpLtFh
         MDJpNBXM+a378iDVcoDFs4pK6IpDlBlv2cXcgE2dkIa1rlTa1Tk/QOEGlZ70M+ZsMHgd
         6Kbw==
X-Gm-Message-State: AFq9FYLT1S9QarflebiHFLplEoPZUkKm8/mnVPD8skh3ZhGJHbqkr1jR
	53l1sYeEly7Wuq7vXXiWVg4Y32EU+ylTi+gE3Ygq0THy+iTykxHNUq0Y
X-Gm-Gg: AYBFou12w9UpaIOlv3zgy6fPLFi9Ik/2kw4Kr6zjMEv0g5CSVHoet26/tuNv+NVt0yF
	AFJ2FH724WxYAGbC/RZL6abOP/AgzqAZa5S3SXIqCxSpQVj2G+R0thmgnyX320k4SsuypQHEz8z
	3OBDQyOIYcr0DaUpwlrb5ck5c8LY4DuS4zIq/ZAyH95Hfz5fy+AsjkCuy7BPASFCyg/E/Tjdjtv
	cCK65x6JhQ7Xo5zpW50ExfcPpBYCVf7fxvGYzseLDXmD8bmQtZ6u8g7SlcQrNW/jBeoZIaTBiyd
	3GTB5y/4X/LLwprN+i84UjmeGDqCNldw05M7eVi4NFuNQATF6sePk4KcVd/tKamk9ueBfIIbsA/
	MXUMAFqyBSeoCbtYEOtpIloD6z/YcL7KXtjr/6XxwivRWwmTgesHmWFR8OUGTuToMijzmsMKmyy
	nJ69txWGjM5PT86jl8bWUTi6FGiOjaGhyUJa+FpRrDP8xsLvdKm5NKOPjEidAZ78zp8A==
X-Received: by 2002:a17:90b:4a82:b0:3a0:cb48:df6b with SMTP id 98e67ed59e1d1-3a0cb48e2fcmr8188471a91.34.1790620063240;
        Mon, 28 Sep 2026 11:27:43 -0700 (PDT)
Received: from localhost ([8.219.235.175])
        by smtp.gmail.com with ESMTPSA id 98e67ed59e1d1-3a498726d63sm652897a91.17.2026.09.28.11.27.42
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 28 Sep 2026 11:27:42 -0700 (PDT)
From: Dairui Zhang <zhangdairui@gmail.com>
To: Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Dairui Zhang <zhangdairui@gmail.com>
Subject: Re: [PATCH] nfsd: fix READ payload landing one page ahead of the XDR accounting
Date: Tue, 29 Sep 2026 02:27:39 +0800
Message-ID: <20260928182739.1835909-1-zhangdairui@gmail.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <20260927094535.1745224-1-zhangdairui@gmail.com>
References: <20260927094535.1745224-1-zhangdairui@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Chuck Lever wrote:
> When a preceding op truncates to an exact page boundary, page_ptr
> names the empty page after the last full one, with xdr->p at its
> start. The next nfsd4_encode_operation() then sets
> rq_next_page = page_ptr + 1, which is two pages past the last full
> page, and base is zero here.

You're right - the if (base) guard only covers the mid-page case.
At an exact page boundary base is zero, so it does nothing and
rq_next_page stays at page_ptr + 1, two pages past the last full
page. Your form computes the accounting page directly and covers
both. v2 uses it, thanks for the careful read.

Thanks,
Dairui Zhang
