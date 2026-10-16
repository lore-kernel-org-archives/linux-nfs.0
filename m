Received: from mail-yw1-f181.google.com (mail-yw1-f181.google.com [209.85.128.181])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CE2374D7D51
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 14:44:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.128.181
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792161865; cv=none; b=Ehla5Lbs6+rNG79o/oEzN6w/R1Hh7BVpdv5DDbSDrZotm6emDrHoPs3Xv3N2Cgwdtey1A57UPuY4Ex7rNYA5djKhRurXI7TWsgjAJuy7UztbyMaIDD6VnaQoaU6+BLpVfUAhMHnI6vivnj3OE3FjKlEu8N7cnRaIdI/yuTCXOfk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792161865; c=relaxed/simple;
	bh=TOIiJPI34vCinEaBrduHlT9a71FAHO435ctrN82VAoE=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=XJtGmLYvAdBWj+Ntp6+hMcBq993b48ZioNhk8cuwkCHegd/9Tp+Yui7rduaf9zBQQdqrwLF+559Foos7SnHw1ntQ7ZRsH6dgLEVDcU+5o8kJWJwH4HGwliHyv3VPl2sjpfhjjq7y21fH3RhuXt/fe5WCDnhzVYaE57vyOoLYSRA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=gTKfLCJY; arc=none smtp.client-ip=209.85.128.181
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="gTKfLCJY"
Received: by mail-yw1-f181.google.com with SMTP id 00721157ae682-885cf67963eso55648497b3.0
        for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 07:44:20 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1792161860; x=1792766660; darn=vger.kernel.org;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=b5mPysmOg/X2gxFC8sSeZVp+7zx/SSikTAHOJ0n/l4g=;
        b=gTKfLCJYZqf9Va4X2gK4hWvh8JGoXo5O8GFEPbdK5EGPNk1+nMF69RBEbV56m7VuOa
         u1/uUe52eoiqI9sJYiLcG8LRb7athiBY4YQdiuquYPDED6zea7ip1ow8YfUiVI5ALhmQ
         L+EQJFBIjJ6HUsDnxw+ITN5Q1ujd38a6+1giBhswT7LZd0r5VyP94zQOvnzn4r3xOOHD
         g+hmZ1QF9i+dNNoRfoqKzDPfpDjJ/fdl/Ygmq//k/M8kIvU278oZpbQ8rILnv2tqpwXL
         3A2dYomZAyKqfrfk8w7PFMNPIFePM/8IocWMtWX19I88Ccq3Nfrz7GCPL0+eCWDnKAFR
         Xiiw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1792161860; x=1792766660;
        h=in-reply-to:content-disposition:content-type:mime-version
         :references:message-id:subject:cc:to:from:date:x-gm-gg
         :x-gm-message-state:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=b5mPysmOg/X2gxFC8sSeZVp+7zx/SSikTAHOJ0n/l4g=;
        b=LSg8ZS+XZpdqFkv56/nGSPzQDfYtXFmrRLJq+PqpWriMZnimfTyv5nEStY1DFt0teg
         oRGBHEOvIv5DrNsAM3GsFc7evY0xJ/fiz08NEyCLWVi73yJZLiwQHHEuHLPBwjkezgIQ
         nR8BOAsrwmcwqOmlLhX2s/Q0G65vRDFs71zjOnIZLKZPj7+6HncR3mK/jiVkRhIwaysM
         2QA7fEABL/Imy9egaA4noCoXJqGLEwc6sCW+A4J+4jm0QHE1V3JcJlQanyHERgUDVGg2
         Zv9dZhb6APiImArpVRoOP43fKzvF69ikelhf3ItcvtETou+RCmfej2fIQSkaUJxLTOGJ
         zSHg==
X-Forwarded-Encrypted: i=1; AKwUvBxOHqc2WmUmuy/PvKinNya4WOJQA7OdIQdluyoE7ae6IgaaLT63uvsefk0qIzI4ZLz+/HIYWac+yrE=@vger.kernel.org
X-Gm-Message-State: AFq9FYKERnKV2dBgPc8YSOY5dm68N3EtS5mC8mMsXwuvIotKLbMkEX1h
	YuHYGaZPxcpdCyACZkITGP0hrV49U8tMY+NKrJ6LmWuj8Id6ebGgZpw3
