From: Myra Hager <myra.hager@halsystems.com>
Subject: can't contact portmapper - connection refused.
Date: Tue, 10 Jun 2003 13:25:03 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <9A0276ECD63AD4118D1300E018C2F89418C258@HAL01>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C32F75.3A2E7C70"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [66.147.40.129] (helo=hal01.halnt)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19PmfU-0000jr-00
	for <nfs@lists.sourceforge.net>; Tue, 10 Jun 2003 10:12:20 -0700
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C32F75.3A2E7C70
Content-Type: text/plain

I am having trouble getting my exported file systems mounted on another
system.  

 

Here are the details:

Running on a RH 7.2 system on a tcpip local area network (not connected to
the internet).  Running the nfs that shipped on the distro.  Have other
redhat servers running NFS just fine.  Kernel version is 2.4.18-3.

 

On the problem server:

Here is my /etc/exports file:

 

/a     192.0.0.100(rw,no_root_squash,insecure)

/b     192.0.0.100(rw,no_root_squash,insecure)

/c     192.0.0.100(rw,no_root_squash,insecure)

/a     192.0.0.3(rw,no_root_squash,insecure)

/b     192.0.0.3(rw,no_root_squash,insecure)

/c     192.0.0.3(rw,no_root_squash,insecure)

 

hosts.allow is ALL : ALL

hosts.deny has no entries.  (this is a small development network with no
connection to internet.)

 

here is the output of my rpcinfo -p from the NFS server:

 

program vers proto   port

    100000    2   tcp    111  portmapper

    100000    2   udp    111  portmapper

    100011    1   udp    664  rquotad

    100011    2   udp    664  rquotad

    100011    1   tcp    667  rquotad

    100011    2   tcp    667  rquotad

    100005    1   udp   1030  mountd

    100005    1   tcp   1039  mountd

    100005    2   udp   1030  mountd

    100005    2   tcp   1039  mountd

    100005    3   udp   1030  mountd

    100005    3   tcp   1039  mountd

    100003    2   udp   2049  nfs

    100003    3   udp   2049  nfs

    100021    1   udp   1031  nlockmgr

    100021    3   udp   1031  nlockmgr

    100021    4   udp   1031  nlockmgr

 

here is the output of my rpcinfo -p zoot1 from the client SCO:

 

rpcinfo: can't contact portmapper: RPC: Remote system error - Connection
refused.

 

