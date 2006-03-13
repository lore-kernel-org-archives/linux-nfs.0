From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] nfs4: fix segfult on errors returned that are < -1000
Date: Mon, 13 Mar 2006 14:09:39 -0500
Message-ID: <1142276979.16692.6.camel@lade.trondhjem.org>
References: <20060313160503.GA27685@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-YD/wcLGsULnqmXx/vlF0"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FIsQT-0000iO-P3
	for nfs@lists.sourceforge.net; Mon, 13 Mar 2006 11:09:53 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1FIsQR-00070g-P7
	for nfs@lists.sourceforge.net; Mon, 13 Mar 2006 11:09:53 -0800
To: Neil Horman <nhorman@tuxdriver.com>
In-Reply-To: <20060313160503.GA27685@hmsreliant.homelinux.net>
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


--=-YD/wcLGsULnqmXx/vlF0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2006-03-13 at 11:05 -0500, Neil Horman wrote:
> Hey all-
> 	This was reported to me last week.  If you attempt to mount an nfsv4
> share, and the mount syscall for that filesystem returns an error code that is
> less than -1000 (of which NFS4 has many), The IS_ERR macro function will
> erroniously return false, and do_kern_mount will pass the error code to called
> functions as though it were a valid pointer.  This patch fixes up the missed
> point in nfs4_get_sb that allows such an error to propogate to do_kern_mount.

Hmm... On a second read through the code, it looks like this can still
cause trouble in nfs_sb_init(), where there is a similar test. The real
fix should be to ensure that nfs4_proc_get_root() always maps the raw
NFSv4 errors into kernel errors.

Cheers,
  Trond

--=-YD/wcLGsULnqmXx/vlF0
Content-Disposition: inline; filename=linux-2.6.16-92-fix_nfsv4_mount.dif
Content-Type: text/plain; name=linux-2.6.16-92-fix_nfsv4_mount.dif; charset=utf-8
Content-Transfer-Encoding: 7bit

Author: Trond Myklebust <Trond.Myklebust@netapp.com>
NFSv4: fix mount segfault on errors returned that are < -1000

It turns out that nfs4_proc_get_root() may return raw NFSv4 errors instead
of mapping them to kernel errors.
Problem spotted by Neil Horman <nhorman@tuxdriver.com>

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/nfs4proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 145a6b7..3f86138 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -1432,7 +1432,7 @@ static int nfs4_proc_get_root(struct nfs
 	if (status == 0)
 		status = nfs4_do_fsinfo(server, fhandle, info);
 out:
-	return status;
+	return nfs4_map_errors(status);
 }
 
 static int _nfs4_proc_getattr(struct nfs_server *server, struct nfs_fh *fhandle, struct nfs_fattr *fattr)

--=-YD/wcLGsULnqmXx/vlF0--



-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
