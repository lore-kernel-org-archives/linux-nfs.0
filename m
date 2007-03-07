From: Simon Peter <simon.peter@gmx.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 16:10:02 +0100
Message-ID: <20070307161002.ac6cb5ea.simon.peter@gmx.de>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Thomas.Talpey@netapp.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOxmK-00060s-8s
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 07:10:09 -0800
Received: from mail.gmx.net ([213.165.64.20])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HOxmL-0006Ew-T6
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 07:10:10 -0800
In-Reply-To: <20070307160633.77afb618.simon.peter@gmx.de>
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

That should have read "accessed", not "mounted". The export is already
mounted. :)

Simon

> Hi again,
> 
> just verified that the server indeed spins up all disks before
> answering the request. I thus suspect it is somehow checking all
> exports whenever any one export is mounted. Is this correct behaviour?
> 
> Simon
> 
> > The delay seems to be on the server side. What is the server
> > running? Does it have any nameservice issues? Delays on the first
> > response can often be due to server exports checking, which usually
> > requires reverse name lookups.
> > 
> > Tom.
> > 
> > At 05:23 AM 3/7/2007, Simon Peter wrote:
> > >Hi,
> > >
> > >I get a good 10 second delay anytime I am accessing my NFS mounts
> > >from a client for the first time (or after a long time not
> > >accessing them -- I suppose whenever the cache is cleared or
> > >something similar).
> > >
> > >I usually did not bother, even though it is very annoying, but this
> > >time I collected a network protocol capture, which is attached.
> > >Notice the big delay between packet #6 and #8, while #7 should show
> > >that it is not a network issue.
> > >
> > >I would be very glad if somebody could explain these delays.
> > >
> > >Thanks,
> > >Simon
> 


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