X-Gm-Gg: AYBFou05o+riWqsEC9Snjl9oUtsWBDcsxxukC7KDJFrIteWAi75tCYQOHtc7jefRCtx
	6WGtZrq4f3NmeRlRTL60BmDNkIErP76Y2tqL2ZgjgU06aEc+kaieewEvXGSaWtCvOrb+F6ctjci
	1FblDH/rje4AfjC/cMfLSaEODQka1r6mca7Iah+ZcchLsznesz1X62idGPhgsS42tizgKRZOzq+
	dibNcKmBTnX4+Ok2UzSCabyIQROY1JpxkSkafaxC8fgU4A06dCTCzz+3ANHgIiP2dqigd+Da1bA
	Tm3lCTJS2QoM2dEabfwQ1XUT4+arkNkI+WFyPAMLTOziUaLOws4pHSTmTyXOLP8zUTnLV4jDlpq
	+oAYpjukyirqcmd6fiZ2aFuEf1wrZyZSs51BlqpCzb09o2rcQBi+nRr2NYRmdPZRUsWu62vmi4p
	gx0BxRHNotqu6X5L+dX8f5Q+hhMupzTDJzEJQvqe9Gnil0MI/tZq2OiBATFAkIUrTSxyD43FQW
X-Received: by 2002:a05:690c:a4d4:b0:8ae:8d28:77be with SMTP id 00721157ae682-8b0f205d6dfmr777507b3.1.1792161858531;
        Fri, 16 Oct 2026 07:44:18 -0700 (PDT)
Received: from zenbox ([2600:1700:18fb:6011:1002:ecef:6e38:613d])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-8b0e5888166sm9663717b3.14.2026.10.16.07.44.16
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 16 Oct 2026 07:44:17 -0700 (PDT)
Date: Fri, 16 Oct 2026 10:44:16 -0400
From: Justin Suess <utilityemal77@gmail.com>
To: Cai Xinchen <caixinchen1@huawei.com>
Cc: mic@digikod.net, gnoack@google.com, paul@paul-moore.com, 
	jmorris@namei.org, serge@hallyn.com, corbet@lwn.net, skhan@linuxfoundation.org, 
	ast@kernel.org, daniel@iogearbox.net, andrii@kernel.org, eddyz87@gmail.com, 
	memxor@gmail.com, martin.lau@linux.dev, song@kernel.org, yonghong.song@linux.dev, 
	jolsa@kernel.org, emil@etsalapatis.com, ihor.solodrai@linux.dev, 
	rdunlap@infradead.org, gregkh@linuxfoundation.org, rafael@kernel.org, dakr@kernel.org, 
	johan@kernel.org, dlemoal@kernel.org, hch@lst.de, axboe@kernel.dk, 
	viro@zeniv.linux.org.uk, brauner@kernel.org, jack@suse.cz, dhowells@redhat.com, 
	code@tyhicks.com, linkinjeon@kernel.org, sj1557.seo@samsung.com, 
	yuezhang.mo@sony.com, hirofumi@mail.parknet.co.jp, cel@kernel.org, jlayton@kernel.org, 
	neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com, 
	hyc.lee@gmail.com, miklos@szeredi.hu, amir73il@gmail.com, senozhatsky@chromium.org, 
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
Subject: Re: [PATCH v2 -next 09/18] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
Message-ID: <atI20Vs7Du9-g1Hz@zenbox>
References: <20261015125425.3246251-1-caixinchen1@huawei.com>
 <20261015125425.3246251-10-caixinchen1@huawei.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20261015125425.3246251-10-caixinchen1@huawei.com>

