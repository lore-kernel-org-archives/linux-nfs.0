From: Miklos.Szeredi@eth.ericsson.se (Miklos Szeredi)
Subject: scheduling in atomic while unexporting
Date: Mon, 19 Jan 2004 12:42:48 +0100 (MET)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200401191142.i0JBgme11875@duna48.eth.ericsson.se>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AiXoP-0005k5-B8
	for nfs@lists.sourceforge.net; Mon, 19 Jan 2004 03:43:21 -0800
Received: from eagle.ericsson.se ([193.180.251.53])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1AiXoN-0000fd-4N
	for nfs@lists.sourceforge.net; Mon, 19 Jan 2004 03:43:19 -0800
To: neilb@cse.unsw.edu.au
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

The following scenario shows some locking problems with nfsd under
2.6.0:

 - export filesystem
 - lazy unmount filesystem
 - unexport filesystem

The following call trace is produced:

   bad: scheduling while atomic!
   Call Trace:
    [schedule+1301/1456] schedule+0x585/0x590
    [__filemap_fdatawrite+164/208] __remove_from_page_cache+0x24/0x60
    [__pagevec_lru_add+121/256] __pagevec_release+0x29/0x40
    [truncate_inode_pages+498/656] truncate_inode_pages+0xc2/0x290
    [__iget+1/96] destroy_inode+0x51/0x60
    [__iget+1/96] destroy_inode+0x51/0x60
    [invalidate_inodes+138/208] dispose_list+0xaa/0xb0
    [prune_icache+100/496] invalidate_inodes+0xa4/0xd0
    [sget+75/368] generic_shutdown_super+0x7b/0x190
    [get_sb_bdev+183/352] kill_anon_super+0x17/0x50
    [generic_shutdown_super+14/400] deactivate_super+0x5e/0xc0
    [_end+274119914/1069647496] svc_export_put+0x82/0x90 [nfsd]
    [_end+273198636/1069647496] cache_clean+0x164/0x250 [sunrpc]
    [_end+273198973/1069647496] cache_flush+0x15/0x50 [sunrpc]
    [_end+274126880/1069647496] nfsd_export_flush+0x38/0x50 [nfsd]
    [_end+274095171/1069647496] nfsd+0x32b/0x3b0 [nfsd]
    [_end+274094360/1069647496] nfsd+0x0/0x3b0 [nfsd]
    [kernel_thread_helper+5/12] kernel_thread_helper+0x5/0xc

The heart of the problem seems to be that cache_clean is holding the
cache_list_lock spinlock while calling cache_put (svc_export_put),
which calls mntput, which may sleep.

Miklos


-------------------------------------------------------
The SF.Net email is sponsored by EclipseCon 2004
Premiere Conference on Open Tools Development and Integration
See the breadth of Eclipse activity. February 3-5 in Anaheim, CA.
http://www.eclipsecon.org/osdn
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
