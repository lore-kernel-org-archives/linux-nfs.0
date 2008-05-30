From: James Lentini <jlentini@netapp.com>
Subject: Re: [PATCH] update mount.nfs example in NFS/RDMA documentation
Date: Fri, 30 May 2008 18:14:00 -0400 (EDT)
Message-ID: <alpine.LFD.1.10.0805301805490.26788@jlentini-linux.nane.netapp.com>
References: <alpine.LFD.1.10.0805291534360.2898@jlentini-linux.nane.netapp.com> <A04A3C4F-EF91-4204-B28F-E63BFEAF3241@oracle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Tom Tucker <tom@opengridcomputing.com>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Thomas Talpey <talpey@netapp.com>, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:35308 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751620AbYE3WOE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 30 May 2008 18:14:04 -0400
In-Reply-To: <A04A3C4F-EF91-4204-B28F-E63BFEAF3241@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Hi Chuck,

Replies below:

On Fri, 30 May 2008, Chuck Lever wrote:

> Do you still need to invoke the helper directly?  I think this should work
> with a straight mount command after 1.1.2, since the "-i" flag is no longer
> necessary.

Correct. I'll update this.

> If it works, the "permanent" instructions in this documentation should use
> "mount" not "mount.nfs," and specify the command line arguments in the right
> order (doesn't mount like the "-o options" to come before the arguments?).  We

mount.nfs accepts either order, but I'll move the -o options before 
the other arguments to agree with the mount man page.

> shouldn't encourage direct use of the helper subcommand if we can avoid it,
> and it would allow admins to place rdma mounts in /etc/fstab and automounter
> maps.
> 
> In fact, since 1.1.2 is now available, why even mention 1.1.1 in the
> instructions?  It would nicely simplify the text if you start with 1.1.2, and
> the scourge (or ridiculousness?) of the "-i" option need never be mentioned
> again.
> 
> Looking at other parts of nfs-rdma.txt:
> 
> The instructions describing how to build nfs-utils are slightly misleading.
> The "--disable-gss" and "--disable-nfsv4" options do not affect the mount
> command -- the resulting mount.nfs executable still supports NFSv4.
> 
> The true reason to specify these options on ./configure is to prevent
> nfs-utils from building the idmapper and gssd executables, which you don't
> need to replace if you are only installing a new mount.nfs command, and which
> require that the build system have certain other packages installed.

Thanks. I'll correct this.

> You can simply extract the rebuilt mount.nfs command instead of installing the
> whole package with
> 
> 	$ sudo cp utils/mount/mount.nfs /path/to/your/mount.nfs

For mount.nfs to be picked up automatically by mount, mount.nfs needs 
to be at /sbin/mount.nfs, correct? In the instructions, I'll recommend 
that the binary be copied as follows:

 $ sudo cp utils/mount/mount.nfs /sbin/mount.nfs

> 
> The tcp_wrappers package is needed to build nfs-utils in any case, so it would
> be helpful to mention that too.

I'd like to leave that detail to the nfs-utils README. Does that sound 
reasonable?

> It's worth mentioning that several distributions already ship with 
> 1.1.2, so on modern systems, this build step is probably not needed.
> 
> Also, I would use a standard shell prompt in the examples (say, "$ " or "% ",
> or "# " as necessary, instead of "> "), but that's just me.

Good point. ">" is my shell prompt, so it looks natural to me. I'll 
change it to "$".
