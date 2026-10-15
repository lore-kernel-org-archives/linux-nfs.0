Received: from vtj.irix.systems (vtj.irix.systems [82.76.27.144])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BCE73E169F;
	Thu, 15 Oct 2026 19:00:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=82.76.27.144
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792090825; cv=none; b=hy5swx6lnnHn5RFh3tAy6jhTzf3jJlvPG1Epnk9MlmvVmGTUloJEbJQ9jlAt2vyTswmjs8qDneeFimNLvjFlD6B0d90iYAPQ5diWd+x9vuOZ5yF1KOd5k1b80oi2y6buYmleBpipg3EJr5pGtD4cWZExxJt3mFLgyYXEzRJylHE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792090825; c=relaxed/simple;
	bh=EHY+jDXHN8l9W9NAnQiCcDhI/lRVuDk62Io1rS6/3ic=;
	h=From:To:CC:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=ELr9aMcuRbOoxjex5lIXVoWylxA9UW+sY4lwtR/A1n05m16LWIzw8gxVmcOrMxshFcnvKsPrtLS4R5pSZn5zlhBqjXvwDjk5ZHaM2vawmTGPBSXOVyAwT3HevwCG+hlW7de8gGPcE7x7kPSMyr7L8F7OxldRtzBMzU8qMZMyvFs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=andrei-z.com; spf=pass smtp.mailfrom=andrei-z.com; dkim=pass (2048-bit key) header.d=andrei-z.com header.i=@andrei-z.com header.b=bPi8Mk2w; arc=none smtp.client-ip=82.76.27.144
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=andrei-z.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=andrei-z.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=andrei-z.com header.i=@andrei-z.com header.b="bPi8Mk2w"
Received: from MAILGW-BIG.big.vtj.corp.irix.systems (localhost [127.0.0.1])
	by vtj.irix.systems (Proxmox) with ESMTP id 56AA412272;
	Thu, 15 Oct 2026 22:00:21 +0300 (EEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=andrei-z.com; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:from:from:in-reply-to:message-id:mime-version:references
	:reply-to:subject:subject:to:to; s=sig1; bh=EHY+jDXHN8l9W9NAnQiC
	cDhI/lRVuDk62Io1rS6/3ic=; b=bPi8Mk2wywtMFG5yin3/az/KxmVVGDpmcnuz
	2tKaOK2nKnOAhm9tSeHcaqrFwMtL98//5hswoHtvC1y8kxP6KQIhdBEhBBvNfnLK
	NT0RQg3uUk4HeMc1qhcviWLqg435t08Ce9q7dzBLZ3RKlGbPEe9JUcfk2eYXTVli
	i3dJgJjtwigNQ7ltr8MhgIWc+T/sG5x/aEpW4TCCgn6kwbqgKUh7Xk/3eflLbAGT
	PBzhhm5RI0WVyFsEMccsaC7w3dEhsg8tQtcJB19RQ09xgIiien5QEjDH8iYvQv2Q
	c60JSuU2stj9r0Gp3lyokyp3oE4hFebhS/sVX1KJ3miZ38XLJw==
Received: from VTJ-MX.corp.irix.systems (unknown [IPv6:2a02:2f04:1:9c24::6])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by vtj.irix.systems (Proxmox) with ESMTPS id 5084C122AF;
	Thu, 15 Oct 2026 22:00:20 +0300 (EEST)
Received: from [10.89.11.73] (10.57.8.14) by VTJ-MX.corp.irix.systems
 (2a02:2f04:1:9c24::6) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.49; Thu, 15 Oct
 2026 22:00:20 +0300
From: Andrei-Alexandru Bleortu <me@andrei-z.com>
To: Chuck Lever <cel@kernel.org>
CC: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
	<tom@talpey.com>, <linux-kernel@vger.kernel.org>,
	<linux-nfs@vger.kernel.org>, <linux-rdma@vger.kernel.org>
Subject: Re: [PATCH 1/1] xprtrdma: Post small RPC Calls inline
Date: Thu, 15 Oct 2026 22:00:19 +0300
Message-ID: <20261015220019.3412840-1-me@andrei-z.com>
In-Reply-To: <ddd5a532-bdb2-4976-9b1b-6470414473ec@app.fastmail.com>
References: <20261015124826.2962950-1-me@andrei-z.com>
 <20261015124826.2962950-2-me@andrei-z.com>
 <ddd5a532-bdb2-4976-9b1b-6470414473ec@app.fastmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: VTJ-MX.corp.irix.systems (2a02:2f04:1:9c24::6) To
 VTJ-MX.corp.irix.systems (2a02:2f04:1:9c24::6)

On Thu, Oct 15, 2026, Chuck Lever wrote:
> These mean completion latency gains are noise compared to the client's
> own RPC tasking machinery. Perhaps the additional code complexity is
> not worth it yet.

Thanks for looking. The gain is real but small. Over 40 paired runs
its interval excludes zero, and a comment-only patch moved the result
by -0.0139 us. But the 4 KiB write took 48.4 us on average, so the Call
saves 0.4 % of it, and 0.8 % of the 35.7 us read.

> General policy is not to put device-specific details like this
> in ULP code. So, NACK on holding these numbers in a table in
> the rpcrdma.ko module.

Understood. Bart asked for the same on the SRP patch, and I proposed
the create flag you describe on linux-rdma:
https://lore.kernel.org/all/20261015212227.3338582-1-me@andrei-z.com/

I will drop this patch and the svcrdma one for now. If the flag goes
in, the client change shrinks to setting the flag and the check in the
send path, with your lower bound. You can judge then whether it is
worth it.

