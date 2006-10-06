From: Michael Martinez <mikem@nmt.edu>
Subject: mail server crashing with RPC error 12 ENOMEM
Date: Fri, 06 Oct 2006 17:08:33 -0600
Message-ID: <4526E1F1.502@nmt.edu>
Reply-To: mikem@nmt.edu
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVyoI-0006rO-R9
	for nfs@lists.sourceforge.net; Fri, 06 Oct 2006 16:08:55 -0700
Received: from mailhost.nmt.edu ([129.138.4.52])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GVyoI-0007NJ-H0
	for nfs@lists.sourceforge.net; Fri, 06 Oct 2006 16:08:55 -0700
Received: from localhost (localhost.localdomain [127.0.0.1])
	by localhost.localdomain (Postfix) with ESMTP id 5C350435F4D
	for <nfs@lists.sourceforge.net>; Fri,  6 Oct 2006 17:08:48 -0600 (MDT)
Received: from mailhost.nmt.edu ([127.0.0.1])
	by localhost (mailhost.nmt.edu [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id 19694-03 for <nfs@lists.sourceforge.net>;
	Fri,  6 Oct 2006 17:08:45 -0600 (MDT)
Received: from [129.138.4.218] (rainbow.nmt.edu [129.138.4.218])
	by mailhost.nmt.edu (Postfix) with ESMTP id 09495435F90
	for <nfs@lists.sourceforge.net>; Fri,  6 Oct 2006 17:08:45 -0600 (MDT)
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hey all -

We've got a mail server running RHEL AS 3 update 2, postfix, amavisd, 
imap, spamassassin, squirrelmail.

Mail is delivered to local spool. Users home directories are 
auto-mounted from nfs and each user has got their .procmailrc. The local 
copy of procmail on the mail server processes these rcs. We've got a 
couple thousand users.

This was working great for two months until a week and a half ago. Since 
then, every day the server freezes up. We go the console and see 'RPC: 
sendmsg returned error 12' messages scrolling by. The computer is 
unresponsive and the only thing we can do is a hard reboot.

We're stumped as to what's causing this. It appears error 12 is an 
ENOMEM (out of memory). So it seems something is trying to allocate 
memory and not getting it. But we don't know why or what. There's no log 
messages telling us anything useful.

Anyone got any ideas??

-- 
Regards,

Michael Martinez
Engineering Manager
Tech Computer Center (TCC), Speare Room 128
New Mexico Tech, 801 Leroy Place, Socorro, NM 87801
(505) 835-5388 mikem@nmt.edu
http://www.nmt.edu/tcc/
--
http://sftplogging.sourceforge.net
http://atftplocalnet.sourceforge.net/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
