From: Erik Enge <eenge@prium.net>
Subject: How does lockd work when specifying mountd port.
Date: Tue, 14 Jan 2003 14:38:27 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <871y3fwmh8.fsf@prium.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from main.gmane.org ([80.91.224.249])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18YWtL-0004p0-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 11:38:31 -0800
Received: from list by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 18YWs2-0006fg-00
	for <nfs@lists.sourceforge.net>; Tue, 14 Jan 2003 20:37:10 +0100
To: nfs@lists.sourceforge.net
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

Hi.

I have opened ports 111, 2049 and 32700 through my firewall for NFS
traffic.  32700 is for mountd.  I am wondering how lockd works under
these conditions?  Does it talk through one of the mention ports or does
it not work (I can't see any dropped packets, but lockd is still
running).

Also, how does this work with many NFS clients?  Will they all go
through 32700 for mounting and will this cause a problem?

Thanks,

Erik Enge.



-------------------------------------------------------
This SF.NET email is sponsored by: Take your first step towards giving 
your online business a competitive advantage. Test-drive a Thawte SSL 
certificate - our easy online guide will show you how. Click here to get 
started: http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0027en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
