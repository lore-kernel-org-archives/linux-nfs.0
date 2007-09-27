From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: NFS server development update
Date: Thu, 27 Sep 2007 11:39:56 -0400
Message-ID: <20070927153956.GF2522@fieldses.org>
References: <20070927153233.GE2522@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-kernel@vger.kernel.org
To: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <20070927153233.GE2522@fieldses.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

On Thu, Sep 27, 2007 at 11:32:33AM -0400, J. Bruce Fields wrote:
> I'll follow up with a summary of the patches I currently have.

... but this time around that's nothing major--mostly just small
bugfixes and cleanup, including 64 bit inode support from Peter Staubach
and some preparation for supporting callbacks (hence delegations) over
krb5.

One outstanding question is what to do about the server RDMA and
transport-switch code, not yet included below.  It would nice to finally
see that start going in, but it's a lot of code to add this late.

--b.

>From git://linux-nfs.org/~bfields/linux.git nfs-server-stable:

Andrew Morton (1):
      nfsd warning fix

Christoph Hellwig (1):
      nfsd: fix horrible indentation in nfsd_setattr

Dr. David Alan Gilbert (1):
      knfsd: Add source address to sunrpc svc errors

J. Bruce Fields (14):
      nfsd: tone down inaccurate dprintk
      nfsd: remove unused cache_for_each macro
      knfsd: delete code made redundant by map_new_errors
      knfsd: cleanup of nfsd4 cmp_* functions
      knfsd: demote some printk()s to dprintk()s
      knfsd: nfs4 name->id mapping not correctly parsing negative downcall
      knfsd: spawn kernel thread to probe callback channel
      knfsd: move nfsv4 slab creation/destruction to module init/exit
      knfsd: fix callback rpc cred
      knfsd: remove code duplication in nfsd4_setclientid()
      svcgss: move init code into separate function
      knfsd: let nfsd manage timing out its own leases
      knfsd: don't shutdown callbacks until nfsv4 client is freed
      knfsd: nfsv4 delegation recall should take reference on client

Peter Staubach (1):
      knfsd: 64 bit ino support for NFS server
