From: "Cuenta de la lista de linux" <user_linux@citma.cu>
Subject: NFS problem: udp  port nfs unreachable
Date: Wed, 15 Jan 2003 14:11:00 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030115191100.M18217@webmail.citma.cu>
References: <6440EA1A6AA1D5118C6900902745938E07D551FA@black.eng.netapp.com> <20030115130759.B11894@ti19> <20030115182436.GO30598@questra.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [169.158.128.3] (helo=mail.citma.cu)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Ystu-00025R-00
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 11:08:35 -0800
Received: from webmail.citma.cu (webmail.citma.cu [10.0.1.4])
	by mail.citma.cu (8.11.6/8.11.6) with ESMTP id h0FJDvq12047
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 14:13:57 -0500
Received: from webmail.citma.cu (webmail.citma.cu [10.0.1.4])
	by webmail.citma.cu (8.11.6/8.11.6) with ESMTP id h0FJB0X21815
	for <nfs@lists.sourceforge.net>; Wed, 15 Jan 2003 14:11:00 -0500
To: nfs@lists.sourceforge.net
In-Reply-To: <20030115182436.GO30598@questra.com>
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


Hi all:
  
  I am having some problems running a little cluster with nfs.
  I have a nfs server  with redhat 7.2 , kernel 2.4.7-10 ,
 portmap 4.0-38 and i have upgraded to nfs-utils 1.0.1 
  

 When from the client i try : 
 mount ipservidor:/home /mnt/home 
 
I always get the following errors messages en /var/log/messages:
  
 authenticated mount request from client'sip:762
 
 I have used tcpdump to dig into the problem and all that i can see the server
sending the following  ICMP mesages to the client:

 udp  port nfs unreachable 
  
 How can I add the levels of the log  to the syslog(/var/log/messages) in
order to get more messages and debugging my problems?

Have anybody some ideas about these errors messages?
What is wrong?

David

 




-------------------------------------------------------
This SF.NET email is sponsored by: A Thawte Code Signing Certificate 
is essential in establishing user confidence by providing assurance of 
authenticity and code integrity. Download our Free Code Signing guide:
http://ads.sourceforge.net/cgi-bin/redirect.pl?thaw0028en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
