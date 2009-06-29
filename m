From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 15/31] mount.nfs: If port= specifies an unregistered port,
	retry, then fail
Date: Mon, 29 Jun 2009 13:37:09 -0400
Message-ID: <20090629173709.2076.83138.stgit@matisse.1015granger.net>
References: <20090629172704.2076.45402.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:36130 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754018AbZF2Rhi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Jun 2009 13:37:38 -0400
In-Reply-To: <20090629172704.2076.45402.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Suppose a port= option is specified on the mount command line, but not
enough other mount options are specified to avoid an rpcbind query to
discover the NFS service.

If the NFS service isn't registered on [100003, 3, "tcp", port] (even
if the server is listening on the specified port), the legacy mount.nfs
command fails immediately with:

 mount.nfs: mount to NFS server 'server' failed: RPC Error: Success

What's more, this mount request should succeeded if an NFS service is
registered on the specified port for another version and/or protocol.

So instead, let's retry the rpcbind query with the other versions and
transport protocols to be absolutely sure that port won't work with
either version or transport.  Then, if all fails, report:

 mount.nfs: mount to NFS server 'server' failed:
				RPC Error: Program not registered

This change also affects text-based mounts that require negotiation
by the mount.nfs command.

Note that if the mount options specify all four pmap parameters for
NFS, the rpcbind query for the NFS service is skipped entirely.  The
mount command then hangs and times out later if NFS service is not
listening on the requested tuple.  This is unchanged from previous
behavior.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 9661995..73d64a2 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -567,7 +567,8 @@ static int nfs_probe_port(const struct sockaddr *sap, const socklen_t salen,
 				if (nfs_rpc_ping(saddr, salen, prog,
 							*p_vers, *p_prot, NULL))
 					goto out_ok;
-			}
+			} else
+				rpc_createerr.cf_stat = RPC_PROGNOTREGISTERED;
 		}
 		if (rpc_createerr.cf_stat != RPC_PROGNOTREGISTERED &&
 		    rpc_createerr.cf_stat != RPC_TIMEDOUT &&

