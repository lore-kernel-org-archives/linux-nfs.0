From: Valerie Aurora <vaurora@redhat.com>
Subject: Re: Union mounts, NFS, and locking
Date: Tue, 14 Jul 2009 20:19:33 -0400
Message-ID: <20090715001933.GI27582@shell>
References: <20090714220515.GH27582@shell> <200907142233.n6EMXRQp019008@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Jan Blunck <jblunck@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Erez Zadok <ezk@cs.sunysb.edu>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <200907142233.n6EMXRQp019008@agora.fsl.cs.sunysb.edu>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 14, 2009 at 06:33:27PM -0400, Erez Zadok wrote:
> In message <20090714220515.GH27582@shell>, Valerie Aurora writes:
> > On Tue, Jul 14, 2009 at 04:36:40PM -0400, Erez Zadok wrote:
> > > In message <20090714201940.GF27582@shell>, Valerie Aurora writes:
> > >
> > > > Okay, so my best idea for a solution is to introduce a new NFS mount
> > > > option that means the server promises that the exported file system is
> > > > read-only (using superblock read-only count scheme locally).  E.g.:
> > > 
> > > How would the server be able to guarantee that?  Are you planning to change
> > > the protocol or implementation somehow?  Are you assuming that the server
> > > will be running linux w/ special r/o sb support?  If so, it won't work on
> > > other platforms (NFS is supposed to be interoperable in principle :-)
> > > 
> > > Without a protocol change, such an option (if I understood you), is at best
> > > a server promise to "behave nice."
> > 
> > Yeah, it's just a promise, one that the NFS server shouldn't make if
> > it can't implement it.  The client's sole responsibility is to fail
> > gracefully if the server breaks its promise.
> [...]
> 
> How would the client detect that the server broke the promise?

The same way we detect other NFS server bugs - frequently by crashing
the client, but in the best case hitting code like:

fs/nfs/inode.c.:

        if (!fattr->nlink) {
                printk("NFS: Buggy server - nlink == 0!\n");
                goto out_no_inode;
        }

If the server happily mounts with the server_ro option, and then
writes to the exported file system, it's buggy.  Deal accordingly.

-VAL