On Thu, Oct 15, 2026 at 08:54:15PM +0800, Cai Xinchen wrote:
> Add two new filesystem access rights to control file metadata access:
> 
> - LANDLOCK_ACCESS_FS_READ_METADATA: Read file or directory metadata
>   (e.g. inode attributes, extended attributes and POSIX ACLs) through
>   stat(2), fstat(2), lstat(2), newfstatat(2), getxattr(2) and
>   friends, listxattr(2) and friends, and the POSIX ACL read
>   operations.
> - LANDLOCK_ACCESS_FS_WRITE_METADATA: Change file or directory
>   metadata through chmod(2) and friends, chown(2) and friends,
>   utimensat(2) and friends, setxattr(2) and friends, removexattr(2)
>   and friends, and the POSIX ACL set and remove operations.
> 
> This follows the coarse-grained grouping approach discussed in the
> mailing list [1], where file metadata operations are grouped by
> security relevance rather than by individual syscall.
> 
> Implement the two rights by hooking the inode_getattr,
> inode_file_getattr, inode_setattr, inode_file_setattr,
> inode_setxattr, inode_getxattr, inode_listxattr, inode_removexattr,
> inode_set_acl, inode_get_acl and inode_remove_acl LSM hooks, which
> now receive a struct path thanks to the preceding VFS and LSM
> refactoring.  The following system calls are now controlled:
> 
> - stat(2), fstat(2), lstat(2), newfstatat(2), getxattr(2) and
>   friends, listxattr(2) and friends, POSIX ACL reads, and the
>   chattr(1)/xfs_io style reads: ioctl(FS_IOC_GETFLAGS),
>   ioctl(FS_IOC_FSGETXATTR) and file_getattr(2) via inode_getattr,
>   inode_getxattr, inode_listxattr, inode_get_acl and
>   inode_file_getattr (READ_METADATA)
> - chmod(2), fchmod(2), fchmodat(2), fchmodat2(2), chown(2), fchown(2),
>   lchown(2), fchownat(2), chgrp(2), utimensat(2), futimens(2),
>   utime(2), setxattr(2) and friends, removexattr(2) and friends,
>   POSIX ACL set and remove, and the chattr(1)/xfs_io style writes:
>   ioctl(FS_IOC_SETFLAGS), ioctl(FS_IOC_FSSETXATTR) and
>   file_setattr(2) via inode_setattr, inode_file_setattr,
>   inode_setxattr, inode_removexattr, inode_set_acl and
>   inode_remove_acl (WRITE_METADATA)
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
> Stacking filesystems forward fileattr operations to underlying inodes
> without calling the LSM hooks again (see the preceding patch), so a
> fileattr operation on an overlayfs file is checked once on the
> user-facing merged path and is not spuriously denied because of the
> kernel-side creator credentials used for the forward.
> 
> Kernel-internal accesses performed with override_creds() (e.g.
> overlayfs and cachefiles) are not affected because Landlock domains
> are attached to credentials, and kernel threads without a Landlock
> domain (e.g. nfsd and ksmbd) are not restricted either.
> 
> Remove stat(2), chmod(2), chown(2), setxattr(2) and utime(2) from the
> list of file-related actions that cannot be restricted yet, and add
> the names of the new rights to _LANDLOCK_ACCESS_FS_NAMES in
> include/linux/landlock.h, which is shared by audit records and trace
> events, so that denied accesses can be reported with a human-readable
> name and the static assertion on fs_access_strings in
> security/landlock/audit.c stays valid.
> 
> Increment the Landlock ABI version from 12 to 13, and update the ABI
> version check in tools/testing/selftests/landlock/base_test.c
> accordingly.
>
LANDLOCK_ACCESS_FS_*_METADATA should be checked at open time and follow
the mechanic for the truncate right. Otherwise the access for already
opened file descriptors would be changed. See hook_file_open in
security/landlock/fs.c and this discussion here [1]

It should have clear documentation for this as well.

Justin
[1] https://lore.kernel.org/all/20260929.Ahgoo4yeetai@digikod.net/


