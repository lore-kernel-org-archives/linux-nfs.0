Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.224
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794535692;
	b=p+OCAdGyQTluAMXM2IMjhPqoDssF3k0v9cXs1PByJ8sQNTntlLl32u9gYFwRGQxoMsuF
	 FpPG/uNtz8O8rMCukKoRuiXR90YdYwVEEHfhh616wlsW0OR8aRmepRvL3T0vJ7Oe+/PoU
	 4h70MG50RqjBv4F69D6wB4lIn6PTxbuH6sLiTBTRz4YpwRIpEBaGqe7Y3kjI0ldcuXT2y
	 RE7GRQphiYobnV4CB8aXdO9qtkyzxFSD4zKhKBTSTYrGSWn8nrhPQ784N5tWBWXnkSx6L
	 cm/ce2LhWJlRj8jWTXMnlBy6cZxSt34FRzAUDB4jMReP09fSxH6cKHxxTMlSsaXEyKQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794535692;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:CC:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding:X-Originating-IP:X-ClientProxiedBy;
	bh=fRlFnEwOyhCsf6bntFNWmv0q3cjwumqt5gvXEY0j99s=;
	b=h/zV89+qLgaCReHEGqt6Yz7QuMFLau76PrUC64xyupskVtNCPQ+nmxOMNmYpHzOqslFo
	 kgKw5ZY2wbzhJd0lF+zjKrlPUCmjb5IgsUFtoQqhIVm9cnGfBBQV27Zmw0SOuawfTJrqj
	 COUDeteeu91XQma3e/4ndW4VEdrl3CeyYA6qLcmmNoBHr88AeGjUDrznix08ey7CkL7dN
	 ATYbiJ85jaQA4TqrEF0OxrluHBWYxqRn9fPvtPMnNG9q6tAJkXdtwGsMyPUdrjdmiatZM
	 Nm2oKKg5nghW9PZOToKPGBNxCtDI6DTaPEoBLZidyMqSogmB9o3taotFsdyv1n5vU6w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=tgB76D+u;
	arc=none smtp.remote-ip=113.46.200.224
Received: from canpmsgout09.his.huawei.com (canpmsgout09.his.huawei.com [113.46.200.224])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 81167606A31C;
	Fri, 13 Nov 2026 02:08:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 81167606A31C
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=tgB76D+u
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=fRlFnEwOyhCsf6bntFNWmv0q3cjwumqt5gvXEY0j99s=;
	b=tgB76D+uPHT+xoP/MsIq5QT99tPRFyjCjYAa5bPvS0n/BLMW7GmhAJphWd0AaFaCXwNcxc4Ka
	dPjWkV3Gm+TFWMTFawukI93MmREL5xwGs2ILp3CVZdJ2RNXEKTgDHIK4mZDlwgvononmGVpnLul
	eI6cXevbd8zNABceS1BMSf4=
Received: from mail.maildlp.com (unknown [172.19.163.127])
	by canpmsgout09.his.huawei.com (SkyGuard) with ESMTPS id 4jQgdL6LlBz1cyTG;
	Fri, 13 Nov 2026 10:07:50 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 63B8C40572;
	Fri, 13 Nov 2026 10:08:07 +0800 (CST)
