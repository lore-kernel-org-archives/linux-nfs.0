From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: about reclaim notifications ,  stale handle , umount
Date: Thu, 23 Dec 2004 00:15:42 -0800 (PST)
Message-ID: <20041223081542.29193.qmail@web51602.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ChO8T-0001yE-4T
	for nfs@lists.sourceforge.net; Thu, 23 Dec 2004 00:15:49 -0800
Received: from web51602.mail.yahoo.com ([206.190.38.207])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.41)
	id 1ChO8S-0002Zn-0e
	for nfs@lists.sourceforge.net; Thu, 23 Dec 2004 00:15:48 -0800
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
      I have three questions.It would be helpful
      if anybody could answer them.

      1.Client reclaims locks after receiving
        notification from server.But does client
        check Monitor ID or Base ip of sender
        to decide whether or not to reclaim lock.??
        As monitor ID may not be same as base ip of
        sender.

      2.If I restart nfs server on same machine
        but nfs modules were not unloaded before
        restart , then can it lead to stale nfs
        handle problem.??

      3.Filesystems which are mounted in order
        to export them to nfs client  , refuse
        to umount though there are no visible
        refereces to it.This problem occurs
        only when client does some transaction
        after mounting filesystems exported by 
        nfs server.This occurs around 30% of s
        the times.fuser -m does not show show any
        user of filesystem but still it does not
        umount
        
        

thanks in advance.

     
     



		
__________________________________ 
Do you Yahoo!? 
Take Yahoo! Mail with you! Get it on your mobile phone. 
http://mobile.yahoo.com/maildemo 


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
