From: DUPRE Julien <julien.dupre-renexter@renault.com>
Subject: Re: how many nfs  thread needed
Date: Wed, 02 Mar 2005 11:25:10 +0100
Message-ID: <0a4601c51f12$1cc5bac0$bef5dc0a@corp.noxiane.net>
References: <01e101c51b2a$07a027c0$bef5dc0a@corp.noxiane.net>
 <421F6BA3.7050304@int-evry.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="----------=_1109759124-22799-319"
Cc: nfs@lists.sourceforge.net
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D6R2t-0002kQ-SH
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 02:25:35 -0800
Received: from xenia3-in0.renault.fr ([193.194.133.17] helo=xenia3.mc2.renault.fr)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D6R2s-0002dW-4s
	for nfs@lists.sourceforge.net; Wed, 02 Mar 2005 02:25:35 -0800
Received: from univers4.mc2.renault.fr (univers4-in0.mc2.renault.fr [10.210.68.9])
	by xenia3.mc2.renault.fr (8.13.1/8.13.1) with ESMTP id j22APO06011338
	for <nfs@lists.sourceforge.net>; Wed, 2 Mar 2005 11:25:24 +0100 (MET)
Received: from hepatite2.mc2.renault.fr (hepatite2.mc2.renault.fr [10.210.68.22])
	by univers4.mc2.renault.fr (8.13.1/8.13.1) with SMTP id j22APO9D002095
	for <nfs@lists.sourceforge.net>; Wed, 2 Mar 2005 11:25:24 +0100 (MET)
Received: from su356aos (su356aos.mc2.renault.fr [138.21.107.59])
	by univers4.mc2.renault.fr (8.13.1/8.13.1) with ESMTP id j22APANj001420
	for <nfs@lists.sourceforge.net>; Wed, 2 Mar 2005 11:25:10 +0100 (MET)
Received: from su318aos (su318aos.mc2.renault.fr [138.21.107.184])
 by wsmtp54.mc2.renault.fr
 (iPlanet Messaging Server 5.2 HotFix 1.25 (built Mar  3 2004))
 with ESMTP id <0ICP00KZAZLYOO@wsmtp54.mc2.renault.fr> for
 nfs@lists.sourceforge.net; Wed, 02 Mar 2005 11:25:10 +0100 (MET)
Received: from FR20025184 (fr20025184.corp.noxiane.net [10.220.245.190])
 by wsmtpin55.mc2.renault.fr
 (iPlanet Messaging Server 5.2 HotFix 1.25 (built Mar  3 2004))
 with SMTP id <0ICP00LRIZLYEQ@wsmtpin55.mc2.renault.fr> for
 nfs@lists.sourceforge.net; Wed, 02 Mar 2005 11:25:10 +0100 (MET)
To: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
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

------------=_1109759124-22799-319
Content-type: text/plain; charset=iso-8859-1
Content-transfer-encoding: 7BIT
Content-Disposition: inline

Hi,

i've  increase my number of thread nfsd 84->210->312
balsa-b# cat /proc/net/rpc/nfsd |grep th
th 312 0 10.763 1.697 1.433 0.281 0.224 0.589 0.853 2.841 0.169 0.000
balsa-b#

It's looking good for the master but i've always some problem for the
clients

***** balsa47:  Commande grep nfs /var/log/messages *****
balsa47:        Mar  2 10:44:26 balsa47 kernel: nfs: server balsa not
responding, still trying
balsa47:        Mar  2 10:44:26 balsa47 kernel: nfs: server balsa OK
balsa47:        Mar  2 10:44:27 balsa47 kernel: nfs: server balsa not
responding, still trying
balsa47:        Mar  2 10:44:28 balsa47 kernel: nfs: server balsa OK

I don't understand why.
My 31 last threads are never used. Why nfs not responding.

For info my  cluster is:
52 bi-xeon 2Go memory running under ES3 with nfs v2
2 master bi-PIV 2Go memory running under Redhat 7.3 with nfs v3 ( i m
waiting for 2 new master in ES3)

