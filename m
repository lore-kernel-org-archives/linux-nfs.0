Received: from mail-wm2-f12.google.com (mail-wm2-f12.google.com [74.125.225.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3FB023A6B6D
	for <linux-nfs@vger.kernel.org>; Sat, 26 Sep 2026 08:38:28 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.225.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790411912; cv=none; b=i+Kc/x5G9TwLAQFHLnuE3vXbN0iM3DJdqHxA1ANTRNydO7xM9//KBebrDK5J7YXZnAIMa3J7zcsoAvqpbmJknVwqlWuBQgqMv95OCANyItIc0S07NMmsJr8L2PlJ/KodwnRHFd3y+sq8Dm4NpLr6V6Y1mv3HDxMqY0IUmhRf2s4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790411912; c=relaxed/simple;
	bh=dg1L5YWtdAyboMbKumSCH8z23MTRvvFyqARphfS6bXE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=tMOd1qLo60EStDpm0q6zanQbv1rUMAAyPwRGu9oExxPJy+iP+ctDye+vhIwdrqFLaSA92t1VoS1JoebUAylphqziFLI7iT/zAu0tUe4v6sZeI/My6jK4sPil6i2Gb8oL/XNTK2QXqlCyJ3BU07zIRU7cUbCwrylF4MKZDbY+q+0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=BKURZPTO; arc=none smtp.client-ip=74.125.225.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="BKURZPTO"
Received: by mail-wm2-f12.google.com with SMTP id 5b1f17b1804b1-49cd4ba9f68so17754075e9.1
        for <linux-nfs@vger.kernel.org>; Sat, 26 Sep 2026 01:38:28 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790411906; x=1791016706; darn=vger.kernel.org;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=c9e9Ohjh62jjpKVoXb3eLlcbg9rHFeTPk+yn3uYWypA=;
        b=BKURZPTOWxv3VmPPK29w/6Si+KDE00h4CnjQmN8AsVssqxOHoY+LFnD7548RMzRKlw
         kC1H75pYwv88rBTYtz7U4GLaSTWr/UCfaqsmA35bA6JrHALtnz/rvSOQgIyS9am4tAI8
         857YtNnRAjqSAAbTM5AnkwBw0DJgnHP5EN3xPZ+5t2Vml0NuBZOROu2f4KAMRNbVYRkt
         dmA0jfdAhBGp3t02V20XibZQmtzAN3qDkqE+ekgZcwcNAhXeTHwFltNh3IRz+TyaTnHb
         HNtz9S/Jcz8jgJFoei42ZnCLoJn7yAdYgDj2BMe/12b7qNoWAwa9whoLYDTxJHrGkEoH
         OwVw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790411906; x=1791016706;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=c9e9Ohjh62jjpKVoXb3eLlcbg9rHFeTPk+yn3uYWypA=;
        b=DUHoDe9ikMS872VSlqgncwGRimiF4/QDIigSqQodtX7IWBYl380bXWDcKnE01QcR1S
         HgTOX9CXajU09eKLtBUCJwf+ts1Vj0WZuBjdFE3Svkyz30SrNiY7qgGZtcc0P04h0xiu
         Sjd/U1C40jg9OgBFCdMXembpwLnJirpbI+L+OoA4EO7GOaWzpiUICocLxkPhjsE524/1
         +zEK0Z8PE91Mt5Vlnu83u0YniXPY/KmoAbljoQUJimSjoKHoM6qTwYzATwKPEzcRfQgh
         xE45ZzKIzvtvDMYvm9QOIsQlJy54rrHbklEci7oEmPCtCpvw9CR1MuemExZvjd23QFJ3
         O1uQ==
X-Forwarded-Encrypted: i=1; AKwUvBy8t69e8CZr930cN9nsz/Exj5yrXu8IO/GWlQX2utfMMpV6iDfpGo31bnsTrZu9IkeeoxYu5kWfqcE=@vger.kernel.org
X-Gm-Message-State: AFuF++mMz0wL7QWbjL/UBt+rNiWDxFwlAMcrSzGPYufk7ZlOIK3r+Yoa
	/qF2C/oI8Vy+7mlOk2TivorrjeskMaZfu1Fgo4iKmxDUzyhleGhv1hJ1
X-Gm-Gg: AYBFou0rqWfMMHLPhuR/fsMl0F7R5JaIzlsFNFoRKMeiucYn0KOT0gQSnTSSwqye/wc
	qTS9ZSxfv+hkjlthVV8sHF7klcbeeHGaqez0A3pCoZ5kUhGlxQZdIuA3ebllaK7+QHxn2ug5OAB
	QhI+qz1/rxmmItHvNd4ZGhlIOS8YIBhr2tOL56b/Y4ri2JyTZzjL6++l+8QsRUdKUTtP+08jymn
	bscfTv+nGdn8FOVEdoBitFC7g+EuSS5EfUOzKbhJS+HOTP47L2/cHse/aGCC+xJqzxdmljFeeyD
	UgQ+/gxTQlysBVgFRkazb3vz9Y5el+1LSSi1liPs42U0EavYDnRBLPumIHhheFFmEd1d5mWHFLb
	GIsCxU9Gumc72ghzah6KJ+U28wc83ry1WT/9QgzdJVMN12Dp3OeSajn0AxU24UM4AUNXfhblNnX
	6KRztYGHLp3OtVucvYRANTs4bb6GfcWZUrxeHdzXsHH9fIw3dQEbcXFlTTnkrSLN2tOwXkLEBj4
	mla0mnpTRWbolZSP0RiLbs=
X-Received: by 2002:a05:600c:1d02:b0:49f:fd66:5fe0 with SMTP id 5b1f17b1804b1-49ffd6661a7mr12811255e9.9.1790411906263;
        Sat, 26 Sep 2026 01:38:26 -0700 (PDT)
Received: from localhost (ip87-106-108-193.pbiaas.com. [87.106.108.193])
        by smtp.gmail.com with ESMTPSA id 5b1f17b1804b1-49fe5de4de4sm215396785e9.8.2026.09.26.01.38.25
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sat, 26 Sep 2026 01:38:25 -0700 (PDT)
Date: Sat, 26 Sep 2026 10:38:24 +0200
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
	xiujianfeng@huawei.com, lujialin4@huawei.com
Subject: Re: [PATCH RFC -next 09/12] landlock: Implement metadata access hooks
Message-ID: <20260926.a96402fcbd4b@gnoack.org>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
 <20260924104831.1081137-10-caixinchen1@huawei.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260924104831.1081137-10-caixinchen1@huawei.com>

On Thu, Sep 24, 2026 at 06:48:28PM +0800, Cai Xinchen wrote:
> Implement the LANDLOCK_ACCESS_FS_READ_METADATA and
> LANDLOCK_ACCESS_FS_WRITE_METADATA access rights by hooking the
> inode_getattr, inode_setattr, inode_setxattr, inode_getxattr,
> inode_listxattr, inode_removexattr, inode_set_acl, inode_get_acl and
> inode_remove_acl LSM hooks, which now receive a struct path thanks to
> the preceding VFS and LSM refactoring.
> 
> The following system calls are now controlled:
> 
> - stat(2), fstat(2), lstat(2), newfstatat(2), getxattr(2) and
>   friends, listxattr(2) and friends, and POSIX ACL reads via
>   inode_getattr, inode_getxattr, inode_listxattr and inode_get_acl
>   (READ_METADATA)
> - chmod(2), fchmod(2), fchmodat(2), fchmodat2(2), chown(2), fchown(2),
>   lchown(2), fchownat(2), chgrp(2), utimensat(2), futimens(2),
>   utime(2), setxattr(2) and friends, removexattr(2) and friends, and
>   POSIX ACL set and remove via inode_setattr, inode_setxattr,
>   inode_removexattr, inode_set_acl and inode_remove_acl
>   (WRITE_METADATA)
> 
> Both new rights are added to ACCESS_FILE as they apply to both files
> and directories.
> 
> hook_inode_setattr only restricts explicit metadata changes, i.e. it
> checks WRITE_METADATA only when the ia_valid mask contains
> ATTR_MODE, ATTR_UID, ATTR_GID, ATTR_TIMES_SET or ATTR_TOUCH.
> Metadata changes that the kernel performs implicitly, such as
> timestamp updates on write(2) or size changes on truncate(2), are
> therefore not restricted, and neither are chmod(2)/chown(2) calls
> that do not change any attribute (e.g. chown(2) with -1/-1, which is
> a no-op that never reaches the hook), matching the behavior of the
> SELinux inode_setattr hook.
> 
> Kernel-internal accesses performed with override_creds() (e.g.
> overlayfs and cachefiles) are not affected because Landlock domains
> are attached to credentials, and kernel threads without a Landlock
> domain (e.g. nfsd and ksmbd) are not restricted either.
> 
> Assisted-by: opencode: glm-5.3
> Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
> ---
>  security/landlock/fs.c | 86 ++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 86 insertions(+)
> 
> diff --git a/security/landlock/fs.c b/security/landlock/fs.c
> index cab43892ec2f..e58b2aa0da65 100644
> --- a/security/landlock/fs.c
> +++ b/security/landlock/fs.c
> @@ -318,6 +318,8 @@ static struct landlock_object *get_inode_object(struct inode *const inode)
>  	LANDLOCK_ACCESS_FS_EXECUTE | \
>  	LANDLOCK_ACCESS_FS_WRITE_FILE | \
>  	LANDLOCK_ACCESS_FS_READ_FILE | \
> +	LANDLOCK_ACCESS_FS_READ_METADATA | \
> +	LANDLOCK_ACCESS_FS_WRITE_METADATA | \
>  	LANDLOCK_ACCESS_FS_TRUNCATE | \
>  	LANDLOCK_ACCESS_FS_IOCTL_DEV | \
>  	LANDLOCK_ACCESS_FS_RESOLVE_UNIX)
> @@ -1676,6 +1678,81 @@ static int hook_path_truncate(const struct path *const path)
>  	return current_check_access_path(path, LANDLOCK_ACCESS_FS_TRUNCATE);
>  }
>  
> +static int hook_inode_getattr(const struct path *const path)
> +{
> +	return current_check_access_path(path,
> +					LANDLOCK_ACCESS_FS_READ_METADATA);
> +}
> +
> +static int hook_inode_setattr(const struct path *const path,
> +			      struct iattr *const attr)
> +{
> +	/*
> +	 * Explicit metadata changes (i.e. mode, ownership, and timestamps
> +	 * set with utimes() and friends) require
> +	 * LANDLOCK_ACCESS_FS_WRITE_METADATA.  Implicit timestamp updates
> +	 * (e.g. ATTR_CTIME set for a write) and size changes (handled by
> +	 * the truncate hooks) are not restricted.

Nit: It feels like this comment about implicit timestamp updates
(especially the size change) should go in the top-level documentation
for the WRITE_METADATA right?  setattr() can not result in a size
change, after all, AFAIK?

Remark on the side, apart from truncation, normal writes into the file
can of course also change its size ;-) and ATTR_ATIME and ATTR_MTIME
also come to mind as implicit metadata changes.

> +	 */
> +	if (!(attr->ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID |
> +				ATTR_TIMES_SET | ATTR_TOUCH)))
> +		return 0;
> +
> +	return current_check_access_path(path,
> +					LANDLOCK_ACCESS_FS_WRITE_METADATA);
> +}
> +
> +static int hook_inode_setxattr(const struct path *const path,
> +			       const char *const name,
> +			       const void *const value, const size_t size,
> +			       const int flags)
> +{
> +	return current_check_access_path(path,
> +					LANDLOCK_ACCESS_FS_WRITE_METADATA);
> +}
> +
> +static int hook_inode_getxattr(const struct path *const path,
> +			       const char *const name)
> +{
> +	return current_check_access_path(path,
> +					LANDLOCK_ACCESS_FS_READ_METADATA);
> +}
> +
> +static int hook_inode_listxattr(const struct path *const path)
> +{
> +	return current_check_access_path(path,
> +					LANDLOCK_ACCESS_FS_READ_METADATA);
> +}
> +
> +static int hook_inode_removexattr(const struct path *const path,
> +				  const char *const name)
> +{
> +	return current_check_access_path(path,
> +					LANDLOCK_ACCESS_FS_WRITE_METADATA);
> +}
> +
> +static int hook_inode_set_acl(const struct path *const path,
> +			      const char *const acl_name,
> +			      struct posix_acl *const kacl)
> +{
> +	return current_check_access_path(path,
> +					LANDLOCK_ACCESS_FS_WRITE_METADATA);
> +}
> +
> +static int hook_inode_get_acl(const struct path *const path,
> +			      const char *const acl_name)
> +{
> +	return current_check_access_path(path,
> +					LANDLOCK_ACCESS_FS_READ_METADATA);
> +}
> +
> +static int hook_inode_remove_acl(const struct path *const path,
> +				 const char *const acl_name)
> +{
> +	return current_check_access_path(path,
> +					LANDLOCK_ACCESS_FS_WRITE_METADATA);
> +}
> +
>  /**
>   * unmask_scoped_access - Remove access right bits in @masks in all layers
>   *                        where @client and @server have the same domain
> @@ -2100,6 +2177,15 @@ static struct security_hook_list landlock_hooks[] __ro_after_init = {
>  	LSM_HOOK_INIT(path_unlink, hook_path_unlink),
>  	LSM_HOOK_INIT(path_rmdir, hook_path_rmdir),
>  	LSM_HOOK_INIT(path_truncate, hook_path_truncate),
> +	LSM_HOOK_INIT(inode_getattr, hook_inode_getattr),
> +	LSM_HOOK_INIT(inode_setattr, hook_inode_setattr),
> +	LSM_HOOK_INIT(inode_setxattr, hook_inode_setxattr),
> +	LSM_HOOK_INIT(inode_getxattr, hook_inode_getxattr),
> +	LSM_HOOK_INIT(inode_listxattr, hook_inode_listxattr),
> +	LSM_HOOK_INIT(inode_removexattr, hook_inode_removexattr),
> +	LSM_HOOK_INIT(inode_set_acl, hook_inode_set_acl),
> +	LSM_HOOK_INIT(inode_get_acl, hook_inode_get_acl),
> +	LSM_HOOK_INIT(inode_remove_acl, hook_inode_remove_acl),
>  	LSM_HOOK_INIT(unix_find, hook_unix_find),
>  
>  	LSM_HOOK_INIT(file_alloc_security, hook_file_alloc_security),
> -- 
> 2.18.0.huawei.25
> 

On the Landlock side, the implementation looks quite straightforward,
without having double checked for missing hooks now.  This commit is
probably fine as soon as we have agreement on the LSM hook changes.

–Günther
