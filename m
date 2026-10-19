Received: from canpmsgout06.his.huawei.com (canpmsgout06.his.huawei.com [113.46.200.221])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C388E4F4043;
	Mon, 19 Oct 2026 13:16:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.221
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792415807; cv=none; b=p9y034GIKmj4+x2ziW0SHvyiIy6KpV+4gM9hwHkf4SpI1WD5bNfXvlk6wmN02Rykiv/Br/YOrfokJtDWhbEBp2w5wD0E0f5eDZcI/DEJ7vTGT4uuIJEFNn/JnaJavg/lZ5aEaSbn/jbmcPsYyQrdRAZjxIa4CWLcNWCO2ECsWMI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792415807; c=relaxed/simple;
	bh=KEfUjJ+sWeyEpypWIo35O6elA0OeVZ28l/vNOIqBtYE=;
	h=Message-ID:Date:MIME-Version:Subject:To:CC:References:From:
	 In-Reply-To:Content-Type; b=mA5/VZwc5jpK8Yvou1ZFTHU80J2mswJ24LI3Boh1XORYUYOGJ7C3SX5xYGegXqi5nVbI2fdtrTIwxSDnvltkUUHaL/joIQZGSrD+FMg0OC0iXHsb3acLJ3cEb/9DU9OTaiHq+y4juD2qWTHboD48rp66iSVaQvrOSQp+um4GJGs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=CGjJxHSS; arc=none smtp.client-ip=113.46.200.221
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="CGjJxHSS"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=KEfUjJ+sWeyEpypWIo35O6elA0OeVZ28l/vNOIqBtYE=;
	b=CGjJxHSSLnLyFiBJ6fmCvw7MlJSp71N6IQMPcQkTfVBF4w4+qhSNBqybtc2YkWCvE5LwoEOVU
	nkl6Q6kL3AgrL1evhkMPi2OeyEjemmmAVgbOgxQlks5tBhbrz4Ra7a12Oy27gvkosJfa6xtd7mk
	IO1wVoLvEGKoMecheF6kbbs=
Received: from mail.maildlp.com (unknown [172.19.162.223])
	by canpmsgout06.his.huawei.com (SkyGuard) with ESMTPS id 4j7bfV0G5ZzRhrQ;
	Mon, 19 Oct 2026 21:16:34 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 3320840575;
	Mon, 19 Oct 2026 21:16:37 +0800 (CST)
Received: from [10.67.110.140] (10.67.110.140) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Mon, 19 Oct 2026 21:16:30 +0800
Message-ID: <5e6e9ac9-172e-4434-a333-8bcad9e026de@huawei.com>
Date: Mon, 19 Oct 2026 21:16:28 +0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 -next 09/18] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
To: Justin Suess <utilityemal77@gmail.com>
CC: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>, <ast@kernel.org>, <daniel@iogearbox.net>,
	<andrii@kernel.org>, <eddyz87@gmail.com>, <memxor@gmail.com>,
	<martin.lau@linux.dev>, <song@kernel.org>, <yonghong.song@linux.dev>,
	<jolsa@kernel.org>, <emil@etsalapatis.com>, <ihor.solodrai@linux.dev>,
	<rdunlap@infradead.org>, <gregkh@linuxfoundation.org>, <rafael@kernel.org>,
	<dakr@kernel.org>, <johan@kernel.org>, <dlemoal@kernel.org>, <hch@lst.de>,
	<axboe@kernel.dk>, <viro@zeniv.linux.org.uk>, <brauner@kernel.org>,
	<jack@suse.cz>, <dhowells@redhat.com>, <code@tyhicks.com>,
	<linkinjeon@kernel.org>, <sj1557.seo@samsung.com>, <yuezhang.mo@sony.com>,
	<hirofumi@mail.parknet.co.jp>, <cel@kernel.org>, <jlayton@kernel.org>,
	<neil@brown.name>, <okorniev@redhat.com>, <Dai.Ngo@oracle.com>,
	<tom@talpey.com>, <hyc.lee@gmail.com>, <miklos@szeredi.hu>,
	<amir73il@gmail.com>, <senozhatsky@chromium.org>,
	<chenxiaosong@chenxiaosong.com>, <kpsingh@kernel.org>, <matt@bobrowski.net>,
	<rostedt@goodmis.org>, <mhiramat@kernel.org>,
	<mathieu.desnoyers@efficios.com>, <john.johansen@canonical.com>,
	<georgia.garcia@canonical.com>, <zohar@linux.ibm.com>,
	<roberto.sassu@huawei.com>, <dmitry.kasatkin@gmail.com>,
	<eric.snowberg@oracle.com>, <stephen.smalley.work@gmail.com>,
	<omosnacek@gmail.com>, <casey@schaufler-ca.com>, <takedakn@nttdata.co.jp>,
	<penguin-kernel@i-love.sakura.ne.jp>, <xiujianfeng@huawei.com>,
	<nanx95726@gmail.com>, <djwong@kernel.org>, <lujialin4@huawei.com>,
	<bpf@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <netfs@lists.linux.dev>,
	<ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <ntfs@lists.linux.dev>,
	<linux-unionfs@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
	<linux-trace-kernel@vger.kernel.org>, <apparmor@lists.ubuntu.com>,
	<linux-integrity@vger.kernel.org>, <selinux@vger.kernel.org>,
	<linux-kselftest@vger.kernel.org>
References: <20261015125425.3246251-1-caixinchen1@huawei.com>
 <20261015125425.3246251-10-caixinchen1@huawei.com> <atI20Vs7Du9-g1Hz@zenbox>
Content-Language: en-US
From: Cai Xinchen <caixinchen1@huawei.com>
In-Reply-To: <atI20Vs7Du9-g1Hz@zenbox>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
X-ClientProxiedBy: kwepems500002.china.huawei.com (7.221.188.17) To
 whupemk100010.china.huawei.com (7.152.184.41)

Hello Justin,

Thank you for the review, and for thinking the implications through so
carefully -- the concrete scenarios you describe were very helpful to
settle the design.

I agree it should be a conscious
decision: the next revision will make the *_METADATA checked at open time

and follow the mechanic for the truncate right

On 10/16/2026 10:44 PM, Justin Suess wrote:
> LANDLOCK_ACCESS_FS_*_METADATA should be checked at open time and follow
> the mechanic for the truncate right. Otherwise the access for already
> opened file descriptors would be changed. See hook_file_open in
> security/landlock/fs.c and this discussion here [1]
>
> It should have clear documentation for this as well.
