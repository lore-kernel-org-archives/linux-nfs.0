Received: from mail.itouring.de (mail.itouring.de [85.10.202.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5D9E3D5640
	for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2026 09:55:19 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=85.10.202.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785491726; cv=none; b=ld6qXHSDPnkkazMPqSv46m4NgFNYFvZYXa5zrPI0ewMIfJwEyCGuy7dgIUiUvEGF/urOECVhkLRgT7IXpYpQR0BIti980TF57RRaD43L0293nG5IavlR99uW/TVJjArdTxy9Nz//FgeLSYBP+J6UnOidhLAEPOosT28mFOIvMzc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785491726; c=relaxed/simple;
	bh=uaREOnVH6cecmN4/b2ZMyqLtn7RYSIvnoBo/JSW8dVU=;
	h=Subject:To:References:From:Message-ID:Date:MIME-Version:
	 In-Reply-To:Content-Type; b=lsnh9/KltJTY4C5sHCvxucpfyBBwX0QQS1dVwWqXxzci2pW/uvd9vRGt6skNuDCwRTcBwM3Ha/jNNds8PNJGROaesjew4J8rIdTTw813jf93em5+2KiGkK+d++L/0mHKpyxVNNWmls+/ZW4IBfhgUk2HP/2RLP5tk4AYVdmD/5Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=applied-asynchrony.com; spf=pass smtp.mailfrom=applied-asynchrony.com; arc=none smtp.client-ip=85.10.202.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=applied-asynchrony.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=applied-asynchrony.com
Received: from tux.applied-asynchrony.com (p5ddd7a22.dip0.t-ipconnect.de [93.221.122.34])
	by mail.itouring.de (Postfix) with ESMTPSA id 651796141;
	Fri, 31 Jul 2026 11:49:41 +0200 (CEST)
Received: from [192.168.100.223] (ragnarok.applied-asynchrony.com [192.168.100.223])
	by tux.applied-asynchrony.com (Postfix) with ESMTP id 1573F60187F36;
	Fri, 31 Jul 2026 11:49:41 +0200 (CEST)
Subject: Re: [BUG] NFSv4.2: futimens() returns success without sending SETATTR
To: Matt Kinni <matt@cipixia.com>, Michael Yang <michaely4ng@proton.me>,
 "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <nMlXgkbm-9ZP_fFN16OpzFd4kwNlyXq169-6CoOE4nuHyTsmGaFeJgzuhj3grRboJKg9RapKov2_FJ1E3BCL0oZ7UNzF0pgwwhVC6VOVJYQ=@proton.me>
 <fcffc38c-80fd-ca2f-1b1a-f9d041c6a2c7@applied-asynchrony.com>
 <rW3QLccRCVEh1K5wdSXYsXqoy7-0LhDI_yFdXIxHj9L8v9BfBdI1U3RM4eAqhktqrOiL25N_JPtUBygWz1v3yxT3OBnZxjSTtW9Pyk9Ngmk=@proton.me>
 <7ddc02d8-fa98-4d89-b2c7-0048fe9cfa10@cipixia.com>
From: =?UTF-8?Q?Holger_Hoffst=c3=a4tte?= <holger@applied-asynchrony.com>
Organization: Applied Asynchrony, Inc.
Message-ID: <10af95c9-fe18-35b9-d696-5dbd53066b3d@applied-asynchrony.com>
Date: Fri, 31 Jul 2026 11:49:41 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <7ddc02d8-fa98-4d89-b2c7-0048fe9cfa10@cipixia.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit

On 2026-07-31 07:40, Matt Kinni wrote:
> I have not tried forcing vers=4.1 yet, but disabling NFS delegations
> on the server with fs.leases-enable=0 made the problem go away for
> me.
Thanks for that hint. Disabling leases seems like the best workaround for
now if one can live with the performance hit. Forcing 4.1 makes files work,
but in turn seems to break directory modification timestamps. :-/

thanks
Holger
