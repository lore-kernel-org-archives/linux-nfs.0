From: Neal Lippman <nl@lippman.org>
Subject: nfs permissions / access problem
Date: Tue, 13 Aug 2002 10:38:08 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020813143423.QHGF221.sccrmhc02.attbi.com@there>
References: <F118hBAgKR7ANimhYOj0000f31f@hotmail.com>
Reply-To: nl@lippman.org
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sccrmhc02.attbi.com ([204.127.202.62])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17eckf-0007Td-00
	for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 07:34:30 -0700
Received: from there ([12.243.55.158]) by sccrmhc02.attbi.com
          (InterMail vM.4.01.03.27 201-229-121-127-20010626) with SMTP
          id <20020813143423.QHGF221.sccrmhc02.attbi.com@there>
          for <nfs@lists.sourceforge.net>; Tue, 13 Aug 2002 14:34:23 +0000
To: nfs@lists.sourceforge.net
In-Reply-To: <F118hBAgKR7ANimhYOj0000f31f@hotmail.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

I am hoping someone can provide some advice. The situation is that I want to 
have available on my nfs server a share that is accessible to a group of 
people connecting from their workstations, but am having trouble doing so.

Following what I would have done for a local directory, I created the 
directory: /shared and set its ownship to root, with group=sharedgroup, and 
then gave group permissions of rwx. I made sure each user who needs to use 
the shared directory is in the sharedgroup on the server, and for good 
measure also did so on each workstation (and yes, the gid's are the same on 
each machine). Unfortunately, the directory remains inaccessible via nfs with 
this scheme.

I suspect the problem here is that nfs receives from the client the uid and 
gid that the client process is currently executing under, but does not 
received the extended group list, and also does not look up that user's 
extended group list on the server but rather just does permission checking 
with the single active uid and gid it received from the client, and so cannot 
access via extended group information.

That doesn't strike me as the best way for nfs to operate, although I am am 
sure there was sound design decision involved (maybe overhead of looking up 
the groups on each access, which the os does not have locally as that info is 
already in the process's state information, placed there at login).

In any case, it means that I cannot easily export a shared directory in this 
fashion.

So my question is: How do I make an exported folder accessible to a group of 
users?

Thanks.
nl


-------------------------------------------------------
This sf.net email is sponsored by: Dice - The leading online job board
for high-tech professionals. Search and apply for tech jobs today!
http://seeker.dice.com/seeker.epl?rel_code=31
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
