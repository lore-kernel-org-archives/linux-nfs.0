From: Daniel Forrest <forrest@lmcg.wisc.edu>
Subject: Re: NFS client does not report accurate mtime when mtime is 0
Date: Mon, 14 Jun 2004 14:41:32 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200406141941.i5EJfWM29182@rda07.lmcg.wisc.edu>
References: <200406141657.i5EGvL812308@rda07.lmcg.wisc.edu> <1087235299.3936.20.camel@lade.trondhjem.org>
Reply-To: Daniel Forrest <forrest@lmcg.wisc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BZxKt-0002Xt-OM
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 12:41:39 -0700
Received: from mail.lmcg.wisc.edu ([144.92.101.145])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BZxKt-00056d-A8
	for nfs@lists.sourceforge.net; Mon, 14 Jun 2004 12:41:39 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-reply-to: <1087235299.3936.20.camel@lade.trondhjem.org> (message from Trond
	Myklebust on Mon, 14 Jun 2004 13:48:19 -0400)
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

Trond,

>> So are you doing this on the server or on the client? If the
>> former, then you shouldn't expect any updates to atime/mtime to be
>> registered until the attribute cache has expired on the client (see
>> "man 5 nfs" for a description of the mount options that control the
>> length of the cache timeout).

It doesn't matter where I set the atime/mtime from.

Certain clients report an incorrect mtime regardless of how long it
has been since the atime/mtime was set.

For instance:


On the server:

# touch -d "00:00:00 1/1/70GMT" timestamp0


Which is creating a file "timestamp0" that did not exist before, so
there are no attributes that can be cached.


On a 2.4.20 client:

$ TZ=GMT stat timestamp0
  File: "timestamp0"
  Size: 0         	Blocks: 0          IO Block: 4096   Regular File
Device: ch/12d	Inode: 14483498    Links: 1    
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (  101/   users)
Access: Thu Jan  1 00:00:00 1970
Modify: Mon Jun 14 19:15:01 2004
Change: Mon Jun 14 19:14:57 2004


Note that in this instance, the returned mtime is equal to the current
time, this is not always the case.  (Also, this incorrect value has
persisted for 25 minutes since I first checked.)  Other 2.4.20 clients
report different (but always incorrect) mtimes, while 2.4.9 clients
report the mtime correctly.


Back on the server:

# touch -d "00:00:01 1/1/70GMT" timestamp1


Which is creating a file "timestamp1" that did not exist before.


Back on the 2.4.20 client:

$ TZ=GMT stat timestamp1
  File: "timestamp1"
  Size: 0         	Blocks: 0          IO Block: 4096   Regular File
Device: ch/12d	Inode: 14483770    Links: 1    
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (  101/   users)
Access: Thu Jan  1 00:00:01 1970
Modify: Thu Jan  1 00:00:01 1970
Change: Mon Jun 14 19:16:13 2004


Note that in this case (1 second into the Epoch) the returned values
are correct on this and all other clients.


In general, when the mtime is 0, the 2.4.20 clients never report the
correct mtime.  Different clients report different mtimes when queried
at the same time.  A specific client will persist in reporting the
same incorrect mtime for a while, but the value does change over time
and never is correct.

-- 
Daniel K. Forrest	Laboratory for Molecular and
forrest@lmcg.wisc.edu	Computational Genomics
			University of Wisconsin, Madison


-------------------------------------------------------
This SF.Net email is sponsored by The 2004 JavaOne(SM) Conference
Learn from the experts at JavaOne(SM), Sun's Worldwide Java Developer
Conference, June 28 - July 1 at the Moscone Center in San Francisco, CA
REGISTER AND SAVE! http://java.sun.com/javaone/sf Priority Code NWMGYKND
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
