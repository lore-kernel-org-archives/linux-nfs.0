Received: from zeniv.linux.org.uk (zeniv.linux.org.uk [62.89.141.173])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4932227CB35;
	Tue, 24 Feb 2026 05:14:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=62.89.141.173
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771910099; cv=none; b=Zkj2gzx5Ba3/oS7/pwkt+CpZHm5RrYQxXbDvCXv2/tplimQgZepmqHplMAIPAX/us+mJwoNrHtFQ8ASXZ10gzTqod4mCvh7ySOot+2j5IofXQBk4XYMxfggVgVhjdR9qW6aGkuVeJZWVSgAgvPpMU59R481/bzyFzQZWuilMT/s=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771910099; c=relaxed/simple;
	bh=5gjYpTIN4YCsnqqxfusMWKco5LaTTOjrlumXA9PBJa0=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=AQOHLV+PmaA3LbhIWP7aeSX7ApnhlOqNeMendTLRia9ioYUKeX/gSnM5oYCbwkpFEouwgqcf0v+zZvc6BP3bL4xzD/O7eFVSkIYooUAgTCeMsi36i+r1p5cUFQp8hSw2+sBhjVvRoHPMcYGIiN6QAy1bPQVdJScfjn5I+TX4osg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk; spf=none smtp.mailfrom=ftp.linux.org.uk; dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b=QHkHk3Lb; arc=none smtp.client-ip=62.89.141.173
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=zeniv.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org; spf=none smtp.mailfrom=ftp.linux.org.uk
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=linux.org.uk header.i=@linux.org.uk header.b="QHkHk3Lb"
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=linux.org.uk; s=zeniv-20220401; h=Sender:In-Reply-To:Content-Type:
	MIME-Version:References:Message-ID:Subject:Cc:To:From:Date:Reply-To:
	Content-Transfer-Encoding:Content-ID:Content-Description;
	bh=fScT3edAvk0SBxL7di0v4GgtE3hfdRqW25fjnSh97hE=; b=QHkHk3LbYFKkyKXls9QK+w6VcD
	OTdKi0duhWT1kgJ0fNSsqxLHkVOTlJ2q6NxZmi448+gIYwWN58BTa2knJnLxsOwD/dri8R9aOe0s4
	OhxL6+t/lRId0fAk2YSfR9eOrF2tnXQQM+yM+TMGTEuB6NPGbEPDBB6tLYSCfgb/1HRsJlHJen3ca
	WcfXlBd8OTDTXINzSkQlDmWs07iE5cvwNq5qUlG6V7EmBp8ey/iPJtrKWST+n21uIvf6NHvA/R5r5
	6CIuk5B6o8bqUQRcyK/P1RGxMx0Mw4+rPbRCIif85dsEh8Mydbk4zGG1YbroII6aXV+/xO39A2XJF
	BhjbD3pg==;
Received: from viro by zeniv.linux.org.uk with local (Exim 4.99.1 #2 (Red Hat Linux))
	id 1vuknZ-00000008Z6H-0tl8;
	Tue, 24 Feb 2026 05:17:29 +0000
Date: Tue, 24 Feb 2026 05:17:29 +0000
From: Al Viro <viro@zeniv.linux.org.uk>
To: Shyam Prasad N <nspmangalore@gmail.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	CIFS <linux-cifs@vger.kernel.org>, linux-nfs@vger.kernel.org,
	David Howells <dhowells@redhat.com>
Subject: Re: [LSF/MM/BPF TOPIC] Support to split superblocks during remount
Message-ID: <20260224051729.GB1762976@ZenIV>
References: <CANT5p=orpQdzqxjNronnnKUo5HFGjuVwkwpjiGHQRmwh8es0Pw@mail.gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CANT5p=orpQdzqxjNronnnKUo5HFGjuVwkwpjiGHQRmwh8es0Pw@mail.gmail.com>
Sender: Al Viro <viro@ftp.linux.org.uk>

On Tue, Feb 17, 2026 at 10:15:58AM +0530, Shyam Prasad N wrote:
> Filesystems today use sget/sget_fc at the time of mount to share
> superblocks when possible to reuse resources. Often the reuse of
> superblocks is a function of the mount options supplied. At the time
> of umount, VFS handles the cleaning up of the superblock and only
> notifies the filesystem when the last of those references is dropped.
> 
> Some mount options could change during remount, and remount is
> associated with a mount point and not the superblock it uses. Ideally,
> during remount, the mount API needs to provide the filesystem an
> option to call sget to get a new superblock (that can also be shared)
> and do a put_super on the old superblock.
> 
> I do realize that there are challenges here about how to transparently
> failover resources (files, inodes, dentries etc) to the new
> superblock.

That's putting it way too mildly.  A _lot_ of places rely upon the following:
	* any struct inode instance belongs to the same superblock through the
entire lifetime.  ->i_sb is assign-once and can be accessed as such.
	* any struct dentry instance belongs to the same superblock through
the entire lifetime; ->d_sb is assign-once and can be accessed as such.  If it's
postive, the corresponding inode will belong to the same superblock.
	* any struct mount instance is associated with the same superblock
through the entire lifetime; ->mnt_sb is assign-once and can be accessed as such.
	* any opened file is associated with the same dentry and mount through
the entire lifetime; mount and dentry are from the same superblock.

Exclusion that would required to cope with the possibility of the above
being violated would cost far too much, and that's without going into the
amount of analysis needed to make sure that things wouldn't break.

Which filesystem do you have in mind?
