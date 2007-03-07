From: Simon Peter <simon.peter@gmx.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 14:22:57 +0100
Message-ID: <20070307142257.b070d887.simon.peter@gmx.de>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOw6p-0003ZU-KM
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 05:23:11 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HOw6q-00059M-8o
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 05:23:13 -0800
In-Reply-To: <EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
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

The server runs Debian unstable:
Linux server 2.6.18-3-k7 #1 SMP Sun Dec 10 20:17:39 UTC 2006 i686
GNU/Linux

And I use classic NFSv3, exporting only to that subnet with options
(rw,sync). The client uses solely the intr option.

There shouldn't be any nameservice issues since the server is also
running the nameserver and is the authority for the subnet that I am
mounting from. I tried canonical and reverse lookups of the client's
name/IP from that server, all without delay. How would I check for
nameservice issues?

The server has some disks with exported directories that spin down after
some idle time, but the disk of that particular mount point that I am
using is always online. Maybe the server somehow checks all exports all
the time and not just the particular requested one and thus spins up
all the other disks?

Simon

> The delay seems to be on the server side. What is the server running?
> Does it have any nameservice issues? Delays on the first response can
> often be due to server exports checking, which usually requires
> reverse name lookups.
> 
> Tom.
> 
> At 05:23 AM 3/7/2007, Simon Peter wrote:
> >Hi,
> >
> >I get a good 10 second delay anytime I am accessing my NFS mounts
> >from a client for the first time (or after a long time not accessing
> >them -- I suppose whenever the cache is cleared or something
> >similar).
> >
> >I usually did not bother, even though it is very annoying, but this
> >time I collected a network protocol capture, which is attached.
> >Notice the big delay between packet #6 and #8, while #7 should show
> >that it is not a network issue.
> >
> >I would be very glad if somebody could explain these delays.
> >
> >Thanks,
> >Simon


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
