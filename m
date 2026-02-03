Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7C4453B9618;
	Tue,  3 Feb 2026 15:42:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1770133335; cv=none; b=fVosh4sdwXy+57yNPeMKGMlkhT1JkF0j7TdPCXBB5UJEXuA6qJzf4UPODI/l/0mMzhloKyQuwN/TGnCRKsI5owPp0k0t5FrK/1kwWs65z39I2vDvRxcP8SV3A5qtArfuYc/9CySapv2jTYpsKzO4uzzj7LZiWN/Vxzw21NakvHY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1770133335; c=relaxed/simple;
	bh=3m6PM7BiTfYOv0eengmhgqKYzAjLzI/HkhF1VU3RCnE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=U/JF2eL43DDRNkTCcI94ZmjejyySfp2eBKDzdFpU1iHrt3fr5v14h6/XWPhj0otIgpX+niSw4M0zvg2Z6TXIA0Oh++u+QEAVYTdItpwJbsygegBkxMGiVJKwRhKzgBXK8gTmd+r+Jt+auVdCsc56aqfzrvbXTXXNlpzf7D3SByY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RK2koJqA; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RK2koJqA"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9EDCBC19425;
	Tue,  3 Feb 2026 15:42:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1770133335;
	bh=3m6PM7BiTfYOv0eengmhgqKYzAjLzI/HkhF1VU3RCnE=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject:From;
	b=RK2koJqANQq5iACFYR+IUEBdtBj6nK+EocxQXmh/l0Pj6Ki2FQURGZwC8sqQZKYQC
	 Gr/nEzCfoFGHwyzCV63MLpNHyptKWwNsSTKNOh0Rn5ZH5homcAHXyZw9hGE+f+YNiG
	 266HCO28bnSIk8ulSxuNSUcFGxeDhGJDLwF/Q3kZ7kJbVhiLEFUKaGjBJ3sMYg8fMj
	 3gnH8iYV8JDbqVb3noyRP3pH/auoVnlC4YzTuM8Rm+5kybkxE0E9NN/4YLq6N3crNs
	 dicWIWO1GVp2N7Xzjgpnp4UwEN3hfnAvYijlxhE2iefrx/D9YIllTWFR7AQblC4+Qj
	 ZOczsCG49m83A==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 8DC2BF40068;
	Tue,  3 Feb 2026 10:42:13 -0500 (EST)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Tue, 03 Feb 2026 10:42:13 -0500
X-ME-Sender: <xms:VReCaU0E5VQhxrnNNTWe65aDJ6kepY_g3IIqitt9hes8da2Rt9DnxA>
    <xme:VReCaZ7W6n-4zRjEx4MHIJnHx9ijV-ZDAlPlowGJ9AEdVDAqJbucbRQmHDCvcE-t9
    hfCOad93jHYFGVeFai5VWltDxk7_v7MgXM-7FsSnsBxTscmbqNJz04j>
X-ME-Proxy-Cause: gggruggvucftvghtrhhoucdtuddrgeefgedrtddtgddukedtgeefucetufdoteggodetrf
    dotffvucfrrhhofhhilhgvmecuhfgrshhtofgrihhlpdfurfetoffkrfgpnffqhgenuceu
    rghilhhouhhtmecufedttdenucesvcftvggtihhpihgvnhhtshculddquddttddmnecujf
    gurhepofggfffhvfevkfgjfhfutgfgsehtjeertdertddtnecuhfhrohhmpedftehnnhgr
    ucfutghhuhhmrghkvghrfdcuoegrnhhnrgeskhgvrhhnvghlrdhorhhgqeenucggtffrrg
    htthgvrhhnpeeuudehieehteekfeeuffeugfeihfeugeevfeejveffueehieevjeeggffh
    jeehkeenucffohhmrghinhepkhgvrhhnvghlrdhorhhgnecuvehluhhsthgvrhfuihiivg
    eptdenucfrrghrrghmpehmrghilhhfrhhomheprghnnhgrodhmvghsmhhtphgruhhthhhp
    vghrshhonhgrlhhithihqdduieejjeduvddtjeelqdeffedvvdefgeejuddqrghnnhgrpe
    epkhgvrhhnvghlrdhorhhgsehnohifhhgvhigtrhgvrghmvghrhidrtghomhdpnhgspghr
    tghpthhtohepuddtpdhmohguvgepshhmthhpohhuthdprhgtphhtthhopegsrhgruhhnvg
    hrsehkvghrnhgvlhdrohhrghdprhgtphhtthhopehjlhgrhihtohhnsehkvghrnhgvlhdr
    ohhrghdprhgtphhtthhopehsfhhorhhshhgvvgeskhgvrhhnvghlrdhorhhgpdhrtghpth
    htohepthhrohhnughmhieskhgvrhhnvghlrdhorhhgpdhrtghpthhtoheprghlvgigrghn
    uggvrhesmhhihhgrlhhitgihnhdrtghomhdprhgtphhtthhopehjrggtkhesshhushgvrd
    gtiidprhgtphhtthhopehlihhnuhigqdhfshguvghvvghlsehvghgvrhdrkhgvrhhnvghl
    rdhorhhgpdhrtghpthhtoheplhhinhhugidqkhgvrhhnvghlsehvghgvrhdrkhgvrhhnvg
    hlrdhorhhgpdhrtghpthhtoheplhhinhhugidqnhhfshesvhhgvghrrdhkvghrnhgvlhdr
    ohhrgh
