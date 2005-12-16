From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: NFS: fix inadvertent reversion of mode bits during chown
Date: Fri, 16 Dec 2005 11:14:25 -0500
Message-ID: <20051216161425.GA10723@hmsreliant.homelinux.net>
References: <1134656087.7954.7.camel@lade.trondhjem.org> <20051215144945.GA8376@hmsreliant.homelinux.net> <1134658644.7954.13.camel@lade.trondhjem.org> <20051215163834.GB8376@hmsreliant.homelinux.net> <43A19E51.1060901@redhat.com> <1134667920.7944.14.camel@lade.trondhjem.org> <20051215181746.GC8376@hmsreliant.homelinux.net> <20051215194318.GD8376@hmsreliant.homelinux.net> <1134675975.7956.16.camel@lade.trondhjem.org> <20051215195112.GF8376@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net,
	neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EnIEH-00029U-HV
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 08:14:45 -0800
Received: from ra.tuxdriver.com ([24.172.12.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EnIEF-0006A8-Eb
	for nfs@lists.sourceforge.net; Fri, 16 Dec 2005 08:14:45 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20051215195112.GF8376@hmsreliant.homelinux.net>
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

On Thu, Dec 15, 2005 at 02:51:12PM -0500, Neil Horman wrote:
> On Thu, Dec 15, 2005 at 02:46:15PM -0500, Trond Myklebust wrote:
> > On Thu, 2005-12-15 at 14:43 -0500, Neil Horman wrote:
> > 
> > > Heres another alternative.  It removes the clearing of ATTR_KILL_SUID from
> > > notify_change, so we can positively determine that the VFS intent in this case
> > > was to issue a mode change for the purpose of clearing the SUID/SGID bits in the
> > > file.  If we assume that the server will drop the s[g|u]id bits on our behalf,
> > > then we can safely drop the mode modification in nfs_setattr, because we know
> > > that was the only reason that the VFS was requesting that the mode be updated.
> > 
> > Why hack it like this instead of doing it right?
> > 
> Primarily because I don't really see it as a hack, but secondarily because I was
> posting this at the same time that you were posting your suggestion :)
> 
> I'll work up another patch that attempts your suggested fix.
> 
> Regards
> Neil
> 
> > Cheers,
> >   Trond

As promised, heres my updated patch which fixes the permissions regression in
chown entirely within the VFS.  I've tested it, and confirmed that it fixes the
reported problem.  I made a pass through the kernel tree looking for filesystems
which may need to yet call inode_setattr, but it appears (to my somewhat
untrained eye), that at the moment everyone seems to use the call appropriately.
I thought for a moment that nfs_setattr itself might need to make use of the
call, but I believe that nfs_refresh_inode handles all the updates that we would
otherwise need inode_setattr for.  Anywho, tested and working, submitted for
your approval.

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 attr.c      |   41 +++++++++++++++++++++--------------------
 1 file changed, 21 insertions(+), 20 deletions(-)


diff --git a/fs/attr.c b/fs/attr.c
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -69,6 +69,27 @@ int inode_setattr(struct inode * inode, 
 	unsigned int ia_valid = attr->ia_valid;
 	int error = 0;
 
+	if (ia_valid & ATTR_KILL_SUID) {
+		attr->ia_valid &= ~ATTR_KILL_SUID;
+		if (inode->i_mode & S_ISUID) {
+			if (!(ia_valid & ATTR_MODE)) {
+				ia_valid = attr->ia_valid |= ATTR_MODE;
+				attr->ia_mode = inode->i_mode & ~S_ISUID;
+			}
+			attr->ia_mode &= ~S_ISUID;
+		}
+	}
+	if (ia_valid & ATTR_KILL_SGID) {
+		attr->ia_valid &= ~ ATTR_KILL_SGID;
+		if ((inode->i_mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)) {
+			if (!(ia_valid & ATTR_MODE)) {
+				ia_valid = attr->ia_valid |= ATTR_MODE;
+				attr->ia_mode = inode->i_mode & ~S_ISGID;
+			}
+			attr->ia_mode &= ~S_ISGID;
+		}
+	}
+
 	if (ia_valid & ATTR_SIZE) {
 		if (attr->ia_size != i_size_read(inode)) {
 			error = vmtruncate(inode, attr->ia_size);
@@ -125,26 +146,6 @@ int notify_change(struct dentry * dentry
 		attr->ia_atime = now;
 	if (!(ia_valid & ATTR_MTIME_SET))
 		attr->ia_mtime = now;
-	if (ia_valid & ATTR_KILL_SUID) {
-		attr->ia_valid &= ~ATTR_KILL_SUID;
-		if (mode & S_ISUID) {
-			if (!(ia_valid & ATTR_MODE)) {
-				ia_valid = attr->ia_valid |= ATTR_MODE;
-				attr->ia_mode = inode->i_mode;
-			}
-			attr->ia_mode &= ~S_ISUID;
-		}
-	}
-	if (ia_valid & ATTR_KILL_SGID) {
-		attr->ia_valid &= ~ ATTR_KILL_SGID;
-		if ((mode & (S_ISGID | S_IXGRP)) == (S_ISGID | S_IXGRP)) {
-			if (!(ia_valid & ATTR_MODE)) {
-				ia_valid = attr->ia_valid |= ATTR_MODE;
-				attr->ia_mode = inode->i_mode;
-			}
-			attr->ia_mode &= ~S_ISGID;
-		}
-	}
 	if (!attr->ia_valid)
 		return 0;
 
-- 
/***************************************************
 *Neil Horman
 *Software Engineer
 *gpg keyid: 1024D / 0x92A74FA1 - http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
