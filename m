From: "William A.(Andy) Adamson" <andros@citi.umich.edu>
Subject: Re: [NFS] Re: [RFC] NLM lock failover admin interface
Date: Thu, 15 Jun 2006 10:07:43 -0400
Message-ID: <20060615140743.36CDC1BBAD@citi.umich.edu>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<17550.11870.186706.36949@cse.unsw.edu.au>
	<1150268091.28264.75.camel@localhost.localdomain>
	<1150293654.28264.91.camel@localhost.localdomain>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	linux clustering <linux-cluster@redhat.com>
Return-path: <linux-cluster-bounces@redhat.com>
To: Wendy Cheng <wcheng@redhat.com>
In-reply-to: <1150293654.28264.91.camel@localhost.localdomain> 
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

this discusion has centered around removing the locks of an export.
we also want the interface to ge able to remove the locks owned by a single 
client. this is needed to enable client migration between replica's or between 
nodes in a cluster file system. it is not acceptable to place an entire export 
in grace just to move a small number of clients.

-->Andy

wcheng@redhat.com said:
> On Wed, 2006-06-14 at 02:54 -0400, Wendy Cheng wrote:
> 
> Assume we still have this on the table.... Could I expect the admin
> interface goes thru rpc.lockd command (man page and nfs-util code
> changes) ? The modified command will take similar options as rpc.statd;
> more specifically, the -n, -o, and -p (see "man rpc.statd"). To pass the
> individual IP (socket address) to kernel, we'll need nfsctl with struct
> nfsctl_svc modified.
>
> I want to make sure people catch this. Here we're talking about NFS system
> call interface changes. We need either a new NFS syscall or altering the
> existing nfsctl_svc structure.

> -- Wendy
