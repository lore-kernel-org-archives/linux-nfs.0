Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794743271;
	b=BdK9H1y+HNRqD/jOpQfiJ8CK50RxEZMCjwgIS48DNkylfGZf+h7yYt+dLR/rohWShFPk
	 wfY+Vi1XUiR4xQoz/9dl0reIiXKOG5wLW7gkB4jYbbvKAp0onbjRpWAq3h6DDbAxHfbTR
	 5/PaQlaVaf7TtFwba6zsHiW9KlQbLjzo0EerdKKIi48ZFuJLc3WH+ltRAnMLBo+gAqRpL
	 ov61lFfeKEVmTbros4bY5hLqTBfdHKhysZz363XUX2UJKA7MroJWDEdJE++rHrOfqDHYG
	 NlZSY4qxT1OqOgEdTD541oNseZI8+FDCzpXM+gOKg5I+2qmGEiQp5Da0bFa+VHsozfA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794743271;
	h=Received:DKIM-Signature:Date:From:To:Cc:Subject:Message-ID:
	 References:MIME-Version:Content-Type:Content-Disposition:
	 Content-Transfer-Encoding:In-Reply-To;
	bh=dUUoDFkPJkBg6tiiX+gwUNqdlWB0vRGU4J1TlhHh7ZE=;
	b=iuKSIOwNdjXAi2+nKsqu7pIfpzXuLtuj3wXCa1g9MN5BFnFnH+efqOzfUtJXvT2zUGGl
	 V9IfHEzKQzynFa9Fuo1ssXUF+7C+Eoevg9R/uDVp3b207QzEgfuu6a4+z5JoRhmzh2QN0
	 9vJY2NJZgqRfrAE94UuSb7lSNUhcz8q8wGqjWRw5n7k7BXCLYZBSkg22ZgvSiHJnnwpNY
	 2bXzqhTqJYzU82V3hEswRLXZDMXOPwMPocN2bf1yYrFAEINhs1DN1LNIND4gakdX7BwOF
	 /NBQXI11IeC+qk96wRGrOuIRB815lx2fweUabl5k2cTyNpurMwEGTlfjb0o79097iFQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=O5UCROmp;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E5C6D606A32E;
	Sun, 15 Nov 2026 11:47:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=O5UCROmp
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0FF671F000C4;
	Sun, 15 Nov 2026 11:47:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794743270;
	bh=dUUoDFkPJkBg6tiiX+gwUNqdlWB0vRGU4J1TlhHh7ZE=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=O5UCROmpYOxPof//EVMXlzhE8CwpBAuLxySuhjVJTwgdWIcUjDEHfxQDjag+uTRua
	 Z+qDIjnj4mqHBNrUw8Ko1zjkZMcqAeFq8ldvZlzCVbByFB+ptCuml13g6R68XiAcOc
	 tTmUPUcRTu4mDvyiHtXFi/q4pZoMhhtkVDTdv1WqLRxEzoDBelkcsk5jYXJt2EAUob
	 xjg6qsjtw4gR2WGGuYhHVN3Y9VjEoACQTHM3FtneMm5yNVilA99bE1xWageT1rHDiS
	 UNAqlNNFNjgatsQNOofsxEUu3m18tcJw6JldfrHIojxyBAVmlXl979klg5KOmmNJfI
	 Ivyq26TJMKVYg==
Date: Sun, 15 Nov 2026 12:47:41 +0100
From: Christian Brauner <brauner@kernel.org>
To: Amir Goldstein <amir73il@gmail.com>
Cc: Chris Down <chris@chrisdown.name>, linux-fsdevel@vger.kernel.org, 
	Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, 
	Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, linux-block@vger.kernel.org, 
	linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
	target-devel@vger.kernel.org, driver-core@lists.linux.dev, linux-mm@kvack.org, 
	bpf@vger.kernel.org, linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, netdev@vger.kernel.org, 
	fuse-devel@lists.linux.dev, linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
	ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, 
	linux-usb@vger.kernel.org, linux-erofs@lists.ozlabs.org, linux-kselftest@vger.kernel.org
Subject: Re: [PATCH RFC v2 33/42] fs: add file_check_backing()
Message-ID: <20261115-boxen-mundschutz-jacht-0ab871beca58@brauner>
References: <20261114-work-loop-pseudo-v2-0-98639a2286fb@kernel.org>
 <20261114-work-loop-pseudo-v2-33-98639a2286fb@kernel.org>
 <20261114120557.4bc1eb6e57218cdc@chrisdown.name>
 <CAOQ4uxhGxpBtMZ5kfuzR1tQAewiecoX7UjXQRo91QjJHH9T_Yw@mail.gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAOQ4uxhGxpBtMZ5kfuzR1tQAewiecoX7UjXQRo91QjJHH9T_Yw@mail.gmail.com>

On Sun, Nov 15, 2026 at 12:19:57AM +0100, Amir Goldstein wrote:
> On Sat, Nov 14, 2026 at 9:06 PM Chris Down <chris@chrisdown.name> wrote:
> >
> > Hi Christian,
> >
> > Christian Brauner writes:
> > >+      /* Look through stacking filesystems at the inode with the data. */
> > >+      if (d_real_inode(file->f_path.dentry)->i_sb->s_iflags & SB_I_PSEUDO)
> > >+              return -EINVAL;
> >
> > This looks good in general, but what the bots said about O_PATH files
> > here is real. With FMODE_PATH this is reached for a file that was never
> > opened, so on overlayfs nothing has been through ovl_open() to look up
> > the lowerdata of a metacopy file yet. ovl_d_real() then does the lookup
> > itself, and when that fails it hits the WARN(1) at its end and returns
> > the overlayfs dentry, so the check passes as well.
> >
> > Only fuse passes FMODE_PATH, so it takes CAP_SYS_ADMIN to get there, but
> > it's easy to trigger with that. From a quick test with a metacopy file
> > whose redirect into a data-only layer points at nothing, registering an
> > O_PATH fd of it with FUSE_DEV_IOC_BACKING_OPEN gives
> >
> >      ovl_d_real(/f, 0): real dentry not found
> >      WARNING: fs/overlayfs/super.c:79 at ovl_d_real+0xc9/0x210
> >      [...]
> >       file_check_backing+0x308/0x5e0
> >       fuse_backing_new+0x219/0x4a0
> >       fuse_backing_open+0xe8/0x390
> >       fuse_dev_ioctl+0x53a/0x7d0
> >
> > and the ioctl still succeeds. A normal open of that file fails with
> > ENOENT, so nothing could have used it as a backing file anyway, but with
> > panic_on_warn this is now a panic.
> >
> > Maybe ovl_d_real() should just stop warning when the lookup fails, now
> > that it has a caller that isn't trace_uprobe?
> 
> Yeh I guess that this needs to be a Fixes for lazy data lookup.

I have a fix for that.

> The correct fix would be to teach all the callers to deal with an error.

I've also implemented that. It wasn't that hard and it's also a bug. Not
a bad one but still.

> > The check would still pass
> > for an O_PATH file whose lowerdata couldn't be looked up at that point,
> > though.
> 
> One observation relevant to this patch set is that a datadir layer has no
> business being a pseudo fs and that can and should be blocked explicitly
> at overlayfs mount time.

I agree.

> The other observation is that fuse_passthrough_open() should probably
> check the backing_file that was opened for io in addition to checking
> in fuse_backing_open(), which could have different FMODE and specifically
> could be FMODE_PATH.

Sounds good.
