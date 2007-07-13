From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] have NFSv4 nfs sockets bind to the callback address
Date: Fri, 13 Jul 2007 11:06:44 -0400
Message-ID: <20070713110644.4758124a.jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: nfsv4@linux-nfs.org
Return-path: <nfsv4-bounces@linux-nfs.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <nfs.lists.sourceforge.net>

It's been pointed out to me that some clients have complicated routing,
or have HA requirements that require that they prefer particular source
addresses for their NFS sockets. Here's one such scheme that was
described to me:

-------[snip]--------
-  two interfaces, each on different subnets (say eth0 and eth1)
-  an lo:foo virtual interface with a /32 bit netmask (in a different
   IP range than the above two).
-  multiple, equal cost, default routes out each of the two real
   interfaces
-  advertise the /32 lo:foo IP simultaneously, VIA RIPv2, out bot eth0
   and eth1 or
-  add equal cost static routes, on the router, to the lo:foo IP via
   eth0 and eth1
-  you would need something to monitor the routers and remove the route
   on the host if one of them goes down.

without any patch, when you mount, the above configured NFS client will
use one of the eth0/1 IPs, never the lo:foo IP as the src.  Then if the
router out the int it chose to use goes down, it will never recover
cause the NFS server only knows it via that addr.  but if you mounted
the NFS volume using the src addr of lo:foo, it will "just work"
-------[snip]--------

After looking at some different ways to handle this, I think the best
scheme would be to expand the scope of the NFSv4 "clientaddr=" option
so that the nfs socket is also bound to the same local address.

Now that Frank V.M. has done the heavy lifting to allow client side
sockets to bind to a specified address, this patch is fairly simple to
implement for NFSv4. If this is acceptable we might consider doing
the same for v2/3, but I'd prefer to wait until Chuck's string-based
options patch is fully in place rather than having to change the
nfs_mount_options struct.

Thoughts?

Signed-off-by: Jeff Layton <jlayton@redhat.com>

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index ccb4550..aa43c2e 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -372,6 +372,7 @@ static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
 {
 	struct rpc_timeout	timeparms;
 	struct rpc_clnt		*clnt = NULL;
+	struct sockaddr_in	sin_client;
 	struct rpc_create_args args = {
 		.protocol	= proto,
 		.address	= (struct sockaddr *)&clp->cl_addr,
@@ -387,6 +388,14 @@ static int nfs_create_rpc_client(struct nfs_client *clp, int proto,
 	if (!IS_ERR(clp->cl_rpcclient))
 		return 0;
 
+	/* if cl_ipaddr is set then set the src address to be the same */
+	if (clp->cl_ipaddr[0] != '\0' && in4_pton(clp->cl_ipaddr, -1,
+	    (u8 *) &sin_client.sin_addr.s_addr, 0, NULL)) {
+		sin_client.sin_family = AF_INET;
+		sin_client.sin_port = 0;
+		args.saddress = (struct sockaddr *) &sin_client;
+	}
+
 	nfs_init_timeout_values(&timeparms, proto, timeo, retrans);
 	clp->retrans_timeo = timeparms.to_initval;
 	clp->retrans_count = timeparms.to_retries;
@@ -844,11 +853,12 @@ static int nfs4_init_client(struct nfs_client *clp,
 	/* Check NFS protocol revision and initialize RPC op vector */
 	clp->rpc_ops = &nfs_v4_clientops;
 
+	memcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
+
 	error = nfs_create_rpc_client(clp, proto, timeo, retrans, authflavour,
 					RPC_CLNT_CREATE_DISCRTRY);
 	if (error < 0)
 		goto error;
-	memcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
 
 	error = nfs_idmap_new(clp);
 	if (error < 0) {
