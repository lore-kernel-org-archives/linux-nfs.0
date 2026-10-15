Received: from mail-oo1-f47.google.com (mail-oo1-f47.google.com [209.85.161.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6C19F3E4109
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 20:25:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.161.47
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792095914; cv=none; b=MeVlBQxX+78VZjb5Q7YglUUFZnglgsZNC06rAoi3Jv6LQE2BQAMkEbwZ2Zj6w9ufq36iO+oteTHfP7zDjWtW0afsXbikpifhEdeMfmC3waAFhjEcgTmkmlMv3XUuDatCzmANfPhgJrG0wkThsmL0XKTclPF35BBtydWUFjL/t5o=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792095914; c=relaxed/simple;
	bh=JR8UUrkb751uoe8c+kx7f/pcFn3yD3phw1+0bnRVD9I=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=truatctCISuWRH5P6DdalnA9WgMhQySTl7jr+1AVanQZD8n4CQeeE5Ai4HeOZnbXWhOjPBNcPBL+reKUpN7qMq8KGZmpbFTZCBvMwFMtWzjs1ggxfrCgNc7lhvhs2wuTWGTqNoHUxvspeql4DhFYUAKgQYQ0ufunM2uGQvjwPaM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=n+3QEbvm; arc=none smtp.client-ip=209.85.161.47
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="n+3QEbvm"
Received: by mail-oo1-f47.google.com with SMTP id 006d021491bc7-6cf995766a3so4599020eaf.2
        for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 13:25:13 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1792095912; x=1792700712; darn=vger.kernel.org;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=FasFmG3+u/YJgr74y+uX/0QTIZ4D+65+ggHRPMtqahQ=;
        b=n+3QEbvmW8iOhA44DqJHBF+Tjx07bELG4BcCaQbPaO1x7xToltuNEPLSDAVf2d5o46
         WrxZrNGc0iOY4Xn141jNuEm/dYnUvrwmOR88e0srPDO+H1kxAQ/F/Wf8OSQncd5eNXWy
         E1doCBACtqdQSh+okRBWhS51RN6pUz7JYj1j8i82P3GVDBDa5pW5Nqfkt5hXRNNS20wH
         P7jxkk2/rageWh0DpBDQ6zpzZl6HMwNUrLIaHkDQxWVb5t+FL0HBaqFMHOgEO5VK559V
         aU2u1ys7f6yJQW6TzjzSeSTzCl3senbabfvk94d5Qf0D1DR+73/G+QF93HEopukd5ztS
         TQiQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792095912; x=1792700712;
        h=content-type:mime-version:references:in-reply-to:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=FasFmG3+u/YJgr74y+uX/0QTIZ4D+65+ggHRPMtqahQ=;
        b=qClGK3qwFSY53FFrKvCK4Rrgr61X93ySVt2WAwL/7AKdny8mirGc9Epj2AMxZ9EV9V
         PFMCRh3Twp+efqL4tH9A+rskUvEAFEdBNlEoMncOhYHzaLjcmjAvUjUK5utSdLBT/Skt
         RbRS3pO2vP6SOPieEPabf/qbQLvwAMDvITiCXALo4oYHuY5Dzf1IjOatEbry7sGrGasv
         sR9bJl3lFybXs6nazY3v3tj9mObA6FEqEtRZnNrSM+hMRDNfYRiDT0xy2Yw0c0MfBxRA
         2b/6V9+Gt4GbZUR2hc5FzAjWlTs/sLeumPYMSR2zkRVn3WiXOUrHtd5eCrN92FwmLHdJ
         2g8Q==
X-Forwarded-Encrypted: i=1; AKwUvByhmFYGmBogzaPWm2Y2g5uTp74KGH5/0SiXt1y++Asqha1IVOvSbP4OyhcS/mXEQ+0V178nUmYUXe0=@vger.kernel.org
X-Gm-Message-State: AFq9FYLRh86SABgzVId9l8xy7PsnOLStSNq25pkWjy2dVyuKUSy6pU0h
	69zEDyTp9KcWiicvsDy2saWJ8BVyAyws9yQiSvpmXOdatlG2nEBrpGHYm2HaevvjHuI=
X-Gm-Gg: AYBFou2F8tm+ZLbPvjVviFttW8UIa63UNIjnvoQUrxMFbyHykGAJ1bPoP0jWuMGlUrD
	H7yyC8ll341iHlo/yMYeUvJPKPdXRNiVwtdYddCJsqE2fE6A/rhboTAnYfxjSMkLlseWoH79HxW
	wZDqIZslJCV2oby86wr1rCRBp2/3YaFJBqmp76DOZOmtYazlhXk5ZOOUyVW2yt+6byS7Q4iJgw9
	j3Bpgab5HgHA0MxAi9xJEI08G3/tLw9watlNk9630g5CYSVYrHgZiFgbxzpM5h2WNTtCUJUOWqf
	PhQK7+Z2EhtupY/eYy+mkq5BqDGxQFdUyZ1iXhit6uVK+nIGUYMdMmFD9wLJ96FR1mC/tFKzx6x
	3+8uTjIe2mY4gXDCCY2w1fhfPR/JnbqE1xDtAUkD9FteGcrP71jF6QYdo1J5M5WfshOVKv//8/B
	x31o3hbHDEJmM8xnzKNx3qB48WBGA/L0xydYcr3nWwAyyM0jaRKITg4UUS09CSaY2hHFbKMqZuS
	inMt4jBbWOAiTJbh3siCs/DqBlXvg==
X-Received: by 2002:a05:6820:4dca:b0:6d9:1628:7b7c with SMTP id 006d021491bc7-6ef10a7fa4dmr15620136eaf.82.1792095911989;
        Thu, 15 Oct 2026 13:25:11 -0700 (PDT)
Received: from [192.168.254.51] ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 46e09a7af769-842a6e12dfasm100050a34.24.2026.10.15.13.25.10
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 15 Oct 2026 13:25:11 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Daejun Park <daejun7.park@samsung.com>
Cc: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>,
 Christoph Hellwig <hch@lst.de>, Benjamin Coddington <bcodding@redhat.com>,
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 0/7] nfsd: layout recall and lease break fixes
Date: Thu, 15 Oct 2026 16:25:09 -0400
X-Mailer: MailMate (2.0r6272)
Message-ID: <5E58C7FF-4202-4F10-BAB7-B027292AD070@hammerspace.com>
In-Reply-To: <20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com>
References: <20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain

On 15 Oct 2026, at 0:15, Daejun Park via B4 Relay wrote:

> nfsd polls a client that has accepted a CB_LAYOUTRECALL by sending the
> callback again every 10 ms, with the stateid of the first callback. A
> Linux client from v6.8 on answers the repeat with NFS4ERR_OLD_STATEID,
> and nfsd takes that as a failed recall. So a client that needs more than
> 10 ms to return a layout has the layout revoked and the fence path run.
> With the block layout that client loses data it has written and synced,
> with the SCSI layout it is cut off from the device.

[...]

Patch 5's point that the Linux client doesn't report NFS4ERR_BADLAYOUT
on LAYOUTCOMMIT - nfs4_layoutcommit_done() throws it away, so fsync()
returns 0 while the block layout writes into unwritten extents are gone.  I
think thats reachable today through the existing recall failure path, so
it would be a client bug - I'm going to see if I can fix that.

Otherwise, this looks good to me.  For the series:

Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>

Ben
