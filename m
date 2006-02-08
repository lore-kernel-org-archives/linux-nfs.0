From: Stephen Carville <stephen@totalflood.com>
Subject: Performance improvement.
Date: Tue, 07 Feb 2006 23:56:24 -0800
Message-ID: <43E9A428.2030606@totalflood.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F6kBg-000213-V3
	for nfs@lists.sourceforge.net; Tue, 07 Feb 2006 23:56:28 -0800
Received: from [209.189.103.195] (helo=mail.totalflood.com)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1F6kBf-0007Gy-Ni
	for nfs@lists.sourceforge.net; Tue, 07 Feb 2006 23:56:29 -0800
Received: from [192.168.124.232] (pellucidar.totalflood.com [192.168.124.232])
	by mail.totalflood.com (Un-Exchange Mail Version 9.7.2.4) with ESMTP id B7C61540DC
	for <nfs@lists.sourceforge.net>; Tue,  7 Feb 2006 23:56:24 -0800 (PST)
To: NFS List <nfs@lists.sourceforge.net>
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

Maybe my expectations are too high but...

I have an NFS server (amazon) running FC3 and two clients (tigris and 
euphrates) running Redhat ES-3.4 and ES-3.0 respectively.   I am writing 
the nightly rman backups of the oracle databases running tigris and 
euphrates to a large RAID on amazon.  The machines are connected via a 
private network thru a Dell Power Connect 2716 switch.  After some 
tuning, Iperf shows consistent transfer rates of 950 Mbps to 980 Mbps 
for both TCP and UDP.

Euphrates (ES 3.0) will only work with nfs2 and, even with 8K packets, 
only produices about 1.5 MB/s (12 Mbps).  By comparison, tigris (ES 3.4) 
handles V3 with 32K datagrams and produces about 12 MB/s (96 Mbps). 
Still only a fraction of what the network can handle but much better 
than the other box.

I've tuned the network and I'm using the largest blocksize I can.  What 
else can I do to improve performance?

-- 
Stephen Carville <stephen@totalflood.com>
Unix and Network Admin
Nationwide Totalflood
6033 W. Century Blvd
Los Angeles, CA 90045
310-342-3602


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
