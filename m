From: ralph gonzalez <rgonzale@ibl.bm>
Subject: Re: Force client page cache invalidation?
Date: Wed, 25 Feb 2004 10:05:05 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <403CAB91.1030208@ibl.bm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Avzg1-0003wo-At
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 06:06:17 -0800
Received: from outgoing.logic.bm ([199.172.192.16])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1Avzel-0005Wu-2n
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 06:04:59 -0800
Received: from mailproxy.logic.bm ([199.172.192.13] helo=ibl.bm)
	by outgoing.logic.bm with esmtp (Exim 3.36 #2)
	id 1AvzKO-0000Na-00
	for nfs@lists.sourceforge.net; Wed, 25 Feb 2004 09:43:56 -0400
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

[snip]
 >> Linux 2.4.22-10mdk (nfs utils 1.0.5) seems to be unwilling to reload the
 >> file cache *when another application already has the file mmapped*.
 >
 > Which is quite sane semantics for mmap().

Agreed...

[snip]
 >>*Question*: Instead, is there a way to force the client to reload the
 >
 > file cache (exclusively for this file)? (So when we subsequently
 > close/open the file in each application asynchronously, they see the
 > correct pages.) Maybe there's a simple option or utility I'm missing?
 >
 > Linux does not support this sort of kludge and is unlikely to do so for
 > the near future. The VM simply cannot support it.
 >
 > In any case, the fact is that strict POSIX mmap() semantics assume
 > exclusive access to the file on the server while it is mapped on a given
 > client. If you're not providing that, then you are going to be prone to
 > some nasty races whether or not the cache invalidation works like Solaris
 > does.

I wasn't aware of the POSIX semantics. It's a shame, since we've been
using this approach -- multiple readers and single writer -- on Solaris
for 8 years with excellent stability and performance. When we switched to
Linux we found this unexpected and unfriendly behavior:

   If NFS client has the file mmapped while it is edited on the server,
   and the client then opens a second application which mmaps the file
   (without closing the first application), then no matter what you do
   -- close both clients, etc -- the file cache never releases the old
   pages!

-- 
Ralph Gonzalez
rgonzale@ibl.bm



-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
