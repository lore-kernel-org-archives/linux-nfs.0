Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:35140 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751634Ab0ESOGz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 19 May 2010 10:06:55 -0400
Date: Wed, 19 May 2010 10:06:39 -0400
To: Jeremy Allison <jra@samba.org>
Cc: Jamie Lokier <jamie@shareable.org>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        ebiederm@xmission.com, adobriyan@gmail.com, viro@ZenIV.linux.org.uk
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on
	file
Message-ID: <20100519140639.GB4581@fieldses.org>
References: <4BED195F.3070504@cn.fujitsu.com> <20100514055844.109d2fdc@tlielax.poochiereds.net> <1273857471.4732.7.camel@localhost.localdomain> <20100514133819.5e383485@tlielax.poochiereds.net> <20100514174653.GC10133@shareable.org> <20100514181643.GC9217@samba1>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100514181643.GC9217@samba1>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, May 14, 2010 at 11:16:43AM -0700, Jeremy Allison wrote:
> On Fri, May 14, 2010 at 06:46:53PM +0100, Jamie Lokier wrote:
> 
> > I think you can delete open files on Windows nowadays, if they are
> > opened with a particular flag.
> 
> You can only mark them as "to be deleted" once the last opener
> closes. They still exist in the namespace.

So, I'm a little lost: in your opinion, would leases be more useful to
Samba if they were broken on delete, or if they weren't, or does it not
matter because you'll never do that?

(And, what about the same question for rename, link, chmod, chown, ...?)

I see three options:
	1. modify the existing file lease behavior to match what NFSv4
	   (and Samba?) needs; or
	2. leave the existing leases alone and create some new lock type
	   (or otherwise flag some leases somehow) that does what we
	   want; and, if we do that, either:
		2a. leave the new leases in-kernel-only, or
		2b. expose the new leases to userspace somehow so Samba
		   (or whever) can use them.

I don't think any of 1, 2a, or 2b is likely to be harder than any other,
so it's just a question of what we want.

--b.
