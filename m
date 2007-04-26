From: Neil Brown <neilb@suse.de>
Subject: Re: [Cluster-devel] [PATCH 0/4 Revised] NLM - lock failover
Date: Thu, 26 Apr 2007 15:43:38 +1000
Message-ID: <17968.15370.88587.653447@notabene.brown>
References: <46156F3F.3070606@redhat.com> <4625204D.1030509@redhat.com>
	<17959.5245.635902.823441@notabene.brown>
	<462D79F0.4060800@redhat.com>
	<17965.39683.396108.623418@notabene.brown>
	<46302C01.2060500@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, nfs@lists.sourceforge.net
To: wcheng@redhat.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hgwlo-0006RB-IO
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 22:43:56 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hgwlq-0000bd-Md
	for nfs@lists.sourceforge.net; Wed, 25 Apr 2007 22:43:59 -0700
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
> 
> A convincing argument... unfortunately, this happens to be a case where 
> we need to protect server from client's misbehaviors. For a local 
> filesystem (ext3), if any file reference count is not zero (i.e. some 
> clients are still holding the locks), the filesystem can't be 
> un-mounted. We would have to fail the failover to avoid data corruption.

I think this is a tangential problem.
"removing locks held by troublesome clients so that I can unmount my
filesystem" is quite different from "remove locks held by client
clients using virtual-NAS-foo so they can be migrated".

I would have no problem with a new file in the nfsd filesystem such
that
      echo /some/path > /proc/fs/nfsd/nlm_drop_locks
would cause lockd to drop all locks on all files with the same 'struct
super' as "/some/path"->i_sb.
But I think that is independent functionality, that might be useful to
people who aren't doing active-active failover, but happens also to be
useful in conjunction with active-active failover.

We could discuss whether it should be "same superblock" or "same
vfsmount".  Both make sense to some extent.  The latter is possible
more flexible. 

If you had this interface, you might not need to send the various RPC
calls to lockd to get it to drop locks.... but then if you had a
cluster filesystem and wanted to only move some clients to a different
host, you would not want to drop *all* the locks on the filesystem, so
maybe both interfaces are still needed.

> 
> IMHO, having grace period for each client (host) is overkilled.

Yes, it gives you much more flexibility than you would ever what or
use, and in that sense it is overkill.
But it also makes available the specific flexibility that you do want
(grace period per local-address) with an extremely simple change to the
lockd interface, which I think is a big win.

> >
> >[snip]
> >I feel it has taken me quite a while to gain a full understanding of
> >what you are trying to achieve.  Maybe it would be useful to have a
> >concise/precise description of what the goal is.
> >I think a lot of the issues have now become clear, but it seems there
> >remains the issue of what system-wide configurations are expected, and
> >what configuration we can rule 'out of scope' and decide we don't have
> >to deal with.
> >  
> >
> I'm trying to do the write-up now. But could the following temporarily 
> serve the purpose ? What is not clear from this thread of discussion?
> 
> http://www.redhat.com/archives/linux-cluster/2006-June/msg00050.html

Lots of things are not clear - mostly things that have since become
clear in the ongoing discussion.
 - The many-IPs to many-filesystems possibilitiy
 - The need to explicitly handle mis-configured clients
 - The details of needs with respect to SM_NOTIFY callbacks
 - the "big picture" stuff.

I confess that I had a much more shallow understanding of how statd
interacts with lockd  when this discussion first started.
I'm sure that slowed me down in understanding the key issues, and in
suggesting workable possibilities.

I am sorry that this has taken so long.  However I think we are very
close to a solution that will solve everybody's needs.  And you've
found some bugs along the way!!

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
