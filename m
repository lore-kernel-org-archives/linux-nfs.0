Received: from mail-yx2-f12.google.com (mail-yx2-f12.google.com [74.125.224.140])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8765851599B
	for <linux-nfs@vger.kernel.org>; Thu,  1 Oct 2026 13:47:51 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.224.140
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790862474; cv=none; b=kacHW8TH1KMs13UPK4dDzfSr3o47cGlt4RWASXBmZUwodpkRxLhIsRK1XSxGLwbBmR/JSoVvreIrgNA+lGi9ahXzEWd7ZIBtEcFAS+7yoc7GumNG9KyEX7tOuxum2xpjluTuE4UpYZf4iCu9IpsOVBFtWjG4fVrqSL/icIpjRGY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790862474; c=relaxed/simple;
	bh=gA8S2Zv1xNNyDX4iYS17032tJpE3+n+24wFdKWnzALg=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=HnxF5CnLXqUDwjAtLa8t/8m2O/VKmCbVblUx5xs64Mf6GgQPczaNL3qZQOjWrDAFibtIIU+qyHo/8tLDb7pQRatc4hBLQtWH/TNbSXth1NunSYA6SEgl7ePX3FhMNDUJ6IdaO+1MpgRjk4TZ65VNgB5b+z4vxNRhzO4XDpPTXeU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=EhaW2OzD; arc=none smtp.client-ip=74.125.224.140
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="EhaW2OzD"
Received: by mail-yx2-f12.google.com with SMTP id 956f58d0204a3-66e4aa8d882so7385152d50.0
        for <linux-nfs@vger.kernel.org>; Thu, 01 Oct 2026 06:47:51 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790862470; x=1791467270; darn=vger.kernel.org;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=CEmshy0XDjhpiyv3Dhm414kHwT2h52SJeHo7PfDF82c=;
        b=EhaW2OzDDRUOCWgEZSKXKYeN+XbP9miocHDfmLQBqGxwkbY7vqDj1q453KkeaWr0eM
         oFPM0Li3SYb6xHlAUiHqk/3UuTgQcZycggAkwMkBP+I+B9YOlraFKXoJlOwt/O4GDamO
         gcnqyHxplgfNNsj0eAt0WP8wOe/3woxe574P6mPYjZq1EHEuXEHazW2qqXgE5g7ROA7x
         /9f4vPvPnNqA1t0UWSirK8Q5M9slbhPNAdZYE3cJnEPmBUGvtOioJjEYp01N8G77E3gJ
         63IjFzZ4F4yI39412ugz0sTPwwEu4RgVdy49ERdhexc9XgYqs37+hWYrpxaeG7FcT5uR
         pvVw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790862470; x=1791467270;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=CEmshy0XDjhpiyv3Dhm414kHwT2h52SJeHo7PfDF82c=;
        b=W2msOgGfjfw4q6AjiQ2gn7+xXn+1+109B5ClJWrfLHRdf54qfFy9pZg6Y4eAChvDL8
         2nhaRTdCKd2fTobzN+jw/LmrSaRuCTldKTvsP8wnU4DvjBWxAEWSD22l0wJEX122DdJe
         WdxcNqi/IqxWbTCd57ZbX1YU8C8mhUnE1B1NdOuk43JhIZ8lte92TcLAgjsGpZhVMlDZ
         pBJVlXKNeSHvrcWP205Ds1i2RiWdEM+Kvyjsqa2ETJPdBwdgf1RkuRe0U7KYHgIrs2jJ
         IMX+VRZcuwABKddjRQ/61EIllaj1FW5Y8tIEq+eXAA40uuxtWNlzIaOCYaruiU1VltqU
         Xawg==
X-Forwarded-Encrypted: i=1; AKwUvBymSdfragOmOsqNCkZcKWax1Djycs1aBKbVPhpfm5L0Cd4Kz2v2i7TqMqzUTjVHrfzdlTsvovvYR4o=@vger.kernel.org
X-Gm-Message-State: AFuF++mx9Re4Vl7Huz5Sjk253AYqCZqA9RDRBJ2JJWvXiWIthbB52SDq
	clxjHf88qbjf1vmXSR5LkpqeIP4ND8GuAJ8aYP4ta3QUPoA5AQCQkKww
