From: Jonathan Woithe <jwoithe@physics.adelaide.edu.au>
Subject: Can NFS be started after NIS/DNS?
Date: Thu, 22 Aug 2002 08:54:42 +0930 (CST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200208212324.g7LNOgU15880@sprite.physics.adelaide.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
        jwoithe@physics.adelaide.edu.au (Jonathan Woithe)
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adelphi.physics.adelaide.edu.au ([129.127.102.1])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17heqN-0002W8-00
	for <nfs@lists.sourceforge.net>; Wed, 21 Aug 2002 16:24:55 -0700
To: trond.myklebust@fys.uio.no
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

Hi

Does anyone know of any reason why the NFS services on a server can't be
started after NIS and/or DNS servers?  At least Redhat 7.x and Slackware
(8.x) start NFS before these services; however, if local name resolution
depends on either NIS or DNS then NFS needs to be started after these if 
previously exising clients are to have their access permissions restored
correctly.

I can see no reason why switching the order can't be done.

I have been starting NFS after NIS/DNS on a server for several weeks now and
it hasn't given any troubles across numerous test reboots.  On the other
hand, I did read in an archived message from some years ago that NIS had the
potential to mess NFS up if NIS startup preceeded NFS.

Please CC me any replies since I don't subscribe to the list.

Best regards
  jonathan
-- 
* Jonathan Woithe    jwoithe@physics.adelaide.edu.au                        *
*                    http://www.physics.adelaide.edu.au/~jwoithe            *
***-----------------------------------------------------------------------***
** "Time is an illusion; lunchtime doubly so"                              **
*  "...you wouldn't recognize a subtle plan if it painted itself purple and *
*   danced naked on a harpsichord singing 'subtle plans are here again'"    *


-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
