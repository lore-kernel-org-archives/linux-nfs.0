Received: from canpmsgout11.his.huawei.com (canpmsgout11.his.huawei.com [113.46.200.226])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 13A88377A8A;
	Mon, 28 Sep 2026 06:52:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=113.46.200.226
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790578347; cv=none; b=GhwIK7rpTDFxDUOJlupaujJhou+zSk77wFLi5hZRFNnsm1pkbtt4aPdoBulJG9nAfmlQ+udvIlmgpD+QiO+mzLfn1qoJjI8UjT8TVLnUEoblB0gOfRk1E7bbIUjRqMoFE5AQdmezaGL8w9mQsKyi5Yd3bAGz2TJUUt91yWkUzJc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790578347; c=relaxed/simple;
	bh=l99O4EFuTYgaVlJE6vpUwnoIBIsWomYu6FImDHQefNw=;
	h=Message-ID:Date:MIME-Version:Subject:To:CC:References:From:
	 In-Reply-To:Content-Type; b=Pcc4+n5IQamy6p4GXCQFIaMjKD5/vQh/ap5biYCdEQHtTg3vdY+Nf5fyt9VlzdICR3Rp9prLIyepv1SpmMXZqb5bE4mhOeZyAlrn9NPiH8cidCQm2QZ3Co7MtTPc/gj4ImoOk8etUBNP3ZReiHmMapeKKaezTDMGHLQMVQiutGc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com; spf=pass smtp.mailfrom=huawei.com; dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b=tZ+wKmOM; arc=none smtp.client-ip=113.46.200.226
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=huawei.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=huawei.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=huawei.com header.i=@huawei.com header.b="tZ+wKmOM"
dkim-signature: v=1; a=rsa-sha256; d=huawei.com; s=dkim;
	c=relaxed/relaxed; q=dns/txt;
	h=From;
	bh=bF8dwco2OpD4jw+50IjUaWbm2lJ2kGH1r7RGZwU0W0U=;
	b=tZ+wKmOMTbZczy4gL36DV6korVrDaOkEMaU77eNpngM0R1q31v2+V3uXwl+/ZcznRLqzPasUl
	eIce1fwk7YKmARooBYj6Lqiw3GAaNlYP/36f2E2tCuWM4AXAFAu9UNw4dtAJP6Ye0pJE5lBixZP
	fRIxJ9kXCs/c6I2hGflDe9Q=
Received: from mail.maildlp.com (unknown [172.19.163.127])
	by canpmsgout11.his.huawei.com (SkyGuard) with ESMTPS id 4htWrY3DnCzKmWP;
	Mon, 28 Sep 2026 14:39:57 +0800 (CST)
Received: from whupemk100010.china.huawei.com (unknown [7.152.184.41])
	by mail.maildlp.com (Postfix) with ESMTPS id 2F7F640572;
	Mon, 28 Sep 2026 14:52:09 +0800 (CST)
Received: from [10.67.109.91] (10.67.109.91) by whupemk100010.china.huawei.com
 (7.152.184.41) with Microsoft SMTP Server (version=TLS1_2,
 cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id 15.2.2562.45; Mon, 28 Sep
 2026 14:52:03 +0800
Message-ID: <a6a40c38-0e1c-4a3f-a705-e4a38c575c25@huawei.com>
Date: Mon, 28 Sep 2026 14:52:02 +0800
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH RFC -next 00/12] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
To: =?UTF-8?Q?G=C3=BCnther_Noack?= <gnoack3000@gmail.com>
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
	<tom@talpey.com>, <miklos@szeredi.hu>, <amir73il@gmail.com>,
	<senozhatsky@chromium.org>, <chenxiaosong@chenxiaosong.com>,
	<zohar@linux.ibm.com>, <roberto.sassu@huawei.com>,
	<dmitry.kasatkin@gmail.com>, <eric.snowberg@oracle.com>,
	<stephen.smalley.work@gmail.com>, <omosnacek@gmail.com>,
	<casey@schaufler-ca.com>, <nanx95726@gmail.com>, <djwong@kernel.org>,
	<daniel@iogearbox.net>, <linux-security-module@vger.kernel.org>,
	<linux-doc@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<driver-core@lists.linux.dev>, <linux-block@vger.kernel.org>,
	<linux-fsdevel@vger.kernel.org>, <netfs@lists.linux.dev>,
	<ecryptfs@vger.kernel.org>, <exfat@lists.linux.dev>,
	<linux-nfs@vger.kernel.org>, <linux-unionfs@vger.kernel.org>,
	<linux-cifs@vger.kernel.org>, <linux-integrity@vger.kernel.org>,
	<selinux@vger.kernel.org>, <linux-kselftest@vger.kernel.org>,
	<xiujianfeng@huawei.com>, <lujialin4@huawei.com>, <bpf@vger.kernel.org>,
	<kpsingh@kernel.org>, <matt@bobrowski.net>, <alexei.starovoitov@gmail.com>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
 <20260926.e0135fe7712f@gnoack.org>
