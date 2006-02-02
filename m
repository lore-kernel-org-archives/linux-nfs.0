From: Ingo Lantschner <ingo.lists@vum.at>
Subject: udp port sunrpc unreachable
Date: Thu, 02 Feb 2006 10:21:14 +0100
Message-ID: <drsiub$vok$1@sea.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1F4anp-00048V-6s
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 01:30:57 -0800
Received: from main.gmane.org ([80.91.229.2] helo=ciao.gmane.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1F4anl-0008Af-SZ
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 01:30:57 -0800
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1F4anY-0000XZ-38
	for nfs@lists.sourceforge.net; Thu, 02 Feb 2006 10:30:40 +0100
Received: from 85-124-230-82.work.xdsl-line.inode.at ([85.124.230.82])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 02 Feb 2006 10:30:40 +0100
Received: from ingo.lists by 85-124-230-82.work.xdsl-line.inode.at with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <nfs@lists.sourceforge.net>; Thu, 02 Feb 2006 10:30:40 +0100
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
I have a propably simple problem here - but can not find a solution:
NFS-Client wslisi should mount a directory from NFS-Server wsvideo. 
Potmaper und nfs-common are installed on both machines. The server has 
nfs-kernel-server installed:
-------------------------------------------------------------------------
wsvideo$ env LANG=C dpkg -l nfs*
...
un  nfs-client                       <none>
ii  nfs-common                       1.0.6-3.1ubuntu1
ii  nfs-kernel-server                1.0.6-3.1ubuntu1
--------------------------------------------------------------------------

But I still can not connect - tcpdump says that port 111 (sunrpc) is not 
reachable:
-------------------------------------------------------------------------
# tcpdump -t not port 22
IP wslisi.696 > wsvideo.sunrpc: S 727126627:727126627(0) win 5840 <mss 
1460,sackOK,timestamp 2256871 0,nop,wscale 2>
IP wsvideo.sunrpc > wslisi.696: R 0:0(0) ack 727126628 win 0
IP wslisi.697 > wsvideo.sunrpc: UDP, length: 56
IP wsvideo > wslisi: icmp 92: wsvideo udp port sunrpc unreachable
IP wsvideo.32803 > fw.domain:  29191+ PTR? 13.4.168.192.in-addr.arpa. (43)
IP wslisi.698 > wsvideo.sunrpc: S 724474935:724474935(0) win 5840 <mss 
1460,sackOK,timestamp 2256872 0,nop,wscale 2>
IP wsvideo.sunrpc > wslisi.698: R 0:0(0) ack 724474936 win 0
IP fw.domain > wsvideo.32803:  29191* 1/0/0 (64)
IP wsvideo.32803 > fw.domain:  29192+ PTR? 12.4.168.192.in-addr.arpa. (43)
IP fw.domain > wsvideo.32803:  29192* 1/0/0 (63)
IP wsvideo.32803 > fw.domain:  29193+ PTR? 254.4.168.192.in-addr.arpa. (44)
IP fw.domain > wsvideo.32803:  29193* 1/0/0 (60)
arp who-has wsvideo tell wslisi
arp reply wsvideo is-at 00:0c:76:71:02:09
arp who-has fw tell wsvideo
arp reply fw is-at 00:4f:4e:05:d1:bd
--------------------------------------------------------------------------

netstat sees tcp open:

--------------------------------------------------------------------------
$ env LANG=C netstat -an | grep 111
tcp        0      0 127.0.0.1:111           0.0.0.0:*           LISTEN
udp        0      0 127.0.0.1:111           0.0.0.0:*
--------------------------------------------------------------------------

Any idea? TIA Ingo.



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=103432&bid=230486&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
