From: seth vidal <skvidal@phy.duke.edu>
Subject: Re: NFS server not responding
Date: Sun, 30 Nov 2003 15:01:50 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1070222510.14818.10.camel@binkley>
References: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Douglas Furlong <douglas.furlong@firebox.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AQXp8-0006NZ-00
	for <nfs@lists.sourceforge.net>; Sun, 30 Nov 2003 12:05:42 -0800
Received: from mail.phy.duke.edu ([152.3.182.2] ident=[E0q4g80hNxjLSluhCWb73a3vUngm/JCf])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AQXp8-0001XQ-KX
	for nfs@lists.sourceforge.net; Sun, 30 Nov 2003 12:05:42 -0800
To: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
In-Reply-To: <Pine.LNX.4.44.0311281257130.22389-100000@kenzo.iwr.uni-heidelberg.de>
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


> The load on the server when simultaneously rebooting several tens of nodes
> goes up to 10-12, while previously it was 3-5. IMHO, this points more to a
> slower/less-efficient NFS daemon or to a more agressive client (but which 
> gives up easier afterwards as seen from the logged messages).


it's the red hat kernel.
https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=100680

I bet it's related to that problem.

-sv




-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
