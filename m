Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:54342 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750943Ab0ESQVb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 May 2010 12:21:31 -0400
Date: Wed, 19 May 2010 17:21:15 +0100
From: Jamie Lokier <jamie@shareable.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeremy Allison <jra@samba.org>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@fys.uio.no>,
        Mi Jinlong <mijinlong@cn.fujitsu.com>,
        NFSv3 list <linux-nfs@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
        ebiederm@xmission.com, adobriyan@gmail.com, viro@ZenIV.linux.org.uk
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on file
Message-ID: <20100519162115.GC1693@shareable.org>
References: <4BED195F.3070504@cn.fujitsu.com> <20100514055844.109d2fdc@tlielax.poochiereds.net> <1273857471.4732.7.camel@localhost.localdomain> <20100514133819.5e383485@tlielax.poochiereds.net> <20100514174653.GC10133@shareable.org> <20100514181643.GC9217@samba1> <20100519140639.GB4581@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100519140639.GB4581@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
> On Fri, May 14, 2010 at 11:16:43AM -0700, Jeremy Allison wrote:
> > On Fri, May 14, 2010 at 06:46:53PM +0100, Jamie Lokier wrote:
> > 
> > > I think you can delete open files on Windows nowadays, if they are
> > > opened with a particular flag.
> > 
> > You can only mark them as "to be deleted" once the last opener
> > closes. They still exist in the namespace.
> 
> So, I'm a little lost: in your opinion, would leases be more useful to
> Samba if they were broken on delete, or if they weren't, or does it not
> matter because you'll never do that?

Samba might not delete open files (I'm not sure), but the Linux user
on the server can still unlink the files, or rename over them.

What should happen then, I'm not sure.  Maybe Samba should be able to
delay the delete (like reads/writes can be delayed), or maybe it
should be able to refuse the delete altogether (similar to the way
the fanotify framework can block operations).

> I see three options:
> 	1. modify the existing file lease behavior to match what NFSv4
> 	   (and Samba?) needs; or
> 	2. leave the existing leases alone and create some new lock type
> 	   (or otherwise flag some leases somehow) that does what we
> 	   want; and, if we do that, either:
> 		2a. leave the new leases in-kernel-only, or
> 		2b. expose the new leases to userspace somehow so Samba
> 		   (or whever) can use them.
> 
> I don't think any of 1, 2a, or 2b is likely to be harder than any other,
> so it's just a question of what we want.

I think changing the userspace contract for long-standing F_SETLEASE
is rude at least.  Samba and NFS aren't the only lease users, and
anyway people will still run old Samba on new kernels; changing its
behaviour is a bit risky.

Imho, new lease semantics should use new userspace API.

-- Jamie
