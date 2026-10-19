Received: from canpmsgout10.his.huawei.com (canpmsgout10.his.huawei.com [113.46.200.225])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 02A61305E1F;
	Mon, 19 Oct 2026 13:18:30 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.225
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792415913; cv=none; b=XKpGr6cTWSlm9myuwrL+gKYJ8rJ0rkt4YaPISt1QFbmLH9IkJqocFAjflYXjHB+wt/r/MNrI7xlYbixEiPQFNgnFQMlbqdnzcyIPkvex+Xj1o4qLojCx2D8cBZKyjpAQyatyeORvDFxEgl418FZR7BAbkbhnyijFfemdZIf+ITE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792415913; c=relaxed/simple;
	bh=tw/NIA6n/WlEM9gbRkoL6G9qlG0bYIFMcFGFohHaOpg=;
	h=Message-ID:Date:MIME-Version:Subject:To:CC:References:From:
	 In-Reply-To:Content-Type; b=SZL35z+CpLiuo6vCm6aly2QyiPs4uF4CT4zRUSarulMebxS9/EzQOL9u8UYaOyNWunhpfWIUelZ0Z0FgErUEZCtkcwyigPlh3fnpEAOl9Yw3Z/+NRjV/Pf2Nj50eiWQ9wqphUdXNPyviNUVaMr7gyuObr1PuSxuaFnPOxCECuLA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=4TBSCuQs; arc=none smtp.client-ip=113.46.200.225
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="4TBSCuQs"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=nsTgvIZAvLZ3AkHd7te1YwAT5vQcze+ZS3sOvyFtcIg=;
	b=4TBSCuQs0ZdnPFMgTM9bX9OvAvFEfbIZ0LIjSwYBzm0TCIeE0rVraJFOIej4k1X7EItvC1NmR
	DX3BwVJS/9MaAexRTXkUg/68Kdod6DsiNW4k5ZZ6iNTl5sWy1P0de+g7jr1skB7fCwujvSD5mIa
	tukVtvADo4Ri0z5qNKiN+rE=
Received: from mail.maildlp.com (unknown [172.19.163.163])
	by canpmsgout10.his.huawei.com (SkyGuard) with ESMTPS id 4j7bhR2MFBz1K96D;
	Mon, 19 Oct 2026 21:18:15 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 23C6D4057A;
	Mon, 19 Oct 2026 21:18:18 +0800 (CST)
Received: from [10.67.110.140] (10.67.110.140) by
 whupemk100010.china.huawei.com (7.152.184.41) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.2.2562.45; Mon, 19 Oct 2026 21:18:11 +0800
Message-ID: <bfc74a80-92e9-4dcf-926e-0a2e2c33e4d5@huawei.com>
Date: Mon, 19 Oct 2026 21:18:10 +0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v2 -next 09/18] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
To: =?UTF-8?Q?G=C3=BCnther_Noack?= <gnoack@google.com>, Justin Suess
	<utilityemal77@gmail.com>
CC: <mic@digikod.net>, <paul@paul-moore.com>, <jmorris@namei.org>,
	<serge@hallyn.com>, <corbet@lwn.net>, <skhan@linuxfoundation.org>,
	<ast@kernel.org>, <daniel@iogearbox.net>, <andrii@kernel.org>,
	<eddyz87@gmail.com>, <memxor@gmail.com>, <martin.lau@linux.dev>,
	<song@kernel.org>, <yonghong.song@linux.dev>, <jolsa@kernel.org>,
	<emil@etsalapatis.com>, <ihor.solodrai@linux.dev>, <rdunlap@infradead.org>,
	<gregkh@linuxfoundation.org>, <rafael@kernel.org>, <dakr@kernel.org>,
	<johan@kernel.org>, <dlemoal@kernel.org>, <hch@lst.de>, <axboe@kernel.dk>,
	<viro@zeniv.linux.org.uk>, <brauner@kernel.org>, <jack@suse.cz>,
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
 <20261015125425.3246251-10-caixinchen1@huawei.com> <atI20Vs7Du9-g1Hz@zenbox>
 <atYBVCIYE1zDb7do@google.com>
