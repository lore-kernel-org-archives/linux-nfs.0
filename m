From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 4 of 7 - Protect against NFS requests to create symlinks bigger than one page
Date: Tue, 05 Aug 2003 13:59:23 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E19jsyp-0000n7-00@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19jsyy-0001hW-00
	for <nfs@lists.sourceforge.net>; Mon, 04 Aug 2003 20:59:32 -0700
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@osdl.org>) (for <nfs@lists.sourceforge.net>) By note
	With Smtp ; Tue, 5 Aug 2003 13:59:27 +1000
To: Linus Torvalds <torvalds@osdl.org>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

### Comments for ChangeSet

Such a request would cause the nul terminator to be written
to some other page, and cause havoc.

Also rearrange two tests to avoid the possibility of testing the byte
just past the end of a buffer - doing so can causes an oops with appropriate
kernel-debug config options

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs3xdr.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff ./fs/nfsd/nfs3xdr.c~current~ ./fs/nfsd/nfs3xdr.c
--- ./fs/nfsd/nfs3xdr.c~current~	2003-08-04 11:34:32.000000000 +1000
+++ ./fs/nfsd/nfs3xdr.c	2003-08-04 11:34:32.000000000 +1000
@@ -446,7 +446,7 @@ nfs3svc_decode_symlinkargs(struct svc_rq
 	 */
 	svc_take_page(rqstp);
 	len = ntohl(*p++);
-	if (len <= 0 || len > NFS3_MAXPATHLEN)
+	if (len <= 0 || len > NFS3_MAXPATHLEN || len >= PAGE_SIZE)
 		return 0;
 	args->tname = new = page_address(rqstp->rq_respages[rqstp->rq_resused-1]);
 	args->tlen = len;
@@ -454,7 +454,7 @@ nfs3svc_decode_symlinkargs(struct svc_rq
 	old = (char*)p;
 	vec = &rqstp->rq_arg.head[0];
 	avail = vec->iov_len - (old - (char*)vec->iov_base);
-	while (len > 0 && *old && avail) {
+	while (len && avail && *old) {
 		*new++ = *old++;
 		len--;
 		avail--;
@@ -465,7 +465,7 @@ nfs3svc_decode_symlinkargs(struct svc_rq
 		if (avail > PAGE_SIZE) avail = PAGE_SIZE;
 		old = page_address(rqstp->rq_arg.pages[0]);
 	}
-	while (len > 0 && *old && avail) {
+	while (len && avail && *old) {
 		*new++ = *old++;
 		len--;
 		avail--;


-------------------------------------------------------
This SF.Net email sponsored by: Free pre-built ASP.NET sites including
Data Reports, E-commerce, Portals, and Forums are available now.
Download today and enter to win an XBOX or Visual Studio .NET.
http://aspnet.click-url.com/go/psa00100003ave/direct;at.aspnet_072303_01/01
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
