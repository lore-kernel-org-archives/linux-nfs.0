From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 3/4 Revised] NLM - kernel lockd-statd changes
Date: Wed, 11 Apr 2007 14:50:04 +1000
Message-ID: <17948.26876.426822.963222@notabene.brown>
References: <46156FA0.4030506@redhat.com>
	<200704101109.44333.okir@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net
To: Olaf Kirch <okir@lst.de>, Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HbUmg-0000zp-7h
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 21:50:18 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HbUmi-0000aE-5b
	for nfs@lists.sourceforge.net; Tue, 10 Apr 2007 21:50:20 -0700
In-Reply-To: message from Olaf Kirch on Tuesday April 10
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

On Tuesday April 10, okir@lst.de wrote:
> On Thursday 05 April 2007 23:52, Wendy Cheng wrote:
> > The changes record the ip interface that accepts the lock requests and 
> > passes the correct "my_name" (in standard IPV4 dot notation) to user 
> > mode statd (instead of system_utsname.nodename). This enables rpc.statd 
> > to add the correct taken-over IPv4 address into the 3rd parameter of 
> > ha_callout program. Current nfs-utils always resets "my_name" into 
> > loopback address (127.0.0.1), regardless the statement made in rpc.statd 
> > man page. Check out "man rpc.statd" and "man sm-notify" for details.
> 
> I don't think this is the right approach. For one, there's not enough
> room in the SM_MON request to accomodate an additional IPv6
> address, so you would have to come up with something entirely
> different for IPv6 anyway. But more importantly, I think we should
> move away from associating all sorts of network level addresses
> with lockd state - addresses are just smoke and mirrors. Despite
> all of NLM/NSMs shortcomings, there's a vehicle to convey identity,
> and that's mon_name. IMHO the focus should be on making it work
> properly if it doesn't do what you do.

I don't understand your complaint.
You say there's "not enough room", but the extra information is being
placed in the 'my_name' string which is up to 1024 bytes long, which
I think is long enough.

You say that "mon_name" is the vehicle to convey identity and while
that is true, I don't think it is relevant as it is the identity of
the *server* that is being conveyed, rather than the identity of the
client (this on an NFS server).

Think of it like this.  The goal is (appears to be) to make it
possible to implement multiple independent NFS servers on the one
Linux host.
As a simplification, each server serves precisely one filesystem which
no other server serves, and each server has precisely one network
address which no other server shares.

So the 'servers' can be identified either by the filesystem (or FSID)
or by the network address.

Most NFS operations are file-local or at most filesystem-local and so
they don't need to care that there are multiple servers.  But locking
and peer-restart in particular is not.  It is server-local.  So for
the peer monitoring/notification operations, we need to enhance to
model to make the server name explicit rather than implicit ('this
host').

To allow a 'server' to migrate from one host to another (active-active
failover) we need to synthesise a reboot which means knowing which
clients are using which server.

lockd knows which is which either based on the destination network
address of the lock request, or the filesystem on which the lock was
taken.   Somehow this information needs to get communicated to statd
so that different 'sm' directories can be used.  my_name seems a
sensible place to put the information.


However:  now that I think I actually understand what is happening, I
wonder if FSID and IPaddress are really the right handles to use.  It
would seem to make more sense to use the filesystem name (i.e. a
path).

So I'm suggesting writing a directory name to
    /proc/fs/nfsd/nlm_unlock
and maybe also to
    /proc/fs/nlm_restart_grace_for_fs

and have 'my_name' in the SM_MON request be the path name of the
export point rather the network address.

Thinking more,  lockd would need to know whether each filesystem is an
independent server so that it knows if independent nsm objects are
needed.

So maybe we want an export flag "active_failover".
If this is set then the filesystem has an independent grace period
that starts on first export (except that 'first export' isn't really a
well defined concept) and lockd treats clients using that filesystem
as different from the same client using any other filesystem.

I'm not sure we really need the 'nlm_unlock' interface either.  We can
just synthesis incoming SM_NOTIFYs from all clients of that filesystem
and the locks will go away.

Not that I'm saying we have to use this approach rather than the
current one.  I'm just exploring the issue and making sure that I
understand it.


> 
> But - why do you need to record the address on which the request was
> received. at all? Don't you know beforehand on which IP addresses you
> will be servicing NFS requests, and which will need to be migrated?
> 
> Side note: should we think about replacing SM_MON with some new
> design altogether (think netlink)?

Well, I want something new to support the various state that needs to
be recorded by NFSv4, and what ever gets created could probably be
used for lockd/statd too.
But given that we have SM_MON implemented, what is so broken that it
needs to be replaced?

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
