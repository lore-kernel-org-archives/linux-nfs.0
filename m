Received: from mail-yx2-f42.google.com (mail-yx2-f42.google.com [74.125.224.170])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 38C434F393D
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 17:14:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.224.170
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790615651; cv=none; b=uUwbiFj/GTitQ57C3vOT17pVxUVs5OlvCLmrHbJgnZKyKeFHn1m3EAXy9Hf1s3aqEZstYDpeNSj0ck7MUyTLnX2SvFtpvilD6P9WmHGh7sfP+ZC0ljVXrURPKjL9M2fdNmP+0/YDlGGiNuO/MioDss22Ap3esbXpzE8m8N2vsRU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790615651; c=relaxed/simple;
	bh=MbYUL73La3phT6CWXVxz3A2hkcPLAKJyAdn49kkRKFc=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=iB09zHJ4HAPI9aDUL0zrCtEv/RT3PSJ9Oy57vrBoHZvlfoU1JMDBRqYpIG1/CMp+MyFraxEMWsSVrFpTDKiQ/bZOyHVDRIZBCsqPWrEgDKfS4pyVi/b1NHPolBT9Dlp0lgktSU7RwvdRxpR02Liisw2QVFxA0na0CgPOkFLEM8M=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com; spf=pass smtp.mailfrom=gmail.com; dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b=DpEt8Q/R; arc=none smtp.client-ip=74.125.224.170
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="DpEt8Q/R"
Received: by mail-yx2-f42.google.com with SMTP id 956f58d0204a3-672ce86b21aso3522353d50.3
        for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 10:14:08 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20251104; t=1790615647; x=1791220447; darn=vger.kernel.org;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:from:to:cc:subject:date:message-id:reply-to:content-type;
        bh=MmJ/EW0KwY0F0cm8LaUC3Fhj6N704NFs3EmzLQEffnQ=;
        b=DpEt8Q/Rtt6CU3VVCy088mlM94gI41xgFL8/OIpF7pLSuO5iZe0mNZsHnYrtDAxXH0
         hJUBdhVhN4oej1WlPQhTfYlrf8FVZLn/Kqq6kzE7jSdpa5rY1Prk7NIoKnPW7z9n+klw
         mWAtVjQboIZziiPgP+TY2Bge/YSusfHHOvkSn59MNZR1OAL3agPO+Lq0bqe90fr4z29l
         BZDEZFONCqNi35OL8P0pUwsiDVQddf++iE7GOXMf2O6JOD4jkWmv+EUpdgqp/9MwXfbE
         bhVWF7vK2Q+15ah7ydijagIGn6QwcNK70wA1I1/gAJIHvjji3tEm5JUboSICRcvCP8nh
         fHZg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1790615647; x=1791220447;
        h=in-reply-to:content-transfer-encoding:content-disposition
         :content-type:mime-version:references:message-id:subject:cc:to:from
         :date:x-gm-gg:x-gm-message-state:from:to:cc:subject:date:message-id
         :reply-to:content-type;
        bh=MmJ/EW0KwY0F0cm8LaUC3Fhj6N704NFs3EmzLQEffnQ=;
        b=RQYplfxxQ0uYlTavn3Q0gVLZXc52Hb2qUPPG4i4R84pNT0iEHQvvDGxY4aceWSxdDQ
         CHsI98XQ+fkyhIQNZJXjbwCTzVbo0+NdNnnc3o3iGTdwkb6UQeED7fgGMYZPELUnk/55
         jVzZ78GgImEc4CJadKEA3F/QP3VRvccIWjVA+rQcfwbp9NvnxqkT79qEvWg1Vx86rynR
         hezNNA3nlb2hldWiBdLcpALyY5QDXVB54hnEAY6jH3H83rEkEQZVdtF2nOLzicc9B3Vc
         kYwfVTAE0VJK/gJWxV/k0WO7bdZcTG4xpeTN612HOPiGeyXTn6QKI2fJY5qFb7hgQfCu
         dWvQ==
X-Forwarded-Encrypted: i=1; AKwUvBywG7pPS88EbwrlgTAHyywNGY/akYWqDexk5BWn6XmuU6wO680FSYFm6pm+bBj7UF8yfIh8G6TyBpk=@vger.kernel.org
X-Gm-Message-State: AFq9FYJe8MmYIIv6aweJQY4I99ij5usCuYagrtuxdxoYkNV4j3GBIOqS
	o7t7DXWVeTDTHdYge/9emNibx5odBQ9Sfw5FPeQsXfFrqOXqA+Bp+/Q3
