Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D8D84346AE8;
	Fri,  6 Mar 2026 09:42:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1772790131; cv=none; b=r6g2Aua1Hu4F1lyQvcxyszVjmmIunal5scxRTYLX1zXme1ZF+uSMQ2MI+sf/VTMfKeg7ukUtrcmK4zPly8qjFau+zrBZpwyX2ghj78d5ajoXC30MFij2eKX8LgaW/eSbgsEdquo+L1CpTOOOScOuPgK9NZLzIektXRu5io3pMjg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1772790131; c=relaxed/simple;
	bh=fFg7aWjPxphbulTb79Nt+ZDPqV4b3jllfkrmJmykajI=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=GE1Q2pAwymuqcA54dQSbWRgjeHGvmmSdnJbGHLBMijanWrvk60n7hlT/Vwj5SFUSfM7HFVIuBNWEcskVlBoDp7tOHWNbfNlMxP9CWEobVHUHN2yEY69h9Wf65K7tGSaQ186HUpSBVY/t3TuEfVcFK65+xtuccZ2EJWk4z2roPZs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HH0dSpc/; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HH0dSpc/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 42949C4CEF7;
	Fri,  6 Mar 2026 09:42:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1772790130;
	bh=fFg7aWjPxphbulTb79Nt+ZDPqV4b3jllfkrmJmykajI=;
	h=Date:From:To:Cc:Subject:References:In-Reply-To:From;
	b=HH0dSpc/NY5W6vJribQ+0/VUib+ntzCMXwsF44TqYjP1DQJWwC4t2dC/dm+Mi9VCk
	 o33dauJ6s4cCsTKppZWf2FouzNEPL7RkNJM2sQRR0OWzENbwBdn2ID0ImWSfUdYA3d
	 G6Ycyw5KRr1tlQpXPgOg/TNKn/xLOUpRQJQZzub+CTcJdgW5iyjjUZtTDAAdL3bOoz
	 15PnfIMPjE5DIc5W/D+cnLdq1HvN4kM0cGlnEspFGoym/UwjmuTFDwMIkZgkeyX7o3
	 MH8iwSDfyPNa88MIts0uDSl97VM/yIsxUbTn60rD8OhRvxA6r4Zhu3gGkF95tj8S8t
	 F7xNzkhP59KAA==
Date: Fri, 6 Mar 2026 10:42:02 +0100
From: Christian Brauner <brauner@kernel.org>
To: NeilBrown <neil@brown.name>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, 
	David Howells <dhowells@redhat.com>, Jan Kara <jack@suse.cz>, Chuck Lever <chuck.lever@oracle.com>, 
	Jeff Layton <jlayton@kernel.org>, Miklos Szeredi <miklos@szeredi.hu>, 
	Amir Goldstein <amir73il@gmail.com>, John Johansen <john.johansen@canonical.com>, 
	Paul Moore <paul@paul-moore.com>, James Morris <jmorris@namei.org>, 
	"Serge E. Hallyn" <serge@hallyn.com>, Stephen Smalley <stephen.smalley.work@gmail.com>, 
	"Darrick J. Wong" <djwong@kernel.org>, linux-kernel@vger.kernel.org, netfs@lists.linux.dev, 
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-unionfs@vger.kernel.org, 
	apparmor@lists.ubuntu.com, linux-security-module@vger.kernel.org, selinux@vger.kernel.org
Subject: Re: [PATCH v3 05/15] Apparmor: Use simple_start_creating() /
 simple_done_creating()
Message-ID: <20260306-fastnacht-kernig-3b350bd2fab0@brauner>
References: <20260224222542.3458677-1-neilb@ownmail.net>
 <20260224222542.3458677-6-neilb@ownmail.net>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20260224222542.3458677-6-neilb@ownmail.net>

On Wed, Feb 25, 2026 at 09:16:50AM +1100, NeilBrown wrote:
> From: NeilBrown <neil@brown.name>
> 
> Instead of explicitly locking the parent and performing a look up in
> apparmor, use simple_start_creating(), and then simple_done_creating()
> to unlock and drop the dentry.
> 
> This removes the need to check for an existing entry (as
> simple_start_creating() acts like an exclusive create and can return
> -EEXIST), simplifies error paths, and keeps dir locking code
> centralised.
> 
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
> Signed-off-by: NeilBrown <neil@brown.name>
> ---

Fwiw, I think this fixes a reference count leak:

The old aafs_create returned dentries with refcount=2 (one from
lookup_noperm, one from dget in __aafs_setup_d_inode). The cleanup path
aafs_remove puts one reference leaving one reference that didn't get
cleaned up.

After your changes this is now correct as simple_done_creating() puts
the lookup reference.
