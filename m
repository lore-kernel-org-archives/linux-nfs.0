From: "Peter Plantagenet" <plantagenet@music.com>
Subject: NFS v3 in nfs-server 2.2beta47?
Date: Tue, 25 Jun 2002 18:33:42 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200206260133.g5Q1XgR13196@mail19.bigmailbox.com>
Mime-Version: 1.0
Content-Type: text/plain
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail19.bigmailbox.com ([209.132.220.50])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17N2cF-0001IM-00
	for <nfs@lists.sourceforge.net>; Tue, 25 Jun 2002 19:33:07 -0700
To: nfs@lists.sourceforge.net
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


Hi -

I have two Linux boxes, one running the kernel-space NFS and the other the userspace version, nfs-server 2.2beta 47. This is the version SuSE has been bundling with its distributions for the last several years.

rcpinfo tells me that the kernel-space version is providing NFS v3, while the user-space version is only providing NFS v2.

I need v3 for various reasons, the main being the ability to transfer files larger than 2GB.

My question is very simple: does nfs-server 2.2beta 47 only provide NFS v2? If so, is there an update to the user-space version that provides v3?

I would like to avoid building a new kernel on this machine if possible, and find it hard to believe that the user-space nfs really only provides v2. 

I would really appreciate a knowledgeable answer to this simple question -- I'm stymied, and looked around quite a bit before I found you guys.

Cheers,
Peter

  

------------------------------------------------------------
Get YourName.Music.com- http://www.music.com/myband_main.html
Reserve your .Music.com address and reach thousands of fans!


---------------------------------------------------------------------
Express yourself with a super cool email address from BigMailBox.com.
Hundreds of choices. It's free!
http://www.bigmailbox.com
---------------------------------------------------------------------


-------------------------------------------------------
This sf.net email is sponsored by: Jabber Inc.
Don't miss the IM event of the season | Special offer for OSDN members! 
JabConf 2002, Aug. 20-22, Keystone, CO http://www.jabberconf.com/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
