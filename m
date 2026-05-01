Received: from zeniv.linux.org.uk (zeniv.linux.org.uk [62.89.141.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D5F861922F5;
	Fri,  1 May 2026 03:37:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=62.89.141.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1777606630; cv=none; b=CkXak+VOxK3C5QhD4JoVOfOWBKrJXjFa+sPpM3r5ymUE9bV7P56D3hAqr9Y2jTZxFCvJHfHWIir5q8qo3LythXuEqtmaAA9yvzQyfG0/5s+k+W5n5fWhNcZnKhLXEVWZMQpYwNdPKhKM/j+UZKVaesPNdLg4QG9TWTh5MJy8TBg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1777606630; c=relaxed/simple;
	bh=2vdaGUjWcVqBMZTMVk6ThhAnvlDDzv3WEczvAjqQNR8=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=Rs1IGq4oPycvUdHBDnQ/c7PpV28CGn4DaaRPU+WQ7HX06rRo6szB9FgLmnaOCy/hxNa7D0I+L6unaBiEb7sOZF92VS1s2GJjlMUW3DeECbLOVJhcQHb42zQo92gBRArLAdj0qQ3pkpRwneD3BO7iVuaay0F9zaPFznY3KbnF9NA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk; spf=none smtp.mailfrom=ftp.linux.org.uk; dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b=fDcqcR88; arc=none smtp.client-ip=62.89.141.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=ftp.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b="fDcqcR88"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=linux.org.uk; s=zeniv-20220401; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=JxVilBzd+nRyVxCW8ybOTcFtzKi7C7+jc5949dfnSYo=; b=fDcqcR88Ea2pIXSh09LVrtjokq
	DWdzsE1AbUv54bonjsVTDLX6bapuY6QGE5HruqmHjrjh9WmVXV2Pyl2OuJVl7vIQ8G/wATN+BqjOS
	8V+EP+FIrY3uGTmryBm5p0X7x8ZgyupqJNtJm9qjP5DSPpLoYTRlhrGAgSDIE65TyQ/WltJCV1c78
	0HsgFSjHfl01pDtDyL+puYdWP81KAEugpBJZOvtdky+IV5rsXBcqXQBCCry3QS3CJI2Qz0/3rTvWD
	c12uNzOx5A1sZ107muRQq+y968hMGK3LsAEq3clFx/GpKqAhMI/XWvd3N1TqKp0djW30hXOoOB4m9
	9EE7t2nQ==;
Received: from viro by zeniv.linux.org.uk with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1wIegl-0000000DHmd-1opQ;
	Fri, 01 May 2026 03:37:15 +0000
Date: Fri, 1 May 2026 04:37:15 +0100
From: Al Viro <viro@zeniv.linux.org.uk>
To: NeilBrown <neil@brown.name>
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Christian Brauner <brauner@kernel.org>, Jan Kara <jack@suse.cz>,
	Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Miklos Szeredi <miklos@szeredi.hu>,
	Amir Goldstein <amir73il@gmail.com>, Jeremy Kerr <jk@ozlabs.org>,
	Ard Biesheuvel <ardb@kernel.org>, linux-efi@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	linux-unionfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v3 04/19] VFS: use wait_var_event for waiting in
 d_alloc_parallel()
Message-ID: <20260501033715.GB3518998@ZenIV>
References: <20260427040517.828226-5-neilb@ownmail.net>
 <20260428033738.GV3518998@ZenIV>
 <177737511992.1474915.1952404144121931523@noble.neil.brown.name>
 <20260428142225.GX3518998@ZenIV>
 <177741881482.1474915.12527082398060370192@noble.neil.brown.name>
 <20260429052626.GY3518998@ZenIV>
 <20260429170731.GZ3518998@ZenIV>
 <177759308866.1474915.9708613530229799376@noble.neil.brown.name>
 <20260501011132.GA3518998@ZenIV>
 <177759959922.1474915.14496442965390503813@noble.neil.brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <177759959922.1474915.14496442965390503813@noble.neil.brown.name>
Sender: Al Viro <viro@ftp.linux.org.uk>

On Fri, May 01, 2026 at 11:39:59AM +1000, NeilBrown wrote:

> I dislike them too.  I doubt I can find solutions that either of us
> like, but they should be relatively short-lived.  Once we push the
> locking down in the the inode_operations the filesystem will be in a
> position to hold the lock only when it actually needs it (if at all).

... or we'll end up with hard-to-formulate constraints on what a filesystem
may do with its internal locking to use the APIs provided by fs/{dcache,namei}.c
safely.

Note that e.g. "->iterate_shared() wants to know the synthetic inumbers
a concurrent stat(2) would inject into dcache" (which is the original
reason for dcache preseeding in that thing) is not uncommon.  In procfs
you are lucky to have no mkdir() and friends; the same is not true in
general and we'd better have a sane answer to "what could a filesystem
like that do with its internal locking".  Or that thing will get blindly
copied, with predictable results.

> I'm confident that dropping the lock is safe.  If there was some way to
> tell the VFS that the lock has already been dropped, then we wouldn't
> need to reclaim it, but I cannot see a clean way to do that.

FWIW, I'm more concerned about ->iterate_shared() - d_add_ci() is garbage
that isn't used on a sanely configured kernel; ls -lR is not going away,
no matter what, and exclusion requirements are going to be a lot more
interesting for that one anyway.  It might be worth teaching iterate_dir()
that in such-and-such conditions it ought to save position, drop the lock,
do a lookup on name stashed in dir_context, retake the lock and call back into
->iterate_shared() from saved position.  With helper callable by ->iterate_shared()
instances if they run into failing d_alloc_trylock() in a situation where they
can't just shrug and move on...  Not sure.

What kind of exclusion do you have in mind for foo_iterate_shared() in the
long run?  Assuming that filesystem has directory-modifying operations, as
well as lookups, and its inumbers are synthetic.

BTW, do you have AFS and CIFS counterparts of your stuff from back in 2022
that killed d_rehash() uses in fs/nfs?  I would love to kill d_rehash();
exfat use is an easily removable junk, but fs/afs and fs/smb/client ones
are trickier and the reasons why it needed to be killed in fs/nfs apply
to those as well.
