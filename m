From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: NFS: fix inadvertent reversion of mode bits during chown
Date: Thu, 15 Dec 2005 14:43:18 -0500
Message-ID: <20051215194318.GD8376@hmsreliant.homelinux.net>
References: <20051215130939.GA8111@hmsreliant.homelinux.net> <1134656087.7954.7.camel@lade.trondhjem.org> <20051215144945.GA8376@hmsreliant.homelinux.net> <1134658644.7954.13.camel@lade.trondhjem.org> <20051215163834.GB8376@hmsreliant.homelinux.net> <43A19E51.1060901@redhat.com> <1134667920.7944.14.camel@lade.trondhjem.org> <20051215181746.GC8376@hmsreliant.homelinux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Peter Staubach <staubach@redhat.com>, nfs@lists.sourceforge.net,
	neilb@cse.unsw.edu.au, linux-kernel@vger.kernel.org,
	viro@zeniv.linux.org.uk
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emz0q-0000mg-4H
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 11:43:36 -0800
Received: from ra.tuxdriver.com ([24.172.12.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Emz0o-0002Qc-NA
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 11:43:36 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <20051215181746.GC8376@hmsreliant.homelinux.net>
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

On Thu, Dec 15, 2005 at 01:17:46PM -0500, Neil Horman wrote:
> On Thu, Dec 15, 2005 at 12:32:00PM -0500, Trond Myklebust wrote:
> > On Thu, 2005-12-15 at 11:48 -0500, Peter Staubach wrote:
> > 
> > > I don't think that it can be quite this easy.  I don't think that the 
> > > protocol
> > > requires that the server have this behavior, so, if the client requires it,
> > > then it will need to check to see whether the right thing happened and 
> > > if not,
> > > then make it happen.
> > > 
> > > Perhaps the right answer is a conditional second SETATTR operation to 
> > > correct
> > > the mode if it does not get set right when the uid/gid is changed.
> > 
> > That still allows for dangerous races in which client applications may
> > suddenly find themselves authorised to suid/sgid to the new uid/gid. Any
> > server that does this should probably be mounted using the nosuid mount
> > option and simply not be used for setuid/setgid applications.
> > 
> > As I see it, there are 2 possible options here:
> > 
> >  1) Rely on cached attributes and explicitly clear the suid/sgid mode
> > bit (which is what we do now).
> This isn't a good option.  It opens up an NFS share to inadvertently allow
> access to a file that we shouldn't have rights to change.
> 
> >  2) Rely on the server clearing the suid/sgid mode bit.
> > 
> But you just Nacked my version of the patch which does exactly that, on the
> basis that were trying to second guess the intent of the VFS, so it seems like
> your trying to have it both ways here.  I suppose we could not mask off the
> KILL_SUID flag in ia_valud up in notify_change, and supress the mode
> modification in nfs_setattr based on that KILL_SUID flag (trusting that the
> server will do it for us).  That way we could be clear on the intent of the VFS.
> How does that sound?
> 
> Thanks & Regards
> Neil
> 
> > Trying to fix up the mode to be set inside the filesystem code is an
> > unacceptable practice since we cannot know who the caller is, or what
> > the intentions were.
> > 
> > Cheers,
> >   Trond

Heres another alternative.  It removes the clearing of ATTR_KILL_SUID from
notify_change, so we can positively determine that the VFS intent in this case
was to issue a mode change for the purpose of clearing the SUID/SGID bits in the
file.  If we assume that the server will drop the s[g|u]id bits on our behalf,
then we can safely drop the mode modification in nfs_setattr, because we know
that was the only reason that the VFS was requesting that the mode be updated.

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 attr.c      |    1 -
 nfs/inode.c |   13 +++++++++++++
 2 files changed, 13 insertions(+), 1 deletion(-)


diff --git a/fs/attr.c b/fs/attr.c
--- a/fs/attr.c
+++ b/fs/attr.c
@@ -126,7 +126,6 @@ int notify_change(struct dentry * dentry
 	if (!(ia_valid & ATTR_MTIME_SET))
 		attr->ia_mtime = now;
 	if (ia_valid & ATTR_KILL_SUID) {
-		attr->ia_valid &= ~ATTR_KILL_SUID;
 		if (mode & S_ISUID) {
 			if (!(ia_valid & ATTR_MODE)) {
 				ia_valid = attr->ia_valid |= ATTR_MODE;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -845,6 +845,19 @@ nfs_setattr(struct dentry *dentry, struc
 	if (attr->ia_valid == 0)
 		return 0;
 
+	/*
+	 * If we are modifying UID/GID, and the VFS is 
+	 * explicitly telling us to drop the SUID/SGID bits
+	 * (via the ATTR_KILL_SUID flag), we assume that the
+	 * NFS server is capable of dropping the suid bits
+	 * on our behalf, and so we just drop the mode update
+	 * to prevent inadvertent mode reverts.
+	 */
+	if ((attr->ia_valid & (ATTR_UID|ATTR_GID)) &&
+	    (attr->ia_valid & ATTR_KILL_SUID)) {
+		attr->ia_valid &= ~ATTR_MODE;
+	}
+
 	lock_kernel();
 	nfs_begin_data_update(inode);
 	/* Write all dirty data if we're changing file permissions or size */
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
