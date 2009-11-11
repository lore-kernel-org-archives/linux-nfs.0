From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 0/2] vfs: ensure that dentries are revalidated on open
 (try #2)
Date: Wed, 11 Nov 2009 21:17:19 +0900
Message-ID: <1257941839.2949.9.camel@heimdal.trondhjem.org>
References: <1257870456-31188-1-git-send-email-jlayton@redhat.com>
	 <E1N884c-0006Br-Je@pomaz-ex.szeredi.hu>
	 <1257927970.5138.24.camel@heimdal.trondhjem.org>
	 <E1N88eK-0006Im-1F@pomaz-ex.szeredi.hu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: jlayton@redhat.com, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
	ebiederm@xmission.com, adobriyan@gmail.com,
	viro@ZenIV.linux.org.uk, jamie@shareable.org
To: Miklos Szeredi <miklos@szeredi.hu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <E1N88eK-0006Im-1F@pomaz-ex.szeredi.hu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2009-11-11 at 09:33 +0100, Miklos Szeredi wrote:
> On Wed, 11 Nov 2009, Trond Myklebust wrote:
> > Aren't both proc symlinks and bind mounts pretty much guaranteed to
> > point to a valid dentry?
> 
> It could for example happen that client bind mounts a regular file,
> then the file is unlinked on the server.  Then the bind mounted dentry
> is no longer valid.

The mountpoint dentry is still supposed to remain valid and accessible
on the client even if the object it points to on the server is invalid.
Otherwise you will not be able to unmount.

Cheers
  Trond

