From: AK <amithl_prem@yahoo.com>
Subject: Performance: NFS v3  mounting with 'noac' option
Date: Wed, 7 Mar 2007 06:54:09 -0800 (PST)
Message-ID: <253.39893.qm@web56602.mail.re3.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HOxWy-0004PN-97
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 06:54:17 -0800
Received: from web56602.mail.re3.yahoo.com ([66.196.97.46])
	by mail.sourceforge.net with smtp (Exim 4.44) id 1HOxWx-0003vZ-UV
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 06:54:18 -0800
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

Hi All,

Trying to understand what performance impact could
result if we mount the file system with 'noac' option.

We have multiple file systems begin mounted from the
same NFS server. One of our user's application
requires to mount the file system with 'noac' option. 

We have user directories under /scratch file system,
Now we would like to mount this file system with
'noac' option so that we can make one of our user
happy. But this would afftect every user. Isn't it
true?

So Now if we just decide to create a new FS
/newScratchUserA and mount it with 'noac' option;
WILL THIS AFFECT the other files systems mounted from
the same server, if so how bad could it be. 

Are there any other alternatives to reduce the impact
of using this option on other mounted File systems.

really appreciate any advise .... 

~ thanks!


 
____________________________________________________________________________________
Never miss an email again!
Yahoo! Toolbar alerts you the instant new Mail arrives.
http://tools.search.yahoo.com/toolbar/features/mail/

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
