From: "Stuckless, Colin" <cstuckless@petro-canada.ca>
Subject: RE: RHEL3 Update 1 and NetApp NFS freeze issues
Date: Fri, 10 Sep 2004 08:42:16 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <B9F4645CD7B0D511BE8300508B68C327025EB3EC@tnscapp02.pcacorp.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C49744.3982B858"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C5meD-0001Z1-L5
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 07:45:09 -0700
Received: from pcx1.petro-canada.ca ([209.82.98.50] helo=pcaxs03.petro-canada.ca)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1C5me4-0006Eb-1E
	for nfs@lists.sourceforge.net; Fri, 10 Sep 2004 07:45:04 -0700
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

------_=_NextPart_001_01C49744.3982B858
Content-Type: text/plain

> -----Original Message-----
> From: nfs-admin@lists.sourceforge.net 
> [mailto:nfs-admin@lists.sourceforge.net] 
> Sent: Thursday, September 09, 2004 10:18 PM
> To: 'nfs@lists.sourceforge.net'
> Subject: [NFS] RHEL3 Update 1 and NetApp NFS freeze issues
> 
> 
> Greetings,
> 
> This is a bit of a stab in the dark but I thought this might 
> be a good forum to ask for input as it has both Linux NFS 
> experts and a NetApp expert who are regular contributors.  We 
> are unsure what the cause of the problem is (even whether 
> it's hardware or software) but one of our focuses is NFS hangs.
> ...
> Previous to switching to NFS via TCP the "retrans" counter 
> shown via nfsstat was an extremely high percentage of total 
> rpc calls.  Our NetApps are extremely busy with hundreds of 
> Linux clients pounding them with reads/writes.  These 
> machines are used in an EDA/engineering environment where we 
> have hundreds of Linux clients accessing a set of NetApp 
> Filers via Ethernet.  In this case the machines which crash 
> are Opteron boxes with Broadcom NICs using the tg3 driver.  
> We have RHEL3 Intel Xeon machines which don't exhibit this 
> problem as well as hundreds of RH7.2/7.3 clients which don't 
> exhibit the problem.

What's the latest status of the tg3 driver vs. the bcm5700 driver for the
Broadcom? I know HP supplies the bcm5700 with their workstations/servers
that have Broadcom chipsets, and I've never had a problem with them here. 

The tg3 driver is somewhat annoying in that it doesn't support parameters
via modules.conf to force certain settings (ethtool or mii-tool being the
preferred method I guess). I know I have seen complaints against the
stability of tg3 drivers in the past. This one from November 2002 is dated
now but might be worth looking at:
http://lists.us.dell.com/pipermail/linux-poweredge/2002-November/010486.html


-cjs


                         ********************

This email communication is intended as a private communication for the sole
use of the primary addressee and those individuals listed for copies in the
original message. The information contained in this email is private and
confidential and If you are not an intended recipient you are hereby
notified that copying, forwarding or other dissemination or distribution of
this communication by any means is prohibited.  If you are not specifically
authorized to receive this email and if you believe that you received it in
error please notify the original sender immediately.  We honour similar
requests relating to the privacy of email communications.

Cette communication par courrier electronique est une communication privee a
l'usage exclusif du destinataire principal ainsi que des personnes dont les
noms figurent en copie.  Les renseignements contenus dans ce courriel sont
confidentiels et si vous n'etes pas le destinataire prevu, vous etes avise,
par les presentes que toute reproduction, transfert ou autre forme de
diffusion de cette communication par quelque moyen que ce soit est
interdite.  Si vous n'etes pas specifiquement autorise a recevoir ce
courriel ou si vous croyez l'avoir recu par erreur, veuillez en aviser
l'expediteur original immediatement.  Nous respectons les demandes
similaires qui touchent la confidentialite des communications par courrier
electronique.

------_=_NextPart_001_01C49744.3982B858
Content-Type: text/html
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3Dus-ascii">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
5.5.2658.2">
<TITLE>RE: [NFS] RHEL3 Update 1 and NetApp NFS freeze issues</TITLE>
</HEAD>
<BODY>

<P><FONT SIZE=3D2>&gt; -----Original Message-----</FONT>
<BR><FONT SIZE=3D2>&gt; From: nfs-admin@lists.sourceforge.net </FONT>
<BR><FONT SIZE=3D2>&gt; [<A =
HREF=3D"mailto:nfs-admin@lists.sourceforge.net">mailto:nfs-admin@lists.s=
ourceforge.net</A>] </FONT>
<BR><FONT SIZE=3D2>&gt; Sent: Thursday, September 09, 2004 10:18 =
PM</FONT>
<BR><FONT SIZE=3D2>&gt; To: 'nfs@lists.sourceforge.net'</FONT>
<BR><FONT SIZE=3D2>&gt; Subject: [NFS] RHEL3 Update 1 and NetApp NFS =
freeze issues</FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt; Greetings,</FONT>
<BR><FONT SIZE=3D2>&gt; </FONT>
<BR><FONT SIZE=3D2>&gt; This is a bit of a stab in the dark but I =
thought this might </FONT>
<BR><FONT SIZE=3D2>&gt; be a good forum to ask for input as it has both =
Linux NFS </FONT>
<BR><FONT SIZE=3D2>&gt; experts and a NetApp expert who are regular =
contributors.&nbsp; We </FONT>
<BR><FONT SIZE=3D2>&gt; are unsure what the cause of the problem is =
(even whether </FONT>
<BR><FONT SIZE=3D2>&gt; it's hardware or software) but one of our =
focuses is NFS hangs.</FONT>
<BR><FONT SIZE=3D2>&gt; ...</FONT>
<BR><FONT SIZE=3D2>&gt; Previous to switching to NFS via TCP the =
&quot;retrans&quot; counter </FONT>
<BR><FONT SIZE=3D2>&gt; shown via nfsstat was an extremely high =
percentage of total </FONT>
<BR><FONT SIZE=3D2>&gt; rpc calls.&nbsp; Our NetApps are extremely busy =
with hundreds of </FONT>
<BR><FONT SIZE=3D2>&gt; Linux clients pounding them with =
reads/writes.&nbsp; These </FONT>
<BR><FONT SIZE=3D2>&gt; machines are used in an EDA/engineering =
environment where we </FONT>
<BR><FONT SIZE=3D2>&gt; have hundreds of Linux clients accessing a set =
of NetApp </FONT>
<BR><FONT SIZE=3D2>&gt; Filers via Ethernet.&nbsp; In this case the =
machines which crash </FONT>
<BR><FONT SIZE=3D2>&gt; are Opteron boxes with Broadcom NICs using the =
tg3 driver.&nbsp; </FONT>
<BR><FONT SIZE=3D2>&gt; We have RHEL3 Intel Xeon machines which don't =
exhibit this </FONT>
<BR><FONT SIZE=3D2>&gt; problem as well as hundreds of RH7.2/7.3 =
clients which don't </FONT>
<BR><FONT SIZE=3D2>&gt; exhibit the problem.</FONT>
</P>

<P><FONT SIZE=3D2>What's the latest status of the tg3 driver vs. the =
bcm5700 driver for the Broadcom? I know HP supplies the bcm5700 with =
their workstations/servers that have Broadcom chipsets, and I've never =
had a problem with them here. </FONT></P>

<P><FONT SIZE=3D2>The tg3 driver is somewhat annoying in that it =
doesn't support parameters via modules.conf to force certain settings =
(ethtool or mii-tool being the preferred method I guess). I know I have =
seen complaints against the stability of tg3 drivers in the past. This =
one from November 2002 is dated now but might be worth looking at: <A =
HREF=3D"http://lists.us.dell.com/pipermail/linux-poweredge/2002-November=
/010486.html" =
TARGET=3D"_blank">http://lists.us.dell.com/pipermail/linux-poweredge/200=
2-November/010486.html</A></FONT></P>
<BR>

<P><FONT SIZE=3D2>-cjs</FONT>
</P>
<BR>

<P><FONT =
SIZE=3D2>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb=
sp;&nbsp; ********************</FONT>
</P>

<P><FONT SIZE=3D2>This email communication is intended as a private =
communication for the sole use of the primary addressee and those =
individuals listed for copies in the original message. The information =
contained in this email is private and confidential and If you are not =
an intended recipient you are hereby notified that copying, forwarding =
or other dissemination or distribution of this communication by any =
means is prohibited.&nbsp; If you are not specifically authorized to =
receive this email and if you believe that you received it in error =
please notify the original sender immediately.&nbsp; We honour similar =
requests relating to the privacy of email communications.</FONT></P>

<P><FONT SIZE=3D2>Cette communication par courrier &eacute;lectronique =
est une communication priv&eacute;e &agrave; l'usage exclusif du =
destinataire principal ainsi que des personnes dont les noms figurent =
en copie.&nbsp; Les renseignements contenus dans ce courriel sont =
confidentiels et si vous n'&ecirc;tes pas le destinataire pr&eacute;vu, =
vous &ecirc;tes avis&eacute;, par les pr&eacute;sentes que toute =
reproduction, transfert ou autre forme de diffusion de cette =
communication par quelque moyen que ce soit est interdite.&nbsp; Si =
vous n'&ecirc;tes pas sp&eacute;cifiquement autoris&eacute; &agrave; =
recevoir ce courriel ou si vous croyez l'avoir re&ccedil;u par erreur, =
veuillez en aviser l'exp&eacute;diteur original =
imm&eacute;diatement.&nbsp; Nous respectons les demandes similaires qui =
touchent la confidentialit&eacute; des communications par courrier =
&eacute;lectronique.</FONT></P>

</BODY>
</HTML>
------_=_NextPart_001_01C49744.3982B858--


-------------------------------------------------------
This SF.Net email is sponsored by: YOU BE THE JUDGE. Be one of 170
Project Admins to receive an Apple iPod Mini FREE for your judgement on
who ports your project to Linux PPC the best. Sponsored by IBM. 
Deadline: Sept. 13. Go here: http://sf.net/ppc_contest.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