Received: from [10.67.110.140] (10.67.110.140) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Fri, 13 Nov 2026 10:08:00 +0800
Message-ID: <2dbd365b-eac5-448b-b6c2-4ed8754551a7@huawei.com>
Date: Fri, 13 Nov 2026 10:07:59 +0800
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
Subject: Re: [PATCH v3 -next 00/18] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
To: Christian Brauner <brauner@kernel.org>
CC: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>, <utilityemal77@gmail.com>, <ast@kernel.org>,
	<daniel@iogearbox.net>, <andrii@kernel.org>, <eddyz87@gmail.com>,
	<memxor@gmail.com>, <martin.lau@linux.dev>, <song@kernel.org>,
	<yonghong.song@linux.dev>, <jolsa@kernel.org>, <emil@etsalapatis.com>,
	<ihor.solodrai@linux.dev>, <rdunlap@infradead.org>,
	<gregkh@linuxfoundation.org>, <rafael@kernel.org>, <dakr@kernel.org>,
	<johan@kernel.org>, <dlemoal@kernel.org>, <hch@lst.de>, <axboe@kernel.dk>,
	<viro@zeniv.linux.org.uk>, <jack@suse.cz>, <dhowells@redhat.com>,
	<code@tyhicks.com>, <linkinjeon@kernel.org>, <sj1557.seo@samsung.com>,
	<yuezhang.mo@sony.com>, <hirofumi@mail.parknet.co.jp>, <cel@kernel.org>,
	<jlayton@kernel.org>, <neil@brown.name>, <okorniev@redhat.com>,
	<Dai.Ngo@oracle.com>, <tom@talpey.com>, <hyc.lee@gmail.com>,
	<miklos@szeredi.hu>, <amir73il@gmail.com>, <senozhatsky@chromium.org>,
	<chenxiaosong@chenxiaosong.com>, <dsterba@suse.com>, <mason@kernel.org>,
	<kpsingh@kernel.org>, <matt@bobrowski.net>, <rostedt@goodmis.org>,
	<mhiramat@kernel.org>, <mathieu.desnoyers@efficios.com>,
	<john.johansen@canonical.com>, <georgia.garcia@canonical.com>,
	<zohar@linux.ibm.com>, <roberto.sassu@huawei.com>,
	<dmitry.kasatkin@gmail.com>, <eric.snowberg@oracle.com>,
	<stephen.smalley.work@gmail.com>, <omosnacek@gmail.com>,
	<casey@schaufler-ca.com>, <takedakn@nttdata.co.jp>,
	<penguin-kernel@i-love.sakura.ne.jp>, <xiujianfeng@huawei.com>,
	<nanx95726@gmail.com>, <djwong@kernel.org>, <lujialin4@huawei.com>,
	<bpf@vger.kernel.org>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <linux-security-module@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-btrfs@vger.kernel.org>, <linux-fsdevel@vger.kernel.org>,
	<netfs@lists.linux.dev>, <ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <ntfs@lists.linux.dev>,
	<linux-unionfs@vger.kernel.org>, <linux-cifs@vger.kernel.org>,
	<linux-trace-kernel@vger.kernel.org>, <apparmor@lists.ubuntu.com>,
	<linux-integrity@vger.kernel.org>, <selinux@vger.kernel.org>,
	<linux-kselftest@vger.kernel.org>
References: <20261027121151.1887650-1-caixinchen1@huawei.com>
 <20261110-rekonstruieren-erbfolge-vollversammlung-26be74966211@brauner>
Content-Language: en-US
From: Cai Xinchen <caixinchen1@huawei.com>
In-Reply-To: <20261110-rekonstruieren-erbfolge-vollversammlung-26be74966211@brauner>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: kwepems500002.china.huawei.com (7.221.188.17) To
 whupemk100010.china.huawei.com (7.152.184.41)

You are right, and thanks for catching it.

I have been working on these modifications over the past two weeks and 
have deployed sashiko locally. However, my current changes are still 
being flagged for some bugs by my local sashiko, and I am still in the 
process of fixing them. I expect to release v4 in a few days. Regarding 
these issues, my current fixes are as follows: - AT_EMPTY_PATH: v4 will 
use CLASS(fd_raw, f)(dfd), the   same lookup path_init() does for an 
empty path, so O_PATH descriptors   work again.  do_utimes_fd() 
(futimens(2)) intentionally keeps   CLASS(fd, f), matching 
fchmod(2)/fchown(2); AT_EMPTY_PATH returns   -EINVAL there anyway.  The 
same patch rejects a NULL pathname with   -EFAULT before 
CLASS(filename_maybe_null) can turn it into an empty   path relative to 
AT_FDCWD, and adds the missing audit_file() on the   do_utimes_path() fd 
branch. - __nullable (patches 5-9, 11-13): v4 will extend 
kernel/bpf/bpf_lsm_proto.c (the existing   strong-override file used for 
mmap_file) with strong definitions for   all 11 hooks that gained a file 
argument, each declared   file__nullable, so the verifier sees 
PTR_MAYBE_NULL and a program must   check before dereferencing. - ntfs 
named stream setattr (patch 1): v3 forwarded with   
__notify_change(idmap, base_dentry, ...).  v4 will use   
notify_change_target(idmap, attr->ia_path, base_dentry, ...), so the   
hook is checked against the path the syscall used while the attributes   
still land on the base inode. - overlayfs fileattr (patch 8): v3 removed 
the ovl_security_fileattr()   workaround but then called the unchecked 
__vfs_fileattr_get()/_set()   on the real dentry, which bypasses the 
hooks.  v4 will call the checked   vfs_fileattr_get()/_set() with the 
real upper/lower path, so the hooks   also run for the underlying layer; 
ecryptfs is switched the same way.

Best regards.

Cai

On 11/11/2026 12:52 AM, Christian Brauner wrote:
> This regresses AT_EMPTY_PATH. fchmodat2(), fchownat() and utimensat()
> with an empty path now go through CLASS(fd) which is fdget() and that
> refuses O_PATH file descriptors. IOW, this is very very broken.
>
> Please also go through Sashiko's review of v3 (cf. [1]). The new struct
> file arguments need __nullable or bpf programs can dereference NULL,
> and the ntfs3 stream setattr and overlayfs fileattr paths that bypass
> the hooks need treatment.
