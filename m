Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.219
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795695630;
	b=Jrm+aONv+go1owVY7FKtvzNjM6DCsMtKi82oQcp0sNrsLuk7bF1ScqOaKL3CbwLdvXbM
	 p88VM/sqm7BuLYu6Xngf1/xF4sjMvpYTUSZMW6O/X33KkNuciKynutEl/VBhzZxmbVlTM
	 xwNmnPY+D5J7+dF7hAAbUq6lNsEbd+tSgCML9zeI4T2nahaD75Oo8TMgm4c1D4kcdUqhA
	 5a+Nl0ahtx+wJm4z7yeC4F7H/f6MX/eKuGD/fWbOB2HXNkAskM5oXOyz93Gr09sNxVaO4
	 j9CkI/TO+xAgQSW6JRlARr2QixN0ZZi4raN3KEIxptd2cjvyA9d0ROld5gJIao+b9Gg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795695630;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:CC:References:In-Reply-To:
	 From:Content-Type:Content-Transfer-Encoding:X-Originating-IP:
	 X-ClientProxiedBy;
	bh=bR8azapuIm6gND1BCKfwp153fvy53Jfj0Qmpom7VgG0=;
	b=XWNes9PGmMla8DKSpahZSauKnDfZBMHHUrD56dDc9veOQl+NvT69MhrhDCzo2OYIhJdS
	 Yd64FeUtU4piDCgVNoT8JOjx8ORSx1ZnR0VwE0kNmkc6B16ZFzJvtldie2EQLDOJSj/2o
	 jb3z2FxILK6wcckgwdlj0OxpfuJUDDx3R6xB62lfV5i57r/vmr4SII5lpdr3bt8QKYqSq
	 6n+jFT4YYlzThJbl0dz1ORMnPLDZbw4or725ymiUeAMeDvIrWmmiB9qIbjMjDvBV9mR3R
	 Q2JfGufUHFUW95Yn+WPD4Ynmcqg0TSurqcSLpki/WRCQMjiHt3Md3J8YEXJqU4t7iag==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b="o1j/DIFm";
	arc=none smtp.remote-ip=113.46.200.219
Received: from canpmsgout04.his.huawei.com (canpmsgout04.his.huawei.com [113.46.200.219])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 678FC606A31C;
	Thu, 26 Nov 2026 12:20:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 678FC606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=o1j/DIFm
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=bR8azapuIm6gND1BCKfwp153fvy53Jfj0Qmpom7VgG0=;
	b=o1j/DIFmJzlB2Mlzls2lw7Bhpj2OKKbQ6ovNSQepgOjJAoOXBsyGEQeuUjfjcM57YESShuv6I
	bO5kL9S8DgZK2SBboIo/RApBbgUTS0NjTMz/O+s05JFyIBMbxsUYdWcWpGvYEKp3c6Q58u8b04q
	jfrk87D8lgFScrQqJh7YhKw=
Received: from mail.maildlp.com (unknown [172.19.162.223])
	by canpmsgout04.his.huawei.com (SkyGuard) with ESMTPS id 4jZwbp4Q1Xz1prLJ;
	Thu, 26 Nov 2026 20:20:06 +0800 (CST)
Received: from whupemk300014.china.huawei.com (unknown [7.152.185.8])
	by mail.maildlp.com (Postfix) with ESMTPS id 4C34B40561;
	Thu, 26 Nov 2026 20:20:24 +0800 (CST)
Received: from [10.174.177.221] (10.174.177.221) by
 whupemk300014.china.huawei.com (7.152.185.8) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Thu, 26 Nov 2026 20:20:22 +0800
Message-ID: <3e8628bd-2171-4e70-b448-4feb8a7e9eba@huawei.com>
Date: Thu, 26 Nov 2026 20:20:21 +0800
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v3 3/3] xprtrdma: Wake connect worker on device removal
To: "tmenninger@purestorage.com" <tmenninger@purestorage.com>
CC: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
	<neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	<Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, Trond Myklebust
	<trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>,
	"linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"stable@vger.kernel.org" <stable@vger.kernel.org>, yuehaibing
	<yuehaibing@huawei.com>, zhangchangzhong <zhangchangzhong@huawei.com>,
	"weiyongjun (A)" <weiyongjun1@huawei.com>
References: <20261124021842.130141-1-lixiasong1@huawei.com>
 <20261124021842.130141-4-lixiasong1@huawei.com>
 <179563855914.3954750.11018048330217114132.b4-review@b4>
In-Reply-To: 179563855914.3954750.11018048330217114132.b4-review@b4
From: Li Xiasong <lixiasong1@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: kwepems100001.china.huawei.com (7.221.188.238) To
 whupemk300014.china.huawei.com (7.152.185.8)

On 11/26/2026 4:29 AM, tmenninger@purestorage.com wrote:
> Could you split these endpoint/CM ID lifetime changes into a separate
> patch, ahead of the connect-worker wakeup changes?

That makes sense. I started out fixing the missed wakeup and ended
up folding the teardown changes in during the v1 review. I'll give
the teardown fix its own patch and put it ahead of the wakeup fix
in v4.

> 
> I'm still working on a reproducer to give you a tested tag.
> 

Thanks for working on a reproducer, Tim.

Li Xiasong
