Received: from smtp-190d.mail.infomaniak.ch (smtp-190d.mail.infomaniak.ch [185.125.25.13])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 567A24EA380
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 19:47:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=185.125.25.13
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790624849; cv=none; b=ejVc+uKSnjPSKtqcgbI7omijBTHngGnBWyfrWrj3jK+qYiJAC1kmYDnaSSFAN9YfhsZgjv8FXcugQQn1GlU6kKiVoM812IH9HTzvSJx2PE44LSJlinGvOrzSP8zNq0o67Vnn10DDnKHm1vt4mD3NYXWFNkARaSbvKjCraPT9wqk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790624849; c=relaxed/simple;
	bh=U+kqju76cNoJQVhw6/DyvDJkrDhq+++/O9NLhBaWyAU=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=KcPoINpmosPhRJ08PXcFMg8vWICe+rGjEpBSLmO0wNi+CzFBwQrK5iauvva1uKXfj6mWkoY+KkYPSbeAnDZaUKxQkL+rEfv57cFTAofbuphlys2BxunKlV2SikInu3NJtYQ6Wp4mBmq6ylGWPpMxFZNwRW8fvzGxsf220nrpU+g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=digikod.net; spf=pass smtp.mailfrom=digikod.net; dkim=pass (1024-bit key) header.d=digikod.net header.i=@digikod.net header.b=kxjEERuW; arc=none smtp.client-ip=185.125.25.13
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=digikod.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=digikod.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=digikod.net header.i=@digikod.net header.b="kxjEERuW"
Received: from smtp-3-0001.mail.infomaniak.ch (smtp-3-0001.mail.infomaniak.ch [10.4.36.108])
	by smtp-4-3000.mail.infomaniak.ch (Postfix) with ESMTPS id 4htsK66KK9zghY;
	Mon, 28 Sep 2026 21:47:22 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=digikod.net;
	s=20191114; t=1790624842;
	bh=+VdTVqBVlfaHaioRFQvSt61ywqOeh3oyx/gpUYheHVw=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=kxjEERuWtRNOkoKYbnyFMJQOilbAHdkBxlSQMMZMvjbqPrsq2eMZbZvAL/F1Lg8wr
	 hZmXb9TizZwTXzGEERZSbI2gk8zdZKkYDQsk+a7k5MydGnxkPjmDiTH92dVoV3de77
	 Dqw46RQmrVe5y7Ys5yBJNPv2q4pSUH00ZdtLOuvg=
Received: from unknown by smtp-3-0001.mail.infomaniak.ch (Postfix) with ESMTPA id 4htsJl14b7z2g4;
	Mon, 28 Sep 2026 21:47:03 +0200 (CEST)
Date: Mon, 28 Sep 2026 21:46:59 +0200
From: =?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?= <mic@digikod.net>
To: Cai Xinchen <caixinchen1@huawei.com>
Cc: =?utf-8?Q?G=C3=BCnther?= Noack <gnoack3000@gmail.com>, 
	gnoack@google.com, paul@paul-moore.com, jmorris@namei.org, serge@hallyn.com, 
	corbet@lwn.net, skhan@linuxfoundation.org, rdunlap@infradead.org, 
	gregkh@linuxfoundation.org, rafael@kernel.org, dakr@kernel.org, dlemoal@kernel.org, 
	hch@lst.de, axboe@kernel.dk, viro@zeniv.linux.org.uk, brauner@kernel.org, 
	jack@suse.cz, dhowells@redhat.com, code@tyhicks.com, linkinjeon@kernel.org, 
	sj1557.seo@samsung.com, yuezhang.mo@sony.com, hirofumi@mail.parknet.co.jp, 
	cel@kernel.org, jlayton@kernel.org, neil@brown.name, okorniev@redhat.com, 
	Dai.Ngo@oracle.com, tom@talpey.com, miklos@szeredi.hu, amir73il@gmail.com, 
	senozhatsky@chromium.org, chenxiaosong@chenxiaosong.com, zohar@linux.ibm.com, 
	roberto.sassu@huawei.com, dmitry.kasatkin@gmail.com, eric.snowberg@oracle.com, 
	stephen.smalley.work@gmail.com, omosnacek@gmail.com, casey@schaufler-ca.com, nanx95726@gmail.com, 
	djwong@kernel.org, daniel@iogearbox.net, linux-security-module@vger.kernel.org, 
	linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, driver-core@lists.linux.dev, 
	linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, netfs@lists.linux.dev, 
	ecryptfs@vger.kernel.org, exfat@lists.linux.dev, linux-nfs@vger.kernel.org, 
	linux-unionfs@vger.kernel.org, linux-cifs@vger.kernel.org, linux-integrity@vger.kernel.org, 
	selinux@vger.kernel.org, linux-kselftest@vger.kernel.org, xiujianfeng@huawei.com, 
	lujialin4@huawei.com, bpf@vger.kernel.org, kpsingh@kernel.org, matt@bobrowski.net, 
	alexei.starovoitov@gmail.com
