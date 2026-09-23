Received: from fhigh-a1-smtp.messagingengine.com (fhigh-a1-smtp.messagingengine.com [103.168.172.152])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A64EB446851;
	Wed, 23 Sep 2026 06:51:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.152
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790146269; cv=none; b=AaH/W68Cty+p6ZKlo2pjHY19AQO7UYYwHE79M4SPLHqh7Ac1KPxcApLratqcb/VkSWACH+82as8FdGFLK99dJefErgEq140gtHh/yW3KkCcGV1YE+ryAprCJ6M0UBNxkdOHGJd1hKpgW4d99/F2V1qscYv5mxYvj6tUfw5uo3t0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790146269; c=relaxed/simple;
	bh=VLwVzwpx5W42FrPWeGRizZdOMjOPvhw8rKz1u3Rw9og=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=LW0Rp0TdgBlX0jdWSzJUsy7GOAbBL2KnjVE2QXU/FfeZE5GJ8CA7XI/YoXZ7WPjbS9ClX8tufQYTJhPwO8cofnDL0Vr/0wpRHqO6eErJ5hHVzs/6BBs1kxlVYcTjXLGSSB0YlMcTJbAUpdz+oDvPx4ukj6zxCHy4mmOVCT1Fya0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=ObjoTqtJ; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=WhXfHjWW; arc=none smtp.client-ip=103.168.172.152
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="ObjoTqtJ";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="WhXfHjWW"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.phl.internal (Postfix) with ESMTP id 6FA3F1400102;
	Wed, 23 Sep 2026 02:50:58 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-04.internal (MEProxy); Wed, 23 Sep 2026 02:50:58 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790146258; x=1790232658; bh=SWZT1UO2bIi+bYZrTn/ccdVzadVGT0rvvLw
	AXS4xoBE=; b=ObjoTqtJnTHvEjCqxatHSI7ADSLLgmmPS2o8RYbujzEFxvz67Rx
	nNPn+NjTaIPoXlbLl3rCZK1MB9H8k0vRh/UyKs3eo9VT7KdynU/9l8PzzG4ruyRz
	3fYVjGkajwLEmHTYlkyoxnjaigKJQ6kajOMUjxZksZpDhFANGUN4erNJioJz+HWM
	2vBZimZUBIUQPiVwP/QXl+V0YtHr7ZvL5OKGJWyKYeZzRFanG9y3UYjGWOH1dfQC
	HBFQFmzwvM5WaBlSVjoQagsRtOjvJgsa2826qUKnuq//gvKbcJ2FVDpQpOySbDnM
	YjOtHCk0r50fLu/QQo0Hd7nktjkHmL8pH0w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790146258; x=
	1790232658; bh=SWZT1UO2bIi+bYZrTn/ccdVzadVGT0rvvLwAXS4xoBE=; b=W
	hXfHjWWdmI7MelHKwwiapzmkhuj68PD+zn1pJYHLbZHrFUWBoLDQtFi6SLPJCdQc
	wFcJbsC2r4xSeaCh/aCWNEBF70oKXvi98ZI7GRfsYas3vgSruS/bIdZC9zW9KQxP
	KC7QQhpr9C9mcf2HB/NN24GgKzWle44UaJZAMJafCWNtwWsfxiXOT16uvNjl/5zQ
	a80P8cxMQ2ItKVmwhOeWCsmi6MQUpixu0PuWrduiNZVzeTgXY8i6Qf2u+cqJQ2c7
	zRSXemxDxAFLU6Sm/Y7NKzyT5gF9q4VoRf6CY5URK3tE22DaHA33ReybxxPg7C3B
	uKnabbMzSeA9dVTj24OyQ==
X-ME-Sender: <xms:0Xazauu6HZgRmyLT8Y-INiF8EbhdHAFtKvqQC6EMe6yqhMZbodBFUQ>
    <xme:0Xazaj1sSl9mHMg6zWXeWlaYHqpZBLurSjCDEvvNWFTe0ApFGzlVbafY-EqJ50gja
    DHrqAdYbC1VsJIJwJehOywPgLLb8KmSFvatpE3X1_n0GbPa_HU>
X-ME-Received: <xmr:0Xazaq7x5JwWNfEMO1wGhuDonw2Xp5569A3aLim3plFS80-AfQffYYbyXe_WTomz8uzIQDqpQnuij0tQGSDE-eR97p5zvt8>
X-ME-Proxy-Cause: dmFkZTGPLK21tCRFjoeO4q0Sa94FhwKtIvMtcd+/OrDFWj7zVfeY3UAbtPR8o4TcVID45e
    1GKFtxOzBV6L6E2zwDaIrJjLsesy37b/82+yppMX9QFR35VBA4D+0REbIvi3mv0Htpsw5U
    RlrUHYd50N3J4eWZk9PVIaIgdhJM2iuB4jliEae6qG1VPKZ7WWc2+bJDzDF054mqZmZX0j
    9DxELv6/Odk0dt3uHWDSu2TyCqWF1+cmK7vvNnIwXjI0S0kOP2ucgwWgQ7DoVJVP82kvGZ
    nUqLM4NjizjReJnzSznmqzRC1vWFGLm3sYAN93KQ9NeH34wW5Okv2yIIXzyLBSqY6wObbE
    6QYvTA1ru9qQTyVIBu1ISTAiPPqPeTj1e7WmKFxAWyjdg4U70LMnS/FX1Exj98187mi8KH
    tvcuojtdGOeftAXV+coWBkG3w4knABLYqNAGqFLy0tfaRjuO+7peaeWgUXkQZx08iSvftM
    utCazEZppyGVZnqLe//2sQDg0HqxQQSPTn13kV+rEhiVhntpHhvg3MgSeo7r1v3gDkHHrI
    ff0VKm56go9yzxmdC93cQX9NxBbUAhJfk/QXmQJLfrb4c+Ow8OSHYe7V13WrDZxdPd47Pg
    k6syhgPOFTB60Gy4Ci1bohFXsyucb2hlfAn+ADJF5Nrobt1nAcYGF5lipCuQ
