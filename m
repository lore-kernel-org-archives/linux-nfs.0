From: Thomas Stockheim <tommi@bub-agema.de>
Subject: Re: NFS problem - close to open cache consistency broken ?
Date: Thu, 15 Sep 2005 17:14:12 +0200
Message-ID: <43298FC4.3080008@bub-agema.de>
References: <12528729.1126796454117.JavaMail.root@dtm1eusosrv72.dtm.ops.eu.uu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFvSG-00071B-A6
	for nfs@lists.sourceforge.net; Thu, 15 Sep 2005 08:15:16 -0700
Received: from dhuumrelay3.dtm.ops.eu.uu.net ([194.139.33.96] helo=dhuumrelay3.mail.eu.uu.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EFvSB-00062a-E1
	for nfs@lists.sourceforge.net; Thu, 15 Sep 2005 08:15:16 -0700
Received: from bub-agema.de (dhuumprxy3.dtm.ops.eu.uu.net [194.139.33.83])
	by dhuumrelay3.mail.eu.uu.net (8.13.4/8.13.4) with ESMTP id j8FFEsE7026725
	for <nfs@lists.sourceforge.net>; Thu, 15 Sep 2005 15:15:03 GMT
Received: from [134.130.203.160] (pccl-03-16 [134.130.203.160])
	by bub-agema.de (8.9.3 (PHNE_18979)/8.9.3) with ESMTP id RAA06895
	for <nfs@lists.sourceforge.net>; Thu, 15 Sep 2005 17:14:10 +0200 (METDST)
To: nfs@lists.sourceforge.net
In-Reply-To: <12528729.1126796454117.JavaMail.root@dtm1eusosrv72.dtm.ops.eu.uu.net>
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

Lever, Charles wrote:
>>>peter, do you happen to know how the solaris NFS client 
>>
>>behaves when an
>>
>>>application holds a file open like this?
>>>
>>>close-to-open is a convention, not a specification, so it's 
>>
>>really up to
>>
>>>the client developers to implement what they think is right.  i'm
>>>guessing that the Linux client is working as designed here.  i'm not
>>>convinced it's very *convenient* behavior, though.
>>>
>>>
>>>
>>
>>Well, linux did not allways do this - same directory mounted 
>>on an older 
>>redhat with kernel 2.4.2 and its working fine.
> 
> 
> those ancient kernels don't support close-to-open.  that was introduced
> around 2.4.20.
> 
> 
I don't know what model they had instead, but it worked better
for us. I've been running linux clusters for 5 years or so and
never had this problem before.



-- 

************************************************************************
**
**  B&B-AGEMA GmbH
**
**  Thomas Stockheim
**  Juelicher Strasse 338
**  D-52070 Aachen
**  Germany
**
**  Tel. (Zentrale):  ++49-(0)241-56878-0
**  Tel. (Durchwahl): ++49-(0)241-56878-31
**  Fax.:             ++49-(0)241-56878-79
**  e-mail:           <tommi@bub-agema.de>
**  Internet:         http://www.bub-agema.de
**
************************************************************************


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
