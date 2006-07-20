From: Neil Brown <neilb@suse.de>
Subject: Re: NFSv4 Active-Active Cluster Queries
Date: Thu, 20 Jul 2006 17:12:25 +1000
Message-ID: <17599.11481.634050.489349@cse.unsw.edu.au>
References: <44BCC5620200007F0000E2C6@lucius.provo.novell.com>
	<44BCD1F80200007F0000E2CA@lucius.provo.novell.com>
	<44BCE7BB0200007F0000E2E7@lucius.provo.novell.com>
	<44BF54250200007F0000E3E0@lucius.provo.novell.com>
	<44BF5EF80200007F0000E3E4@lucius.provo.novell.com>
	<44BF5F580200007F0000E3E7@lucius.provo.novell.com>
	<44BF5F8B0200007F0000E3EA@lucius.provo.novell.com>
	<44BF607D0200007F0000E3ED@lucius.provo.novell.com>
	<44BF6B4F0200007F0000E3F6@lucius.provo.novell.com>
	<44BF6B870200007F0000E3F9@lucius.provo.novell.com>
	<44BF6BA30200007F0000E3FC@lucius.provo.novell.com>
	<44BF6BE60200007F0000E3FF@lucius.provo.novell.com>
	<44BF6BE5.6FDC.007F.0@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
To: "Rajat Upadhyaya" <urajat@novell.com>
In-Reply-To: message from Rajat Upadhyaya on Thursday July 20
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

On Thursday July 20, urajat@novell.com wrote:
> Hi,
> 
> I have been working on setting up NFSv4 in cluster scenario. But when
> it comes to an Active-Active setup, it seems there are a few problems. 
> 
> In Active-Passive case, the /var/lib/nfs directory itself is moved to
> shared storage & on the nodes in the cluster, symlinks are created
> pointing to the location on shared storage. This isn't possible in case
> of Active-Active setup. In this case, we will need to use scripts to
> merge the information in /var/lib/nfs from the failed node with that on
> the running one and then do a re-export. 
> 
> 1) From the High Availability wiki (http://wiki.linux-ha.org), I got to
> this page -
> http://chilli.linuxmds.com/~mschilli/NFS/active-active-nfs.html where
> a method of setting up Active-Active NFS failover was described.
> Basically a set of scripts is used to duplicate the rmtab entries on the
> node that takes over the process during failover. Will this method hold
> in case of NFSv4 too? What other data would need to be duplicated?

rmtab is simply not an issue - you can ignore it.
Provided /proc/fs/nfsd is mounted, the contents of rmtab are ignored.

What is important is locking state.  For NFSv4, that means the 
contents of /var/lib/nfs/v4recovery.  I don't know exactly how this is
handled.

> 
> 3) Locking issues - revocation & reacquiring of locks.

Wendy Cheng <wcheng@redhat.com> has been looking at what kernel/utils
changes are needed to support this fully, though I think she is only
looking at v3.

> 
> 4) I can see that there is some HA callout code in nfs-utils (under
> support). Is this applicable for NFSv4 also?

No.  Currently all v4 state is handled by the kernel, though that may change.

NeilBrown
