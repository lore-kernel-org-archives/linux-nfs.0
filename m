From: Pol Hallen <grungadeben@fuckaround.org>
Subject: Enable logs
Date: Sat, 20 Oct 2007 12:13:26 +0200
Message-ID: <200710201213.27120.grungadeben@fuckaround.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IjBKm-0005lP-I1
	for nfs@lists.sourceforge.net; Sat, 20 Oct 2007 03:13:32 -0700
Received: from vsmtp1.tin.it ([212.216.176.141])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IjBKq-0003dL-NP
	for nfs@lists.sourceforge.net; Sat, 20 Oct 2007 03:13:38 -0700
Received: from luna (87.8.44.97) by vsmtp1.tin.it (7.3.122)
	id 469A4E990B152C2B for nfs@lists.sourceforge.net;
	Sat, 20 Oct 2007 12:13:28 +0200
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

Hi all :-)

I use debian stable with kernel 2.6.18.
I just installed nfs (portmap, nfs-common, nfs-kernel-server), 
configurated /etc/exports and checked /etc/hosts.allow/deny.

Client can connect to server without any problems, but I have to enable 
logging on my nfs server.

Into the docs included in debian packages there isn't any reference about any 
logs (!)

How I can enable it?

Thanks! 
Pol

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
