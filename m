From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/2] vfs: ensure that dentries are revalidated on open
 (try #2)
Date: Wed, 11 Nov 2009 17:26:10 +0900
Message-ID: <1257927970.5138.24.camel@heimdal.trondhjem.org>
References: <1257870456-31188-1-git-send-email-jlayton@redhat.com>
	 <E1N884c-0006Br-Je@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Jeff Layton <jlayton@redhat.com>, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	ebiederm@xmission.com, adobriyan@gmail.com,
	viro@ZenIV.linux.org.uk, jamie@shareable.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <E1N884c-0006Br-Je@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-11-11 at 08:57 +0100, Miklos Szeredi wrote:
> On Tue, 10 Nov 2009, Jeff Layton wrote:
> > This is the second attempt to fix this problem. The first one attempted
> > to fix this in procfs, but Eric Biederman pointed out that file bind
> > mounts have a similar problem. This set attempts to fix the issue at a
> > higher level, in the generic VFS layer.
> 
> I suspect the correct fix would be to clean up the open API so that
> NFSv4 doesn't have to hack its stateful open routine into the
> ->lookup() and ->d_revalidate() methods.

I've been working on that. I hope to have patches soon...

> Having said that, doing revalidation for proc symlinks and bind mounts
> (and not just for opens) might make sense.  This is something similar
> to FS_REVAL_DOT, so perhaps make it conditional on this flag (or a
> new, appropriately named one).

Aren't both proc symlinks and bind mounts pretty much guaranteed to
point to a valid dentry? Once we fix the open case, I can't see that we
need to do much more. Networked filesystems may want to revalidate the
inode attributes, but not the dentry itself...

Cheers
  Trond

