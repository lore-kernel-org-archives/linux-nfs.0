From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: Re: [NFS] [RFC] NLM lock failover admin interface
Date: Wed, 14 Jun 2006 10:00:54 -0400
Message-ID: <1150293654.28264.91.camel@localhost.localdomain>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<17550.11870.186706.36949@cse.unsw.edu.au>
	<1150268091.28264.75.camel@localhost.localdomain>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
Return-path: <linux-cluster-bounces@redhat.com>
To: linux clustering <linux-cluster@redhat.com>
In-Reply-To: <1150268091.28264.75.camel@localhost.localdomain>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/linux-cluster>,
	<mailto:linux-cluster-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-cluster>
List-Post: <mailto:linux-cluster@redhat.com>
List-Help: <mailto:linux-cluster-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-cluster>,
	<mailto:linux-cluster-request@redhat.com?subject=subscribe>
Sender: linux-cluster-bounces@redhat.com
Errors-To: linux-cluster-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

On Wed, 2006-06-14 at 02:54 -0400, Wendy Cheng wrote:

> 
> Assume we still have this on the table.... Could I expect the admin
> interface goes thru rpc.lockd command (man page and nfs-util code
> changes) ? The modified command will take similar options as rpc.statd;
> more specifically, the -n, -o, and -p (see "man rpc.statd"). To pass the
> individual IP (socket address) to kernel, we'll need nfsctl with struct
> nfsctl_svc modified.

I want to make sure people catch this. Here we're talking about NFS
system call interface changes. We need either a new NFS syscall or
altering the existing nfsctl_svc structure.

-- Wendy

> 
> For the kernel piece, since we're there anyway, could we have the
> individual lockd IP interface passed to SM (statd) (in SM_MON call) ?
> This would allow statd to structure its SM files based on each lockd IP
> address, an important part of lock recovery.
> 
> >   One is to register a callback when an interface is shut down.
> 
> Haven't checked out (linux) socket interface yet. I'm very fuzzy how
> this can be done. Anyone has good ideas ? 
> 
> >   Another (possibly the best) is to arrange a new signal for lockd
> >   which say "Drop any locks which were sent to IP addresses that are
> >   no longer valid local addresses".
> 
> Very appealing - but the devil's always in the details. How to decide
> which IP address is no longer valid ? Or how does lockd know about these
> IP addresses ? And how to associate one particular IP address with the
> "struct nlm_file" entries within nlm_files list ? Need few more days to
> sort this out (or any one already has ideas in mind ?).
> 
> -- Wendy
> 
> --
> Linux-cluster mailing list
> Linux-cluster@redhat.com
> https://www.redhat.com/mailman/listinfo/linux-cluster