X-Gm-Gg: AYBFou0lahD4HfRiA/+3HkHiVwR04jfKuHplkW8lci5um8QlOyOqi22qv+WNzffe2q7
	WB3KjEWHSQCg46QKURtcKQKD3gGOiCB+f/6u4lTosMOdAZFfRBnA0N3Wn1rQZ/tzVgVkjS3Da7z
	PxJ+aZbWzKWl/dN4ggDiZfqRmWBo3RVx9Cr9Vb0sv6k2DAAOq0CiNTA3r/hx9SVXPzk9NcYAHj5
	TiNfJ8jXasRP6GOlemaiA076V55NhT0pW8AyS1vY8JQVHtNTCMedWkUTaXmzGzs/NTVeY71gjWP
	CdZzJABg0a8x2xFuyO0k/iWvC63s0Z5b16HVKZsYpx0PzaSIJGYYJtq+P4DADy1Dg/BpTKxuliE
	igGsNeJV56lzuJPQFwWuEY4xfcl2aRj8/hQS+KY6GKRpUsjYcXuZuw0D2U9qZiFo79c/eizC/O7
	7JV5ebHbc1iwSWdjYYmdWEOwvqCiGpeCmCDpnHWWotGQO8njkCu5cJVKiGi0Y1Wd7Bs/5/DlFL9
	4w=
X-Received: by 2002:a53:ac98:0:b0:671:1398:648d with SMTP id 956f58d0204a3-674111a8a77mr3399078d50.9.1790615647178;
        Mon, 28 Sep 2026 10:14:07 -0700 (PDT)
Received: from suesslenovo ([71.132.185.69])
        by smtp.gmail.com with ESMTPSA id 956f58d0204a3-6740ee940a0sm4752038d50.3.2026.09.28.10.14.06
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Mon, 28 Sep 2026 10:14:06 -0700 (PDT)
Date: Mon, 28 Sep 2026 13:13:35 -0400
From: Justin Suess <utilityemal77@gmail.com>
To: =?utf-8?Q?G=C3=BCnther?= Noack <gnoack3000@gmail.com>
Cc: Cai Xinchen <caixinchen1@huawei.com>, mic@digikod.net, 
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
	lujialin4@huawei.com
Subject: Re: [PATCH RFC -next 00/12] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
Message-ID: <arqcbjWLN1CLkL_Y@suesslenovo>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
 <araxO4ze0KZBz756@suesslenovo>
 <20260926.255b951d3013@gnoack.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20260926.255b951d3013@gnoack.org>

On Sat, Sep 26, 2026 at 09:56:28AM +0200, Günther Noack wrote:
> Hello!
> 
> On Fri, Sep 25, 2026 at 02:03:05PM -0400, Justin Suess wrote:
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
> > I like these patches, but is the ability to read metadata already
> > sorta controlled by LANDLOCK_ACCESS_FS_READ_DIR on the parent
> > directory?
> > 
> > The one case I see this being different is:
> > 
> > 1. if you wanted to grant read access to the file, but not metadata
> > read access, but I can't think of any usecase for being able to read
> > the contents of a file, but not the metadata. (see below)
> > 
> > 2. If you had the absolute path already and didn't need READ_DIR.
> > 
> > I see introducing this READ_METADATA as causing potential
> > hard-to-diagnose issues.
> > 
> > Say you handle READ_METADATA and READ_FILE, but only grant READ_FILE.
> > 
> > The program can technically open the file with the READ_FILE permission,
> > but it may error out because the stat() on it beforehand failed.
> > It's pretty common for programs to do that kind of thing (stat before
> > open), like for checking for config files (strace bash and you see it
> > stat .profile, /etc/profile)
> > 
> > There may be other bugs, because being able to set permissions to read
> > a file *but not read it's metadata* isn't possible currently in posix
> > acl and userspace may not work well if that assumption no longer holds.
> >
* posix acl and linux DAC.

> > So maybe WRITE_METADATA is good enough?
> 
> The existing use cases are the combinations of (a) READ_DIR
> allowed/denied and (b) READ_METADATA allowed/denied.  Because these
> two access rights overlap slightly, it seems likely that for a given
> directory or file, users will want to either grant both, or deny both.
> 
> At the moment, where the (not yet existing) READ_METADATA is
> implicitly always allowed, the problematic case is the one where the
> Landlock user wants to deny READ_DIR, but where much of the same
> metadata is still available through stat() and the various
> get-attribute syscalls.  (c.f. the warning box in the Landlock docs
> [1])
> 
> In my view the READ_METADATA right closes a gap that READ_DIR left
> open (which is also potentially surprising to callers if they did not
> read the docs closely).  Also, if its implementation is symmetric to
> WRITE_METADATA, I feel that it's worth having it in the same patch
> set.
> 
> –Günther
> 
> P.S.: I know, even after we can control stat(), there are likely ways
> to infer the presence of a file by observing Landlock error codes.
> This would be nice to fix as well, but is harder to do without
> controlling the path walk itself [2].  But also, the fact that this is
> currently not controllable is not an excuse for leaving READ_METADATA
> open IMHO.
>
I'm still sort of concerned about the case where read access is allowed,
but metadata isn't, due to how many applications will not cleanly handle
such an unexpected condition. You can reproduce this with a seccomp
policy forbidding stat().

Would it make sense to have the existing READ rights
(READ_DIR/READ_FILE) imply READ_METADATA on the files/directories 
if READ_METADATA is handled? Reading a file's contents should always
imply that you can read the metadata.

Thanks,
Justin
> [1] https://docs.kernel.org/userspace-api/landlock.html#filesystem-flags
> [2] https://github.com/landlock-lsm/linux/issues/9
