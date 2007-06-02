From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [NFS] [PATCH] locks: provide a file lease method enabling
	cluster-coherent leases
Date: Sat, 02 Jun 2007 13:39:10 -0400
Message-ID: <1180805950.6687.17.camel@heimdal.trondhjem.org>
References: <1180647624483-git-send-email-bfields@fieldses.org>
	 <11806476252240-git-send-email-bfields@fieldses.org>
	 <11806476252913-git-send-email-bfields@fieldses.org>
	 <1180650849.7084.19.camel@heimdal.trondhjem.org>
	 <20070601165317.GE10492@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-fsdevel@vger.kernel.org,
	David Teigland <teigland@redhat.com>,
	nfs@lists.sourceforge.net, Marc Eshel <eshel@almaden.ibm.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20070601165317.GE10492@fieldses.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Fri, 2007-06-01 at 12:53 -0400, J. Bruce Fields wrote:
> > It also means that you're calling twice down
> > into the filesystem for every call to may_open() (once for
> > vfs_permission() and once for break_lease()) and 3 times in
> > do_sys_truncate().
> > 
> > Would it perhaps make sense to package up the call to vfs_permission()
> > and break_lease() as a single 'may_open()' inode operation that could be
> > called by may_open(), do_sys_truncate() and nfsd?
> 
> Could be, but this may no longer make sense when we try to do
> lease-breaking on rename and unlink.

Hmm... Clustered lease breaking on rename and unlink really needs to be
done _atomically_ with the actual operation. It really needs to be done
inside the ->rename() and ->unlink() operation because only the
filesystem can guarantee atomicity.

Thinking about it, perhaps the may_open() thing is wrong too: again, you
have atomicity requirements inside the open() call. A break_lease()
inode operation won't help either...

Trond