Content-Language: en-US
From: Cai Xinchen <caixinchen1@huawei.com>
In-Reply-To: <atYBVCIYE1zDb7do@google.com>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: kwepems500002.china.huawei.com (7.221.188.17) To
 whupemk100010.china.huawei.com (7.152.184.41)

Hello Günther,

Yes, this seems reasonable to me, and I agree it should be a conscious
decision: the next revision will make the *_METADATA rights follow the
same "file descriptor as capability" semantic as *_TRUNCATE and
*_IOCTL_DEV.

Concretely:

- hook_file_open() will record READ_METADATA and WRITE_METADATA
   availability at open() time, together with TRUNCATE and IOCTL_DEV;
   both rights will join the _LANDLOCK_ACCESS_FS_OPTIONAL set, which
   also keeps the deny-mask and quiet-audit logic consistent.
- Metadata operations that go through a file descriptor (fstat() and
   statx() on a descriptor, fchmod(), fchown(), futimensat() with
   AT_EMPTY_PATH, fgetxattr(), fsetxattr(), flistxattr(),
   fremovexattr(), POSIX ACLs set through a descriptor, the FS_IOC_*
   flag ioctls, and file_getattr() / file_setattr() with AT_EMPTY_PATH)
   will be authorized with the rights recorded at open() time,
   regardless of the domain of the calling thread -- like ftruncate()
   today.
- Operations on paths keep being checked against the current domain.
- The "Rights associated with file descriptors" documentation section
   will be updated accordingly, together with a note that
   READ_METADATA should usually be requested in lockstep with
   READ_FILE and READ_DIR, as for WRITE_FILE and TRUNCATE.

