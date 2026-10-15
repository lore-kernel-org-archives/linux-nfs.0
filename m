Received: from mail-wr1-f41.google.com (mail-wr1-f41.google.com [209.85.221.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B258053C3C9
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 17:28:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.41
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792085342; cv=none; b=Sm4Ygb82q5Qbg56iBOS6Bf90ipCrIDMG3anLArBVeot7lUJFoqwwnukP+TyodMkZu7kC0YoLntiaIPaIPntIL7e40jWEgtel8d59oXeqSF4jUSH+C5jejwk0tIr0Vpl6oebUrhHVj6BWNkdYK28EWIC9ASDVJ9jALaQrIY5+GQA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792085342; c=relaxed/simple;
	bh=gSNO9YK5nfjHkWHYjlyrDKyJyoyba2/FQKYBvshQ5Lg=;
	h=Message-ID:Date:From:To:Subject:In-Reply-To:References:
	 Content-Type:MIME-Version; b=ZCMtCog4sFEOoFTHSiVGRd5NqD+QjWEjRzM2Y0UAHgzblZAhc2jWkn2eDeaGt6BU6X4HVtFJmmLf8pkSj4Bf7RzGku0j7N2aERnixu0WMbsDoR6yiWDFRo97fIN62xPUVDdTFSFODrIRBN8pZ+IljqJBvHByvd3fLS2+4qhOu64=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=Q664c+w1; arc=none smtp.client-ip=209.85.221.41
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Q664c+w1"
Received: by mail-wr1-f41.google.com with SMTP id ffacd0b85a97d-48441a2ba1bso1135712f8f.1
        for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 10:28:49 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792085328; x=1792690128; darn=vger.kernel.org;
        h=mime-version:content-transfer-encoding:content-type:references
         :in-reply-to:subject:to:from:date:message-id:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=gSNO9YK5nfjHkWHYjlyrDKyJyoyba2/FQKYBvshQ5Lg=;
        b=Q664c+w1snR8189IOMGs9JglgkMEtlkdv8yyCqJWKrEGDIoj1FnETrI1vR58xO0gXT
         KrG6js8t2Xw21R/5pgmZLAm5LYgUMkR4dmUtG8YhPR+rjRcc5cBv+CeFp+yjBlwica4p
         LA6PvIXli+gcbkr+w8ZXR25SIIf0soHL0QsHMFzCnaQsEU7TK5+BYXpuh2kjNFv8R2zn
         qxv0WRrtuDl49zahZRBre4hJM3pXuVbuhVnGlf1sMIxp3GDR0b+VM8bYB3ZHeR4eLGHm
         ODX/1dn39/YfYLI6S0p7tcMLcKFALcnQr2t3IDNuLucz6xVAW6kpaltRUV38mCEab08R
         C8pg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792085328; x=1792690128;
        h=mime-version:content-transfer-encoding:content-type:references
         :in-reply-to:subject:to:from:date:message-id:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=gSNO9YK5nfjHkWHYjlyrDKyJyoyba2/FQKYBvshQ5Lg=;
        b=XzVvlqPXq4ZalxzBHqaj5qLjFNAs4nE1hN0JNeYlG4EzaxsOOKqpZHfXhJ76Mqni/F
         ET1joU/sMBi63PeygRCIN1VYkL2sK2emy9vptRwLtH57wDlx2/3YZpcHuRx6ESSsf+E7
         60ZKzYzOJN1jPQ4WsOKKa5wOFCVc8xfbdZEgFi/TOMGWF4ffxsTFBBkQ9kL2nS7gpHby
         xd9Z66egQO98YA/6mp9DLLzwcEFCQ88mmO31wdyKEe9Bee9UDmsGaF+h04R4qR+2mRD/
         XMv92J8ETCBfS9TQ7pVHWKNsQXT3RZlaLkvtlMGxoDZDf80BltpNi3ehTHXncqiYFTs2
         oyCA==
X-Gm-Message-State: AFq9FYJsy8qnrbb/vachHDlTxohAWLCdchZyTpCwIPN3Lm7gcxAN9lnG
	kjA5eghruEBFUXE/BC7Zi8HUtVJpxqYwoVrT0RaQeM6zHTC0AocTHE2MH8DnN6OBcHY=
X-Gm-Gg: AYBFou0UN7FooGK2Ev1vk5xLyool9CVyqWvLnFEEOesjX+nWZlOkg7pEhWTG8nnisob
	xf31i2SMzILDM+2eZG3iTYrX91UAv2mQx8MgZPm3PJ23HVbgBg2G0o9ddTu8QRqhqidoEllfCTl
	mxj75eVVMf7uTt30hrC3905shKf10w3Fp902mp0ksMF1CaZsV7iUKu/gL3527NutlhFeXxQ4j3u
	tnl4vUz2fJ1O8fsworAZBakmfQpio9X+KFxJIVkSPVXGt6vTgGPjWfpCen2VzzoPGBARVI5Z/j/
	yz2+2lFRphWVhP3xyCaFyo9YO03k2KTloWW9vF1zU2X7r1Oybc72HJlEYorKJe20uM5yDhGBq5k
	6lANfIJEyJ1I9Ej3ULklLKiIbsbPObgmASd1B4uaPQ8kpIJoUL9bjrO8yyLFE/O7vUSYRedUJvM
	wdNt1DTvKIFIUQf1uG1zU3ZKYjY+khF7ysnT2m0C6HIzIAptjkkTcMkIzSj4gyVg5aM/ybE26rf
	tYalA==
X-Received: by 2002:a05:6000:3108:b0:48d:d736:4df7 with SMTP id ffacd0b85a97d-48dd7364f87mr27729886f8f.30.1792085327597;
        Thu, 15 Oct 2026 10:28:47 -0700 (PDT)
Received: from SurHub.localdomain ([102.213.68.193])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-48de0ac36f9sm19097036f8f.36.2026.10.15.10.28.46
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 15 Oct 2026 10:28:47 -0700 (PDT)
Message-ID: <6ad10d4f.869db401.313f36.ee1e@mx.google.com>
Date: Thu, 15 Oct 2026 10:28:47 -0700 (PDT)
From: Abdifatah Suruur <suruurism@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] lockd: fix use-after-free in nlmsvc_retry_blocked()
In-Reply-To: <6dbeec76-a55d-4e41-9115-99d199997497@slotpi15m67>
References: <20260930202212.1482-1-suruurism@gmail.com>
 <6dbeec76-a55d-4e41-9115-99d199997497@slotpi15m67>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Resending in plain text: the list rejected my earlier reply as HTML.
Chuck already has this; apologies for the duplicate.

Hi Chuck,

Thanks for the quick review and the detailed explanation -- both points
are well taken.

On the retry path: I hadn't checked nfsd-testing before sending; agreed,
it's the same fix in the same place. I'll drop this patch and base any
future lockd/NFSD work on your nfsd-testing branch.

On nlmsvc_notify_blocked(): you're right, and thanks for spelling it
out. I missed that __locks_wake_up_blocks() clears waiter->flc_blocker
only after lm_notify returns (the smp_store_release in fs/locks.c), so
any concurrent locks_delete_block() from the GRANT_RES/CANCEL paths has
to acquire blocked_lock_lock and wait for the callback to finish. The
list reference can't be dropped between the spin_unlock() and the
svc_wake_up(), so there's no window there. Please disregard that hunk.

Thanks again for the explanation -- it also tells me where to look next
time.

Regards,
Abdifatah
