Received: from proxmox-new.maurer-it.com (proxmox-new.maurer-it.com [94.136.29.106])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0F7803C2B8F;
	Sun, 11 Oct 2026 20:33:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=94.136.29.106
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791750834; cv=none; b=AahvpHtQ4XHxXAGdWM5EluAX9JPKKnDELKpOuQUAfh/G1drz13EP9EJcaYHSXuonQyqQRanxXwsbci05Xx5AoOufxkp8jK3LiJbHwJcQ2nUjeXnCeKc2J+VxFzPybbPMPp/C2d0SiyGf9SmJs+/9XMsUK30GbOUjGSmOK+WtQIk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791750834; c=relaxed/simple;
	bh=g4UWbUinchomSLFSYVuzUtSeD0BgU42CnUiWXIZ2ddc=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=g7tC00ivzWk8/RJxmwJNAYJS9lXGDdx/l9hSNUsOzlnsKry1bRlisLMcB9+w/jsVfmaDw7RKwSm1DBbbAdZ5qRttRXhbNxg8VPSKfBjY/XgwgBWhNIXMq1bpjRGgJbDmc53L6iuJQeLqgBT1Y1giRmynbUK7C6xoxIWU57q57pE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=proxmox.com; spf=pass smtp.mailfrom=proxmox.com; arc=none smtp.client-ip=94.136.29.106
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=proxmox.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=proxmox.com
Received: from proxmox-new.maurer-it.com (localhost.localdomain [127.0.0.1])
	by proxmox-new.maurer-it.com (Proxmox) with ESMTP id D1BB547FED;
	Sun, 11 Oct 2026 22:33:43 +0200 (CEST)
Message-ID: <40e4d425-8239-4375-ad96-adeff63e0f8d@proxmox.com>
Date: Mon, 12 Oct 2026 07:33:37 +1100
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [REGRESSION] 7.2.4: nfsd sends CB_OFFLOAD with all-zero stateid,
 async NFSv4.2 COPY never completes
To: Greg KH <gregkh@linuxfoundation.org>
Cc: stable@vger.kernel.org, regressions@lists.linux.dev,
 Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
References: <7cc824c4-632d-49df-ae5e-cfcbb5bf76ad@proxmox.com>
 <2026101121-staining-scheme-358a@gregkh>
Content-Language: en-US
From: Lubos Rendek <l.rendek@proxmox.com>
In-Reply-To: <2026101121-staining-scheme-358a@gregkh>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-Bm-Milter-Handled: 55990f41-d878-4baa-be0a-ee34c49e34d2
X-Bm-Transport-Timestamp: 1791750823244

On Sun, Oct 11, 2026 at 09:19 +0200, Greg KH wrote:
> Can you just use git bisect to determine the offending commit?
>
> And is this also the same for 7.3-rc?

7.3-rc6 works fine here, only 7.2.y and 6.18.y are affected.

I didn't bisect, but Jeff confirmed 14b978e8d05c as the culprit and
Sasha has queued the fix, so I think a bisect isn't needed anymore.
Let me know if you still want one.

Thanks everyone for the quick response.

Lubos

