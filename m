From: Thomas Stockheim <tommi@bub-agema.de>
Subject: NFS problem - close to open cache consistency broken ?
Date: Tue, 13 Sep 2005 11:04:41 +0200
Message-ID: <43269629.3030503@bub-agema.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EF6jL-0007y1-4q
	for nfs@lists.sourceforge.net; Tue, 13 Sep 2005 02:05:31 -0700
Received: from dhuumrelay3.dtm.ops.eu.uu.net ([194.139.33.96] helo=dhuumrelay3.mail.eu.uu.net)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EF6jH-0000xX-IO
	for nfs@lists.sourceforge.net; Tue, 13 Sep 2005 02:05:31 -0700
Received: from bub-agema.de (dhuumprxy3.dtm.ops.eu.uu.net [194.139.33.83])
	by dhuumrelay3.mail.eu.uu.net (8.13.4/8.13.4) with ESMTP id j8D95IJm007925
	for <nfs@lists.sourceforge.net>; Tue, 13 Sep 2005 09:05:18 GMT
Received: from [134.130.203.160] (pccl-03-16 [134.130.203.160])
	by bub-agema.de (8.9.3 (PHNE_18979)/8.9.3) with ESMTP id LAA05488
	for <nfs@lists.sourceforge.net.>; Tue, 13 Sep 2005 11:04:36 +0200 (METDST)
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

I'm having a problem with NFS caching after updating from Redhat 8 to 
Fedora. Sometimes changes to files ( even when done on the server) just 
do not show up. At first we suspected timing problems, but all machines
are synchronized with ntp.

Then I found out how to reproduce it:
1 server: echo xxxx > testfile
2 client: Application 1 on client opens testfile, does nothing with it - 
keeps it open forever ( simple fortran program with an open and an
endless loop )
3 client: cat testfile  gives xxxx
4 server: echo yyyy > testfile
5 client: cat testfile  still shows xxxx

Its not a file attribute caching problem I think, ls -l shows the
correct, updated modificiation time for the file. But the file contents
never get updated. Once I kill the application that was holding open the 
testfile, it still shows the wrong content, but any new changes show 
immediately.

At first, we tested this on kernel 2.6.11 and 2.6.9. Here, increasing
file size by 1 worked to get the updated file contents on the client, 
but decreasing file size did not work.

6a server: echo zzzzz > testfile
7a client: cat testfile  shows zzzzz

6b server: echo zzz > testfile
7b server: cat testfile  shows xxxx

With kernel 2.6.13, any file size changes show the new content directly,
but if the file size stays constant it still does not work.

I tried all the mount options, but even turning attribute
caching totally off does not seem to help. Mouting as nfsv2 did not help
either.

I assume its a problem of the client, not the server - mounting the
same exports on old redhat 7 with kernel 2.4.2 everything works.

If I understand Close-to-open cache consistency right, having the file
opened from a different application on the same client should not be a 
problem ?


Thanks, Thomas

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
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
