From: Phy Prabab <phyprabab@yahoo.com>
Subject: Question of writing out cache from nfs writes
Date: Sun, 18 Apr 2004 23:54:10 -0700 (PDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040419065410.86217.qmail@web90007.mail.scd.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BFSfX-0006AR-G5
	for nfs@lists.sourceforge.net; Sun, 18 Apr 2004 23:54:15 -0700
Received: from web90007.mail.scd.yahoo.com ([66.218.94.65])
	by sc8-sf-mx1.sourceforge.net with smtp (Exim 4.30)
	id 1BFSfX-0001Ng-DD
	for nfs@lists.sourceforge.net; Sun, 18 Apr 2004 23:54:15 -0700
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

Sirs,

I am curious how to get the nfs cached information
writen out to disk without using using the sync flag. 
That is, I have noticed that several users will move
large files to the NFS server and much will be cached
on the server side (held without writing to disk), but
then when they attempt to move more files of of fairly
large size, the second copy into the dir takes twice
as long (sometimes longer).  Watching top on the
server shows that when the second copy takes place the
cached is filled and so Linux begins to move data to
disk.

I would like to know if it is possible to have the
Linux VM move more data off to disk out of cache over
time (especially when it is not busy servicing as is
the case with this file server) and be equally
agressive at this as it is at using the cache?

1x File server:
1G RAM
2x 1.0GHz
Linux Kernel 2.6.5

25x Clients:
2G RAM
2x 2.4GHz
Linux 2.4.26

Thank you for your time.
Phy


	
		
__________________________________
Do you Yahoo!?
Yahoo! Photos: High-quality 4x6 digital prints for 25¢
http://photos.yahoo.com/ph/print_splash


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
