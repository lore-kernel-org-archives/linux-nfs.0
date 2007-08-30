From: xiao.liang@cn.alps.com
Subject: Re: mount nfs:RPC timeout
Date: Thu, 30 Aug 2007 17:45:34 +0800
Message-ID: <OF1293E709.88AA97BF-ON48257347.000F4C02-48257347.00352090@alps.com.hk>
References: <1188398161.6580.68.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1550852251=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQgWc-0001yP-KP
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 02:41:20 -0700
Received: from [61.213.178.131] (helo=qalpsgw3.alps.co.jp)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IQgWg-0003Wv-Ha
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 02:41:23 -0700
In-Reply-To: <1188398161.6580.68.camel@heimdal.trondhjem.org>
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
--===============1550852251==
Content-Type: multipart/alternative;
	boundary="=_alternative 0035208D48257347_="

This is a multipart message in MIME format.
--=_alternative 0035208D48257347_=
Content-Type: text/plain; charset="ISO-2022-JP"

Thank you! Now I do not think it is version problem. Actually, I found 
that the TCP connection is never complete between my nfs client and 
server. The server reply the SYN,ACK but the client just do not respond. 
As for UDP is the same . I use inetd and portmap on client side , I think 
there must be sth wrong on my client side.
packets :
from client to server:
src port : 794, dest port:111
from server to client:
src port:111 dest port:794

the tcpdump on the client side is look like this

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

Is it the portmap or inetd' problem?




Trond Myklebust <trond.myklebust@fys.uio.no> 
08/29/2007 10:36 PM

宛先
xiao.liang@cn.alps.com
cc
nfs@lists.sourceforge.net
件名
Re: [NFS] mount nfs:RPC timeout






On Wed, 2007-08-29 at 14:08 +0800, xiao.liang@cn.alps.com wrote:
> 
> Hi, 
>    I have encounter a nfs mount problem, I use busybox1.3.1,kernel
> version 2.4.20,libc version 2.3.2. The NFS server is V4 
> 
>    The error is: 
> 
>         mount -t nfs 10.25.16.130:/opt/Qtopia /opt/Qtopia 
> 
>    after a while 
> 
>         mount : RPC : timed out. 
>         mount: nfsmount failed: Bad file descriptor 
> 
>   I use ethereal to catch log in the NFS server side, and found the
> mount protocol is V1. And another success nfs mount use mount protocol
> V3. Is it the problem? 
>   And I do not know how can change the mount protocol to V3, I tried
> to use the same busybox, the same libc, the same kernel as the success
> mount but none worked. 
>   Any suggestion is very very very appreciate! 

mount -t nfs4 10.25.16.130:/opt/Qtopia /opt/Qtopia
            ^

Please also ensure that you have rpc.idmapd running first.

Cheers
  Trond



--=_alternative 0035208D48257347_=
Content-Type: text/html; charset="ISO-2022-JP"


