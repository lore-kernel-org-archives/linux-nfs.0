From: jkt <jkt@execpc.com>
Subject: NFS Setup
Date: Tue, 19 Mar 2002 23:15:34 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3C981AF6.E64A4D8A@execpc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Received: from out3.mx.nwbl.wi.voyager.net ([169.207.3.79])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16nYSL-0003qk-00
	for <nfs@lists.sourceforge.net>; Tue, 19 Mar 2002 21:16:13 -0800
Received: from pop2.nwbl.wi.voyager.net (pop2.nwbl.wi.voyager.net [169.207.3.115])
	by out3.mx.nwbl.wi.voyager.net (8.11.1/8.11.4/1.7) with ESMTP id g2K5GC193747
	for <nfs@lists.sourceforge.net>; Tue, 19 Mar 2002 23:16:12 -0600 (CST)
Received: from execpc.com (d121.as7.nwbl0.wi.voyager.net [169.207.128.249])
	by pop2.nwbl.wi.voyager.net (8.10.2/8.10.2) with ESMTP id g2K5GBh12885
	for <nfs@lists.sourceforge.net>; Tue, 19 Mar 2002 23:16:11 -0600 (CST)
To: "nfs@lists.sourceforge.net" <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Hello,

My name is John Tankersley. I am new to NFS and am seeking some help in
how to set up the entries in 
the /etc/exports file on the host side and the /etc/fstab file on the
client side.
I have two machines running SuSE Linux 7.3 professional each.  I can
ping and telnet between the two
machines successfully. Machine (1) host machine's ip is 192.168.1.3. 
The client machine's ip is 
192.168.1.1.  Here is the entry in the host machine /etc/exports  file. 
/tmp 192.168.1.1.
The entry at the client machine in /etc/fstab file is 192.168.1.3:/tmp. 
I just want to know what I am doing wrong in my entries.  I hope my
explanation is clear.  I am trying to mount the /tmp directory on the
host machine to the client machine.  Could someone please indicate what
is wrong with my entries?

Thank-you,

John Tankersley
jkt@execpc.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
