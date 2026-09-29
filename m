Received: from smtp-bc0e.mail.infomaniak.ch (smtp-bc0e.mail.infomaniak.ch [45.157.188.14])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 62374550DBA;
	Tue, 29 Sep 2026 18:52:04 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=45.157.188.14
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790707928; cv=none; b=QysDqDXR1wWZb6P0kI1ZibNJ7w4vxL6M21+vcF97cGHgaR0EWpF1Wboui4yCorcfuMqf9CvdIjXjH6DtJkaawOb0FEOKzUAMpBouEkGUaBIwPAUuulzxEjJl9AiH9cJBGYYAa0X03oQCIG8QqZExnCPGHmUZVGQOieL/viWNssk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790707928; c=relaxed/simple;
	bh=XG42HsU/sMqXC+2mZyZtlSTX6jXkUuV0jGL7ftsUi1c=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=FErFM+tdiLTUwM40poEcFNd2bE2qeVKEYaVcjM2crLx/kWt4+ubVBVhEXuclZ/ZOn37FMY3GM9XB/hlxt83YZc4nJCSrMqNc5YB0b0I1OogNLenAKGxLzh/TCkzK2cVYfgYqPV/uBR5Uu7d2JcYQE8h/TLK4SsJfneu6Gv13j7E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=digikod.net; spf=pass smtp.mailfrom=digikod.net; dkim=pass (1024-bit key) header.d=digikod.net header.i=@digikod.net header.b=NmkxKvYY; arc=none smtp.client-ip=45.157.188.14
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=digikod.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=digikod.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=digikod.net header.i=@digikod.net header.b="NmkxKvYY"
Received: from smtp-4-0000.mail.infomaniak.ch (unknown [IPv6:2001:1600:7:10::a6b])
	by smtp-3-3000.mail.infomaniak.ch (Postfix) with ESMTPS id 4hvS2p2m6Sz1CD;
	Tue, 29 Sep 2026 20:52:02 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=digikod.net;
	s=20191114; t=1790707921;
	bh=n8m+1/BomLkKgTbR4X98Agh5NHkdrJRlqsVG38xM61s=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=NmkxKvYY7IAkYpsQSw34+uAQW9dfJv3xKt7fsNkRohVNKzr5oP5BjUWuF2NdOi79t
	 vvs4m9cuI+bBBRuJQAVOoHW1oRrA18o+pALFKcTK6U8VOdF0aQDADis65isVXer8D4
	 UtHi4jAnDX1/It25jO4gSTSKy338JFE41uy/4218=
Received: from unknown by smtp-4-0000.mail.infomaniak.ch (Postfix) with ESMTPA id 4hvS2b4dnJzppl;
	Tue, 29 Sep 2026 20:51:51 +0200 (CEST)
Date: Tue, 29 Sep 2026 20:51:47 +0200
From: =?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?= <mic@digikod.net>
To: Justin Suess <utilityemal77@gmail.com>
Cc: =?utf-8?Q?G=C3=BCnther?= Noack <gnoack@google.com>, 
	=?utf-8?Q?G=C3=BCnther?= Noack <gnoack3000@gmail.com>, Cai Xinchen <caixinchen1@huawei.com>, paul@paul-moore.com, 
	jmorris@namei.org, serge@hallyn.com, corbet@lwn.net, skhan@linuxfoundation.org, 
	rdunlap@infradead.org, gregkh@linuxfoundation.org, rafael@kernel.org, dakr@kernel.org, 
	dlemoal@kernel.org, hch@lst.de, axboe@kernel.dk, viro@zeniv.linux.org.uk, 
	brauner@kernel.org, jack@suse.cz, dhowells@redhat.com, code@tyhicks.com, 
	linkinjeon@kernel.org, sj1557.seo@samsung.com, yuezhang.mo@sony.com, 
	hirofumi@mail.parknet.co.jp, cel@kernel.org, jlayton@kernel.org, neil@brown.name, 
	okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com, miklos@szeredi.hu, 
	amir73il@gmail.com, senozhatsky@chromium.org, chenxiaosong@chenxiaosong.com, 
	zohar@linux.ibm.com, roberto.sassu@huawei.com, dmitry.kasatkin@gmail.com, 
	eric.snowberg@oracle.com, stephen.smalley.work@gmail.com, omosnacek@gmail.com, 
	casey@schaufler-ca.com, nanx95726@gmail.com, djwong@kernel.org, daniel@iogearbox.net, 
	linux-security-module@vger.kernel.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, 
	driver-core@lists.linux.dev, linux-block@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	netfs@lists.linux.dev, ecryptfs@vger.kernel.org, exfat@lists.linux.dev, 
	linux-nfs@vger.kernel.org, linux-unionfs@vger.kernel.org, linux-cifs@vger.kernel.org, 
	linux-integrity@vger.kernel.org, selinux@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	xiujianfeng@huawei.com, lujialin4@huawei.com
