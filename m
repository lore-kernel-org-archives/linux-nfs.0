From: Junfeng Yang <yjf@stanford.edu>
Subject: [CHECKER] NFS on JFS doesn't sync all file system operations (NFS
 on JFS, 2.6.11)
Date: Sat, 12 Mar 2005 22:56:53 -0800 (PST)
Message-ID: <Pine.GSO.4.44.0503122250560.6688-100000@elaine24.Stanford.EDU>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	<mc@cs.Stanford.EDU>
To: jfs-discussion@lists.sourceforge.net,
	Dave Kleikamp <shaggy@austin.ibm.com>, <nfs@lists.sourceforge.net>
Sender: jfs-discussion-admin@lists.sourceforge.net
Errors-To: jfs-discussion-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/jfs-discussion>,
	<mailto:jfs-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Post: <mailto:jfs-discussion@lists.sourceforge.net>
List-Help: <mailto:jfs-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/jfs-discussion>,
	<mailto:jfs-discussion-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=jfs-discussion>
List-ID: <nfs.lists.sourceforge.net>


Hi,

FiSC found that at link operation and unlink operation on a NFS partion on
top of JFS are not sync'ed.   These warnings show up in JFS but not in
ext2, ext3, so I suspect it's a potential JFS problem.

cat /etc/exports shows:
/mnt/sbd0-export          localhost(rw,sync,no_subtree_check)
/mnt/sbd1-export          localhost(rw,sync,no_subtree_check)

test cases can be found at:

http://fisc.stanford.edu/bug17/crash.c
http://fisc.stanford.edu/bug17/crash-unlink.c

Thanks,
-Junfeng



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
