Received: from mail-wm2-f12.google.com (mail-wm2-f12.google.com [74.125.225.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6359D39A815
	for <linux-nfs@vger.kernel.org>; Sat, 26 Sep 2026 08:28:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.225.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790411288; cv=none; b=uJMGJNEp6Az0iavI8SOn8BMI7FiCYt2mI2nZX29x7WH+4KtH+e2ZOXm/qV2LhViBJiF0T6gpQp76hlOXQpvpxaaWhO+9m6JJTfHq++Z/NBOQxw4JN0CQq3e4FyGe+Y2p5qxOb3WVvFVHd7EqP3Ek/CZXBbcCMYQ4xuApzB5id1A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790411288; c=relaxed/simple;
	bh=95Vs9hoaKg76Ufz/33WhtAeKWKx39eNDm61SF5fsyOE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=M64Qjb61AhFNflpf/I98LrpzBSGIIpexo7ik6ThGTuAZq8J/brNi6unS5JFYYtb6tZkouXkIRTQlGxgzG8fa2VwpA4vOpww03gLLj/WpadRR9cD+Dx92UlVe4LLGUDu5HNqJrPku+mAI/T2M9CZrNxuqrpwsPEifeenVVUjlcCw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=DniRPhJQ; arc=none smtp.client-ip=74.125.225.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DniRPhJQ"
Received: by mail-wm2-f12.google.com with SMTP id 5b1f17b1804b1-49b912d822dso11568265e9.2
        for <linux-nfs@vger.kernel.org>; Sat, 26 Sep 2026 01:28:05 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790411284; x=1791016084; darn=vger.kernel.org;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=tPXUTB33yRiVb0ap+iiavNUW+iiPbvO+JMKJab+k0Zc=;
        b=DniRPhJQplQ0wdwrhhLjitPE2tYLACalop1qkLYyutbqNFz1sWU0WfS0+AgbxsRGXr
         AaX+j+rg2fV+8HV6eBhOVznOXhihs9BBOdBag9lJun+diTZys5pZ5wiK0UmedKjZvJM/
         F4O13fvxOOIrZueKch3Extd1H049ZpHB/qdrah6b8Cj7effVItu+eEMCZh6icVrI0g2c
         pS0DT8l6Za1wksdL2d3nmWgcTIxJX3q4I9bfcqSpz7A/CIKt/7Le7okC8mgVmhxU+Ix0
         AJ+oAxsJJqPoDCY4Y7cDopY3hlREeHMYHQDyVEWlb3Wl7yMf6y/JE/7eVm42/W8RAe+u
         eq7w==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790411284; x=1791016084;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=tPXUTB33yRiVb0ap+iiavNUW+iiPbvO+JMKJab+k0Zc=;
        b=vzTYBeIPFzKg/wKHlQXSMqpQb3Vyp5L8hjIYcmprWZmIr7QBvA4KZgDUgZSLXjTnqB
         AcUK2E6Ytuan32s1OAhUtMWL+2DSu6YGjX1Omw/QcaDGyhoLxErUrE8day6Cx0ch41iz
         FuuIz1LOwUaCbKTPkwCzf95NO8XKNl6KWEb2AB8DmKc5Sg2HhNiBSbT/Rv7EHVvEF7d8
         LTSxNaGJXNTBwDtvja4aBD1GNvg7s8NUMC6yQ35IuKS8wcuXdGS9ZCSbVE3kjNhFaiXC
         ZeNl72etZUSvYHA+nKEk9vbAauiVKKIc5nECecAmtYhopUYnzvS6EYaiJBmJd1nKepKz
         ASiw==
X-Forwarded-Encrypted: i=1; AKwUvBz9bMoXuU1HlKXO3rXoD3K8JU60ChRUuqUZ/6Cb6ed5O/zCQ5Ur3zVnw6555edFqAo66DFgzd+aK6Q=@vger.kernel.org
X-Gm-Message-State: AFuF++nOYsE8sjH0B7uotI5piaLZl7hoVe3tsAQQ0KN2tDHgEYSBmh0y
	iK/dXIt7CcNjeP7cXKj6/M7AtOdmuLkeOqQV62simsNzbuUQVHv1X9J/
X-Gm-Gg: AYBFou3GXOo0/+2YB8g8Fq1feOUIxzaJ0xWX9MtFoBORs47gvnMWnCVq5kuYjXbCcRx
	7sPbCKg92n32mOuawigggXKFSsCwwmJDpw+q5GuxAxO2eHhZ5ogXs0fELcuCffra8X3QjNW1rWL
	Yln0LMKQU/i0bIcPxK/z4ubLOQrok9SNQogCV6WYW3htPg54k9Vx7QF0b1QzI5AyVMgctWB9F1M
	HmjcsVI5riwXfKNCg32yBYwC3OYdzy4v+3RDRkqHpRPLZBktbauj9R7d7tl3C5oOJ/xt1lZvpV+
	aM1B0hjrxjLxHVVzNNpzKcHP5JdQW9HqueDHCbw6MgtQC4fs5yWTaVOkR+887kAvAtem0MYvGsH
	NXXahoiW+T8ES1b+P4MfDflt9r4zCQnW0FCvviYNWf9RbWUe4jDp5nx8ed3G7UUO39BzoGrnKTa
	sHvMwjN6KLU+pOtGYeTyJas2ZiXx3cz2tBTWa20eGr+Vbqa1Kdbj/hgWe1jqYCkQIdLMmD8805M
	E+9eZzOayEpFb5NW/FwrVU=
X-Received: by 2002:a05:600c:621a:b0:496:c1f3:e8f8 with SMTP id 5b1f17b1804b1-49fe7b52ed6mr138634065e9.7.1790411283366;
        Sat, 26 Sep 2026 01:28:03 -0700 (PDT)
Received: from localhost (ip87-106-108-193.pbiaas.com. [87.106.108.193])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-4887a64f9bcsm12711265f8f.32.2026.09.26.01.28.02
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 26 Sep 2026 01:28:02 -0700 (PDT)
Date: Sat, 26 Sep 2026 10:27:57 +0200
From: =?iso-8859-1?Q?G=FCnther?= Noack <gnoack3000@gmail.com>
To: Cai Xinchen <caixinchen1@huawei.com>
Cc: mic@digikod.net, gnoack@google.com, paul@paul-moore.com,
	jmorris@namei.org, serge@hallyn.com, corbet@lwn.net,
	skhan@linuxfoundation.org, rdunlap@infradead.org,
	gregkh@linuxfoundation.org, rafael@kernel.org, dakr@kernel.org,
	dlemoal@kernel.org, hch@lst.de, axboe@kernel.dk,
	viro@zeniv.linux.org.uk, brauner@kernel.org, jack@suse.cz,
	dhowells@redhat.com, code@tyhicks.com, linkinjeon@kernel.org,
	sj1557.seo@samsung.com, yuezhang.mo@sony.com,
	hirofumi@mail.parknet.co.jp, cel@kernel.org, jlayton@kernel.org,
	neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com,
	tom@talpey.com, miklos@szeredi.hu, amir73il@gmail.com,
	senozhatsky@chromium.org, chenxiaosong@chenxiaosong.com,
	zohar@linux.ibm.com, roberto.sassu@huawei.com,
	dmitry.kasatkin@gmail.com, eric.snowberg@oracle.com,
	stephen.smalley.work@gmail.com, omosnacek@gmail.com,
	casey@schaufler-ca.com, nanx95726@gmail.com, djwong@kernel.org,
	daniel@iogearbox.net, linux-security-module@vger.kernel.org,
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
	driver-core@lists.linux.dev, linux-block@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, netfs@lists.linux.dev,
	ecryptfs@vger.kernel.org, exfat@lists.linux.dev,
	linux-nfs@vger.kernel.org, linux-unionfs@vger.kernel.org,
	linux-cifs@vger.kernel.org, linux-integrity@vger.kernel.org,
	selinux@vger.kernel.org, linux-kselftest@vger.kernel.org,
	xiujianfeng@huawei.com, lujialin4@huawei.com, bpf@vger.kernel.org,
	kpsingh@kernel.org, matt@bobrowski.net,
	alexei.starovoitov@gmail.com
Subject: Re: [PATCH RFC -next 00/12] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
Message-ID: <20260926.e0135fe7712f@gnoack.org>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260924104831.1081137-1-caixinchen1@huawei.com>

On Thu, Sep 24, 2026 at 06:48:19PM +0800, Cai Xinchen wrote:
> This series adds two new Landlock filesystem access rights,
> LANDLOCK_ACCESS_FS_READ_METADATA and LANDLOCK_ACCESS_FS_WRITE_METADATA,
> which control access to file and directory metadata such as inode
> attributes (mode, ownership, timestamps), extended attributes and POSIX
> ACLs.  It picks up the work from the "landlock: add chmod and chown
> support" series [1] and follows the coarse-grained grouping discussed in
> that thread [2]: instead of separate chmod/chown rights, metadata
> operations are grouped into one read and one write right.
> 
> Landlock evaluates access rights on a per-path basis, but the metadata
> related LSM hooks (inode_getattr, inode_setattr, inode_setxattr,
> inode_getxattr, inode_listxattr, inode_removexattr, inode_set_acl,
> inode_get_acl, inode_remove_acl) only receive the dentry of the accessed
> object.  Patches 1-7 therefore first pass struct path instead of dentry
> through the metadata-related VFS helpers and LSM hooks.  This is a pure
> refactoring with no behavior change, split so that every patch builds
> and works on its own:
> 
>   1: notify_change() and its callers
>   2: inode_setsecctx hook (must come before 3: the SELinux and Smack
>      implementations call __vfs_setxattr_locked internally)
>   3: xattr helpers, which also drops a redundant EVM xattr size sanity
>      check whose vfs_getxattr() call only has a dentry and therefore
>      cannot be migrated to the new path-based signature
>   4: POSIX ACL helpers
>   5: inode_setattr hook
>   6: inode xattr hooks
>   7: inode POSIX ACL hooks
> 
> Two deliberate scoping decisions for this refactor:
> 
> - The hooks consistently take struct path rather than struct file.  The
>   VFS call sites involved (chmod(2), chown(2), utimensat(2), xattr(2)
>   and ACL syscalls) operate on paths, and several of them (lstat(2),
>   lchown(2), llistxattr(2), ...) have no struct file to begin with.
> 
> - struct inode_operations->setattr still receives (idmap, dentry, attr).
>   Only the VFS boundary (notify_change()) and the LSM hook layer see the
>   path, which keeps the refactor contained to fs/attr.c and the LSM
>   infrastructure instead of touching every filesystem.
> 
> Patches 8-12 then implement the new rights, their tests, the sandboxer
> sample and the documentation.  Semantics:
> 
> - READ_METADATA covers stat(2) and friends, getxattr(2) and friends,
>   listxattr(2) and friends, and POSIX ACL reads.
> - WRITE_METADATA covers chmod(2), chown(2), utimensat(2), setxattr(2),
>   removexattr(2) and friends, and POSIX ACL set and remove.
> - Only explicit metadata changes requested by user space are restricted.
>   Implicit changes performed by the kernel (e.g. timestamp updates on
>   write(2), size changes on truncate(2)) are not, and neither are
>   chmod(2)/chown(2) calls that change nothing (e.g. chown(2) with
>   (-1, -1), which never reaches the hook), matching the SELinux
>   inode_setattr behavior.
> - Kernel-internal accesses performed with override_creds() (e.g.
>   overlayfs, cachefiles) and kernel threads without a Landlock domain
>   (e.g. nfsd, ksmbd) are not restricted.
> 
> The Landlock ABI version is incremented from 11 to 12.
> 
> The series is based on linux-next commit 5c4d4169604b ("Add linux-next
> specific files for 20260921").
> 
> Testing: each patch has been built for aarch64 (gcc, -Werror) and the
> landlock selftests (445 tests, including the new ones) pass in QEMU on
> aarch64; base_test reports ABI v12.
> 
> [1] https://lore.kernel.org/all/20220827111215.131442-1-xiujianfeng@huawei.com/
> [2] https://lore.kernel.org/all/abc960a1-e66e-792e-6869-cfd201c29dbe@digikod.net/

Thank you for sending this patch set!

Some meta-remarks at the beginning:

* You might want to link the bugtracker feature request:
  https://github.com/landlock-lsm/linux/issues/11
* In the final version, I think it's preferred to merge patches 8
  (adding the access right enums) and 9 (adding the LSM hooks that use
  them).  Having the feature as an atomic commit makes it harder to
  accidentally mess it up during a backport, because you can't patch 8
  without 9.
* As Paul alluded to, the changes to the LSM hook interface and to the
  existing callers in VFS are likely the hardest part of this patch
  set.  Alexei from the BPF subsystem has also reiterated recently
  that he wants BPF to be looped into such changes.  BPF hooks do not
  give the same backwards compatibility guarantees as the syscall
  layer, but there are existing users of LSM hooks specifically
  through the BPF LSM.

* In https://github.com/landlock-lsm/linux/issues/18, we came across
  statfs(), which returns file system meta-information based for the
  file system that a given file belongs to.  I have weak confidence
  that READ_METADATA would be the right access right to protect this
  with, but it's a somewhat related operation.  Maybe you have some
  thoughts on this?

More concrete questions:

* If a "inode" LSM hook gets a "path" argument now, should it be
  renamed from "inode_..." to "path_..."?

  (Maybe the BPF people can chime in about to what extent that would
  cause additional churn for BPF users, in a situation where they
  anyway already need to make a change due to the changing function
  signature?)

–Günther
