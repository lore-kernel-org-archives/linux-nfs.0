From: "Moshe Linzer" <Moshe.Linzer@nsc.com>
Subject: grpid mount option for NFS
Date: Tue, 11 Feb 2003 18:33:50 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <OFB8969C39.4D0AD0CC-ONC2256CCA.005AED06-C2256CCA.005B2E37@nsc.com>
Mime-Version: 1.0
Content-Type: multipart/alternative;
 boundary="=_alternative 005B2E20C2256CCA_="
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail1.nsc.com ([12.151.32.15] helo=sc2k-ntrdcss1.nsc.com)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18idM5-0003RE-00
	for <nfs@lists.sourceforge.net>; Tue, 11 Feb 2003 08:33:57 -0800
Received: from scsmtp01.nsc.com by scmh1.nsc.com with ESMTP for
 nfs@lists.sourceforge.net; Tue, 11 Feb 2003 08:33:41 -0800
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
--=_alternative 005B2E20C2256CCA_=
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit

How can I get the behaviour of the grpid mount option on NFS mounts? I.e., 
I want files created on the mounted FS to assume the GID of the parent 
dir, instead of the user's GID.  Solaris has such an option for nfs_mount, 
but Linux only seems to have it for ext2 mounts. 

thanks, 

Moshe 

Moshe Linzer
IT Manager 
National Semiconductor, Israel
Phone: 972-9-970-2247
Fax: 972-9-970-2001

--=_alternative 005B2E20C2256CCA_=
Content-Type: text/html;
 charset=us-ascii
Content-Transfer-Encoding: 7bit


<br><font size=2>How can I get the behaviour of the grpid mount option
on NFS mounts? I.e., I want files created on the mounted FS to assume the
GID of the parent dir, instead of the user's GID.&nbsp; Solaris has such
an option for nfs_mount, but Linux only seems to have it for ext2 mounts.
<br>
<br>
thanks, <br>
<br>
Moshe </font><font size=2 face="sans-serif"><br>
</font>
<table width=100%>
<tr>
<td width=100%><font size=4 color=blue><b>Moshe Linzer</b></font>
<br><font size=3 color=#000099><b>IT Manager</b> </font>
<tr>
<td><font size=2 color=#000099><b><i>National Semiconductor, Israel<br>
Phone: 972-9-970-2247<br>
Fax: 972-9-970-2001</i></b></font></table>
<br>
--=_alternative 005B2E20C2256CCA_=--



-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