Also get the same kind of error when running rpcinfo -p zoot1 from another
AIX client (rpcinfo: can't contact portmapper: RPC: Success).

 

I can ping the server from the clients by IP and name.  I can also telnet
and ftp to the server.

 

 

If I look in /var/log/messages I see this one below that is curious to me.

Jun 10 15:18:25 zoot1 rpc.mountd: Caught signal 15, un-registering and
exiting.

 

Can someone please tell me what I seem to be missing here?  

 

Many Kind Regards,

 

Myra Hager

 

 


------_=_NextPart_001_01C32F75.3A2E7C70
Content-Type: text/html

<html>

<head>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=us-ascii">


<meta name=Generator content="Microsoft Word 10 (filtered)">

<style>
<!--
 /* Font Definitions */
 @font-face
	{font-family:"Lucida Sans Unicode";
	panose-1:2 11 6 2 3 5 4 2 2 4;}
 /* Style Definitions */
 p.MsoNormal, li.MsoNormal, div.MsoNormal
	{margin:0in;
	margin-bottom:.0001pt;
	font-size:12.0pt;
	font-family:"Times New Roman";}
a:link, span.MsoHyperlink
	{color:blue;
	text-decoration:underline;}
a:visited, span.MsoHyperlinkFollowed
	{color:purple;
	text-decoration:underline;}
span.EmailStyle17
	{font-family:Arial;
	color:windowtext;}
@page Section1
	{size:8.5in 11.0in;
	margin:1.0in 1.25in 1.0in 1.25in;}
div.Section1
	{page:Section1;}
-->
</style>

</head>

<body lang=EN-US link=blue vlink=purple>

<div class=Section1>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>I am having trouble getting my exported file systems mounted
on another system. &nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>Here are the details:</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>Running on a RH 7.2 system on a tcpip local area network
(not connected to the internet). &nbsp;Running the nfs that shipped on the
distro.&nbsp; Have other redhat servers running NFS just fine.&nbsp; Kernel
version is 2.4.18-3.</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>On the problem server:</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>Here is my /etc/exports file:</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>/a&nbsp;&nbsp;&nbsp;&nbsp; 192.0.0.100(rw,no_root_squash,insecure)</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>/b&nbsp;&nbsp;&nbsp;&nbsp; 192.0.0.100(rw,no_root_squash,insecure)</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>/c&nbsp;&nbsp;&nbsp;&nbsp; 192.0.0.100(rw,no_root_squash,insecure)</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>/a&nbsp;&nbsp;&nbsp;&nbsp; 192.0.0.3(rw,no_root_squash,insecure)</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>/b&nbsp;&nbsp;&nbsp;&nbsp; 192.0.0.3(rw,no_root_squash,insecure)</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>/c&nbsp;&nbsp;&nbsp;&nbsp; 192.0.0.3(rw,no_root_squash,insecure)</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>hosts.allow is ALL : ALL</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>hosts.deny has no entries.&nbsp; (this is a small
development network with no connection to internet.)</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>here is the output of my rpcinfo -p from the NFS
server:</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>program vers proto&nbsp;&nbsp; port</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp; </span></font><font
size=2 face=Arial><span lang=FR style='font-size:10.0pt;font-family:Arial'>tcp&nbsp;&nbsp;&nbsp;
111&nbsp; portmapper</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span lang=FR style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100000&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 111&nbsp; portmapper</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span lang=FR style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 664&nbsp; rquotad</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span lang=FR style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;
udp&nbsp;&nbsp;&nbsp; 664&nbsp; rquotad</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span lang=FR style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 667&nbsp; rquotad</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span lang=FR style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100011&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;
tcp&nbsp;&nbsp;&nbsp; 667&nbsp; rquotad</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span lang=FR style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;
udp&nbsp;&nbsp; 1030&nbsp; mountd</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span lang=FR style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; </span></font><font size=2 face=Arial><span
style='font-size:10.0pt;font-family:Arial'>100005&nbsp;&nbsp;&nbsp;
1&nbsp;&nbsp; tcp&nbsp;&nbsp; 1039&nbsp; mountd</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;
udp&nbsp;&nbsp; 1030&nbsp; mountd</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;
tcp&nbsp;&nbsp; 1039&nbsp; mountd</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp;
udp&nbsp;&nbsp; 1030&nbsp; mountd</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100005&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp;
tcp&nbsp;&nbsp; 1039&nbsp; mountd</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; 2&nbsp;&nbsp;
udp&nbsp;&nbsp; 2049&nbsp; nfs</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100003&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp;
udp&nbsp;&nbsp; 2049&nbsp; nfs</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; 1&nbsp;&nbsp;
udp&nbsp;&nbsp; 1031&nbsp; nlockmgr</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; 3&nbsp;&nbsp;
udp&nbsp;&nbsp; 1031&nbsp; nlockmgr</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;&nbsp;&nbsp; 100021&nbsp;&nbsp;&nbsp; 4&nbsp;&nbsp;
udp&nbsp;&nbsp; 1031&nbsp; nlockmgr</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>here is the output of my rpcinfo -p zoot1 from the
client SCO:</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>rpcinfo: can't contact portmapper: RPC: Remote system error
- Connection refused.</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>Also get the same kind of error when running rpcinfo -p
zoot1 from another AIX client (rpcinfo: can't contact portmapper: RPC: Success).</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>I can ping the server from the clients by IP and name.&nbsp;
I can also telnet and ftp to the server.</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>If I look in /var/log/messages I see this one below that is
curious to me.</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>Jun 10 </span></font><font size=2 face=Arial><span
 style='font-size:10.0pt;font-family:Arial'>15:18:25</span></font><font size=2
face=Arial><span style='font-size:10.0pt;font-family:Arial'> zoot1 rpc.mountd:
Caught signal 15, un-registering and exiting.</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>Can someone please tell me what I seem to be missing
here?&nbsp; </span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>Many Kind Regards,</span></font></p>

<p class=MsoNormal><font size=2 face=Arial><span style='font-size:10.0pt;
font-family:Arial'>&nbsp;</span></font></p>

<div>

<p class=MsoNormal><font size=2 color=blue face="Lucida Sans Unicode"><span
  style='font-size:10.0pt;font-family:"Lucida Sans Unicode";color:blue'>Myra</span></font><font
size=2 color=blue face="Lucida Sans Unicode"><span style='font-size:10.0pt;
font-family:"Lucida Sans Unicode";color:blue'> Hager</span></font></p>

</div>

<div>

<p class=MsoNormal><font size=3 face="Times New Roman"><span style='font-size:
12.0pt'>&nbsp;</span></font></p>

</div>

<p class=MsoNormal><font size=3 face="Times New Roman"><span style='font-size:
12.0pt'>&nbsp;</span></font></p>

</div>

</body>

</html>

------_=_NextPart_001_01C32F75.3A2E7C70--


-------------------------------------------------------
This SF.net email is sponsored by:  Etnus, makers of TotalView, The best
thread debugger on the planet. Designed with thread debugging features
you've never dreamed of, try TotalView 6 free at www.etnus.com.
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
