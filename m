From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: problems using devices via nfsvers3 with 2.6.6. and 2.6.7
Date: Fri, 23 Jul 2004 13:38:36 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16640.34876.166606.352477@cse.unsw.edu.au>
References: <40EAF250.2080202@strike.wu-wien.ac.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Bnqtf-0003zH-2x
	for nfs@lists.sourceforge.net; Thu, 22 Jul 2004 20:38:59 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.34)
	id 1Bnqte-0007H3-JW
	for nfs@lists.sourceforge.net; Thu, 22 Jul 2004 20:38:58 -0700
To: Alexander Bergolth <leo@strike.wu-wien.ac.at>
In-Reply-To: message from Alexander Bergolth on Tuesday July 6
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

On Tuesday July 6, leo@strike.wu-wien.ac.at wrote:
> Hi!
> 
> I'm getting "permission denied" errors when trying to access devices 
> from a 2.6 client that are mounted via nfsvers3 and exported read-only 
> by the server. Using nfsvers2 or a 2.4 kernel doesn't show this error.
> 
> I could reproduce this with kernel 2.6.6-1.435.2.3 (from FC-2) and with
> kernel 2.6.7-1.456_4.rhfc2.at (from ATrpms).
> 
> Any hints?

Yes.  Try the following patch.  It should fix the problem.

NeilBrown


### Diffstat output
 ./fs/nfsd/vfs.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2004-07-23 13:36:36.000000000 +1000
+++ ./fs/nfsd/vfs.c	2004-07-23 13:37:38.000000000 +1000
@@ -376,12 +376,13 @@ static struct accessmap	nfs3_anyaccess[]
 	 * to the server to check for access for things like /dev/null
 	 * (which really, the server doesn't care about).  So
 	 * We provide simple access checking for them, looking
-	 * mainly at mode bits
+	 * mainly at mode bits, and we make sure to ignore read-only
+	 * filesystem checks
 	 */
     {	NFS3_ACCESS_READ,	MAY_READ			},
     {	NFS3_ACCESS_EXECUTE,	MAY_EXEC			},
-    {	NFS3_ACCESS_MODIFY,	MAY_WRITE			},
-    {	NFS3_ACCESS_EXTEND,	MAY_WRITE			},
+    {	NFS3_ACCESS_MODIFY,	MAY_WRITE|MAY_LOCAL_ACCESS	},
+    {	NFS3_ACCESS_EXTEND,	MAY_WRITE|MAY_LOCAL_ACCESS	},
 
     {	0,			0				}
 };


-------------------------------------------------------
This SF.Net email is sponsored by BEA Weblogic Workshop
FREE Java Enterprise J2EE developer tools!
Get your free copy of BEA WebLogic Workshop 8.1 today.
http://ads.osdn.com/?ad_id=4721&alloc_id=10040&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
