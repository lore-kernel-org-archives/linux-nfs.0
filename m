From: Spencer Shepler <spencer.shepler@sun.com>
Subject: Re: Questions about NFS over TCP
Date: Wed, 23 Apr 2003 14:13:22 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030423191322.GD101439@dhcp-uaus08-128-191.Central.Sun.COM>
References: <3EA66B58.2B1E4A45@moving-picture.com> <003901c309c2$4b1be2d0$c501d318@doggy>
Reply-To: spencer.shepler@sun.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from nwkea-mail-2.sun.com ([192.18.42.14])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 198PfE-00064w-00
	for <nfs@lists.sourceforge.net>; Wed, 23 Apr 2003 12:12:16 -0700
To: Work <daniel.brunner@duni.com>
In-Reply-To: <003901c309c2$4b1be2d0$c501d318@doggy>
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

On Wed, Work wrote:
> Hello!!
> 
> Actually I run NFS over TCP using RH 7.3 with a 2.4.20 recompiled kernel,
> and all the clients run Mac OS X 10.2.5.
> 
> Besides some performance issues (10 MB/sec...ACK), rebooting the Linux box
> doesn't lock up the Macs at all...
> 
> UNLESS, they try to access the NFS mount. But if files are open, and the
> clients are working with them it's not a problem.
> 
> To me, it's better to shutdown all clients, then reboot the Linux box...

That is unfortunate.  It is possible to implement an NFS client such
that it will properly recovery from server failure and not interrupt
service to the application.

Spencer


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