Content-Language: en-US
From: Cai Xinchen <caixinchen1@huawei.com>
In-Reply-To: <20260926.e0135fe7712f@gnoack.org>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 8bit
X-ClientProxiedBy: kwepems100001.china.huawei.com (7.221.188.238) To
 whupemk100010.china.huawei.com (7.152.184.41)

Thank you for review!

I will link the feature request
(https://github.com/landlock-lsm/linux/issues/11) in the v2 cover letter.

For https://github.com/landlock-lsm/linux/issues/18, the current
READ_METADATA cannot solve this problem, and I don't have a good idea 
for now.

For path_* rename, I'd rather keep the inode_* names:

* There is precedent for the mismatch: the inode_getattr hook
   upstream already takes a "const struct path *" (this series just
   aligns the other metadata hooks with it).

* The path_* prefix has an established meaning in the LSM hook
   interface: it denotes the pathname-based (TOMOYO/AppArmor-style)
   hooks that are invoked at the VFS path level *before* the
   corresponding inode_* hook, as a paired, duplicate check
   serving a different class of LSMs.  For example, a chmod(2)
   currently runs security_path_chmod() (fs/open.c, for TOMOYO and
   AppArmor) and then, via notify_change(),
   security_inode_setattr() (for SELinux, Smack and now Landlock);
   vfs_mknod() similarly calls both security_path_mknod() and
   security_inode_mknod().  Renaming inode_setattr to
   path_setattr would put two path_-prefixed hooks with different
   call contracts into the same syscall, and path_chown(path,
   uid, gid) next to a path_setattr(path, attr) would read as a
   redundant pair, even though they belong to different hook
   families.  Landlock itself already uses the path_* family for
   its real path-level hooks (e.g. path_truncate for the TRUNCATE
   right), so mixing renamed inode hooks into that prefix would
   also blur its own hook table.

* If the consensus is that these hooks should be renamed, I think
   that should be a standalone, tree-wide rename series (including
   inode_getattr), so that BPF programs only break once instead of
   twice.

On 9/26/2026 4:27 PM, Günther Noack wrote:
> On Thu, Sep 24, 2026 at 06:48:19PM +0800, Cai Xinchen wrote:
>> This series adds two new Landlock filesystem access rights,
>> LANDLOCK_ACCESS_FS_READ_METADATA and LANDLOCK_ACCESS_FS_WRITE_METADATA,
>> which control access to file and directory metadata such as inode
>> attributes (mode, ownership, timestamps), extended attributes and POSIX
>> ACLs.  It picks up the work from the "landlock: add chmod and chown
>> support" series [1] and follows the coarse-grained grouping discussed in
>> that thread [2]: instead of separate chmod/chown rights, metadata
>> operations are grouped into one read and one write right.
>>
>> Landlock evaluates access rights on a per-path basis, but the metadata
>> related LSM hooks (inode_getattr, inode_setattr, inode_setxattr,
>> inode_getxattr, inode_listxattr, inode_removexattr, inode_set_acl,
>> inode_get_acl, inode_remove_acl) only receive the dentry of the accessed
>> object.  Patches 1-7 therefore first pass struct path instead of dentry
>> through the metadata-related VFS helpers and LSM hooks.  This is a pure
>> refactoring with no behavior change, split so that every patch builds
>> and works on its own:
>>
>>    1: notify_change() and its callers
>>    2: inode_setsecctx hook (must come before 3: the SELinux and Smack
>>       implementations call __vfs_setxattr_locked internally)
>>    3: xattr helpers, which also drops a redundant EVM xattr size sanity
>>       check whose vfs_getxattr() call only has a dentry and therefore
>>       cannot be migrated to the new path-based signature
>>    4: POSIX ACL helpers
>>    5: inode_setattr hook
>>    6: inode xattr hooks
>>    7: inode POSIX ACL hooks
>>
>> Two deliberate scoping decisions for this refactor:
>>
>> - The hooks consistently take struct path rather than struct file.  The
>>    VFS call sites involved (chmod(2), chown(2), utimensat(2), xattr(2)
>>    and ACL syscalls) operate on paths, and several of them (lstat(2),
>>    lchown(2), llistxattr(2), ...) have no struct file to begin with.
>>
>> - struct inode_operations->setattr still receives (idmap, dentry, attr).
>>    Only the VFS boundary (notify_change()) and the LSM hook layer see the
>>    path, which keeps the refactor contained to fs/attr.c and the LSM
>>    infrastructure instead of touching every filesystem.
>>
>> Patches 8-12 then implement the new rights, their tests, the sandboxer
>> sample and the documentation.  Semantics:
>>
>> - READ_METADATA covers stat(2) and friends, getxattr(2) and friends,
>>    listxattr(2) and friends, and POSIX ACL reads.
>> - WRITE_METADATA covers chmod(2), chown(2), utimensat(2), setxattr(2),
>>    removexattr(2) and friends, and POSIX ACL set and remove.
>> - Only explicit metadata changes requested by user space are restricted.
>>    Implicit changes performed by the kernel (e.g. timestamp updates on
>>    write(2), size changes on truncate(2)) are not, and neither are
>>    chmod(2)/chown(2) calls that change nothing (e.g. chown(2) with
>>    (-1, -1), which never reaches the hook), matching the SELinux
>>    inode_setattr behavior.
>> - Kernel-internal accesses performed with override_creds() (e.g.
>>    overlayfs, cachefiles) and kernel threads without a Landlock domain
>>    (e.g. nfsd, ksmbd) are not restricted.
>>
>> The Landlock ABI version is incremented from 11 to 12.
>>
>> The series is based on linux-next commit 5c4d4169604b ("Add linux-next
>> specific files for 20260921").
>>
>> Testing: each patch has been built for aarch64 (gcc, -Werror) and the
>> landlock selftests (445 tests, including the new ones) pass in QEMU on
>> aarch64; base_test reports ABI v12.
>>
>> [1] https://lore.kernel.org/all/20220827111215.131442-1-xiujianfeng@huawei.com/
>> [2] https://lore.kernel.org/all/abc960a1-e66e-792e-6869-cfd201c29dbe@digikod.net/
> Thank you for sending this patch set!
>
> Some meta-remarks at the beginning:
>
> * You might want to link the bugtracker feature request:
>    https://github.com/landlock-lsm/linux/issues/11
> * In the final version, I think it's preferred to merge patches 8
>    (adding the access right enums) and 9 (adding the LSM hooks that use
>    them).  Having the feature as an atomic commit makes it harder to
>    accidentally mess it up during a backport, because you can't patch 8
>    without 9.
> * As Paul alluded to, the changes to the LSM hook interface and to the
>    existing callers in VFS are likely the hardest part of this patch
>    set.  Alexei from the BPF subsystem has also reiterated recently
>    that he wants BPF to be looped into such changes.  BPF hooks do not
>    give the same backwards compatibility guarantees as the syscall
>    layer, but there are existing users of LSM hooks specifically
>    through the BPF LSM.
>
> * In https://github.com/landlock-lsm/linux/issues/18, we came across
>    statfs(), which returns file system meta-information based for the
>    file system that a given file belongs to.  I have weak confidence
>    that READ_METADATA would be the right access right to protect this
>    with, but it's a somewhat related operation.  Maybe you have some
>    thoughts on this?
>
> More concrete questions:
>
> * If a "inode" LSM hook gets a "path" argument now, should it be
>    renamed from "inode_..." to "path_..."?
>
>    (Maybe the BPF people can chime in about to what extent that would
>    cause additional churn for BPF users, in a situation where they
>    anyway already need to make a change due to the changing function
>    signature?)
>
> –Günther
