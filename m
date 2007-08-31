From: xiao.liang@cn.alps.com
Subject: NFS:RPC timed out
Date: Fri, 31 Aug 2007 14:14:56 +0800
Message-ID: <OFF770B138.A6668C02-ON48257348.0021C294-48257348.00224EEA@alps.com.hk>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============2057120063=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQzmL-0000m2-Td
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 23:14:54 -0700
Received: from [61.213.178.131] (helo=qalpsgw3.alps.co.jp)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQzmP-0005TE-To
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 23:14:54 -0700
Received: from interscan2.alps.co.jp ([10.10.4.9])
	by qalpsgw3.alps.co.jp (8.11.7p1+Sun/3.7W-99022419) with ESMTP id
	l7V6Ekt10536
	for <nfs@lists.sourceforge.net>; Fri, 31 Aug 2007 15:14:46 +0900 (JST)
Received: from interscan2.alps.co.jp (localhost [127.0.0.1])
	by localhost.alps.co.jp (Postfix) with ESMTP id 1525427740E
	for <nfs@lists.sourceforge.net>; Fri, 31 Aug 2007 15:14:46 +0900 (JST)
Received: from qalpsgw2.alps.co.jp (qalpsgw2.alps.co.jp [10.10.4.1])
	by interscan2.alps.co.jp (Postfix) with ESMTP id D418927740D
	for <nfs@lists.sourceforge.net>; Fri, 31 Aug 2007 15:14:45 +0900 (JST)
Received: from asia01.alps.com (asia01.alps.co.jp [10.10.4.42])
	by qalpsgw2.alps.co.jp (8.11.7p1+Sun/3.7W-99042312) with ESMTP id
	l7V6EjA18709
	for <nfs@lists.sourceforge.net>; Fri, 31 Aug 2007 15:14:45 +0900 (JST)
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

This is a multipart message in MIME format.
--===============2057120063==
Content-Type: multipart/alternative;
	boundary="=_alternative 00224EE448257348_="

This is a multipart message in MIME format.
--=_alternative 00224EE448257348_=
Content-Type: text/plain; charset="US-ASCII"

Hi,
 


I use kernel 2.4.20,busybox 1.3.1,the NFS server is V4.When I try to mount 
use 

mount -t nfs 10.25.16.130:/opt/Qtopia /opt/Qtopia 

Got error ,mount: RPC time out 

When I use ethreal on both the server and client side , found that the 
server have sent SYN,ACK back to client with the TCP connection, but the 
client just do not respond. I use portmap and also inetd. The tcpdump log 
is look like this: 

10.25.16.160.794 > 10.25.16.130.sunrpc: S, cksum 0x5740 (correct), 
31406388 

10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x79e6 (correct), 
2533961748:2 
10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x79e6 (correct), 
2533961748:2 
60) 10.25.16.160.794 > 10.25.16.130.sunrpc: S, cksum 0x5614 (correct), 
31406388 
10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x76ff (correct), 
2533961748:2 
10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x76ff (correct), 
2533961748:2 
10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x76f8 (correct), 
2533961748:2 
10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x76f8 (correct), 
2533961748:2 


60) 10.25.16.160.794 > 10.25.16.130.sunrpc: S, cksum 0x53bc (correct), 
31406388 
10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x7123 (correct), 
2533961748:2 
10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x7123 (correct), 
2533961748:2 
10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x711c (correct), 
2533961748:2 
10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x711c (correct), 
2533961748:2 


10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x6563 (correct), 
2533961748:2 
60) 10.25.16.160.794 > 10.25.16.130.sunrpc: S, cksum 0x4f0c (correct), 
31406388 
10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x6561 (correct), 
2533961748:2 
10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x6563 (correct), 
2533961748: 


If it is the portmap and inetd's problem? 




etc/service 
sunrpc 111/tcp portmap 
sunrpc 111/udp portmap 

/etc/inetd.conf 
#rstatd/1-3 dgram rpc/udp wait root /usr/sbin/tcpd rpc.rstatd 
#rusersd/2-3 dgram rpc/udp wait root /usr/sbin/tcpd rpc.rusersd 

