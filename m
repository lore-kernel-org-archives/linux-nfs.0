From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: unexplained ESTALE
Date: Mon, 30 Aug 2004 16:37:43 -0600 (MDT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.60.0408301629590.561@harp.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1C1umY-0000l4-FS
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 15:37:46 -0700
Received: from harp.ngdc.noaa.gov ([140.172.187.26])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1C1umX-0001r6-2a
	for nfs@lists.sourceforge.net; Mon, 30 Aug 2004 15:37:46 -0700
Received: from harp.ngdc.noaa.gov (harp.ngdc.noaa.gov [127.0.0.1])
	by harp.ngdc.noaa.gov (8.12.11/8.12.11) with ESMTP id i7UMbhxj011845
	for <nfs@lists.sourceforge.net>; Mon, 30 Aug 2004 16:37:43 -0600
Received: from localhost (ahoward@localhost)
	by harp.ngdc.noaa.gov (8.12.11/8.12.11/Submit) with ESMTP id i7UMbhH6011841
	for <nfs@lists.sourceforge.net>; Mon, 30 Aug 2004 16:37:43 -0600
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


we are getting random, un-explained ESTALE errors from our nfs server.  the
files in question are all binaries that get run on our cluster.  none of the
files or their directories have been moved, copied, created, etc. for months.
the export/mount have stayed the same.  in short, nothing has changed.  the
only reason i have seen the error is due to some err trsapping i do in my
crontab files that ensure some daemons are running at all time, eg.

   * * * * * /nfs/mounted/daemon -l logfile > daemon.oe 2>&1

this is obviously for daemons for which it is impossible to have two copies
running simoultaneously.  i can't imagine that this has any affect whatsoever,
i'm simply pointing out that this daemon will run for days on end without
problem, and then exit suddenly with

   no such file ESTALE /nfs/mounted/daemon

showing up in the daemon.oe file.

are there any conditions on client or server i should know about (besides the
obvious ones) that could cause this?

all kernels are

   Linux 2.4.21-15.0.4.EL i686

up2date with the latest nfs-utils

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
