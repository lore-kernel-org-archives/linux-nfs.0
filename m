From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [NFS] [RFC] NLM lock failover admin interface
Date: Thu, 15 Jun 2006 02:39:24 -0400
Message-ID: <1150353564.4566.89.camel@localhost.localdomain>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<17550.11870.186706.36949@cse.unsw.edu.au>
	<1150268091.28264.75.camel@localhost.localdomain>
	<17552.57749.121240.42384@cse.unsw.edu.au>
Reply-To: linux clustering <linux-cluster@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net, linux-cluster@redhat.com
Return-path: <linux-cluster-bounces@redhat.com>
To: Neil Brown <neilb@suse.de>
In-Reply-To: <17552.57749.121240.42384@cse.unsw.edu.au>
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

On Thu, 2006-06-15 at 14:27 +1000, Neil Brown wrote:

> You started out suggesting that the required functionality was to
> "remove all locks that lockd holds on a particular filesystem".

I didn't make this clear. No, we don't want to "remove all locks
associated with a particular filesystem". We want to "remove all locks
associated with an NFS service" - one NFS service is normally associated
with one NFS export. For example, say in /etc/exports:

/mnt/export_fs/dir_1     *(fsid=1,async,rw)
/mnt/export_fs/dir_2     *(fsid=2,async,rw)

One same filesystem (export_fs) is exported via two entries, each with
its own fsid. The "fsid" is eventually encoded as part of the filehanlde
stored into "struct nlm_file" and linked into nlm_file global list. 

This is to allow, not only active-active failover (for local filesystem
such as ext3), but also load balancing for cluster file systems (such as
GFS). 

In reality, each NFS service is associated with one virtual IP. The
failover and load-balancing tasks are carried out by moving the virtual
IP around - so I'm ok with the idea of "remove all locks that lockd
holds on behalf of a particular IP address".
  
> 
> Lockd is not currently structured to associate locks with
> server-ip-addresses.  There is an assumption that one client may talk
> to any of the IP addresses that the server supports.  This is clearly
> not the case for the failover scenario that you are considering, so a
> little restructuring might be in order.
> 
> Some locks will be held on behalf of a client, no matter what
> interface the requests arrive on.  Other locks will be held on behalf
> of a client and tied to a particular server IP address.  Probably the
> easiest way to make this distinction in as a new nfsd export flag.

We're very close now - note that I originally proposed adding a new nfsd
export flag (NFSEXP_FOLOCKS) so we can OR it into export's ex_flag upon
un-export. If the new action flag is set, a new sub-call added into
unexport kernel routine will walk thru nlm_file to find the export entry
(matched by either fsid or devno, taken from filehandle, within nlm_file
struct); then subsequently release the lock.   

The ex_flag is an "int" but currently only used up to 16 bit. So my new
export flag is defined as: NFSEXP_FOLOCKS 0x00010000. 

> 
> So, maybe something like this:
> 
>   Add a 'struct sockaddr_in' to 'struct nlm_file'.
>   If nlm_fopen return (say) 3, then treat is as success, and 
>     also copy rqstp->rq_addr into that 'sockaddr_in'.
>   define a new file in the 'nfsd' filesystem into which can
>     be written an IP address and which calls some new lockd
>     function which releases all locks held for that IP address.
>   Probably get nlm_lookup_file to insist that if the sockaddr_in
>     is defined in a lock, it must match the one in rqstp

Yes, we definitely can do this but there is a "BUT" from our end. What I
did in my prototyping code is taking filehandle from nlm_file structure
and yank the fsid (or devno) out of it (so we didn't need to know the
socket address). With (your) above approach, adding a new field into
"struct nlm_file" to hold the sock addr, sadly say, violates our KABI
policy. 

I learnt my lesson. Forget KABI for now. Let me see what you have in the
next paragraph (so I can know how to response ...)

> 
> 
> > >   One is the multiple-lockd-threads idea.
> 
> I'm losing interest in the multiple-lockd-threads approach myself (for
> the moment anyway :-)
> However I would be against trying to re-use rpc.lockd - that was a
> mistake that is best forgotten.
> If the above approach were taken, then I don't think you need anything
> more than
>    echo aa.bb.cc.dd > /proc/fs/nfsd/vserver_unlock
> (or whatever), though it you really want to wrap that in a shell
> script that might be ok.

This is funny - so we go back to /proc. OK with me :) but you may want
to re-think my exportfs command approach. Want me to go over the
unexport flow again ? The idea is to add a new user mode flag, say "-h".
If you unexport the interface as:

shell> exportfs -u *:/export_path   // nothing happens, old behavior

but if you do:

shell> exportfs -hu *:/export_patch  // the kernel code would walk thru 
                                     // nlm_file list to release the
                                     // the locks.

The "-h" "OR" 0x0001000 into ex_flags field of struct nfsctl_export so
kernel can know what to do. With fsid (or devno) in filehandle within
nlm_file, we don't need socket address at all. 

But again, I'm OK with /proc approach. However, with /proc approach, we
may need socket address (since not every export uses fsid and devno is
not easy to get).

Do we agree now ? In simple sentence, I prefer my original "exportfs -
hu" approach. But I'm ok with /proc if you insist.


> 
> > 
> > For the kernel piece, since we're there anyway, could we have the
> > individual lockd IP interface passed to SM (statd) (in SM_MON call) ?
> > This would allow statd to structure its SM files based on each lockd IP
> > address, an important part of lock recovery.
> > 
> 
> Maybe....  but I don't get the scenario.
> Surely the SM files are only needed when the server  restarts, and in
> that case it needs to notify all clients... Or is it that you want to
> make sure the notification comes from the right IP address.... I guess
> that would make sense.  I that what you are after?

Yes ! Right now, lockd doesn't pass the specific server address (that
client connects to) to statd. I don't know how the "-H" can ever work.
Consider this a bug. If you forget what "rpc.statd -H" is, check out the
man page (man rpc.statd).

Thank you for the patience - I'm grateful.

-- Wendy
