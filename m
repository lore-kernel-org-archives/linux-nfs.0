From: Thomas Stockheim <tommi@bub-agema.de>
Subject: Re: NFS problem - close to open cache consistency broken ?
Date: Thu, 15 Sep 2005 09:47:58 +0200
Message-ID: <4329272E.7070807@bub-agema.de>
References: <6063053.1126674084242.JavaMail.root@dtm1eusosrv72.dtm.ops.eu.uu.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFoUM-00069p-M0
	for nfs@lists.sourceforge.net; Thu, 15 Sep 2005 00:48:58 -0700
Received: from dhuumrelay3.dtm.ops.eu.uu.net ([194.139.33.96] helo=dhuumrelay3.mail.eu.uu.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EFoUK-0002sq-Pm
	for nfs@lists.sourceforge.net; Thu, 15 Sep 2005 00:48:58 -0700
Received: from bub-agema.de (dhuumprxy3.dtm.ops.eu.uu.net [194.139.33.83])
	by dhuumrelay3.mail.eu.uu.net (8.13.4/8.13.4) with ESMTP id j8F7mdFa022008
	for <nfs@lists.sourceforge.net>; Thu, 15 Sep 2005 07:48:40 GMT
Received: from [134.130.203.160] (pccl-03-16 [134.130.203.160])
	by bub-agema.de (8.9.3 (PHNE_18979)/8.9.3) with ESMTP id JAA06589
	for <nfs@lists.sourceforge.net>; Thu, 15 Sep 2005 09:47:55 +0200 (METDST)
To: nfs@lists.sourceforge.net
In-Reply-To: <6063053.1126674084242.JavaMail.root@dtm1eusosrv72.dtm.ops.eu.uu.net>
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
>>I'm having a problem with NFS caching after updating from Redhat 8 to 
>>Fedora. Sometimes changes to files ( even when done on the 
>>server) just 
>>do not show up. At first we suspected timing problems, but 
>>all machines
>>are synchronized with ntp.
>>
>>Then I found out how to reproduce it:
>>1 server: echo xxxx > testfile
>>2 client: Application 1 on client opens testfile, does 
>>nothing with it - 
>>keeps it open forever ( simple fortran program with an open and an
>>endless loop )
>>3 client: cat testfile  gives xxxx
>>4 server: echo yyyy > testfile
>>5 client: cat testfile  still shows xxxx
>>
>>Its not a file attribute caching problem I think, ls -l shows the
>>correct, updated modificiation time for the file. But the 
>>file contents
>>never get updated. Once I kill the application that was 
>>holding open the 
>>testfile, it still shows the wrong content, but any new changes show 
>>immediately.
>>
>>At first, we tested this on kernel 2.6.11 and 2.6.9. Here, increasing
>>file size by 1 worked to get the updated file contents on the client, 
>>but decreasing file size did not work.
>>
>>6a server: echo zzzzz > testfile
>>7a client: cat testfile  shows zzzzz
>>
>>6b server: echo zzz > testfile
>>7b server: cat testfile  shows xxxx
>>
>>With kernel 2.6.13, any file size changes show the new 
>>content directly,
>>but if the file size stays constant it still does not work.
>>
>>I tried all the mount options, but even turning attribute
>>caching totally off does not seem to help. Mouting as nfsv2 
>>did not help
>>either.
>>
>>I assume its a problem of the client, not the server - mounting the
>>same exports on old redhat 7 with kernel 2.4.2 everything works.
>>
>>If I understand Close-to-open cache consistency right, having the file
>>opened from a different application on the same client should 
>>not be a problem ?
> 
> 
> thomas-
> 
> the client uses mtime and size to detect file changes on the server.  if
> the mtime doesn't change on the server, the clients won't detect any
> data changes.
> 
> what physical file system are you using on the server?
> 
> 

Thanks for the reply, but thats exactly my problem: Mtime does change
on the server, and the client even sees that change ( faster or slower 
depending on caching settings ).

But the data on the client never gets updated.

I tested some more, and this only happens if another application on the
client has the file open for writing.

I think it might have to do something with the data_unstable flag in
nfs_refresh_inode - but I don't understand the kernel code well enough
to see what happens exactly or how to fix it for us.

Thomas



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
