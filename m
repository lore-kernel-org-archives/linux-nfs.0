From: Peter Astrand <peter@cendio.se>
Subject: Re: statd simplified
Date: Tue, 3 Feb 2004 21:06:06 +0100 (CET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0402031627450.27418-100000@maggie.lkpg.cendio.se>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Ao85r-0008Uf-9T
	for nfs@lists.sourceforge.net; Tue, 03 Feb 2004 13:28:27 -0800
Received: from mail.cendio.se ([193.12.253.66])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Ao85q-0002ra-FC
	for nfs@lists.sourceforge.net; Tue, 03 Feb 2004 13:28:26 -0800
To: Olaf Kirch <okir@suse.de>, <nfs@lists.sourceforge.net>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


>I've never really liked statd for a number of reasons (the following
>list is not exhaustive):
>...
>So I sat down last week and dusted off some old ideas how to simplify
>NLM/NSM interaction quite a bit.

Here is something to add to the wishlist: HA support. 
http://marc.theaimsgroup.com/?l=linux-nfs&m=106880965906133&w=2 lists some 
problems with using statd in a HA environment. 


-- 
Peter Åstrand		www.thinlinc.com
Cendio			www.cendio.se
Teknikringen 3		Phone: +46-13-21 46 00
583 30 Linköping








-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
