From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 2 of 9] Simplify nfsd4 name encoding.
Date: Thu, 24 Jun 2004 14:46:51 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BdM8R-0001Le-Oe@notabene.cse.unsw.edu.au>
References: <20040624143710.5086.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8h-00023a-Vq
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:07 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BdM8h-0005ee-Jy
	for nfs@lists.sourceforge.net; Wed, 23 Jun 2004 21:47:07 -0700
To: Andrew Morton <akpm@osdl.org>
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



Use opaque xdr encoding routines from xdr.c instead of rolling our own.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4xdr.c |   14 ++------------
 1 files changed, 2 insertions(+), 12 deletions(-)

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-06-23 14:37:06.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2004-06-23 14:37:26.000000000 +1000
@@ -1288,18 +1288,11 @@ static u32 nfs4_ftypes[16] = {
         NF4SOCK, NF4BAD,  NF4LNK, NF4BAD,
 };
 
-static inline int
-xdr_padding(int l)
-{
-       return 3 - ((l - 1) & 3); /* smallest i>=0 such that (l+i)%4 = 0 */
-}
-
 static int
 nfsd4_encode_name(struct svc_rqst *rqstp, int group, uid_t id,
 			u32 **p, int *buflen)
 {
 	int status;
-	u32 len;
 
 	if (*buflen < (XDR_QUADLEN(IDMAP_NAMESZ) << 2) + 4)
 		return nfserr_resource;
@@ -1309,11 +1302,8 @@ nfsd4_encode_name(struct svc_rqst *rqstp
 		status = nfsd_map_uid_to_name(rqstp, id, (u8 *)(*p + 1));
 	if (status < 0)
 		return nfserrno(status);
-	len = (unsigned)status;
-	*(*p)++ = htonl(len);
-	memset((u8 *)*p + len, 0, xdr_padding(len));
-	*p += XDR_QUADLEN(len);
-	*buflen -= (XDR_QUADLEN(len) << 2) + 4;
+	*p = xdr_encode_opaque(*p, NULL, status);
+	*buflen -= (XDR_QUADLEN(status) << 2) + 4;
 	BUG_ON(*buflen < 0);
 	return 0;
 }


-------------------------------------------------------
This SF.Net email sponsored by Black Hat Briefings & Training.
Attend Black Hat Briefings & Training, Las Vegas July 24-29 - 
digital self defense, top technical experts, no vendor pitches, 
unmatched networking opportunities. Visit www.blackhat.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
