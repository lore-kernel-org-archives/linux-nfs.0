From: Harald Hannelius <harald+nfs@arcada.fi>
Subject: Re: Poor NFS performance, kernel 2.6.6. (fwd)
Date: Thu, 27 May 2004 14:40:07 +0300 (EEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.58.0405271439470.10125@penti.sit.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTJF6-0003uK-53
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 04:40:12 -0700
Received: from penti.sit.fi ([193.167.33.237])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTJF5-0000Nc-Em
	for nfs@lists.sourceforge.net; Thu, 27 May 2004 04:40:11 -0700
Received: from penti.sit.fi (harald@localhost [127.0.0.1])
	by penti.sit.fi (8.12.10/8.12.10) with ESMTP id i4RBe7gT010132
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 14:40:07 +0300
Received: from localhost (harald@localhost)
	by penti.sit.fi (8.12.10/8.12.9/Submit) with ESMTP id i4RBe7hS010129
	for <nfs@lists.sourceforge.net>; Thu, 27 May 2004 14:40:07 +0300
To: nfs@lists.sourceforge.net
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


---------- Forwarded message ----------
Date: Thu, 27 May 2004 14:38:18 +0300 (EEST)
From: Harald Hannelius <harald@arcada.fi>
To: Vincent ROQUETA <vincent.roqueta@ext.bull.net>
Cc: nfs@lists.sourceforge.net
Subject: Re: [NFS] Poor NFS performance, kernel 2.6.6.


On Thu, 27 May 2004, Vincent ROQUETA wrote:
> Le Jeudi 27 Mai 2004 12:31, Harald Hannelius a =E9crit :

> > I'm running two servers, both Dual Opterons with Broadcom Gb NICs. I'm
> > using the bcm5700 driver and I see no errors whatsoever with 'ifconfig'=
=2E

> on NFSv3, 1 ethernet 1GB I reached  89% of the avalaible brandwith for NF=
Sv3,
> kernel 2.6.3, for file less than the total amount of ram (4Go), and 22% o=
f
> the brandwith for file over 6Go, because of the use of harddisk use in th=
e
> copy process (swap).
>
> What is  your memory configuration?

I have 1GB ram i both computers, hence the 2GB testfile.

> I am trying to setup a protocol performances to test NFS, with this we ca=
n
> compare the tests by using the same  tools.
> Here is a short description of the tools :
> http://nfsv4.bullopensource.org/tools/testing_tools.html
>
> and a survey to determine one tool for perfs :
> http://nfsv4.bullopensource.org/tools/sondage.php

I took iozone and ran an automatic test;

  http://people.arcada.fi/~harald/nfs/performance.xls

Or in ascii;

  http://people.arcada.fi/~harald/nfs/performance.csv





--=20
A: Top Posters
Q: What is the most annoying thing on mailing lists?

Harald H Hannelius | harald/a\arcada.fi      | GSM +358 50 594 1020


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
