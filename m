From: DUPRE Julien <julien.dupre-renexter@renault.com>
Subject: how many nfs  thread needed
Date: Fri, 25 Feb 2005 12:06:17 +0100
Message-ID: <01e101c51b2a$07a027c0$bef5dc0a@corp.noxiane.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----------=_1109329785-7095-161"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D4dLw-0005oA-CG
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 03:09:48 -0800
Received: from xenia3-in0.renault.fr ([193.194.133.17] helo=xenia3.mc2.renault.fr)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D4dLu-00072c-IN
	for nfs@lists.sourceforge.net; Fri, 25 Feb 2005 03:09:48 -0800
Received: from univers4.mc2.renault.fr (univers4-in0.mc2.renault.fr [10.210.68.9])
	by xenia3.mc2.renault.fr (8.13.1/8.13.1) with ESMTP id j1PB9jqT023387
	for <nfs@lists.sourceforge.net>; Fri, 25 Feb 2005 12:09:45 +0100 (MET)
Received: from hepatite1.mc2.renault.fr (hepatite1.mc2.renault.fr [10.210.68.19])
	by univers4.mc2.renault.fr (8.13.1/8.13.1) with SMTP id j1PB9g2s023517
	for <nfs@lists.sourceforge.net>; Fri, 25 Feb 2005 12:09:43 +0100 (MET)
Received: from su356aos (su356aos.mc2.renault.fr [138.21.107.59])
	by univers4.mc2.renault.fr (8.13.1/8.13.1) with ESMTP id j1PB9LXj021977
	for <nfs@lists.sourceforge.net>; Fri, 25 Feb 2005 12:09:21 +0100 (MET)
Received: from su333aos (su333aos.mc2.renault.fr [138.21.107.224])
 by wsmtp54.mc2.renault.fr
 (iPlanet Messaging Server 5.2 HotFix 1.25 (built Mar  3 2004))
 with ESMTP id <0ICG00EA2S6OIH@wsmtp54.mc2.renault.fr> for
 nfs@lists.sourceforge.net; Fri, 25 Feb 2005 12:06:24 +0100 (MET)
Received: from FR20025184 (fr20025184.corp.noxiane.net [10.220.245.190])
 by wsmtpin56.mc2.renault.fr
 (iPlanet Messaging Server 5.2 HotFix 1.25 (built Mar  3 2004))
 with SMTP id <0ICG000XSS6OZG@wsmtpin56.mc2.renault.fr> for
 nfs@lists.sourceforge.net; Fri, 25 Feb 2005 12:06:24 +0100 (MET)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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

This is a multi-part message in MIME format...

------------=_1109329785-7095-161
Content-Type: multipart/alternative;
 boundary="Boundary_(ID_0onVqzhpm2oQmn3hStB46A)"
Content-Transfer-Encoding: 7bit

This is a multi-part message in MIME format...

--Boundary_(ID_0onVqzhpm2oQmn3hStB46A)
Content-type: text/plain; charset=iso-8859-1
Content-transfer-encoding: 7BIT
Content-Disposition: inline

Hi,

i'm looking for tunning my NFS configuration on a RedHAt 7.3 ( my client are in ES3)
for increase my performance.

I reading some docs but i need help for chose a good value

balsa-b#  grep th /proc/net/rpc/nfsd  
th 84 203258 22002.912 7932.515 4694.613 6721.031 4074.175 605.630 396.916 376.582 501.927 2942.259
balsa-b# 


I think i need to change my number of thread nfsd but how many ?


Thanks in advance










--Boundary_(ID_0onVqzhpm2oQmn3hStB46A)
Content-type: text/html; charset=iso-8859-1
Content-transfer-encoding: 7BIT
Content-Disposition: inline

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML><HEAD>
<META http-equiv=Content-Type content="text/html; charset=iso-8859-1">
<META content="MSHTML 6.00.2800.1491" name=GENERATOR>
<STYLE></STYLE>
</HEAD>
<BODY bgColor=#ffffff>
<DIV><FONT face="Courier New"></FONT><FONT face="Courier New">Hi,</FONT></DIV>
<DIV><FONT face="Courier New">&nbsp;</DIV>
<DIV>i'm looking for tunning my NFS configuration on a RedHAt 7.3 ( my client 
are in ES3)</DIV>
<DIV>for increase my performance.</DIV>
<DIV>&nbsp;</DIV>
<DIV>I reading some docs but i need help for chose a good value</DIV>
<DIV>&nbsp;</DIV>
<DIV>balsa-b#&nbsp; grep th /proc/net/rpc/nfsd&nbsp; <BR>th 84 203258 22002.912 
7932.515 4694.613 6721.031 4074.175 605.630 396.916 376.582 501.927 
2942.259<BR>balsa-b# </DIV>
<DIV>&nbsp;</DIV>
<DIV><BR>I&nbsp;think i need to change my number of thread nfsd but how many 
?</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>Thanks in advance</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV>&nbsp;</DIV>
<DIV><BR></FONT>&nbsp;</DIV></BODY></HTML>

--Boundary_(ID_0onVqzhpm2oQmn3hStB46A)--

------------=_1109329785-7095-161
Content-Type: text/plain; name="disclaimer.txt"
Content-Disposition: inline; filename="disclaimer.txt"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-Mailer: MIME-tools 5.411 (Entity 5.404)

-- Disclaimer ------------------------------------
Ce message ainsi que les eventuelles pieces jointes constituent une correspondance privee et confidentielle a l'attention exclusive du destinataire designe ci-dessus. Si vous n'etes pas le destinataire du present message ou une personne susceptible de pouvoir le lui delivrer, il vous est signifie que toute divulgation, distribution ou copie de cette transmission est strictement interdite. Si vous avez recu ce message par erreur, nous vous remercions d'en informer l'expediteur par telephone ou de lui retourner le present message, puis d'effacer immediatement ce message de votre systeme.
***
This e-mail and any attachments is a confidential correspondence intended only for use of the individual or entity named above. If you are not the intended recipient or the agent responsible for delivering the message to the intended recipient, you are hereby notified that any disclosure, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please notify the sender by phone or by replying this message, and then delete this message from your system.
------------=_1109329785-7095-161--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
