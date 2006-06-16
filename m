From: Neil Brown <neilb@suse.de>
Subject: Re: [Linux-cluster] Re: [RFC] NLM lock failover
	admin	interface
Date: Fri, 16 Jun 2006 16:09:49 +1000
Message-ID: <17554.19245.914383.436585@cse.unsw.edu.au>
References: <1150089943.26019.18.camel@localhost.localdomain>
	<17550.11870.186706.36949@cse.unsw.edu.au>
	<1150268091.28264.75.camel@localhost.localdomain>
	<1150293654.28264.91.camel@localhost.localdomain>
	<20060615140743.36CDC1BBAD@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux clustering <linux-cluster@redhat.com>,
	nfs@lists.sourceforge.net, Wendy Cheng <wcheng@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fr7Ww-00042K-7Y
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 23:10:06 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Fr7Wu-0001VA-G7
	for nfs@lists.sourceforge.net; Thu, 15 Jun 2006 23:10:06 -0700
To: "William A.(Andy) Adamson" <andros@citi.umich.edu>
In-Reply-To: message from William A.(Andy) Adamson on Thursday June 15
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

On Thursday June 15, andros@citi.umich.edu wrote:
> this discusion has centered around removing the locks of an export.
> we also want the interface to ge able to remove the locks owned by a single 
> client. this is needed to enable client migration between replica's or between 
> nodes in a cluster file system. it is not acceptable to place an entire export 
> in grace just to move a small number of clients.

Hmmmm....
You want to remove all the locks owned by a particular client
with the intension of reclaiming those locks against a different NFS
server (on a cluster filesystem)
and you don't want to put the whole filesystem into grace mode while
doing it.

Is that correct?

Sounds extremely racy to me.  Suppose some other client takes a
conflicting lock between dropping them on one server and claiming them
on the other?  That would be bad.  The purpose of the grace mode is
precisely to avoid this sort of race.

It would seem that what you "really" want to do is to tell the cluster
filesystem to migrate the locks to a different node and some how tell
lockd about out.

Is there a comprehensive design document about how this is going to
work, because I'm feeling doubtful.

For the 'between replicas' case - I'm not sure locking makes sense.
Locking on a read-only filesystem is pretty pointless, and presumably
replicas are read-only???

Basically, dropping locks that are expected to be picked up again,
without putting the whole filesystem into a grace period simply
doesn't sound workable to me.

Am I missing something?

NeilBrown


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
