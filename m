From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC] NLM lock failover admin interface
Date: Tue, 13 Jun 2006 13:17:50 +1000
Message-ID: <17550.11870.186706.36949@cse.unsw.edu.au>
References: <1150089943.26019.18.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-cluster@redhat.com, nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FpzPn-0002uR-79
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 20:18:03 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FpzPk-0004GI-QA
	for nfs@lists.sourceforge.net; Mon, 12 Jun 2006 20:18:03 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: message from Wendy Cheng on Monday June 12
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

On Monday June 12, wcheng@redhat.com wrote:
> NFS v2/v3 active-active NLM lock failover has been an issue with our
> cluster suite. With current implementation, it (cluster suite) is trying
> to carry the workaround as much as it can with user mode scripts where,
> upon failover, on taken-over server, it:
> 
> 1. Tear down virtual IP.
> 2. Unexport the subject NFS export.
> 3. Signal lockd to drop the locks.
> 4. Un-mount filesystem if needed.
> 
...
>                                                                 we would
> like to be able to selectively drop locks (only) associated with the
> requested exports without disrupting other NFS services. 

There seems to be an unstated assumption here that there is one
virtual IP per exported filesystem.  Is that true?

Assuming it is and that I understand properly what you want to do....

I think that maybe the right thing to do is *not* drop the locks on a
particular filesystem, but to drop the locks made to a particular
virtual IP.

Then it would make a lot of sense to have one lockd thread per IP, and
signal the lockd in order to drop the locks.
True: that might be more code.  But if it is the right thing to do,
then it should be done that way.

On the other hand, I can see a value in removing all the locks for a
particular filesytem quite independent of failover requirements.
If I want to force-unmount a filesystem, I need to unexport it, and I
need to kill all the locks.  Currently you can only remove locks from
all filesystems, which might not be ideal.

I'm not at all keen on the NFSEXP_FOLOCK flag to exp_unexport, as that
is an interface that I would like to discard eventually.  The
preferred mechanism for exporting filesystems is to flush the
appropriate 'cache', and allow it to be repopulated with whatever is
still valid via upcalls to mountd.

So:
 I think if we really want to "remove all NFS locks on a filesystem",
 we could probably tie it into umount - maybe have lockd register some
 callback which gets called just before s_op->umount_begin.

 If we want to remove all locks that arrived on a particular
 interface, then we should arrange to do exactly that.  There are a
 number of different options here. 
  One is the multiple-lockd-threads idea.
  One is to register a callback when an interface is shut down.
  Another (possibly the best) is to arrange a new signal for lockd
  which say "Drop any locks which were sent to IP addresses that are
  no longer valid local addresses".

So those are my thoughts.  Do any of them seem reasonable to you?

NeilBrown



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
