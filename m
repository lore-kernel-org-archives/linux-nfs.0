From: Errol Casey <work-usenet@nouce.net>
Subject: Reserving port 800 on linux NFS clients
Date: Tue, 16 Mar 2004 23:36:05 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <o8lf50t2d4junli54us281h0i7433pl5lr@4ax.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3SpS-0002FD-B2
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 20:38:54 -0800
Received: from main.gmane.org ([80.91.224.249])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1B3SpN-0003wV-5s
	for nfs@lists.sourceforge.net; Tue, 16 Mar 2004 20:38:49 -0800
Received: from list by main.gmane.org with local (Exim 3.35 #1 (Debian))
	id 1B3SpO-0005Yy-00
	for <nfs@lists.sourceforge.net>; Wed, 17 Mar 2004 05:38:50 +0100
Received: from cpe-066-057-143-078.nc.rr.com ([66.57.143.78])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Wed, 17 Mar 2004 05:38:50 +0100
Received: from work-usenet by cpe-066-057-143-078.nc.rr.com with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Wed, 17 Mar 2004 05:38:50 +0100
To: nfs@lists.sourceforge.net
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

Recently, I've run into an issue where my Linux NFS clients are using
port 800 to communicate with NFSd daemons running on an Netapp Filer.

Is there any way to configure the Linux NFS client software to not use
port 800. Looking at the ports in use on my clients, it looks as if a 
series of ports 797-800 are used to communicate to nfsd.

I would like to use port 800 for another daemon. On a few machines, 
this conflict does not occur.





-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
