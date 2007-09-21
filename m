From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 05/19] NFS: use in-kernel mount argument	structure
	for nfsv4 mounts
Date: Thu, 20 Sep 2007 20:33:43 -0400
Message-ID: <1190334823.6763.174.camel@heimdal.trondhjem.org>
References: <EXNANE01AP4MWU5SyR1000004b4@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-QayTgkSuzlwE5dRE+QHu"
Cc: nfs@lists.sourceforge.net
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IYWSt-0003yu-1v
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 17:33:51 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IYWSw-0000lD-8q
	for nfs@lists.sourceforge.net; Thu, 20 Sep 2007 17:33:56 -0700
In-Reply-To: <EXNANE01AP4MWU5SyR1000004b4@exnane01.hq.netapp.com>
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


--=-QayTgkSuzlwE5dRE+QHu
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, 2007-09-10 at 13:44 -0400, Talpey, Thomas wrote:
> NFS: use in-kernel mount argument structure for nfsv4 mounts
> 
> The user-visible nfs4_mount_data does not contain sufficient data to
> describe new mount options, and also is now a legacy structure. Replace
> it with the internal nfs_parsed_mount_data for nfsv4 in-kernel use.
> 
> Signed-off-by: Tom Talpey <tmt@netapp.com>
> Acked-by: Chuck Lever <chuck.lever@oracle.com>

Requires the following fix in order to actually work.

Cheers
  Trond

--=-QayTgkSuzlwE5dRE+QHu
Content-Disposition: inline;
	filename=linux-2.6.23-055-fix_bug_in_nfs4_validate_mount_data.dif
Content-Type: message/rfc822;
	name=linux-2.6.23-055-fix_bug_in_nfs4_validate_mount_data.dif

From: Trond Myklebust <Trond.Myklebust@netapp.com>
Date: Thu, 20 Sep 2007 20:23:51 -0400
NFSv4: Fix a bug in nfs4_validate_mount_data()
Subject: No Subject
Message-Id: <1190334810.6763.173.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit

The previous patch introduced a bug when copying the server address.

Also clarify a copy into the auth_flavours array: currently the two
size calculations are equivalent, but we may decide to change the size
of auth_flavors[] at some point.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 178099f..8c2761f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1539,7 +1539,7 @@ static int nfs4_validate_mount_data(void *options,
 			goto out_no_address;
 		if (copy_from_user(&args->nfs_server.address,
 				   data->host_addr,
-				   sizeof(&args->nfs_server.address)))
+				   sizeof(args->nfs_server.address)))
 			return -EFAULT;
 		if (args->nfs_server.address.sin_port == 0)
 			args->nfs_server.address.sin_port = htons(NFS_PORT);
@@ -1552,9 +1552,9 @@ static int nfs4_validate_mount_data(void *options,
 			args->auth_flavors[0] = RPC_AUTH_UNIX;
 			break;
 		case 1:
-			if (copy_from_user(args->auth_flavors,
+			if (copy_from_user(&args->auth_flavors[0],
 					   data->auth_flavours,
-					   sizeof(args->auth_flavors)))
+					   sizeof(args->auth_flavors[0])))
 				return -EFAULT;
 			break;
 		default:

--=-QayTgkSuzlwE5dRE+QHu
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
--=-QayTgkSuzlwE5dRE+QHu
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--=-QayTgkSuzlwE5dRE+QHu--
