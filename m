From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 0/2] vfs: ensure that dentries are revalidated on open
 (try #2)
Date: Wed, 11 Nov 2009 07:36:02 -0500
Message-ID: <20091111073602.66e89147@tlielax.poochiereds.net>
References: <1257870456-31188-1-git-send-email-jlayton@redhat.com>
	<E1N884c-0006Br-Je@pomaz-ex.szeredi.hu>
	<1257927970.5138.24.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Miklos Szeredi <miklos@szeredi.hu>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	ebiederm@xmission.com, adobriyan@gmail.com,
	viro@ZenIV.linux.org.uk, jamie@shareable.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62123 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753377AbZKKMgS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Nov 2009 07:36:18 -0500
In-Reply-To: <1257927970.5138.24.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 11 Nov 2009 17:26:10 +0900
Trond Myklebust <trond.myklebust@fys.uio.no> wrote:

> On Wed, 2009-11-11 at 08:57 +0100, Miklos Szeredi wrote:
> > On Tue, 10 Nov 2009, Jeff Layton wrote:
> > > This is the second attempt to fix this problem. The first one attempted
> > > to fix this in procfs, but Eric Biederman pointed out that file bind
> > > mounts have a similar problem. This set attempts to fix the issue at a
> > > higher level, in the generic VFS layer.
> > 
> > I suspect the correct fix would be to clean up the open API so that
> > NFSv4 doesn't have to hack its stateful open routine into the
> > ->lookup() and ->d_revalidate() methods.
> 
> I've been working on that. I hope to have patches soon...
> 

Yes, that would be a much cleaner fix. It's good to hear that you're
working on it. Another approach for fixing this in the NFSv4 code did
occur to me too:

We could have nfs4_intent_set_file call lookup_instantiate_filp with an
open function pointer that's different from nfs_file_open. That function
would basically do what nfs_file_open does now. We could then fix
nfs_file_open to do a stateful open when it gets a filp with no state.

Until you have the VFS open interface fixed that might be the safest
approach in case there are other ways to skip dentry revalidation that
we haven't identified yet.

> > Having said that, doing revalidation for proc symlinks and bind mounts
> > (and not just for opens) might make sense.  This is something similar
> > to FS_REVAL_DOT, so perhaps make it conditional on this flag (or a
> > new, appropriately named one).
> 

> Aren't both proc symlinks and bind mounts pretty much guaranteed to
> point to a valid dentry? Once we fix the open case, I can't see that we
> need to do much more. Networked filesystems may want to revalidate the
> inode attributes, but not the dentry itself...
> 

As Miklos pointed out, removing the file on the server would make even
those invalid...

A new fs_flag sounds like a reasonable idea. Assuming that I didn't
break the refcounting, my main worry with the set I have so far is that
it'll slow down path walking. A new fs_flag should help minimize that
for filesystems where this isn't an issue.

-- 
Jeff Layton <jlayton@redhat.com>
