From: James Bottomley <James.Bottomley@steeleye.com>
Subject: Re: High Availability NFS Proposal
Date: Mon, 23 Sep 2002 09:53:55 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200209231353.g8NDru530832@localhost.localdomain>
References: <neilb@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: James Bottomley <James.Bottomley@SteelEye.com>, nfs@lists.sourceforge.net,
        lmb@suse.de
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host194.steeleye.com ([66.206.164.34] helo=pogo.mtv1.steeleye.com)
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17tTfN-0006H2-00
	for <nfs@lists.sourceforge.net>; Mon, 23 Sep 2002 06:54:25 -0700
Received: (from root@localhost)
	by pogo.mtv1.steeleye.com (8.9.3/8.9.3) id GAA20752
	for <nfs@lists.sourceforge.net>; Mon, 23 Sep 2002 06:54:23 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: Message from Neil Brown <neilb@cse.unsw.edu.au>
   of "Sun, 15 Sep 2002 20:12:48 +1000." <15748.23840.351420.134476@notabene.cse.unsw.edu.au>
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

neilb@cse.unsw.edu.au said:
> Any progress on this?... The idea seems quite sound. My only
> suggestion would be not to depend on the existance of a program in /
> var/lib/nfs, but rather to have such a program specified as a command
> line argument.  It makes it more explicit. 

Not yet...I was hoping to have this ready for our HA NFS in RHAS2.1, but the 
time scales wouldn't line up.  I'll probably have time to get back to it in 
October.

I'll make the program directory be an explicit configuration option, thanks.

> Also, the need for this support in mountd will almost certainly go
> away in 2.6 (that is what I am working on at the moment) but ofcourse
> 2.4 is going to be around for a while so it is probably still worth
> while. 

Yes, historically the 2.2 kernel was still being released up to a year after 
2.4 came out.  How are you planning to change mountd? make the kernel do the 
authentication checks?

James




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