X-Gm-Gg: AYBFou0yJj0bpKb7NSFkz4CFOX67M8leiKUR3wxCqaFL12mXIAyyOVoHceAgHX8Y/P/
	CSya4n0alITfnBDP1MBgHfAVaUaubLkwepcWmM70scc7HRyoFLKtkBcmKXBCEIRFyhef3L+KYdb
	3FPsIkeEcC2TuY8ROu2Rg3siM9XELBpB9ikV6KBlF90EEd5Pzb8ZK2GrU8O74yCkdggyJ4ap7u0
	jwMV/K9JRd4LMSuO/17vc+ltAos1/XuU1nh/TxzqpGfyGDVrZ4YWA+CrbYuhK5bWCL/mXaUuVRy
	Qkfsi+HTCzxP4ULzE3rKwApcrschGvrB1kle5aZ8RugyxMuUtzI+/xdnxFRFPpv903JpesiMKq1
	JWOvp3G8HcZbr/J/XschEjNDRFikjREWOTnnjW3gyMJEmdBcpcT6BvsgB9TDlapFKcYTYNmFafv
	AMpuI4bD5XkeC5F+Qxn8FsTC3ZIIj/pMzOECHi838w/YXrRFnm8s6dgZJYrkhRKcwhN7nGG+zlu
	U3B
X-Received: by 2002:a05:690e:ca:b0:675:6e73:fbdd with SMTP id 956f58d0204a3-67683572f34mr1849533d50.88.1790862470241;
        Thu, 01 Oct 2026 06:47:50 -0700 (PDT)
Received: from suesslenovo ([71.132.185.69])
        by smtp.gmail.com with ESMTPSA id 00721157ae682-8acdab5665fsm10834727b3.6.2026.10.01.06.47.48
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 01 Oct 2026 06:47:49 -0700 (PDT)
Date: Thu, 1 Oct 2026 09:47:18 -0400
From: Justin Suess <utilityemal77@gmail.com>
To: =?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?= <mic@digikod.net>
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
Message-ID: <ar5hdxmv2Ohqqxqj@suesslenovo>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
 <araxO4ze0KZBz756@suesslenovo>
 <20260926.255b951d3013@gnoack.org>
 <arqcbjWLN1CLkL_Y@suesslenovo>
 <arurOphe6QIx2Zr8@google.com>
 <arvjb0HJYh1KyEBB@suesslenovo>
 <20260929.Ahgoo4yeetai@digikod.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260929.Ahgoo4yeetai@digikod.net>

