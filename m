Received: from canpmsgout02.his.huawei.com (canpmsgout02.his.huawei.com [113.46.200.217])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B5B553FC5AE;
	Mon, 28 Sep 2026 08:44:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.217
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790585096; cv=none; b=cNA6/xLPW9ioG5KbsFcNMOkFKQxD/6BIb1iJzKOX8GU0ztWKA9r1V8M9Foc1+bA80Tmi/0JNx7BGa7Cs9GzPgPzn7cpJJpezGF4h17Yhwu4wJt6S4iuz5f6XWlx0KTYsvp952DtNe/MoWA6bvr1ccIdYfjiMbKn+gN24XHPvSnU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790585096; c=relaxed/simple;
	bh=iDGp7P3BEvSWs1L7iNJIWjF45NYDB+xMs1LHa1Er8uQ=;
	h=Message-ID:Date:MIME-Version:Subject:To:CC:References:From:
	 In-Reply-To:Content-Type; b=pfVyHmoq/Q2gQ9ebu3eQEWsXTWUPT4NHNHmPcFjQ+8UGE6UQNtsJfEr6vEGPjXVoCQA9YwGRQqHNObSz9szPhIhfNHxaXKrgFh8SO7NBcG+M39TySQxTEXDQ2VVV5Ep8S+kp14dgFxn4MLU5vPNGlv4KjAcCQ6+WDhfWt0ZEqHY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=Il61np93; arc=none smtp.client-ip=113.46.200.217
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="Il61np93"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=iDGp7P3BEvSWs1L7iNJIWjF45NYDB+xMs1LHa1Er8uQ=;
	b=Il61np93Mzpfh1Yw6ZTaudK8+nCQ4+DjNBs7VntEmE0tZXcn7sPEF3AumdIjHPSk2gTjz273a
	wBOH1W7k/4xR4wPV7l62M9UPquFd63zSevJQns1zbf6BGnLBtZpCHWpqVhapwho/G5mndn+Ez1O
	jCI6EYJd4AynyN7whX7Q3xA=
Received: from mail.maildlp.com (unknown [172.19.162.197])
	by canpmsgout02.his.huawei.com (SkyGuard) with ESMTPS id 4htZM82gK2zcb3G;
	Mon, 28 Sep 2026 16:33:08 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id A9A0740579;
	Mon, 28 Sep 2026 16:44:41 +0800 (CST)
Received: from [10.67.109.91] (10.67.109.91) by whupemk100010.china.huawei.com
 (7.152.184.41) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Mon, 28 Sep
 2026 16:44:37 +0800
Message-ID: <f697efa0-81c9-4ace-b9cc-d672b98dfc9d@huawei.com>
Date: Mon, 28 Sep 2026 16:44:35 +0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC -next 03/12] fs: pass struct path to xattr helpers
To: Amir Goldstein <amir73il@gmail.com>
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
	<tom@talpey.com>, <miklos@szeredi.hu>, <senozhatsky@chromium.org>,
	<chenxiaosong@chenxiaosong.com>, <zohar@linux.ibm.com>,
	<roberto.sassu@huawei.com>, <dmitry.kasatkin@gmail.com>,
	<eric.snowberg@oracle.com>, <stephen.smalley.work@gmail.com>,
	<omosnacek@gmail.com>, <casey@schaufler-ca.com>, <nanx95726@gmail.com>,
	<djwong@kernel.org>, <daniel@iogearbox.net>,
	<linux-security-module@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <driver-core@lists.linux.dev>,
	<linux-block@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<netfs@lists.linux.dev>, <ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <linux-unionfs@vger.kernel.org>,
	<linux-cifs@vger.kernel.org>, <linux-integrity@vger.kernel.org>,
	<selinux@vger.kernel.org>, <linux-kselftest@vger.kernel.org>,
	<xiujianfeng@huawei.com>, <lujialin4@huawei.com>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
 <20260924104831.1081137-4-caixinchen1@huawei.com>
 <CAOQ4uxhMhcxq5+crz84f8xj+Wi1bHhNqa_TecP-RvipheBR+ug@mail.gmail.com>
Content-Language: en-US
From: Cai Xinchen <caixinchen1@huawei.com>
In-Reply-To: <CAOQ4uxhMhcxq5+crz84f8xj+Wi1bHhNqa_TecP-RvipheBR+ug@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: kwepems500002.china.huawei.com (7.221.188.17) To
 whupemk100010.china.huawei.com (7.152.184.41)

Thank you for review

I will switched to ovl_path_real in the next version.

ovl_creds is a prepare_creds() clone of the mounter, so unless
the mounter itself was sandboxed, the clone carries no Landlock
domain and every check short-circuits. The new rights are also
enforced at the security_inode_*xattr() call sites in fs/xattr.c,
which run with the user-visible overlay path.

The exception is an unprivileged overlay mount by an already
sandboxed mounter: the domain is inherited into
creator_cred through the cred_prepare hook, so the internal
real-path calls *do* get checked there.  For this series that
means:

- ovl_xattr_get/set/ovl_listxattr() forwarding and the
   ovl_setattr() -> ovl_do_notify_change() forwarding would be
   checked against the upper/lower paths;
- copy-up would newly require the metadata rights on the backing
   directories too (ovl_copy_xattr() calls the security-checking
   vfs_listxattr()/vfs_setxattr());
- stat() is unaffected: ovl_getattr() goes through the _nosec
   variant.

This is not Landlock-specific: every LSM
that keeps its state in the cred blob inherits the mounter's
context into creator_cred through cred_prepare.

On 9/24/2026 7:12 PM, Amir Goldstein wrote:
> that's ovl_path_real()
>
> I have no technical issue with the ovl patch bits in this series.
> Anyway, I guess landlock is not going to enforce anything on the
> private mnt with ovl_creds anyway?
