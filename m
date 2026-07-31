Received: from mail.itouring.de (mail.itouring.de [85.10.202.141])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 92E563E120E
	for <linux-nfs@vger.kernel.org>; Fri, 31 Jul 2026 12:39:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=85.10.202.141
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785501569; cv=none; b=SstCqp31QODnFAmE3uHnkYDYcZXtV9BCtWgWnmIGMXitSwgntqaOs86Eyg/BJD6843gRLC+Y/oLBc0dcMLtymjyeBCr3H82rJyGPWXglHH3d8AbVwAtSdaNtEGOlur5BMaMnZVQdeqLhxs8dFEwLuFkq6NAeXq5SKXqWpjPbtks=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785501569; c=relaxed/simple;
	bh=KH7oSznSkdn0cGqS7t2AZICwnP8qVROUWW94KYbnDws=;
	h=Subject:From:To:References:Message-ID:Date:MIME-Version:
	 In-Reply-To:Content-Type; b=fvnh5nz+60INYMeB1PqESW4J2fkt+0SGRNo7jCd421N07U48B5HcIIIaJ30hJEi/Fu4z9LzMduru6p7fPpqx2xEPxtuBOLLDLrjf6ILizZe56fdNI/x1vP2Oxx7IwY/uGViQYT5MhUxY9U2JxR5vTA0SDy8edohWxktSIWV35RU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=applied-asynchrony.com; spf=pass smtp.mailfrom=applied-asynchrony.com; arc=none smtp.client-ip=85.10.202.141
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=applied-asynchrony.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=applied-asynchrony.com
Received: from tux.applied-asynchrony.com (p5ddd7a22.dip0.t-ipconnect.de [93.221.122.34])
	by mail.itouring.de (Postfix) with ESMTPSA id 6FCE46141;
	Fri, 31 Jul 2026 14:39:24 +0200 (CEST)
Received: from [192.168.100.223] (ragnarok.applied-asynchrony.com [192.168.100.223])
	by tux.applied-asynchrony.com (Postfix) with ESMTP id 1A61160187F36;
	Fri, 31 Jul 2026 14:39:24 +0200 (CEST)
Subject: Re: [BUG] NFSv4.2: futimens() returns success without sending SETATTR
From: =?UTF-8?Q?Holger_Hoffst=c3=a4tte?= <holger@applied-asynchrony.com>
To: Matt Kinni <matt@cipixia.com>, Michael Yang <michaely4ng@proton.me>,
 "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <nMlXgkbm-9ZP_fFN16OpzFd4kwNlyXq169-6CoOE4nuHyTsmGaFeJgzuhj3grRboJKg9RapKov2_FJ1E3BCL0oZ7UNzF0pgwwhVC6VOVJYQ=@proton.me>
 <fcffc38c-80fd-ca2f-1b1a-f9d041c6a2c7@applied-asynchrony.com>
 <rW3QLccRCVEh1K5wdSXYsXqoy7-0LhDI_yFdXIxHj9L8v9BfBdI1U3RM4eAqhktqrOiL25N_JPtUBygWz1v3yxT3OBnZxjSTtW9Pyk9Ngmk=@proton.me>
 <7ddc02d8-fa98-4d89-b2c7-0048fe9cfa10@cipixia.com>
 <10af95c9-fe18-35b9-d696-5dbd53066b3d@applied-asynchrony.com>
Organization: Applied Asynchrony, Inc.
Message-ID: <83b13893-067e-74f0-be47-52661212d0f0@applied-asynchrony.com>
Date: Fri, 31 Jul 2026 14:39:24 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
In-Reply-To: <10af95c9-fe18-35b9-d696-5dbd53066b3d@applied-asynchrony.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit

On 2026-07-31 11:49, Holger Hoffstätte wrote:
> On 2026-07-31 07:40, Matt Kinni wrote:
>> I have not tried forcing vers=4.1 yet, but disabling NFS delegations
>> on the server with fs.leases-enable=0 made the problem go away for
>> me.
> Thanks for that hint. Disabling leases seems like the best workaround for
> now if one can live with the performance hit. Forcing 4.1 makes files work,
> but in turn seems to break directory modification timestamps. :-/

Since 7.2-rc contains a few commits that fix related problems, I decided to
give -rc5 a try (with fs.leases-enable=1). Unfortunately the lack of
attribute persistence seems to persist.

-h
