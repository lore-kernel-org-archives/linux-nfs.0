From: Steven Shiau <steven@nchc.org.tw>
Subject: NFS service takes very long time to start when internet disconnected..
Date: Sat, 24 Jul 2004 14:36:35 +0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040724063635.GA25341@lfod.nchc.org.tw>
Reply-To: steven@nchc.org.tw
Mime-Version: 1.0
Content-Type: text/plain; charset=big5
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BoG99-0006dt-Jm
	for nfs@lists.sourceforge.net; Fri, 23 Jul 2004 23:36:39 -0700
Received: from lfod.nchc.org.tw ([140.110.17.130])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1BoG98-0001Nr-WA
	for nfs@lists.sourceforge.net; Fri, 23 Jul 2004 23:36:39 -0700
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

Hi...
My NFS server has two NICs, eth0 is public IP address, eth1 is private
IP. It's a NAT server, too.
The NFS service is for those clients with private IP address.
The server is running Fedora Core 1, with nfs-utils-1.0.6-1, and kernel
2.4.22-1.2193smp.
My problem is, when the server loses the Internet connection, i.e. the
eth0 can NOT connect to Internet, either it's caused when I move the machine to
different subnet while forgetting change the network setting,  or the network cable is disconnected, the Fedore Core 1 takes very long time to boot. It just stops in "Starting NFS service..." for more than 17 minutes...
So usually I reboot the machine, and enter the interactive mode to disable the NFS service when it boot.
My point is, is that possible I can make the NFS service startup very
quickly as usual when the eth0 Internet connection is NOT available ?

Thanks in advance.
-- 
Please AVOID distributing documents in WORD, EXCEL or POWERPOINT format.
[Chinese Big5] 請避免散佈WORD, EXCEL 或是 POWERPOINT格式的檔案.
See http://www.fsf.org/philosophy/no-word-attachments.html
and http://www.cyut.edu.tw/~ckhung/published/997nodoc.shtml
----------------------------------
Steven Shiau
E-mail: steven _at_ nchc.org.tw; steven _at_ stick.idv.tw


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
