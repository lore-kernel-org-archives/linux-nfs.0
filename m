From: =?iso-8859-1?q?beooi=20alex?= <beooia@yahoo.fr>
Subject: quick connection then wait but for what?
Date: Sun, 28 Mar 2004 11:59:47 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040328095947.22068.qmail@web25108.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary="0-918764719-1080467987=:22039"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1B7X58-00023h-7A
	for nfs@lists.sourceforge.net; Sun, 28 Mar 2004 01:59:54 -0800
Received: from web25108.mail.ukl.yahoo.com ([217.12.10.56])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1B7X57-0006Il-M2
	for nfs@lists.sourceforge.net; Sun, 28 Mar 2004 01:59:53 -0800
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

--0-918764719-1080467987=:22039
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit

hello,
 
first of all excuse me for my poor english :)
 
this is our lvs cluster:
 
                             director
                                  |
                              switch
                                  |
            ----------------------------------------------
           |                                              |
web/mailserver                          webmailserver
           |                                              |
            ----------------------------------------------
                                  |
                              switch
                                  |
            ----------------------------------------------
           |                                              |
     fileserver                              databaseserver
 
we have a strange problem:
we don't use nor identd nor hostnamelookup but we have those symptoms...
 
when you request a page, the result is the same with a 1ko page or a 10 mo one,
you see connection, opening, then you wait between 1 and 3 seconds,
then everything appear very fast
 
we didn't have this problem before we "clustered" our installation
and dedicated a server for the files.
we add a smart array 641 controller with 4 discs (raid10) for the fileserver.

we tried quite all combinaisons of rsize, wsize, tcp, udp, version 2; version 3.
 
we don't understand how this cluster can respond slower than before.
(before we just used one server)

can it be the default stripe size of the file server (128 ko for raid10)?
...?
 
thanks a lot in advance for your responses/help. :)
 
alex.

		
---------------------------------
Yahoo! Mail : votre e-mail personnel et gratuit qui vous suit partout !
Créez votre Yahoo! Mail

Dialoguez en direct avec vos amis grâce à Yahoo! Messenger !
--0-918764719-1080467987=:22039
Content-Type: text/html; charset=iso-8859-1
Content-Transfer-Encoding: 8bit

<DIV>hello,<BR> <BR>first of all excuse me for my poor english :)<BR> <BR>this is our lvs cluster:<BR> <BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; director<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; switch<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<BR>&nbsp;&nbsp;&nbsp;&
 nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 ----------------------------------------------<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<BR>web/mailserver&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; webmailserver<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nb
 sp; |<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 ----------------------------------------------<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; switch<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ----------------------------------------------<BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
 |&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |<BR>&nbsp;&nbsp;&nbsp;&nbsp; fileserver&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; databaseserver<BR> <BR>we have a strange problem:<BR>we don't use nor identd nor hostnamelookup but we have those symptoms...<BR> <BR>when you request a page, the result is the same with a 1ko page or a 10 mo one,<BR>you see connection, opening, then you wait between 1 and 3 seconds,<BR>then everything appear very fast<BR> <BR>we didn't have this problem before we "clustered" our installation</DIV>
<DIV>and dedicated a server for the files.<BR>we add a smart array 641 controller with 4 discs (raid10) for the fileserver.<BR></DIV>
<DIV>we tried quite all combinaisons of rsize, wsize, tcp, udp, version 2; version 3.</DIV>
<DIV>&nbsp;<BR>we don't understand how this cluster can respond slower than before.</DIV>
<DIV>(before we just used one server)<BR><BR>can it be the default stripe size of the file server (128 ko for raid10)?<BR>...?<BR> <BR>thanks a lot in advance for your responses/help. :)<BR> <BR>alex.</DIV><p>
		<hr size=1>
Yahoo! Mail : votre e-mail personnel et gratuit qui vous suit partout !
<br><a href="http://fr.rd.yahoo.com/mail/taglines/*http://fr.rd.yahoo.com/mail/mail_taglines/default/*http://fr.benefits.yahoo.com/">Créez votre Yahoo! Mail</a>
<br><br>
Dialoguez en direct avec vos amis grâce à <a href="http://fr.rd.yahoo.com/mail/taglines/*http://fr.rd.yahoo.com/messenger/mail_taglines/default/*http://fr.messenger.yahoo.com/">Yahoo! Messenger !</a>
--0-918764719-1080467987=:22039--


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