On 10/19/2026 7:43 PM, Günther Noack wrote:
> Hello!
>
> On Fri, Oct 16, 2026 at 10:44:16AM -0400, Justin Suess wrote:
>> On Thu, Oct 15, 2026 at 08:54:15PM +0800, Cai Xinchen wrote:
>>> Add two new filesystem access rights to control file metadata access:
>>>
>>> - LANDLOCK_ACCESS_FS_READ_METADATA: Read file or directory metadata
>>>    (e.g. inode attributes, extended attributes and POSIX ACLs) through
>>>    stat(2), fstat(2), lstat(2), newfstatat(2), getxattr(2) and
>>>    friends, listxattr(2) and friends, and the POSIX ACL read
>>>    operations.
>>> - LANDLOCK_ACCESS_FS_WRITE_METADATA: Change file or directory
>>>    metadata through chmod(2) and friends, chown(2) and friends,
>>>    utimensat(2) and friends, setxattr(2) and friends, removexattr(2)
>>>    and friends, and the POSIX ACL set and remove operations.
>>>
>>> This follows the coarse-grained grouping approach discussed in the
>>> mailing list [1], where file metadata operations are grouped by
>>> security relevance rather than by individual syscall.
>>>
>>> Implement the two rights by hooking the inode_getattr,
>>> inode_file_getattr, inode_setattr, inode_file_setattr,
>>> inode_setxattr, inode_getxattr, inode_listxattr, inode_removexattr,
>>> inode_set_acl, inode_get_acl and inode_remove_acl LSM hooks, which
>>> now receive a struct path thanks to the preceding VFS and LSM
>>> refactoring.  The following system calls are now controlled:
>>>
>>> - stat(2), fstat(2), lstat(2), newfstatat(2), getxattr(2) and
>>>    friends, listxattr(2) and friends, POSIX ACL reads, and the
>>>    chattr(1)/xfs_io style reads: ioctl(FS_IOC_GETFLAGS),
>>>    ioctl(FS_IOC_FSGETXATTR) and file_getattr(2) via inode_getattr,
>>>    inode_getxattr, inode_listxattr, inode_get_acl and
>>>    inode_file_getattr (READ_METADATA)
>>> - chmod(2), fchmod(2), fchmodat(2), fchmodat2(2), chown(2), fchown(2),
>>>    lchown(2), fchownat(2), chgrp(2), utimensat(2), futimens(2),
>>>    utime(2), setxattr(2) and friends, removexattr(2) and friends,
>>>    POSIX ACL set and remove, and the chattr(1)/xfs_io style writes:
>>>    ioctl(FS_IOC_SETFLAGS), ioctl(FS_IOC_FSSETXATTR) and
>>>    file_setattr(2) via inode_setattr, inode_file_setattr,
>>>    inode_setxattr, inode_removexattr, inode_set_acl and
>>>    inode_remove_acl (WRITE_METADATA)
>>>
>>> Both new rights are added to ACCESS_FILE as they apply to both files
>>> and directories.
>>>
>>> hook_inode_setattr only restricts explicit metadata changes, i.e. it
>>> checks WRITE_METADATA only when the ia_valid mask contains
>>> ATTR_MODE, ATTR_UID, ATTR_GID, ATTR_TIMES_SET or ATTR_TOUCH.
>>> Metadata changes that the kernel performs implicitly, such as
>>> timestamp updates on write(2) or size changes on truncate(2), are
>>> therefore not restricted, and neither are chmod(2)/chown(2) calls
>>> that do not change any attribute (e.g. chown(2) with -1/-1, which is
>>> a no-op that never reaches the hook), matching the behavior of the
>>> SELinux inode_setattr hook.
>>>
>>> Stacking filesystems forward fileattr operations to underlying inodes
>>> without calling the LSM hooks again (see the preceding patch), so a
>>> fileattr operation on an overlayfs file is checked once on the
>>> user-facing merged path and is not spuriously denied because of the
>>> kernel-side creator credentials used for the forward.
>>>
>>> Kernel-internal accesses performed with override_creds() (e.g.
>>> overlayfs and cachefiles) are not affected because Landlock domains
>>> are attached to credentials, and kernel threads without a Landlock
>>> domain (e.g. nfsd and ksmbd) are not restricted either.
>>>
>>> Remove stat(2), chmod(2), chown(2), setxattr(2) and utime(2) from the
>>> list of file-related actions that cannot be restricted yet, and add
>>> the names of the new rights to _LANDLOCK_ACCESS_FS_NAMES in
>>> include/linux/landlock.h, which is shared by audit records and trace
>>> events, so that denied accesses can be reported with a human-readable
>>> name and the static assertion on fs_access_strings in
>>> security/landlock/audit.c stays valid.
>>>
>>> Increment the Landlock ABI version from 12 to 13, and update the ABI
>>> version check in tools/testing/selftests/landlock/base_test.c
>>> accordingly.
>>>
>> LANDLOCK_ACCESS_FS_*_METADATA should be checked at open time and follow
>> the mechanic for the truncate right. Otherwise the access for already
>> opened file descriptors would be changed. See hook_file_open in
>> security/landlock/fs.c and this discussion here [1]
>>
>> It should have clear documentation for this as well.
>>
>> Justin
>> [1] https://lore.kernel.org/all/20260929.Ahgoo4yeetai@digikod.net/
>
> I agree with Justin here.
>
> Apart from what I said in [1], Justin and Mickaël pointed out this
> other aspect in which it is similar to *_TRUNCATE, in [2] and [3]:
> System calls like fstat(2) operate on an already-opened file
> descriptor, and the semantic that Landlock has so far been following
> for these is that the effective access rights for that file descriptor
> would be determined at the time of open(2) and stored in the opened
> struct file, just as it has been done for the *_TRUNCATE and
> *_IOCTL_DEV access rights in the hook_file_open() call which Justin
> points to above.
>
> That way, an already opened file acts as a handle for a "capability"
> (in the more general sense of the word), and the things you can do
> with that opened file don't change as the process enforces nested
> Landlock domains.
>
> Landlock's documentation describes this in
> https://docs.kernel.org/userspace-api/landlock.html#rights-associated-with-file-descriptors
>
> It feels that this would be in order for the *_METADATA rights as
> well?  Does this seem reasonable to you?
>
> (If you have arguments against that, I'm also more than happy to
> discuss, but we should make a conscious decision. :-))
>
> —Günther
>
> [1] https://lore.kernel.org/all/arurOphe6QIx2Zr8@google.com/
> [2] https://lore.kernel.org/all/arvjb0HJYh1KyEBB@suesslenovo/
> [3] https://lore.kernel.org/all/20260929.Ahgoo4yeetai@digikod.net/