On Tue, Sep 29, 2026 at 08:51:47PM +0200, Mickaël Salaün wrote:
> On Tue, Sep 29, 2026 at 01:27:44PM -0400, Justin Suess wrote:
> > On Tue, Sep 29, 2026 at 02:12:42PM +0200, Günther Noack wrote:
> > > On Mon, Sep 28, 2026 at 01:13:35PM -0400, Justin Suess wrote:
> > > > On Sat, Sep 26, 2026 at 09:56:28AM +0200, Günther Noack wrote:
> > > > > Hello!
> > > > > 
> > > > > On Fri, Sep 25, 2026 at 02:03:05PM -0400, Justin Suess wrote:
> > > > > > On Thu, Sep 24, 2026 at 06:48:19PM +0800, Cai Xinchen wrote:
> > > > > > > This series adds two new Landlock filesystem access rights,
> > > > > > > LANDLOCK_ACCESS_FS_READ_METADATA and LANDLOCK_ACCESS_FS_WRITE_METADATA,
> > > > > > > which control access to file and directory metadata such as inode
> > > > > > > attributes (mode, ownership, timestamps), extended attributes and POSIX
> > > > > > > ACLs.  It picks up the work from the "landlock: add chmod and chown
> > > > > > > support" series [1] and follows the coarse-grained grouping discussed in
> > > > > > > that thread [2]: instead of separate chmod/chown rights, metadata
> > > > > > > operations are grouped into one read and one write right.
> > > > > > > 
> > > > > > > Landlock evaluates access rights on a per-path basis, but the metadata
> > > > > > > related LSM hooks (inode_getattr, inode_setattr, inode_setxattr,
> > > > > > > inode_getxattr, inode_listxattr, inode_removexattr, inode_set_acl,
> > > > > > > inode_get_acl, inode_remove_acl) only receive the dentry of the accessed
> > > > > > > object.  Patches 1-7 therefore first pass struct path instead of dentry
> > > > > > > through the metadata-related VFS helpers and LSM hooks.  This is a pure
> > > > > > > refactoring with no behavior change, split so that every patch builds
> > > > > > > and works on its own:
> > > > > > >
> > > > > > I like these patches, but is the ability to read metadata already
> > > > > > sorta controlled by LANDLOCK_ACCESS_FS_READ_DIR on the parent
> > > > > > directory?
> > > > > > 
> > > > > > The one case I see this being different is:
> > > > > > 
> > > > > > 1. if you wanted to grant read access to the file, but not metadata
> > > > > > read access, but I can't think of any usecase for being able to read
> > > > > > the contents of a file, but not the metadata. (see below)
> > > > > > 
> > > > > > 2. If you had the absolute path already and didn't need READ_DIR.
> > > > > > 
> > > > > > I see introducing this READ_METADATA as causing potential
> > > > > > hard-to-diagnose issues.
> > > > > > 
> > > > > > Say you handle READ_METADATA and READ_FILE, but only grant READ_FILE.
> > > > > > 
> > > > > > The program can technically open the file with the READ_FILE permission,
> > > > > > but it may error out because the stat() on it beforehand failed.
> > > > > > It's pretty common for programs to do that kind of thing (stat before
> > > > > > open), like for checking for config files (strace bash and you see it
> > > > > > stat .profile, /etc/profile)
> > > > > > 
> > > > > > There may be other bugs, because being able to set permissions to read
> > > > > > a file *but not read it's metadata* isn't possible currently in posix
> > > > > > acl and userspace may not work well if that assumption no longer holds.
> > > > > >
> > > > * posix acl and linux DAC.
> > > > 
> > > > > > So maybe WRITE_METADATA is good enough?
> > > > > 
> > > > > The existing use cases are the combinations of (a) READ_DIR
> > > > > allowed/denied and (b) READ_METADATA allowed/denied.  Because these
> > > > > two access rights overlap slightly, it seems likely that for a given
> > > > > directory or file, users will want to either grant both, or deny both.
> > > > > 
> > > > > At the moment, where the (not yet existing) READ_METADATA is
> > > > > implicitly always allowed, the problematic case is the one where the
> > > > > Landlock user wants to deny READ_DIR, but where much of the same
> > > > > metadata is still available through stat() and the various
> > > > > get-attribute syscalls.  (c.f. the warning box in the Landlock docs
> > > > > [1])
> > > > > 
> > > > > In my view the READ_METADATA right closes a gap that READ_DIR left
> > > > > open (which is also potentially surprising to callers if they did not
> > > > > read the docs closely).  Also, if its implementation is symmetric to
> > > > > WRITE_METADATA, I feel that it's worth having it in the same patch
> > > > > set.
> > > > > 
> > > > > –Günther
> > > > > 
> > > > > P.S.: I know, even after we can control stat(), there are likely ways
> > > > > to infer the presence of a file by observing Landlock error codes.
> > > > > This would be nice to fix as well, but is harder to do without
> > > > > controlling the path walk itself [2].  But also, the fact that this is
> > > > > currently not controllable is not an excuse for leaving READ_METADATA
> > > > > open IMHO.
> > > > >
> > > > I'm still sort of concerned about the case where read access is allowed,
> > > > but metadata isn't, due to how many applications will not cleanly handle
> > > > such an unexpected condition. You can reproduce this with a seccomp
> > > > policy forbidding stat().
> > > > 
> > > > Would it make sense to have the existing READ rights
> > > > (READ_DIR/READ_FILE) imply READ_METADATA on the files/directories 
> > > > if READ_METADATA is handled? Reading a file's contents should always
> > > > imply that you can read the metadata.
> > > 
> > > I am wary of situations where the handling of access rights implicity
> > > implies other access rights.  We have discussed such schemes in the
> > > past (e.g. we considered a design for RESOLVE_UNIX where we'd have
> > > both a "scoped" and a "access_fs" right that would interact with each
> > > other), but in the end we always settled for approaches where such
> > > interactions would not be necessary.  One of the concerns was that it
> > > would complicate "best effort" fallback logic in all Landlock
> > > libraries and in the countless places where people use the syscalls
> > > directly.
> > > 
> > > To throw another option in the mix.  (To be clear, I have only 70%
> > > confidence, so feel free to push back, but it feels like it might
> > > work?):
> > > 
> > > Is this similar to the "truncate" right?
> > > ----------------------------------------
> > > 
> > > With "truncate", there was an existing common operation (open(2) with
> > > O_TRUNC, a.k.a. creat(2)) which called the truncation hook and checked
> > > for the truncation access right.  But that was in fact OK.  The way we
> > > resolved it at the time was by documenting very loudly that WRITE_FILE
> > > and TRUNCATE access rights should always be requested in lockstep, if
> > > TRUNCATE is handled.
> > > 
> > > If READ_DIR and READ_FILE do in fact read and return metadata to the
> > > user, maybe the right thing would be to do it the same way here and
> > > *require* that we have READ_METADATA to do these operations?
> > > 
> > > (READ_METADATA is automatically allowed as long as it's not handled,
> > > so that approach does not break existing programs.  Programs who
> > > consciously start handling READ_METADATA must simply take into account
> > > that reading directories and opening files for reading requires
> > > READ_METADATA.)
> > > 
> > > (BTW, I can see it for reading directories, but I am not sure I fully
> > > follow the argument why opening files for reading means that you can
> > > read the metadata?  Can't that be guarded on fstat()-like operations?)
> > >
> > Many standard libraries will call stat before / after opening a file to
> > allocate a buffer matching the file size. Or to figure out if mmap
> > is more efficient than opening it directly.
> > 
> > So Python's open().read() or Go's os.ReadFile they may throw an error
> > when opening the file, making it look as if the file is inaccessible
> > when its contents are. They make the assumption that if a file is
> > readable, the metadata is too.
> > 
> > There's also a lot of metadata that is already leaked by just having
> > READ_FILE. FS_IOC_GETFLAGS/FS_IOC_FSGETXATTR ioctl / fileattr_get are
> > unrestrictable and allow you to see inode attributes. There's also
> > access(2) which isn't restricted here and allows you to see your rights
> > on the file. The size can be found by simply seeking to the beginning
> > and end. So much of the metadata is obtainable with just READ_DIR/READ_FILE.
> > 
> > ...
> > 
> > Another problem I'm just realizing is that this READ_METADATA
> > right is inconsistent with open file descriptor behavior. With most
> > rights, already open file descriptors are exempted, but here, fstat,
> > (and the other stat-family calls which takes a file descriptor) become
> > denied even on already open files. It's a catch 22 here, if you change
> > the fstat to not apply to opened files, then READ_FILE becomes a bypass
> > for READ_METADATA. But if you leave it as is, then it's inconsistent with
> > the other Landlock rights wrt already opened files.
> 
> Indeed, these access rights should follow the
> LANDLOCK_ACCESS_FS_TRUNCATE mechanic.
>
Ahh good idea. Forgot about that! So associate the
READ_METADATA right with the fd at open time like with truncate.
> > 
> > Which isn't the end of the world, but just shows that either
> > approach is going to have it's quirks. 
> > 
> > I think it would be better to just avoid the cat and mouse game here
> > of trying to seperate READ_FILE/READ_METADATA and either require
> > READ_METADATA be specified with READ_FILE if READ_METADATA is handled
> > like Gunther proposed, or have READ_FILE imply READ_METADATA.
> > 
> > Documenting it strongly is OK too, but really there are really zero
> > usecases where you'd want to grant READ_FILE without READ_METADATA
> > so it would need to be made extremely clear.
> 
> What about a program that just need to read files? We can think about
> sanboxes such as those used in web browsers, but that applies to other
> tailored processes that don't need/want to access metadata e.g., for
> confidentiality or personal information (UID, timestamp) concerns.
> 
> This is similar to FILE_WRITE vs. TRUNCATE: most of the time we want
> them to be grouped.
> 
Your argument is persuasive :)

I still have open questions about file_getattr(2)
and the FS_* ioctls above, which I don't think are handled by this
READ_METADATA right. access(2) is a seperate question, but I'm
unsure if that's worth it/in scope for restricting.

(I think WRITE_METADTA also doesn't handle file_setattr(2) and
the FS_IOC_FSSETFLAGS ioctls)

Justin
> > 
> > Thanks,
> > Justin
> > 
> > > —Günther
> > 
