From: ralph gonzalez <rgonzale@ibl.bm>
Subject: Force client page cache invalidation?
Date: Tue, 24 Feb 2004 14:30:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <403B9842.9070001@ibl.bm>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Cc: ralph gonzalez <rgonzale@ibl.bm>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AvhKp-0008Mp-GY
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 10:31:11 -0800
Received: from outgoing.logic.bm ([199.172.192.16])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1Avh7k-0005d9-CO
	for nfs@lists.sourceforge.net; Tue, 24 Feb 2004 10:17:40 -0800
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

We tend to run multiple applications on a single client, which all
mmap (usually readonly) the same file on an nfs-mounted volume.
If the file changes on the server, then we would like clients to
see these changes upon closing/reopening this file.

On Solaris (which we are moving from), this would work fine. However
Linux 2.4.22-10mdk (nfs utils 1.0.5) seems to be unwilling to reload
the file cache *when another application already has the file mmapped*.

Therefore each time the file is editted on the server, we have to
force all applications mapping this file (on the client in question)
to close the file *simultaneously*, and then allow them to reopen the
mapping.

*Question*: Instead, is there a way to force the client to reload
the file cache (exclusively for this file)? (So when we subsequently
close/open the file in each application asynchronously, they see the
correct pages.) Maybe there's a simple option or utility I'm missing?

A separate problem is that the file attributes are cached, so the
file cache is only reloaded if we force the client to reread the
file attributes whenever the file is editted on the server. This we
accomplish by the trick of locking/unlocking the file immediately
after opening it, to avoid disabling mount-level attribute caching
via the noac option.

Thanks for any suggestions!
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
