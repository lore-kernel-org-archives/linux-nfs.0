Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792578116;
	b=NL8ZpqZCWWwYYFAZoHYONQvHTrjJ09JyOIcJWYDNMqW4NcqVVRHJtR6mshvcfn6xXTW/
	 5K7ttWzjWPAbK+2ufHIYXrJjzhaQpeU2tPcQGUjCNfbrwnUjwLO5X861cWLUvJm2f1Ie6
	 cd0x7u0edN2SpdLWWefE0Mq6hC8uXaHNhpVd3nXSJg1+Xg8eTG0AEnwZBJGS2WDbqS5Qt
	 KS45fbYnkOkbV5cfHNVjQm/lcg9BBpqSGyfcZUQtrBWqD/bvDpTil5Bhd17yFid/q5Nfl
	 +fIK2p7KqPRYuNXwDPXKGxoYStzV4f5NAwcF8+e7oUjKE53YXyHuMxluFKkdx4qPODQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792578116;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=IzO1E6ikKD8tl2Wsl1moqCKEq1l/nX4FZiTYItV58uI=;
	b=Na30fbzbmF9ffbf88MZXidvz/GwP0bvyyaD5DJk/Q175LC/IAkZyAsAw9tbrBeHJXGew
	 Yj9KBnaxHHKLm4e+o3xU3WHlgccBbjGC/vR5XkxsaDOEw/KiR2OV8Rer6hQiN0T36I6VV
	 b7GZ1oBOsEmadAlzHtTKZxFP071Vtj1g3VMS/Ez+QR3ez3BVmy4lcQ3G26HCEXxiB+hsw
	 oQbDef1Xa03LNaoDIQdKyN64ZILCgsOYNCVtf99Zq+QowwesxjDx8vdwrSrSVUaOwlZGz
	 nsFCXFOEpna5ytlOKlJOg89WjYA1ebqNAN1bCyNDjeyclaf8lFc8+D1q7N2uPX8DcOA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mxIJkEAE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 812FE606A31A;
	Wed, 21 Oct 2026 10:21:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mxIJkEAE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1A92D1F000C9;
	Wed, 21 Oct 2026 10:21:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792578116;
	bh=IzO1E6ikKD8tl2Wsl1moqCKEq1l/nX4FZiTYItV58uI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=mxIJkEAEUemoHzqFpjGOGsISTWbamBRSUja5/+PShimgeDu5pEKvopKkpU417cjQS
	 LUqwYcw1SBOPpayMExd/35Gnzu6vWNYtpIRwMBn1YzbAVoItArpZDVk3V/2yxpBUSt
	 9fzVhM7CM1JzxX/30rMD4LM/SMeQgvPK71uLA9cJ6KKuCcL9byzvEuq3NKJpBNSfkI
	 hOZZhVe1KN8bfJmLl2/aV98mPzJLBOsp6PiULbCuee+h9exCxuOQwZCmfAA20lj/Y5
	 rZglUOVWEtzU9bw0QJBCz7xQiasZhWom0scGxlDmBqafUSH/ovyAfRSFdg3IQhiHli
	 c6Wa6I1EvnH2g==
Date: Wed, 21 Oct 2026 12:21:35 +0200
From: Christian Brauner <brauner@kernel.org>
To: Cai Xinchen <caixinchen1@huawei.com>
Cc: mic@digikod.net, gnoack@google.com, paul@paul-moore.com, 
	jmorris@namei.org, serge@hallyn.com, corbet@lwn.net, skhan@linuxfoundation.org, 
	ast@kernel.org, daniel@iogearbox.net, andrii@kernel.org, eddyz87@gmail.com, 
	memxor@gmail.com, martin.lau@linux.dev, song@kernel.org, yonghong.song@linux.dev, 
	jolsa@kernel.org, emil@etsalapatis.com, ihor.solodrai@linux.dev, 
	rdunlap@infradead.org, gregkh@linuxfoundation.org, rafael@kernel.org, dakr@kernel.org, 
	johan@kernel.org, dlemoal@kernel.org, hch@lst.de, axboe@kernel.dk, 
	viro@zeniv.linux.org.uk, jack@suse.cz, dhowells@redhat.com, code@tyhicks.com, 
	linkinjeon@kernel.org, sj1557.seo@samsung.com, yuezhang.mo@sony.com, 
	hirofumi@mail.parknet.co.jp, cel@kernel.org, jlayton@kernel.org, neil@brown.name, 
	okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com, hyc.lee@gmail.com, 
	miklos@szeredi.hu, amir73il@gmail.com, senozhatsky@chromium.org, 
	chenxiaosong@chenxiaosong.com, kpsingh@kernel.org, matt@bobrowski.net, rostedt@goodmis.org, 
	mhiramat@kernel.org, mathieu.desnoyers@efficios.com, john.johansen@canonical.com, 
	georgia.garcia@canonical.com, zohar@linux.ibm.com, roberto.sassu@huawei.com, 
	dmitry.kasatkin@gmail.com, eric.snowberg@oracle.com, stephen.smalley.work@gmail.com, 
	omosnacek@gmail.com, casey@schaufler-ca.com, takedakn@nttdata.co.jp, 
	penguin-kernel@i-love.sakura.ne.jp, xiujianfeng@huawei.com, nanx95726@gmail.com, djwong@kernel.org, 
	lujialin4@huawei.com, bpf@vger.kernel.org, linux-doc@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-security-module@vger.kernel.org, 
	driver-core@lists.linux.dev, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	netfs@lists.linux.dev, ecryptfs@vger.kernel.org, exfat@lists.linux.dev, 
	linux-nfs@vger.kernel.org, ntfs@lists.linux.dev, linux-unionfs@vger.kernel.org, 
	linux-cifs@vger.kernel.org, linux-trace-kernel@vger.kernel.org, apparmor@lists.ubuntu.com, 
	linux-integrity@vger.kernel.org, selinux@vger.kernel.org, linux-kselftest@vger.kernel.org
Subject: Re: [PATCH v2 -next 01/18] fs: pass struct path to notify_change()
Message-ID: <20261021-nanotechnologie-gebadet-gepaukt-52a950759f0a@brauner>
References: <20261015125425.3246251-1-caixinchen1@huawei.com>
 <20261015125425.3246251-2-caixinchen1@huawei.com>
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
In-Reply-To: <20261015125425.3246251-2-caixinchen1@huawei.com>

On Thu, Oct 15, 2026 at 08:54:07PM +0800, Cai Xinchen wrote:
> notify_change() takes a struct mnt_idmap and a struct dentry even
> though all of its callers either already hold a struct path (or a
> struct file) or have to pass &nop_mnt_idmap because no idmapped
> mount is involved.  Switch the helper and its declaration to take a
> struct path instead and derive the idmap and dentry from it.

No, the idmap needs to be passed separately. The whole point is that
during path lookup mnt->mnt_idmap can change. So mnt->mnt_idmap is taken
of the mount at the time it was checked and passed down to the
filesystem so that the VFS and the filesystem are guaranteed to see the
same idmap.
