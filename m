From: alexander.liu@jazzsemi.com
Subject: RH8.0 nfs server, client RPC time_time_out issues
Date: Tue, 11 Feb 2003 09:01:07 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OF24B722A7.F9405887-ON88256CCA.005ABDD0-88256CCA.005D624F@nb.jazzsemi.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="=_alternative 005D624C88256CCA_="
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from cnxtsmtp2.conexant.com ([198.62.9.253])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18idlP-0000XU-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Feb 2003 09:00:07 -0800
Received: from npbsmtp1.conexant.com (npbsmtp1.nb.conexant.com [157.152.161.153])
	by cnxtsmtp2.conexant.com (8.9.3/8.9.3) with ESMTP id IAA14955
	for <nfs@lists.sourceforge.net>; Tue, 11 Feb 2003 08:59:58 -0800 (PST)
To: nfs@lists.sourceforge.net
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

This is a multipart message in MIME format.
--=_alternative 005D624C88256CCA_=
Content-Type: text/plain; charset="us-ascii"

Hello,

We are having issues with our nfs server based on Redhat 8.0. 
It seen that every other day or so, our nfs clients which are HPUX 10.20 
and Tru64 4.0D and Solaris 8 will not be able to access the server. 
Linux clients do not have any problems.

Client error messages include:

HPUX -    automount[621]: xx_fs:/raid/auto/home/rt_util server not 
responding: RPC_TIMED_OUT
TRU64 -  vmunix: NFS2 server not responding still trying
Solaris 8 - automountd[163]: [ID 748625 daemon.error] xx_fs server not 
responding: RPC_TIMED_OUT

The server appears to be fine.

I have searched the archives for RPC timeout errors and have implemented 
some of the suggestions such as:
Making sure the server name is in DNS and the local host table for reverse 
and forward resolution.

However, the problem continues.

Problem resolution currently means stopping and restarting NFS on the 
server.

Has anyone experience similar problems, am I overlooking something 
obvious, any suggestion on what I should look at next.

Thanks, 

Alex Liu
--=_alternative 005D624C88256CCA_=
Content-Type: text/html; charset="us-ascii"


<br><font size=2 face="sans-serif">Hello,</font>
<br>
<br><font size=2 face="sans-serif">We are having issues with our nfs server based on Redhat 8.0. </font>
<br><font size=2 face="sans-serif">It seen that every other day or so, our nfs clients which are HPUX 10.20 and Tru64 4.0D and Solaris 8 will not be able to access the server. </font>
<br><font size=2 face="sans-serif">Linux clients do not have any problems.</font>
<br>
<br><font size=2 face="sans-serif">Client error messages include:</font>
<br>
<br><font size=2 face="sans-serif">HPUX - &nbsp; &nbsp;automount[621]: xx_fs:/raid/auto/home/rt_util server not responding: RPC_TIMED_OUT</font>
<br><font size=2 face="sans-serif">TRU64 - &nbsp;vmunix: NFS2 server not responding still trying</font>
<br><font size=2 face="sans-serif">Solaris 8 - automountd[163]: [ID 748625 daemon.error] xx_fs server not responding: RPC_TIMED_OUT</font>
<br>
<br><font size=2 face="sans-serif">The server appears to be fine.</font>
<br>
<br><font size=2 face="sans-serif">I have searched the archives for RPC timeout errors and have implemented some of the suggestions such as:</font>
<br><font size=2 face="sans-serif">Making sure the server name is in DNS and the local host table for reverse and forward resolution.</font>
<br>
<br><font size=2 face="sans-serif">However, the problem continues.</font>
<br>
<br><font size=2 face="sans-serif">Problem resolution currently means stopping and restarting NFS on the server.</font>
<br>
<br><font size=2 face="sans-serif">Has anyone experience similar problems, am I overlooking something obvious, any suggestion on what I should look at next.</font>
<br>
<br><font size=2 face="sans-serif">Thanks, </font>
<br>
<br><font size=2 face="sans-serif">Alex Liu</font>
--=_alternative 005D624C88256CCA_=--


-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
