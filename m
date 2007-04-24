From: Neil Brown <neilb@suse.de>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Tue, 24 Apr 2007 15:52:03 +1000
Message-ID: <17965.39683.396108.623418@notabene.brown>
References: <46156F3F.3070606@redhat.com> <4625204D.1030509@redhat.com>
	<17959.5245.635902.823441@notabene.brown>
	<462D79F0.4060800@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
To: wcheng@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HgDwp-0000AJ-Dc
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 22:52:19 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HgDwr-0005oh-2j
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 22:52:22 -0700
In-Reply-To: message from Wendy Cheng on Monday April 23
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

On Monday April 23, wcheng@redhat.com wrote:
> Neil Brown wrote:
> 
> >One thing that has been bothering me is that sometimes the
> >"filesystem" (in the guise of an fsid) is used to talk to the kernel
> >about failover issues (when flushing locks or restarting the grace
> >period) and sometimes the local network address is used (when talking
> >with statd). 
> 
> This is a perception issue - it depends on how the design is described. 

Perception affects understanding.  Understanding is vital.

> More on this later.

OK.

> 
> >I would rather use a single identifier.  In my previous email I was
> >leaning towards using the filesystem as the single identifier.  Today
> >I'm leaning the other way - to using the local network address.
> >  
> >
> Guess you're juggling with too many things so forget why we came down to 
> this route ?

Probably :-)

>              We started the discussion using network interface (to drop 
> the locks) but found it wouldn't work well on local filesytems such as 
> ext3. There is really no control on which local (sever side) interface 
> NFS clients will use (shouldn't be hard to implement one though). When 
> the fail-over server starts to remove the locks, it needs a way to find 
> *all* of the locks associated with the will-be-moved partition. This is 
> to allow umount to succeed. The server ip address alone can't guarantee 
> that. That was the reason we switched to fsid. Also remember this is NFS 
> v2/v3 - clients have no knowledge of server migration.

Hmmm...
I had in mind that you would have some name in the DNS like
"virtual-nas-foo" which maps to a number of IP addresses,  And every
client that wants to access /bar, which is known to be served by
virtual-nas-foo would:
   mount virtual-nas-foo:/bar /bar

and some server (A) from the pool of possibilities would configure a bunch
of virtual interfaces to have the different IP addresses that the DNS
knows to be associated with 'virtual-nas-foo'.
It might also configure a bunch of other virtual interfaces with the
addresses of 'virtual-nas-baz', but no client would ever try to 
   mount virtual-nas-baz:/bar /bar
because, while that might work depending on the server configuration,
it is clearly a config error and as soon as /bar was migrated A to B,
those clients would mysteriously lose service.

So it seems to me we do know exactly the list of local-addresses that
could possibly be associated with locks on a given filesystem.  They
are exactly the IP addresses that are publicly acknowledged to be
usable for that filesystem.
And if any client tries to access the filesystem using a different IP
address then they are doing the wrong thing and should be reformatted.

Maybe the idea of using network addresses was the first suggestion,
and maybe it was rejected for the reasons you give, but it doesn't
currently seem like those reasons are valid.  Maybe those who proposed
those reasons (and maybe that was me) couldn't see the big picture at
the time.... maybe I still don't see the big picture?

> >   The reply to SM_MON (currently completely ignored by all versions
> >   of Linux) has an extra value which indicates how many more seconds
> >   of grace period there is to go.  This can be stuffed into res_stat
> >   maybe.
> >   Places where we currently check 'nlmsvc_grace_period', get moved to
> >   *after* the nlmsvc_retrieve_args call, and the grace_period value
> >   is extracted from host->nsm.
> >  
> >
> ok with me but I don't see the advantages though ?

So we can have a different grace period for each different 'host'.

> 
> >  This is the full extent of the kernel changes.
> >
> >  To remove old locks, we arrange for the callbacks registered with
> >  statd for the relevant clients to be called.
> >  To set the grace period, we make sure statd knows about it and it
> >  will return the relevant information to lockd.
> >  To notify clients of the need to reclaim locks, we simple use the
> >  information stored by statd, which contains the local network
> >  address.
> >  
> >
> 
> I'm lost here... help ?
> 

Ok, I'll try to not be so terse.

> >  To remove old locks, we arrange for the callbacks registered with
> >  statd for the relevant clients to be called.

Part of unmounting the filesystem from Server A requires getting
Server A to drop all the locks on the filesystem.  We know they can
only be held by client that sent request to a given set of IP
addresses.   Lockd created an 'nsm' for each client/local-IP pair and
registered each of those with statd.  The information registered with
statd includes the details of an RPC call that can be made to lockd to
tell it to drop all the locks owned by that client/local-IP pair.

The statd in 1.1.0 records all this information in the files created
in /var/lib/nfs/sm (and could pass it to the ha-callout if required).
So when it is time to unmount the filesystem, some program can look
through all the files in nfs/nm, read each of the lines, find those
which relate to any of the local IP address that we want to move, and
initialiate the RPC callback described on that line.  This will tell
lockd to drop those lockd.  When all the RPCs have been sent, lockd
will not hold any locks on that filesystem any more.

> >  To set the grace period, we make sure statd knows about it and it
> >  will return the relevant information to lockd.

On Server-B, we mount the filesystem(s) and export them.  When a lock
request arrives from some client, lockd needs to know whether the
grace period is still active.  We want that determination to depend on
which filesystem/local-IP was used.  One way to do that is to have in
information passing in by statd when lockd asks for the client to be
monitored.  A possible implementation would be to have the ha-callout
find out the virtual-server was migrated, and return a number of
seconds remaining by writing it to stdout.  statd could run the
ha-callout with output to a pipe, read the number, and include that in
the reply to SM_MON.

> >  To notify clients of the need to reclaim locks, we simple use the
> >  information stored by statd, which contains the local network
> >  address.

Once the filesystem is exported on Server-B, we need to notify all
clients to reclaim their locks.  We can find the same lines that were
used to tell lockd to close locks on the server, and use that
information to tell client that they need to reclaim (or information
recorded elsewhere by the ha-callout can do the same thing).

Does that make it clearer?

> I feel we're in the loop again... If there is any way I can shorten this 
> discussion, please do let me know.
> 

Much as the 'waterfall model' is frowned upon these days, I wonder if
it could serve us here.
I feel it has taken me quite a while to gain a full understanding of
what you are trying to achieve.  Maybe it would be useful to have a
concise/precise description of what the goal is.
I think a lot of the issues have now become clear, but it seems there
remains the issue of what system-wide configurations are expected, and
what configuration we can rule 'out of scope' and decide we don't have
to deal with.
Once we have a clear statement of the gaol that we can agree on, it
should be a lot easy to evaluate and reason about different
implementation proposals.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
