From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: combined ac/noac mounts
Date: Thu, 2 Sep 2004 18:25:01 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0409021822160.1684@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C31tz-0005E3-Fr
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 17:26:03 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C31tz-0004eI-2j
	for nfs@lists.sourceforge.net; Thu, 02 Sep 2004 17:26:03 -0700
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id i830P153002754
	for <nfs@lists.sourceforge.net>; Thu, 2 Sep 2004 18:25:01 -0600
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id i830P1BT002750
	for <nfs@lists.sourceforge.net>; Thu, 2 Sep 2004 18:25:01 -0600
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


if one exports a file system and also does a sub-export of that file system
from a server and a client has two mounts to that system: one noac and one
'ac' - will accesses to files via the various paths do the 'right thing'.  eg.
accesses via the noac path will hit the server while accesses via the 'ac'
mount will try to use the cache?

we are planning on trying this and tracing packets to find out - but i thought
i'd ask about expected behaviour.

kind regards.

-a
--
===============================================================================
| EMAIL   :: Ara [dot] T [dot] Howard [at] noaa [dot] gov
| PHONE   :: 303.497.6469
| A flower falls, even though we love it;
| and a weed grows, even though we do not love it. 
|   --Dogen
===============================================================================


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=5047&alloc_id=10808&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
