From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: NFSD SGID permission problem
Date: Fri, 1 Apr 2005 12:06:17 +1000
Message-ID: <16972.44185.735806.933401@cse.unsw.edu.au>
References: <424CA313.8030508@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DHBYI-000086-Ic
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 18:06:26 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DHBYG-0000dx-UZ
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 18:06:26 -0800
To: Kenneth Sumrall <ksumrall@pacbell.net>
In-Reply-To: message from Kenneth Sumrall on Thursday March 31
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

On Thursday March 31, ksumrall@pacbell.net wrote:
> So, I sent the message below on 12/10/04, and got no response.  So, I'm
> resending it again.  I'd like some feedback on this as I'm not sure my
> fix doesn't create a security hole.

Thanks for being persistent.
You have identified a real issue, but you are right that your fix
isn't really safe. 

The following mimics the logic in chown_common() in open.c.  Note that
it also ignores the setXid bits on directories.

I would appreciate it if you could double check that this fixes your
problem.

This is against 2.4.30-rc1 (and later).  The same problem does not
exist in 2.6.

NeilBrown


### Diffstat output
 ./fs/nfsd/vfs.c |   12 ++++++++----
 1 files changed, 8 insertions(+), 4 deletions(-)

diff ./fs/nfsd/vfs.c~current~ ./fs/nfsd/vfs.c
--- ./fs/nfsd/vfs.c~current~	2005-04-01 12:00:29.000000000 +1000
+++ ./fs/nfsd/vfs.c	2005-04-01 12:04:44.000000000 +1000
@@ -280,13 +280,17 @@ nfsd_setattr(struct svc_rqst *rqstp, str
 	}
 
 	/* Revoke setuid/setgid bit on chown/chgrp */
-	if ((iap->ia_valid & ATTR_UID) && (imode & S_ISUID)
-	 && iap->ia_uid != inode->i_uid) {
+	if ((iap->ia_valid & ATTR_UID)
+	    && (imode & S_ISUID)
+	    && !S_ISDIR(imode)
+	    && iap->ia_uid != inode->i_uid) {
 		iap->ia_valid |= ATTR_MODE;
 		iap->ia_mode = imode &= ~S_ISUID;
 	}
-	if ((iap->ia_valid & ATTR_GID) && (imode & S_ISGID)
-	 && iap->ia_gid != inode->i_gid) {
+	if ((iap->ia_valid & ATTR_GID)
+	    && (imode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)
+	    && !S_ISDIR(imode)
+	    && iap->ia_gid != inode->i_gid) {
 		iap->ia_valid |= ATTR_MODE;
 		iap->ia_mode = imode &= ~S_ISGID;
 	}


-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
