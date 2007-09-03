From: xiao.liang@cn.alps.com
Subject: Re: NFS:RPC timed out
Date: Mon, 3 Sep 2007 15:43:05 +0800
Message-ID: <OF71DC95A2.62F6D303-ON4825734B.002A2C79-4825734B.002A6166@alps.com.hk>
References: <1188569020.6649.78.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0309660683=="
Cc: nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IS7Ug-0003rk-S4
	for nfs@lists.sourceforge.net; Mon, 03 Sep 2007 01:41:15 -0700
Received: from [61.213.178.131] (helo=qalpsgw3.alps.co.jp)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IS767-000397-9Q
	for nfs@lists.sourceforge.net; Mon, 03 Sep 2007 01:15:52 -0700
In-Reply-To: <1188569020.6649.78.camel@heimdal.trondhjem.org>
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
--===============0309660683==
Content-Type: multipart/alternative;
	boundary="=_alternative 002A61634825734B_="

This is a multipart message in MIME format.
--=_alternative 002A61634825734B_=
Content-Type: text/plain; charset="ISO-2022-JP"

Yes, 'mount -t nfs4 10.25.16.130:/opt/Qtopia /opt/Qtopia' is reported with 
"No such device".

'rpcinfo -p 10.25.16.130' gives rpcinfo:cann't contact 
portmapper:RPC:Remote system error - Connection timed out





Trond Myklebust <trond.myklebust@fys.uio.no> 
08/31/2007 10:03 PM

宛先
xiao.liang@cn.alps.com
cc
nfs@lists.sourceforge.net
件名
Re: [NFS] NFS:RPC timed out






As I said previously, in order to mount and nfsv4 partition, you have to
'mount -t nfs4 10.25.16.130:/opt/Qtopia /opt/Qtopia'.

Otherwise, what does 'rpcinfo -p 10.25.16.130' give you?

Trond


On Fri, 2007-08-31 at 14:14 +0800, xiao.liang@cn.alps.com wrote:
> 
> Hi, 
> 
> 
> I use kernel 2.4.20,busybox 1.3.1,the NFS server is V4.When I try to
> mount use 
> 
> mount -t nfs 10.25.16.130:/opt/Qtopia /opt/Qtopia 
> 
> Got error ,mount: RPC time out 
> 
> When I use ethreal on both the server and client side , found that the
> server have sent SYN,ACK back to client with the TCP connection, but
> the client just do not respond. I use portmap and also inetd. The
> tcpdump log is look like this: 
> 
> 10.25.16.160.794 > 10.25.16.130.sunrpc: S, cksum 0x5740 (correct),
> 31406388 
> 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x79e6 (correct),
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x79e6 (correct),
> 2533961748:2 
> 60) 10.25.16.160.794 > 10.25.16.130.sunrpc: S, cksum 0x5614 (correct),
> 31406388 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x76ff (correct),
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x76ff (correct),
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x76f8 (correct),
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x76f8 (correct),
> 2533961748:2 
> 
> 
> 60) 10.25.16.160.794 > 10.25.16.130.sunrpc: S, cksum 0x53bc (correct),
> 31406388 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x7123 (correct),
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x7123 (correct),
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x711c (correct),
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x711c (correct),
> 2533961748:2 
> 
> 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x6563 (correct),
> 2533961748:2 
> 60) 10.25.16.160.794 > 10.25.16.130.sunrpc: S, cksum 0x4f0c (correct),
> 31406388 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x6561 (correct),
> 2533961748:2 
> 10.25.16.130.sunrpc > 10.25.16.160.794: S, cksum 0x6563 (correct),
> 2533961748: 
> 
> 
> If it is the portmap and inetd's problem? 
> 
> 
> 
> 
> etc/service 
> sunrpc 111/tcp portmap 
> sunrpc 111/udp portmap 
> 
> /etc/inetd.conf 
> #rstatd/1-3 dgram rpc/udp wait root /usr/sbin/tcpd rpc.rstatd 
> #rusersd/2-3 dgram rpc/udp wait root /usr/sbin/tcpd rpc.rusersd 
> 
> Client use a random tcp port number to connect with server:111, then
> who will look after the SYN,ACK packet sent back by server, the inetd?
> Should I add a line in inetd.conf like "794    stream  tcp   nowait
> root  portmap" , but it is a ramdom port number?! Or should there be a
> tcpd or sth run on my board???? 
> 
> Ask for help!!!!! 
> 
> ps 
> 
> /usr/sbin/inetd 
> /sbin/portmap 
> 
> 
> 
> 
-------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >>  http://get.splunk.com/
> _______________________________________________ NFS maillist - 
NFS@lists.sourceforge.net https://lists.sourceforge.net/lists/listinfo/nfs



--=_alternative 002A61634825734B_=
Content-Type: text/html; charset="ISO-2022-JP"


