Received: from smtp-42ab.mail.infomaniak.ch (smtp-42ab.mail.infomaniak.ch [84.16.66.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5AD564F4CF5
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 19:34:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=84.16.66.171
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790624089; cv=none; b=A5UWVZ19g5KvXQdXxOYlODYme8aI6BLvAVnzCunHf4TJy6jcj1Lh18Vi8Z7dcFMCccCOD3tbum369tCwohzJ8A9n/LRsELYsQ4we1nfk0pFPVPONf5qau9a/HRYnulBXrrO/Nsg7kEwZ2VZlBKO+WEy3rwUy3YkSQhOgyqbx128=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790624089; c=relaxed/simple;
	bh=a/fVDOxXWPf4pRO+JMUIkEs0kESCcu/HaVc7rPzOchg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=e5D4dERUrXrPKQUwhhbSsGkUpExK5qwVllxX3pjtwsBfL910atajD60TLcZAwGkXuSXE7RTmXSRfN3fhCJ4flPVaNgL65gtfcWZ/+W/ON9sjY/uz3OWhMH2Kof+NFGQJwd1+VHUPlMyNn+4B+MH8IhstrnpwRAWDxAjM5rjgKek=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=digikod.net; spf=pass smtp.mailfrom=digikod.net; dkim=pass (1024-bit key) header.d=digikod.net header.i=@digikod.net header.b=sXM4jCYk; arc=none smtp.client-ip=84.16.66.171
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=digikod.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=digikod.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=digikod.net header.i=@digikod.net header.b="sXM4jCYk"
Received: from smtp-3-0001.mail.infomaniak.ch (smtp-3-0001.mail.infomaniak.ch [10.4.36.108])
	by smtp-4-3000.mail.infomaniak.ch (Postfix) with ESMTPS id 4htrrm2xgqzP3d;
	Mon, 28 Sep 2026 21:26:16 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=digikod.net;
	s=20191114; t=1790623575;
	bh=CrjvvaHMWaKYxoFcBUB4DJe92VZuzwdQ8u7IVRkbMcU=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=sXM4jCYkfSMLVOJD3ZTes7bDu0d+mQkq46RD27THmJWjN2OLGRENiHtu/kk3q9MmY
	 1rS3gQ42pIxSGI6Jri5E1rvadGfwYZ013Om7EwYKUsN0PhD4mOifCDvQNxdEVSmMKd
	 jevpWMMN/ZmoE0TF9iizmsTOaz0QYQtwFwzl6pHE=
Received: from unknown by smtp-3-0001.mail.infomaniak.ch (Postfix) with ESMTPA id 4htrrF6HTKzphQ;
	Mon, 28 Sep 2026 21:25:48 +0200 (CEST)
Date: Mon, 28 Sep 2026 21:25:44 +0200
From: =?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?= <mic@digikod.net>
To: Justin Suess <utilityemal77@gmail.com>
Cc: =?utf-8?Q?G=C3=BCnther?= Noack <gnoack3000@gmail.com>, 
	Cai Xinchen <caixinchen1@huawei.com>, gnoack@google.com, paul@paul-moore.com, jmorris@namei.org, 
	serge@hallyn.com, corbet@lwn.net, skhan@linuxfoundation.org, rdunlap@infradead.org, 
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
	lujialin4@huawei.com
Subject: Re: [PATCH RFC -next 00/12] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
Message-ID: <20260928.eithae8Oov4p@digikod.net>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
 <araxO4ze0KZBz756@suesslenovo>
 <20260926.255b951d3013@gnoack.org>
 <arqcbjWLN1CLkL_Y@suesslenovo>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <arqcbjWLN1CLkL_Y@suesslenovo>
X-Infomaniak-Routing: alpha

On Mon, Sep 28, 2026 at 01:13:35PM -0400, Justin Suess wrote:
> On Sat, Sep 26, 2026 at 09:56:28AM +0200, Günther Noack wrote:
> > Hello!
> > 
> > On Fri, Sep 25, 2026 at 02:03:05PM -0400, Justin Suess wrote:
> > > On Thu, Sep 24, 2026 at 06:48:19PM +0800, Cai Xinchen wrote:
> > > > This series adds two new Landlock filesystem access rights,
> > > > LANDLOCK_ACCESS_FS_READ_METADATA and LANDLOCK_ACCESS_FS_WRITE_METADATA,
> > > > which control access to file and directory metadata such as inode
> > > > attributes (mode, ownership, timestamps), extended attributes and POSIX
> > > > ACLs.  It picks up the work from the "landlock: add chmod and chown
> > > > support" series [1] and follows the coarse-grained grouping discussed in
> > > > that thread [2]: instead of separate chmod/chown rights, metadata
> > > > operations are grouped into one read and one write right.
> > > > 
> > > > Landlock evaluates access rights on a per-path basis, but the metadata
> > > > related LSM hooks (inode_getattr, inode_setattr, inode_setxattr,
> > > > inode_getxattr, inode_listxattr, inode_removexattr, inode_set_acl,
> > > > inode_get_acl, inode_remove_acl) only receive the dentry of the accessed
> > > > object.  Patches 1-7 therefore first pass struct path instead of dentry
> > > > through the metadata-related VFS helpers and LSM hooks.  This is a pure
> > > > refactoring with no behavior change, split so that every patch builds
> > > > and works on its own:
> > > >
> > > I like these patches, but is the ability to read metadata already
> > > sorta controlled by LANDLOCK_ACCESS_FS_READ_DIR on the parent
> > > directory?
> > > 
> > > The one case I see this being different is:
> > > 
> > > 1. if you wanted to grant read access to the file, but not metadata
> > > read access, but I can't think of any usecase for being able to read
> > > the contents of a file, but not the metadata. (see below)
> > > 
> > > 2. If you had the absolute path already and didn't need READ_DIR.
> > > 
> > > I see introducing this READ_METADATA as causing potential
> > > hard-to-diagnose issues.
> > > 
> > > Say you handle READ_METADATA and READ_FILE, but only grant READ_FILE.
> > > 
> > > The program can technically open the file with the READ_FILE permission,
> > > but it may error out because the stat() on it beforehand failed.
> > > It's pretty common for programs to do that kind of thing (stat before
> > > open), like for checking for config files (strace bash and you see it
> > > stat .profile, /etc/profile)
> > > 
> > > There may be other bugs, because being able to set permissions to read
> > > a file *but not read it's metadata* isn't possible currently in posix
> > > acl and userspace may not work well if that assumption no longer holds.
> > >
> * posix acl and linux DAC.
> 
> > > So maybe WRITE_METADATA is good enough?
> > 
> > The existing use cases are the combinations of (a) READ_DIR
> > allowed/denied and (b) READ_METADATA allowed/denied.  Because these
> > two access rights overlap slightly, it seems likely that for a given
> > directory or file, users will want to either grant both, or deny both.
> > 
> > At the moment, where the (not yet existing) READ_METADATA is
> > implicitly always allowed, the problematic case is the one where the
> > Landlock user wants to deny READ_DIR, but where much of the same
> > metadata is still available through stat() and the various
> > get-attribute syscalls.  (c.f. the warning box in the Landlock docs
> > [1])
> > 
> > In my view the READ_METADATA right closes a gap that READ_DIR left
> > open (which is also potentially surprising to callers if they did not
> > read the docs closely).  Also, if its implementation is symmetric to
> > WRITE_METADATA, I feel that it's worth having it in the same patch
> > set.
> > 
> > –Günther
> > 
> > P.S.: I know, even after we can control stat(), there are likely ways
> > to infer the presence of a file by observing Landlock error codes.
> > This would be nice to fix as well, but is harder to do without
> > controlling the path walk itself [2].  But also, the fact that this is
> > currently not controllable is not an excuse for leaving READ_METADATA
> > open IMHO.
> >
> I'm still sort of concerned about the case where read access is allowed,
> but metadata isn't, due to how many applications will not cleanly handle
> such an unexpected condition. You can reproduce this with a seccomp
> policy forbidding stat().

I agree that wrong policies could cause userspace to break, but that the
same for any kind of access control/restriction (e.g. your seccomp
example).

This series fill a gap which is to forbid access to metadata.  As for
other kind of access rights, this should be use wisely, and (user space)
libraries can help.

To be able to deny reading or modifying file's attributes, following the
Landlock model means to "handle" the related access rights, and
potentially to add exceptions to that with rules.

Your concern is legitimate and the documentation should warn about this
case (i.e. most of the time, users should tie READ_FILE with
READ_METADATA...).

> 
> Would it make sense to have the existing READ rights
> (READ_DIR/READ_FILE) imply READ_METADATA on the files/directories 
> if READ_METADATA is handled? Reading a file's contents should always
> imply that you can read the metadata.

That would make the kernel code more complex, especially wrt nested
domains.  However, user space libraries/configurations can make that the
default.  Anyway, if user space break with this kind of too strict
policy, I guess it would be quite loud and then fixed quickly.

Also, some tailored user space programs may not need to read metadata.

> 
> Thanks,
> Justin
> > [1] https://docs.kernel.org/userspace-api/landlock.html#filesystem-flags
> > [2] https://github.com/landlock-lsm/linux/issues/9
> 
