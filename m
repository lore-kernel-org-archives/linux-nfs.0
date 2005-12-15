From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: NFS: fix inadvertent reversion of mode bits during chown
Date: Thu, 15 Dec 2005 11:38:34 -0500
Message-ID: <20051215163834.GB8376@hmsreliant.homelinux.net>
References: <20051215130939.GA8111@hmsreliant.homelinux.net> <1134656087.7954.7.camel@lade.trondhjem.org> <20051215144945.GA8376@hmsreliant.homelinux.net> <1134658644.7954.13.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org, viro@zeniv.linux.org.uk
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emw88-0003ku-5s
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 08:38:56 -0800
Received: from ra.tuxdriver.com ([24.172.12.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Emw85-0003js-N2
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 08:38:56 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134658644.7954.13.camel@lade.trondhjem.org>
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

On Thu, Dec 15, 2005 at 09:57:24AM -0500, Trond Myklebust wrote:
> On Thu, 2005-12-15 at 09:49 -0500, Neil Horman wrote:
> 
> > I considered this, but I'm not sure thats the right way to go. It seems that the
> > attribute structure can only set the mode bit, it has no way to represent a
> > masking of bits.  So to set the mode, the VFS needs to know what the current
> > mode flags are.  Since the sys_chown code path has no authoritative info on what
> > the mode bits should be (like chmod does, where the user explicitly specifies
> > the mode bits), notify_change has to rely on the current mode bits in
> > inode->i_mode.  We could modify notify_change to not alter the mode bits at all
> > and leave the ATTR_KILL_SUID flag in the ia_valid field for individual
> > filesystems to deal with, but I'm not sure thats the better solution, as it
> > would still leave NFS (and all other filesystems) with the responsibility of
> > turning the s[u|g]id bits off.
> 
> As far as an NFS client is concerned, we don't need to clear the
> suid/sgid bits at all since the server will do it for us anyway. If the
> VFS were to just send us the ATTR_UID/ATTR_GID fields, then we'd be
> fine.
> 
> As for local filesystems, they can be given a helper function that fixes
> up the struct sattr to do the KILL_SUID thing.
> 
> Cheers,
>   Trond
> 
> 
> 
> -------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
> for problems?  Stop!  Download the new AJAX search engine that makes
> searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
> http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs

Then this patch should work just as well (and save the overhead of both adding
the extra getaddr call and the need to add a helper function to all the other
supported file systems to kill the SUID bits that already happens in the VFS.

Thanks & Regards
Neil

Signed-off-by: Neil Horman <nhorman@tuxdriver.com>


 inode.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+)


diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -845,6 +845,22 @@ nfs_setattr(struct dentry *dentry, struc
 	if (attr->ia_valid == 0)
 		return 0;
 
+	/*
+	 * If we are changing UID/GID, lets be sure that we
+	 * have the latest mode attribute.  Conducting a chown,
+	 * causes the suid bits to get dropped, and that in turn 
+	 * can accidentally revert file permissions.
+	 */
+	if ((attr->ia_valid & (ATTR_UID|ATTR_GID)) &&
+	    (attr->ia_valid & ATTR_MODE)) {
+		/*
+		 * We fix this by simply dropping the mode change
+		 * as the NFS server will conditionally drop the 
+		 * the [s|g]uid bits at the server anyway
+		 */
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
