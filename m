From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Nfs Failover
Date: Tue, 9 Oct 2007 15:51:28 -0400
Message-ID: <20071009195128.GQ22750@fieldses.org>
References: <2a46ebd60710091240k37369e15rbc99b57d26579e8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Saurabh Sehgal <saurabh.r.s@gmail.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfL70-0000iy-HM
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 12:51:26 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfL74-0007mP-F3
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 12:51:31 -0700
In-Reply-To: <2a46ebd60710091240k37369e15rbc99b57d26579e8a@mail.gmail.com>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Tue, Oct 09, 2007 at 03:40:22PM -0400, Saurabh Sehgal wrote:
> Hi all,
> 
> I am trying to do an nfs failover from one server to another in a 4 node
> cluster . During this failover, I have a link from /var/lib/nfs directory to
> a mount that resides on a shared disk. When i want to move the "resources"
> from one node to the other ... this is how I go about initiating the move :
> 
> 1) /etc/init.d/nfsserver stop
> 2) mount /var/lib/nfs on the failover node
> 3) move IP address to failover node
> 3) /etc/init.d/nfsserver start
> 4) /sbin/sm-notify -v <failover ip address>
> 
> Are these the correct steps ? What I end up getting is a Stale NFS File
> handle on all client nodes, until I unmount and remount them again. For the
> purpose of my application this mount/unmount of clients is undesirable .
> What should I do ? Any help would be appreciated.

What filesystem are you exporting?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
