From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: linux-next: nfs tree build failures
Date: Mon, 06 Apr 2009 10:43:53 +0300
Message-ID: <49D9B2B9.5010401@panasas.com>
References: <20090406162905.7d2d7037.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-next@vger.kernel.org, Andy Adamson <andros@netapp.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20090406162905.7d2d7037.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Apr. 06, 2009, 9:29 +0300, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi Trond,
> 
> Today's linux-next build (powerpc ppc44x_config) failed like this:
> 
> fs/nfs/client.c: In function 'nfs_match_client':
> fs/nfs/client.c:444: error: 'struct nfs_client' has no member named 'cl_minorversion'
> 
> Caused by commit 10d5a514705f0687cfbb6a080c3562b857e340fe ("nfs41: Use
> mount minorversion option").  The existence of cl_minorversion is
> controlled by CONFIG_NFS_V4 but the reference is not.


Stephan,

First, thanks! I apologize for introducing this.
This was caused by a late fix to Trond's review comment which
apparently was under-tested, as you mentioned.

> 
> I added the small patch below for today.

Based on Trond's review comment:
http://linux-nfs.org/pipermail/pnfs/2009-March/006938.html

We'd actually want to keep cl_minorversion's usage in the clear
and rather move its definition out of the #ifdef.

Please see PATCH 1/3 in reply to this message.

> 
> The same build gets this warning as well:
> 
> fs/nfs/client.c:554: warning: 'nfs4_session_set_rwsize' defined but not used

This one needs to go under CONFIG_NFS_V4.
See PATCH 2/2

> 
> and then fails like this:
> 
> fs/built-in.o: In function `nfs_readpage_result_full':
> read.c:(.text+0x70d24): undefined reference to `nfs4_restart_rpc'
> fs/built-in.o: In function `nfs_readpage_result_partial':
> read.c:(.text+0x70e3c): undefined reference to `nfs4_restart_rpc'
> fs/built-in.o: In function `nfs_async_unlink_done':
> unlink.c:(.text+0x71af0): undefined reference to `nfs4_restart_rpc'
> fs/built-in.o: In function `nfs_writeback_done':
> (.text+0x72c00): undefined reference to `nfs4_restart_rpc'
> 
> Caused by commit c105a9f16f11aaa9fcb9f75f8342b89c5d9665cf ("nfs41: use
> rpc prepare call state for session reset") which I have reverted for
> today.

See PATCH 3/3 that inlines nfs4_restart_rpc's definition.

Benny

> 
> Trond, is all this NFS v4.1 stuff that turned up yesterday really 2.6.30
> material?  If not, it should be removed from linux-next until after
> 2.6.30-rc1 is released.  (and clearly better tested ...)
> 
> Bruce, I guess the same question applies to the nfsd tree as well.
