From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: lockd/rpc bug
Date: Thu, 13 Jan 2005 18:35:31 -0700 (MST)
Message-ID: <Pine.LNX.4.60.0501131829200.6332@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CpGNC-0001rN-Sb
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 17:35:34 -0800
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1CpGNA-0006mZ-H9
	for nfs@lists.sourceforge.net; Thu, 13 Jan 2005 17:35:34 -0800
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id j0E1ZVkW011462
	for <nfs@lists.sourceforge.net>; Thu, 13 Jan 2005 18:35:31 -0700
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id j0E1ZV0X011458
	for <nfs@lists.sourceforge.net>; Thu, 13 Jan 2005 18:35:31 -0700
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


we rebooted a client that's part of a single server single client pair (plan
is obviously to expand).  the client held about 8 locks on reboot.  it
apparently is not notifying the server correctly because the server now thinks
all 8 locks are still vaild.  on the server /proc/locks shows

   1: POSIX  ADVISORY  WRITE 27936 08:11:11075589 0 EOF f586b580 c03a87c8 c6e1d824 00000000 f586b58c
   2: POSIX  ADVISORY  WRITE 27936 08:11:11075586 0 EOF c6e1d820 f586b584 c6e1de24 00000000 c6e1d82c
   3: POSIX  ADVISORY  WRITE 6031 08:11:104480774 0 EOF c6e1de20 c6e1d824 f7d26104 00000000 c6e1de2c
   4: POSIX  ADVISORY  WRITE 4852 08:11:11321352 0 EOF f7d26100 c6e1de24 f71affa4 00000000 f7d2610c
   5: POSIX  ADVISORY  WRITE 31579 08:11:11321348 0 EOF f71affa0 f7d26104 f73a71c4 00000000 f71affac
   6: POSIX  ADVISORY  WRITE 31577 08:11:11075593 0 EOF f73a71c0 f71affa4 f73a7644 00000000 f73a71cc
   7: POSIX  ADVISORY  WRITE 29989 08:07:327687 0 EOF f73a7640 f73a71c4 f73b7f44 00000000 f73a764c
   8: FLOCK  ADVISORY  WRITE 11997 08:07:327694 0 EOF f73b7f40 f73a7644 c03a87c8 00000000 f73b7f4c

the proccesses in question do not exist on either client or server (verified
with kill -0).  we are running

   Linux 2.4.21-27.0.1.ELsmp i686

   Red Hat Enterprise Linux WS release 3 (Taroon Update 4)

   nfs-utils-1.0.6-33EL

where do i go from here?  our system is crippled without working locks and it
appears a reboot will cause this uniformly...

thanks for any info.

-a
-- 
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| When you do something, you should burn yourself completely, like a good
| bonfire, leaving no trace of yourself.  --Shunryu Suzuki
===============================================================================


-------------------------------------------------------
The SF.Net email is sponsored by: Beat the post-holiday blues
Get a FREE limited edition SourceForge.net t-shirt from ThinkGeek.
It's fun and FREE -- well, almost....http://www.thinkgeek.com/sfshirt
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
