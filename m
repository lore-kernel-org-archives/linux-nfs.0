Received: from proxmox-new.maurer-it.com (proxmox-new.maurer-it.com [94.136.29.106])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B55C4538D72;
	Tue, 13 Oct 2026 19:45:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=94.136.29.106
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791920752; cv=none; b=bkXE9p9oNmYrWD+DtIiu6ZxBBq2N5AMYFFr7WlWSHMgXlXiGUv2hPnhN9v3tmzTWRwkg76Ls6OX5ZmqU3d7q0RAZjd/FcCHKNmK5sRxhdjoMcq0ZZsT/SOktVLRPOIKPK1gBNzGZdadyRmJ04+R2YnkFtKc9Ka6Yq0/LB/+SX7I=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791920752; c=relaxed/simple;
	bh=sRVBJiqBGAD/A1Wagts82QIjT/i63TOnqb+BtmRT7nQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=mx5TZDhaEn6M9r+WrI/HzeE4x4DrCsWAD2mc9N/urXasIw30ByJ5izK7wD+a4KqXkQPWZFkf2haXs6MQ/0o/j7Td3O+Rij4cbfGtX90afzpOPM2K9sTwqDfaQSIlYl2NtxSOl/O7IgTqLxOucQqI3oF+LcLQgLLB0Kg2kxSNCQc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=proxmox.com; spf=pass smtp.mailfrom=proxmox.com; arc=none smtp.client-ip=94.136.29.106
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=proxmox.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=proxmox.com
Received: from proxmox-new.maurer-it.com (localhost.localdomain [127.0.0.1])
	by proxmox-new.maurer-it.com (Proxmox) with ESMTP id 146DC45F50;
	Tue, 13 Oct 2026 21:45:42 +0200 (CEST)
Message-ID: <bb39cba3-c4a3-4fc4-b078-c92752cf483a@proxmox.com>
Date: Wed, 14 Oct 2026 06:45:34 +1100
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [REGRESSION] 7.2.4: nfsd sends CB_OFFLOAD with all-zero stateid,
 async NFSv4.2 COPY never completes
To: Jeff Layton <jlayton@kernel.org>, Sasha Levin <sashal@kernel.org>,
 stable@vger.kernel.org
Cc: Chuck Lever <cel@kernel.org>, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, regressions@lists.linux.dev,
 =?UTF-8?Q?Fabian_Gr=C3=BCnbichler?= <f.gruenbichler@proxmox.com>
References: <1791797151.oll70jtyaa.astroid@yuna.none>
 <2026-10-12-1-daily-reply-0001-nfsd-cb-offload-zero-stateid@kernel.org>
 <e67eb43ccee21fc4271269e56be668b3dbf1b055.camel@kernel.org>
Content-Language: en-US
From: Lubos Rendek <l.rendek@proxmox.com>
In-Reply-To: <e67eb43ccee21fc4271269e56be668b3dbf1b055.camel@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Bm-Milter-Handled: 55990f41-d878-4baa-be0a-ee34c49e34d2
X-Bm-Transport-Timestamp: 1791920741506

On Tue, 2026-10-13 at 06:15 -0400, Jeff Layton wrote:
> Lubis, since you did the original patch, would you like to send ones
> for those releases? Then Chuck and I can just send R-b's for it. If
> not, then I'll plan to send some.

Yes, I'll send them. I'll test them on current 7.2.y and 6.18.y first,
expect them within a week at the latest.

Lubos

