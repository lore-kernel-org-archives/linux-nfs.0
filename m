From: "Stuckless, Colin" <cstuckless@petro-canada.ca>
Subject: Linux NFS server for heterogeneous production environment
Date: Wed, 20 Oct 2004 06:44:22 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <B9F4645CD7B0D511BE8300508B68C327025EB483@tnscapp02.pcacorp.net>
Mime-Version: 1.0
Content-Type: multipart/alternative;
	boundary="----_=_NextPart_001_01C4B6A2.85DDA870"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CKFsk-0002MC-K3
	for nfs@lists.sourceforge.net; Wed, 20 Oct 2004 05:47:58 -0700
Received: from pcx1.petro-canada.ca ([209.82.98.50] helo=pcaxs03.petro-canada.ca)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CKFsj-0000RQ-Hd
	for nfs@lists.sourceforge.net; Wed, 20 Oct 2004 05:47:58 -0700
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

------_=_NextPart_001_01C4B6A2.85DDA870
Content-Type: text/plain



I'm looking for case studies or reference sites that have moved their
production NFS server environments to Linux. We run a mix of Sun, Linux and
a few SGI clients and are currently running a Solaris 2.8 NFS server.

In looking at upgrade options and of course the debate between NAS or a
server based solution comes up. In my experience, NAS tends to take the
OS/hardware issues and hand them over to your NAS vendor (for better or for
worse). Given my location, there isn't a lot of presence from any of the
major NAS vendors, so I tend to prefer a server based solution that I can
manage more myself. Also, backup options for NAS (NDMP or backing up from
NFS mounts) are not as desirable as running our Legato agents directly on
the file server.

And that brings me to Linux. Inexpensive, reliable and well supported x86
hardware is in plentiful supply, but I'm balking at the maturity of the NFS
stack in Linux in suggesting a move in that direction, given our mix of
clients as I stated above. Has anyone out there done it? What did you use
(vanilla distribution from RedHat or Suse, or addons like Polyserve's Matrix
server)? 

At the end of the day, what I would like is a dual server solution (for
scalable performance, and redundancy) with SAN attached storage that is able
to handle a mixture of NFS clients (Solaris and Linux predominantly) with
high speed (Gigabit) connections without breaking a sweat and without
needing a high amount of care and feeding (my goal is to keep storage
management as <5% of my workload as I have others things to do). If you have
that, and don't mind sharing, please email or followup to the list. I'll
promise to do a summary if I do get some replies.

I know with the work that is going into NFS on Linux that this is not a
question of "if", but a question of "when", and I'm wondering if the time is
right and if there are some references I can pull together to support our
own evaluation.


Thanks,
Colin Stuckless





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

------_=_NextPart_001_01C4B6A2.85DDA870
Content-Type: text/html
Content-Transfer-Encoding: quoted-printable

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 3.2//EN">
<HTML>
<HEAD>
<META HTTP-EQUIV=3D"Content-Type" CONTENT=3D"text/html; =
charset=3DUS-ASCII">
<META NAME=3D"Generator" CONTENT=3D"MS Exchange Server version =
5.5.2658.2">
<TITLE>Linux NFS server for heterogeneous production =
environment</TITLE>
</HEAD>
<BODY>
<BR>
<BR>

<P><FONT SIZE=3D2>I'm looking for case studies or reference sites that =
have moved their production NFS server environments to Linux. We run a =
mix of Sun, Linux and a few SGI clients and are currently running a =
Solaris 2.8 NFS server.</FONT></P>

<P><FONT SIZE=3D2>In looking at upgrade options and of course the =
debate between NAS or a server based solution comes up. In my =
experience, NAS tends to take the OS/hardware issues and hand them over =
to your NAS vendor (for better or for worse). Given my location, there =
isn't a lot of presence from any of the major NAS vendors, so I tend to =
prefer a server based solution that I can manage more myself. Also, =
backup options for NAS (NDMP or backing up from NFS mounts) are not as =
desirable as running our Legato agents directly on the file =
server.</FONT></P>

<P><FONT SIZE=3D2>And that brings me to Linux. Inexpensive, reliable =
and well supported x86 hardware is in plentiful supply, but I'm balking =
at the maturity of the NFS stack in Linux in suggesting a move in that =
direction, given our mix of clients as I stated above. Has anyone out =
there done it? What did you use (vanilla distribution from RedHat or =
Suse, or addons like Polyserve's Matrix server)? </FONT></P>

<P><FONT SIZE=3D2>At the end of the day, what I would like is a dual =
server solution (for scalable performance, and redundancy) with SAN =
attached storage that is able to handle a mixture of NFS clients =
(Solaris and Linux predominantly) with high speed (Gigabit) connections =
without breaking a sweat and without needing a high amount of care and =
feeding (my goal is to keep storage management as &lt;5% of my workload =
as I have others things to do). If you have that, and don't mind =
sharing, please email or followup to the list. I'll promise to do a =
summary if I do get some replies.</FONT></P>

<P><FONT SIZE=3D2>I know with the work that is going into NFS on Linux =
that this is not a question of &quot;if&quot;, but a question of =
&quot;when&quot;, and I'm wondering if the time is right and if there =
are some references I can pull together to support our own =
evaluation.</FONT></P>
<BR>

<P><FONT SIZE=3D2>Thanks,</FONT>
<BR><FONT SIZE=3D2>Colin Stuckless</FONT>
</P>
<BR>
<BR>
<BR>
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
------_=_NextPart_001_01C4B6A2.85DDA870--


-------------------------------------------------------
This SF.net email is sponsored by: IT Product Guide on ITManagersJournal
Use IT products in your business? Tell us what you think of them. Give us
Your Opinions, Get Free ThinkGeek Gift Certificates! Click to find out more
http://productguide.itmanagersjournal.com/guidepromo.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
