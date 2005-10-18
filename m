From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: historical question: nfs_rename()
Date: Tue, 18 Oct 2005 11:06:42 -0700
Message-ID: <1129658802.12268.25.camel@lade.trondhjem.org>
References: <044B81DE141D7443BCE91E8F44B3C1E288E56A@exsvl02.hq.netapp.com>
	 <1129651829.8989.17.camel@lade.trondhjem.org> <4355296E.4020606@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-P8cG7IRQ/zP4yh6jxvPv"
Cc: "Lever, Charles" <Charles.Lever@netapp.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ERvrq-0006uv-7b
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 11:07:18 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1ERvra-0003wd-NK
	for nfs@lists.sourceforge.net; Tue, 18 Oct 2005 11:07:18 -0700
To: Peter Staubach <staubach@redhat.com>
In-Reply-To: <4355296E.4020606@redhat.com>
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


--=-P8cG7IRQ/zP4yh6jxvPv
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

ty den 18.10.2005 klokka 12:57 (-0400) skreiv Peter Staubach:
> However, renaming one directory to another directory, when the target
> directory is "empty", should not fail.

Ah... I see now. OK, so when I rewrite the test case to the attached
code then it does indeed succeed.

The following patch should do the right thing then.

Cheers,
  Trond

NFS: Fix rename of directory onto empty directory

 If someone tries to rename a directory onto an empty directory, we
 currently fail and return EBUSY.
 This patch ensures that we try the rename if both source and target
 are directories, and that we fail with a correct error of EISDIR if
 the source is not a directory.

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

Index: linux-2.6/fs/nfs/dir.c
===================================================================
--- linux-2.6.orig/fs/nfs/dir.c
+++ linux-2.6/fs/nfs/dir.c
@@ -1511,9 +1511,11 @@ static int nfs_rename(struct inode *old_
 	 */
 	if (!new_inode)
 		goto go_ahead;
-	if (S_ISDIR(new_inode->i_mode))
-		goto out;
-	else if (atomic_read(&new_dentry->d_count) > 2) {
+	if (S_ISDIR(new_inode->i_mode)) {
+		error = -EISDIR;
+		if (!S_ISDIR(old_inode->i_mode))
+			goto out;
+	} else if (atomic_read(&new_dentry->d_count) > 2) {
 		int err;
 		/* copy the target dentry's name */
 		dentry = d_alloc(new_dentry->d_parent,


--=-P8cG7IRQ/zP4yh6jxvPv
Content-Disposition: inline; filename=main.c
Content-Type: text/x-csrc; name=main.c; charset=utf-8
Content-Transfer-Encoding: 7bit

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>

#define DIRNAME1 "gnurr"
#define DIRNAME2 "gnarg"

void die(char *errmsg)
{
	perror(errmsg);
	exit(1);
}

int main()
{
	int fd;
	int err;

	err = mkdir(DIRNAME1, 0700);
	if (err != 0)
		die("Creation of directory 1 failed");
	err = mkdir(DIRNAME2, 0770);
	if (err != 0)
		die("Creation of directory 2 failed");
	err = rename(DIRNAME1, DIRNAME2);
	if (err != 0)
		die("Rename failed");
}

--=-P8cG7IRQ/zP4yh6jxvPv--



-------------------------------------------------------
This SF.Net email is sponsored by:
Power Architecture Resource Center: Free content, downloads, discussions,
and more. http://solutions.newsforge.com/ibmarch.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
