From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC] NLM lock failover admin interface
Date: Thu, 15 Jun 2006 18:02:48 +1000
Message-ID: <17553.5160.366425.740082@cse.unsw.edu.au>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<17550.11870.186706.36949@cse.unsw.edu.au>
	<1150268091.28264.75.camel@localhost.localdomain>
	<17552.57749.121240.42384@cse.unsw.edu.au>
	<1150353564.4566.89.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-cluster@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fqmom-0007LV-Ea
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 01:03:08 -0700
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fqmoi-0001YO-Dy
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 01:03:08 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: message from Wendy Cheng on Thursday June 15
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thursday June 15, wcheng@redhat.com wrote:
> On Thu, 2006-06-15 at 14:27 +1000, Neil Brown wrote:
> 
> > You started out suggesting that the required functionality was to
> > "remove all locks that lockd holds on a particular filesystem".
> 
> I didn't make this clear. No, we don't want to "remove all locks
> associated with a particular filesystem". We want to "remove all locks
> associated with an NFS service" - one NFS service is normally associated
> with one NFS export. For example, say in /etc/exports:
> 
> /mnt/export_fs/dir_1     *(fsid=1,async,rw)
> /mnt/export_fs/dir_2     *(fsid=2,async,rw)

That makes sense.

> 
> One same filesystem (export_fs) is exported via two entries, each with
> its own fsid. The "fsid" is eventually encoded as part of the filehanlde
> stored into "struct nlm_file" and linked into nlm_file global list. 
> 
> This is to allow, not only active-active failover (for local filesystem
> such as ext3), but also load balancing for cluster file systems (such as
> GFS). 

Could you please explain to me what "active-active failover for local
filesystem such as ext3" means (I'm not very familiar with cluster
terminology).
It sounds like the filesystem is active on two nodes at once, which of
course cannot work for ext3, so I am confused.
And if you are doing "failover", what has failed?

The load-balancing scenario makes sense (at least so far...).

> 
> In reality, each NFS service is associated with one virtual IP. The
> failover and load-balancing tasks are carried out by moving the virtual
> IP around - so I'm ok with the idea of "remove all locks that lockd
> holds on behalf of a particular IP address".
>   

Good. :-)

> > 
> > Lockd is not currently structured to associate locks with
> > server-ip-addresses.  There is an assumption that one client may talk
> > to any of the IP addresses that the server supports.  This is clearly
> > not the case for the failover scenario that you are considering, so a
> > little restructuring might be in order.
> > 
> > Some locks will be held on behalf of a client, no matter what
> > interface the requests arrive on.  Other locks will be held on behalf
> > of a client and tied to a particular server IP address.  Probably the
> > easiest way to make this distinction in as a new nfsd export flag.
> 
> We're very close now - note that I originally proposed adding a new nfsd
> export flag (NFSEXP_FOLOCKS) so we can OR it into export's ex_flag upon
> un-export. If the new action flag is set, a new sub-call added into
> unexport kernel routine will walk thru nlm_file to find the export entry
> (matched by either fsid or devno, taken from filehandle, within nlm_file
> struct); then subsequently release the lock.   
> 
> The ex_flag is an "int" but currently only used up to 16 bit. So my new
> export flag is defined as: NFSEXP_FOLOCKS 0x00010000. 
> 

Our two export flags mean VERY different things.
Mine says 'locks against this export are per-server-ip-address'.
Yours says (I think) 'remove all lockd locks from this export' and is
really an unexport flag, not an export flag.

And this makes it not really workable.  We no-longer require the user
of the nfssvc syscall to unexport filesystems.  Infact nfs-utils doesn't
use it at all if /proc/fs/nfsd is mounted.  filesystems are unexported
by their entry in the export cache expiring, or the cache being
flushed.