<br><font size=2 face="sans-serif">Thank you! Now I do not think it is
version problem. Actually, I found that the TCP connection is never complete
between my nfs client and server. The server reply the SYN,ACK but the
client just do not respond. As for UDP is the same . I use inetd and portmap
on client side , I think there must be sth wrong on my client side.</font>
<br><font size=2 face="sans-serif">packets :</font>
<br><font size=2 face="sans-serif">from client to server:</font>
<br><font size=2 face="sans-serif">src port : 794, dest port:111</font>
<br><font size=2 face="sans-serif">from server to client:</font>
<br><font size=2 face="sans-serif">src port:111 dest port:794</font>
<br>
<br><font size=2 face="sans-serif">the tcpdump on the client side is look
like this</font>
<br>
<br><font size=2 face="sans-serif">10.25.16.160.794 &gt; 10.25.16.130.sunrpc:
S, cksum 0x5740 (correct), 31406388</font>
<br>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x79e6 (correct), 2533961748:2</font>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x79e6 (correct), 2533961748:2</font>
<br><font size=2 face="sans-serif">&nbsp;60) 10.25.16.160.794 &gt; 10.25.16.130.sunrpc:
S, cksum 0x5614 (correct), 31406388</font>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x76ff (correct), 2533961748:2</font>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x76ff (correct), 2533961748:2</font>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x76f8 (correct), 2533961748:2</font>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x76f8 (correct), 2533961748:2</font>
<br>
<br>
<br><font size=2 face="sans-serif">&nbsp;60) 10.25.16.160.794 &gt; 10.25.16.130.sunrpc:
S, cksum 0x53bc (correct), 31406388</font>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x7123 (correct), 2533961748:2</font>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x7123 (correct), 2533961748:2</font>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x711c (correct), 2533961748:2</font>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x711c (correct), 2533961748:2</font>
<br>
<br>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x6563 (correct), 2533961748:2</font>
<br><font size=2 face="sans-serif">&nbsp;60) 10.25.16.160.794 &gt; 10.25.16.130.sunrpc:
S, cksum 0x4f0c (correct), 31406388</font>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x6561 (correct), 2533961748:2</font>
<br><font size=2 face="sans-serif">&nbsp;10.25.16.130.sunrpc &gt; 10.25.16.160.794:
S, cksum 0x6563 (correct), 2533961748:</font>
<br>
<br><font size=2 face="sans-serif">Is it the portmap or inetd' problem?</font>
<br>
<br>
<br>
<br>
<table width=100%>
<tr valign=top>
<td width=40%><font size=1 face="sans-serif"><b>Trond Myklebust &lt;trond.myklebust@fys.uio.no&gt;</b>
</font>
<p><font size=1 face="sans-serif">08/29/2007 10:36 PM</font>
<td width=59%>
<table width=100%>
<tr valign=top>
<td>
<div align=right><font size=1 face="sans-serif">宛先</font></div>
<td><font size=1 face="sans-serif">xiao.liang@cn.alps.com</font>
<tr valign=top>
<td>
<div align=right><font size=1 face="sans-serif">cc</font></div>
<td><font size=1 face="sans-serif">nfs@lists.sourceforge.net</font>
<tr valign=top>
<td>
<div align=right><font size=1 face="sans-serif">件名</font></div>
<td><font size=1 face="sans-serif">Re: [NFS] mount nfs:RPC timeout</font></table>
<br>
<table>
<tr valign=top>
<td>
<td></table>
<br></table>
<br>
<br>
<br><tt><font size=2>On Wed, 2007-08-29 at 14:08 +0800, xiao.liang@cn.alps.com
wrote:<br>
&gt; <br>
&gt; Hi, <br>
&gt; &nbsp; &nbsp;I have encounter a nfs mount problem, I use busybox1.3.1,kernel<br>
&gt; version 2.4.20,libc version 2.3.2. The NFS server is V4 <br>
&gt; <br>
&gt; &nbsp; &nbsp;The error is: <br>
&gt; <br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; mount -t nfs 10.25.16.130:/opt/Qtopia
/opt/Qtopia <br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; <br>
&gt; &nbsp; &nbsp;after a while <br>
&gt; <br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; mount : RPC : timed out. <br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; mount: nfsmount failed: Bad file descriptor
<br>
&gt; <br>
&gt; &nbsp; I use ethereal to catch log in the NFS server side, and found
the<br>
&gt; mount protocol is V1. And another success nfs mount use mount protocol<br>
&gt; V3. Is it the problem? <br>
&gt; &nbsp; And I do not know how can change the mount protocol to V3,
I tried<br>
&gt; to use the same busybox, the same libc, the same kernel as the success<br>
&gt; mount but none worked. <br>
&gt; &nbsp; Any suggestion is very very very appreciate! <br>
<br>
mount -t nfs4 10.25.16.130:/opt/Qtopia /opt/Qtopia<br>
 &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;^<br>
<br>
Please also ensure that you have rpc.idmapd running first.<br>
<br>
Cheers<br>
 &nbsp;Trond<br>
<br>
</font></tt>
<br>
--=_alternative 0035208D48257347_=--


--===============1550852251==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============1550852251==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1550852251==--
