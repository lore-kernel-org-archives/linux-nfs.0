From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: hung locks
Date: Fri, 14 May 2004 14:31:59 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0405141427510.12288-100000@fattire.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BOjLi-0004La-3a
	for nfs@lists.sourceforge.net; Fri, 14 May 2004 13:32:06 -0700
Received: from fattire.ngdc.noaa.gov ([140.172.187.207])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BOjLh-0000No-FC
	for nfs@lists.sourceforge.net; Fri, 14 May 2004 13:32:05 -0700
Received: from localhost (ahoward@localhost)
	by fattire.ngdc.noaa.gov (8.11.6/8.11.6) with ESMTP id i4EKVxZ12749
	for <nfs@lists.sourceforge.net>; Fri, 14 May 2004 14:31:59 -0600
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



we just had a reboot of our nfs server and i have a process wich is new hung
trying to obtain a lock.  the other machines which were competing for the lock
had all been rebooting so i know all those processes are dead - plus i
checked.  so the current situation seems that it's caused by a host going down
which held the lock, but lockd somehow not knowing about it.  i straced the
hung process and it is, indeed, hung in fcntl64... so, my question is this:

where does one start looking for the source of this problem?  client logs?
server logs?  is the there some sort of procedure our sysads should follow
when rebooting nfs client/servers with respect to currently held locks?

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| ADDRESS :: E/GC2 325 Broadway, Boulder, CO 80305-3328
| URL     :: http://www.ngdc.noaa.gov/stp/
| TRY     :: for l in ruby perl;do $l -e "print \"\x3a\x2d\x29\x0a\"";done 
===============================================================================



-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
