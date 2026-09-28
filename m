Received: from canpmsgout11.his.huawei.com (canpmsgout11.his.huawei.com [113.46.200.226])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9BF1238F624;
	Mon, 28 Sep 2026 06:19:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.226
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790576360; cv=none; b=ExPKGgblfPlM4BNGTd7meJIFp9cRXkmcaANMYEZD0JlVeTrwratVZS4+krE9v0AuTqbZeBwd7kWBK5zR8oqRz7PRID2qtuAQUk4uzugErmilS8tM7xFoMRjXvMjLh/NrD2Jt1ovtYqCfzsHv/sLbj0iqIO0Gv4S+cp+CZf59TJA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790576360; c=relaxed/simple;
	bh=4fL1geGwR/vTw2pP+aud257yMQC2kIMBAThqmN3v7XE=;
	h=Message-ID:Date:MIME-Version:Subject:To:CC:References:From:
	 In-Reply-To:Content-Type; b=tcgQAugebzns6PvivHglY1Q3BAeWg822Q0LhpPQKYLye9TB7Ue9YbBDZUBLvwiEBIZypGvU4J7hhHMHRyZ69eBpvnxxQsb9B/d3V2V0Tl3s6dml8c8gxzb+KEQsqk9YvARhl0KkEFXuDZF6qLJ3mCyT/RAZiqynLKaopWHeGlmw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=XvJLuFVF; arc=none smtp.client-ip=113.46.200.226
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="XvJLuFVF"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=hQEbXTR0WO6OLctre3xEpANMZkBOustPdfsjT/vetaI=;
	b=XvJLuFVFKIsF5clGxrSoqwAGVY+g3ugM68udF3ON7tQ/lQLwaMuoYIolmm9/YnF1e05w8Iw8K
	PDQnaD7jO+WxUfz/naLxHMBEuQrIGqHIYfxDCR1YoRyqyy6HAML1dNc1Gcw3j4CInQXfpbQm9P0
	yW8zOpXooIbBwC6YE0IqSuo=
Received: from mail.maildlp.com (unknown [172.19.163.200])
	by canpmsgout11.his.huawei.com (SkyGuard) with ESMTPS id 4htW6Y0jfbzKm5t;
	Mon, 28 Sep 2026 14:07:01 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id CAABB40563;
	Mon, 28 Sep 2026 14:19:12 +0800 (CST)
Received: from [10.67.109.91] (10.67.109.91) by whupemk100010.china.huawei.com
 (7.152.184.41) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Mon, 28 Sep
 2026 14:19:06 +0800
Message-ID: <7161a5f0-0176-45c3-9e78-d90e39cf4288@huawei.com>
Date: Mon, 28 Sep 2026 14:19:05 +0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC -next 09/12] landlock: Implement metadata access hooks
To: =?UTF-8?Q?G=C3=BCnther_Noack?= <gnoack3000@gmail.com>
CC: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>, <rdunlap@infradead.org>,
	<gregkh@linuxfoundation.org>, <rafael@kernel.org>, <dakr@kernel.org>,
	<dlemoal@kernel.org>, <hch@lst.de>, <axboe@kernel.dk>,
	<viro@zeniv.linux.org.uk>, <brauner@kernel.org>, <jack@suse.cz>,
	<dhowells@redhat.com>, <code@tyhicks.com>, <linkinjeon@kernel.org>,
	<sj1557.seo@samsung.com>, <yuezhang.mo@sony.com>,
	<hirofumi@mail.parknet.co.jp>, <cel@kernel.org>, <jlayton@kernel.org>,
	<neil@brown.name>, <okorniev@redhat.com>, <Dai.Ngo@oracle.com>,
	<tom@talpey.com>, <miklos@szeredi.hu>, <amir73il@gmail.com>,
	<senozhatsky@chromium.org>, <chenxiaosong@chenxiaosong.com>,
	<zohar@linux.ibm.com>, <roberto.sassu@huawei.com>,
	<dmitry.kasatkin@gmail.com>, <eric.snowberg@oracle.com>,
	<stephen.smalley.work@gmail.com>, <omosnacek@gmail.com>,
	<casey@schaufler-ca.com>, <nanx95726@gmail.com>, <djwong@kernel.org>,
	<daniel@iogearbox.net>, <linux-security-module@vger.kernel.org>,
	<linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <netfs@lists.linux.dev>,
	<ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <linux-unionfs@vger.kernel.org>,
	<linux-cifs@vger.kernel.org>, <linux-integrity@vger.kernel.org>,
	<selinux@vger.kernel.org>, <linux-kselftest@vger.kernel.org>,
	<xiujianfeng@huawei.com>, <lujialin4@huawei.com>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
 <20260924104831.1081137-10-caixinchen1@huawei.com>
 <20260926.a96402fcbd4b@gnoack.org>
Content-Language: en-US
From: Cai Xinchen <caixinchen1@huawei.com>
In-Reply-To: <20260926.a96402fcbd4b@gnoack.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: kwepems100001.china.huawei.com (7.221.188.238) To
 whupemk100010.china.huawei.com (7.152.184.41)

You are right.

I will change in the next version

On 9/26/2026 4:38 PM, Günther Noack wrote:
> Nit: It feels like this comment about implicit timestamp updates
> (especially the size change) should go in the top-level documentation
> for the WRITE_METADATA right?  setattr() can not result in a size
> change, after all, AFAIK?
