Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794329543;
	b=MqUrDRKNkm5LTuWw/p72EmWMN8y5gRS7IKO9coqAv0GrbEWIJsBAT987R4Icfg+VWKI2
	 uo4ni/3H9tbkzcfyK89ILbPx2po3H4aJt8bADreecaLh6FLcAahbfvoewTUJCStR54Bk0
	 JkbQES+PqiCgbMDyF1EAIJilLbna8+LZHRvL2MPVmcTpyKzzbXa2rQF+IWXQEj0blP8ym
	 WgivW55NuDvwXCrregevCDHueABXJ1HvJA+1Z++6bstcMbA/95HTL3+D31s3o6SMuwFgR
	 VlIH7aw/1GBxOdCm8o9fF+QmMVKT9YNCFkJQeswK5esi27KX1ayMXXTXdDTj4VVAQYA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794329543;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=KyDcpTwF2G84cUTe+PVKDz9G3rULU78GRC2w0kOsrLc=;
	b=l4aw2tre8GbBz5g9LuX5bM4yQTz96CFbLG8LsM7VKIXayuVmXV30ZQ32DPTyLKLklvnF
	 fYFQ3zY+xdGIl+RC9ylnA/C7J49VUkApYGigBDyRkZo5czIM8Cqw8hUKbFZyn1/IgtQ3m
	 Z/RGVRymJUJsoZqE4xFLoNPCFQbl09Pa3uiRQy/26ID/0+MFb3/zKlbTzp+JvVrStnzwK
	 eWITQsh2iQT/0NCBfg5oKIZVh3Q6CWsgmG0dT0HwHYfcy3NvJnhpa5fox9BM20Ijf/wdi
	 YYcsCHji+6Oik6v5hEeEl7hh1kCC4piXf0Q3DTWANagDf07zGSFRMlxB9cJ+9m6KinQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="WSR4/meg";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 57DB6606A330;
	Tue, 10 Nov 2026 16:52:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WSR4/meg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0C6B21F0089F;
	Tue, 10 Nov 2026 16:52:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794329543;
	bh=KyDcpTwF2G84cUTe+PVKDz9G3rULU78GRC2w0kOsrLc=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=WSR4/megdggMO9wsDWOY+uoQSmNtO3j2yfbZkG8wNi5rB7hE651wqOzDxlgDXK7Ew
	 RmAWiz2VBpllg4ynVFTcPIjgzyk7nAxhySjvb+byysmSgsCnpkfEzxkJqRWKHq9/mc
	 YNAQhE0ikpxZ0sqlywqGqK0vnkiWmSjRjigl1fL7x76Q0lUOnOc+fEhl7WUDNrnt2X
	 Hda+VOxkwzLr8arHFGMZFn9v/vCdMOGy5b+eY24hGBQ3e42uhb8xHhCF/aPlSMJPft
	 3tCywwxXOQqTXxdhv8EqxUpg5QCSLRW2i8oyD+4B0ftty6ddfdgKmdarmtnmAcuyq1
	 heVa4ehNncfYw==
Date: Tue, 10 Nov 2026 17:52:03 +0100
From: Christian Brauner <brauner@kernel.org>
To: Cai Xinchen <caixinchen1@huawei.com>
Cc: mic@digikod.net, gnoack@google.com, paul@paul-moore.com, 
	jmorris@namei.org, serge@hallyn.com, corbet@lwn.net, skhan@linuxfoundation.org, 
	utilityemal77@gmail.com, ast@kernel.org, daniel@iogearbox.net, andrii@kernel.org, 
	eddyz87@gmail.com, memxor@gmail.com, martin.lau@linux.dev, song@kernel.org, 
	yonghong.song@linux.dev, jolsa@kernel.org, emil@etsalapatis.com, ihor.solodrai@linux.dev, 
	rdunlap@infradead.org, gregkh@linuxfoundation.org, rafael@kernel.org, dakr@kernel.org, 
	johan@kernel.org, dlemoal@kernel.org, hch@lst.de, axboe@kernel.dk, 
	viro@zeniv.linux.org.uk, jack@suse.cz, dhowells@redhat.com, code@tyhicks.com, 
	linkinjeon@kernel.org, sj1557.seo@samsung.com, yuezhang.mo@sony.com, 
	hirofumi@mail.parknet.co.jp, cel@kernel.org, jlayton@kernel.org, neil@brown.name, 
	okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com, hyc.lee@gmail.com, 
	miklos@szeredi.hu, amir73il@gmail.com, senozhatsky@chromium.org, 
	chenxiaosong@chenxiaosong.com, dsterba@suse.com, mason@kernel.org, kpsingh@kernel.org, 
	matt@bobrowski.net, rostedt@goodmis.org, mhiramat@kernel.org, 
	mathieu.desnoyers@efficios.com, john.johansen@canonical.com, georgia.garcia@canonical.com, 
	zohar@linux.ibm.com, roberto.sassu@huawei.com, dmitry.kasatkin@gmail.com, 
	eric.snowberg@oracle.com, stephen.smalley.work@gmail.com, omosnacek@gmail.com, 
	casey@schaufler-ca.com, takedakn@nttdata.co.jp, penguin-kernel@i-love.sakura.ne.jp, 
	xiujianfeng@huawei.com, nanx95726@gmail.com, djwong@kernel.org, lujialin4@huawei.com, 
	bpf@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, 
	linux-security-module@vger.kernel.org, driver-core@lists.linux.dev, linux-block@vger.kernel.org, 
	linux-btrfs@vger.kernel.org, linux-fsdevel@vger.kernel.org, netfs@lists.linux.dev, 
	ecryptfs@vger.kernel.org, exfat@lists.linux.dev, linux-nfs@vger.kernel.org, 
	ntfs@lists.linux.dev, linux-unionfs@vger.kernel.org, linux-cifs@vger.kernel.org, 
	linux-trace-kernel@vger.kernel.org, apparmor@lists.ubuntu.com, linux-integrity@vger.kernel.org, 
	selinux@vger.kernel.org, linux-kselftest@vger.kernel.org
Subject: Re: [PATCH v3 -next 00/18] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
Message-ID: <20261110-rekonstruieren-erbfolge-vollversammlung-26be74966211@brauner>
References: <20261027121151.1887650-1-caixinchen1@huawei.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20261027121151.1887650-1-caixinchen1@huawei.com>

On Tue, Oct 27, 2026 at 08:11:33PM +0800, Cai Xinchen wrote:
> - The idmap is passed separately from the struct path again, instead
>   of being derived from path->mnt inside the helpers and the hooks.
>   As Christian explains in his review of patch 1, the idmap must be
>   taken of the mount at the time it was checked and passed down to
>   the filesystem so that the VFS and the filesystem are guaranteed
>   to see the same idmap.

This regresses AT_EMPTY_PATH. fchmodat2(), fchownat() and utimensat()
with an empty path now go through CLASS(fd) which is fdget() and that 
refuses O_PATH file descriptors. IOW, this is very very broken.

Please also go through Sashiko's review of v3 (cf. [1]). The new struct
file arguments need __nullable or bpf programs can dereference NULL,
and the ntfs3 stream setattr and overlayfs fileattr paths that bypass
the hooks need treatment.

[1]: https://sashiko.dev/#/patchset/20261027121151.1887650-1-caixinchen1%40huawei.com

-- 