X-ME-Proxy: <xmx:0XazalPs1sz3MVQKHSXlm4TEQkzyjhZzScNWEq5SNHdDx9CdGOEt0A>
    <xmx:0XazauE1iMEOqO1E13l62oF_DYGV2t6ghGib0_sRpQXmPoW2I7Ra-w>
    <xmx:0Xazap2-jjsbFBWhLKaQCmkmnTpp6lGaNa93WD5zzrPxNJ14dpTMzA>
    <xmx:0XazalHU6b_88_1jm6RQKmD7LLNKLPx9EwNFqe1Q0E7zOai1tsM6vA>
    <xmx:0nazahjHYXBAgpcmszhBYJmYbWY0rV44yWk7F7pQrO4B0JD289ezJpL4>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 23 Sep 2026 02:50:52 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Namjae Jeon" <linkinjeon@kernel.org>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, "Jori Koolstra" <jkoolstra@xs4all.nl>,
 "Mateusz Guzik" <mjguzik@gmail.com>,
 "Dorjoy Chowdhury" <dorjoychy111@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Andreas Gruenbacher" <agruenba@redhat.com>, gfs2@lists.linux.dev,
 "Ilya Dryomov" <idryomov@gmail.com>, "Alex Markuze" <amarkuze@redhat.com>,
 "Viacheslav Dubeyko" <slava@dubeyko.com>, ceph-devel@vger.kernel.org,
 "Paulo Alcantara" <pc@manguebit.org>, linux-cifs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 05/14] cifs: allow -EISDIR precedence over -EFTYPE in
 __cifs_do_create()
In-reply-to:
 <CAKYAXd9W3O=Dsavu4=XUp+3SyFWOL3Bs7fbzg0YBFpwk4-TCAA@mail.gmail.com>
References: <20260919022441.3305170-1-neilb@ownmail.net>
  <20260919022441.3305170-6-neilb@ownmail.net>
  <CAKYAXd9W3O=Dsavu4=XUp+3SyFWOL3Bs7fbzg0YBFpwk4-TCAA@mail.gmail.com>
Date: Wed, 23 Sep 2026 16:50:48 +1000
Message-id: <179014624846.37859.16894598335961934458@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 23 Sep 2026, Namjae Jeon wrote:
> On Sat, Sep 19, 2026 at 11:25 AM NeilBrown <neilb@ownmail.net> wrote:
> >
> > From: NeilBrown <neil@brown.name>
> >
> > If atomic_open is given __O_REGULAR, we now would prefer -EISDIR
> > if a directory was found.  So move the S_ISDIR() tests earlier.
> >
> > Also don't return -EFTYPE for S_ISLNK() - that should get -ELOOP and only
> > if O_NOFOLLOW.
> Simply exempting symlinks from the __O_REGULAR check in cifs is not
> sufficient. Once this check allows the symlink through,
> cifs_atomic_open() still calls finish_open() on it, setting
> FMODE_OPENED. open_last_lookups() then skips symlink traversal, so
> do_open() returns -EFTYPE before may_open() can return -ELOOP. This
> path also reaches cifs_new_fileinfo(), which pins the symlink dentry
> with dget(). The symlink's file operations do not provide CIFS's
> .release handler, so the failed open does not call cifs_close() to
> release that reference.
> 
> 

Thanks for looking at this.  I think I can see what you mean.

If __cifs_do_open() chooses not to call cifs_posix_open(), if that call
succeeds without providing an inode, then we could end up at
cifs_get_inode_info_unix() or cifs_get_inode_info() and if that returns
a symlink inode, this will be returned to cifs_atomic_open() which will
try to open it (finish_open()).
This is a pre-existing problem - is that right?  If an O_CREAT open
which doesn't have __O_REGULAR happens to find a symlink, then it will
already try to open it.

Presumably after calling cifs_do_create(), cifs_atomic_open() should
check if the inode is something that it can open.  If not it should call
finish_no_open().  Does it need to call server->ops->close() too?
Can I leave you to clean that up?  My goal here wasn't to fix
everything, but to improve the documentation and change some the details
of what errors are created by __O_REGULAR.

Thanks,
NeilBrown

