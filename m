From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsv2 ref leak in 2.6.24?
Date: Sat, 20 Oct 2007 13:12:31 -0400
Message-ID: <1192900351.7440.6.camel@heimdal.trondhjem.org>
References: <200710200233.l9K2X5qx015844@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Erez Zadok <ezk@cs.sunysb.edu>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IjHsI-0006E0-TA
	for nfs@lists.sourceforge.net; Sat, 20 Oct 2007 10:12:35 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IjHsL-0007hQ-PM
	for nfs@lists.sourceforge.net; Sat, 20 Oct 2007 10:12:40 -0700
In-Reply-To: <200710200233.l9K2X5qx015844@agora.fsl.cs.sunysb.edu>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


On Fri, 2007-10-19 at 22:33 -0400, Erez Zadok wrote:
> Trond, good news.  I was able to narrow down the problem to purely the
> client-side, probably dcache/readdir related, and I have a shell script that
> deterministically triggers the problem each time for me (this is a FC6 image
> under Vmware 6.0.1).  Here's a short shell script which reliably triggers
> the "lost files" problem -- I create a file via nfs2 on the client side, and
> sometimes it doesn't show up in readdir, but it is there if you stat it
> directly.

Ah... I got confused as to what you were measuring and where. Looking at
nfs_proc_create(), there is indeed a missing call to
nfs_mark_for_revalidate(). The reason why you need such a call being the
usual one: NFSv2 doesn't provide post-op attributes for the directory.

The patch below ought to fix the problem.

Cheers
  Trond
---------------------- CUT HERE -----------------------
From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Sat, 20 Oct 2007 13:07:21 -0400
NFSv2: Ensure that the directory metadata gets revalidated on file create

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/proc.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index 97669ed..4f80d88 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -211,6 +211,7 @@ nfs_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
 	nfs_fattr_init(&fattr);
 	dprintk("NFS call  create %s\n", dentry->d_name.name);
 	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
+	nfs_mark_for_revalidate(dir);
 	if (status == 0)
 		status = nfs_instantiate(dentry, &fhandle, &fattr);
 	dprintk("NFS reply create: %d\n", status);



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