<br><font size=2 face="sans-serif">Yes, </font><tt><font size=2>'mount
-t nfs4 10.25.16.130:/opt/Qtopia /opt/Qtopia' is reported with &quot;No
such device&quot;.</font></tt>
<br>
<br><tt><font size=2>'rpcinfo -p 10.25.16.130' gives rpcinfo:cann't contact
portmapper:RPC:Remote system error - Connection timed out</font></tt>
<br>
<br>
<br>
<br>
<br>
<table width=100%>
<tr valign=top>
<td width=40%><font size=1 face="sans-serif"><b>Trond Myklebust &lt;trond.myklebust@fys.uio.no&gt;</b>
</font>
<p><font size=1 face="sans-serif">08/31/2007 10:03 PM</font>
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
<td><font size=1 face="sans-serif">Re: [NFS] NFS:RPC timed out</font></table>
<br>
<table>
<tr valign=top>
<td>
<td></table>
<br></table>
<br>
<br>
<br><tt><font size=2>As I said previously, in order to mount and nfsv4
partition, you have to<br>
'mount -t nfs4 10.25.16.130:/opt/Qtopia /opt/Qtopia'.<br>
<br>
Otherwise, what does 'rpcinfo -p 10.25.16.130' give you?<br>
<br>
Trond<br>
<br>
<br>
On Fri, 2007-08-31 at 14:14 +0800, xiao.liang@cn.alps.com wrote:<br>
&gt; <br>
&gt; Hi, <br>
&gt; &nbsp; &nbsp; &nbsp; &nbsp; <br>
&gt; <br>
&gt; I use kernel 2.4.20,busybox 1.3.1,the NFS server is V4.When I try
to<br>
&gt; mount use <br>
&gt; <br>
&gt; mount -t nfs 10.25.16.130:/opt/Qtopia /opt/Qtopia <br>
&gt; <br>
&gt; Got error ,mount: RPC time out <br>
&gt; <br>
&gt; When I use ethreal on both the server and client side , found that
the<br>
&gt; server have sent SYN,ACK back to client with the TCP connection, but<br>
&gt; the client just do not respond. I use portmap and also inetd. The<br>
&gt; tcpdump log is look like this: <br>
&gt; <br>
&gt; 10.25.16.160.794 &gt; 10.25.16.130.sunrpc: S, cksum 0x5740 (correct),<br>
&gt; 31406388 <br>
&gt; <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x79e6 (correct),<br>
&gt; 2533961748:2 <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x79e6 (correct),<br>
&gt; 2533961748:2 <br>
&gt; 60) 10.25.16.160.794 &gt; 10.25.16.130.sunrpc: S, cksum 0x5614 (correct),<br>
&gt; 31406388 <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x76ff (correct),<br>
&gt; 2533961748:2 <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x76ff (correct),<br>
&gt; 2533961748:2 <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x76f8 (correct),<br>
&gt; 2533961748:2 <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x76f8 (correct),<br>
&gt; 2533961748:2 <br>
&gt; <br>
&gt; <br>
&gt; 60) 10.25.16.160.794 &gt; 10.25.16.130.sunrpc: S, cksum 0x53bc (correct),<br>
&gt; 31406388 <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x7123 (correct),<br>
&gt; 2533961748:2 <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x7123 (correct),<br>
&gt; 2533961748:2 <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x711c (correct),<br>
&gt; 2533961748:2 <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x711c (correct),<br>
&gt; 2533961748:2 <br>
&gt; <br>
&gt; <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x6563 (correct),<br>
&gt; 2533961748:2 <br>
&gt; 60) 10.25.16.160.794 &gt; 10.25.16.130.sunrpc: S, cksum 0x4f0c (correct),<br>
&gt; 31406388 <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x6561 (correct),<br>
&gt; 2533961748:2 <br>
&gt; 10.25.16.130.sunrpc &gt; 10.25.16.160.794: S, cksum 0x6563 (correct),<br>
&gt; 2533961748: <br>
&gt; <br>
&gt; <br>
&gt; If it is the portmap and inetd's problem? <br>
&gt; <br>
&gt; <br>
&gt; <br>
&gt; <br>
&gt; etc/service <br>
&gt; sunrpc 111/tcp portmap <br>
&gt; sunrpc 111/udp portmap <br>
&gt; <br>
&gt; /etc/inetd.conf <br>
&gt; #rstatd/1-3 dgram rpc/udp wait root /usr/sbin/tcpd rpc.rstatd <br>
&gt; #rusersd/2-3 dgram rpc/udp wait root /usr/sbin/tcpd rpc.rusersd <br>
&gt; <br>
&gt; Client use a random tcp port number to connect with server:111, then<br>
&gt; who will look after the SYN,ACK packet sent back by server, the inetd?<br>
&gt; Should I add a line in inetd.conf like &quot;794 &nbsp; &nbsp;stream
&nbsp;tcp &nbsp; nowait<br>
&gt; root &nbsp;portmap&quot; , but it is a ramdom port number?! Or should
there be a<br>
&gt; tcpd or sth run on my board???? <br>
&gt; <br>
&gt; Ask for help!!!!! <br>
&gt; <br>
&gt; ps <br>
&gt; <br>
&gt; /usr/sbin/inetd <br>
&gt; /sbin/portmap <br>
&gt; <br>
&gt; <br>
&gt; <br>
&gt; -------------------------------------------------------------------------<br>
&gt; This SF.net email is sponsored by: Splunk Inc.<br>
&gt; Still grepping through log files to find problems? &nbsp;Stop.<br>
&gt; Now Search log events and configuration files using AJAX and a browser.<br>
&gt; Download your FREE copy of Splunk now &gt;&gt; &nbsp;http://get.splunk.com/<br>
&gt; _______________________________________________ NFS maillist - NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs<br>
<br>
</font></tt>
<br>
--=_alternative 002A61634825734B_=--


--===============0309660683==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
--===============0309660683==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0309660683==--
