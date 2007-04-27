From: Neil Brown <neilb@suse.de>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Fri, 27 Apr 2007 16:00:13 +1000
Message-ID: <17969.37229.250000.895316@notabene.brown>
References: <46156F3F.3070606@redhat.com> <4625204D.1030509@redhat.com>
	<17959.5245.635902.823441@notabene.brown>
	<462D79F0.4060800@redhat.com>
	<17965.39683.396108.623418@notabene.brown>
	<46302C01.2060500@redhat.com>
	<17968.15370.88587.653447@notabene.brown>
	<46315EED.9020103@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
To: wcheng@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HhJVU-0006gm-Fb
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 23:00:36 -0700
Received: from mail.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HhJVV-0007g3-Gq
	for nfs@lists.sourceforge.net; Thu, 26 Apr 2007 23:00:39 -0700
In-Reply-To: message from Wendy Cheng on Thursday April 26
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

On Thursday April 26, wcheng@redhat.com wrote:
> Neil Brown wrote:
> 
> >On Thursday April 26, wcheng@redhat.com wrote:
> >  
> >
> >>A convincing argument... unfortunately, this happens to be a case where 
> >>we need to protect server from client's misbehaviors. For a local 
> >>filesystem (ext3), if any file reference count is not zero (i.e. some 
> >>clients are still holding the locks), the filesystem can't be 
> >>un-mounted. We would have to fail the failover to avoid data corruption.
> >>    
> >>
> >
> >I think this is a tangential problem.
> >"removing locks held by troublesome clients so that I can unmount my
> >filesystem" is quite different from "remove locks held by client
> >clients using virtual-NAS-foo so they can be migrated".
> >  
> >
> The reason to unmount is because we want to migrate the virtual IP.

The reason to unmount is because we want to migrate the filesystem. In
your application that happens at the same time as migrating the
virtual IP, but they are still distinct operations.
 
>                                                                     IMO 
> they are the same issue but it is silly to keep fighting about this. In 
> any case, one interface is better than two, if you allow me to insist on 
> this.

How many interfaces depends somewhat on how many jobs to do.
You want to destroy state that will be rebuilt on a different server,
and you want to force-unmount a filesystem.  Two different jobs. Two
interfaces seems OK.
If they could both be done with one simple interface that would be
ideal, but I'm not sure they can.

And no-one gets to insist on anything.
You are writing the code.  I am accepting/rejecting it.  We both need
to agree or we won't move forward.  (Well... I could just write code
myself, but I don't plan to do that).

> 
> So how about we do RPC call to lockd to tell it to drop the locks owned 
> by the client/local-IP pair as you proposed, *but* add an "OR" with fsid 
> to fool proof the process ? Say something like this:
> 
> RPC_to_lockd_with (client_host, client_ip, fsid);
> if ((host == client_host && vip == client_ip) ||
> (get_fsid(file) == client_fsid))
> drop_the_locks();
> 
> This logic (RPC to lockd) will be triggered by a new command added to 
> nfs-util package.
> 
> If we can agree on this, the rest would be easy. Done ?

Sorry, but we cannot agree with this, and I think the rest is still
easy.

The more I think about it, the less I like the idea of using an fsid.
The fsid concept was created simply because we needed something that
would fit inside a filehandle.  I think that is the only place it
should be used.
Outside of filehandles, we have a perfectly good and well-understood
mechanism for identifying files and filesystems.  It is a "path name".
The functionality "drop all locks held by lockd on a particular
filesystem" is potentially useful outside of any fail-over
configuration, and should work on any filesystem, not just one that
was exported with 'fsid='.

So if you need that, then I think it really must be implemented by
something a lot like
   echo -n /path/name > /proc/fs/nfs/nlm_unlock_filesystem

This is something that we could possible teach "fuser -k" about - so
it can effectively 'kill' that part of lockd that is accessing a given
filesystem.  It is useful to failover, but definitely useful beyond
failover.


Everything else can be done in the RPC interface between lockd and
statd, leveraging the "my_name" field to identify state based on which
local network address was used.  All this other functionality is
completely agnostic about the particular filesystem and just looks at
the virtual IP that was used.
All this other functionality is all that you need unless you have a
misbehaving client.
You would do all the lockd/statd/rpc stuff.  Then try to unmount the
filesystem.  If that fails, try "fuser -k -m /whatever" and try the
unmount again.

Another interface alternative might be to hook in to
umount(MNT_FORCE), but that would require even broader review, and
probably isn't worth it....

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