Subject: Re: [PATCH RFC -next 00/12] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
Message-ID: <20260928.phei6Ohmeiba@digikod.net>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
 <20260926.e0135fe7712f@gnoack.org>
 <a6a40c38-0e1c-4a3f-a705-e4a38c575c25@huawei.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <a6a40c38-0e1c-4a3f-a705-e4a38c575c25@huawei.com>
X-Infomaniak-Routing: alpha

Thank for this patch series!

I'll send more reviews tomorrow, but in the meantime here are some
answers:

On Mon, Sep 28, 2026 at 02:52:02PM +0800, Cai Xinchen wrote:
> Thank you for review!
> 
> I will link the feature request
> (https://github.com/landlock-lsm/linux/issues/11) in the v2 cover letter.
> 
> For https://github.com/landlock-lsm/linux/issues/18, the current
> READ_METADATA cannot solve this problem, and I don't have a good idea for
> now.
> 
> For path_* rename, I'd rather keep the inode_* names:
> 
> * There is precedent for the mismatch: the inode_getattr hook
>   upstream already takes a "const struct path *" (this series just
>   aligns the other metadata hooks with it).
> 
> * The path_* prefix has an established meaning in the LSM hook
>   interface: it denotes the pathname-based (TOMOYO/AppArmor-style)
>   hooks that are invoked at the VFS path level *before* the
>   corresponding inode_* hook, as a paired, duplicate check
>   serving a different class of LSMs.  For example, a chmod(2)
>   currently runs security_path_chmod() (fs/open.c, for TOMOYO and
>   AppArmor) and then, via notify_change(),
>   security_inode_setattr() (for SELinux, Smack and now Landlock);
>   vfs_mknod() similarly calls both security_path_mknod() and
>   security_inode_mknod().  Renaming inode_setattr to
>   path_setattr would put two path_-prefixed hooks with different
>   call contracts into the same syscall, and path_chown(path,
>   uid, gid) next to a path_setattr(path, attr) would read as a
>   redundant pair, even though they belong to different hook
>   families.  Landlock itself already uses the path_* family for
>   its real path-level hooks (e.g. path_truncate for the TRUNCATE
>   right), so mixing renamed inode hooks into that prefix would
>   also blur its own hook table.

I had the same though as Günther on this, but I'll leave that up to
Paul.

Regarding the BPF LSM use case, I don't think it would make a big
difference.  Anyway, some BPF selftests need to be updated at the same
time, which will also make the changes clear to the BPF folks.

> 
> * If the consensus is that these hooks should be renamed, I think
>   that should be a standalone, tree-wide rename series (including
>   inode_getattr), so that BPF programs only break once instead of
>   twice.

As a general rule, please create bisectable patches (e.g. any patch must
pass BPF and Landlock selftests; all dependent kernel code must build).
But new tests still deserve their own patches.

> 
> On 9/26/2026 4:27 PM, Günther Noack wrote:
> > On Thu, Sep 24, 2026 at 06:48:19PM +0800, Cai Xinchen wrote:
> > > This series adds two new Landlock filesystem access rights,
> > > LANDLOCK_ACCESS_FS_READ_METADATA and LANDLOCK_ACCESS_FS_WRITE_METADATA,
> > > which control access to file and directory metadata such as inode
> > > attributes (mode, ownership, timestamps), extended attributes and POSIX
> > > ACLs.  It picks up the work from the "landlock: add chmod and chown
> > > support" series [1] and follows the coarse-grained grouping discussed in
> > > that thread [2]: instead of separate chmod/chown rights, metadata
> > > operations are grouped into one read and one write right.
> > > 
> > > Landlock evaluates access rights on a per-path basis, but the metadata
> > > related LSM hooks (inode_getattr, inode_setattr, inode_setxattr,
> > > inode_getxattr, inode_listxattr, inode_removexattr, inode_set_acl,
> > > inode_get_acl, inode_remove_acl) only receive the dentry of the accessed
> > > object.  Patches 1-7 therefore first pass struct path instead of dentry
> > > through the metadata-related VFS helpers and LSM hooks.  This is a pure
> > > refactoring with no behavior change, split so that every patch builds
> > > and works on its own:
> > > 
> > >    1: notify_change() and its callers
> > >    2: inode_setsecctx hook (must come before 3: the SELinux and Smack
> > >       implementations call __vfs_setxattr_locked internally)
> > >    3: xattr helpers, which also drops a redundant EVM xattr size sanity
> > >       check whose vfs_getxattr() call only has a dentry and therefore
> > >       cannot be migrated to the new path-based signature
> > >    4: POSIX ACL helpers
> > >    5: inode_setattr hook
> > >    6: inode xattr hooks
> > >    7: inode POSIX ACL hooks
> > > 
> > > Two deliberate scoping decisions for this refactor:
> > > 
> > > - The hooks consistently take struct path rather than struct file.  The
> > >    VFS call sites involved (chmod(2), chown(2), utimensat(2), xattr(2)
> > >    and ACL syscalls) operate on paths, and several of them (lstat(2),
> > >    lchown(2), llistxattr(2), ...) have no struct file to begin with.
> > > 
> > > - struct inode_operations->setattr still receives (idmap, dentry, attr).
> > >    Only the VFS boundary (notify_change()) and the LSM hook layer see the
> > >    path, which keeps the refactor contained to fs/attr.c and the LSM
> > >    infrastructure instead of touching every filesystem.
> > > 
> > > Patches 8-12 then implement the new rights, their tests, the sandboxer
> > > sample and the documentation.  Semantics:
> > > 
> > > - READ_METADATA covers stat(2) and friends, getxattr(2) and friends,
> > >    listxattr(2) and friends, and POSIX ACL reads.
> > > - WRITE_METADATA covers chmod(2), chown(2), utimensat(2), setxattr(2),
> > >    removexattr(2) and friends, and POSIX ACL set and remove.
> > > - Only explicit metadata changes requested by user space are restricted.
> > >    Implicit changes performed by the kernel (e.g. timestamp updates on
> > >    write(2), size changes on truncate(2)) are not, and neither are
> > >    chmod(2)/chown(2) calls that change nothing (e.g. chown(2) with
> > >    (-1, -1), which never reaches the hook), matching the SELinux
> > >    inode_setattr behavior.
> > > - Kernel-internal accesses performed with override_creds() (e.g.
> > >    overlayfs, cachefiles) and kernel threads without a Landlock domain
> > >    (e.g. nfsd, ksmbd) are not restricted.
> > > 
> > > The Landlock ABI version is incremented from 11 to 12.
> > > 
> > > The series is based on linux-next commit 5c4d4169604b ("Add linux-next
> > > specific files for 20260921").
> > > 
> > > Testing: each patch has been built for aarch64 (gcc, -Werror) and the
> > > landlock selftests (445 tests, including the new ones) pass in QEMU on
> > > aarch64; base_test reports ABI v12.
> > > 
> > > [1] https://lore.kernel.org/all/20220827111215.131442-1-xiujianfeng@huawei.com/
> > > [2] https://lore.kernel.org/all/abc960a1-e66e-792e-6869-cfd201c29dbe@digikod.net/
> > Thank you for sending this patch set!
> > 
> > Some meta-remarks at the beginning:
> > 
> > * You might want to link the bugtracker feature request:
> >    https://github.com/landlock-lsm/linux/issues/11
> > * In the final version, I think it's preferred to merge patches 8
> >    (adding the access right enums) and 9 (adding the LSM hooks that use
> >    them).  Having the feature as an atomic commit makes it harder to
> >    accidentally mess it up during a backport, because you can't patch 8
> >    without 9.
> > * As Paul alluded to, the changes to the LSM hook interface and to the
> >    existing callers in VFS are likely the hardest part of this patch
> >    set.  Alexei from the BPF subsystem has also reiterated recently
> >    that he wants BPF to be looped into such changes.  BPF hooks do not
> >    give the same backwards compatibility guarantees as the syscall
> >    layer, but there are existing users of LSM hooks specifically
> >    through the BPF LSM.
> > 
> > * In https://github.com/landlock-lsm/linux/issues/18, we came across
> >    statfs(), which returns file system meta-information based for the
> >    file system that a given file belongs to.  I have weak confidence
> >    that READ_METADATA would be the right access right to protect this
> >    with, but it's a somewhat related operation.  Maybe you have some
> >    thoughts on this?
> > 
> > More concrete questions:
> > 
> > * If a "inode" LSM hook gets a "path" argument now, should it be
> >    renamed from "inode_..." to "path_..."?
> > 
> >    (Maybe the BPF people can chime in about to what extent that would
> >    cause additional churn for BPF users, in a situation where they
> >    anyway already need to make a change due to the changing function
> >    signature?)
> > 
> > –Günther
> 
