From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH,RESEND] make knfsd interact cleanly with HSMs
Date: Mon, 8 May 2006 11:13:06 +1000
Message-ID: <17502.39714.775234.337995@cse.unsw.edu.au>
References: <20060505115254.GA13916@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>,
	Linux Filesystem Mailing List <linux-fsdevel@vger.kernel.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Greg Banks <gnb@sgi.com>
In-Reply-To: message from Greg Banks on Friday May 5
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Friday May 5, gnb@sgi.com wrote:
> 
> This patch seeks to remedy the interaction between knfsd and HSMs by
> providing mechanisms to allow knfsd to tell an underlying filesystem
> (which supports HSMs) not to block for reads, writes and truncates
> of offline files.  It's a port of a Linux 2.4 patch used in SGI's
> ProPack distro since 2004 and in SLES9 since SP2.  The patch:
> 
> *  provides a new ATTR_NO_BLOCK flag which the kernel can
>    use to tell a filesystem's inode_ops->setattr() operation not
>    to block when truncating an offline file.  XFS already obeys
>    this flag (inside a #ifdef)
> 
> *  changes knfsd to provide ATTR_NO_BLOCK when it does the VFS
>    calls to implement the SETATTR NFS call.
> 
> *  changes knfsd to supply the O_NONBLOCK flag in the temporary
>    struct file it uses for VFS reads and writes, in order to ask
>    the filesystem not to block when reading or writing an offline
>    file.  XFS already obeys this new semantic for O_NONBLOCK
>    (and in SLES9 so does JFS).
> 
> *  adds code to translate the -EAGAIN the filesystem returns when
>    it would have blocked, to the -ETIMEDOUT that knfsd expects.
> 

Yes, I'm happy with this.  All the changes make sense and look right.

Thanks for persisting with it.

I'll send it on up the chain...

NeilBrown

