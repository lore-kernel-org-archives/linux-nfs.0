From: Greg Lindahl <lindahl@keyresearch.com>
Subject: Re: NFS mount/umount problem
Date: Thu, 16 Jan 2003 12:00:18 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030116200018.GA1253@wumpus.internal.keyresearch.com>
References: <1042744656.3312.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS mailing list <nfs@lists.sourceforge.net>,
   Craig Tierney <ctierney@hpti.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from ppp-66-122-194-201.aonnetworks.com ([66.122.194.201] helo=localhost.localdomain)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 18ZG6s-0006BS-00
	for <nfs@lists.sourceforge.net>; Thu, 16 Jan 2003 11:55:30 -0800
To: "David B. Ritch" <dritch@hpti.com>
In-Reply-To: <1042744656.3312.43.camel@localhost>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> After I upgraded the server from 2.4.14 to 2.4.20, I am having a problem
> mounting and unmounting the NFS partitions using autofs. I have all
> of the clients touch the nfs filesystems (ls /misc/scratchx) to cause
> them to mount.  Many of the mounts fail (~ 50%) with the error.

Dave,

You might want to have Craig mention how many clients are involved.
If this is the FSL cluster, it's 1000. I don't know how mount decides
whether to use UCP or TCP for the mount operation, but I do know that
1000 UDP requests heading at the same server at the same time is some
major congestion. 1000 TCP connections against the same server is
likewise problemmatic.

-- greg



-------------------------------------------------------
This SF.NET email is sponsored by: Thawte.com
Understand how to protect your customers personal information by implementing
SSL on your Apache Web Server. Click here to get our FREE Thawte Apache 
Guide: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0029en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
