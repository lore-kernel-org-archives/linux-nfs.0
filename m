From: Ingo Lantschner <ingo.lists@vum.at>
Subject: NFS Server listening to only one interface - but how?
Date: Wed, 15 Feb 2006 13:42:22 +0100
Message-ID: <dsv7jf$m2r$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F9Lzb-0005Ez-TY
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 04:42:47 -0800
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F9LzZ-0006g7-AB
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 04:42:48 -0800
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1F9LzI-0002NU-Ou
	for nfs@lists.sourceforge.net; Wed, 15 Feb 2006 13:42:29 +0100
Received: from 85-124-230-82.work.xdsl-line.inode.at ([85.124.230.82])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Wed, 15 Feb 2006 13:42:28 +0100
Received: from ingo.lists by 85-124-230-82.work.xdsl-line.inode.at with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Wed, 15 Feb 2006 13:42:28 +0100
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

Hi all,
I would like to run NFS Server (kernel) on a firewall. For obvious 
reasons I would like it to listen only to the internal interface.
I tried to start portmap with -i 192.168.x.y - which is fine, but it 
prevents nfs-kernel-server from starting.
It says in syslog:
fw kernel: portmap: server localhost not responding, timed out
fw kernel: RPC: failed to contact portmap (errno -5).
fw last message repeated 4 times

How can I tell the nfs-serer to contact the portmapper at 192.168.x.y 
and not at localhost? Can I make portmap listen to both interfaces (lo 
and eth1)?

Btw.: I am missing the man-page for nfs-kernel server - I use now Ubuntu 
Breezy (based on debian)

TIA, Ingo.



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
