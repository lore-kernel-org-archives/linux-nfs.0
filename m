From: Steve Dickson <SteveD@redhat.com>
Subject: Re: mail server crashing with RPC error 12 ENOMEM
Date: Fri, 06 Oct 2006 19:47:15 -0400
Message-ID: <4526EB03.5070201@RedHat.com>
References: <4526E1F1.502@nmt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GVzPY-0001ac-Cw
	for nfs@lists.sourceforge.net; Fri, 06 Oct 2006 16:47:26 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GVzPX-0007GA-3U
	for nfs@lists.sourceforge.net; Fri, 06 Oct 2006 16:47:25 -0700
To: mikem@nmt.edu
In-Reply-To: <4526E1F1.502@nmt.edu>
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

Michael Martinez wrote:
> Hey all -
> 
> We've got a mail server running RHEL AS 3 update 2, postfix, amavisd, 
> imap, spamassassin, squirrelmail.
> 
> Mail is delivered to local spool. Users home directories are 
> auto-mounted from nfs and each user has got their .procmailrc. The local 
> copy of procmail on the mail server processes these rcs. We've got a 
> couple thousand users.
> 
> This was working great for two months until a week and a half ago. Since 
> then, every day the server freezes up. We go the console and see 'RPC: 
> sendmsg returned error 12' messages scrolling by. The computer is 
> unresponsive and the only thing we can do is a hard reboot.
I seem to remember this as being an issue with the VM...
Make sure your are running RHEL3 U8 since I believe the
fixed is in there...

steved.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
