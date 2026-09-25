Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 92CED2E7394;
	Fri, 25 Sep 2026 15:33:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790350399; cv=none; b=OmosOmyB+EacXZLbU5q0h8E/mfRoiZXChjAvFN1wFPg4DAKbqcIDyLZ75dYfhAFduGR+xzeXIVGGBCz5dMzm5SwqxxWRxT83BNzmmO5hxlAEmnFdQjY6d3OOc2Q7unyHms97BrVIBSiv5LlRrAfyvBZ/Gqom4D8zW5G7Z7rMW6k=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790350399; c=relaxed/simple;
	bh=2QtlFg1TQBLFoWLLR+xnMLhwaH/oGyTYdOxAvK0TVDI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=rVMEKKJId9nhkQRg1YfVpkjD2iivCBM28SW2RG1O0rUjip1VghFAumynSBg7c6UhjdWgPCwJqORCZfdaO9A1EDU95OfA227+EwP2sALvs8rZT2RyQGWQBQB8cNgvNxeDf7rMsYY8aVX87TuCCtjH0G5tW7UXlYBps9DZJSWNugw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PlJNduoW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PlJNduoW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6EFB11F000FF;
	Fri, 25 Sep 2026 15:33:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790350398;
	bh=nM7l79drUPilYt35VeJ3ygXZ+22Hcj/BVqiTPeeQn04=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=PlJNduoW1gaAsBwzDG24uVvzEEqhy3uQuCIDvpwyLa9NDQxiTTKO33Kxmdrmh19rt
	 oBLewGSVUqt6LSczA2CWf0wIrCuS1ZSioEnyd+7sC5yuA3bl12xzGtF2GcMInIpJWD
	 BYilMI4hge5yVPYHJsg+yVpB7+l/1Zz0xfp2S4XUfHXDv45xL2ns2oqGbWjyd8cX8H
	 Kel44pOx+Stw1fKK98CWoUX6LK5issBOuk5pwvaqBUAU2wsCb0BNp39dYgvfDBiYHQ
	 dY1DFDMOUpJwHx1ysd7Uo/QTBKV0Qfu88fSqbSsMsCpcwLeKxOTdsyh1NiW+y5WcKj
	 BKGOoABoJp74A==
Date: Fri, 25 Sep 2026 17:33:03 +0200
From: Christian Brauner <brauner@kernel.org>
To: Cai Xinchen <caixinchen1@huawei.com>, mic@digikod.net
Cc: gnoack@google.com, paul@paul-moore.com, jmorris@namei.org, 
	serge@hallyn.com, corbet@lwn.net, skhan@linuxfoundation.org, rdunlap@infradead.org, 
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
Message-ID: <20260925-zahnersatz-hielt-lerche-141893658522@brauner>
References: <20260924104831.1081137-1-caixinchen1@huawei.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20260924104831.1081137-1-caixinchen1@huawei.com>

On Thu, Sep 24, 2026 at 06:48:19PM +0800, Cai Xinchen wrote:
> This series adds two new Landlock filesystem access rights,
> LANDLOCK_ACCESS_FS_READ_METADATA and LANDLOCK_ACCESS_FS_WRITE_METADATA,
> which control access to file and directory metadata such as inode
> attributes (mode, ownership, timestamps), extended attributes and POSIX
> ACLs.  It picks up the work from the "landlock: add chmod and chown
> support" series [1] and follows the coarse-grained grouping discussed in
> that thread [2]: instead of separate chmod/chown rights, metadata
> operations are grouped into one read and one write right.

This is mostly fine for me. @Michael, for the fs side of things I would
give you a stable branch vfs-7.*.shared.landlock.path that you can pull
once this is ready.
