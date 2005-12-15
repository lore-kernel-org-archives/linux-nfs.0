From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH]: NFS: fix inadvertent reversion of mode bits during chown
Date: Thu, 15 Dec 2005 09:49:45 -0500
Message-ID: <20051215144945.GA8376@hmsreliant.homelinux.net>
References: <20051215130939.GA8111@hmsreliant.homelinux.net> <1134656087.7954.7.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au,
	linux-kernel@vger.kernel.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EmuQo-00043y-3P
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 06:50:06 -0800
Received: from ra.tuxdriver.com ([24.172.12.4])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EmuQm-0006Ux-Im
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 06:50:06 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134656087.7954.7.camel@lade.trondhjem.org>
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

On Thu, Dec 15, 2005 at 09:14:47AM -0500, Trond Myklebust wrote:
> On Thu, 2005-12-15 at 08:09 -0500, Neil Horman wrote:
> > Hey all-
> > 	This problem was reported to me recently that when a process is attempting
> > to change ownership (chown) on a file on a NFS share, it is possible that
> > permissions bits will be reverted to a previous state on the server, even if an
> > exclusive lock is held on the file.  I verified this, and came to find that this
> > occurs if the SUID bit is set on the file.  Basically when a file is chown-ed,
> > the chown_call forcibly strips the SUID/SGID bits from the mode (ostensibly for
> > security purposes).  The VFS then implements this stripping (if the SUID/SGID
> > bits are currently set on the inode in question) by updating the iattr structure
> > in notify_change to not only change the UID/GID of the inode, but also the MODE,
> > using the mode bits in the inode.  This works fine on locally mounted file
> > systems, in which the inodes in ram are only modified by one system, and are in
> > sync with disk contents.  However on NFS, its possible for the a files
> > attributes to be out of sync with the cached inode on a given system sharing the
> > NFS mount.  As such, if system A changes the mode bits on a file on the server,
> > system B preforming a chown on an inode cached locally can inadvertantly revert
> > permissions on the inode to whatever was most recently cached.
> > 
> > I don't think this hole can be 100% closed, as we can guarantee the order of
> > arival of packets to the server between nodes, but we can be sure that the
> > filesystem bits aren't reverted if the accessing programs participate in a
> > locking protocol.  The patch below refreshes the inode and strips the SUID/SGID
> > bits from the latest server side inode->i_mode bits.  This has been tested and
> > prevents the described problem from occuring.
> > 
> > An alternate solution (and one that generates less traffic) may be to simply
> > disallow the setting of ATTR_MODE and (ATTR_UID|ATTR_GID) at the same time in
> > nfs_setattr, but I haven't thought through what all the implications are there.
> 
> Third alternative: Fix the VFS to not do that. That makes the whole
> thing race-free.
> 
I considered this, but I'm not sure thats the right way to go. It seems that the
attribute structure can only set the mode bit, it has no way to represent a
masking of bits.  So to set the mode, the VFS needs to know what the current
mode flags are.  Since the sys_chown code path has no authoritative info on what
the mode bits should be (like chmod does, where the user explicitly specifies
the mode bits), notify_change has to rely on the current mode bits in
inode->i_mode.  We could modify notify_change to not alter the mode bits at all
and leave the ATTR_KILL_SUID flag in the ia_valid field for individual
filesystems to deal with, but I'm not sure thats the better solution, as it
would still leave NFS (and all other filesystems) with the responsibility of
turning the s[u|g]id bits off.

Thanks & Regards
Neil

> Cheers,
>   Trond

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
