From: "Kouri, William" <wkouri@sandia.gov>
Subject: NLM UDP and TCP
Date: Mon, 16 Feb 2004 13:14:49 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <AC89BDA1E3CCBC42B9CA5B50FE7934D306C96DFE@es10snlnt.sandia.gov>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="----_=_NextPart_001_01C3F4C8.F5991916"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AspCl-0003Xi-R4
	for nfs@lists.sourceforge.net; Mon, 16 Feb 2004 12:18:59 -0800
Received: from mm01snlnto.sandia.gov ([132.175.109.20] helo=MM01SNLNTO.son.sandia.gov)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Asp92-0006Ul-Nz
	for nfs@lists.sourceforge.net; Mon, 16 Feb 2004 12:15:08 -0800
Received: from es08snlnt.sandia.gov (es08snlnt.sandia.gov
 [134.253.130.11]) by mailgate2.sandia.gov (8.12.10/8.12.10) with ESMTP
 id i1GKEthc019129 for <nfs@lists.sourceforge.net>; Mon, 16 Feb 2004 13:
 14:55 -0700 (MST)
To: "'nfs@lists.sourceforge.net'" <nfs@lists.sourceforge.net>
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

This message is in MIME format. Since your mail reader does not understand
this format, some or all of this message may not be legible.

------_=_NextPart_001_01C3F4C8.F5991916
Content-Type: text/plain;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit

We currently have Redhat 9 clients (2.4.20-28.9).

When attempting to NFS mount Sun (Solaris 8) file systems, the Sun is asking
for the

network lock manager service on a TCP port. An "rpcinfo -p" on the client
shows only 

UDP ports registered with portmapper. "netstat -npa" also shows that there
are 

no TCP ports open for NLM. We added "options lockd nlm_udpport=4001 

nlm_tcpport=4001" to the /etc/modules.conf file. The udp port did change to 

4001, but the tcp port still did not come up. All of the documentation we
have 

seen on the WEB shows nlockmgr listening on both UDP and TCP ports. 

See: 

http://www.europe.redhat.com/documentation/HOWTO/NFS-HOWTO/server.php3#CONFI
G 

How do we get network lock manager to listen on TCP ports?

 

Thanks, Bill Kouri


------_=_NextPart_001_01C3F4C8.F5991916
Content-Type: text/html;
 charset=iso-8859-1
Content-Transfer-Encoding: 7bit

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=ISO-8859-1">


<META content="MSHTML 6.00.2800.1276" name=GENERATOR></HEAD>
<BODY>
<DIV>
<P><SPAN class=187381020-16022004><FONT face=Arial size=2>We currently have 
Redhat 9 clients (2.4.20-28.9).</FONT></SPAN></P>
<P><FONT face=Arial size=2>When attempting to NFS mount Sun<SPAN 
class=187381020-16022004> (Solaris 8)</SPAN>&nbsp;file systems, the Sun is 
asking for the</FONT></P>
<P><FONT face=Arial size=2>network lock manager service on a TCP port. An 
"rpcinfo -p" on the client shows only </FONT></P>
<P><FONT face=Arial size=2>UDP ports registered with portmapper. "netstat -npa" 
also shows that there are </FONT></P>
<P><FONT face=Arial size=2>no TCP ports open for NLM. We added "options lockd 
nlm_udpport=4001 </FONT></P>
<P><FONT face=Arial size=2>nlm_tcpport=4001" to the /etc/modules.conf file. The 
udp port did change to </FONT></P>
<P><FONT face=Arial size=2>4001, but the tcp port still did not come up. All of 
the documentation we have </FONT></P>
<P><FONT face=Arial size=2>seen on the WEB shows nlockmgr listening on both UDP 
and TCP ports. </FONT></P>
<P><FONT face=Arial size=2>See: </FONT></P>
<P><FONT face=Arial 
size=2>http://www.europe.redhat.com/documentation/HOWTO/NFS-HOWTO/server.php3#CONFIG 
</FONT></P>
<P><FONT face=Arial size=2></FONT></P>
<P><FONT face=Arial size=2>How do we get network lock manager to listen on TCP 
ports?</FONT></P>
<P><FONT face=Arial size=2></FONT>&nbsp;</P>
<P><SPAN class=187381020-16022004><FONT face=Arial size=2>Thanks, Bill 
Kouri</FONT></SPAN></P></DIV></BODY></HTML>

------_=_NextPart_001_01C3F4C8.F5991916--



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