Client use a random tcp port number to connect with server:111, then who 
will look after the SYN,ACK packet sent back by server, the inetd? Should 
I add a line in inetd.conf like "794    stream  tcp   nowait root portmap" 
, but it is a ramdom port number?! Or should there be a tcpd or sth run on 
my board????

Ask for help!!!!!

ps 

/usr/sbin/inetd 
/sbin/portmap 


--=_alternative 00224EE448257348_=
Content-Type: text/html; charset="US-ASCII"


<br><font size=2 face="sans-serif">Hi,</font>
<br><font size=2 face="sans-serif">&nbsp; &nbsp; &nbsp; &nbsp; </font>
<table width=100%>
<tr>
<td width=100% bgcolor=#a5a6c9><font size=2><br>
</font>
<table width=100%>
<tr>
<td width=100% bgcolor=#ffffee><font size=2 face="Verdana">I use kernel
2.4.20,busybox 1.3.1,the NFS server is V4.When I try to mount use <br>
<br>
mount -t nfs 10.25.16.130:/opt/Qtopia /opt/Qtopia <br>
<br>
Got error ,mount: RPC time out <br>
<br>
When I use ethreal on both the server and client side , found that the
server have sent SYN,ACK back to client with the TCP connection, but the
client just do not respond. I use portmap and also inetd. The tcpdump log
is look like this: <br>
<br>
10.25.16.160.794 &gt; 10.25.16.130.sunrpc: S, cksum 0x5740 (correct), 31406388
<br>
<br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x79e6 (correct), 2533961748:2
<br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x79e6 (correct), 2533961748:2
<br>
60) 10.25.16.160.794 &gt; 10.25.16.130.sunrpc: S, cksum 0x5614 (correct),
31406388 <br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x76ff (correct), 2533961748:2
<br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x76ff (correct), 2533961748:2
<br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x76f8 (correct), 2533961748:2
<br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x76f8 (correct), 2533961748:2
<br>
<br>
<br>
60) 10.25.16.160.794 &gt; 10.25.16.130.sunrpc: S, cksum 0x53bc (correct),
31406388 <br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x7123 (correct), 2533961748:2
<br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x7123 (correct), 2533961748:2
<br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x711c (correct), 2533961748:2
<br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x711c (correct), 2533961748:2
<br>
<br>
<br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x6563 (correct), 2533961748:2
<br>
60) 10.25.16.160.794 &gt; 10.25.16.130.sunrpc: S, cksum 0x4f0c (correct),
31406388 <br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x6561 (correct), 2533961748:2
<br>
10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x6563 (correct), 2533961748:
<br>
<br>
<br>
If it is the portmap and inetd's problem? </font></table>
<br></table>
<br>
<table width=100%>
<tr>
<td width=100% bgcolor=#a5a6c9><font size=2><br>
</font>
<table width=100%>
<tr>
<td width=100% bgcolor=#ffffee><font size=2 face="Verdana">etc/service
<br>
sunrpc 111/tcp portmap <br>
sunrpc 111/udp portmap <br>
<br>
/etc/inetd.conf <br>
#rstatd/1-3 dgram rpc/udp wait root /usr/sbin/tcpd rpc.rstatd <br>
#rusersd/2-3 dgram rpc/udp wait root /usr/sbin/tcpd rpc.rusersd <br>
</font>
<br><font size=2 face="Verdana">Client use a random tcp port number to
connect with server:111, then who will look after the SYN,ACK packet sent
back by server, the inetd? Should I add a line in inetd.conf like &quot;794
&nbsp; &nbsp;stream &nbsp;tcp &nbsp; nowait root &nbsp;portmap&quot; ,
but it is a ramdom port number?! Or should there be a tcpd or sth run on
my board????</font>
<br>
<br><font size=2 face="Verdana">Ask for help!!!!!</font>
<br><font size=2 face="Verdana"><br>
ps <br>
<br>
/usr/sbin/inetd <br>
/sbin/portmap </font></table>
<br></table>
<br>
--=_alternative 00224EE448257348_=--


--===============2057120063==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============2057120063==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============2057120063==--
