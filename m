From: Mark Fasheh <mark.fasheh@oracle.com>
Subject: Re: Announce: new-aops-1 for 2.6.21-rc3
Date: Thu, 15 Mar 2007 14:08:48 -0700
Message-ID: <20070315210848.GG21942@ca-server1.us.oracle.com>
References: <20070315161704.GH8321@wotan.suse.de>
Reply-To: Mark Fasheh <mark.fasheh@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: jfs-discussion@lists.sourceforge.net, xfs@oss.sgi.com,
	cluster-devel@redhat.com, reiserfs-list@namesys.com,
	nfs@lists.sourceforge.net,
	Linux Filesystems <linux-fsdevel@vger.kernel.org>,
	linux-ext4@vger.kernel.org
To: Nick Piggin <npiggin@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
In-Reply-To: <20070315161704.GH8321@wotan.suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Thu, Mar 15, 2007 at 05:17:04PM +0100, Nick Piggin wrote:
> OK, I've gone through and fixed several bugs until the thing actually
> survives fsx-linux for both ext2 and ext3 ordered and writeback (both
> when using the new aops, and the legacy prepare_write path). Actually
> ext3 sometimes breaks, but it does in unpatched kernels anyway.

Attached is a bugfix for a crash folks who use an initrd will hit early on.
	--Mark

--
Mark Fasheh
Senior Software Developer, Oracle
mark.fasheh@oracle.com


From: Mark Fasheh <mark.fasheh@oracle.com>

[PATCH] Populate pagep in simple_write_begin()

This wasn't getting passed back to callers.

Signed-off-by: Mark Fasheh <mark.fasheh@oracle.com>

cbf20bf51ddd6434db935ba29f845a85f3b1ec65
diff --git a/fs/libfs.c b/fs/libfs.c
index 51f9748..602496a 100644
--- a/fs/libfs.c
+++ b/fs/libfs.c
@@ -357,6 +357,8 @@ int simple_write_begin(struct file *file
 	if (!page)
 		return -ENOMEM;
 
+	*pagep = page;
+
 	return simple_prepare_write(file, page, from, from+len);
 }
 
-- 
1.3.3


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
