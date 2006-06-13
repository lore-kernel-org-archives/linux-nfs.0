From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [NFS] [RFC] NLM lock failover admin interface
Date: Tue, 13 Jun 2006 03:00:11 -0400
Message-ID: <1150182012.27203.42.camel@localhost.localdomain>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<17550.11870.186706.36949@cse.unsw.edu.au>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-cluster@redhat.com, nfs@lists.sourceforge.net
Return-path: <linux-cluster-bounces@redhat.com>
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17550.11870.186706.36949@cse.unsw.edu.au>
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

On Tue, 2006-06-13 at 13:17 +1000, Neil Brown wrote:

> So:
>  I think if we really want to "remove all NFS locks on a filesystem",
>  we could probably tie it into umount - maybe have lockd register some
>  callback which gets called just before s_op->umount_begin.

The "umount_begin" idea was one time on my list but got discarded. The
thought was that nfsd was not a filesystem, neither was lockd. How to
register something with VFS umount for non-filesystem kernel modules ?
Invent another autofs-like pseudo filesystem ? Mostly, not every
filesystem would like to get un-mounted upon failover (GFS, for example,
does not get un-mounted by our cluster suite upon failover).

>  If we want to remove all locks that arrived on a particular
>  interface, then we should arrange to do exactly that.  There are a
>  number of different options here. 
>   One is the multiple-lockd-threads idea.

Certainly a good option. To make it happen, we still need admin
interface. How to pass IP address from user mode into kernel - care to
give this some suggestions if you have them handy ? Should socket ports
get dynamics assigned ? Will we have scalibility issues ? 
 
>   One is to register a callback when an interface is shut down.
>   Another (possibly the best) is to arrange a new signal for lockd
>   which say "Drop any locks which were sent to IP addresses that are
>   no longer valid local addresses".

These, again, give individual filesystem no freedom to adjust what they
need upon failover. But I'll check them out this week - maybe there are
good socket layer hooks that I overlook. 

> 
> So those are my thoughts.  Do any of them seem reasonable to you?
> 

The comments are greatly appreciated. And hopefully we can reach
agreement soon.   

-- Wendy
