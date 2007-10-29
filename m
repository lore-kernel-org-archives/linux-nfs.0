From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: Re: [PATCH 19/27] NFS: Ensure that NFS version 4 mounts use
 NFS_PORT if	nfsport wasn't set
Date: Mon, 29 Oct 2007 10:59:50 -0400
Message-ID: <EXNANE01S0qPzg9uV5400000825@exnane01.hq.netapp.com>
References: <20071026173219.31475.68965.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ImW6q-0007Ww-1R
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 08:00:56 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ImW6v-0000NW-Cc
	for nfs@lists.sourceforge.net; Mon, 29 Oct 2007 08:01:01 -0700
In-Reply-To: <20071026173219.31475.68965.stgit@manray.1015granger.net>
References: <20071026173219.31475.68965.stgit@manray.1015granger.net>
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

But... 2049 is only valid for TCP. Ther eis no such guarantee for RDMA,
SCTP, etc etc. Wouldn't it be safer/better to fail the mount if no port
is specified? This is what rpcbind would do if it fails to resolve the port,
for example.

Tom.

At 01:32 PM 10/26/2007, Chuck Lever wrote:
>Text-based mount option parsing introduced a minor regression in the
>behavior of NFS version 4 mounts.  NFS version 4 is not supposed to require
>a running rpcbind service on the server in order for a mount to succeed.
>
>In other words, if the mount options don't specify a port number, the port
>number is supposed to default to 2049.  For earlier versions of NFS, the
>default port number was zero in order to cause the RPC client to autobind
>to the server's NFS service.
>
>Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
>---
>
> fs/nfs/super.c |    2 ++
> 1 files changed, 2 insertions(+), 0 deletions(-)
>
>diff --git a/fs/nfs/super.c b/fs/nfs/super.c
>index fa517ae..1b2fac8 100644
>--- a/fs/nfs/super.c
>+++ b/fs/nfs/super.c
>@@ -1612,6 +1612,8 @@ static int nfs4_validate_mount_data(void *options,
> 		if (nfs_parse_mount_options((char *)options, args) == 0)
> 			return -EINVAL;
> 
>+		if (args->nfs_server.address.sin_port == 0)
>+			args->nfs_server.address.sin_port = htons(NFS_PORT);
> 		if (!nfs_verify_server_address((struct sockaddr *)
> 						&args->nfs_server.address))
> 			return -EINVAL;
>
>
>-------------------------------------------------------------------------
>This SF.net email is sponsored by: Splunk Inc.
>Still grepping through log files to find problems?  Stop.
>Now Search log events and configuration files using AJAX and a browser.
>Download your FREE copy of Splunk now >> http://get.splunk.com/
>_______________________________________________
>NFS maillist  -  NFS@lists.sourceforge.net
>https://lists.sourceforge.net/lists/listinfo/nfs

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