X-ME-Proxy: <xmx:VReCacZSz_jgt5atIJ--lInunwoUf_isHc7F7f0nwjc_cHMfN3ou_A>
    <xmx:VReCaTT1EC4fWDniDuKQ2Me9lJxiTm4td5OSILSt4XZCAVIQmEkIMQ>
    <xmx:VReCaT86QM07ak_slf_X29BRCht82VBoicniuk5tFtzsExWl2sh-KQ>
    <xmx:VReCabjR8il8TUDpKzGbNwkbEdN0pkVzCRh4DKX3zlLl3SA03udurQ>
    <xmx:VReCacbUv7Kv8kTmg9ART5cfjxcWuMGqbu-x3HKCu88NHSYvThRS6rBg>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 647D0B6006E; Tue,  3 Feb 2026 10:42:13 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AQ5zJGJASj87
Date: Tue, 03 Feb 2026 10:41:52 -0500
From: "Anna Schumaker" <anna@kernel.org>
To: "Christian Brauner" <brauner@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, "Trond Myklebust" <trondmy@kernel.org>,
 "Alexander Viro" <viro@zeniv.linux.org.uk>, "Jan Kara" <jack@suse.cz>,
 "Seth Forshee (DigitalOcean)" <sforshee@kernel.org>,
 "Alexander Mikhalitsyn" <alexander@mihalicyn.com>
Message-Id: <b9e9b0dd-745b-46fb-9e62-807d53dd417c@app.fastmail.com>
In-Reply-To: <20260203-leimen-kundgeben-7be98e9cd156@brauner>
References: <20260129-twmount-v1-1-4874ed2a15c4@kernel.org>
 <20260203-leimen-kundgeben-7be98e9cd156@brauner>
Subject: Re: [PATCH] vfs: add FS_USERNS_DELEGATABLE flag and set it for NFS
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Tue, Feb 3, 2026, at 10:08 AM, Christian Brauner wrote:
> On Thu, 29 Jan 2026 16:47:43 -0500, Jeff Layton wrote:
>> Commit e1c5ae59c0f2 ("fs: don't allow non-init s_user_ns for filesystems
>> without FS_USERNS_MOUNT") prevents the mount of any filesystem inside a
>> container that doesn't have FS_USERNS_MOUNT set.
>> 
>> This broke NFS mounts in our containerized environment. We have a daemon
>> somewhat like systemd-mountfsd running in the init_ns. A process does a
>> fsopen() inside the container and passes it to the daemon via unix
>> socket.
>> 
>> [...]
>
> Applied to the vfs-7.0.misc branch of the vfs/vfs.git tree.
> Patches in the vfs-7.0.misc branch should appear in linux-next soon.
>
> Please report any outstanding bugs that were missed during review in a
> new review to the original patch series allowing us to drop it.
>
> It's encouraged to provide Acked-bys and Reviewed-bys even though the
> patch has now been applied. If possible patch trailers will be updated.

Acked-by: Anna Schumaker <anna.schumaker@oracle.com>

>
> Note that commit hashes shown below are subject to change due to rebase,
> trailer updates or similar. If in doubt, please check the listed branch.
>
> tree:   https://git.kernel.org/pub/scm/linux/kernel/git/vfs/vfs.git
> branch: vfs-7.0.misc
>
> [1/1] vfs: add FS_USERNS_DELEGATABLE flag and set it for NFS
>       https://git.kernel.org/vfs/vfs/c/269c46e936f3
