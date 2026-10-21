Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792578331;
	b=EjVzvbXI2YAzzrCLsIYrfiWEnd927BfHxKr3trAVqtA0xeUH1X+eY+ZQ1tNmQ3/oZkd/
	 AG6Rvngehp2HdbB6EBonC6VPmHMZzSOXETGaIjq26xWm/q0yBcFeF1qHDxx1/UIZ3I3D+
	 c+KoYKbiTwjqnvGMdwegLkRdjWMC2j4bqjZyAv3Y9g6ZxOGMRhl9FtHHvRJ4FXwAleb2E
	 f/8UKmzHMwmX/BmfSz1Bp2elPrNlryd3/Umz/s+7XVGaUWow0rdSCbYxixeJ5koIbMd5S
	 1WsRw1qGpd9BSWZ6OJEuUmouul55SxUcpEuCK95De5AM/rqx85QPKe0sLZYtVOdFxVw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792578331;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:In-Reply-To;
	bh=fyUFCbuePzC+XG2QW79bsjnDsYBX6lH465Zgu9TmAmA=;
	b=T2aptLONDZ2m5Bod8KFCpux1s6M9OaOa1yPs22mnoS5ue0+JTk1mN0AnlVruz1JdNdjn
	 KD9IO4KYJJyJAXQHgBhVaRFTDfaSCx9MGomCYtaD9fze25gP5h4wPjoICXDw5B0FkjLnG
	 Vxl+ptGIJe3wpnkY7i6mKdzZcSE8WozuQaWKTGgAiD3ImJYPHrHD35yWs6/Pkr8oC9IlF
	 rLpYm4t4wUI5AVjaAWUHwbM2zDC5cvQaX3bk6tUsIYdjUobyk7L1UBUXbhA/B5/xwqQsn
	 rBg3fzJU42xxXsK970nb2+gAtg4Di8dKSVJymu4mO4lJ6I9uNmdO51icOjAzRRKa4hQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WN+IUwrT;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0DB99606A319;
	Wed, 21 Oct 2026 10:25:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=WN+IUwrT
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9B4A41F000C9;
	Wed, 21 Oct 2026 10:25:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792578330;
	bh=fyUFCbuePzC+XG2QW79bsjnDsYBX6lH465Zgu9TmAmA=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=WN+IUwrT7l8rUPNHcaU/+gEKsExM+ioOu7ktOtPja5M+dDNUVwHb0vzRVzDdLmi2l
	 ZVZx7zVWlmJhAl69UxYI+zhszNbxVxTNXOBiS7d6CtNd6WfNLIPJPJhmVTj0hz17Wh
	 CBPrxhvYRreyd+T8w2TaPEcsFSkV4dKf9ocMHO00y4EhqsJSxfLpthpPmknHsz6GHD
	 XVMxmeCP5wmxvrqe1pag4NI9ASSec8djC8iso0wCeNRusCl3OXQPYTQT30aPNOVjPM
	 aOLdakMoHfKRaCd3xb8lP0LDs+OVib+4+C4N3+fUQQocX68feX4bzSiBxNtciCBsuG
	 N0l+7t93qoF8A==
Date: Wed, 21 Oct 2026 12:25:10 +0200
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
Subject: Re: [PATCH v2 -next 00/18] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
Message-ID: <20261021-neugierig-abgemacht-umbenannt-c77d1addf517@brauner>
References: <20261015125425.3246251-1-caixinchen1@huawei.com>
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
In-Reply-To: <20261015125425.3246251-1-caixinchen1@huawei.com>

> - The hooks consistently take struct path rather than struct file.  The
>   VFS call sites involved (chmod(2), chown(2), utimensat(2), xattr(2)
>   and ACL syscalls) operate on paths, and several of them (lstat(2),
>   lchown(2), llistxattr(2), ...) have no struct file to begin with.
> 
> - struct inode_operations->setattr still receives (idmap, dentry, attr).
>   Only the VFS boundary (notify_change()) and the LSM hook layer see the
>   path, which keeps the refactor contained to fs/attr.c and the LSM
>   infrastructure instead of touching every filesystem.

I have no problem with that provided:

* all hooks take a const struct path argument
* idmaps are passed separately so that VFS and filesystems are
  guaranteed to see the same idmap
* nobody gets any guarantees whatsoever wrt to path->mnt aka vfsmount

  layout and implementation details might change tomorrow and mounts are
  subtle beasts so the security layer gets to keep pieces if it does
  things that the VFS hasn't explicitly sanctioned as a guaranteed
  property. Things continue to be in flux.
