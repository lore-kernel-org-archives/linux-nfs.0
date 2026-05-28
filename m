Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 141343E51EB;
	Thu, 28 May 2026 11:54:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779969282; cv=none; b=JXZduv04OgVbBYvPgRo3Rq0PgTfHDkgPAO3LcsZ1aDAN5vg9tSa7pM7iY/ppx6QBLq7LXPa4pwY0bo4Y0/gtfSAenGMKMeJkZChMzpQ+OT0vdWrg0rJSdo8zlCJX/HIrkcJ5d3zQpzIAnfqmrNxZ4bkR8asec4nwYwc38a8PMCk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779969282; c=relaxed/simple;
	bh=ScsMYDd6WsEnv9FNzT7n0og/oEPdvNPJUi0QVaePJA4=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=L0zsx2UVH46G3tblTktwdM6kWT4WNUadmou5CDAy6f2uep7cJUg9FnR5Ad8QnuouejakLSLM6L7JU49xL371ENf0jvLR2qWofCOXjt7Bf0cUmQzZNqpSVmwYI/ESE1tvyDHuZhmNmfP+nBh0UaHSwgtmkj0hNvDIBO/FQYEUexU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TqPvOn1B; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TqPvOn1B"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DF9981F000E9;
	Thu, 28 May 2026 11:54:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779969280;
	bh=EWDXgypc/7XooyW97XM8K/TWQykaNtrC+ELRkmzs9jk=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To;
	b=TqPvOn1BLY5HNy2XQTNp3rfgM5ZSnWb9w1Q0sDdSCzMEBGniOisYaEaj4aSaabiQr
	 3fGzjMMyHa5yCJBM2853gj6h8T0N96bHhz1EAA5vdbQxyl843T6c6tpX7fHy7kHkE4
	 TSGhcKc+p44nhjR7V9dL4x0b7fHT2H5KhF/avwXCxwdOORgdrNGwavUotFkbxmk4f9
	 q6Cq6bhzJ/4ALknDd8Dun5mIJgnpR4EpsPrG2WLPRRosJ42w6jhR4cn4b5HSdGWmGo
	 +/575jOvQ5LEQneF/1h+zG077ZMa+AARJQc1HyC3YekgpottsIWdsviDnSgeaVEiiJ
	 3tjInNdJYnPQA==
Date: Thu, 28 May 2026 13:54:30 +0200
From: Christian Brauner <brauner@kernel.org>
To: Mike Rapoport <rppt@kernel.org>
Cc: Jan Kara <jack@suse.cz>, Jan Kara <jack@suse.com>, 
	Mark Fasheh <mark@fasheh.com>, Joel Becker <jlbec@evilplan.org>, 
	Joseph Qi <joseph.qi@linux.alibaba.com>, Ryusuke Konishi <konishi.ryusuke@gmail.com>, 
	Viacheslav Dubeyko <slava@dubeyko.com>, Trond Myklebust <trondmy@kernel.org>, 
	Anna Schumaker <anna@kernel.org>, Chuck Lever <chuck.lever@oracle.com>, 
	Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
	Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
	Alexander Viro <viro@zeniv.linux.org.uk>, Dave Kleikamp <shaggy@kernel.org>, Theodore Ts'o <tytso@mit.edu>, 
	Miklos Szeredi <miklos@szeredi.hu>, Andreas Hindborg <a.hindborg@kernel.org>, 
	Breno Leitao <leitao@debian.org>, Kees Cook <kees@kernel.org>, 
	"Tigran A. Aivazian" <aivazian.tigran@gmail.com>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, 
	ocfs2-devel@lists.linux.dev, linux-nilfs@vger.kernel.org, linux-nfs@vger.kernel.org, 
	jfs-discussion@lists.sourceforge.net, linux-ext4@vger.kernel.org, linux-mm@kvack.org
Subject: Re: [PATCH 14/17] fs/namespace: use __getname() to allocate mntpath
 buffer
Message-ID: <20260528-geregelt-unsozial-apathisch-c8b484e0932e@brauner>
References: <20260523-b4-fs-v1-0-275e36a83f0e@kernel.org>
 <20260523-b4-fs-v1-14-275e36a83f0e@kernel.org>
 <lwnrjpmzbv6swapmnmb5jki3xxxzqsxuks5vykniwhakvhqh7i@rhff3qrwfnoj>
 <ahVisehwQGXEoM0g@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <ahVisehwQGXEoM0g@kernel.org>

On Tue, May 26, 2026 at 12:06:57PM +0300, Mike Rapoport wrote:
> On Mon, May 25, 2026 at 06:22:13PM +0200, Jan Kara wrote:
> > On Sat 23-05-26 20:54:26, Mike Rapoport (Microsoft) wrote:
> > > mnt_warn_timestamp_expiry() allocates memory for a path with
> > > __get_free_page() although there is a dedicated helper for allocation of
> > > file paths: __getname().
> > > 
> > > Replace __get_free_page() for allocation of a path buffer with __getname().
> > > 
> > > Signed-off-by: Mike Rapoport (Microsoft) <rppt@kernel.org>
> > > ---
> > >  fs/namespace.c | 4 ++--
> > >  1 file changed, 2 insertions(+), 2 deletions(-)
> > > 
> > > diff --git a/fs/namespace.c b/fs/namespace.c
> > > index fe919abd2f01..2ed9cd846a81 100644
> > > --- a/fs/namespace.c
> > > +++ b/fs/namespace.c
> > > @@ -3303,7 +3303,7 @@ static void mnt_warn_timestamp_expiry(const struct path *mountpoint,
> > >  	   (ktime_get_real_seconds() + TIME_UPTIME_SEC_MAX > sb->s_time_max)) {
> > >  		char *buf, *mntpath;
> > >  
> > > -		buf = (char *)__get_free_page(GFP_KERNEL);
> > > +		buf = __getname();
> > 
> > Fair but d_path() below should then get PATH_MAX and not PAGE_SIZE.
> 
> Ack.
>  
> > >  		if (buf)
> > >  			mntpath = d_path(mountpoint, buf, PAGE_SIZE);
> > >  		else
> > > @@ -3319,7 +3319,7 @@ static void mnt_warn_timestamp_expiry(const struct path *mountpoint,
> > >  
> > >  		sb->s_iflags |= SB_I_TS_EXPIRY_WARNED;
> > >  		if (buf)
> > > -			free_page((unsigned long)buf);
> > > +			__putname(buf);
> > 
> > And __putname() is fine with NULL so no need for the if (buf) check here.
> 
> Will fix.

I've folded this myself.
