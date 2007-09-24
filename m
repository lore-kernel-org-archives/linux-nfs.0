From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 01/14] mount.nfs: Provide comments for public network
	functions
Date: Mon, 24 Sep 2007 11:28:28 -0400
Message-ID: <20070924152828.3804.29915.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZps7-0006ov-Ec
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:19 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZpsC-0005vc-37
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 08:29:24 -0700
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

Clean up: Document public functions in util/mount/network.c with block
comments.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |   42 +++++++++++++++++++++++++++++++++++++-----
 1 files changed, 37 insertions(+), 5 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 16b802d..49d3c6b 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -139,6 +139,13 @@ static const unsigned long probe_mnt3_first[] = {
 	0,
 };
 
+/**
+ * nfs_gethostbyname - resolve a hostname to an IPv4 address
+ * @hostname: pointer to a C string containing a DNS hostname
+ * @saddr: returns an IPv4 address 
+ *
+ * Returns 1 if successful, otherwise zero.
+ */
 int nfs_gethostbyname(const char *hostname, struct sockaddr_in *saddr)
 {
 	struct hostent *hp;
@@ -457,6 +464,16 @@ static int probe_mntport(clnt_addr_t *mnt_server)
 		return probe_port(mnt_server, probe_mnt1_first, probe_udp_only);
 }
 
+/**
+ * probe_bothports - discover the RPC endpoints of mountd and NFS server
+ * @mnt_server: pointer to address and pmap argument for mountd results
+ * @nfs_server: pointer to address and pmap argument for NFS server
+ *
+ * Returns 1 if successful, otherwise zero if some error occurred.
+ * Note that the arguments are both input and output arguments.
+ *
+ * A side effect of calling this function is that rpccreateerr is set.
+ */
 int probe_bothports(clnt_addr_t *mnt_server, clnt_addr_t *nfs_server)
 {
 	struct pmap *nfs_pmap = &nfs_server->pmap;
@@ -524,8 +541,10 @@ static int probe_statd(void)
 	return 1;
 }
 
-/*
- * Attempt to start rpc.statd
+/**
+ * start_statd - attempt to start rpc.statd
+ *
+ * Returns 1 if statd is running; otherwise zero.
  */
 int start_statd(void)
 {
@@ -549,7 +568,7 @@ int start_statd(void)
 	return 0;
 }
 
-/*
+/**
  * nfs_call_umount - ask the server to remove a share from it's rmtab
  * @mnt_server: address of RPC MNT program server
  * @argp: directory path of share to "unmount"
@@ -593,6 +612,13 @@ int nfs_call_umount(clnt_addr_t *mnt_server, dirpath *argp)
 	return 0;
 }
 
+/**
+ * mnt_openclnt - get a handle for a remote mountd service
+ * @mnt_server: address and pmap arguments of mountd service
+ * @msock: returns a file descriptor of the underlying transport socket
+ *
+ * Returns an active handle for the remote's mountd service
+ */
 CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
 {
 	struct sockaddr_in *mnt_saddr = &mnt_server->saddr;
@@ -634,6 +660,12 @@ CLIENT *mnt_openclnt(clnt_addr_t *mnt_server, int *msock)
 	return NULL;
 }
 
+/**
+ * mnt_closeclnt - terminate a handle for a remote mountd service
+ * @clnt: pointer to an active handle for a remote mountd service
+ * @msock: file descriptor of the underlying transport socket
+ *
+ */
 void mnt_closeclnt(CLIENT *clnt, int msock)
 {
 	auth_destroy(clnt->cl_auth);
@@ -641,7 +673,7 @@ void mnt_closeclnt(CLIENT *clnt, int msock)
 	close(msock);
 }
 
-/*
+/**
  * clnt_ping - send an RPC ping to the remote RPC service endpoint
  * @saddr: server's address
  * @prog: target RPC program number
@@ -729,7 +761,7 @@ int clnt_ping(struct sockaddr_in *saddr, const unsigned long prog,
 		return 0;
 }
 
-/*
+/**
  * get_client_address - acquire our local network address
  * @saddr: server's address
  * @caddr: filled in with our network address


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
