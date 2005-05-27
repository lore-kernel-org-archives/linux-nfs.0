From: George Garvey <tmwg-nfs@inxservices.com>
Subject: NFS Performance with sync or async
Date: Fri, 27 May 2005 15:16:16 -0700
Message-ID: <20050527221616.GV4944@inxservices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dbn8F-0002fe-HS
	for nfs@lists.sourceforge.net; Fri, 27 May 2005 15:16:43 -0700
Received: from [63.193.79.19] (helo=mwg.inxservices.lan)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Dbn8E-0007bO-2X
	for nfs@lists.sourceforge.net; Fri, 27 May 2005 15:16:43 -0700
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

   Our tech support person told me her applications running over NFS
were really slow.
   We use a copy of each client's data and their installed program
version for testing and support issues. The data can be updated using
a simple zip file from the client.
   This is all stored on an NFS server for support's use. Server and
client are both on the same gigabit switch. The LAN she is connected
to has only gigabit connections on the switch. We're using TCP anyway
for everything (including NFS over a PTP T1: the T1 does go through
the same switch).
   Just FYI, I tried both UDP and TCP, and it seems that TCP was
slightly faster. However, I was using a system I couldn't shut down,
etc., so I didn't remove caching effects well.

   However, what changed things was removing sync from the mount. I
remounted the directory that stores the client systems without async
instead of sync (it is a subdirectory of a directory already mounted
sync).
   The test that I tried (which requires user input, so exact times
aren't very useful) went from several minutes to several seconds! I
know I don't have many hard facts here, but the difference was so
dramatic I didn't care to be exact. With async, the experience was
about the same as running it off a copy on the local disk.

   This solves my problem. I don't see a problem with using async for
this purpose. If a file gets corrupted, it doesn't really matter,
since it is a test system that can be restored at any time. It might
confuse the support person, but hopefully not. The systems don't crash
very often. And that's part of the environment: to be able to restore
the data after testing to its initial state, so it is easy to deal
with if that starts happening. Time will tell.

   The server file system is EXT3 on a couple of mirrored SCSI disks.
hdparm reports about 80 M/sec. I'm not using data=journal: the mounts
uses defaults (except for nocheck). Linux (Gentoo kernel) 2.6.11-r6.
Everything was done with NFS v3.
   I'm reporting this because it is very disturbing. I didn't expect
sync to have that huge an effect on write times. Fortunately, most of
the files we export with NFS are rarely written, mostly read. The
change to sync was fairly recent, which explains why noone complained
previously.
   Is there a technical reason why sync has to be so incredibly slow?
Is the write really as slow as it appears to be? I do know that when I
did all this the server was not being used heavily at all, because
everyone was at lunch (except for one person to answer the phones,
who doesn't use that server much -- and there are very few users on
that LAN). I find it hard to believe it actually took that much time
to do the writes. The amount of data written was perhaps 100 M.


-------------------------------------------------------
This SF.Net email is sponsored by Yahoo.
Introducing Yahoo! Search Developer Network - Create apps using Yahoo!
Search APIs Find out how you can build Yahoo! directly into your own
Applications - visit http://developer.yahoo.net/?fr=offad-ysdn-ostg-q22005
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
