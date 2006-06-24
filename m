From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [NFS] Problems with POSIX ACL <=> NFSv4 ACL mapping in mainline
Date: Sat, 24 Jun 2006 14:21:16 +0100
Message-ID: <20060624132116.GA15734@infradead.org>
References: <200606231745.23344.agruen@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marius Aamodt Eriksen <marius@umich.edu>,
	Jeff Sedlak <jsedlak@umich.edu>,
	"J. Bruce Fields" <bfields@umich.edu>,
	linux-fsdevel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-fsdevel-owner@vger.kernel.org>
To: Andreas Gruenbacher <agruen@suse.de>
In-Reply-To: <200606231745.23344.agruen@suse.de>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, Jun 23, 2006 at 05:45:22PM +0200, Andreas Gruenbacher wrote:
> In addition, I could imagine that we'll optionally support local NFSv4-style 
> ACLs on specific file systems somewhen in the future.

Most likely not.  Let's not spread the NFSv4 ACL cancer more than absolutely
nessecary.

> * Don't map between POSIX ACLs and NFSv4 ACLs at all, and use a different
>   protocol for POSIX ACLs and for NFSv4 ACLs instead (e.g., version 4 of the
>   NFSACL protocol extension). The protocol extension is not currently
>   implemented in Solaris because current Solaris supports NFSv4 ACLs natively
>   instead of POSIX ACLs, and so they don't seem to have as strong a motivation
>   to keep POSIX ACLs working well as we currently do. The NFSACL protocol has
>   the huge advantage of supporting POSIX ACLs pretty well, and so a lot of the
>   overhead and complexity of doing the NFSv4 mapping would go away though.

We definitly should support NFSACL for Linux to Linux deployments to avoid
all that mess, yes.

> * Map back from NFSv4 ACLs to POSIX ACLs on the client side, so that
>   POSIX ACLs on the server will appear as POSIX ACLs on the client. This
>   would take away all the mess we currently have in user-space and limit the
>   mapping problems to the NFSv4 protocol, where it really occurs. We could
>   define an additional NFsv4 attribute that the server could use to declare
>   if it supports POSIX ACLs only, so that the client won't have to try to
>   convert from NFSv4 to POSIX ACLs for servers that have native NFSv4 ACLs.

That's probably useful if we want to support non-Linux NFSv4 servers.

