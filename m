From: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Subject: lockfiles and caching
Date: Tue, 2 Mar 2004 09:38:42 -0700 (MST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0403020931460.15713-100000@fattire.ngdc.noaa.gov>
Reply-To: "Ara.T.Howard" <Ara.T.Howard@noaa.gov>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyCzh-0003LM-V4
	for nfs@lists.sourceforge.net; Tue, 02 Mar 2004 08:43:45 -0800
Received: from fattire.ngdc.noaa.gov ([140.172.187.207])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AyCcm-0001hK-DM
	for nfs@lists.sourceforge.net; Tue, 02 Mar 2004 08:20:04 -0800
Received: from localhost (ahoward@localhost)
	by fattire.ngdc.noaa.gov (8.11.6/8.11.6) with ESMTP id i22Gcgq16251
	for <nfs@lists.sourceforge.net>; Tue, 2 Mar 2004 09:38:42 -0700
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



i'm working on a distributed application which requires nfs locking.  in
addition to using fcntl based locks i want to have facilities which will work
even without it's use.  i'm wondering about two things

  *) atomically creating a nfs lockfile

    i've read that this can be done by

      - creating a tmpfile (hostname.pid.path.tmplk)
      - linking the lockfile to this file, ignoring status

          path.lk -> hostname.pid.path.tmplk
      - checking the nlink of tmpfile, iff it is 2 then success


    is this still considered the best approach?

  *) forcing uncaching of any attributes

    my current algorithim is

      - stat path
      - link path, refreshfile && unlink refreshfile
      - chmod path, path.mode
      - utime path.stat.atime, path.stat.mtime

    in otherwords i'm doing everything i've read _might_ cause cache
    invalidation.

    are there any other worth trying?


cheers.

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
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
