From: Phy Prabab <phyprabab@yahoo.com>
Subject: NFSd and client connections
Date: Sat, 29 May 2004 13:51:11 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040529205111.15911.qmail@web90005.mail.scd.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUAnV-0004xg-16
	for nfs@lists.sourceforge.net; Sat, 29 May 2004 13:51:17 -0700
Received: from web90005.mail.scd.yahoo.com ([66.218.94.63])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1BUAnU-0005Fc-OG
	for nfs@lists.sourceforge.net; Sat, 29 May 2004 13:51:16 -0700
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

Hello,

I have a question, while doing some simple testing on
the 2.6.7-rc1-bk5 (w/nfsd patch), I noticed that under
v3 udp there is only one nfsd per client connection in
contrast to v2 udp which had multiple nfsd's per
connection; so is this the correct behavior?

Thank you,
Phy


	
		
__________________________________
Do you Yahoo!?
Friends.  Fun.  Try the all-new Yahoo! Messenger.
http://messenger.yahoo.com/ 


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