Subject: Re: [PATCH RFC -next 00/12] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
Message-ID: <20260929.Ahgoo4yeetai@digikod.net>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
 <araxO4ze0KZBz756@suesslenovo>
 <20260926.255b951d3013@gnoack.org>
 <arqcbjWLN1CLkL_Y@suesslenovo>
 <arurOphe6QIx2Zr8@google.com>
 <arvjb0HJYh1KyEBB@suesslenovo>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <arvjb0HJYh1KyEBB@suesslenovo>
X-Infomaniak-Routing: alpha

On Tue, Sep 29, 2026 at 01:27:44PM -0400, Justin Suess wrote:
> On Tue, Sep 29, 2026 at 02:12:42PM +0200, Günther Noack wrote:
> > On Mon, Sep 28, 2026 at 01:13:35PM -0400, Justin Suess wrote:
> > > On Sat, Sep 26, 2026 at 09:56:28AM +0200, Günther Noack wrote:
> > > > Hello!
> > > > 
> > > > On Fri, Sep 25, 2026 at 02:03:05PM -0400, Justin Suess wrote:
> > > > > On Thu, Sep 24, 2026 at 06:48:19PM +0800, Cai Xinchen wrote:
> > > > > > This series adds two new Landlock filesystem access rights,
> > > > > > LANDLOCK_ACCESS_FS_READ_METADATA and LANDLOCK_ACCESS_FS_WRITE_METADATA,
> > > > > > which control access to file and directory metadata such as inode
> > > > > > attributes (mode, ownership, timestamps), extended attributes and POSIX
> > > > > > ACLs.  It picks up the work from the "landlock: add chmod and chown
> > > > > > support" series [1] and follows the coarse-grained grouping discussed in
> > > > > > that thread [2]: instead of separate chmod/chown rights, metadata
> > > > > > operations are grouped into one read and one write right.
> > > > > > 
> > > > > > Landlock evaluates access rights on a per-path basis, but the metadata
> > > > > > related LSM hooks (inode_getattr, inode_setattr, inode_setxattr,
> > > > > > inode_getxattr, inode_listxattr, inode_removexattr, inode_set_acl,
> > > > > > inode_get_acl, inode_remove_acl) only receive the dentry of the accessed
> > > > > > object.  Patches 1-7 therefore first pass struct path instead of dentry
> > > > > > through the metadata-related VFS helpers and LSM hooks.  This is a pure
> > > > > > refactoring with no behavior change, split so that every patch builds
> > > > > > and works on its own:
> > > > > >
> > > > > I like these patches, but is the ability to read metadata already
> > > > > sorta controlled by LANDLOCK_ACCESS_FS_READ_DIR on the parent
> > > > > directory?
> > > > > 
> > > > > The one case I see this being different is:
> > > > > 
> > > > > 1. if you wanted to grant read access to the file, but not metadata
> > > > > read access, but I can't think of any usecase for being able to read
> > > > > the contents of a file, but not the metadata. (see below)
> > > > > 
> > > > > 2. If you had the absolute path already and didn't need READ_DIR.
> > > > > 
> > > > > I see introducing this READ_METADATA as causing potential
> > > > > hard-to-diagnose issues.
> > > > > 
> > > > > Say you handle READ_METADATA and READ_FILE, but only grant READ_FILE.
> > > > > 
> > > > > The program can technically open the file with the READ_FILE permission,
> > > > > but it may error out because the stat() on it beforehand failed.
> > > > > It's pretty common for programs to do that kind of thing (stat before
> > > > > open), like for checking for config files (strace bash and you see it
> > > > > stat .profile, /etc/profile)
> > > > > 
> > > > > There may be other bugs, because being able to set permissions to read
> > > > > a file *but not read it's metadata* isn't possible currently in posix
> > > > > acl and userspace may not work well if that assumption no longer holds.
> > > > >
> > > * posix acl and linux DAC.
> > > 
> > > > > So maybe WRITE_METADATA is good enough?
> > > > 
> > > > The existing use cases are the combinations of (a) READ_DIR
> > > > allowed/denied and (b) READ_METADATA allowed/denied.  Because these
> > > > two access rights overlap slightly, it seems likely that for a given
> > > > directory or file, users will want to either grant both, or deny both.
> > > > 
> > > > At the moment, where the (not yet existing) READ_METADATA is
> > > > implicitly always allowed, the problematic case is the one where the
> > > > Landlock user wants to deny READ_DIR, but where much of the same
> > > > metadata is still available through stat() and the various
> > > > get-attribute syscalls.  (c.f. the warning box in the Landlock docs
> > > > [1])
> > > > 
> > > > In my view the READ_METADATA right closes a gap that READ_DIR left
> > > > open (which is also potentially surprising to callers if they did not
> > > > read the docs closely).  Also, if its implementation is symmetric to
> > > > WRITE_METADATA, I feel that it's worth having it in the same patch
> > > > set.
> > > > 
> > > > –Günther
> > > > 
> > > > P.S.: I know, even after we can control stat(), there are likely ways
> > > > to infer the presence of a file by observing Landlock error codes.
> > > > This would be nice to fix as well, but is harder to do without
> > > > controlling the path walk itself [2].  But also, the fact that this is
> > > > currently not controllable is not an excuse for leaving READ_METADATA
> > > > open IMHO.
> > > >
> > > I'm still sort of concerned about the case where read access is allowed,
> > > but metadata isn't, due to how many applications will not cleanly handle
> > > such an unexpected condition. You can reproduce this with a seccomp
> > > policy forbidding stat().
> > > 
> > > Would it make sense to have the existing READ rights
> > > (READ_DIR/READ_FILE) imply READ_METADATA on the files/directories 
> > > if READ_METADATA is handled? Reading a file's contents should always
> > > imply that you can read the metadata.
> > 
> > I am wary of situations where the handling of access rights implicity
> > implies other access rights.  We have discussed such schemes in the
> > past (e.g. we considered a design for RESOLVE_UNIX where we'd have
> > both a "scoped" and a "access_fs" right that would interact with each
> > other), but in the end we always settled for approaches where such
> > interactions would not be necessary.  One of the concerns was that it
> > would complicate "best effort" fallback logic in all Landlock
> > libraries and in the countless places where people use the syscalls
> > directly.
> > 
> > To throw another option in the mix.  (To be clear, I have only 70%
> > confidence, so feel free to push back, but it feels like it might
> > work?):
> > 
> > Is this similar to the "truncate" right?
> > ----------------------------------------
> > 
> > With "truncate", there was an existing common operation (open(2) with
> > O_TRUNC, a.k.a. creat(2)) which called the truncation hook and checked
> > for the truncation access right.  But that was in fact OK.  The way we
> > resolved it at the time was by documenting very loudly that WRITE_FILE
> > and TRUNCATE access rights should always be requested in lockstep, if
> > TRUNCATE is handled.
> > 
> > If READ_DIR and READ_FILE do in fact read and return metadata to the
> > user, maybe the right thing would be to do it the same way here and
> > *require* that we have READ_METADATA to do these operations?
> > 
> > (READ_METADATA is automatically allowed as long as it's not handled,
> > so that approach does not break existing programs.  Programs who
> > consciously start handling READ_METADATA must simply take into account
> > that reading directories and opening files for reading requires
> > READ_METADATA.)
> > 
> > (BTW, I can see it for reading directories, but I am not sure I fully
> > follow the argument why opening files for reading means that you can
> > read the metadata?  Can't that be guarded on fstat()-like operations?)
> >
> Many standard libraries will call stat before / after opening a file to
> allocate a buffer matching the file size. Or to figure out if mmap
> is more efficient than opening it directly.
> 
> So Python's open().read() or Go's os.ReadFile they may throw an error
> when opening the file, making it look as if the file is inaccessible
> when its contents are. They make the assumption that if a file is
> readable, the metadata is too.
> 
> There's also a lot of metadata that is already leaked by just having
> READ_FILE. FS_IOC_GETFLAGS/FS_IOC_FSGETXATTR ioctl / fileattr_get are
> unrestrictable and allow you to see inode attributes. There's also
> access(2) which isn't restricted here and allows you to see your rights
> on the file. The size can be found by simply seeking to the beginning
> and end. So much of the metadata is obtainable with just READ_DIR/READ_FILE.
> 
> ...
> 
> Another problem I'm just realizing is that this READ_METADATA
> right is inconsistent with open file descriptor behavior. With most
> rights, already open file descriptors are exempted, but here, fstat,
> (and the other stat-family calls which takes a file descriptor) become
> denied even on already open files. It's a catch 22 here, if you change
> the fstat to not apply to opened files, then READ_FILE becomes a bypass
> for READ_METADATA. But if you leave it as is, then it's inconsistent with
> the other Landlock rights wrt already opened files.

Indeed, these access rights should follow the
LANDLOCK_ACCESS_FS_TRUNCATE mechanic.

> 
> Which isn't the end of the world, but just shows that either
> approach is going to have it's quirks. 
> 
> I think it would be better to just avoid the cat and mouse game here
> of trying to seperate READ_FILE/READ_METADATA and either require
> READ_METADATA be specified with READ_FILE if READ_METADATA is handled
> like Gunther proposed, or have READ_FILE imply READ_METADATA.
> 
> Documenting it strongly is OK too, but really there are really zero
> usecases where you'd want to grant READ_FILE without READ_METADATA
> so it would need to be made extremely clear.

What about a program that just need to read files? We can think about
sanboxes such as those used in web browsers, but that applies to other
tailored processes that don't need/want to access metadata e.g., for
confidentiality or personal information (UID, timestamp) concerns.

This is similar to FILE_WRITE vs. TRUNCATE: most of the time we want
them to be grouped.

> 
> Thanks,
> Justin
> 
> > —Günther
> 
