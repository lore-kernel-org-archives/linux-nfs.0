Received: from mail.cipixia.com (mail.cipixia.com [5.78.22.95])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DA18D356747
	for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2026 05:50:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=5.78.22.95
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785477019; cv=none; b=pNdbcJmXBYVUol/3McZl+9EYc7GLxaob8T3snDVFc8TP8KQWgeJxBGF1WEznWJrh9QTIfnCY7dIw7RpZxqvxxM1sn3ra45qwu8PBxQbgsO/UqV0OOZQuPNTHFDS/BAw0D2UDipCpqjl0zOCFRJI1kFjkNBVpHTcNl9xnbUb/VHA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785477019; c=relaxed/simple;
	bh=dS3Daa1b24RbgGbK3UOxZBpdPlRS2tvVFzQ8u1zEyHQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=AoT/WzpKEGvIgwV3T55jnyAmhucVReFQjnUcmzhxfkPxF+u2VbnieI1GT8wgtO+4soq1qK3tBPpSn5lQmX1n3zAlrVOmH+fWSGREKu+kZNXKZIhc1j/ibCz44Psdayz0fPMTM/ulgvgQ34WCMIGJuuSM3L67au2Xh9PJYBPpxGs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=cipixia.com; spf=pass smtp.mailfrom=cipixia.com; dkim=pass (2048-bit key) header.d=cipixia.com header.i=@cipixia.com header.b=eoDPxAqN; dkim=permerror (0-bit key) header.d=cipixia.com header.i=@cipixia.com header.b=ZuLjrBNG; arc=none smtp.client-ip=5.78.22.95
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=cipixia.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=cipixia.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=cipixia.com header.i=@cipixia.com header.b="eoDPxAqN";
	dkim=permerror (0-bit key) header.d=cipixia.com header.i=@cipixia.com header.b="ZuLjrBNG"
Received: from [192.168.1.1] (scrubbed.invalid [10.0.0.1])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange x25519 server-signature ECDSA (secp384r1) server-digest SHA384)
	(No client certificate requested)
	(Authenticated sender: matt)
	by mail.cipixia.com (Postfix) with ESMTPSA id 4hBFKH3DBSz2yPZ;
	Thu, 30 Jul 2026 22:40:35 -0700 (MST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=cipixia.com;
	s=rsa2048-20260504; t=1785476435;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Wl0pYsf5pcSiDvk4a7r9bDCHd92Gs6NWir47ron9J0Y=;
	b=eoDPxAqNEdWXss5fnSRPrwLFFkR89d/jnNkk3HDGZQHqeiQ/hML/hChtjEIH3VOO7ETXtK
	+2bnWy5yCqSXompLA63LLDFL5BGTV6CYlLdzUsLmJM8GonTsi5wgUOfnNGVF2fMDDx/e95
	Q2T9vepAGjVAmErL9R7zZYercNpCBq4ieMu4/L1hiM/+lch0nMsOTKx+yAHZj2MiIHJeBj
	2WVVJ1frOE4bqn0ndSBzjT1JEgmWmsME+QdisEuiNl6RLHAj9iQt+h0xdC737RBewZkmv2
	EHc3K+ejAT4yxGLW43OWxPWnUNQL06b9vy33jIrRRAFCKlBdpLeNsW8DFEmAhg==
DKIM-Signature: v=1; a=ed25519-sha256; c=relaxed/relaxed; d=cipixia.com;
	s=ed25519-20260504; t=1785476435;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:content-type:content-type:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=Wl0pYsf5pcSiDvk4a7r9bDCHd92Gs6NWir47ron9J0Y=;
	b=ZuLjrBNGCE8FCHY3kg4aN94T+KUXAUF5o69dfHgb3pjsWM7gwS+po8iBU5ceLwqB7+zfds
	dQrQLb4xwfdzNBBw==
Message-ID: <7ddc02d8-fa98-4d89-b2c7-0048fe9cfa10@cipixia.com>
Date: Thu, 30 Jul 2026 22:40:34 -0700
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [BUG] NFSv4.2: futimens() returns success without sending SETATTR
To: Michael Yang <michaely4ng@proton.me>,
 "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Cc: =?UTF-8?Q?Holger_Hoffst=C3=A4tte?= <holger@applied-asynchrony.com>
References: <nMlXgkbm-9ZP_fFN16OpzFd4kwNlyXq169-6CoOE4nuHyTsmGaFeJgzuhj3grRboJKg9RapKov2_FJ1E3BCL0oZ7UNzF0pgwwhVC6VOVJYQ=@proton.me>
 <fcffc38c-80fd-ca2f-1b1a-f9d041c6a2c7@applied-asynchrony.com>
 <rW3QLccRCVEh1K5wdSXYsXqoy7-0LhDI_yFdXIxHj9L8v9BfBdI1U3RM4eAqhktqrOiL25N_JPtUBygWz1v3yxT3OBnZxjSTtW9Pyk9Ngmk=@proton.me>
Content-Language: en-US
From: Matt Kinni <matt@cipixia.com>
In-Reply-To: <rW3QLccRCVEh1K5wdSXYsXqoy7-0LhDI_yFdXIxHj9L8v9BfBdI1U3RM4eAqhktqrOiL25N_JPtUBygWz1v3yxT3OBnZxjSTtW9Pyk9Ngmk=@proton.me>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit

On 2026-07-24 at 21:07 (-0700), Michael Yang wrote:
> I've found this report (https://bugzilla.proxmox.com/show_bug.cgi?id=7621) where the problem manifested as early as 6.17.x and 7.0.x (but is not present on the 6.12.88 LTS kernel), and is isolated to NFSv4.2.
> 
> I can confirm with client mount option vers=4.1, the timestamps update successfully on the server.
> 

I'm also seeing this same issue on Fedora 44 with kernel 7.0.8 and 
nfs-utils 2.8.7.

In my case, extracting files locally preserved the timestamps correctly, 
but copying them to an NFSv4.2 mount with rsync -a only showed the 
preserved mtimes on the client. The server-side backing inode did not 
update, and the client view later reverted to the server timestamp.

I also saw the same behavior with touch -d.

I have not tried forcing vers=4.1 yet, but disabling NFS delegations on 
the server with fs.leases-enable=0 made the problem go away for me.


Thanks

-- 
Matt