There is simply no room in the current knfsd design for an unexport
flag - sorry ;-(


> > 
> > So, maybe something like this:
> > 
> >   Add a 'struct sockaddr_in' to 'struct nlm_file'.
> >   If nlm_fopen return (say) 3, then treat is as success, and 
> >     also copy rqstp->rq_addr into that 'sockaddr_in'.
> >   define a new file in the 'nfsd' filesystem into which can
> >     be written an IP address and which calls some new lockd
> >     function which releases all locks held for that IP address.
> >   Probably get nlm_lookup_file to insist that if the sockaddr_in
> >     is defined in a lock, it must match the one in rqstp
> 
> Yes, we definitely can do this but there is a "BUT" from our end. What I
> did in my prototyping code is taking filehandle from nlm_file structure
> and yank the fsid (or devno) out of it (so we didn't need to know the
> socket address). With (your) above approach, adding a new field into
> "struct nlm_file" to hold the sock addr, sadly say, violates our KABI
> policy. 

Does it?
'struct nlm_file' is a structure that is entirely local to lockd.
It does not feature in any of the interface between lockd and any
other part of the kernel.  It is not part of any credible KABI.
The other changes I suggest involve adding an exported symbol to
lockd, which does change the KABI but in a completely back-compatible
way, and re-interpreting the return value of a callout.  
That could not break any external module - it could only break
someone's setup if they had an alternate lockd module, but I don't
your KABI policy allows people to replace modules and stay supported,

However, as you say....

> 
> I learnt my lesson. Forget KABI for now. Let me see what you have in the
> next paragraph (so I can know how to response ...)
> 

....we aren't going to let KABI issues get in our way.

> > 
> > 
> > > >   One is the multiple-lockd-threads idea.
> > 
> > I'm losing interest in the multiple-lockd-threads approach myself (for
> > the moment anyway :-)
> > However I would be against trying to re-use rpc.lockd - that was a
> > mistake that is best forgotten.
> > If the above approach were taken, then I don't think you need anything
> > more than
> >    echo aa.bb.cc.dd > /proc/fs/nfsd/vserver_unlock
> > (or whatever), though it you really want to wrap that in a shell
> > script that might be ok.
> 
> This is funny - so we go back to /proc. OK with me :)

Only sort-of back to /proc.  /proc/fs/nfsd is a separate filesystem
which happens to be mounted there normally.
The unexport system call goes through this exact same filesystem
(though it is somewhat under-the-hood) so at that level, we are
really propose the same style of interface implementation.

>                                                       but you may want
> to re-think my exportfs command approach. Want me to go over the
> unexport flow again ? The idea is to add a new user mode flag, say "-h".
> If you unexport the interface as:
> 
> shell> exportfs -u *:/export_path   // nothing happens, old behavior
> 
> but if you do:
> 
> shell> exportfs -hu *:/export_patch  // the kernel code would walk thru 
>                                      // nlm_file list to release the
>                                      // the locks.
> 
> The "-h" "OR" 0x0001000 into ex_flags field of struct nfsctl_export so
> kernel can know what to do. With fsid (or devno) in filehandle within
> nlm_file, we don't need socket address at all. 

But apart from nfsctl_export being a dead end, this is still
exportpoint specific rather than IP address specific.

> 
> But again, I'm OK with /proc approach. However, with /proc approach, we
> may need socket address (since not every export uses fsid and devno is
> not easy to get).

Absolutely. We need a socket address.  
As part of this process you are shutting down an interface.  We know
(or can easily discover) the address of that interface.  That is
exactly the address that we feed to nfsd.

> 
> Do we agree now ? In simple sentence, I prefer my original "exportfs -
> hu" approach. But I'm ok with /proc if you insist.
> 

I'm not at an 'insist'ing stage at the moment - I like to at least
pretend to be open minded :-)

The main thing I don't like about your "exportfs -hu" approach is that
I don't think it will work (actually, looking at nfs-utils, I'm not so
sure that "exportfs -u" will work at all if you don't have 
/proc/fs/nfsd mounted....)

The other thing I don't like is that it doesn't address your primary
need - decommissioning an IP address.
Rather it addresses a secondary need - removing some locks from some
filesystems. 

But I'm still open to debate...

> 
> > 
> > > 
> > > For the kernel piece, since we're there anyway, could we have the
> > > individual lockd IP interface passed to SM (statd) (in SM_MON call) ?
> > > This would allow statd to structure its SM files based on each lockd IP
> > > address, an important part of lock recovery.
> > > 
> > 
> > Maybe....  but I don't get the scenario.
> > Surely the SM files are only needed when the server  restarts, and in
> > that case it needs to notify all clients... Or is it that you want to
> > make sure the notification comes from the right IP address.... I guess
> > that would make sense.  I that what you are after?
> 
> Yes ! Right now, lockd doesn't pass the specific server address (that
> client connects to) to statd. I don't know how the "-H" can ever work.
> Consider this a bug. If you forget what "rpc.statd -H" is, check out the
> man page (man rpc.statd).

I have to admit I have never given that code a lot of attention.  I
reviewed when sent it - it seemed to make sense and had no obvious
problems - so I accepted it.  I wouldn't be enormously surprised if it
didn't work in some situations.

> 
> Thank you for the patience - I'm grateful.

Ditto.
Conversations work much better when people are patient and polite.

Thanks,
NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
