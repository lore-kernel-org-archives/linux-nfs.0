Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=113.46.200.222
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792737102;
	b=TS5548k+iAHufYgIiUYXNqKtGMyUZMoZTRO1guZIi/hgpZjcOx86YjNPP5dv6SQZ+GaH
	 Gsy0D+V7+SJ2kyDKSpTg8/cAYO6TK5/dQuBPBxEPW2tAeZ5Hsn6PzazkKmjWI7kFDM0XO
	 NV7kRDn0183vM6V+VgIdSmA0XHDyb/8VGRm3vc/LKshW0fJ8fpUsshTjIYmNiIB0nBy9+
	 ntmL9VJs9sNtB67REuvR7XL7piv1S+1iUDKDs6oOqTvZuuUhVmDJWqn1SZ7gkceeh2ssU
	 Gtx9WGMPWbQyf/UpgSP4YVsWgInhp7NI4GgX7MOrRwX1bnuDSjvOTKfTDGTL6jw/jzw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792737102;
	h=DMARC-Filter:dkim-signature:Received:Received:Received:Message-ID:
	 Date:MIME-Version:User-Agent:Subject:To:CC:References:
	 Content-Language:From:In-Reply-To:Content-Type:
	 Content-Transfer-Encoding:X-Originating-IP:X-ClientProxiedBy;
	bh=33tGxL4pQ37PAm6R2PA7y86/iQoPs+fP5QCASbIaiW4=;
	b=xn1+RmYFdw7qrRYR9dl4JePRPxfSHmmoUuaMKbgZZPOQAU8LUTVS6MbyGc47mZGqmVMA
	 9hTK5GHmkortqh/zmUl090slU7WW19KEOc/khfyQt8XE7JZiE8qgBaiDJ/eO1Kti9f0PI
	 qzcEO95xoZzoJor2hANil8Yo/0sqFeiN0KWxzcn3SFcHtjmeHStqPTepLi10yjPOZ3IWO
	 evsgaKf9GmrBjAUeMMfcNX8c+IgzgehralFgEcmf/hjRqa7AKO7RQhQKOBzZPP8OdZdl2
	 ei84XwgD2c79KBKlc4HQnYg9BlEbzOf+pFLcu4BNZQKHr6kX0qNZr0u6HsvLcXsVqiQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=huawei.com;
	spf=pass smtp.mailfrom=huawei.com;
	dkim=pass header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=fjsQ8MHy;
	arc=none smtp.remote-ip=113.46.200.222
Received: from canpmsgout07.his.huawei.com (canpmsgout07.his.huawei.com [113.46.200.222])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C2176606A31B;
	Fri, 23 Oct 2026 06:31:39 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org C2176606A31B
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key, unprotected) header.d=huawei.com header.i=@huawei.com header.a=rsa-sha256 header.s=dkim header.b=fjsQ8MHy
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=33tGxL4pQ37PAm6R2PA7y86/iQoPs+fP5QCASbIaiW4=;
	b=fjsQ8MHyFLg2DKpb+rChWOhrQ6Agx+aJ4B3WloBfzhk5I42lfFR8N28XAuSRbTqFZgHgChm3O
	4OwNSVOJK87cDrNiMupTVhF9pAM7IdBGhA0OswOr1fHmf/8LmJiA8sNJ5JxoASQ+9LC7G7GDo6P
	DlcW4ZEJB+N+XLWejTOA2kU=
Received: from mail.maildlp.com (unknown [172.19.163.163])
	by canpmsgout07.his.huawei.com (SkyGuard) with ESMTPS id 4j9tTJ5rsczLlWr;
	Fri, 23 Oct 2026 14:31:32 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 10C6B40594;
	Fri, 23 Oct 2026 14:31:36 +0800 (CST)
Received: from [10.67.110.140] (10.67.110.140) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Fri, 23 Oct 2026 14:31:29 +0800
Message-ID: <a2832263-3e3b-4d05-98bd-dc006d5be689@huawei.com>
Date: Fri, 23 Oct 2026 14:31:28 +0800
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
Subject: Re: [PATCH v2 -next 01/18] fs: pass struct path to notify_change()
To: Christian Brauner <brauner@kernel.org>
CC: <mic@digikod.net>, <gnoack@google.com>, <paul@paul-moore.com>,
	<jmorris@namei.org>, <serge@hallyn.com>, <corbet@lwn.net>,
	<skhan@linuxfoundation.org>, <ast@kernel.org>, <daniel@iogearbox.net>,
	<andrii@kernel.org>, <eddyz87@gmail.com>, <memxor@gmail.com>,
	<martin.lau@linux.dev>, <song@kernel.org>, <yonghong.song@linux.dev>,
	<jolsa@kernel.org>, <emil@etsalapatis.com>, <ihor.solodrai@linux.dev>,
	<rdunlap@infradead.org>, <gregkh@linuxfoundation.org>, <rafael@kernel.org>,
	<dakr@kernel.org>, <johan@kernel.org>, <dlemoal@kernel.org>, <hch@lst.de>,
	<axboe@kernel.dk>, <viro@zeniv.linux.org.uk>, <jack@suse.cz>,
	<dhowells@redhat.com>, <code@tyhicks.com>, <linkinjeon@kernel.org>,
	<sj1557.seo@samsung.com>, <yuezhang.mo@sony.com>,
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
 <20261015125425.3246251-2-caixinchen1@huawei.com>
 <20261021-nanotechnologie-gebadet-gepaukt-52a950759f0a@brauner>
Content-Language: en-US
From: Cai Xinchen <caixinchen1@huawei.com>
In-Reply-To: <20261021-nanotechnologie-gebadet-gepaukt-52a950759f0a@brauner>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: kwepems100002.china.huawei.com (7.221.188.206) To
 whupemk100010.china.huawei.com (7.152.184.41)

Thanks for the explanation, you are right.  I will restore the idmap as 
a separate argument

On 10/21/2026 6:21 PM, Christian Brauner wrote:
> On Thu, Oct 15, 2026 at 08:54:07PM +0800, Cai Xinchen wrote:
>> notify_change() takes a struct mnt_idmap and a struct dentry even
>> though all of its callers either already hold a struct path (or a
>> struct file) or have to pass &nop_mnt_idmap because no idmapped
>> mount is involved.  Switch the helper and its declaration to take a
>> struct path instead and derive the idmap and dentry from it.
> No, the idmap needs to be passed separately. The whole point is that
> during path lookup mnt->mnt_idmap can change. So mnt->mnt_idmap is taken
> of the mount at the time it was checked and passed down to the
> filesystem so that the VFS and the filesystem are guaranteed to see the
> same idmap.
