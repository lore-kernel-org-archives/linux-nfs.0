Received: from smtp-42a8.mail.infomaniak.ch (smtp-42a8.mail.infomaniak.ch [84.16.66.168])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 805364F393F
	for <linux-nfs@vger.kernel.org>; Mon, 28 Sep 2026 19:27:33 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=84.16.66.168
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790623659; cv=none; b=EjM99wDyv9lMcXYDQiq+/RGCHp1p4bh/4xXTeSdehF2T+EwTVqTp/nbMrzrbYjHcvjWbOAc2JQR5K61RkfDungaJU73ydmm65UEZc/cyvbBRhMnhP8vzmUp7dsUf4VEgvRccIayZ3DL7QCCUyB+SzUpZwXg+FvjG3z4otZ3x+f0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790623659; c=relaxed/simple;
	bh=6xjVniVqjCHQFLrGCtk5qdSMV8MBrax8j4hWdoPd8DQ=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=W0+ZB3nDXSE8cy3ZM2uZK+SEom9HPDGygSzJb+kC/E+eTsbGCLuWROoMozG/AXxjdFJRqCKheC5qaVmSTrsI6gOyfFtz1L6LzjJDwS/FeJaqUJuPhY65tym8syBISxmQJH5MwHElEVKFQOw7W9K1WRdm41UByQ5GmyQgQbI/Ubo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=digikod.net; spf=pass smtp.mailfrom=digikod.net; dkim=pass (1024-bit key) header.d=digikod.net header.i=@digikod.net header.b=XbYx7UpK; arc=none smtp.client-ip=84.16.66.168
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=digikod.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=digikod.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=digikod.net header.i=@digikod.net header.b="XbYx7UpK"
Received: from smtp-3-0001.mail.infomaniak.ch (unknown [IPv6:2001:1600:4:17::246c])
	by smtp-3-3000.mail.infomaniak.ch (Postfix) with ESMTPS id 4htrt961L4zKGc;
	Mon, 28 Sep 2026 21:27:29 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=digikod.net;
	s=20191114; t=1790623649;
	bh=s0iu/y58ex5jQf0shyHgJjsvS0d1Pn766Y0myLp/xWs=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=XbYx7UpKkMU0wm+KNQybv/OEFEaH0br6LrTI8dSkxuh90XrfPNQFZ/5WikB6GEMFr
	 /VOWAHZSUMgt/xHir7wC70zrnSC/j6vhhfJ/b+tyq9zM51hHDimhBq8n1PiZNuninl
	 aJhDsVxnrpvaxGqk9OW8pn9pXXG0JzgD1sJNwMps=
Received: from unknown by smtp-3-0001.mail.infomaniak.ch (Postfix) with ESMTPA id 4htrt61NwlzvBM;
	Mon, 28 Sep 2026 21:27:26 +0200 (CEST)
Date: Mon, 28 Sep 2026 21:27:25 +0200
From: =?utf-8?Q?Micka=C3=ABl_Sala=C3=BCn?= <mic@digikod.net>
To: Paul Moore <paul@paul-moore.com>
Cc: Christian Brauner <brauner@kernel.org>, 
	Cai Xinchen <caixinchen1@huawei.com>, gnoack@google.com, jmorris@namei.org, serge@hallyn.com, 
	corbet@lwn.net, skhan@linuxfoundation.org, rdunlap@infradead.org, 
	gregkh@linuxfoundation.org, rafael@kernel.org, dakr@kernel.org, dlemoal@kernel.org, 
	hch@lst.de, axboe@kernel.dk, viro@zeniv.linux.org.uk, jack@suse.cz, 
	dhowells@redhat.com, code@tyhicks.com, linkinjeon@kernel.org, sj1557.seo@samsung.com, 
	yuezhang.mo@sony.com, hirofumi@mail.parknet.co.jp, cel@kernel.org, jlayton@kernel.org, 
	neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com, 
	miklos@szeredi.hu, amir73il@gmail.com, senozhatsky@chromium.org, 
	chenxiaosong@chenxiaosong.com, zohar@linux.ibm.com, roberto.sassu@huawei.com, 
	dmitry.kasatkin@gmail.com, eric.snowberg@oracle.com, stephen.smalley.work@gmail.com, 
	omosnacek@gmail.com, casey@schaufler-ca.com, nanx95726@gmail.com, djwong@kernel.org, 
	daniel@iogearbox.net, linux-security-module@vger.kernel.org, linux-doc@vger.kernel.org, 
	linux-kernel@vger.kernel.org, driver-core@lists.linux.dev, linux-block@vger.kernel.org, 
	linux-fsdevel@vger.kernel.org, netfs@lists.linux.dev, ecryptfs@vger.kernel.org, 
	exfat@lists.linux.dev, linux-nfs@vger.kernel.org, linux-unionfs@vger.kernel.org, 
	linux-cifs@vger.kernel.org, linux-integrity@vger.kernel.org, selinux@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, xiujianfeng@huawei.com, lujialin4@huawei.com
Subject: Re: [PATCH RFC -next 00/12] landlock: Add READ_METADATA and
 WRITE_METADATA access rights
Message-ID: <20260928.ueyaze7gah5A@digikod.net>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
 <20260925-zahnersatz-hielt-lerche-141893658522@brauner>
 <CAHC9VhSeXmOHvioZ12aVmnOtpP52-G=K_jS3K0fTSiCrDHStPw@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAHC9VhSeXmOHvioZ12aVmnOtpP52-G=K_jS3K0fTSiCrDHStPw@mail.gmail.com>
X-Infomaniak-Routing: alpha

On Fri, Sep 25, 2026 at 01:07:08PM -0400, Paul Moore wrote:
> On Fri, Sep 25, 2026 at 11:33 AM Christian Brauner <brauner@kernel.org> wrote:
> > On Thu, Sep 24, 2026 at 06:48:19PM +0800, Cai Xinchen wrote:
> > > This series adds two new Landlock filesystem access rights,
> > > LANDLOCK_ACCESS_FS_READ_METADATA and LANDLOCK_ACCESS_FS_WRITE_METADATA,
> > > which control access to file and directory metadata such as inode
> > > attributes (mode, ownership, timestamps), extended attributes and POSIX
> > > ACLs.  It picks up the work from the "landlock: add chmod and chown
> > > support" series [1] and follows the coarse-grained grouping discussed in
> > > that thread [2]: instead of separate chmod/chown rights, metadata
> > > operations are grouped into one read and one write right.
> >
> > This is mostly fine for me. @Michael, for the fs side of things I would
> > give you a stable branch vfs-7.*.shared.landlock.path that you can pull
> > once this is ready.
> 
> This is in my queue, but I haven't reviewed the changes yet.
> 
> @Christian, I'm guessing you will merge patches 1/12, 3/13, and 4/12
> since those are the VFS changes?  Once you have a branch for that, and
> we have all the necessary ACKs, I'll merge the LSM changes in 2/12,
> 5/12, 6/12, and 7/12 and then Mickaël can merge the Landlock patches.
> 
> Are we all okay with that?

I guess the initial branch would be Christian's one, then Paul's would
start from this branch and add the LSM patches on top of it, and then
I'll do the same with the Landlock changes?  If Christian needs to
change his branch, Paul would have to rebase on top of the new branch,
and that would cascade to me.  That will be an interesting gymnastic,
especially if there are substantive changes in the VFS (which could lead
to headaches for the -next merges), but we can try.