I use them under maya and mentalray. The node works put all the file in NFS


What happened ???

----- Original Message ----- 
From: "jehan.procaccia" <jehan.procaccia@int-evry.fr>
To: "DUPRE Julien" <julien.dupre-renexter@renault.com>
Cc: <nfs@lists.sourceforge.net>
Sent: Friday, February 25, 2005 7:17 PM
Subject: Re: [NFS] how many nfs thread needed


> DUPRE Julien wrote:
>
> > Hi,
> >
> > i'm looking for tunning my NFS configuration on a RedHAt 7.3 ( my
> > client are in ES3)
> > for increase my performance.
> >
> > I reading some docs but i need help for chose a good value
> >
> > balsa-b#  grep th /proc/net/rpc/nfsd
> > th 84 203258 22002.912 7932.515 4694.613 6721.031 4074.175 605.630
> > 396.916 376.582 501.927 2942.259
> > balsa-b#
> >
>
> you've already got 84 Threads and they all seem quite busy ! I'am not
> sure, but for me unless the last numbers above are near to zero second
> of use , you should increase the number of threads -> up to 128 in your
> case ? but will the server support it ? you seem to have many clients ?
> have a look at:
> http://marc.theaimsgroup.com/?l=linux-nfs&m=102824853219024&w=2
> http://www.int-evry.fr/s2ia/user/procacci/Doc/NFS/nfs.html#htoc8
>
> >
> > I think i need to change my number of thread nfsd but how many ?
> >
> >
> > Thanks in advance
> >
> >
> >
> >
> >
> >
> >
> >
> >
> >
> >
> >------------------------------------------------------------------------
> >
> >-- Disclaimer ------------------------------------
> >Ce message ainsi que les eventuelles pieces jointes constituent une
correspondance privee et confidentielle a l'attention exclusive du
destinataire designe ci-dessus. Si vous n'etes pas le destinataire du
present message ou une personne susceptible de pouvoir le lui delivrer, il
vous est signifie que toute divulgation, distribution ou copie de cette
transmission est strictement interdite. Si vous avez recu ce message par
erreur, nous vous remercions d'en informer l'expediteur par telephone ou de
lui retourner le present message, puis d'effacer immediatement ce message de
votre systeme.
> >***
> >This e-mail and any attachments is a confidential correspondence intended
only for use of the individual or entity named above. If you are not the
intended recipient or the agent responsible for delivering the message to
the intended recipient, you are hereby notified that any disclosure,
distribution or copying of this communication is strictly prohibited. If you
have received this communication in error, please notify the sender by phone
or by replying this message, and then delete this message from your system.
> >
>
>
>
> -------------------------------------------------------
> SF email is sponsored by - The IT Product Guide
> Read honest & candid reviews on hundreds of IT Products from real users.
> Discover which products truly live up to the hype. Start reading now.
> http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>


------------=_1109759124-22799-319
Content-Type: text/plain; name="disclaimer.txt"
Content-Disposition: inline; filename="disclaimer.txt"
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
X-Mailer: MIME-tools 5.411 (Entity 5.404)

-- Disclaimer ------------------------------------
Ce message ainsi que les eventuelles pieces jointes constituent une correspondance privee et confidentielle a l'attention exclusive du destinataire designe ci-dessus. Si vous n'etes pas le destinataire du present message ou une personne susceptible de pouvoir le lui delivrer, il vous est signifie que toute divulgation, distribution ou copie de cette transmission est strictement interdite. Si vous avez recu ce message par erreur, nous vous remercions d'en informer l'expediteur par telephone ou de lui retourner le present message, puis d'effacer immediatement ce message de votre systeme.
***
This e-mail and any attachments is a confidential correspondence intended only for use of the individual or entity named above. If you are not the intended recipient or the agent responsible for delivering the message to the intended recipient, you are hereby notified that any disclosure, distribution or copying of this communication is strictly prohibited. If you have received this communication in error, please notify the sender by phone or by replying this message, and then delete this message from your system.
------------=_1109759124-22799-319--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
