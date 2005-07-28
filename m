From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: nfsd filesystem
Date: Thu, 28 Jul 2005 03:30:13 -0700 (PDT)
Message-ID: <20050728103013.96091.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dy5ef-0003wE-2a
	for nfs@lists.sourceforge.net; Thu, 28 Jul 2005 03:30:21 -0700
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by mail.sourceforge.net with smtp (Exim 4.44)
	id 1Dy5ed-0001eo-B5
	for nfs@lists.sourceforge.net; Thu, 28 Jul 2005 03:30:21 -0700
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

Hi ,
Man page for nfsd FS says that absence of nfsd FS will
make nfs function as it worked on 2.4 kernel
Does this mean that with 2.4 kernel transparent nfs
server failover(along with exports)  cannot be
achieved.Or does it mean that there was mechanisn
different than "nfs upcall to mountd" to generate
handle for client

thanks,
 kiran



__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO Septem=
ber
19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & Q=
A
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