> [1]
> https://lore.kernel.org/all/abc960a1-e66e-792e-6869-cfd201c29dbe@digikod.net/
> 
> Assisted-by: opencode: glm-5.3
> Signed-off-by: Cai Xinchen <caixinchen1@huawei.com>
> ---
>  include/linux/landlock.h      |   4 +-
>  include/uapi/linux/landlock.h |  25 ++++++-
>  security/landlock/fs.c        | 126 ++++++++++++++++++++++++++++++++++
>  security/landlock/limits.h    |   2 +-
>  security/landlock/syscalls.c  |   2 +-
>  5 files changed, 153 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/landlock.h b/include/linux/landlock.h
> index 0ee4880988ba..ee1234fbc9f0 100644
> --- a/include/linux/landlock.h
> +++ b/include/linux/landlock.h
> @@ -41,7 +41,9 @@
>  	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_REFER, "refer"), \
>  	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_TRUNCATE, "truncate"), \
>  	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_IOCTL_DEV, "ioctl_dev"), \
> -	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_RESOLVE_UNIX, "resolve_unix")
> +	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_RESOLVE_UNIX, "resolve_unix"), \
> +	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_READ_METADATA, "read_metadata"), \
> +	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_FS_WRITE_METADATA, "write_metadata")
>  
>  #define _LANDLOCK_ACCESS_NET_NAMES \
>  	_LANDLOCK_NAME_ENTRY(LANDLOCK_ACCESS_NET_BIND_TCP, "bind_tcp"), \
> diff --git a/include/uapi/linux/landlock.h b/include/uapi/linux/landlock.h
> index 24510e5d8479..36dfb499e48e 100644
> --- a/include/uapi/linux/landlock.h
> +++ b/include/uapi/linux/landlock.h
> @@ -429,6 +429,25 @@ struct landlock_capability_attr {
>   *
>   *   The rationale for this design is described in
>   *   :ref:`Documentation/security/landlock.rst <scoped-flags-interaction>`.
> + * - %LANDLOCK_ACCESS_FS_READ_METADATA: Read file or directory metadata (e.g.
> + *   inode attributes, extended attributes, and POSIX ACLs) through
> + *   :manpage:`stat(2)`, :manpage:`fstat(2)`, :manpage:`lstat(2)`,
> + *   :manpage:`newfstatat(2)`, :manpage:`getxattr(2)`, and
> + *   :manpage:`listxattr(2)`.
> + *
> + *   This access right is available since the thirteenth version of the
> + *   Landlock ABI.
> + * - %LANDLOCK_ACCESS_FS_WRITE_METADATA: Change file or directory metadata
> + *   (e.g. inode attributes, extended attributes, and POSIX ACLs) through
> + *   :manpage:`chmod(2)`, :manpage:`chown(2)`, :manpage:`utimensat(2)`,
> + *   :manpage:`setxattr(2)`, and :manpage:`removexattr(2)`, as well as related
> + *   system calls.  Implicit metadata changes performed by the kernel (e.g.
> + *   timestamp updates with :manpage:`write(2)`, or set-user-ID and
> + *   set-group-ID bit clearing with :manpage:`write(2)` or
> + *   :manpage:`truncate(2)`) are not restricted by this access right.
> + *
> + *   This access right is available since the thirteenth version of the
> + *   Landlock ABI.
>   *
>   * Whether an opened file can be truncated with :manpage:`ftruncate(2)` or used
>   * with `ioctl(2)` is determined during :manpage:`open(2)`, in the same way as
> @@ -493,9 +512,7 @@ struct landlock_capability_attr {
>   *
>   *   It is currently not possible to restrict some file-related actions
>   *   accessible through these syscall families: :manpage:`chdir(2)`,
> - *   :manpage:`stat(2)`, :manpage:`flock(2)`, :manpage:`chmod(2)`,
> - *   :manpage:`chown(2)`, :manpage:`setxattr(2)`, :manpage:`utime(2)`,
> - *   :manpage:`fcntl(2)`, :manpage:`access(2)`.
> + *   :manpage:`flock(2)`, :manpage:`fcntl(2)`, :manpage:`access(2)`.
>   *   Future Landlock evolutions will enable to restrict them.
>   */
>  /* clang-format off */
> @@ -516,6 +533,8 @@ struct landlock_capability_attr {
>  #define LANDLOCK_ACCESS_FS_TRUNCATE			(1ULL << 14)
>  #define LANDLOCK_ACCESS_FS_IOCTL_DEV			(1ULL << 15)
>  #define LANDLOCK_ACCESS_FS_RESOLVE_UNIX			(1ULL << 16)
> +#define LANDLOCK_ACCESS_FS_READ_METADATA		(1ULL << 17)
> +#define LANDLOCK_ACCESS_FS_WRITE_METADATA		(1ULL << 18)
>  /* clang-format on */
>  
>  /**
> diff --git a/security/landlock/fs.c b/security/landlock/fs.c
> index a8fa8f77e775..f56277c67a24 100644
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
> @@ -1676,6 +1678,119 @@ static int hook_path_truncate(const struct path *const path)
>  	return current_check_access_path(path, LANDLOCK_ACCESS_FS_TRUNCATE);
>  }
>  
> +static int hook_inode_getattr(const struct path *const path)
> +{
> +	return current_check_access_path(path,
> +					LANDLOCK_ACCESS_FS_READ_METADATA);
> +}
> +
> +static int hook_inode_file_getattr(const struct path *const path,
> +				   struct file_kattr *const fa)
> +{
> +	return current_check_access_path(path,
> +					LANDLOCK_ACCESS_FS_READ_METADATA);
> +}
> +
> +static int hook_inode_setattr(const struct path *const path,
> +			      struct iattr *const attr)
> +{
> +	unsigned int ia_valid = attr->ia_valid;
> +
> +	/*
> +	 * Only explicit metadata changes are checked: implicit
> +	 * timestamp updates never go through notify_change(), and size
> +	 * changes (ATTR_SIZE) are governed by the truncate hooks
> +	 * instead.  See the "File metadata" section in the user space
> +	 * documentation for the full semantics.
> +	 *
> +	 * Clearing the setuid and setgid bits on write(2) or
> +	 * truncate(2) is also an implicit change: callers request it
> +	 * with ATTR_KILL_S[UG]ID, and do_notify_change() then adds a
> +	 * synthesized ATTR_MODE (with these bits removed) before
> +	 * calling this hook.  As do_notify_change() makes it a bug for
> +	 * callers to pass ATTR_MODE together with a kill flag, an
> +	 * ATTR_MODE seen along with ATTR_KILL_S[UG]ID is always
> +	 * kernel-synthesized and must not be checked.  An explicit
> +	 * chmod(2) never sets a kill flag, and an explicit chown(2) on
> +	 * a privileged file is still checked thanks to ATTR_UID and
> +	 * ATTR_GID.
> +	 */
> +	if (ia_valid & (ATTR_KILL_SUID | ATTR_KILL_SGID))
> +		ia_valid &= ~ATTR_MODE;
> +
> +	if (!(ia_valid & (ATTR_MODE | ATTR_UID | ATTR_GID |
> +			  ATTR_TIMES_SET | ATTR_TOUCH)))
> +		return 0;
> +
> +	return current_check_access_path(path,
> +					LANDLOCK_ACCESS_FS_WRITE_METADATA);
> +}
> +
> +static int hook_inode_file_setattr(const struct path *const path,
> +				   struct file_kattr *const fa)
> +{
> +	/*
> +	 * The chattr(2) style flags (e.g. FS_IMMUTABLE_FL) and fsxattr
> +	 * fields are metadata: writing them requires WRITE_METADATA.  The
> +	 * user-facing path is checked here; stacking filesystems skip this
> +	 * hook on their internal forwards because they were already
> +	 * checked on the user-facing path.
> +	 */
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
> @@ -2100,6 +2215,17 @@ static struct security_hook_list landlock_hooks[] __ro_after_init = {
>  	LSM_HOOK_INIT(path_unlink, hook_path_unlink),
>  	LSM_HOOK_INIT(path_rmdir, hook_path_rmdir),
>  	LSM_HOOK_INIT(path_truncate, hook_path_truncate),
> +	LSM_HOOK_INIT(inode_getattr, hook_inode_getattr),
> +	LSM_HOOK_INIT(inode_file_getattr, hook_inode_file_getattr),
> +	LSM_HOOK_INIT(inode_setattr, hook_inode_setattr),
> +	LSM_HOOK_INIT(inode_file_setattr, hook_inode_file_setattr),
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
> diff --git a/security/landlock/limits.h b/security/landlock/limits.h
> index ddd300e10689..ed606ee3102f 100644
> --- a/security/landlock/limits.h
> +++ b/security/landlock/limits.h
> @@ -21,7 +21,7 @@
>  #define LANDLOCK_MAX_NUM_LAYERS		16
>  #define LANDLOCK_MAX_NUM_RULES		U32_MAX
>  
> -#define LANDLOCK_LAST_ACCESS_FS		LANDLOCK_ACCESS_FS_RESOLVE_UNIX
> +#define LANDLOCK_LAST_ACCESS_FS		LANDLOCK_ACCESS_FS_WRITE_METADATA
>  #define LANDLOCK_MASK_ACCESS_FS		((LANDLOCK_LAST_ACCESS_FS << 1) - 1)
>  #define LANDLOCK_NUM_ACCESS_FS		__const_hweight64(LANDLOCK_MASK_ACCESS_FS)
>  
> diff --git a/security/landlock/syscalls.c b/security/landlock/syscalls.c
> index fb5af318b69b..11d3a2abcec1 100644
> --- a/security/landlock/syscalls.c
> +++ b/security/landlock/syscalls.c
> @@ -191,7 +191,7 @@ static const struct file_operations ruleset_fops = {
>   * If the change involves a fix that requires userspace awareness, also update
>   * the errata documentation in Documentation/userspace-api/landlock.rst .
>   */
> -const int landlock_abi_version = 12;
> +const int landlock_abi_version = 13;
>  
>  /**
>   * sys_landlock_create_ruleset - Create a new ruleset
> -- 
> 2.18.0.huawei.25
> 
> 
