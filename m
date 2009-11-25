From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 1/6] nfsd: Remove nfsfh.h dependency on sunrpc
Date: Wed, 25 Nov 2009 15:57:23 -0500
Message-ID: <20091125205723.GM32502@fieldses.org>
References: <4B0AB039.6020608@panasas.com> <1258991910-25335-1-git-send-email-bharrosh@panasas.com> <20091123221705.GF8534@fieldses.org> <4B0B994B.10108@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Benny Halevy <bhalevy@panasas.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>,
	Al Viro <viro@ZenIV.linux.org.uk>,
	Randy Dunlap <randy.dunlap@oracle.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4B0B994B.10108@panasas.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 24, 2009 at 10:28:59AM +0200, Boaz Harrosh wrote:
> On 11/24/2009 12:17 AM, J. Bruce Fields wrote:
> > On Mon, Nov 23, 2009 at 05:58:30PM +0200, Boaz Harrosh wrote:
> >> linux/nfsd/nfsfh.h defines some low level types which
> >> are needed by exportfs and though by filesystems.
> >>
> >> In the file, fh_lock() uses the sunrpc dprint facility which
> >> might cause a dependency of exportfs (and filesystems) on
> > 
> > "might cause"?
> > 
> > Does mere inclusion of this .h (without referencing fh_lock_nested() or
> > its callers) actually create a dependency?
> > 
> > --b.
> > 
> 
> No, only if code actually uses fh_lock_nested it will cause a dependency.
> Which is only used in fs/nfsd/...
> 
> But I would like to discourage nfsd/debug.h at this level.
> 
> Should I move fh_lock_nested() and it's siblings to the new private vfs.h header
> you made, and get rid of it this way?

Sure, that sounds reasonable.

--b.
