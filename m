From: Phy Prabab <phyprabab@yahoo.com>
Subject: nfs performance of 2421 vs 2.6.7-rc2
Date: Mon, 31 May 2004 18:35:06 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040601013506.39615.qmail@web90009.mail.scd.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUyBN-0001sQ-A4
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 18:35:13 -0700
Received: from web90009.mail.scd.yahoo.com ([66.218.94.67])
	by sc8-sf-mx2.sourceforge.net with smtp (Exim 4.30)
	id 1BUyBL-00014w-IB
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 18:35:11 -0700
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

I have been doing some testing of NFS performance with
2.4.21 and 2.6.7-rc2 (2.6.5 and 2.6.6 as well).  I
have noticed that 2.4.21 seems to be faster with the
same hardware and mount options as noted by iozone
(iozone -s 1g -r 1m -o).  As well, the amount of CPU
power on the server side is higher for the test run
under 2.6.7-rc2.  Is this known, or have I done
something incorrect?

2.4.21:

1048576    1024   46646   60697   814945   845351 
844893   24716  845657  106998  845220    44423   
60731  811409   841193

2.6.7-rc2:
1048576    1024   42944   48703   536023   546492 
543524   23445  537662   83739  544263   188456  
259651  538667   537420

I have run the same test against NetApp filers and two
different linux file server (2.4.22 and 2.6.7-rc2). 
The client is a 2x 3.0GHz w/8G RAM, Ge (tg3).

Thank you for your time.
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
